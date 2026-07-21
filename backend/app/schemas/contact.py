import uuid
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict


class ContactCreateRequest(BaseModel):
    name: str
    phone_number: str
    photo_url: str | None = None


class ContactUpdateRequest(BaseModel):
    name: str | None = None
    phone_number: str | None = None
    photo_url: str | None = None


class ContactResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    name: str
    phone_number: str
    photo_url: str | None = None


class ContactListResponse(BaseModel):
    items: list[ContactResponse]
    total: int


class ContactCallLogRequest(BaseModel):
    call_type: Literal["frequent", "emergency"] = "frequent"


class ContactCallLogResponse(BaseModel):
    id: uuid.UUID
    action_type: str
    created_at: datetime
