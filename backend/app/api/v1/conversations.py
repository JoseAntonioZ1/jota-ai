import base64
import uuid

from fastapi import APIRouter, Depends, File, Form, Query, UploadFile
from sqlalchemy.orm import Session

from app.api.v1.deps import get_conversation_service, get_current_user
from app.database import get_db
from app.models.user import User
from app.repositories.action_log_repository import ActionLogRepository
from app.repositories.conversation_repository import ConversationRepository
from app.schemas.conversation import (
    ConversationListResponse,
    ConversationMessageResponse,
    ConversationMessagesResponse,
    ConversationSummaryResponse,
    TextTurnRequest,
    TurnResponse,
    VoiceTurnResponse,
)
from app.services.conversation_service import ConversationService
from app.services.history_service import HistoryService

router = APIRouter()


def _history_service(db: Session = Depends(get_db)) -> HistoryService:
    return HistoryService(ConversationRepository(db), ActionLogRepository(db))


@router.post("/conversations/text-turn", response_model=TurnResponse)
def text_turn(
    payload: TextTurnRequest,
    current_user: User = Depends(get_current_user),
    service: ConversationService = Depends(get_conversation_service),
) -> TurnResponse:
    result = service.handle_text_turn(current_user.id, payload.conversation_id, payload.message)
    return TurnResponse(
        conversation_id=result.conversation_id,
        reply=result.reply,
        intent=result.intent,
        entities=result.entities,
    )


@router.post("/conversations/voice-turn", response_model=VoiceTurnResponse)
def voice_turn(
    audio: UploadFile = File(...),
    conversation_id: uuid.UUID | None = Form(default=None),
    current_user: User = Depends(get_current_user),
    service: ConversationService = Depends(get_conversation_service),
) -> VoiceTurnResponse:
    audio_bytes = audio.file.read()
    result = service.handle_voice_turn(current_user.id, conversation_id, audio_bytes)
    return VoiceTurnResponse(
        conversation_id=result.conversation_id,
        reply=result.reply,
        intent=result.intent,
        entities=result.entities,
        transcript=result.transcript,
        audio_base64=base64.b64encode(result.audio).decode("ascii"),
    )


@router.get("/conversations", response_model=ConversationListResponse)
def list_conversations(
    limit: int = Query(default=20, le=50),
    offset: int = Query(default=0, ge=0),
    current_user: User = Depends(get_current_user),
    service: HistoryService = Depends(_history_service),
) -> ConversationListResponse:
    items, total = service.list_conversations(current_user.id, limit, offset)
    return ConversationListResponse(
        items=[ConversationSummaryResponse.model_validate(item) for item in items], total=total
    )


@router.get("/conversations/{conversation_id}/messages", response_model=ConversationMessagesResponse)
def get_conversation_messages(
    conversation_id: uuid.UUID,
    limit: int = Query(default=50, le=100),
    offset: int = Query(default=0, ge=0),
    current_user: User = Depends(get_current_user),
    service: HistoryService = Depends(_history_service),
) -> ConversationMessagesResponse:
    items, total = service.get_conversation_messages(
        current_user.id, conversation_id, limit, offset
    )
    return ConversationMessagesResponse(
        items=[ConversationMessageResponse.model_validate(item) for item in items], total=total
    )
