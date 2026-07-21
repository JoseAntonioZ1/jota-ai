import uuid

from app.exceptions import NotFoundError
from app.models.action_log import ActionLog
from app.models.conversation import Conversation
from app.models.conversation_message import ConversationMessage
from app.repositories.action_log_repository import ActionLogRepository
from app.repositories.conversation_repository import ConversationRepository


class HistoryService:
    """docs/04_USE_CASES.md UC-11 - vista de solo lectura, sin mutaciones."""

    def __init__(
        self, conversation_repo: ConversationRepository, action_log_repo: ActionLogRepository
    ) -> None:
        self._conversation_repo = conversation_repo
        self._action_log_repo = action_log_repo

    def list_conversations(
        self, user_id: uuid.UUID, limit: int, offset: int
    ) -> tuple[list[Conversation], int]:
        return self._conversation_repo.list_for_user(user_id, limit, offset)

    def get_conversation_messages(
        self, user_id: uuid.UUID, conversation_id: uuid.UUID, limit: int, offset: int
    ) -> tuple[list[ConversationMessage], int]:
        conversation = self._conversation_repo.get_conversation(conversation_id, user_id)
        if conversation is None:
            raise NotFoundError("No se encontro la conversacion solicitada.")
        return self._conversation_repo.get_messages_paginated(conversation_id, limit, offset)

    def list_action_logs(
        self, user_id: uuid.UUID, limit: int, offset: int
    ) -> tuple[list[ActionLog], int]:
        return self._action_log_repo.list_for_user(user_id, limit, offset)
