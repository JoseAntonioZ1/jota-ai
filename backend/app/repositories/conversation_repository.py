import uuid
from typing import Any

from sqlalchemy.orm import Session

from app.models.conversation import Conversation
from app.models.conversation_message import ConversationMessage


class ConversationRepository:
    def __init__(self, db: Session) -> None:
        self._db = db

    def create_conversation(self, user_id: uuid.UUID, channel: str) -> Conversation:
        conversation = Conversation(user_id=user_id, channel=channel)
        self._db.add(conversation)
        self._db.commit()
        self._db.refresh(conversation)
        return conversation

    def get_conversation(
        self, conversation_id: uuid.UUID, user_id: uuid.UUID
    ) -> Conversation | None:
        return (
            self._db.query(Conversation)
            .filter(Conversation.id == conversation_id, Conversation.user_id == user_id)
            .one_or_none()
        )

    def add_message(
        self,
        conversation_id: uuid.UUID,
        role: str,
        content: str,
        intent: str | None = None,
        entities: dict[str, Any] | None = None,
    ) -> ConversationMessage:
        message = ConversationMessage(
            conversation_id=conversation_id,
            role=role,
            content=content,
            intent=intent,
            entities=entities,
        )
        self._db.add(message)
        self._db.commit()
        self._db.refresh(message)
        return message

    def get_recent_messages(
        self, conversation_id: uuid.UUID, limit: int
    ) -> list[ConversationMessage]:
        """Ultimos `limit` mensajes en orden cronologico (mas antiguo primero).

        docs/07_AI_ARCHITECTURE.md seccion 4: solo se envian al LLM los
        ultimos N turnos de la sesion, no el historial completo.
        """
        recent_desc = (
            self._db.query(ConversationMessage)
            .filter(ConversationMessage.conversation_id == conversation_id)
            .order_by(ConversationMessage.created_at.desc())
            .limit(limit)
            .all()
        )
        return list(reversed(recent_desc))
