# JOTA AI — Functional Requirements

**Fecha:** 2026-07-20
**Autor:** José Antonio de la Cruz Portal
**Estado:** Borrador para aprobación
**Fuente:** `docs/01_VISION_DOCUMENT.md` (sección 6 — Alcance del MVP)
**Posición en el flujo de trabajo:** Documento 2 de 10

---

## 1. Propósito

Traducir el alcance del MVP acordado en el Vision Document en requisitos funcionales concretos, verificables y trazables, que sirvan de base directa para los Casos de Uso (documento 4) y para la definición de aceptación de cada feature.

**Regla de trazabilidad:** todo requisito de este documento debe apuntar a un ítem de la sección 6 del Vision Document. Si un requisito no tiene origen ahí, no pertenece al MVP y se mueve a un backlog de "ideas futuras".

## 2. Convenciones

- **ID:** `FR-XX` (Functional Requirement).
- **Prioridad (MoSCoW):**
  - **Must** — sin esto no hay tesis defendible.
  - **Should** — importante, pero el MVP sobrevive sin ello si el tiempo aprieta.
  - **Could** — deseable, primer recorte si hay atraso.
- **Criterio de aceptación:** condición objetiva y verificable, no una descripción vaga.

---

## 3. Requisitos transversales (aplican a todo el sistema)

### FR-00.1 — Accesibilidad base
**Descripción:** La interfaz debe cumplir un mínimo de accesibilidad para adultos mayores: tamaño de fuente configurable con un mínimo grande por defecto, alto contraste, botones grandes con área táctil amplia, sin gestos complejos (evitar swipes múltiples o long-press como única vía de acción).
**Prioridad:** Must
**Criterio de aceptación:** Toda pantalla del MVP es operable usando solo toques simples; el tamaño de fuente por defecto es igual o mayor al recomendado por las guías de accesibilidad móvil (≥18sp en Android/equivalente).

### FR-00.2 — Permisos del dispositivo
**Descripción:** El sistema debe solicitar y gestionar explícitamente los permisos nativos necesarios (micrófono, contactos, llamadas) con explicaciones en lenguaje simple antes de cada solicitud.
**Prioridad:** Must
**Criterio de aceptación:** Ningún permiso se solicita sin una pantalla previa que explique, en lenguaje no técnico, para qué se usará.

### FR-00.3 — Configuración inicial (onboarding)
**Descripción:** Al primer uso, JOTA se presenta, explica brevemente qué puede hacer, y guía la configuración mínima (nombre del usuario, al menos un contacto de emergencia).
**Prioridad:** Should
**Criterio de aceptación:** Un usuario nuevo puede completar el onboarding sin ayuda externa en menos de 5 minutos (a validar en pruebas de usabilidad).

---

## 4. Conversación (texto y voz)

### FR-01.1 — Conversación por texto
**Descripción:** El usuario puede escribir un mensaje y recibir una respuesta generada por el asistente en un formato de chat.
**Prioridad:** Must
**Criterio de aceptación:** Un mensaje de texto enviado produce una respuesta visible en pantalla asociada al turno correcto de la conversación.

### FR-01.2 — Conversación por voz
**Descripción:** El usuario puede mantener presionado (o activar mediante un botón simple) un control para hablar; el audio se transcribe (STT), se procesa por el modelo de lenguaje, y la respuesta se sintetiza en voz (TTS).
**Prioridad:** Must
**Criterio de aceptación:** Al finalizar de hablar, el sistema transcribe el audio, genera una respuesta de texto y la reproduce en voz, dentro del umbral de latencia que se defina en Requisitos No Funcionales.

### FR-01.3 — Contexto de sesión
**Descripción:** El asistente mantiene el contexto de los últimos turnos de la conversación activa (sin memoria persistente entre sesiones, según lo definido como fuera de alcance).
**Prioridad:** Must
**Criterio de aceptación:** Una pregunta de seguimiento que depende de un mensaje anterior en la misma sesión se responde coherentemente.

### FR-01.4 — Manejo de fallos de reconocimiento/generación
**Descripción:** Si el STT no logra transcribir o el modelo no responde a tiempo, JOTA debe comunicarlo de forma amable y sugerir reintentar.
**Prioridad:** Should
**Criterio de aceptación:** Ante un fallo simulado del pipeline, el usuario recibe un mensaje de error comprensible (no un error técnico ni una pantalla en blanco).

---

## 5. Avatar

### FR-02.1 — Estados visuales esenciales
**Descripción:** El avatar debe representar visualmente, como mínimo, los estados: escuchando, pensando, hablando, esperando.
**Prioridad:** Must
**Criterio de aceptación:** Cada transición del flujo conversacional (usuario habla → sistema procesa → sistema responde → inactivo) dispara el estado visual correspondiente del avatar.

### FR-02.2 — Sincronización avatar-voz por amplitud
**Descripción:** Mientras el avatar "habla", su animación de boca reacciona a la amplitud del audio TTS reproducido (no a visemas reales).
**Prioridad:** Should
**Criterio de aceptación:** Durante la reproducción de una respuesta hablada, la animación de la boca varía visiblemente en sincronía aproximada con el volumen del audio.

### FR-02.3 — Estados emocionales adicionales (feliz, confundido, preocupado)
**Descripción:** Estados adicionales opcionales, activados en situaciones específicas (p. ej. "confundido" ante un fallo de reconocimiento).
**Prioridad:** Could
**Criterio de aceptación:** N/A si no se implementa en el MVP; si se implementa, al menos un evento del sistema dispara cada estado adicional.

---

## 6. Recordatorios

### FR-03.1 — Crear recordatorio
**Descripción:** El usuario (por voz o texto) puede crear un recordatorio de medicamento, evento o actividad, especificando descripción y momento.
**Prioridad:** Must
**Criterio de aceptación:** Un recordatorio creado queda almacenado y genera una notificación en el momento programado.

### FR-03.2 — Consultar/editar/eliminar recordatorios
**Descripción:** El usuario puede ver la lista de recordatorios activos, editarlos o eliminarlos.
**Prioridad:** Must
**Criterio de aceptación:** Las operaciones de edición y eliminación se reflejan de inmediato en la lista y en las notificaciones programadas.

### FR-03.3 — Notificación accesible
**Descripción:** La notificación del recordatorio debe ser clara, con texto simple y, si es posible, opción de lectura en voz alta.
**Prioridad:** Should
**Criterio de aceptación:** La notificación muestra el texto del recordatorio sin necesidad de abrir la app para entenderlo.

---

## 7. Contactos frecuentes

### FR-04.1 — Gestión de contactos frecuentes
**Descripción:** El usuario puede agregar, editar y eliminar contactos marcados como frecuentes, con nombre, foto (opcional) y número.
**Prioridad:** Must
**Criterio de aceptación:** Un contacto agregado aparece en una lista de acceso rápido y puede ser llamado con una sola acción.

### FR-04.2 — Llamar mediante voz o texto
**Descripción:** El usuario puede pedirle a JOTA, por voz o texto ("llama a María"), que inicie una llamada a un contacto frecuente.
**Prioridad:** Should
**Criterio de aceptación:** Al reconocer la intención de llamada con un nombre que coincide con un contacto frecuente, el sistema inicia la llamada nativa tras confirmación del usuario.

---

## 8. Emergencias

### FR-05.1 — Contacto(s) de emergencia
**Descripción:** El usuario configura uno o más contactos de emergencia, distintos o iguales a los frecuentes.
**Prioridad:** Must
**Criterio de aceptación:** Existe al menos un contacto de emergencia configurado tras el onboarding (FR-00.3).

### FR-05.2 — Llamada rápida de emergencia
**Descripción:** Un control siempre accesible (botón visible desde la pantalla principal) permite llamar de inmediato al contacto de emergencia.
**Prioridad:** Must
**Criterio de aceptación:** Desde la pantalla principal, activar el control de emergencia inicia la llamada nativa al contacto configurado en 2 toques o menos.

> Nota: por decisión del Vision Document (sección 7), este requisito **no** incluye detección automática de caídas, pánico en la voz, ni ninguna forma de "inteligencia" — es una acción directa disparada por el usuario.

---

## 9. Historial

### FR-06.1 — Historial de conversaciones
**Descripción:** El usuario puede revisar conversaciones pasadas con JOTA.
**Prioridad:** Should
**Criterio de aceptación:** Existe una pantalla que lista conversaciones previas ordenadas por fecha, con acceso al contenido de cada una.

### FR-06.2 — Historial de acciones
**Descripción:** El sistema registra acciones ejecutadas (recordatorio creado, llamada iniciada) para que el usuario pueda revisarlas.
**Prioridad:** Could
**Criterio de aceptación:** Una acción ejecutada por el asistente (p. ej. crear un recordatorio) queda visible en un registro consultable.

---

## 10. Matriz de trazabilidad (Vision → Functional Requirements)

| Ítem del Vision Document (sección 6) | Requisitos funcionales |
|---|---|
| 1. Conversación por texto | FR-01.1, FR-01.3, FR-01.4 |
| 2. Conversación por voz | FR-01.2, FR-01.3, FR-01.4 |
| 3. Avatar con estados esenciales | FR-02.1 |
| 4. Sincronización avatar-voz | FR-02.2 |
| 5. Recordatorios | FR-03.1, FR-03.2, FR-03.3 |
| 6. Contactos frecuentes | FR-04.1, FR-04.2 |
| 7. Contacto de emergencia | FR-05.1, FR-05.2 |
| 8. Historial básico | FR-06.1, FR-06.2 |
| — (transversal, implícito por accesibilidad/seguridad) | FR-00.1, FR-00.2, FR-00.3 |
| — (opcional, no comprometido) | FR-02.3 |

---

## 11. Fuera de alcance (recordatorio)

Ningún requisito de este documento cubre: memoria persistente/RAG, detección emocional, detección de fraudes, avatar 3D, visión por cámara, wearables, hogar inteligente, agente autónomo, ni perfiles múltiples — consistente con el Vision Document, sección 7.

---

## 12. Aprobación y siguiente paso

Este documento debe aprobarse antes de iniciar el documento 3 (**Non-Functional Requirements**), donde se cerrarán los umbrales numéricos (latencia máxima, tasa de éxito de reconocimiento de voz, disponibilidad, etc.) que hoy quedan pendientes en varios criterios de aceptación.

**Próximo documento:** `03_NON_FUNCTIONAL_REQUIREMENTS.md`
