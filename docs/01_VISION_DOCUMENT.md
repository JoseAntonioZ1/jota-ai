# JOTA AI — Vision Document

**Fecha:** 2026-07-20
**Autor:** José Antonio de la Cruz Portal
**Estado:** Borrador para aprobación
**Fuentes:** `docs/JOTA_AI_CONTEXT.md`, `docs/ANALISIS_ARQUITECTONICO.md`
**Posición en el flujo de trabajo:** Documento 1 de 10 (ver sección 9-10 de `ANALISIS_ARQUITECTONICO.md`)

---

## 1. Propósito de este documento

Establecer, por escrito y de forma vinculante para el resto de documentos de diseño, **qué es JOTA AI en el contexto de esta tesis** (no en el contexto de un producto comercial futuro), cuál es el corte exacto entre lo que se construye ahora y lo que queda como trabajo futuro, y cómo se medirá si el proyecto cumplió su objetivo.

Este documento es la referencia que resuelve cualquier disputa de alcance durante Requisitos Funcionales, UX, Arquitectura, etc. Si una funcionalidad no está en la sección 6 (Alcance del MVP), no se construye, sin importar cuán natural parezca agregarla.

---

## 2. Planteamiento del problema

| Elemento | Descripción |
|---|---|
| **El problema de** | Adultos mayores con baja alfabetización digital |
| **afecta a** | Ellos mismos y a sus familiares/cuidadores, quienes deben suplir tareas que la persona mayor no puede resolver sola en su smartphone |
| **el impacto de lo cual es** | Dependencia de terceros para tareas cotidianas, baja adopción de servicios digitales, aislamiento y frustración |
| **una solución exitosa** | Permitiría a la persona mayor comunicarse en lenguaje natural (voz o texto) con un asistente que comprenda su intención y ejecute o guíe tareas simples, sin necesidad de aprender interfaces tradicionales |

---

## 3. Sentencia de posición del producto

> Para **adultos mayores** que **tienen dificultad para usar smartphones mediante interfaces convencionales**, **JOTA AI** es un **asistente conversacional multimodal con avatar** que **permite interactuar por voz o texto en lenguaje natural para tareas cotidianas simples (recordatorios, contactos, emergencias)**. A diferencia de **asistentes genéricos (Siri, Google Assistant) o chatbots sin contexto de accesibilidad**, JOTA AI **está diseñado específicamente para las limitaciones visuales, motrices y cognitivas de adultos mayores, con una identidad amigable y consistente pensada para generar confianza**.

---

## 4. Alcance de tesis vs. alcance de producto

Esta distinción es la decisión de mayor impacto de este documento y debe citarse en cualquier discusión de alcance futura.

- **Alcance de tesis (lo que se construye y se defiende):** un asistente funcional MVP que demuestra la arquitectura, el pipeline de IA local y la viabilidad de la interacción por voz/texto/avatar para adultos mayores, validado con un grupo reducido de usuarios reales.
- **Alcance de producto (visión de largo plazo, fuera de esta tesis):** el asistente "tipo JARVIS" evolutivo descrito en `JOTA_AI_CONTEXT.md` — memoria persistente, detección emocional, hogar inteligente, wearables, agente autónomo.

La tesis **no** se compromete a entregar el producto de largo plazo. Se compromete a entregar un MVP funcional + evidencia de validación + una arquitectura preparada para escalar hacia esa visión (ver `ANALISIS_ARQUITECTONICO.md`, sección 6).

---

## 5. Objetivos

### 5.1 Objetivo general

Diseñar e implementar un asistente conversacional multimodal (JOTA) que incremente la autonomía digital de adultos mayores, y validar su usabilidad con usuarios reales del público objetivo.

### 5.2 Objetivos específicos

1. Diseñar una arquitectura de software (Clean Architecture, Flutter + FastAPI) que soporte conversación por voz y texto con baja latencia percibida.
2. Integrar un pipeline de IA local (Whisper + Llama 3 vía Ollama + Piper) que no dependa de servicios de pago.
3. Diseñar un avatar con retroalimentación visual de estado (escuchando/pensando/hablando/esperando) que refuerce la confianza del usuario en la interacción.
4. Implementar funcionalidades de asistencia cotidiana priorizadas por impacto real: recordatorios, contactos, emergencias.
5. Validar la usabilidad del sistema con un grupo de adultos mayores mediante pruebas de tarea y un instrumento de medición (p. ej. System Usability Scale).

---

## 6. Alcance del MVP (comprometido para la tesis)

Heredado y cerrado a partir de `ANALISIS_ARQUITECTONICO.md`, sección 7:

1. Conversación por texto.
2. Conversación por voz (STT → LLM → TTS).
3. Avatar con estados esenciales: escuchando, pensando, hablando, esperando.
4. Sincronización avatar-voz basada en amplitud de audio (sin visemas reales).
5. Recordatorios (medicamentos, eventos, actividades).
6. Gestión de contactos frecuentes.
7. Contacto de emergencia con llamada rápida nativa (sin detección automática).
8. Historial básico de conversaciones y acciones.

Cualquier funcionalidad adicional requiere una actualización explícita de este documento antes de implementarse.

---

## 7. Explícitamente fuera de alcance (trabajo futuro)

- Memoria persistente / RAG de largo plazo.
- Detección emocional (voz o rostro).
- Detección de fraudes.
- Avatar 3D.
- IA multimodal por visión (cámara).
- Integración con wearables.
- Hogar inteligente (IoT).
- Agente autónomo (acciones sin confirmación del usuario).
- Perfiles múltiples (cuidador/familiar).
- Estados emocionales adicionales del avatar (feliz, confundido, preocupado) — se agregan solo si el tiempo del MVP lo permite, sin comprometerse.

---

## 8. Usuarios y stakeholders

| Rol | Descripción | Interés principal |
|---|---|---|
| **Usuario primario** | Adulto mayor con baja/media alfabetización digital | Poder pedir ayuda o realizar tareas simples sin frustrarse |
| **Autor / Desarrollador** | José Antonio de la Cruz Portal | Completar una tesis viable, técnicamente sólida y defendible |
| **Jurado de tesis** | Comité evaluador de Ingeniería de Sistemas | Rigor metodológico, evidencia empírica, arquitectura justificada |
| **Familiar/cuidador (indirecto)** | No es usuario directo en el MVP | Reducir su carga de soporte tecnológico (beneficio secundario, no medido en MVP) |

---

## 9. Criterios de éxito (medibles)

El proyecto se considera exitoso si, al finalizar, se puede demostrar con evidencia:

1. **Funcional:** las 8 funcionalidades del MVP (sección 6) operan de punta a punta en un dispositivo real.
2. **Latencia percibida:** el tiempo entre que el usuario termina de hablar y JOTA comienza a responder (audible o visualmente) es igual o menor a un umbral definido en el documento de Requisitos No Funcionales (a establecer, referencia inicial: ≤ 3 segundos).
3. **Usabilidad:** un grupo de al menos N adultos mayores (N a definir en el plan de validación) completa un conjunto de tareas predefinidas con una tasa de éxito y un puntaje de usabilidad (p. ej. SUS ≥ 68, "aceptable") documentados.
4. **Arquitectónico:** la arquitectura permite sustituir el proveedor de IA (Ollama → otro) sin modificar la capa de dominio, demostrado con al menos una prueba o ejercicio de sustitución.

Los valores exactos de umbral (N usuarios, segundos de latencia, score mínimo) se cerrarán formalmente en el documento de **Requisitos No Funcionales** (documento 3 del orden de trabajo).

---

## 10. Restricciones

- Presupuesto extremadamente bajo — solo herramientas open source o de costo marginal.
- Un solo desarrollador cubriendo todas las disciplinas (full-stack, IA, UX, DevOps).
- Debe ser viable de completar dentro del calendario académico de una tesis universitaria.
- El hardware de referencia para IA local será el disponible por el autor (no se asume GPU de alta gama ni servidor dedicado, salvo que se confirme lo contrario).

---

## 11. Supuestos

- Existe acceso a un grupo reducido de adultos mayores dispuestos a participar en pruebas de usabilidad.
- El hardware disponible (a confirmar) puede ejecutar Llama 3 cuantizado con latencia aceptable; de no ser así, se evaluará un modelo más pequeño antes de cambiar de arquitectura.
- OpenAI (u otro proveedor de pago) queda como alternativa opcional únicamente si el modelo local no cumple los criterios de latencia/calidad — no es parte del plan base.

---

## 12. Glosario

- **JOTA:** nombre del asistente, inspirado en el autor.
- **MVP:** Minimum Viable Product — alcance mínimo definido en la sección 6.
- **STT:** Speech-to-Text (Whisper).
- **TTS:** Text-to-Speech (Piper).
- **Visema:** representación visual de un fonema, usada para sincronización labial precisa (fuera de alcance del MVP).
- **SUS:** System Usability Scale, instrumento estándar de medición de usabilidad.

---

## 13. Aprobación

Este documento debe ser revisado y aprobado (aunque sea por el propio autor, actuando como product owner de la tesis) antes de iniciar el documento 2 (**Functional Requirements**). Cualquier cambio posterior de alcance debe reflejarse aquí primero.

**Próximo documento:** `02_FUNCTIONAL_REQUIREMENTS.md`
