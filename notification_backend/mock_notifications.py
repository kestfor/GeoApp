#!/usr/bin/env python3
# filename: produce_mock_events_async.py

import asyncio
import json
import random
import uuid
from datetime import datetime

from aiokafka import AIOKafkaProducer
from faker import Faker

from event_consumer.messages import *

fake = Faker()

uid = "5f26919f-ae5c-4f78-90e7-9ce0c7cca9bf"
def make_friend_response() -> FriendResponseMessage:
    u1, u2 = uid, uid
    return FriendResponseMessage(
        from_user_id=u1,
        to_user_id=u2,
        from_username=fake.user_name(),
        to_username=fake.user_name(),
        status=random.choice(list(FriendshipStatus))
    )


def make_post_created() -> PostCreatedMessage:
    event_id = str(uuid.uuid4())
    participants = [uid for _ in range(random.randint(1, 5))]
    return PostCreatedMessage(
        author_id=uid,
        author_username=fake.user_name(),
        event_id=event_id,
        event_name=fake.sentence(nb_words=3),
        event_description=fake.text(max_nb_chars=100),
        participant_ids=participants
    )


def make_new_comment() -> NewCommentMessage:
    event_id = str(uuid.uuid4())
    participants = [uid for _ in range(random.randint(1, 5))]
    return NewCommentMessage(
        from_user_id=uid,
        from_username=fake.user_name(),
        comment=fake.sentence(nb_words=10),
        event_id=event_id,
        event_name=fake.sentence(nb_words=3),
        participant_ids=participants
    )


# === 3) Мэппинг типов → топики ===

TOPIC_MAP = {
    FriendResponseMessage: 'user.events',
    PostCreatedMessage: 'post.events',
    NewCommentMessage: 'comments.events',
}


# === 4) Асинхронный продьюсер ===

async def produce():
    producer = AIOKafkaProducer(
        bootstrap_servers="localhost:29092",
        value_serializer=lambda v: json.dumps(v, default=str).encode('utf-8')
    )
    # Стартуем
    await producer.start()
    try:
        while True:
            # Выбираем тип события
            choice = random.choice(list(TOPIC_MAP.keys()))
            if choice is FriendResponseMessage:
                msg = make_friend_response()
            elif choice is PostCreatedMessage:
                msg = make_post_created()
            else:  # "new_comment"
                msg = make_new_comment()

            topic = TOPIC_MAP[choice]
            # Отправляем
            await producer.send_and_wait(topic, msg.dict())
            print(f"[{datetime.utcnow().isoformat()}] Sent {choice} → {topic}")
            # Пауза
            await asyncio.sleep(random.uniform(10, 20))
    finally:
        await producer.stop()


if __name__ == "__main__":
    try:
        asyncio.run(produce())
    except KeyboardInterrupt:
        print("Shutdown requested, exiting...")
