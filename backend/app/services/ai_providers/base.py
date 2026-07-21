from dataclasses import dataclass
from typing import Any, Protocol


@dataclass
class ConversationTurn:
    role: str  # "user" | "assistant"
    content: str


@dataclass
class LLMResult:
    intent: str
    entities: dict[str, Any]
    reply: str


class AIProvider(Protocol):
    """docs/06_SYSTEM_ARCHITECTURE.md seccion 4.5 (NFR-23)."""

    def generate_response(
        self, system_prompt: str, history: list[ConversationTurn], message: str
    ) -> LLMResult: ...


class SpeechToTextProvider(Protocol):
    def transcribe(self, audio: bytes) -> str: ...


class TextToSpeechProvider(Protocol):
    def synthesize(self, text: str) -> bytes: ...
