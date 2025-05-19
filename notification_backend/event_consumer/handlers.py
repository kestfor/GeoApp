# handlers.py
import logging

from async_firebase.messages import MulticastMessage
from fastapi import Depends
from faststream.kafka.fastapi import KafkaRouter
from sqlalchemy.ext.asyncio.session import AsyncSession

from dependencies.sql_session import get_session
from core.repositories import DeviceTokenRepository
from core.services.firebase import FirebaseService, get_firebase_service
from .messages import FriendResponseMessage, PostCreatedMessage, NewCommentMessage
from .utils import render_post_message, render_comment_message, render_friend_message

router = KafkaRouter("localhost:29092")
logger = logging.getLogger("event_consumer")


@router.subscriber("user.events")
async def handle_friend_response_message(
        msg: FriendResponseMessage,
        firebase_service: FirebaseService = Depends(get_firebase_service),
        session: AsyncSession = Depends(get_session)
):
    # Logging
    action = msg.status.value
    logging.debug(f"[FRIEND RESPONSE] {msg.from_username} → {msg.to_username}: {action}")

    # Fetch device tokens
    user_ids = {msg.from_user_id, msg.to_user_id}
    rep = DeviceTokenRepository(session)
    user_tokens_map = await rep.get_tokens_by_user_ids(user_ids)

    # Send notification to target user
    to_tokens = user_tokens_map.get(msg.to_user_id, [])
    if to_tokens:
        notification = render_friend_message(msg)
        message = MulticastMessage(tokens=to_tokens, notification=notification)
        await firebase_service.send_multicast(message=message)


@router.subscriber("post.events")
async def handle_post_created_message(
        msg: PostCreatedMessage,
        firebase_service: FirebaseService = Depends(get_firebase_service),
        session: AsyncSession = Depends(get_session)
):
    logging.debug(f"[NEW POST] {msg.author_username} in event '{msg.event_name}'")

    # Notify all participants
    rep = DeviceTokenRepository(session)
    user_tokens_map = await rep.get_tokens_by_user_ids(set(msg.participant_ids))
    all_tokens = [t for tokens in user_tokens_map.values() for t in tokens]
    if all_tokens:
        notification = render_post_message(msg)
        message = MulticastMessage(tokens=all_tokens, notification=notification)
        await firebase_service.send_multicast(message=message)


@router.subscriber("comments.events")
async def handle_new_comment_message(
        msg: NewCommentMessage,
        firebase_service: FirebaseService = Depends(get_firebase_service),
        session: AsyncSession = Depends(get_session)
):
    logging.debug(f"[COMMENT] {msg.from_username} commented on '{msg.event_name}': {msg.comment}")

    # Notify all participants
    rep = DeviceTokenRepository(session)
    user_tokens_map = await rep.get_tokens_by_user_ids(set(msg.participant_ids))
    all_tokens = [t for tokens in user_tokens_map.values() for t in tokens]
    if all_tokens:
        notification = render_comment_message(msg)
        message = MulticastMessage(tokens=all_tokens, notification=notification)
        await firebase_service.send_multicast(message=message)
