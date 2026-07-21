# JOTA AI — Análisis Arquitectónico Crítico

**Fecha:** 2026-07-20
**Autor:** Equipo de arquitectura (Claude + José Antonio de la Cruz Portal)
**Fuente de verdad:** `CLAUDE.md`, `docs/JOTA_AI_CONTEXT.md`
**Propósito:** Servir de base para decidir el alcance, la arquitectura y el plan de documentos antes de escribir una sola línea de código.

---

## 1. Fortalezas de la idea

1. **Problema real y medible.** La brecha digital en adultos mayores es un problema social documentado (visión, memoria, motricidad, ansiedad tecnológica). Esto da a la tesis una justificación sólida y evaluable, no solo un pretexto técnico.
2. **Multidisciplinariedad genuina.** El proyecto integra IA conversacional, ingeniería de software, UX de accesibilidad y arquitectura de sistemas — exactamente lo que un jurado de Ingeniería de Sistemas espera ver en profundidad, no solo en superficie.
3. **Stack 100% open source.** Ollama + Llama 3 + Whisper + Piper elimina el riesgo de costos recurrentes por API (crítico dado el presupuesto). Es coherente con la restricción de "presupuesto extremadamente bajo".
4. **Identidad de producto definida.** Tener personalidad, nombre, avatar y estados emocionales desde el inicio evita el error común de "construir features sueltas" — ya existe un norte de producto.
5. **Arquitectura ya orientada a buenas prácticas.** Clean Architecture + SOLID + Repository + DI están declarados desde `CLAUDE.md`, lo que facilita justificar decisiones técnicas ante un comité académico.
6. **Escalable en narrativa de tesis.** El "MVP hoy, JARVIS mañana" permite defender la tesis por lo que sí se construyó, dejando lo ambicioso como "trabajo futuro" — patrón que los jurados valoran positivamente si está bien delimitado.

---

## 2. Riesgos técnicos

1. **Latencia acumulada del pipeline de voz.** STT (Whisper) → LLM (Llama 3 vía Ollama) → TTS (Piper) es una cadena secuencial. Cada eslabón suma cientos de ms a segundos; para un adulto mayor, más de ~2-3s de silencio se percibe como "no funciona". Esto no es un detalle menor: puede ser el punto que hunda la percepción de usabilidad en las pruebas.
2. **Requisitos de hardware de Llama 3 vía Ollama.** Ejecutar un modelo de 8B (o más) con latencia aceptable normalmente requiere GPU. Un desarrollador único con presupuesto bajo probablemente desarrollará y hará la defensa con CPU o una GPU modesta — esto debe validarse empíricamente muy temprano, no asumirse.
3. **Lip-sync / sincronización avatar-voz.** Piper no entrega automáticamente marcas de visemas o fonemas con timestamps. Sincronizar la boca del avatar (Rive) con el audio generado es un problema de ingeniería no trivial; el riesgo es subestimarlo y tratarlo como "detalle de UI".
4. **Precisión de Whisper con voces de adultos mayores.** Voces con temblor, cadencia más lenta, o acentos regionales marcados pueden reducir la precisión del reconocimiento por debajo de lo aceptable para el público objetivo — esto no se puede saber sin pruebas tempranas con usuarios reales.
5. **Concurrencia de servicios de IA en un solo servidor barato.** Ollama + Whisper + Piper corriendo simultáneamente compiten por RAM/CPU/GPU. Si el despliegue objetivo es un VPS económico, el riesgo de inviabilidad de producción (aunque no de tesis) es alto.
6. **Carga de un solo desarrollador full-stack + IA + UX + DevOps.** Es el mayor multiplicador de riesgo técnico: cualquier problema en cualquiera de las 5 disciplinas retrasa todo el proyecto porque no hay paralelización de trabajo.
7. **Seguridad y datos sensibles.** Contactos, llamadas de emergencia y (potencialmente) información de medicación son datos sensibles. Requieren cifrado en tránsito/reposo, gestión cuidadosa de permisos nativos en Flutter (contactos, teléfono, micrófono) y una política mínima de privacidad — fácil de posponer, riesgoso si se omite.

---

## 3. Riesgos de alcance

1. **La visión "tipo JARVIS" no tiene techo natural.** Sin un corte de alcance explícito y escrito, cualquier feature nueva "cabe" en la visión, lo que genera scope creep silencioso.
2. **El MVP declarado en `JOTA_AI_CONTEXT.md` ya es ambicioso para una sola persona:** conversación por voz y texto + avatar animado con 7 estados emocionales + recordatorios + contactos + emergencias + historial, todo en el mismo primer corte. Son al menos 4-5 subsistemas no triviales en paralelo.
3. **Funcionalidades "futuras" son proyectos completos por sí solas:** detección de fraudes, hogar inteligente, wearables y agente autónomo cada una podría ser una tesis independiente. El riesgo es que se filtren al alcance "porque suena interesante" durante el desarrollo.
4. **Avatar 3D y detección emocional son tentaciones de "feature bonita".** Visualmente atractivas en una demo, pero con un costo de desarrollo desproporcionado frente al valor que aportan a la validación de la hipótesis central (autonomía digital para adultos mayores).
5. **Memoria persistente / RAG es una trampa de sobre-ingeniería temprana.** Es fácil justificar "necesitamos que JOTA recuerde todo" pero el diseño correcto de memoria a largo plazo es un problema de investigación en sí mismo; no debe bloquear el MVP.

---

## 4. Riesgos para una tesis universitaria

1. **Falta de plan de validación con usuarios reales.** Ningún documento actual menciona cómo se medirá el éxito (tiempo de tarea, tasa de error, SUS score, entrevistas con adultos mayores). Un jurado de Ingeniería de Sistemas normalmente exige evidencia empírica, no solo la existencia del software.
2. **Ventana de tiempo académica vs. alcance técnico.** Un stack que incluye LLM local + STT + TTS + avatar animado + app móvil + backend completo es razonable para un equipo de 3-5 personas en 6 meses; para una persona en el tiempo típico de tesis, el riesgo de no llegar a un producto demostrable es alto si no se recorta agresivamente.
3. **Riesgo logístico en la sustentación.** Si la demo depende de un servidor con Ollama corriendo modelos pesados, cualquier falla de red, latencia o hardware el día de la defensa es un riesgo de alto impacto y bajo control. Se necesita un plan de contingencia (video de respaldo, entorno local, modelo más pequeño).
4. **Riesgo de percepción de "poca originalidad".** "Chatbot con avatar" es una categoría saturada (Replika, character.ai, asistentes genéricos). La tesis debe anclar su aporte académico en la **arquitectura de accesibilidad para adultos mayores** y no en la novedad del chatbot en sí — esto debe quedar explícito en el Vision Document.
5. **Ambigüedad entre "producto real" y "prueba de concepto académica".** Si no se define desde el inicio qué nivel de robustez se espera (¿producción real vs. prototipo funcional validado?), se puede sobre-invertir en DevOps/infraestructura que no aporta nota académica.

---

## 5. Recomendaciones de simplificación

1. **Recortar el MVP a lo mínimo defendible:** conversación (texto + voz), avatar con 3-4 estados (no los 7 completos), recordatorios básicos, contacto de emergencia con llamada nativa. Todo lo demás pasa a "iteración 2".
2. **Lip-sync simplificado:** sincronizar la boca del avatar con la **amplitud del audio** (envolvente de volumen) en lugar de visemas reales. Visualmente convincente, técnicamente mucho más simple.
3. **Modelo de IA pequeño y cuantizado primero:** validar Llama 3 8B (o modelo más chico) cuantizado (Q4) en el hardware real disponible **antes** de comprometer la arquitectura a un tamaño de modelo específico.
4. **Memoria conversacional simple:** usar ventana de contexto de los últimos N turnos (in-memory o en PostgreSQL), sin vectores ni RAG. Se documenta como punto de extensión futuro, no se construye ahora.
5. **Backend como monolito modular, no microservicios.** Clean Architecture por capas dentro de un único servicio FastAPI es muchísimo más simple de operar y desplegar para una persona, y no sacrifica el aprendizaje arquitectónico de la tesis.
6. **Emergencias sin "inteligencia".** Un botón que llama al contacto marcado usando las capacidades nativas del teléfono. Nada de detección automática de caídas, análisis de voz de pánico, etc. en el MVP.
7. **Autenticación mínima viable.** Un solo perfil de usuario adulto mayor por dispositivo al inicio; posponer perfiles múltiples/cuidador-familiar a versión futura salvo que sea requisito explícito de la tesis.

---

## 6. Recomendaciones de escalabilidad futura

1. **Abstraer el proveedor de IA detrás de una interfaz (`AIProvider`).** Patrón Strategy/Adapter en la capa de dominio/aplicación para que cambiar Ollama por OpenAI (o por un modelo más grande) sea un cambio de infraestructura, no de lógica de negocio — ya alineado con la regla de `CLAUDE.md` de "OpenAI únicamente como alternativa opcional".
2. **Modelar el pipeline de voz como servicios independientes con contratos claros:** `SpeechToTextService`, `TextToSpeechService`, `ConversationService`. Permite reemplazar Whisper o Piper sin tocar el resto del sistema.
3. **Repository Pattern para historial y memoria** desde el día 1, de forma que evolucionar de "últimos N turnos" a "memoria vectorial/RAG" sea agregar una implementación nueva del repositorio, no un rediseño.
4. **Versionar la API desde el inicio** (`/api/v1/...`) aunque solo exista una versión — evita romper el cliente Flutter cuando se agregue funcionalidad futura.
5. **Arquitectura orientada a eventos para puntos de extensión futuros** (wearables, hogar inteligente) sin acoplar el núcleo conversacional a integraciones que no existen aún — basta con dejar los "ganchos" (interfaces, colas) documentados, no implementados.
6. **Contenerización desde el inicio (Docker/Docker Compose).** Aunque el desarrollo sea local, tener el entorno reproducible facilita migrar a un servidor con GPU más adelante sin reescribir infraestructura.
7. **Separar claramente "avatar/presentación" de "estado emocional/dominio".** Los estados emocionales del avatar deben ser una proyección de un estado de dominio (`AssistantState`), no lógica embebida en la capa de presentación — así el avatar (Rive 2D hoy, 3D mañana) es reemplazable sin tocar reglas de negocio.

---

## 7. Funcionalidades que deben formar parte del MVP

| # | Funcionalidad | Alcance recomendado en MVP |
|---|---|---|
| 1 | Conversación por texto | Chat simple con contexto de sesión |
| 2 | Conversación por voz | STT → LLM → TTS, flujo básico, sin barge-in (interrupción) avanzado |
| 3 | Avatar con estados esenciales | Escuchando, pensando, hablando, esperando (recortar "feliz/confundido/preocupado" a v2 si el tiempo aprieta) |
| 4 | Sincronización voz-avatar | Basada en amplitud de audio, no visemas reales |
| 5 | Recordatorios | Medicamentos, eventos, actividades — CRUD + notificaciones locales |
| 6 | Contactos frecuentes | Gestión simple (agregar/editar/llamar) |
| 7 | Emergencias | Contacto de emergencia + llamada rápida nativa, sin lógica de detección automática |
| 8 | Historial | Registro básico de conversaciones y acciones (para revisión del usuario y para demo/tesis) |

---

## 8. Funcionalidades que deben posponerse

- Memoria persistente / RAG de largo plazo.
- Detección emocional (análisis de sentimiento por voz o rostro).
- Detección de fraudes.
- Avatar 3D.
- IA multimodal (visión por cámara).
- Integración con wearables.
- Hogar inteligente (IoT).
- Agente autónomo (acciones proactivas sin confirmación del usuario).
- Perfiles múltiples (cuidador/familiar) — salvo que se determine como requisito obligatorio de la tesis.

---

## 9. Documentos de diseño a construir antes de programar

En orden de dependencia lógica (cada uno alimenta al siguiente):

1. **Vision Document** — refinar el `JOTA_AI_CONTEXT.md` existente: problema, propuesta de valor, alcance de tesis vs. producto, criterios de éxito.
2. **Functional Requirements** — qué debe hacer el sistema, con foco en el MVP recortado de la sección 7.
3. **Non-Functional Requirements** — latencia máxima aceptable, accesibilidad (tamaño de fuente, contraste, WCAG), seguridad/privacidad, disponibilidad, mantenibilidad.
4. **Use Cases** — actores (adulto mayor, opcionalmente cuidador), flujos principales (conversar, crear recordatorio, llamar contacto de emergencia, revisar historial).
5. **UX/UI Design** — flujos de pantalla, wireframes, principios de accesibilidad para adultos mayores (tipografía, voz-primero, tolerancia a error, feedback constante del avatar).
6. **System Architecture** — vista de contenedores/componentes (estilo C4): app Flutter, backend FastAPI, servicios de IA (Ollama/Whisper/Piper), base de datos, cómo se comunican.
7. **AI Architecture** — diseño del pipeline conversacional: prompt/system message de JOTA, manejo de contexto, orquestación STT→LLM→TTS, estrategia de fallback si el modelo no responde a tiempo.
8. **Database Design** — modelo de datos (usuario, recordatorios, contactos, historial de conversación), relaciones, esquema PostgreSQL.
9. **API Design** — contratos REST versionados entre Flutter y FastAPI, formatos de request/response, manejo de errores.
10. **Development Roadmap** — hitos alineados al calendario de tesis (entregables por fase, no solo por feature).

**Nota de orden:** el UX/UI se ubica antes de la arquitectura de sistema a propósito — en un producto voz-primero para adultos mayores, las restricciones de UX (tolerancia a latencia, tamaño de interacción, feedback del avatar) determinan requisitos técnicos concretos (p. ej. si se necesita streaming de audio parcial para no hacer esperar al usuario). Diseñar la arquitectura antes de la UX arriesga tener que rediseñar componentes técnicos después.

---

## 10. Orden de trabajo propuesto

| Orden | Entregable | Objetivo al completarlo |
|---|---|---|
| 1 | Vision Document (revisado) | Alcance y criterios de éxito acordados y escritos |
| 2 | Functional Requirements | Lista cerrada de qué construye el MVP |
| 3 | Non-Functional Requirements | Límites de latencia, accesibilidad y seguridad definidos |
| 4 | Use Cases | Flujos de usuario validados en papel antes de diseñar pantallas |
| 5 | UX/UI Design | Wireframes y flujos de interacción accesibles |
| 6 | System Architecture | Diagrama de contenedores/componentes y decisiones técnicas (ADR si aplica) |
| 7 | AI Architecture | Diseño del pipeline conversacional y contratos entre servicios de IA |
| 8 | Database Design | Esquema de datos definitivo para el MVP |
| 9 | API Design | Contratos REST entre Flutter y FastAPI |
| 10 | Development Roadmap | Plan de sprints/hitos alineado al calendario de tesis |
| — | **Inicio de desarrollo** | Recién aquí comienza la implementación de código |

---

## Próximo paso sugerido

Comenzar por el **Vision Document** (punto 1), ya que ahí se decide formalmente el corte de alcance MVP vs. futuro que se propuso en las secciones 7 y 8 de este análisis. Sin ese acuerdo por escrito, cualquier documento posterior (requisitos, arquitectura, UX) corre el riesgo de heredar la ambigüedad de alcance original.
