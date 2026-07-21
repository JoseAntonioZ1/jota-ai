from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app.repositories.user_repository import UserRepository
from app.schemas.device import DeviceCreateResponse
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
