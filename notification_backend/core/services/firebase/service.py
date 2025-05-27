import asyncio
import logging
from functools import lru_cache
from typing import List, Optional

from async_firebase import AsyncFirebaseClient
from async_firebase.messages import (
    TopicManagementResponse,
    MulticastMessage,
    FCMBatchResponse,
    FCMResponse,
    Message, Notification,
)

from core.config import settings

# Configure root logger (this can be customized in application entrypoint)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)

logger = logging.getLogger(__name__)

class FirebaseService:
    def __init__(self):
        self.cred_path = settings.firebase_settings.cred_path
        self._client: Optional[AsyncFirebaseClient] = None
        self._lock = asyncio.Lock()
        logger.debug("FirebaseService initialized with cred_path=%s", self.cred_path)

    async def _init_client(self) -> AsyncFirebaseClient:
        """
        Lazily initialize the AsyncFirebaseClient singleton under a lock.
        """
        logger.debug("Attempting to initialize Firebase client...")
        async with self._lock:
            if not self._client:
                logger.info("Creating new AsyncFirebaseClient instance")
                client = AsyncFirebaseClient()
                logger.debug("Loading credentials from %s", self.cred_path)
                client.creds_from_service_account_file(self.cred_path)
                self._client = client
                logger.info("Firebase client successfully initialized")
            else:
                logger.debug("Firebase client already initialized, reusing instance")
        return self._client

    # --- Async FCM: sending messages ---

    async def send_to_token(
        self,
        message: Message,
    ) -> FCMResponse:
        """
        Asynchronously send a notification to a single device token.
        """
        logger.debug("Preparing to send message to token: %s", getattr(message, 'token', '<unknown>'))
        client = await self._init_client()
        response = await client.send(message=message)
        logger.info("Message sent to token %s, response: %s", getattr(message, 'token', '<unknown>'), response)
        return response

    async def send_multicast(
        self,
        message: MulticastMessage,
    ) -> FCMBatchResponse:
        """
        Asynchronously send one message to multiple device tokens.
        """
        logger.debug("Preparing to send multicast message to tokens: %s", message.tokens)
        client = await self._init_client()
        batch_response = await client.send_each_for_multicast(multicast_message=message)
        logger.info(
            "Multicast message sent to %d tokens: successes=%d, failures=%d",
            len(message.tokens),
            batch_response.success_count,
            batch_response.failure_count,
        )
        return batch_response

    async def subscribe_tokens_to_topic(
        self,
        tokens: List[str],
        topic: str,
    ) -> TopicManagementResponse:
        """
        Asynchronously subscribe a list of registration tokens to a topic.
        """
        logger.debug("Subscribing tokens to topic '%s': %s", topic, tokens)
        client = await self._init_client()
        result = await client.subscribe_devices_to_topic(device_tokens=tokens, topic_name=topic)
        logger.info(
            "Subscribed %d tokens to topic '%s': success=%d, failures=%d",
            len(tokens), topic, result.success_count, result.failure_count,
        )
        return result

    async def unsubscribe_tokens_from_topic(
        self,
        tokens: List[str],
        topic: str,
    ) -> TopicManagementResponse:
        """
        Asynchronously unsubscribe a list of registration tokens from a topic.
        """
        logger.debug("Unsubscribing tokens from topic '%s': %s", topic, tokens)
        client = await self._init_client()
        result = await client.unsubscribe_devices_from_topic(device_tokens=tokens, topic_name=topic)
        logger.info(
            "Unsubscribed %d tokens from topic '%s': success=%d, failures=%d",
            len(tokens), topic, result.success_count, result.failure_count,
        )
        return result


@lru_cache()
def get_firebase_service() -> FirebaseService:
    """Get a cached singleton of FirebaseService."""
    logger.debug("Retrieving cached FirebaseService instance")
    return FirebaseService()


async def main():
    token = 'ciHopw10RmepEnlVGw1l0r:APA91bGFI04c6HBh1FAZe-gWEunZhuzHs4VaG43sMBXtTktyvVQlOZXgAMVetwwG6n0M2uLJ4aDDi5pAtQElmTggi2IizX5yrU_pay5_Xt0Q_NkI3a5adyo'
    service = get_firebase_service()
    notification = Notification(title="йоу", body="2")
    msg = Message(token=token, notification=notification)
    await service.send_to_token(message=msg)

if __name__ == "__main__":
    asyncio.run(main())
