import uuid

from sqlalchemy.orm import Session

from app.models.action_log import ActionLog


class ActionLogRepository:
    """docs/08_DATABASE_DESIGN.md seccion 3.6. Solo `create` por ahora: la
    lectura/listado (FR-06.2) es alcance de la Fase 7 (Historial)."""

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
