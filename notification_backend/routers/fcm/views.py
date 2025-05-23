from typing import TYPE_CHECKING

from fastapi import APIRouter, Depends

from core.services.firebase import get_firebase_service
from .schema import *
from async_firebase.messages import MulticastMessage, Notification, Message

if TYPE_CHECKING:
    from core.services.firebase import FirebaseService
router = APIRouter(prefix="/fcm", tags=["FCM"])


@router.post("/send-to-token/", response_model=SendResponse)
async def send_to_token(
        req: SendToTokenRequest,
        fb: "FirebaseService" = Depends(get_firebase_service)
) -> SendResponse:
    notification = Notification(req.title, req.description, req.image_url)
    msg = Message(token=req.token, notification=notification)
    resp = await fb.send_to_token(
        message=msg,
    )
    return SendResponse(message_id=resp.message_id)


@router.post("/send-multicast/", response_model=MulticastResponse)
async def send_multicast(
        req: SendMulticastRequest,
        fb: "FirebaseService" = Depends(get_firebase_service)
) -> MulticastResponse:
    nt = Notification(req.title, req.description, req.image_url)
    msg = MulticastMessage(tokens=req.tokens, notification=nt)
    batch_response = await fb.send_multicast(message=msg)
    failed_tokens = [req.tokens[i] for i, r in enumerate(batch_response.responses) if not r.success]
    return MulticastResponse(
        success_count=batch_response.success_count,
        failure_count=batch_response.failure_count,
        failed_tokens=failed_tokens or None
    )


@router.post("/subscribe/", response_model=TopicManagementResponseModel)
async def subscribe_to_topic(
        req: TopicSubscriptionRequest,
        fb: "FirebaseService" = Depends(get_firebase_service)
) -> TopicManagementResponseModel:
    resp = await fb.subscribe_tokens_to_topic(
        tokens=req.tokens,
        topic=req.topic
    )
    return TopicManagementResponseModel(
        success_count=resp.success_count,
        failure_count=resp.failure_count,
        errors=[{"token": err.error, "reason": err.reason} for err in resp.errors] if resp.errors else None
    )


@router.post("/unsubscribe/", response_model=TopicManagementResponseModel)
async def unsubscribe_from_topic(
        req: TopicSubscriptionRequest,
        fb: "FirebaseService" = Depends(get_firebase_service)
) -> TopicManagementResponseModel:
    resp = await fb.unsubscribe_tokens_from_topic(
        tokens=req.tokens,
        topic=req.topic
    )
    return TopicManagementResponseModel(
        success_count=resp.success_count,
        failure_count=resp.failure_count,
        errors=[{"token": err.error, "reason": err.reason} for err in resp.errors] if resp.errors else None
    )
