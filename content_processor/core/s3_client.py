import aioboto3
from aiobotocore.client import AioBaseClient

from core.config import settings

_session: aioboto3.Session | None = None


def get_s3_session() -> aioboto3.Session:
    """
    Возвращает лениво инициализированную S3-сессию.
    """
    global _session
    if _session is None:
        _session = aioboto3.Session()
    return _session


async def get_s3_client() -> AioBaseClient:
    """
    Асинхронный контекстный менеджер, который возвращает s3 клиент.
    Автоматически закрывает соединение после использования.
    """
    session = get_s3_session()
    async with session.client(
            "s3",
            endpoint_url=settings.s3_settings.ENDPOINT_URL,
            aws_secret_access_key=settings.s3_settings.ACCESS_SECRET,
            aws_access_key_id=settings.s3_settings.ACCESS_KEY,
    ) as s3_client:
        yield s3_client
