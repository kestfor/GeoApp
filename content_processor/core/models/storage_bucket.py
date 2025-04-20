from typing import Optional, List, TYPE_CHECKING

from sqlalchemy import Column, String
from sqlmodel import SQLModel, Field, Relationship

from core.models import BaseModelMixin, TimestampMixin

if TYPE_CHECKING:
    from core.models import MediaRepresentation


class StorageBucket(SQLModel, BaseModelMixin, TimestampMixin, table=True):
    __tablename__ = 'storage_bucket'

    id: Optional[int] = Field(default=None, primary_key=True)
    name: str = Field(
        sa_column=Column(String(32), unique=True, nullable=False)
    )  # Имя бакета
    storage_class: str = Field(
        sa_column=Column(String(12), nullable=False)
    )  # Тип хранения (например, standard, cold, ледяное)

    # Обратная связь для представлений, находящихся в данном бакете
    media_representations: List["MediaRepresentation"] = Relationship(
        back_populates="bucket"
    )
