import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

from app.api.v1.router import router as v1_router
from app.exceptions import DomainError
from app.services.ai_providers.factory import get_ai_provider

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        get_ai_provider().warmup()
    except DomainError:
        # Ollama puede no estar listo aun (p. ej. en el primer arranque de
        # Docker Compose); el primer turno real pagara el costo de carga
        # en frio en vez de bloquear el arranque del backend.
        logger.warning("No se pudo precargar el modelo de Ollama al iniciar.")
    yield


app = FastAPI(title="JOTA AI Backend", lifespan=lifespan)

app.include_router(v1_router, prefix="/api/v1")


@app.exception_handler(DomainError)
def handle_domain_error(request: Request, exc: DomainError) -> JSONResponse:
    return JSONResponse(
        status_code=exc.http_status,
        content={"error": {"code": exc.code, "message": exc.message}},
    )
