import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_user
from app.database import get_db
from app.models.user import User
from app.repositories.action_log_repository import ActionLogRepository
from app.repositories.contact_repository import ContactRepository
from app.schemas.contact import (
    ContactCallLogRequest,
    ContactCallLogResponse,
    ContactCreateRequest,
    ContactListResponse,
    ContactResponse,
    ContactUpdateRequest,
)
from app.services.contact_service import ContactService

router = APIRouter()


def _service(db: Session = Depends(get_db)) -> ContactService:
    return ContactService(ContactRepository(db), ActionLogRepository(db))


@router.get("/contacts", response_model=ContactListResponse)
def list_contacts(
    limit: int = Query(default=20, le=50),
    offset: int = Query(default=0, ge=0),
    current_user: User = Depends(get_current_user),
    service: ContactService = Depends(_service),
) -> ContactListResponse:
    items, total = service.list_contacts(current_user.id, limit, offset)
    return ContactListResponse(
        items=[ContactResponse.model_validate(item) for item in items], total=total
    )


@router.post("/contacts", response_model=ContactResponse, status_code=201)
def create_contact(
    payload: ContactCreateRequest,
    current_user: User = Depends(get_current_user),
    service: ContactService = Depends(_service),
) -> ContactResponse:
    contact = service.create_contact(
        current_user.id, payload.name, payload.phone_number, payload.photo_url
    )
    return ContactResponse.model_validate(contact)


@router.patch("/contacts/{contact_id}", response_model=ContactResponse)
def update_contact(
    contact_id: uuid.UUID,
    payload: ContactUpdateRequest,
    current_user: User = Depends(get_current_user),
    service: ContactService = Depends(_service),
) -> ContactResponse:
    fields = payload.model_dump(exclude_unset=True)
    contact = service.update_contact(current_user.id, contact_id, **fields)
    return ContactResponse.model_validate(contact)


@router.delete("/contacts/{contact_id}", status_code=204)
def delete_contact(
    contact_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    service: ContactService = Depends(_service),
) -> None:
    service.delete_contact(current_user.id, contact_id)


@router.post("/contacts/{contact_id}/call-log", response_model=ContactCallLogResponse, status_code=201)
def log_contact_call(
    contact_id: uuid.UUID,
    payload: ContactCallLogRequest,
    current_user: User = Depends(get_current_user),
    service: ContactService = Depends(_service),
) -> ContactCallLogResponse:
    log = service.log_call(current_user.id, contact_id, payload.call_type)
    return ContactCallLogResponse(
        id=log.id, action_type=log.action_type, created_at=log.created_at
    )
