import uuid

from app.exceptions import NotFoundError
from app.models.contact import Contact
from app.models.user import User
from app.repositories.contact_repository import ContactRepository
from app.repositories.user_repository import UserRepository


class EmergencyService:
    """docs/04_USE_CASES.md UC-09."""

    def __init__(self, user_repo: UserRepository, contact_repo: ContactRepository) -> None:
        self._user_repo = user_repo
        self._contact_repo = contact_repo

    def set_emergency_contact(self, user: User, contact_id: uuid.UUID) -> Contact:
        contact = self._contact_repo.get(contact_id, user.id)
        if contact is None:
            raise NotFoundError("No se encontro el contacto solicitado.")
        self._user_repo.update(user, emergency_contact_id=contact.id)
        return contact

    def get_emergency_contact(self, user: User) -> Contact | None:
        if user.emergency_contact_id is None:
            return None
        return self._contact_repo.get(user.emergency_contact_id, user.id)
