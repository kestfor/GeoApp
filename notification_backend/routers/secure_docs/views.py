# Define your module's routes here
import secrets

from fastapi import APIRouter, Depends, HTTPException, FastAPI
from fastapi.openapi.docs import get_swagger_ui_html, get_redoc_html
from fastapi.openapi.utils import get_openapi
from fastapi.security import HTTPBasicCredentials, HTTPBasic
from starlette import status
from starlette.requests import Request
from starlette.responses import HTMLResponse, JSONResponse

from core.config import settings

router = APIRouter(tags=["docs"])
security = HTTPBasic()


def get_current_username(credentials: HTTPBasicCredentials = Depends(security)) -> str:
    correct_username = secrets.compare_digest(credentials.username, settings.secure_docs.USERNAME)
    correct_password = secrets.compare_digest(credentials.password, settings.secure_docs.PASSWORD)
    if not (correct_username and correct_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Basic"},
        )
    return credentials.username


def get_docs_auth_dep():
    # TODO: not work
    if settings.secure_docs.IS_ENABLED:
        return Depends(get_current_username)
    return None  # Не требует авторизации


@router.get("/docs", response_class=HTMLResponse)
async def get_docs(username: str = get_docs_auth_dep()) -> HTMLResponse:
    return get_swagger_ui_html(openapi_url="docs/openapi.json", title="docs")


@router.get("/redoc", response_class=HTMLResponse)
async def get_redoc(username: str = get_docs_auth_dep()) -> HTMLResponse:
    return get_redoc_html(openapi_url="docs/openapi.json", title="redoc")


@router.get("/docs/openapi.json", response_class=JSONResponse)
async def get_openapi_json(request: Request, username: str = get_docs_auth_dep()) -> JSONResponse:
    app: FastAPI = request.app
    openapi_schema = get_openapi(
        title=app.title,
        version=app.version,
        description=app.description,
        routes=app.routes,
    )
    return JSONResponse(openapi_schema)
