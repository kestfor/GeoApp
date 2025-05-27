import uuid
from typing import Optional, Dict, List, TYPE_CHECKING

from sqlalchemy import Column, Enum, JSON
from sqlmodel import SQLModel, Field, Relationship, UUID

from core.models import BaseModelMixin
from core.models.base import TimestampMixin
from core.schemas import MediaType

if TYPE_CHECKING:
    from core.models import MediaRepresentation


class Media(SQLModel, BaseModelMixin, TimestampMixin, table=True):
    __tablename__ = 'media'

    id: str = Field(sa_column=Column("id", UUID,
                                     nullable=False, primary_key=True, default=uuid.uuid4))
    # Можно использовать перечисление, для простоты указан строковый тип
    media_type: MediaType = Field(
        sa_column=Column(Enum('photo', 'video', name='media_type'), nullable=False)
    )
    exif_metadata: Optional[Dict] = Field(
        default=None, sa_column=Column(JSON, nullable=True)
    )

    # author_id

    # Отношение к представлениям медиа
    representations: List["MediaRepresentation"] = Relationship(
        back_populates="media", sa_relationship_kwargs={"cascade": "all, delete-orphan"}
    )
