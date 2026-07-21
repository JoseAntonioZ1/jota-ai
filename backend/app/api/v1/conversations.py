import base64
import uuid

from fastapi import APIRouter, Depends, File, Form, UploadFile

from app.api.v1.deps import get_conversation_service, get_current_user
from app.models.user import User
from app.schemas.conversation import TextTurnRequest, TurnResponse, VoiceTurnResponse
from app.services.conversation_service import ConversationService

router = APIRouter()


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
