import asyncio

from sqlalchemy import select

from core.models import StorageBucket
from dependencies.sql_session import get_sessionmaker

INITIAL_BUCKETS = {"user-content": "STANDARD", "user-content-glacier": "GLACIER"}


async def init_storages():
    session_factory = get_sessionmaker()
    async with session_factory() as session:
        async with session.begin():
            stmt = select(StorageBucket).where(StorageBucket.name.in_(INITIAL_BUCKETS))
            buckets = await session.scalars(stmt)
            not_existed = set(INITIAL_BUCKETS.keys()) - set(bucket.name for bucket in buckets)
            for bucket in not_existed:
                new_bucket = StorageBucket(name=bucket, storage_class=INITIAL_BUCKETS[bucket])
                session.add(new_bucket)


if __name__ == '__main__':
    asyncio.run(init_storages())
