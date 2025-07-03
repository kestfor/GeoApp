import random
from typing import Tuple, List

from async_firebase.messages import Notification

from event_consumer.messages import (
    FriendResponseMessage,
    FriendshipStatus,
    PostCreatedMessage,
    NewCommentMessage,
)

# Шаблоны с юмором
friend_templates_by_status = {
    FriendshipStatus.request_sent: [
        ("Запрос отправлен 📨", "Ты кинул(а) заявку {to_username}. Теперь ждём, как манны небесной.")
    ],
    FriendshipStatus.request_received: [
        ("Кто-то хочет дружить 👀", "{from_username} жмёт лапу и зовёт в друзья. Решайся!")
    ],
    FriendshipStatus.friends: [
        ("Ура, вы друзья 🎉", "{from_username} принял(а) твою заявку. Теперь вы в одной команде!")
    ],
    FriendshipStatus.none: [
        ("Френдзона активирована 🚫", "{from_username} отменил(а) запрос. Видимо, не судьба :(")
    ],
}

post_templates: List[Tuple[str, str]] = [
    (
        "Пост на подходе 🚀: {event_name}",
        "Свежий пост о «{event_name}».\n{extra_description}"
    ),
    (
        "Новая движуха ⚡️",
        "Событие «{event_name}» засветилось в ленте!\n{extra_description}"
    ),
    (
        "🔥 Горяченькое подоспело!",
        "Пост о событии «{event_name}» уже тут. Кликаешь — кайфуешь.\n{extra_description}"
    ),
]

comment_templates: List[Tuple[str, str]] = [
    (
        "Комментарий к {event_name} 💬",
        "{from_username} оставил(а) мнение: «{comment}». Глянь, пока не удалили."
    ),
    (
        "{from_username} снова в эфире 🎙️",
        "На событии «{event_name}» кто-то высказывается: «{comment}»"
    ),
    (
        "Ого, коммент! 😮",
        "{from_username} подкинул(а) мысль: «{comment}». Чекни!"
    ),
]


def render_friend_message(msg: FriendResponseMessage) -> Notification:
    templates = friend_templates_by_status.get(msg.status)
    if not templates:
        templates = [("Оповещение", "Неизвестный статус дружбы...")]
    title_tpl, body_tpl = random.choice(templates)
    subs = {"from_username": msg.from_username, "to_username": msg.to_username}
    return Notification(
        title=title_tpl.format(**subs),
        body=body_tpl.format(**subs),
        image=None,
    )


def render_post_message(msg: PostCreatedMessage) -> Notification:
    title_tpl, body_tpl = random.choice(post_templates)
    extra = msg.event_description.strip() if msg.event_description else ""
    extra_desc = f"Описание: {extra}" if extra else "Пока без подробностей 🤷‍♂️"
    return Notification(
        title=title_tpl.format(event_name=msg.event_name),
        body=body_tpl.format(event_name=msg.event_name, extra_description=extra_desc),
        image=None,
    )


def render_comment_message(msg: NewCommentMessage) -> Notification:
    title_tpl, body_tpl = random.choice(comment_templates)
    subs = {"from_username": msg.from_username, "event_name": msg.event_name, "comment": msg.comment.strip()}
    return Notification(
        title=title_tpl.format(**subs),
        body=body_tpl.format(**subs),
        image=None,
    )


# ----------------------
# Скрипт для демонстрации вариаций рендеров
if __name__ == "__main__":
    print("=== Friend Messages ===")
    for status in [
        FriendshipStatus.request_sent,
        FriendshipStatus.request_received,
        FriendshipStatus.friends,
        FriendshipStatus.none,
    ]:
        msg = FriendResponseMessage(
            from_user_id="u1", to_user_id="u2",
            from_username="Alice", to_username="Bob",
            status=status,
        )
        notif = render_friend_message(msg)
        print(f"Status: {status}")
        print(f"Title: {notif.title}")
        print(f"Body: {notif.body}\n---")

    print("=== Post Messages ===")
    for desc in [None, "Вечеринка в пятницу"]:
        msg = PostCreatedMessage(
            author_id="u1", author_username="Charlie",
            event_id="e1", event_name="CodeFest",
            event_description=desc,
            participant_ids=["u2", "u3"],
        )
        notif = render_post_message(msg)
        print(f"Description: {desc}")
        print(f"Title: {notif.title}")
        print(f"Body: {notif.body}\n---")

    print("=== Comment Messages ===")
    for comment in ["Круто!", "Нужно добавить больше деталей"]:
        msg = NewCommentMessage(
            from_user_id="u3", from_username="Dave",
            comment=comment, event_id="e1",
            event_name="CodeFest", participant_ids=["u1", "u2"],
        )
        notif = render_comment_message(msg)
        print(f"Comment: {comment}")
        print(f"Title: {notif.title}")
        print(f"Body: {notif.body}\n---")