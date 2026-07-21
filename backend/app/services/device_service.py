from app.models.user import User
from app.repositories.user_repository import UserRepository
from app.security import generate_device_token, hash_device_token


class DeviceService:
    def __init__(self, user_repo: UserRepository) -> None:
        self._user_repo = user_repo

    def register_device(self) -> tuple[User, str]:
        """Crea un usuario nuevo y devuelve (usuario, token_en_claro).

        El token en claro solo existe en este momento; el repositorio
        solo persiste su hash (docs/08_DATABASE_DESIGN.md seccion 3.1).
        """
        raw_token = generate_device_token()
        token_hash = hash_device_token(raw_token)
        user = self._user_repo.create(device_token_hash=token_hash, name="")
        return user, raw_token
