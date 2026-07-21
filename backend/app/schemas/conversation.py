import uuid
from typing import Any

from pydantic import BaseModel


class TextTurnRequest(BaseModel):
    conversation_id: uuid.UUID | None = None
    message: str


class TurnResponse(BaseModel):
    conversation_id: uuid.UUID
    reply: str
    intent: str
    entities: dict[str, Any]


class VoiceTurnResponse(TurnResponse):
    transcript: str
    audio_base64: str
