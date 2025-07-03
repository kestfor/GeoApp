from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

from core.exceptions import S3Error, RedisError, PostgresError


def setup_exception_handlers(app: FastAPI):
    @app.exception_handler(S3Error)
    async def s3_exception_handler(request: Request, exc: S3Error):
        return JSONResponse(
            status_code=500,
            content={"detail": f"Ошибка S3: {exc}"}
        )

    @app.exception_handler(RedisError)
    async def redis_exception_handler(request: Request, exc: RedisError):
        return JSONResponse(
            status_code=500,
            content={"detail": f"Ошибка Redis: {exc}"}
        )

    @app.exception_handler(PostgresError)
    async def postgres_exception_handler(request: Request, exc: PostgresError):
        return JSONResponse(
            status_code=500,
            content={"detail": f"Ошибка базы данных: {exc}"}
        )
