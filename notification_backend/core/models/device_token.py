from typing import Optional
from uuid import UUID

from sqlalchemy import Column, String, Enum as SAEnum
from sqlalchemy.dialects.postgresql import UUID as PGUUID
from sqlmodel import SQLModel, Field

from core.models import TimestampMixin
from core.schemas.general import DevicePlatform


class DeviceToken(SQLModel, TimestampMixin, table=True):
    __tablename__ = "device_tokens"

    id: Optional[int] = Field(default=None, primary_key=True)
    # Change user_id to UUID type, storing it in Postgres as UUID
    user_id: Optional[UUID] = Field(
        default=None,
        sa_column=Column(
            "user_id",
            PGUUID(as_uuid=True),
            nullable=True,
            index=True,
        )
    )
    token: str = Field(
        sa_column=Column(
            "token",
            String(512),
            unique=True,
            nullable=False
        )
    )
    platform: DevicePlatform = Field(
        sa_column=Column(
            "platform",
            SAEnum(DevicePlatform, name="device_platform"),
            nullable=False
        )
    )
    is_active: bool = Field(default=True, nullable=False)

    def __init__(
            self,
            **data
    ):
        # Ensure that if a user_id string is passed, it's converted to UUID
        if "user_id" in data and data["user_id"] is not None:
            data["user_id"] = UUID(str(data["user_id"]))
        super().__init__(**data)
