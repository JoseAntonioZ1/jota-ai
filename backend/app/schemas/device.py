import uuid

from pydantic import BaseModel

from app.schemas.contact import ContactResponse


class DeviceCreateRequest(BaseModel):
    device_fingerprint: str


class DeviceCreateResponse(BaseModel):
    user_id: uuid.UUID
    device_token: str
    onboarding_completed: bool


class UserMeResponse(BaseModel):
    user_id: uuid.UUID
    name: str | None
    onboarding_completed: bool
    emergency_contact: ContactResponse | None = None


class UserUpdateRequest(BaseModel):
    name: str | None = None
    onboarding_completed: bool | None = None
