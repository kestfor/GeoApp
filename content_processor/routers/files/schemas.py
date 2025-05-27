from typing import Dict
from uuid import UUID

from pydantic import BaseModel, Field, HttpUrl

from core.schemas import MediaType, MediaVariant


class MediaBase(BaseModel):
    type: MediaType
    media_id: UUID
    author_id: int = Field(default=1)
    metadata: dict = Field(default_factory=dict)


class VideoInfo(MediaBase):
    url: HttpUrl
    thumbnail: HttpUrl


class RepresentationInfo(BaseModel):
    variant: MediaVariant
    url: HttpUrl
    file_size_bytes: int


class PhotoInfo(MediaBase):
    representations: Dict[MediaVariant, RepresentationInfo]
