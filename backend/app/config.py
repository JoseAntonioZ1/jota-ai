from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    database_url: str = "postgresql+psycopg2://jota:jota@localhost:5432/jota_ai"
    ollama_base_url: str = "http://localhost:11434"
    ollama_model: str = "llama3.2:3b"
    whisper_model_size: str = "base"
    piper_voice_path: str = "voices/es_ES-davefx-medium.onnx"
    environment: str = "development"


@lru_cache
def get_settings() -> Settings:
    return Settings()
