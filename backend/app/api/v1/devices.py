from datetime import datetime, timezone

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_user
from app.database import get_db
from app.models.user import User
from app.repositories.user_repository import UserRepository
from app.schemas.device import DeviceCreateResponse, UserMeResponse, UserUpdateRequest
from app.services.device_service import DeviceService

router = APIRouter()


@router.post("/devices", response_model=DeviceCreateResponse, status_code=201)
def register_device(db: Session = Depends(get_db)) -> DeviceCreateResponse:
    service = DeviceService(UserRepository(db))
    user, raw_token = service.register_device()
    return DeviceCreateResponse(
        user_id=user.id,
        device_token=raw_token,
        onboarding_completed=user.onboarding_completed_at is not None,
    )


@router.get("/users/me", response_model=UserMeResponse)
def get_me(current_user: User = Depends(get_current_user)) -> UserMeResponse:
    return _to_user_me_response(current_user)


@router.patch("/users/me", response_model=UserMeResponse)
def update_me(
    payload: UserUpdateRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> UserMeResponse:
    fields: dict[str, object] = {}
    if payload.name is not None:
        fields["name"] = payload.name
    if payload.onboarding_completed is True:
        fields["onboarding_completed_at"] = datetime.now(timezone.utc)

    user = UserRepository(db).update(current_user, **fields)
    return _to_user_me_response(user)


def _to_user_me_response(user: User) -> UserMeResponse:
    return UserMeResponse(
        user_id=user.id,
        name=user.name or None,
        onboarding_completed=user.onboarding_completed_at is not None,
    )
