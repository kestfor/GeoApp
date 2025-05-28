from typing import List
from uuid import UUID, uuid4

from pydantic import BaseModel, field_validator, PrivateAttr
from pydantic_core.core_schema import ValidationInfo

from core.config import settings
from core.schemas import HashType, MimeType, MediaVariant, MediaType


class MediaRepresentation(BaseModel):
    variant: MediaVariant
    hash: str
    hash_type: HashType
    mime_type: MimeType
    file_size_bytes: int

    # Если для видео и фото используются разные лимиты, можно добавить логику для определения.
    # Допустим, используем photo-лимит по умолчанию, а для видео будем проверять отдельно.
    @field_validator('file_size_bytes')
    def check_file_size(cls, file_size_bytes: int, info: ValidationInfo):
        # Если mime_type известен, можно определить, photo это или video
        mime = info.data.get("mime_type")
        if mime in {MimeType.MP4}:
            max_size = settings.s3_settings.MAX_SIZE_VIDEO_BYTES
        else:
            max_size = settings.s3_settings.MAX_SIZE_PHOTO_BYTES

        if file_size_bytes > max_size:
            raise ValueError(f'file_size_bytes ({file_size_bytes}) must be less or equal to {max_size}')
        return file_size_bytes


class MediaFull(BaseModel):
    media_type: MediaType
    exif_metadata: dict
    representations: List[MediaRepresentation]

    # Приватный атрибут для хранения UUID (не отображается в схеме и не может быть задан клиентом)
    _uuid: UUID = PrivateAttr(default_factory=uuid4)

    @property
    def uuid(self) -> str:
        """Возвращает сгенерированный UUID. Этот атрибут не входит в OpenAPI схему."""
        return str(self._uuid)


class BatchPresignedURLRequest(BaseModel):
    medias: List[MediaFull]
