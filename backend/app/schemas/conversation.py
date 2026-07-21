import uuid
from datetime import datetime
from typing import Any, Literal

from pydantic import BaseModel, ConfigDict


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


class ConversationSummaryResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    channel: Literal["text", "voice", "mixed"]
    started_at: datetime


class ConversationListResponse(BaseModel):
    items: list[ConversationSummaryResponse]
    total: int


class ConversationMessageResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    role: Literal["user", "assistant"]
    content: str
    created_at: datetime


class ConversationMessagesResponse(BaseModel):
    items: list[ConversationMessageResponse]
    total: int
