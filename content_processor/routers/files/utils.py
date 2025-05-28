import logging
from typing import TYPE_CHECKING, List, Optional

from sqlalchemy.orm import selectinload, joinedload
from sqlmodel import select

from core.models import Media, MediaRepresentation

if TYPE_CHECKING:
    from sqlalchemy.ext.asyncio import AsyncSession
    from core.schemas import MediaVariant


async def get_medias(session: "AsyncSession", media_ids: List[str]) -> List[Media]:
    stmt = (
        select(Media)
        .where(Media.id.in_(media_ids))
        .options(selectinload(Media.representations))
    )
    results = await session.scalars(stmt)
    medias = results.all()
    return medias


async def resolve_media_location(session: "AsyncSession", file_id: str, variant: "MediaVariant") -> Optional[
    MediaRepresentation]:
    stmt = select(MediaRepresentation).where(MediaRepresentation.media_id == file_id,
                                             MediaRepresentation.variant == variant.value).options(
        joinedload(MediaRepresentation.bucket))
    return (await session.scalar(stmt))


logger = logging.getLogger(__name__)
