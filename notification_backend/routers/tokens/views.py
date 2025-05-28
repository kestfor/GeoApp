from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status, Request, Response
from sqlalchemy.ext.asyncio.session import AsyncSession

from core.repositories import DeviceTokenRepository
from core.utils import get_user_id
from dependencies.sql_session import get_session
from .schema import DeviceTokenCreate, DeviceTokenDelete

router = APIRouter(prefix="/tokens", tags=["tokens"])


@router.post("")
async def register_token(
        request: Request,
        payload: DeviceTokenCreate,
        session: AsyncSession = Depends(get_session),
):
    user_id = get_user_id(request)
    if not user_id:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)
    repository = DeviceTokenRepository(session)
    token = await repository.upsert(user_id=UUID(user_id), token=payload.token, platform=payload.platform,
                                    is_active=True)
    return token


@router.delete("")
async def register_token(
        request: Request,
        payload: DeviceTokenDelete,
        session: AsyncSession = Depends(get_session),
):
    repository = DeviceTokenRepository(session)
    token = await repository.get_by_token(payload.token)
    if not token:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    user_id = get_user_id(request)
    if not user_id:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)
    if token.user_id == user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN)
    await repository.delete(token.id)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
