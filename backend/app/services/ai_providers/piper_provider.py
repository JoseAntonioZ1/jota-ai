import io
import wave

from piper import PiperVoice

from app.services.ai_providers.base import TextToSpeechProvider


class PiperProvider(TextToSpeechProvider):
    def __init__(self, voice_model_path: str) -> None:
        # La carga del modelo ocurre una sola vez (instancia reutilizada via
        # Depends con lru_cache, ver app/services/ai_providers/factory.py).
        self._voice = PiperVoice.load(voice_model_path)

    def synthesize(self, text: str) -> bytes:
        buffer = io.BytesIO()
        with wave.open(buffer, "wb") as wav_file:
            self._voice.synthesize_wav(text, wav_file)
        return buffer.getvalue()
