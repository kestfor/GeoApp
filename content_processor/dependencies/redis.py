from redis.asyncio import Redis

from core.config import settings

_redis_client: Redis | None = None


async def get_redis():
    global _redis_client
    if _redis_client is None:
        _redis_client = Redis(**{
            'host': settings.redis.HOST,
            'port': settings.redis.PORT,
            'password': settings.redis.PASSWORD,
            'db': settings.redis.DB,
            'decode_responses': True
        })
    return _redis_client
