import uuid

from app.exceptions import NotFoundError
from app.models.contact import Contact
from app.models.user import User
from app.repositories.action_log_repository import ActionLogRepository
from app.repositories.contact_repository import ContactRepository
from app.repositories.user_repository import UserRepository


class ContactService:
    def __init__(
        self,
        repo: ContactRepository,
        action_log_repo: ActionLogRepository,
        user_repo: UserRepository,
    ) -> None:
        self._repo = repo
        self._action_log_repo = action_log_repo
        self._user_repo = user_repo

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

    def delete_contact(self, user: User, contact_id: uuid.UUID) -> bool:
        """docs/09_API_DESIGN.md seccion 4.4: si el contacto eliminado era
        el de emergencia vigente, se limpia la referencia y se informa al
        llamador (para que la app pueda redirigir a UC-09)."""
        contact = self._repo.get(contact_id, user.id)
        if contact is None:
            raise NotFoundError("No se encontro el contacto solicitado.")

        was_emergency_contact = user.emergency_contact_id == contact.id
        self._repo.delete(contact)
        if was_emergency_contact:
            self._user_repo.update(user, emergency_contact_id=None)
        return was_emergency_contact

    def log_call(self, user_id: uuid.UUID, contact_id: uuid.UUID, call_type: str):
        contact = self._repo.get(contact_id, user_id)
        if contact is None:
            raise NotFoundError("No se encontro el contacto solicitado.")
        action_type = "emergency_called" if call_type == "emergency" else "contact_called"
        description = f"Llamada a {contact.name}"
        return self._action_log_repo.create(
            user_id=user_id,
            action_type=action_type,
            description=description,
            reference_id=contact.id,
        )
