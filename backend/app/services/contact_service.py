import uuid

from app.exceptions import NotFoundError
from app.models.contact import Contact
from app.repositories.action_log_repository import ActionLogRepository
from app.repositories.contact_repository import ContactRepository


class ContactService:
    def __init__(self, repo: ContactRepository, action_log_repo: ActionLogRepository) -> None:
        self._repo = repo
        self._action_log_repo = action_log_repo

    def create_contact(
        self, user_id: uuid.UUID, name: str, phone_number: str, photo_url: str | None
    ) -> Contact:
        return self._repo.create(user_id, name, phone_number, photo_url)

    def list_contacts(
        self, user_id: uuid.UUID, limit: int, offset: int
    ) -> tuple[list[Contact], int]:
        return self._repo.list_for_user(user_id, limit, offset)

    def update_contact(
        self, user_id: uuid.UUID, contact_id: uuid.UUID, **fields: object
    ) -> Contact:
        contact = self._repo.get(contact_id, user_id)
        if contact is None:
            raise NotFoundError("No se encontro el contacto solicitado.")
        return self._repo.update(contact, **fields)

    def delete_contact(self, user_id: uuid.UUID, contact_id: uuid.UUID) -> None:
        contact = self._repo.get(contact_id, user_id)
        if contact is None:
            raise NotFoundError("No se encontro el contacto solicitado.")
        self._repo.delete(contact)

    def log_call(self, user_id: uuid.UUID, contact_id: uuid.UUID, call_type: str):
        contact = self._repo.get(contact_id, user_id)
        if contact is None:
            raise NotFoundError("No se encontro el contacto solicitado.")
        # docs/04_USE_CASES.md UC-10: la llamada de emergencia se registrara
        # como "emergency_called" cuando la Fase 6 construya ese flujo; por
        # ahora todo llamado desde Contactos es "contact_called".
        action_type = "contact_called"
        description = f"Llamada a {contact.name}"
        return self._action_log_repo.create(
            user_id=user_id,
            action_type=action_type,
            description=description,
            reference_id=contact.id,
        )
