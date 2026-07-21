# ADR-008: Modelo LLM local definitivo para el MVP y revisión de NFR-01

**Fecha:** 2026-07-20
**Estado:** Aceptado
**Contexto:** Fase 1 del roadmap (`docs/10_DEVELOPMENT_ROADMAP.md`) — spike técnico de latencia del pipeline de voz.

## Contexto

`docs/07_AI_ARCHITECTURE.md` (sección 5) dejó pendiente de validación empírica el tamaño de modelo LLM a usar, con Llama 3 8B como punto de partida y una estrategia de fallback hacia modelos más pequeños si no se cumplía NFR-01 (≤3s de latencia total).

El hardware disponible del autor no tiene GPU utilizable por Ollama en Windows (GPU integrada AMD Radeon Vega 10, sin soporte ROCm funcional) — Ollama ejecuta el modelo 100% en CPU (confirmado con `ollama ps`, columna `PROCESSOR: 100% CPU`).

## Medición

Scripts de medición: `backend/spikes/measure_llm_latency.py`, `measure_stt_latency.py`, `measure_tts_latency.py`. Metodología: 1 llamada de calentamiento (no contabilizada) + 5 turnos de conversación representativos (incluyendo el caso más sensible: crear un recordatorio de medicación), usando el system prompt real de `07_AI_ARCHITECTURE.md` sección 3.2.

| Modelo LLM | Latencia (prom.) | Latencia (rango) | Calidad observada |
|---|---|---|---|
| Llama 3 8B | 40.76s | 26.4-66.0s | JSON siempre válido, respuestas coherentes |
| **Llama 3.2 3B** | **11.81s** | **5.1-18.8s** | Mayormente válido (1/5 respuestas sin campo `reply`) |
| Llama 3.2 1B | 8.00s | 3.0-20.0s | **Inaceptable**: en el turno de "recuérdame tomar mi pastilla para la presión", el modelo **rechazó crear el recordatorio alegando un riesgo de salud inventado**; 2/5 respuestas con JSON malformado |

| Componente STT (Whisper) | Latencia | Calidad |
|---|---|---|
| small | 8.5-9.4s | Transcripción perfecta |
| base | ~1.9s | Transcripción con error menor |
| tiny | ~1.2s | Transcripción con error menor |

| Componente TTS (Piper, es_ES-davefx-medium) | Latencia |
|---|---|
| Tras cargar el modelo (una vez al iniciar) | 0.24-0.40s — cumple NFR-02 |

## Decisión

1. **Modelo LLM del MVP: Llama 3.2 3B vía Ollama.** Se descarta Llama 3 8B (demasiado lento incluso para un umbral relajado) y Llama 3.2 1B (falla de forma peligrosa en el caso de uso más sensible del sistema — un recordatorio de medicación — lo cual es inaceptable sin importar la velocidad).
2. **Componente STT del MVP: Whisper `base`** — mejor balance entre latencia (~1.9s) y calidad que `tiny`, y muchísimo más rápido que `small` sin pérdida perceptible de calidad en la prueba.
3. **NFR-01 se revisa de ≤3s a ≤15s** para el hardware CPU-only disponible en esta tesis. El umbral de 3s queda documentado como meta futura, alcanzable si se migra a GPU o a un proveedor en la nube a través de la abstracción `AIProvider` (NFR-23) — cambio de configuración, no de arquitectura.
4. **NFR-07 (timeout de fallo) se revisa de 6s a 25s**, con margen sobre el máximo observado (~20s).
5. **Se rechaza, por ahora, migrar a un proveedor en la nube (Groq/OpenAI)** para cumplir el umbral original de 3s — decisión explícita del autor para mantener el proyecto 100% local y gratuito, coherente con la restricción de presupuesto extremadamente bajo/nulo de `CLAUDE.md`. Queda como opción documentada si el hardware o el contexto del proyecto cambian.
6. **La UX de espera se rediseña** (ver `docs/05_UX_UI_DESIGN.md`, sección 6.4) para una espera real de varios segundos, en vez de una señal breve de "sigo aquí" pensada originalmente para 1.5s.

## Consecuencias

- La demo y la sustentación de tesis deben comunicar honestamente que las respuestas de JOTA tardan varios segundos — esto se convierte en una limitación documentada y justificada empíricamente, no en un defecto oculto.
- El riesgo técnico #2 de `ANALISIS_ARQUITECTONICO.md` ("requisitos de hardware de Llama 3 vía Ollama") queda confirmado empíricamente, no solo como hipótesis.
- Los scripts de spike (`backend/spikes/`) se conservan como evidencia reproducible para el capítulo de resultados preliminares de la tesis (`docs/10_DEVELOPMENT_ROADMAP.md`, sección 5).
- Si en el futuro se dispone de mejor hardware, revertir a Llama 3 8B (o subir de tamaño) es un cambio de una sola línea de configuración (`OLLAMA_MODEL`), no un cambio arquitectónico.
