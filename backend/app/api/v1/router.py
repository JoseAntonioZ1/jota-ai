from fastapi import APIRouter

from app.api.v1 import contacts, conversations, devices, reminders

router = APIRouter()


@router.get("/health")
def health_check() -> dict[str, str]:
    return {"status": "ok"}


router.include_router(devices.router)
router.include_router(conversations.router)
router.include_router(reminders.router)
router.include_router(contacts.router)
