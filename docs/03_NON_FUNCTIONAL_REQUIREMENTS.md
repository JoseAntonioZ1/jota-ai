# JOTA AI — Non-Functional Requirements

**Fecha:** 2026-07-20
**Autor:** José Antonio de la Cruz Portal
**Estado:** Borrador para aprobación
**Fuente:** `docs/01_VISION_DOCUMENT.md` (sección 9 — Criterios de éxito), `docs/02_FUNCTIONAL_REQUIREMENTS.md`
**Posición en el flujo de trabajo:** Documento 3 de 10

---

## 1. Propósito

Cerrar con valores numéricos concretos los umbrales que el Vision Document y los Functional Requirements dejaron pendientes (latencia, precisión de voz, disponibilidad, seguridad), y definir las cualidades del sistema que no son "una funcionalidad" pero determinan si el producto es usable, seguro y mantenible.

**Regla de trazabilidad:** todo umbral aquí definido reemplaza cualquier valor "a definir" mencionado en documentos anteriores. Desde este punto, estos son los números oficiales del proyecto.

## 2. Convenciones

- **ID:** `NFR-XX`.
- **Prioridad:** Must / Should / Could (igual que Functional Requirements).
- **Método de verificación:** cómo se comprobará el cumplimiento (medición, prueba, inspección).

---

## 3. Rendimiento y latencia

### NFR-01 — Latencia total de respuesta por voz
**Requisito (revisado tras spike de Fase 1, ver ADR-008):** Desde que el usuario termina de hablar hasta que JOTA comienza a reproducir audio de respuesta, el tiempo no debe superar **15 segundos** en el hardware de referencia del proyecto (equipo del autor, CPU sin aceleración GPU).
**Prioridad:** Must
**Justificación original:** por encima de ~3s, un adulto mayor tiende a asumir que el sistema no funcionó (riesgo técnico #1 en `ANALISIS_ARQUITECTONICO.md`). Ese umbral de 3s sigue siendo el ideal de UX y es el objetivo para una futura iteración con GPU/nube (ver NFR-23), pero **no es alcanzable en el hardware CPU-only disponible para esta tesis** — medido empíricamente en la Fase 1 (`backend/spikes/`): el LLM por sí solo toma 5-19s incluso con el modelo local más pequeño confiable (Llama 3.2 3B). Se documenta como limitación de hardware conocida, no como incumplimiento oculto.
**Verificación:** Medición cronometrada en al menos 20 interacciones de prueba, reportando p50 y p95.
**Mitigación:** dado que la espera real es de varios segundos, la mitigación deja de ser una señal breve de "sigo aquí" y pasa a ser una experiencia de espera diseñada explícitamente (ver `05_UX_UI_DESIGN.md`, sección 6.4 revisada): el avatar permanece en "pensando" de forma continua, con un mensaje de texto tranquilizador si la espera supera ~5s.
**Camino de mejora futura:** si en una iteración posterior se dispone de GPU o se activa un proveedor en la nube (Groq/OpenAI) vía la abstracción `AIProvider` (NFR-23), el umbral ideal de 3s vuelve a ser la meta — el cambio es de configuración, no de arquitectura.

### NFR-02 — Desglose de latencia por componente (medido, Fase 1)
**Requisito:** valores medidos empíricamente en `backend/spikes/` con el modelo confirmado (Llama 3.2 3B + Whisper base + Piper): STT ≈ 1.9s, generación LLM ≈ 5-19s (prom. 11.8s), TTS ≈ 0.3-0.5s (tras cargar el modelo), overhead ≈ 0.5s. Suma realista ≈ 12-15s, consistente con NFR-01.
**Prioridad:** Should
**Verificación:** Logging de tiempos por etapa en el backend durante pruebas (ya validado una vez en el spike; repetir con logging productivo en Fase 2).

### NFR-03 — Tiempo de arranque de la app
**Requisito:** La app debe estar lista para interactuar (avatar visible, en estado "esperando") en menos de **4 segundos** desde que se abre, en un dispositivo gama media-baja.
**Prioridad:** Should
**Verificación:** Medición manual en dispositivo de prueba definido en System Architecture.

### NFR-04 — Fluidez de animación del avatar
**Requisito:** Las animaciones del avatar (Rive) deben mantener un mínimo de 30 FPS en el dispositivo de referencia.
**Prioridad:** Should
**Verificación:** Inspección con herramientas de profiling de Flutter (DevTools).

---

## 4. Precisión y calidad de IA

### NFR-05 — Precisión de reconocimiento de voz (STT)
**Requisito:** Whisper (o el modelo STT elegido) debe lograr una Tasa de Error de Palabra (WER) igual o menor a **20%** sobre un conjunto de prueba de grabaciones de adultos mayores hablando español.
**Prioridad:** Must
**Justificación:** Es el requisito con mayor incertidumbre del proyecto (riesgo técnico #4 en `ANALISIS_ARQUITECTONICO.md`); debe validarse empíricamente lo antes posible, no asumirse.
**Verificación:** Conjunto de al menos 20 grabaciones reales de adultos mayores, transcripción manual de referencia, cálculo de WER.
**Plan de contingencia:** Si el WER supera 20% de forma consistente, evaluar modelo Whisper de mayor tamaño, normalización de audio (reducción de ruido), o ajuste de UX (confirmación por texto de lo entendido antes de ejecutar acciones).

### NFR-06 — Coherencia conversacional mínima
**Requisito:** El modelo de lenguaje debe responder de forma coherente con el contexto de sesión (FR-01.3) en al menos **85%** de un conjunto de pruebas de conversación de referencia (diseñado manualmente).
**Prioridad:** Should
**Verificación:** Set de 15-20 diálogos de prueba evaluados manualmente contra un criterio de "respuesta coherente / no coherente".

### NFR-07 — Comportamiento ante fallos de IA
**Requisito (revisado tras spike de Fase 1):** Si el modelo de lenguaje no responde dentro de **25 segundos** (timeout — margen sobre el máximo observado de ~19-20s en el spike), el sistema debe abortar y mostrar el mensaje de error amigable de FR-01.4, nunca dejar la interfaz "colgada" sin retroalimentación.
**Prioridad:** Must
**Verificación:** Prueba de simulación de caída/latencia del servicio de IA.

---

## 5. Usabilidad y accesibilidad

### NFR-08 — Puntaje de usabilidad (SUS)
**Requisito:** El sistema debe alcanzar un puntaje **System Usability Scale (SUS) ≥ 68** ("aceptable") en las pruebas con el grupo de adultos mayores definido en el plan de validación.
**Prioridad:** Must
**Verificación:** Cuestionario SUS estándar de 10 ítems aplicado post-tarea.

### NFR-09 — Tasa de finalización de tareas
**Requisito:** Al menos **75%** de los participantes de prueba deben poder completar sin ayuda externa las tareas básicas: enviar un mensaje de voz, crear un recordatorio, llamar a un contacto de emergencia.
**Prioridad:** Must
**Verificación:** Observación estructurada durante sesiones de prueba de usabilidad (n a definir, referencia mínima 5-8 participantes por ser un estudio cualitativo de tesis).

### NFR-10 — Accesibilidad visual (WCAG orientativo)
**Requisito:** Contraste de color mínimo 4.5:1 para texto normal (WCAG 2.1 AA), tamaño de fuente por defecto ≥18sp con soporte de escalado hasta 200%, área táctil mínima de 48dp por elemento interactivo.
**Prioridad:** Must
**Verificación:** Inspección con checklist WCAG 2.1 AA aplicable a apps móviles + prueba con herramienta de accesibilidad de Flutter.

### NFR-11 — Tolerancia a error del usuario
**Requisito:** Ninguna acción irreversible (llamar, eliminar recordatorio/contacto) se ejecuta sin una confirmación explícita de un solo toque.
**Prioridad:** Must
**Verificación:** Revisión de flujos de UX (documento 5) contra este requisito.

---

## 6. Seguridad y privacidad

### NFR-12 — Cifrado en tránsito
**Requisito:** Toda comunicación entre la app Flutter y el backend FastAPI debe usar HTTPS/TLS, sin excepciones incluso en entornos de prueba.
**Prioridad:** Must
**Verificación:** Inspección de configuración de red y certificados.

### NFR-13 — Cifrado y minimización de datos en reposo
**Requisito:** Los datos sensibles (recordatorios de medicación, contactos de emergencia, historial de conversación) deben almacenarse cifrados en PostgreSQL a nivel de campo o disco, y el audio crudo de voz **no se conserva** más allá del tiempo necesario para transcribirlo (se descarta tras generar el texto, salvo consentimiento explícito del usuario para guardarlo).
**Prioridad:** Must
**Verificación:** Revisión de esquema de base de datos (documento 8) y del flujo de manejo de audio (documento 7).

### NFR-14 — Cumplimiento normativo local
**Requisito:** El manejo de datos personales debe alinearse con la Ley N.º 29733 (Ley de Protección de Datos Personales, Perú), en particular por tratarse de datos de salud (medicación), considerados datos sensibles bajo dicha ley: consentimiento informado explícito y explicado en lenguaje simple durante el onboarding.
**Prioridad:** Must
**Verificación:** Checklist de cumplimiento incluido como anexo en la tesis; texto de consentimiento revisado.

### NFR-15 — Gestión de permisos nativos
**Requisito:** (Refuerza FR-00.2) Ningún permiso del sistema operativo (micrófono, contactos, llamadas) se solicita de forma anticipada o en bloque; se solicita en el momento en que la funcionalidad correspondiente se usa por primera vez.
**Prioridad:** Must
**Verificación:** Prueba manual del flujo de permisos en Android.

### NFR-16 — Sin telemetría/analítica de terceros no declarada
**Requisito:** No se integran SDKs de analítica o publicidad de terceros que recolecten datos del usuario sin declaración explícita en la tesis y consentimiento del usuario.
**Prioridad:** Must
**Verificación:** Revisión de dependencias del proyecto (`pubspec.yaml`, `requirements.txt`).

---

## 7. Disponibilidad y confiabilidad

### NFR-17 — Disponibilidad durante pruebas
**Requisito:** El sistema debe estar disponible y operativo durante las ventanas de prueba de usabilidad y la sustentación de tesis (no se define un SLA de producción 24/7, dado que no es un servicio comercial).
**Prioridad:** Must
**Verificación:** Checklist de "pre-vuelo" antes de cada sesión de prueba/demo (servicios de IA activos, backend accesible, base de datos migrada).

### NFR-18 — Plan de contingencia de demo
**Requisito:** Debe existir un entorno de respaldo (grabación en video o instancia local) utilizable si el entorno de red/servidor falla durante la sustentación.
**Prioridad:** Should
**Verificación:** Existencia documentada del plan de contingencia (riesgo de tesis #3 en `ANALISIS_ARQUITECTONICO.md`).

### NFR-19 — Tolerancia a fallos del backend
**Requisito:** Si el backend no está disponible, la app debe informarlo claramente en la interfaz (no un crash) y permitir funciones que no dependen de red (ver recordatorios ya guardados localmente, si aplica).
**Prioridad:** Should
**Verificación:** Prueba de desconexión de red simulada.

---

## 8. Mantenibilidad y calidad de código

### NFR-20 — Conformidad arquitectónica
**Requisito:** El código debe respetar la separación `presentation/domain/data` (Flutter) y `api/services/repositories/models/schemas` (FastAPI) definida en `CLAUDE.md`, verificable por revisión manual o linting de estructura.
**Prioridad:** Must
**Verificación:** Revisión de estructura de carpetas en cada entrega, previo a cada commit relevante.

### NFR-21 — Cobertura de pruebas mínima en lógica de dominio
**Requisito:** La capa de dominio (casos de uso / reglas de negocio) debe tener pruebas unitarias que cubran al menos los flujos principales de cada Functional Requirement "Must".
**Prioridad:** Should
**Verificación:** Reporte de cobertura (`flutter test --coverage`, `pytest --cov`).

### NFR-22 — Documentación de decisiones arquitectónicas
**Requisito:** Toda decisión técnica no trivial (elección de modelo de IA, patrón de sincronización avatar-voz, etc.) debe registrarse como un Architecture Decision Record (ADR) breve.
**Prioridad:** Should
**Verificación:** Existencia de carpeta `docs/adr/` con al menos una entrada por decisión relevante, a partir del documento 6 (System Architecture).

---

## 9. Escalabilidad y portabilidad

### NFR-23 — Sustitución del proveedor de IA
**Requisito:** (Cierra el criterio de éxito arquitectónico del Vision Document, sección 9) Debe ser posible sustituir Ollama/Llama 3 por otro proveedor (OpenAI, Mistral, Gemma) implementando una única interfaz `AIProvider`, sin modificar la capa de dominio ni la UI.
**Prioridad:** Must
**Verificación:** Ejercicio concreto de sustitución documentado (al menos como prueba de integración con un segundo proveedor, aunque no se use en producción).

### NFR-24 — Compatibilidad de dispositivos
**Requisito:** La app debe funcionar en Android 8.0 (API 26) o superior, dado que es común que adultos mayores (o sus familiares) usen equipos de gama media-baja no recientes. Soporte iOS queda fuera de alcance del MVP salvo que se determine lo contrario.
**Prioridad:** Should
**Verificación:** Prueba en al menos un dispositivo físico o emulador con API 26-28.

### NFR-25 — Idioma
**Requisito:** El MVP soporta únicamente español (Perú); no se requiere internacionalización (i18n) para la tesis.
**Prioridad:** Must
**Verificación:** N/A — se declara como restricción de alcance, no como funcionalidad a construir.

---

## 10. Matriz de cierre de pendientes (Vision Document → valores definitivos)

| Pendiente en Vision Document (sección 9) | Valor cerrado aquí |
|---|---|
| Umbral de latencia percibida (referencia inicial ≤3s) | NFR-01: **revisado a ≤15s** tras el spike empírico de la Fase 1 (hardware CPU-only sin GPU) — ver ADR-008. El ≤3s original queda como meta futura si se migra a GPU/nube. |
| N de usuarios para validación de usabilidad | NFR-09: referencia mínima 5-8 participantes (estudio cualitativo) |
| Score mínimo de usabilidad (SUS ≥68 propuesto) | NFR-08: confirmado SUS ≥68 |
| Prueba de sustitución de proveedor IA | NFR-23: definida como ejercicio de integración obligatorio |
| Modelo LLM definitivo para el MVP | Llama 3.2 3B (vía Ollama), confirmado empíricamente en la Fase 1 — ver ADR-008 |

---

## 11. Aprobación y siguiente paso

Estos umbrales son ahora vinculantes para el diseño de UX (documento 5), la Arquitectura de Sistema (documento 6) y la Arquitectura de IA (documento 7). Cualquier decisión técnica que no pueda cumplir un requisito "Must" debe documentarse como una excepción justificada, no ignorarse silenciosamente.

**Próximo documento:** `04_USE_CASES.md`
