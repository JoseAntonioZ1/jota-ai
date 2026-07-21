import io

from faster_whisper import WhisperModel

from app.services.ai_providers.base import SpeechToTextProvider

# docs/adr/0008-modelo-llm-local-para-mvp.md: "base" confirmado por el spike
# de la Fase 1 (mejor balance latencia/calidad en hardware CPU-only).
DEFAULT_MODEL_SIZE = "base"


class FasterWhisperProvider(SpeechToTextProvider):
    def __init__(self, model_size: str = DEFAULT_MODEL_SIZE) -> None:
        # La carga del modelo ocurre una sola vez (instancia reutilizada via
        # Depends con lru_cache, ver app/services/ai_providers/factory.py).
        self._model = WhisperModel(model_size, device="cpu", compute_type="int8")

    def transcribe(self, audio: bytes) -> str:
        segments, _info = self._model.transcribe(io.BytesIO(audio), language="es")
        return " ".join(segment.text.strip() for segment in segments).strip()
