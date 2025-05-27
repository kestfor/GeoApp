from enum import Enum
from typing import List, Literal, Optional

from pydantic import BaseModel, Field


# 1) запрос в друзья # 2) Ответ на запрос "status" from to uuid
# 3) создание поста (description, author_id, author_username, event_id, event_name, event_descriptionOptional[], participant_ids = list[str])
# 4) новый коммент (from_user_id, from_username, comment, event_name, participant_ids, event_id)


class FriendshipStatus(str, Enum):
    none = "none"
    friends = "friends"
    request_sent = "request_sent"
    request_received = "request_received"

class BaseMessage(BaseModel):
    pass

class FriendResponseMessage(BaseMessage):
    """
    Сообщение-ответ на запрос в друзья.
    """
    from_user_id: str = Field(..., description="UUID инициатора запроса")
    to_user_id: str = Field(..., description="UUID пользователя, дающего ответ")
    from_username: str = Field(..., description="Username инициатора запроса")
    to_username: str = Field(..., description="Username пользователя, дающего ответ")
    status: FriendshipStatus = Field(
        ..., description="Статус ответа на запрос в друзья"
    )


class PostCreatedMessage(BaseMessage):
    """
    Сообщение о создании нового поста для события.
    """
    author_id: str = Field(..., description="UUID автора поста")
    author_username: str = Field(..., description="Username автора")
    event_id: str = Field(..., description="UUID события")
    event_name: str = Field(..., description="Название события")
    event_description: Optional[str] = Field(
        None, description="Описание события (опционально)"
    )
    participant_ids: List[str] = Field(
        ..., description="Список UUID участников события"
    )


class NewCommentMessage(BaseMessage):
    """
    Сообщение о новом комментарии к событию.
    """
    from_user_id: str = Field(..., description="UUID автора комментария")
    from_username: str = Field(..., description="Имя пользователя автора")
    comment: str = Field(..., description="Текст комментария")
    event_id: str = Field(..., description="UUID события")
    event_name: str = Field(..., description="Название события")
    participant_ids: List[str] = Field(
        ..., description="Список UUID участников события"
    )
