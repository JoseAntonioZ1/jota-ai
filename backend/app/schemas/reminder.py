import uuid
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict

ReminderType = Literal["medication", "event", "activity"]
ReminderStatus = Literal["pending", "completed", "cancelled"]


class ReminderCreateRequest(BaseModel):
    description: str
    reminder_type: ReminderType
    scheduled_at: datetime


class ReminderUpdateRequest(BaseModel):
    description: str | None = None
    reminder_type: ReminderType | None = None
    scheduled_at: datetime | None = None
    status: ReminderStatus | None = None


class ReminderResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    description: str
    reminder_type: ReminderType
    scheduled_at: datetime
    status: ReminderStatus


class ReminderListResponse(BaseModel):
    items: list[ReminderResponse]
    total: int
