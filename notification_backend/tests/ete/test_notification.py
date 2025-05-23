import pytest
import json
from uuid import uuid4
from aiokafka import AIOKafkaProducer, AIOKafkaConsumer
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlmodel import select
from core.models import NotificationLog
import asyncio

@pytest.fixture(scope="module")
def event_loop():
    loop = asyncio.get_event_loop()
    yield loop
    loop.close()

@pytest.mark.asyncio
async def test_full_notification_flow():
    # 1. Generate test event
    test_event = {
        "type": "friend_response",
        "from_user_id": str(uuid4()),
        "to_user_id": str(uuid4()),
        "status": "accepted"
    }

    # 2. Send to Kafka
    producer = AIOKafkaProducer(
        bootstrap_servers="localhost:29092",
        value_serializer=lambda v: json.dumps(v).encode('utf-8')
    )
    await producer.start()
    await producer.send("user.events", value=test_event)
    await producer.stop()

    # 3. Wait for processing
    consumer = AIOKafkaConsumer(
        "notification.logs",
        bootstrap_servers="localhost:29092",
        auto_offset_reset="earliest",
        enable_auto_commit=False
    )
    await consumer.start()
    
    try:
        msg = await consumer.getone()
        notification = json.loads(msg.value)
        
        # 4. Verify database
        engine = create_async_engine("postgresql+asyncpg://user:pass@localhost:5435/db")
        async with AsyncSession(engine) as session:
            result = await session.execute(
                select(NotificationLog).where(
                    NotificationLog.event_id == test_event["from_user_id"]
                )
            )
            log_entry = result.scalar_one()
            
            assert log_entry.status == "delivered"
            assert notification["recipient_id"] == test_event["to_user_id"]
    finally:
        await consumer.stop()
