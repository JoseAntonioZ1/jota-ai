import uuid

from pydantic import BaseModel


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


class UserUpdateRequest(BaseModel):
    name: str | None = None
    onboarding_completed: bool | None = None
