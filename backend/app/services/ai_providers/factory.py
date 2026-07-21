from functools import lru_cache

from app.config import get_settings
from app.services.ai_providers.ollama_provider import OllamaProvider
from app.services.ai_providers.piper_provider import PiperProvider
from app.services.ai_providers.whisper_provider import FasterWhisperProvider


@lru_cache
def get_ai_provider() -> OllamaProvider:
    settings = get_settings()
    return OllamaProvider(base_url=settings.ollama_base_url, model=settings.ollama_model)


@lru_cache
def get_stt_provider() -> FasterWhisperProvider:
    settings = get_settings()
    return FasterWhisperProvider(model_size=settings.whisper_model_size)


@lru_cache
def get_tts_provider() -> PiperProvider:
    settings = get_settings()
    return PiperProvider(voice_model_path=settings.piper_voice_path)
