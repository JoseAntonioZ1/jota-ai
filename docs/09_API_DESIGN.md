# JOTA AI — API Design

**Fecha:** 2026-07-20
**Autor:** José Antonio de la Cruz Portal
**Estado:** Borrador para aprobación
**Fuente:** `docs/06_SYSTEM_ARCHITECTURE.md` (sección 4.4, 4.6), `docs/07_AI_ARCHITECTURE.md`, `docs/08_DATABASE_DESIGN.md`
**Posición en el flujo de trabajo:** Documento 9 de 10

---

## 1. Propósito

Definir los contratos REST entre la app Flutter y el backend FastAPI: endpoints, formatos de request/response y manejo de errores, derivados directamente del esquema de base de datos (documento 8) y de las decisiones de comunicación ya tomadas (documento 6, síncrono para el turno de voz).

---

## 2. Convenciones generales

- **Versionado:** todos los endpoints bajo `/api/v1/`, según lo definido en `06_SYSTEM_ARCHITECTURE.md`.
- **Autenticación:** header `Authorization: Bearer <device_token>` en todos los endpoints salvo el de registro de dispositivo. El token se emite una única vez durante el onboarding (UC-01) y se guarda en almacenamiento seguro del dispositivo (`flutter_secure_storage` o equivalente).
- **Formato:** JSON (`application/json`), salvo el endpoint de turno de voz, que acepta `multipart/form-data` (audio binario + metadatos) y puede responder con audio binario o una URL temporal de audio, según se defina en implementación.
- **Paginación:** listas (`reminders`, `contacts`, `conversations`, `action-logs`) usan `limit`/`offset` con `limit` por defecto 20, máximo 50 — suficiente dado el volumen de datos esperado por usuario (uso personal, no multi-tenant masivo).
- **Formato de error estándar:**
```json
{
  "error": {
    "code": "REMINDER_NOT_FOUND",
    "message": "No se encontró el recordatorio solicitado."
  }
}
```
El campo `message` está pensado para depuración/logs, **no** para mostrarse directamente al usuario final (los mensajes amigables de UX se generan en el cliente según el documento 5, sección 8).

---

## 3. Catálogo de endpoints

| Método | Ruta | Propósito | Caso de uso / requisito |
|---|---|---|---|
| POST | `/api/v1/devices` | Registrar dispositivo, emitir token | UC-01 |
| GET | `/api/v1/users/me` | Obtener perfil del usuario actual | UC-01 |
| PATCH | `/api/v1/users/me` | Actualizar nombre / completar onboarding | UC-01 |
| PUT | `/api/v1/users/me/emergency-contact` | Configurar/reemplazar contacto de emergencia | UC-09 |
| POST | `/api/v1/conversations/text-turn` | Enviar mensaje de texto, recibir respuesta | UC-02 |
| POST | `/api/v1/conversations/voice-turn` | Enviar audio, recibir transcripción + respuesta + audio | UC-03 |
| GET | `/api/v1/conversations` | Listar conversaciones pasadas | UC-11 |
| GET | `/api/v1/conversations/{id}/messages` | Ver mensajes de una conversación | UC-11 |
| GET | `/api/v1/reminders` | Listar recordatorios | UC-05 |
| POST | `/api/v1/reminders` | Crear recordatorio (tras confirmación en el cliente) | UC-04 |
| PATCH | `/api/v1/reminders/{id}` | Editar recordatorio | UC-05 |
| DELETE | `/api/v1/reminders/{id}` | Eliminar recordatorio | UC-05 |
| GET | `/api/v1/contacts` | Listar contactos frecuentes | UC-07 |
| POST | `/api/v1/contacts` | Crear contacto | UC-07 |
| PATCH | `/api/v1/contacts/{id}` | Editar contacto | UC-07 |
| DELETE | `/api/v1/contacts/{id}` | Eliminar contacto | UC-07 |
| POST | `/api/v1/contacts/{id}/call-log` | Registrar llamada iniciada (frecuente o emergencia) | UC-08, UC-10 |
| GET | `/api/v1/action-logs` | Listar historial de acciones | UC-11 (FR-06.2) |

**Nota importante:** las llamadas telefónicas y las notificaciones locales las ejecuta el sistema operativo desde el cliente (`url_launcher` / `flutter_local_notifications`), **no** el backend. Los endpoints `call-log` solo registran el evento para el historial (UC-11) — el backend nunca inicia una llamada.

---

## 4. Especificación detallada

### 4.1 Dispositivo y usuario

**`POST /api/v1/devices`** — sin autenticación previa (es el punto de entrada).
```json
// Request
{ "device_fingerprint": "opaque-client-generated-id" }

// Response 201
{
  "user_id": "uuid",
  "device_token": "opaque-secret-token",
  "onboarding_completed": false
}
```
`device_token` se devuelve **una sola vez**; el backend solo almacena su hash (documento 8, sección 3.1).

**`PATCH /api/v1/users/me`**
```json
// Request
{ "name": "Rosa", "onboarding_completed": true }

// Response 200
{ "user_id": "uuid", "name": "Rosa", "onboarding_completed": true }
```

**`PUT /api/v1/users/me/emergency-contact`**
```json
// Request
{ "contact_id": "uuid" }

// Response 200
{ "emergency_contact": { "id": "uuid", "name": "José", "phone_number": "+51..." } }
```
**Error posible:** `404 CONTACT_NOT_FOUND` si `contact_id` no pertenece al usuario autenticado.

---

### 4.2 Conversación

**`POST /api/v1/conversations/text-turn`**
```json
// Request
{ "conversation_id": "uuid|null", "message": "recuérdame tomar mi pastilla a las 3pm" }

// Response 200
{
  "conversation_id": "uuid",
  "reply": "Claro, ¿quieres que te recuerde hoy a las 3:00 p.m.?",
  "intent": "create_reminder",
  "entities": { "description": "tomar tu pastilla", "scheduled_at": "2026-07-20T15:00:00-05:00" }
}
```
Si `conversation_id` es `null`, el backend crea una nueva conversación (nueva fila en `conversations`).

**Regla de negocio explícita:** este endpoint **nunca** crea el recordatorio directamente aunque `intent = "create_reminder"` — solo informa la intención detectada. La app muestra el `ConfirmationCard` (documento 5) y, si el usuario confirma, llama a `POST /api/v1/reminders` por separado con los datos ya confirmados (posiblemente corregidos por el usuario).

**`POST /api/v1/conversations/voice-turn`** (multipart/form-data)
```
campos: conversation_id (opcional), audio (archivo, formato definido en 07_AI_ARCHITECTURE.md sección 6.2)

Response 200 (multipart o JSON con audio en base64, a definir en implementación):
{
  "conversation_id": "uuid",
  "transcript": "recuérdame tomar mi pastilla a las 3pm",
  "reply": "Claro, ¿quieres que te recuerde hoy a las 3:00 p.m.?",
  "intent": "create_reminder",
  "entities": { "description": "tomar tu pastilla", "scheduled_at": "2026-07-20T15:00:00-05:00" },
  "audio_base64": "..."
}
```
**Timeout del cliente:** 25 segundos (alineado con NFR-07, revisado en ADR-008 tras medir la latencia real del LLM en hardware CPU-only); si se supera, la app muestra el error de FR-01.4 sin esperar más.

**`GET /api/v1/conversations?limit=20&offset=0`**
```json
{ "items": [ { "id": "uuid", "started_at": "...", "channel": "voice" } ], "total": 5 }
```

**`GET /api/v1/conversations/{id}/messages`**
```json
{ "items": [ { "role": "user", "content": "...", "created_at": "..." }, { "role": "assistant", "content": "...", "created_at": "..." } ] }
```

---

### 4.3 Recordatorios

**`POST /api/v1/reminders`**
```json
// Request
{ "description": "Tomar tu pastilla", "reminder_type": "medication", "scheduled_at": "2026-07-20T15:00:00-05:00" }

// Response 201
{ "id": "uuid", "description": "Tomar tu pastilla", "reminder_type": "medication", "scheduled_at": "...", "status": "pending" }
```

**`GET /api/v1/reminders?status=pending&limit=20&offset=0`**
```json
{ "items": [ { "id": "uuid", "description": "...", "scheduled_at": "...", "status": "pending" } ], "total": 3 }
```

**`PATCH /api/v1/reminders/{id}`** — cuerpo parcial, cualquier subconjunto de `description`, `reminder_type`, `scheduled_at`, `status`.

**`DELETE /api/v1/reminders/{id}`** → `204 No Content`.

---

### 4.4 Contactos

**`POST /api/v1/contacts`**
```json
// Request
{ "name": "María González", "phone_number": "+51987654321", "photo_url": null }

// Response 201
{ "id": "uuid", "name": "María González", "phone_number": "+51987654321" }
```

**`GET /api/v1/contacts?limit=20&offset=0`**, **`PATCH /api/v1/contacts/{id}`**, **`DELETE /api/v1/contacts/{id}`** — análogos a recordatorios.

**Restricción de negocio:** si se elimina un contacto que es el `emergency_contact_id` vigente de `users`, el backend limpia esa referencia (`ON DELETE SET NULL`, documento 8) y la respuesta incluye `"emergency_contact_cleared": true` para que la app pueda avisar al usuario y redirigir a UC-09.

**`POST /api/v1/contacts/{id}/call-log`**
```json
// Request
{ "call_type": "frequent" }  // o "emergency"

// Response 201
{ "id": "uuid", "action_type": "contact_called", "created_at": "..." }
```

---

### 4.5 Historial de acciones

**`GET /api/v1/action-logs?limit=20&offset=0`**
```json
{ "items": [ { "action_type": "reminder_created", "description": "Recordatorio creado: Tomar tu pastilla, 3:00 p.m.", "created_at": "..." } ], "total": 12 }
```

---

## 5. Manejo de errores HTTP

| Código | Uso |
|---|---|
| `400 Bad Request` | Validación de esquema fallida (Pydantic) |
| `401 Unauthorized` | Token ausente o inválido |
| `404 Not Found` | Recurso no existe o no pertenece al usuario autenticado |
| `408 Request Timeout` | El backend abortó por exceder el timeout de IA (NFR-07); solo aplica a `voice-turn`/`text-turn` |
| `422 Unprocessable Entity` | El LLM no devolvió un JSON procesable tras reintentos internos (degradación de `07_AI_ARCHITECTURE.md`, sección 3.3) — en la práctica, el backend intenta degradar a `intent: "chat"` antes de llegar a este código; se reserva para fallos irrecuperables |
| `500 Internal Server Error` | Fallo no controlado; siempre logueado, nunca expone detalles internos en `message` |
| `503 Service Unavailable` | Ollama u otro proveedor de IA no disponible (NFR-19) |

**Regla:** ningún error devuelve trazas de pila (stack traces) ni detalles de infraestructura en la respuesta — solo en logs del servidor.

---

## 6. Aprobación y siguiente paso

Estos contratos son la referencia para implementar los `routers/` (FastAPI) y los `data/` repositories (Flutter). Con este documento se cierra el diseño técnico; el último documento antes de programar es la planificación temporal.

**Próximo documento:** `10_DEVELOPMENT_ROADMAP.md`
