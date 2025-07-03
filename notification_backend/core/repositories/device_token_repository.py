import datetime
import logging
from collections import defaultdict
from typing import List, Optional, Set
from uuid import UUID

from sqlalchemy.dialects.postgresql import insert as pg_insert
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select

from core.models import DeviceToken
from core.schemas import DevicePlatform


logger = logging.getLogger(__name__)


class DeviceTokenRepository:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.logger = logger
        self.logger.info("Initialized DeviceTokenRepository with session %s", session)

    async def get_by_id(self, token_id: int) -> Optional[DeviceToken]:
        self.logger.info("get_by_id called with token_id=%s", token_id)
        statement = select(DeviceToken).where(DeviceToken.id == token_id)
        result = await self.session.execute(statement)
        obj = result.scalar_one_or_none()
        self.logger.info("get_by_id result: %s", obj)
        return obj

    async def get_by_token(self, token: str) -> Optional[DeviceToken]:
        self.logger.info("get_by_token called with token=%s", token)
        statement = select(DeviceToken).where(DeviceToken.token == token)
        result = await self.session.execute(statement)
        obj = result.scalar_one_or_none()
        self.logger.info("get_by_token result: %s", obj)
        return obj

    async def get_tokens_by_user_ids(self, user_ids: Set[str]) -> dict[str, List[str]]:
        self.logger.info("get_tokens_by_user_ids called with user_ids=%s", user_ids)
        statement = (
            select(DeviceToken)
            .where(
                DeviceToken.user_id.in_(user_ids),
                DeviceToken.is_active.is_(True)
            )
            .order_by(DeviceToken.created_at, DeviceToken.updated_at)
        )
        records = await self.session.execute(statement)
        res_dict = defaultdict(list)
        for record in records.scalars():
            res_dict[str(record.user_id)].append(str(record.token))
        self.logger.info("get_tokens_by_user_ids result: %s", res_dict)
        return res_dict

    async def list_by_user(
        self,
        user_id: UUID,
        active_only: bool = True
    ) -> List[DeviceToken]:
        self.logger.info("list_by_user called with user_id=%s active_only=%s", user_id, active_only)
        statement = select(DeviceToken).where(DeviceToken.user_id == user_id)
        if active_only:
            statement = statement.where(DeviceToken.is_active == True)
        result = await self.session.execute(statement)
        objs = result.scalars().all()
        self.logger.info("list_by_user result count: %s", len(objs))
        return objs

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
        self.logger.info(
            "upsert called with user_id=%s, token=%s, platform=%s, is_active=%s",
            user_id, token, platform, is_active
        )

        stmt = pg_insert(DeviceToken.__table__).values(
            user_id=user_id,
            token=token,
            platform=platform,
            is_active=is_active,
            created_at=now,
            updated_at=now,
        ).on_conflict_do_update(
            index_elements=["token"],
            set_={
                "user_id": user_id,
                "platform": platform,
                "is_active": is_active,
                "updated_at": now,
            }
        ).returning(DeviceToken)

        result = await self.session.execute(stmt)
        row = result.first()
        obj = DeviceToken(**row._mapping)
        self.logger.info("upsert result: %s", obj)
        return obj

    async def deactivate(self, token_id: int) -> Optional[DeviceToken]:
        self.logger.info("deactivate called with token_id=%s", token_id)
        obj = await self.get_by_id(token_id)
        if not obj:
            self.logger.warning("deactivate: DeviceToken with id=%s not found", token_id)
            return None
        obj.is_active = False
        self.session.add(obj)
        await self.session.flush()
        self.logger.info("DeviceToken id=%s deactivated", token_id)
        return obj

    async def delete(self, token_id: int) -> bool:
        self.logger.info("delete called with token_id=%s", token_id)
        obj = await self.get_by_id(token_id)
        if not obj:
            self.logger.warning("delete: DeviceToken with id=%s not found", token_id)
            return False
        await self.session.delete(obj)
        await self.session.flush()
        self.logger.info("DeviceToken id=%s deleted", token_id)
        return True
