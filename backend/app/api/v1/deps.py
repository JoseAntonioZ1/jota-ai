from fastapi import Depends, Header
from sqlalchemy.orm import Session

from app.database import get_db
from app.exceptions import InvalidTokenError
from app.models.user import User
from app.repositories.conversation_repository import ConversationRepository
from app.repositories.user_repository import UserRepository
from app.security import hash_device_token
from app.services.ai_providers.factory import get_ai_provider, get_stt_provider, get_tts_provider
from app.services.conversation_service import ConversationService


def get_current_user(
    authorization: str = Header(...), db: Session = Depends(get_db)
) -> User:
    if not authorization.startswith("Bearer "):
        raise InvalidTokenError("Token de dispositivo ausente o con formato invalido.")

    raw_token = authorization.removeprefix("Bearer ").strip()
    token_hash = hash_device_token(raw_token)

    user = UserRepository(db).get_by_token_hash(token_hash)
    if user is None:
        raise InvalidTokenError("Token de dispositivo invalido.")
    return user


def get_conversation_service(db: Session = Depends(get_db)) -> ConversationService:
    return ConversationService(
        ai_provider=get_ai_provider(),
        stt_provider=get_stt_provider(),
        tts_provider=get_tts_provider(),
        conversation_repo=ConversationRepository(db),
    )
