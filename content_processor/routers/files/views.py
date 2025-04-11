import logging
from typing import TYPE_CHECKING, List

from fastapi import APIRouter, Depends, Request, HTTPException
from fastapi.responses import RedirectResponse
from starlette.responses import HTMLResponse

from core.schemas import MediaVariant, MediaType
from core.utils import get_base_url
from dependencies.s3 import get_s3_service
from dependencies.sql_session import get_session
from .schemas import PhotoInfo, RepresentationInfo, VideoInfo
from .utils import get_medias, resolve_media_location

if TYPE_CHECKING:
    from core.models import MediaRepresentation
    from sqlalchemy.ext.asyncio import AsyncSession

router = APIRouter(prefix="/files", tags=["files"])

logger = logging.getLogger(__name__)


@router.get(
    "/{file_id}/{size}",
    responses={
        200: {
            "description": "HTML preview of image (если preview=true)",
            "content": {
                "text/html": {
                    "example": """
                    <html>
                        <body>
                            <h3>Here is your image:</h3>
                            <img src="https://example.com/image.jpg" alt="Image" />
                        </body>
                    </html>
                    """
                }
            },
        },
        302: {
            "description": "Редирект на URL изображения",
            "headers": {
                "location": {
                    "description": "URL изображения",
                    "schema": {"type": "string", "format": "uri"}
                }
            },
        },
    },
    response_class=HTMLResponse  # это важно для Swagger UI!
)
async def get_media(
        file_id: str,
        size: MediaVariant = MediaVariant.ORIGINAL,
        preview: bool = False,
        s3_service: "S3Service" = Depends(get_s3_service),
        session: "AsyncSession" = Depends(get_session),
):
    media_rep: "MediaRepresentation" = await resolve_media_location(session, file_id, size)
    if media_rep is None:
        logger.warning(f"No media found for {file_id}")
        raise HTTPException(status_code=404, detail="Media not found")
    redirect_url = await s3_service.generate_download_presigned_url(media_rep.bucket.name, media_rep.s3_key)
    if preview:
        return HTMLResponse(content=f"""
            <html>
                <body>
                    <h3>Here is your file:</h3>
                    <img src="{redirect_url}" alt="Image" />
                </body>
            </html>
            """, status_code=200)
    logger.info("Redirect to %s", redirect_url)
    return RedirectResponse(url=redirect_url, status_code=302, headers={"Location": redirect_url})


@router.post("/info")
async def photo_info(request: "Request", media_ids: List[str],
                     session: "AsyncSession" = Depends(get_session),
                     s3_service: "S3Service" = Depends(get_s3_service)) -> List[PhotoInfo | VideoInfo]:
    media_models = await get_medias(session, media_ids)
    result = []
    base_url = get_base_url(request)
    get_media_url = s3_service.get_media_url
    for model in media_models:
        if model.media_type == MediaType.PHOTO.value:
            media = PhotoInfo(type=model.media_type, media_id=model.id,
                              representations={
                                  rep.variant: RepresentationInfo(variant=rep.variant,
                                                                  url=get_media_url(base_url, model.id,
                                                                                    rep.variant),
                                                                  file_size_bytes=rep.file_size_bytes,
                                                                  )
                                  for rep in
                                  model.representations})
        else:
            media = VideoInfo(type=model.media_type, media_id=model.id,
                              url=get_media_url(base_url, model.id, MediaVariant.ORIGINAL),
                              thumbnail=get_media_url(base_url, model.id, MediaVariant.THUMBNAIL),
                              metadata=model.exif_metadata)
        result.append(media)
    return result
