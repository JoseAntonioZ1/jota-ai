import uuid
from datetime import datetime

from sqlalchemy.orm import Session

from app.models.reminder import Reminder


class ReminderRepository:
    def __init__(self, db: Session) -> None:
        self._db = db

    def create(
        self,
        user_id: uuid.UUID,
        description: str,
        reminder_type: str,
        scheduled_at: datetime,
    ) -> Reminder:
        reminder = Reminder(
            user_id=user_id,
            description=description,
            reminder_type=reminder_type,
            scheduled_at=scheduled_at,
        )
        self._db.add(reminder)
        self._db.commit()
        self._db.refresh(reminder)
        return reminder

    def list_for_user(
        self, user_id: uuid.UUID, status: str | None, limit: int, offset: int
    ) -> tuple[list[Reminder], int]:
        query = self._db.query(Reminder).filter(Reminder.user_id == user_id)
        if status is not None:
            query = query.filter(Reminder.status == status)

        total = query.count()
        items = (
            query.order_by(Reminder.scheduled_at.asc()).offset(offset).limit(limit).all()
        )
        return items, total

    def get(self, reminder_id: uuid.UUID, user_id: uuid.UUID) -> Reminder | None:
        return (
            self._db.query(Reminder)
            .filter(Reminder.id == reminder_id, Reminder.user_id == user_id)
            .one_or_none()
        )

    def update(self, reminder: Reminder, **fields: object) -> Reminder:
        for key, value in fields.items():
            setattr(reminder, key, value)
        self._db.commit()
        self._db.refresh(reminder)
        return reminder

    def delete(self, reminder: Reminder) -> None:
        self._db.delete(reminder)
        self._db.commit()
