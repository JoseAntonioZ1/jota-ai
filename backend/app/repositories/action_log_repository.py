import uuid

from sqlalchemy.orm import Session

from app.models.action_log import ActionLog


class ActionLogRepository:
    """docs/08_DATABASE_DESIGN.md seccion 3.6."""

    def __init__(self, db: Session) -> None:
        self._db = db

    def create(
        self,
        user_id: uuid.UUID,
        action_type: str,
        description: str,
        reference_id: uuid.UUID | None = None,
    ) -> ActionLog:
        log = ActionLog(
            user_id=user_id,
            action_type=action_type,
            reference_id=reference_id,
            description=description,
        )
        self._db.add(log)
        self._db.commit()
        self._db.refresh(log)
        return log

    def list_for_user(
        self, user_id: uuid.UUID, limit: int, offset: int
    ) -> tuple[list[ActionLog], int]:
        """docs/04_USE_CASES.md UC-11 (FR-06.2)."""
        query = self._db.query(ActionLog).filter(ActionLog.user_id == user_id)
        total = query.count()
        items = query.order_by(ActionLog.created_at.desc()).offset(offset).limit(limit).all()
        return items, total
