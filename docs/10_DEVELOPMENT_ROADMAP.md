# JOTA AI — Development Roadmap

**Fecha:** 2026-07-20
**Autor:** José Antonio de la Cruz Portal
**Estado:** Borrador para aprobación
**Fuente:** Documentos 1-9 (`docs/01_VISION_DOCUMENT.md` a `docs/09_API_DESIGN.md`)
**Posición en el flujo de trabajo:** Documento 10 de 10 (último documento de diseño antes de programar)

> **Supuesto a validar:** las duraciones de este roadmap están expresadas en semanas relativas (Semana 1, 2, 3...), no en fechas de calendario, porque aún no se ha confirmado el calendario académico exacto (fecha de sustentación, hitos de avance de tesis). Antes de ejecutar este plan, se debe mapear cada fase a fechas reales del calendario de la universidad.

---

## 1. Propósito

Ordenar la implementación del MVP priorizando la reducción de riesgo técnico antes que la construcción de features, definir checkpoints de validación (gates) que no deben saltarse, y conectar cada fase con lo que un informe de tesis típico necesita reportar como evidencia.

---

## 2. Principios de planificación

1. **Validar el riesgo más incierto primero.** El pipeline de voz (latencia NFR-01, precisión NFR-05) es la mayor incógnita del proyecto — se prueba con un spike técnico antes de construir cualquier pantalla.
2. **Valor demostrable temprano.** Conversación por texto funcionando de punta a punta (aunque sin avatar pulido) es la primera demo posible, no la última.
3. **No pulir antes de validar.** Las animaciones finas del avatar (sincronización por amplitud, transiciones suaves) se dejan para después de que la lógica funcional esté probada — evita invertir tiempo de arte en algo que podría cambiar.
4. **La validación con usuarios reales no es la última semana.** Debe reservarse tiempo suficiente para reaccionar a los hallazgos (Fase 10), no solo para ejecutarla y reportarla.
5. **Los recortes de alcance ya definidos (Vision Document, sección 7) son el plan B oficial** si el cronograma se atrasa — no se improvisan recortes nuevos bajo presión.

---

## 3. Fases y orden de implementación

### Fase 0 — Setup de infraestructura (Semana 1-2)
- Repositorio, estructura de carpetas Clean Architecture (Flutter y backend) según `06_SYSTEM_ARCHITECTURE.md`.
- `docker-compose.yml` con PostgreSQL y Ollama.
- Migración inicial de Alembic (`08_DATABASE_DESIGN.md`).
- Esqueleto de la app Flutter con GoRouter configurado (rutas vacías).
- **Entregable:** proyecto ejecutable localmente, sin funcionalidad todavía, pero con arquitectura verificable (NFR-20).

### Fase 1 — Spike técnico: pipeline de voz (Semana 2-3) — ✅ COMPLETADA
- Scripts de medición: `backend/spikes/measure_llm_latency.py`, `measure_stt_latency.py`, `measure_tts_latency.py`.
- Medición real de latencia (NFR-01/NFR-02) en el hardware disponible (CPU-only, sin GPU utilizable por Ollama en Windows).
- **Gate de salida resuelto (ver ADR-008):** Llama 3 8B no cumplió los umbrales (40.8s prom.); Llama 3.2 1B fue más rápido pero falló de forma peligrosa en el caso de uso de recordatorio de medicación. **Modelo definitivo: Llama 3.2 3B** (11.8s prom., confiable). Decisión del autor: relajar NFR-01 (≤3s → ≤15s) y mantener el sistema 100% local/gratuito, en vez de migrar a un proveedor en la nube. WER real contra voces de adultos mayores (NFR-05) queda pendiente para la Fase 9 (requiere grabaciones humanas reales).

### Fase 2 — Backend MVP: conversación (Semana 3-5)
- Modelos SQLAlchemy + repositorios para `users`, `conversations`, `conversation_messages`.
- `ConversationService` con la abstracción `AIProvider`/`SpeechToTextProvider`/`TextToSpeechProvider` (NFR-23).
- Endpoints `POST /api/v1/devices`, `/conversations/text-turn`, `/conversations/voice-turn` (`09_API_DESIGN.md`).
- **Entregable:** conversación funcional vía API (probable con herramientas como Postman/Thunder Client), sin app todavía.

### Fase 3 — Flutter MVP: onboarding y conversación (Semana 5-8)
- Onboarding (UC-01): permisos, nombre, contacto de emergencia obligatorio.
- Pantalla `/home` con `AvatarWidget` en sus 4 estados esenciales (sin animación fina de Rive todavía — placeholders visuales válidos en esta fase).
- Conversación por texto primero (más simple de depurar), luego por voz.
- **Entregable:** primera demo end-to-end: onboarding → conversar por texto y voz con JOTA.

### Fase 4 — Recordatorios (Semana 8-10)
- Backend: modelo, repositorio, endpoints CRUD (`09_API_DESIGN.md`, sección 4.3).
- Flutter: pantallas de lista/creación/edición, `ConfirmationCard` (documento 5), notificaciones locales.
- **Entregable:** UC-04, UC-05, UC-06 completos.

### Fase 5 — Contactos frecuentes (Semana 10-11)
- Backend + Flutter para CRUD de contactos y llamada por voz/texto (UC-07, UC-08).

### Fase 6 — Emergencia (Semana 11-12)
- `EmergencyButton` global, `PUT /users/me/emergency-contact`, flujo de confirmación y llamada nativa (UC-09, UC-10).
- **Nota:** técnicamente es el módulo más simple (reutiliza contactos y `ConfirmationCard`), pero es el de mayor sensibilidad — requiere pruebas manuales exhaustivas antes de considerarse "terminado".

### Fase 7 — Historial (Semana 12-13)
- `GET /conversations`, `GET /conversations/{id}/messages`, `GET /action-logs` (UC-11).
- Prioridad: implementar historial de conversaciones (Should) antes que historial de acciones (Could) — si el tiempo aprieta, este último se pospone sin renegociar alcance.

### Fase 8 — Pulido de avatar y UX (Semana 13-15)
- Animaciones Rive definitivas para los 4 estados MVP.
- Sincronización por amplitud de audio (FR-02.2).
- `LatencyIndicator` ("sigo aquí", documento 5, sección 6.4).
- Revisión completa contra el checklist de accesibilidad (documento 5, sección 9).

### Fase 9 — Validación de usabilidad con usuarios reales (Semana 15-17)
- Reclutamiento de 5-8 adultos mayores (NFR-09).
- Sesiones de prueba de tarea + cuestionario SUS (NFR-08).
- **Gate:** este es el checkpoint más importante del proyecto para la tesis — sin esta evidencia, no hay forma de sustentar el objetivo específico 5 del Vision Document.

### Fase 10 — Ajustes post-validación (Semana 17-19)
- Corrección de los problemas de usabilidad más críticos encontrados en Fase 9 (no todos — priorizar por impacto y tiempo restante).
- Nueva medición ligera si el ajuste es significativo (no se repite el estudio completo).

### Fase 11 — Preparación de sustentación (Semana 19-20)
- Plan de contingencia de demo (NFR-18): video de respaldo grabado, entorno local probado.
- Consolidación de la documentación de tesis (capítulos, evidencia de Fase 9).
- Registro final de ADRs pendientes (documento 6, sección 8; documento 7, sección 9).

---

## 4. Cronograma tentativo (resumen)

| Semana | Fase | Hito verificable |
|---|---|---|
| 1-2 | Fase 0 | Proyecto corre localmente con Docker Compose |
| 2-3 | Fase 1 ✅ | Latencia medida con datos reales; modelo de IA confirmado (Llama 3.2 3B, ADR-008) |
| 3-5 | Fase 2 | Conversación funcional vía API |
| 5-8 | Fase 3 | Demo: onboarding + conversación por texto y voz en la app |
| 8-10 | Fase 4 | Recordatorios end-to-end |
| 10-11 | Fase 5 | Contactos end-to-end |
| 11-12 | Fase 6 | Emergencia end-to-end |
| 12-13 | Fase 7 | Historial disponible |
| 13-15 | Fase 8 | Avatar pulido, UX final |
| 15-17 | Fase 9 | Datos de usabilidad recolectados (SUS, tasa de finalización) |
| 17-19 | Fase 10 | Ajustes críticos aplicados |
| 19-20 | Fase 11 | Listo para sustentación |

---

## 5. Relación con el informe de tesis

| Fase(s) | Alimenta el capítulo de tesis |
|---|---|
| Fases 0-2 | Metodología / Arquitectura del sistema |
| Fase 1 | Resultados preliminares de viabilidad técnica (justifica decisiones de modelo de IA) |
| Fases 3-8 | Desarrollo / Implementación |
| Fase 9 | Resultados — validación con usuarios (la evidencia empírica que un jurado de Ingeniería de Sistemas exige, según riesgo #1 de `ANALISIS_ARQUITECTONICO.md`) |
| Fase 10 | Discusión / limitaciones |
| Fase 11 | Conclusiones y trabajo futuro (enlaza directamente con Vision Document, sección 7) |

---

## 6. Definición de "terminado" (Definition of Done) por feature

Una funcionalidad se considera terminada cuando:
1. Cumple su(s) criterio(s) de aceptación en `02_FUNCTIONAL_REQUIREMENTS.md`.
2. Respeta la arquitectura definida (capas, patrones) sin excepciones no documentadas.
3. Tiene al menos una prueba manual registrada contra su caso de uso correspondiente.
4. No introduce una violación conocida de un NFR "Must".
5. Está commiteada siguiendo la convención de `CLAUDE.md` (tipo + mensaje descriptivo en español).

---

## 7. Riesgos de cronograma y mitigación

| Riesgo | Mitigación |
|---|---|
| Fase 1 reveló que el hardware no soporta Llama 3 8B con latencia aceptable | **Materializado y resuelto:** se cambió a Llama 3.2 3B (ADR-008) sin rediseñar arquitectura, solo la configuración del `AIProvider` — confirma que el patrón de abstracción funcionó como estaba previsto |
| Fase 9 (usabilidad) se retrasa por dificultad de reclutar adultos mayores | Iniciar el reclutamiento en paralelo a la Fase 3, no esperar a tener el producto "perfecto" |
| Atraso general acumulado | Aplicar los recortes ya pre-aprobados del Vision Document (sección 7) — nunca inventar recortes de último momento sin registrarlos ahí primero |
| Fase 8 (pulido de avatar) se extiende más de lo previsto | Es la fase con menor impacto en los criterios de éxito medibles (sección 9, Vision Document); recortable a estados estáticos sin animación fina si es necesario |

---

## 8. Aprobación y cierre del proceso de diseño

Con este documento se completa la secuencia de 10 documentos de diseño acordada en `ANALISIS_ARQUITECTONICO.md`. El siguiente paso, fuera del alcance de este documento, es **iniciar la Fase 0** (setup de infraestructura) del desarrollo.

**Documentos de diseño completos:**
1. Vision Document
2. Functional Requirements
3. Non-Functional Requirements
4. Use Cases
5. UX/UI Design
6. System Architecture
7. AI Architecture
8. Database Design
9. API Design
10. Development Roadmap (este documento)
