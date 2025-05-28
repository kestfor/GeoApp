from typing import Optional, TYPE_CHECKING

from sqlalchemy import Column, Integer, String, ForeignKey, UUID
from sqlmodel import Field, SQLModel, Relationship

from core.models import BaseModelMixin
from core.models.base import TimestampMixin
from core.schemas import MediaVariant

if TYPE_CHECKING:
    from core.models import Media, StorageBucket


class MediaRepresentation(SQLModel, BaseModelMixin, TimestampMixin, table=True):
    __tablename__ = 'media_representation'

    id: Optional[int] = Field(default=None, primary_key=True)

    media_id: str = Field(
        sa_column=Column(UUID, ForeignKey("media.id"), nullable=False)
    )

    # Название представления (например: 'thumbnail', 'medium', 'original')
    variant: MediaVariant = Field(
        sa_column=Column(String(16), nullable=False)
    )
    s3_key: str = Field(
        sa_column=Column(String(128), nullable=False)
    )

    # Атрибуты конкретного представления
    file_size_bytes: int = Field(
        sa_column=Column(Integer, nullable=False)
    )
    hash: str = Field(
        sa_column=Column(String(1024), nullable=False)
    )
    hash_type: str = Field(
        sa_column=Column(String(10), nullable=False)
    )

    # Связь с бакетом хранения
    bucket_id: int = Field(
        sa_column=Column(Integer, ForeignKey("storage_bucket.id"), nullable=False)
    )

    # Обратные связи
    media: "Media" = Relationship(back_populates="representations")
    bucket: "StorageBucket" = Relationship(back_populates="media_representations")
