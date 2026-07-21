import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_user
from app.database import get_db
from app.models.user import User
from app.repositories.reminder_repository import ReminderRepository
from app.schemas.reminder import (
    ReminderCreateRequest,
    ReminderListResponse,
    ReminderResponse,
    ReminderStatus,
    ReminderUpdateRequest,
)
from app.services.reminder_service import ReminderService

router = APIRouter()


def _service(db: Session = Depends(get_db)) -> ReminderService:
    return ReminderService(ReminderRepository(db))


@router.get("/reminders", response_model=ReminderListResponse)
def list_reminders(
    status: ReminderStatus | None = Query(default=None),
    limit: int = Query(default=20, le=50),
    offset: int = Query(default=0, ge=0),
    current_user: User = Depends(get_current_user),
    service: ReminderService = Depends(_service),
) -> ReminderListResponse:
    items, total = service.list_reminders(current_user.id, status, limit, offset)
    return ReminderListResponse(
        items=[ReminderResponse.model_validate(item) for item in items], total=total
    )


@router.post("/reminders", response_model=ReminderResponse, status_code=201)
def create_reminder(
    payload: ReminderCreateRequest,
    current_user: User = Depends(get_current_user),
    service: ReminderService = Depends(_service),
) -> ReminderResponse:
    reminder = service.create_reminder(
        current_user.id, payload.description, payload.reminder_type, payload.scheduled_at
    )
    return ReminderResponse.model_validate(reminder)


@router.patch("/reminders/{reminder_id}", response_model=ReminderResponse)
def update_reminder(
    reminder_id: uuid.UUID,
    payload: ReminderUpdateRequest,
    current_user: User = Depends(get_current_user),
    service: ReminderService = Depends(_service),
) -> ReminderResponse:
    fields = payload.model_dump(exclude_unset=True)
    reminder = service.update_reminder(current_user.id, reminder_id, **fields)
    return ReminderResponse.model_validate(reminder)


@router.delete("/reminders/{reminder_id}", status_code=204)
def delete_reminder(
    reminder_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    service: ReminderService = Depends(_service),
) -> None:
    service.delete_reminder(current_user.id, reminder_id)
