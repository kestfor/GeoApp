import random
from typing import Tuple, List

from async_firebase.messages import Notification

from .messages import (
    FriendResponseMessage,
    FriendshipStatus,
    PostCreatedMessage,
    NewCommentMessage,
)

# Шаблоны уведомлений с юмором
friend_templates: List[Tuple[str, str]] = [
    (
        "Новая заявка в друзья",
        "{from_username} отправил(а) вам запрос в друзья. Готовы к новым приключениям?"
    ),
    (
        "Изменился статус дружбы",
        "{from_username} {action_text} вашу заявку в друзья. Пора устраивать тусовку!"
    ),
    (
        "Дружба на грани",
        "{from_username} {action_text} вас. Надеемся, вы не обиделись!"
    ),
    (
        "Френдзона обновлена",
        "{from_username} {action_text} вашу френдзону. Что дальше?"
    ),
]

post_templates: List[Tuple[str, str]] = [
    (
        "Новый пост: {event_name}",
        "Опубликован(а) новый пост «{event_name}».\n{extra_description}"
    ),
    (
        "Ого, новое событие!",
        "Ваш друг снова в деле: «{event_name}».\n{extra_description}"
    ),
    (
        "ЧЧЕЕЕЕ? 💀💀💀",
        "Только что появился пост про «{event_name}». Не пропустите!\n{extra_description}"
    ),
    (
        "Ваш друг опять вляпался..",
        "На этот раз в «{event_name}».\n{extra_description}"
    ),
]

comment_templates: List[Tuple[str, str]] = [
    (
        "Новый комментарий: {event_name}",
        "{from_username} оставил(а) комментарий к событию «{event_name}»: «{comment}»"
    ),
    (
        "Комментарий от {from_username}",
        "«{comment}» — к событию «{event_name}»"
    ),
    (
        "Ваша новость обсуждают",
        "Пользователь {from_username} прокомментировал(а) «{event_name}»: {comment}"
    ),
    (
        "Звук комментария",
        "Псс! Есть новый комментарий на «{event_name}»: «{comment}»"
    ),
]


def render_friend_message(msg: FriendResponseMessage) -> Notification:
    title_tpl, body_tpl = random.choice(friend_templates)
    action_text_map = {
        FriendshipStatus.friends: "принял(а)",
        FriendshipStatus.request_sent: "отправил(а)",
        FriendshipStatus.request_received: "получил(а)",
        FriendshipStatus.none: "отменил(а)",
    }
    action_text = action_text_map.get(msg.status, "обновил(а)")

    title = title_tpl
    body = body_tpl.format(
        from_username=msg.from_username,
        action_text=action_text,
    )
    return Notification(title=title, body=body, image=None)


def render_post_message(msg: PostCreatedMessage) -> Notification:
    title_tpl, body_tpl = random.choice(post_templates)
    extra_description = msg.event_description.strip() if msg.event_description else ""
    if extra_description:
        extra_description = f"Описание: {extra_description}"

    title = title_tpl.format(
        event_name=msg.event_name,
    )
    body = body_tpl.format(
        event_name=msg.event_name,
        extra_description=extra_description,
    )
    return Notification(title=title, body=body, image=None)


def render_comment_message(msg: NewCommentMessage) -> Notification:
    title_tpl, body_tpl = random.choice(comment_templates)

    title = title_tpl.format(
        event_name=msg.event_name,
        from_username=msg.from_username,
    )
    body = body_tpl.format(
        from_username=msg.from_username,
        event_name=msg.event_name,
        comment=msg.comment.strip(),
    )
    return Notification(title=title, body=body, image=None)
