import uuid

from sqlalchemy.orm import Session

from app.models.contact import Contact


class ContactRepository:
    def __init__(self, db: Session) -> None:
        self._db = db

    def create(
        self, user_id: uuid.UUID, name: str, phone_number: str, photo_url: str | None
    ) -> Contact:
        contact = Contact(
            user_id=user_id, name=name, phone_number=phone_number, photo_url=photo_url
        )
        self._db.add(contact)
        self._db.commit()
        self._db.refresh(contact)
        return contact

    def list_for_user(
        self, user_id: uuid.UUID, limit: int, offset: int
    ) -> tuple[list[Contact], int]:
        query = self._db.query(Contact).filter(Contact.user_id == user_id)
        total = query.count()
        items = query.order_by(Contact.name.asc()).offset(offset).limit(limit).all()
        return items, total

    def get(self, contact_id: uuid.UUID, user_id: uuid.UUID) -> Contact | None:
        return (
            self._db.query(Contact)
            .filter(Contact.id == contact_id, Contact.user_id == user_id)
            .one_or_none()
        )

    def update(self, contact: Contact, **fields: object) -> Contact:
        for key, value in fields.items():
            setattr(contact, key, value)
        self._db.commit()
        self._db.refresh(contact)
        return contact

    def delete(self, contact: Contact) -> None:
        self._db.delete(contact)
        self._db.commit()
