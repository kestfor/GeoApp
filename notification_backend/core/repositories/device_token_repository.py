import datetime
from collections import defaultdict
from typing import List, Optional, Set
from uuid import UUID
from sqlalchemy.dialects.postgresql import insert as pg_insert
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select

from core.models import DeviceToken
from core.schemas import DevicePlatform


class DeviceTokenRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_by_id(self, token_id: int) -> Optional[DeviceToken]:
        statement = select(DeviceToken).where(DeviceToken.id == token_id)
        result = await self.session.execute(statement)
        return result.scalar_one_or_none()

    async def get_by_token(self, token: str) -> Optional[DeviceToken]:
        statement = select(DeviceToken).where(DeviceToken.token == token)
        result = await self.session.execute(statement)
        return result.scalar_one_or_none()

    async def get_tokens_by_user_ids(self, user_ids: Set[str]) -> dict[str, List[str]]:
        statement = select(DeviceToken).where(DeviceToken.user_id.in_(user_ids),
                                              DeviceToken.is_active.is_(True)).order_by(DeviceToken.created_at, DeviceToken.updated_at)
        records = await self.session.execute(statement)
        res_dict = defaultdict(list)
        for record in records.scalars():
            res_dict[record.user_id].append(record.token)
        return res_dict

    async def list_by_user(
            self,
            user_id: UUID,
            active_only: bool = True
    ) -> List[DeviceToken]:
        statement = select(DeviceToken).where(DeviceToken.user_id == user_id)
        if active_only:
            statement = statement.where(DeviceToken.is_active == True)
        result = await self.session.execute(statement)

        return result.scalars().all()

    async def upsert(
            self,
            user_id: UUID,
            token: str,
            platform: DevicePlatform,
            is_active: bool = True,
    ) -> DeviceToken:
        """
        Выполняет INSERT … ON CONFLICT (token) DO UPDATE
        одним запросом к Postgres.
        """
        now = datetime.datetime.now(datetime.UTC)

        # 1) Собираем INSERT…ON CONFLICT-выражение
        stmt = pg_insert(DeviceToken.__table__).values(
            user_id=user_id,
            token=token,
            platform=platform,
            is_active=is_active,
            created_at=now,
            updated_at=now,
        ).on_conflict_do_update(
            index_elements=["token"],  # конфликт по уникальному полю token
            set_={
                "user_id": user_id,
                "platform": platform,
                "is_active": is_active,
                "updated_at": now,  # обновляем метку времени
            }
        ).returning(DeviceToken)  # возвращаем полный ORM-объект :contentReference[oaicite:0]{index=0}

        # 2) Выполняем конструкцию и получаем результирующий ряд
        result = await self.session.execute(stmt)
        row = result.first()  # получаем строку с данными
        obj = DeviceToken(**row._mapping)  # создаём ORM-объект из данных
        return obj

    async def deactivate(self, token_id: int) -> Optional[DeviceToken]:
        obj = await self.get_by_id(token_id)
        if not obj:
            return None
        obj.is_active = False
        self.session.add(obj)
        await self.session.flush()
        return obj

    async def delete(self, token_id: int) -> bool:
        obj = await self.get_by_id(token_id)
        if not obj:
            return False
        await self.session.delete(obj)
        await self.session.flush()
        return True
