import uuid
from datetime import datetime

from app.exceptions import NotFoundError
from app.models.reminder import Reminder
from app.repositories.reminder_repository import ReminderRepository


class ReminderService:
    def __init__(self, repo: ReminderRepository) -> None:
        self._repo = repo

    def create_reminder(
        self,
        user_id: uuid.UUID,
        description: str,
        reminder_type: str,
        scheduled_at: datetime,
    ) -> Reminder:
        return self._repo.create(user_id, description, reminder_type, scheduled_at)

    def list_reminders(
        self, user_id: uuid.UUID, status: str | None, limit: int, offset: int
    ) -> tuple[list[Reminder], int]:
        return self._repo.list_for_user(user_id, status, limit, offset)

    def update_reminder(
        self, user_id: uuid.UUID, reminder_id: uuid.UUID, **fields: object
    ) -> Reminder:
        reminder = self._repo.get(reminder_id, user_id)
        if reminder is None:
            raise NotFoundError("No se encontro el recordatorio solicitado.")
        return self._repo.update(reminder, **fields)

    def delete_reminder(self, user_id: uuid.UUID, reminder_id: uuid.UUID) -> None:
        reminder = self._repo.get(reminder_id, user_id)
        if reminder is None:
            raise NotFoundError("No se encontro el recordatorio solicitado.")
        self._repo.delete(reminder)
