from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_user
from app.database import get_db
from app.models.user import User
from app.repositories.action_log_repository import ActionLogRepository
from app.repositories.conversation_repository import ConversationRepository
from app.schemas.action_log import ActionLogListResponse, ActionLogResponse
from app.services.history_service import HistoryService

router = APIRouter()


def _history_service(db: Session = Depends(get_db)) -> HistoryService:
    return HistoryService(ConversationRepository(db), ActionLogRepository(db))


@router.get("/action-logs", response_model=ActionLogListResponse)
def list_action_logs(
    limit: int = Query(default=20, le=50),
    offset: int = Query(default=0, ge=0),
    current_user: User = Depends(get_current_user),
    service: HistoryService = Depends(_history_service),
) -> ActionLogListResponse:
    items, total = service.list_action_logs(current_user.id, limit, offset)
    return ActionLogListResponse(
        items=[ActionLogResponse.model_validate(item) for item in items], total=total
    )
