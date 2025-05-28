import datetime
import logging
from typing import Optional, Dict

from sqlalchemy import and_, select, inspect, Column, func, DateTime
from sqlalchemy.ext.asyncio import AsyncAttrs
from sqlalchemy.orm import declarative_mixin
from sqlalchemy.util import immutabledict
from sqlmodel import SQLModel, Field, TIMESTAMP
from sqlmodel.ext.asyncio.session import AsyncSession

logger = logging.getLogger(__name__)


class BaseModelMixin(AsyncAttrs):
    __repr_attrs__ = []

    def to_dict(self) -> Dict:
        return self.model_dump()  # Используем встроенный метод Pydantic

    @property
    def get_session(self) -> Optional[AsyncSession]:
        session = inspect(self).session
        return session

    @classmethod
    async def get_all(cls, session: AsyncSession, expunge: bool = False):
        stmt = select(cls)
        objs = (await session.scalars(stmt)).unique().all()
        if expunge:
            session.expunge_all()
        return objs

    @classmethod
    async def get(cls, session: AsyncSession, id: int, expunge: bool = False):
        try:
            stmt = select(cls).where(cls.id == id)
            obj = await session.scalar(stmt)
            if expunge:
                session.expunge_all()
            return obj
        except Exception as e:
            logger.exception(e)

    @classmethod
    async def get_by(cls, session: AsyncSession, **kwargs):
        stmt = select(cls).where(and_(getattr(cls, k) == v for k, v in kwargs.items()))
        obj = await session.scalar(stmt)
        # session.expunge_all()
        return obj

    @classmethod
    async def create(cls, session: AsyncSession, **kwargs):
        obj = cls(**kwargs)
        session.add(obj)
        await session.flush()
        session.expunge_all()
        return obj

    @classmethod
    async def update(cls, session: AsyncSession, id: int, **kwargs):
        if obj := await cls.get(session, id):
            for key, value in kwargs.items():
                setattr(obj, key, value)
            await session.flush()
            session.expunge_all()
        return obj

    def __repr__(self):
        attrs = [f"{attr}={getattr(self, attr)}" for attr in self.__repr_attrs__]
        return f"<{self.__class__.__name__} {', '.join(attrs)}>"


@declarative_mixin
class TimestampMixin:
    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )
    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )

def utc_now():
    return datetime.datetime.now(datetime.UTC)


convention = {
    "ix": "ix_%(column_0_label)s",
    "uq": "uq_%(table_name)s_%(column_0_name)s",
    "ck": "ck_%(table_name)s_%(constraint_name)s",
    "fk": "fk_%(table_name)s_%(column_0_name)s_%(referred_table_name)s",
    "pk": "pk_%(table_name)s",
}

SQLModel.metadata.naming_convention = immutabledict(convention)
