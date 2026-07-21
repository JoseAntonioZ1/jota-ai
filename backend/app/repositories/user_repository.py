import uuid

from sqlalchemy.orm import Session

from app.models.user import User


class UserRepository:
    def __init__(self, db: Session) -> None:
        self._db = db

    def create(self, device_token_hash: str, name: str) -> User:
        user = User(device_token_hash=device_token_hash, name=name)
        self._db.add(user)
        self._db.commit()
        self._db.refresh(user)
        return user

    def get_by_token_hash(self, device_token_hash: str) -> User | None:
        return (
            self._db.query(User)
            .filter(User.device_token_hash == device_token_hash)
            .one_or_none()
        )

    def get_by_id(self, user_id: uuid.UUID) -> User | None:
        return self._db.get(User, user_id)

    def update(self, user: User, **fields: object) -> User:
        for key, value in fields.items():
            setattr(user, key, value)
        self._db.commit()
        self._db.refresh(user)
        return user
