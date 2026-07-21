from fastapi import APIRouter

from app.api.v1 import conversations, devices

router = APIRouter()


@router.get("/health")
def health_check() -> dict[str, str]:
    return {"status": "ok"}


router.include_router(devices.router)
router.include_router(conversations.router)
