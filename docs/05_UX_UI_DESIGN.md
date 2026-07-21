# JOTA AI — UX/UI Design

**Fecha:** 2026-07-20
**Autor:** José Antonio de la Cruz Portal
**Estado:** Borrador para aprobación
**Fuente:** `docs/04_USE_CASES.md`, `docs/03_NON_FUNCTIONAL_REQUIREMENTS.md` (NFR-10, NFR-11), `docs/JOTA_AI_CONTEXT.md` (personalidad de JOTA)
**Posición en el flujo de trabajo:** Documento 5 de 10

---

## 1. Propósito

Traducir los casos de uso en pantallas, flujos de navegación y componentes concretos, aplicando los principios de accesibilidad para adultos mayores como restricción de diseño desde el inicio (no como ajuste posterior). Este documento es la referencia visual/funcional para implementar Flutter (documento de arquitectura de sistema y desarrollo posteriores).

**Regla de trazabilidad:** toda pantalla propuesta aquí debe poder señalar a qué caso de uso (`docs/04_USE_CASES.md`) responde.

---

## 2. Principios de diseño para adultos mayores

1. **Voz primero, texto como alternativa.** La interacción por voz debe sentirse tan válida como el texto, nunca secundaria — refleja la naturaleza multimodal de JOTA.
2. **Una acción principal por pantalla.** Evitar pantallas con múltiples decisiones simultáneas; si hay más de una acción posible, una debe ser claramente la primaria (más grande, más contraste).
3. **Nada de gestos complejos.** Sin swipe-to-delete, sin long-press como única vía, sin gestos multitáctiles. Toda acción debe ser alcanzable con un toque simple y, cuando sea destructiva, un segundo toque de confirmación (NFR-11).
4. **Retroalimentación constante.** El usuario nunca debe preguntarse "¿está haciendo algo?" — el avatar, un indicador de carga o un mensaje de texto deben responder a cada acción en menos de 300ms de percepción inmediata, incluso si la respuesta final tarda más (ver Indicador de latencia, sección 6.4).
5. **Lenguaje simple, cero jerga técnica.** Ningún texto de interfaz usa términos como "sincronizando", "token", "sesión expirada" — siempre lenguaje cotidiano ("Guardando tu recordatorio...", "No pude escucharte bien, ¿puedes repetir?").
6. **Consistencia por encima de la novedad.** Los mismos componentes (botón de confirmación, botón de emergencia, tarjeta de recordatorio) se ven y comportan igual en todas las pantallas donde aparecen.
7. **Tolerancia al error, no prevención agresiva.** Preferir permitir corregir fácilmente ("Editar" siempre visible) antes que bloquear con validaciones estrictas que generen mensajes de error confusos.

---

## 3. Sistema de diseño (design tokens)

### 3.1 Tipografía
| Token | Valor | Uso |
|---|---|---|
| `font.body` | 18sp (escalable hasta 200% con ajustes de sistema, NFR-10) | Texto de conversación, listas |
| `font.title` | 24sp | Títulos de pantalla |
| `font.button` | 20sp, semibold | Texto de botones |
| Familia tipográfica | Sans-serif de alta legibilidad (p. ej. Atkinson Hyperlegible o similar disponible sin costo) | Todo el sistema |

### 3.2 Color y contraste
| Token | Uso | Contraste mínimo |
|---|---|---|
| `color.primary` | Acciones principales, avatar en estado activo | ≥4.5:1 sobre fondo (NFR-10) |
| `color.emergency` | Botón de emergencia (rojo, reservado exclusivamente para esta acción) | ≥4.5:1 |
| `color.background` | Fondo neutro, alto contraste con texto | ≥4.5:1 con `font.body` |
| `color.error` | Mensajes de error/confusión | Nunca es el único indicador (siempre acompañado de texto e ícono, no solo color) |

**Regla:** el color rojo (`color.emergency`) se usa **únicamente** para el botón de emergencia, en ninguna otra parte de la interfaz, para que el usuario lo asocie de forma inequívoca.

### 3.3 Espaciado y tamaño táctil
| Token | Valor |
|---|---|
| `touch.target.min` | 48dp × 48dp (NFR-10) |
| `spacing.between.targets` | ≥8dp, para evitar toques accidentales |
| `spacing.screen.padding` | 24dp en los bordes de pantalla |

### 3.4 Iconografía
- Íconos siempre acompañados de texto (nunca solo ícono), salvo el botón de emergencia y el micrófono, que son universalmente reconocibles y de uso muy frecuente.

---

## 4. Arquitectura de información (inventario de pantallas)

| Ruta (GoRouter) | Pantalla | Caso(s) de uso |
|---|---|---|
| `/onboarding` | Configuración inicial (flujo multi-paso) | UC-01 |
| `/home` | Pantalla principal (avatar + conversación) | UC-02, UC-03 |
| `/reminders` | Lista de recordatorios | UC-05 |
| `/reminders/new` | Crear recordatorio (formulario guiado, respaldo de la vía por voz) | UC-04 |
| `/reminders/:id/edit` | Editar recordatorio | UC-05 |
| `/contacts` | Lista de contactos frecuentes | UC-07, UC-08 |
| `/contacts/new` o `/contacts/:id/edit` | Agregar/editar contacto | UC-07 |
| `/settings/emergency-contact` | Configurar/actualizar contacto de emergencia | UC-09 |
| `/history` | Historial (conversaciones y acciones) | UC-11 |

El **botón de emergencia** (UC-10) no es una ruta — es un componente global persistente disponible desde `/home`, `/reminders` y `/contacts` (ver sección 6.3).

---

## 5. Flujo de navegación

```mermaid
flowchart TD
  Start([Primera apertura]) --> Onboarding[/onboarding]
  Onboarding --> Home[/home]

  Home -->|icono recordatorios| RemindersList[/reminders]
  Home -->|icono contactos| ContactsList[/contacts]
  Home -->|icono historial| History[/history]
  Home -->|boton emergencia global| EmergencyConfirm{Confirmar llamada}

  RemindersList -->|nuevo| ReminderNew[/reminders/new]
  RemindersList -->|editar| ReminderEdit[/reminders/:id/edit]
  ReminderNew --> RemindersList
  ReminderEdit --> RemindersList

  ContactsList -->|nuevo/editar| ContactForm[/contacts/new o edit]
  ContactsList -->|configurar emergencia| EmergencySettings[/settings/emergency-contact]
  ContactForm --> ContactsList

  EmergencyConfirm -->|confirmado| NativeCall[(Llamada nativa)]
  EmergencyConfirm -->|sin contacto configurado| EmergencySettings
  EmergencySettings --> ContactsList
```

---

## 6. Componentes reutilizables clave

### 6.1 `AvatarWidget`
**Usa:** FR-02.1, FR-02.2
**Estados visuales (MVP):** `idle/esperando`, `escuchando`, `pensando`, `hablando`.
**Comportamiento:**
- Ocupa una posición fija y prominente en `/home` (tercio superior de la pantalla).
- En `hablando`, la boca reacciona a la amplitud del audio TTS reproducido (FR-02.2), no a visemas.
- Transición entre estados siempre animada (nunca un cambio abrupto/instantáneo) para reforzar la sensación de "ser".

### 6.2 `ConfirmationCard`
**Usa:** UC-04, UC-08 (patrón identificado en la sección 6 de Use Cases)
**Estructura:** título breve ("¿Es correcto?"), resumen de lo entendido en una sola línea legible, dos botones grandes: "Sí, confirmar" (primario) y "No, corregir" (secundario), ambos ≥48dp de alto.
**Regla:** nunca se ejecuta una acción derivada de lenguaje natural (crear recordatorio, iniciar llamada) sin pasar por este componente.

### 6.3 `EmergencyButton` (global)
**Usa:** UC-10
**Comportamiento:** botón flotante o de barra superior, visible en todas las pantallas principales (`/home`, `/reminders`, `/contacts`, `/history`), color `color.emergency` exclusivo, siempre en la misma posición (esquina superior derecha) para generar memoria muscular.
**Interacción:** un toque → `ConfirmationCard` de emergencia → confirmar → llamada nativa. Si no hay contacto de emergencia configurado, el segundo paso redirige a `/settings/emergency-contact` con un mensaje explicativo, nunca un error técnico.

### 6.4 `LatencyIndicator` ("sigo aquí")
**Usa:** UC-03, alternate flow 3a; NFR-01
**Comportamiento:** si han pasado más de 1.5s desde que el usuario terminó de hablar sin respuesta del sistema, se activa una señal breve (pulso visual en el avatar en estado "pensando" + sonido corto opcional) que se repite cada ~2s hasta que llegue la respuesta o se dispare el timeout de NFR-07.
**Justificación:** evita que el silencio se interprete como falla del sistema (riesgo de UX documentado desde el análisis inicial).

### 6.5 `VoiceInputButton`
**Usa:** UC-03
**Comportamiento:** botón circular grande (≥64dp) en la parte inferior de `/home`, con estados visuales propios (inactivo / grabando) independientes del `AvatarWidget`, para que el usuario siempre sepa si el micrófono está activo sin depender solo de la animación del avatar.

### 6.6 `ReminderListItem` / `ContactListItem`
**Estructura común:** texto principal grande, ícono de acción secundaria (editar) siempre visible (no oculto tras gestos), acción de eliminar solo accesible tras entrar al detalle/edición (evita eliminaciones accidentales desde la lista).

---

## 7. Wireframes (representación textual)

### 7.1 `/home` — Pantalla principal

```
┌───────────────────────────────────┐
│  [Recordatorios] [Contactos] [🚨] │  <- barra superior, EmergencyButton a la derecha
│                                    │
│           ┌───────────┐           │
│           │  AVATAR   │           │  <- AvatarWidget, estado visible
│           │  (JOTA)   │           │
│           └───────────┘           │
│        "Esperando tu mensaje"     │  <- texto de estado, refuerza el estado visual
│                                    │
│  ┌──────────────────────────────┐ │
│  │  Hilo de conversación...     │ │
│  │  Tú: ...                     │ │
│  │  JOTA: ...                   │ │
│  └──────────────────────────────┘ │
│                                    │
│  [Escribe un mensaje.....] [➤]    │
│              (( 🎙️ ))             │  <- VoiceInputButton, grande, centrado
└───────────────────────────────────┘
```

### 7.2 `/reminders/new` — Crear recordatorio (con confirmación)

```
Paso 1 (entrada):
┌───────────────────────────────────┐
│  Nuevo recordatorio                │
│                                    │
│  ¿Qué quieres recordar?           │
│  [________________________]      │
│                                    │
│  ¿Cuándo?                         │
│  [ Fecha ]   [ Hora ]             │
│                                    │
│           [ Continuar ]           │
└───────────────────────────────────┘

Paso 2 (ConfirmationCard):
┌───────────────────────────────────┐
│  ¿Es correcto?                    │
│                                    │
│  "Tomar tu pastilla"               │
│  Hoy a las 3:00 p.m.               │
│                                    │
│   [ Sí, confirmar ]  [ Corregir ] │
└───────────────────────────────────┘
```

### 7.3 Confirmación de emergencia (overlay global)

```
┌───────────────────────────────────┐
│              🚨                   │
│                                    │
│   ¿Llamar ahora a José (hijo)?    │
│                                    │
│   [ Sí, llamar ]   [ Cancelar ]   │
└───────────────────────────────────┘
```

---

## 8. Estados vacíos y de error

| Situación | Tratamiento |
|---|---|
| Sin recordatorios aún | Ilustración simple del avatar + texto "Aún no tienes recordatorios. Puedes decirme 'recuérdame...' o tocar 'Nuevo'." |
| Sin conexión / backend no responde (NFR-07, NFR-19) | Mensaje: "No puedo conectarme ahora. Intenta de nuevo en un momento." + botón "Reintentar", avatar en estado neutro (nunca "hablando" sin respuesta real) |
| STT no reconoce audio (UC-03, 2a) | "No pude escucharte bien. ¿Puedes intentar de nuevo?" + `VoiceInputButton` reactivado automáticamente |
| Sin contacto de emergencia (UC-10, 1a) | Redirección inmediata a `/settings/emergency-contact` con mensaje explicativo, no un bloqueo silencioso |

---

## 9. Checklist de accesibilidad (verificación previa a implementación)

- [ ] Todo texto cumple contraste ≥4.5:1 (NFR-10).
- [ ] Todo elemento interactivo mide ≥48dp (NFR-10).
- [ ] Ninguna acción irreversible ocurre sin `ConfirmationCard` (NFR-11).
- [ ] Ninguna pantalla depende de un gesto distinto al toque simple.
- [ ] Todo estado de carga/espera tiene retroalimentación visual dentro de 300ms.
- [ ] El botón de emergencia es visible sin scroll en las pantallas principales.
- [ ] Los textos de error usan lenguaje simple, verificado sin jerga técnica.

---

## 10. Aprobación y siguiente paso

Este diseño es la referencia para la capa de presentación en Flutter. Las decisiones de aquí (componentes, rutas, estados) alimentan directamente el documento de System Architecture, donde se define cómo estos componentes se conectan con el dominio y los servicios de IA.

**Próximo documento:** `06_SYSTEM_ARCHITECTURE.md`
