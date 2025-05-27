from sqlalchemy.ext.asyncio import AsyncEngine, async_sessionmaker, create_async_engine, AsyncSession

from core.config import settings

_async_engine: AsyncEngine | None = None
_async_sessionmaker: async_sessionmaker | None = None


def get_engine() -> AsyncEngine:
    global _async_engine
    if _async_engine is None:
        _async_engine = create_async_engine(
            settings.postgres.url_async,
            echo=settings.postgres.echo,
            future=True,
        )
    return _async_engine


def get_sessionmaker() -> async_sessionmaker:
    global _async_sessionmaker
    if _async_sessionmaker is None:
        _async_sessionmaker = async_sessionmaker(
            bind=get_engine(),
            expire_on_commit=False,
        )
    return _async_sessionmaker


async def get_session() -> AsyncSession:
    """
    Dependency для FastAPI: контекстный менеджер для получения сессии.
    """
    session_factory = get_sessionmaker()
    async with session_factory() as session:
        async with session.begin():
            yield session
