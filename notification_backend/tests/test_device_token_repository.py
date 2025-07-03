import pytest
import datetime
from uuid import uuid4

import pytest_asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlmodel import SQLModel

from core.models import DeviceToken
from core.schemas import DevicePlatform
from core.repositories import DeviceTokenRepository

DATABASE_URL = "sqlite+aiosqlite:///:memory:"

@pytest.fixture(name="engine")
def fixture_engine():
    engine = create_async_engine(DATABASE_URL, echo=False)
    yield engine

@pytest_asyncio.fixture(name="async_session")
async def fixture_async_session(engine):
    async with engine.begin() as conn:
        await conn.run_sync(SQLModel.metadata.create_all)

    async_session_maker = sessionmaker(
        engine, expire_on_commit=False, class_=AsyncSession
    )
    async with async_session_maker() as session:
        yield session

@pytest.fixture(name="repo")
def fixture_repo(async_session):
    return DeviceTokenRepository(async_session)

@pytest.mark.asyncio
async def test_upsert_and_conflict(repo):
    token = "token1"
    user_id1 = uuid4()
    user_id2 = uuid4()

    obj = await repo.upsert(user_id1, token, DevicePlatform.IOS, is_active=True)
    print(obj)
    assert obj.id is not None

    updated = await repo.upsert(user_id2, token, DevicePlatform.ANDROID, is_active=False)
    assert updated.id == obj.id
    assert updated.user_id == user_id2
