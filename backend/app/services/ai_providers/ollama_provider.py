import json
import re

import httpx

from app.exceptions import AIProviderTimeoutError, AIProviderUnavailableError
from app.services.ai_providers.base import AIProvider, ConversationTurn, LLMResult

# docs/03_NON_FUNCTIONAL_REQUIREMENTS.md NFR-07 (revisado en ADR-008 tras el
# spike de la Fase 1: 25s de margen sobre el maximo observado de ~20s en
# caliente). Un arranque en frio (modelo no cargado en memoria) puede
# superar esto largamente, por eso el warmup en el startup de la app
# (ver app/main.py) usa su propio timeout, no este.
REQUEST_TIMEOUT_SECONDS = 25.0
WARMUP_TIMEOUT_SECONDS = 120.0

# Mantiene el modelo cargado en memoria entre solicitudes (docs/07 seccion 5)
# para no pagar el costo de carga en frio (~20-30s) en cada turno real.
KEEP_ALIVE = "30m"

# docs/07_AI_ARCHITECTURE.md seccion 5: respuestas cortas por diseno (UX de voz).
MAX_RESPONSE_TOKENS = 150
TEMPERATURE = 0.4

_JSON_OBJECT_PATTERN = re.compile(r"\{.*\}", re.DOTALL)
_FALLBACK_REPLY = "Entendido, dame un momento para confirmar los detalles."


class OllamaProvider(AIProvider):
    """docs/06_SYSTEM_ARCHITECTURE.md seccion 4.5 (NFR-23)."""

    def __init__(self, base_url: str, model: str) -> None:
        self._base_url = base_url.rstrip("/")
        self._model = model

    def generate_response(
        self, system_prompt: str, history: list[ConversationTurn], message: str
    ) -> LLMResult:
        messages = [{"role": "system", "content": system_prompt}]
        for turn in history:
            messages.append({"role": turn.role, "content": turn.content})
        messages.append({"role": "user", "content": message})

        raw_content = self._chat(messages, timeout=REQUEST_TIMEOUT_SECONDS)
        return self._parse_llm_output(raw_content)

    def warmup(self) -> None:
        """Carga el modelo en memoria al iniciar la app (ver app/main.py),
        para que el primer turno de un usuario real no pague el costo de
        arranque en frio (~20-30s observado en el spike de la Fase 1)."""
        self._chat(
            [{"role": "user", "content": "Hola"}], timeout=WARMUP_TIMEOUT_SECONDS
        )

    def _chat(self, messages: list[dict], timeout: float) -> str:
        try:
            with httpx.Client(timeout=timeout) as client:
                response = client.post(
                    f"{self._base_url}/api/chat",
                    json={
                        "model": self._model,
                        "messages": messages,
                        "stream": False,
                        "keep_alive": KEEP_ALIVE,
                        "options": {
                            "temperature": TEMPERATURE,
                            "num_predict": MAX_RESPONSE_TOKENS,
                        },
                    },
                )
                response.raise_for_status()
        except httpx.TimeoutException as exc:
            raise AIProviderTimeoutError("El asistente tardo demasiado en responder.") from exc
        except httpx.ConnectError as exc:
            raise AIProviderUnavailableError("No se pudo conectar con el modelo de IA.") from exc

        return response.json()["message"]["content"]

    def _parse_llm_output(self, raw_content: str) -> LLMResult:
        """docs/07_AI_ARCHITECTURE.md seccion 3.3: degradacion controlada
        si el modelo no devuelve un JSON valido."""
        parsed = self._try_parse_json(raw_content)
        if parsed is None:
            match = _JSON_OBJECT_PATTERN.search(raw_content)
            parsed = self._try_parse_json(match.group(0)) if match else None

        if parsed is None:
            return LLMResult(intent="chat", entities={}, reply=raw_content.strip())

        # El modelo a veces omite "reply" en un JSON por lo demas valido
        # (observado en el spike de la Fase 1, ver ADR-008). Nunca se debe
        # mostrar el JSON crudo al usuario como si fuera texto natural.
        reply = parsed.get("reply") or _FALLBACK_REPLY

        return LLMResult(
            intent=parsed.get("intent", "chat"),
            entities=parsed.get("entities", {}) or {},
            reply=reply,
        )

    @staticmethod
    def _try_parse_json(text: str) -> dict | None:
        try:
            result = json.loads(text)
        except (json.JSONDecodeError, TypeError):
            return None
        return result if isinstance(result, dict) else None
