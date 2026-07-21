class DomainError(Exception):
    """Error base para fallos de negocio que la capa api/ traduce a HTTP."""

    code: str = "domain_error"
    http_status: int = 400

    def __init__(self, message: str) -> None:
        super().__init__(message)
        self.message = message


class NotFoundError(DomainError):
    code = "not_found"
    http_status = 404


class InvalidTokenError(DomainError):
    code = "invalid_token"
    http_status = 401


class AIProviderTimeoutError(DomainError):
    code = "ai_provider_timeout"
    http_status = 408


class AIProviderUnavailableError(DomainError):
    code = "ai_provider_unavailable"
    http_status = 503
