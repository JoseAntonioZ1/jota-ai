import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict


class ActionLogResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    action_type: str
    description: str
    created_at: datetime


class ActionLogListResponse(BaseModel):
    items: list[ActionLogResponse]
    total: int
