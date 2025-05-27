import random
import pytest
from async_firebase.messages import Notification

from event_consumer.messages import (
    FriendResponseMessage,
    FriendshipStatus,
    PostCreatedMessage,
    NewCommentMessage,
)
from event_consumer.utils import (
    render_friend_message,
    render_post_message,
    render_comment_message,
)


# --- FIXTURES ---

@pytest.fixture(autouse=True)
def fix_random_choice(monkeypatch):
    """ Подменяет random.choice, чтобы выбор шаблона был детерминирован. """
    monkeypatch.setattr(random, "choice", lambda lst: lst[0])


@pytest.fixture
def friend_msg():
    return FriendResponseMessage(
        from_username="Alice",
        status=FriendshipStatus.friends,
        from_user_id="1",
        to_user_id="2",
        to_username="Bob"
    )


@pytest.fixture
def post_msg():
    return PostCreatedMessage(
        author_username="Bob",
        event_name="Концерт",
        event_description="Описание",
        author_id="1",
        event_id="42",
        participant_ids=["1", "2"]
    )


@pytest.fixture
def comment_msg():
    return NewCommentMessage(
        from_username="Dave",
        event_name="Митап",
        comment="Отлично прошло!",
        from_user_id="1",
        event_id="99",
        participant_ids=["1", "2"]
    )


# --- TESTS ---

def test_render_friend_message_type(friend_msg):
    notif = render_friend_message(friend_msg)
    assert isinstance(notif, Notification)


def test_render_post_message_type(post_msg):
    notif = render_post_message(post_msg)
    assert isinstance(notif, Notification)


def test_render_comment_message_type(comment_msg):
    notif = render_comment_message(comment_msg)
    assert isinstance(notif, Notification)
