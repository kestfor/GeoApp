from typing import TYPE_CHECKING, Dict, Any

from fastapi import APIRouter, Depends
from fastapi import Request

from core.models import Media, MediaRepresentation
from core.services.s3 import S3Service
from core.utils import get_base_url
from dependencies.s3 import get_s3_service
from dependencies.sql_session import get_session
from .schemas import BatchPresignedURLRequest
from .utils import resolve_bucket_for_upload, generate_keys, get_upload_urls

if TYPE_CHECKING:
    from sqlalchemy.ext.asyncio import AsyncSession

router = APIRouter(prefix="/upload_urls", tags=["upload_urls"])


@router.post(
    "/",
    summary="Генерация URL загрузки",
    description="Эндпойнт для генерации предварительно подписанных URL для загрузки файлов.",
    response_description="Успешный ответ с маппингом идентификаторов файлов и их соответствующих URL.",
    responses={
        200: {
            "description": "Успешный ответ, содержащий, например, структуру ответа вида:\n"
                           "{\n  \"media_uuid\": {\"rep_hash\": \"url\"}, ...\n}",
            "content": {
                "application/json": {
                    "example": {
                        "b2f1e9d8-1234-5678-90ab-cdef12345678": {
                            "HASH_VALUE1": "https://example-bucket.s3.region.amazonaws.com/path/to/upload/file1"
                        },
                        "a1c2d3e4-2345-6789-0abc-def123456789": {
                            "HASH_VALUE2": "https://example-bucket.s3.region.amazonaws.com/path/to/upload/file2"
                        }
                    }
                }
            }
        }
    }
)
async def generate_upload_urls(request: "Request", data: BatchPresignedURLRequest,
                               session: "AsyncSession" = Depends(get_session),
                               s3_service: "S3Service" = Depends(get_s3_service)) -> Dict[str, Any]:
    bucket = await resolve_bucket_for_upload(session)

    generated_keys = generate_keys(data.medias)
    base_url = get_base_url(request)
    links = await get_upload_urls(s3_service=s3_service, bucket_name=bucket.name, keys=generated_keys,
                                  files=data.medias)
    for media_item in data.medias:
        representations = [MediaRepresentation(media_id=media_item.uuid, variant=rep.variant,
                                               s3_key=generated_keys[media_item.uuid][rep.hash],
                                               file_size_bytes=rep.file_size_bytes, hash=rep.hash,
                                               hash_type=rep.hash_type, bucket_id=bucket.id)
                           for rep in media_item.representations]
        media_model = Media(id=media_item.uuid, media_type=media_item.media_type,
                            exif_metadata=media_item.exif_metadata)
        media_model.representations = representations
        session.add(media_model)
        for rep in media_item.representations:
            links[rep.hash]["file_url"] = s3_service.get_media_url(base_url, media_item.uuid, rep.variant)
            links[rep.hash]["file_id"] = media_item.uuid
    return links
