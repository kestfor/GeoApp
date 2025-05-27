# Utility: Russian templates
import random
from typing import Tuple, List

from async_firebase.messages import Notification

from .messages import FriendResponseMessage, FriendshipStatus, PostCreatedMessage, NewCommentMessage

friend_templates: List[Tuple[str, str]] = [
    ("Заявка в друзья", "Пользователь {from_username} {action_text} вам в друзья."),
    ("Обновление статуса дружбы", "{from_username} теперь {action_text} с вами.")
]

post_templates: List[Tuple[str, str]] = [
    ("Новый пост на событии {event_name}",
     "{author_username} добавил новый пост к событию '{event_name}'. Описание: {event_description}"),
    ("Пост от {author_username}",
     "Событие: {event_name}. {author_username} поделился новым постом!")
]

comment_templates: List[Tuple[str, str]] = [
    ("Новый комментарий на событии {event_name}",
     "{from_username} прокомментировал событие '{event_name}': {comment}"),
    ("Комментарий от {from_username}",
     "Событие '{event_name}': {comment}")
]


def render_friend_message(msg: FriendResponseMessage) -> Notification:
    title_tpl, body_tpl = random.choice(friend_templates)
    action_text = {
        FriendshipStatus.friends: "принял(а)",
        FriendshipStatus.request_sent: "отправил(а)",
        FriendshipStatus.request_received: "получил(а)",
        FriendshipStatus.none: "отменил(а)"
    }[msg.status]
    title = title_tpl
    body = body_tpl.format(
        from_username=msg.from_username,
        action_text=action_text
    )
    return Notification(title=title, body=body, image=None)


def render_post_message(msg: PostCreatedMessage) -> Notification:
    title_tpl, body_tpl = random.choice(post_templates)
    title = title_tpl.format(event_name=msg.event_name, author_username=msg.author_username)
    body = body_tpl.format(
        author_username=msg.author_username,
        event_name=msg.event_name,
        event_description=msg.event_description or ""
    )
    return Notification(title=title, body=body, image=None)


def render_comment_message(msg: NewCommentMessage) -> Notification:
    title_tpl, body_tpl = random.choice(comment_templates)
    title = title_tpl.format(event_name=msg.event_name, from_username=msg.from_username)
    body = body_tpl.format(
        from_username=msg.from_username,
        event_name=msg.event_name,
        comment=msg.comment
    )
    return Notification(title=title, body=body, image=None)
