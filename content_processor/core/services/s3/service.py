# core/services/s3.py
import datetime
from contextlib import asynccontextmanager
from enum import Enum
from typing import Generator, Optional, Union

import aioboto3
from aiobotocore.client import AioBaseClient

from core.config import settings
from core.schemas import HashType, MediaVariant


class S3Service:
    _instance: Optional["S3Service"] = None
    _session: Optional[aioboto3.Session] = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(S3Service, cls).__new__(cls)
            cls._initialize_session()
        return cls._instance

    @classmethod
    def _initialize_session(cls):
        if cls._session is None:
            cls._session = aioboto3.Session()

    @classmethod
    def _get_client_params(cls):
        return {
            "endpoint_url": settings.s3_settings.ENDPOINT_URL,
            "aws_access_key_id": settings.s3_settings.ACCESS_KEY,
            "aws_secret_access_key": settings.s3_settings.ACCESS_SECRET,
        }

    @classmethod
    @asynccontextmanager
    async def get_client(cls) -> Generator[AioBaseClient, None, None]:
        async with cls._session.client("s3", **cls._get_client_params()) as client:
            yield client

    @classmethod
    async def generate_download_presigned_url(
            cls,
            bucket_name: str,
            object_name: str,
            expiration: Union[int, datetime.timedelta] = settings.s3_settings.TTL_SEC,
            extra_params: Optional[dict] = None,
    ) -> str:
        """
        Генерирует предварительно подписанный URL для доступа к объекту
        :param bucket_name: Название бакета S3
        :param object_name: Ключ объекта в бакете
        :param expiration: Время жизни ссылки в секундах (по умолчанию 1 час)
        :return: Строка с подписанным URL
        """
        if isinstance(expiration, datetime.timedelta):
            expiration = expiration.total_seconds()
        if extra_params is None:
            extra_params = {}
        async with cls.get_client() as client:
            return await client.generate_presigned_url(
                ClientMethod="get_object",
                Params={
                    'Bucket': bucket_name,
                    'Key': object_name,
                    **extra_params,
                },
                HttpMethod="GET",
                ExpiresIn=expiration
            )

    @classmethod
    async def generate_upload_presigned_url(
            cls,
            bucket_name: str,
            object_key: str,
            expiration: Union[int, datetime.timedelta] = settings.s3_settings.TTL_SEC,
            max_file_size_bytes: Optional[int] = None,
            checksum_algorithm: Optional["HashType"] = None,
            checksum_value: Optional[str] = None,
            extra_fields: Optional[dict] = None,
            extra_conditions: Optional[list] = None,
    ) -> dict:
        """
        Генерирует предварительно подписанные данные для загрузки файла с проверкой контрольной суммы
        и ограничением по размеру (если это возможно).

        Используется механизм presigned POST, который позволяет указать условия загрузки.

        :param bucket_name: Название бакета S3
        :param object_key: Ключ объекта, который будет создан в бакете
        :param expiration: Время жизни ссылки (секунды или datetime.timedelta, по умолчанию значение из настроек)
        :param max_file_size_bytes: Опционально, максимальный размер файла в байтах.
        :param checksum_algorithm: Опционально, алгоритм контрольной суммы (например, "SHA256" или "SHA512").
                                   Это значение будет передано в поле x-amz-checksum-algorithm.
        :param checksum_value: Значение контрольной суммы, которое будет проверяться.
        :param extra_fields: Дополнительные поля, которые будут включены в форму загрузки.
        :param extra_conditions: Дополнительные условия для политики загрузки (список).
        :return: Словарь с ключами 'url' и 'fields', который используется для загрузки файла.
        """
        # Проверка: если передан один из параметров checksum, то должен быть передан и второй.
        if (checksum_algorithm is None) != (checksum_value is None):
            raise ValueError(
                "Параметры checksum_algorithm и checksum_value должны передаваться вместе либо оба, либо ни одного."
            )

        # Если expiration передан как timedelta – переводим его в секунды.
        if isinstance(expiration, datetime.timedelta):
            expiration = expiration.total_seconds()

        if extra_fields is None:
            extra_fields = {}

        # Устанавливаем обязательное поле key (если не задано извне)
        extra_fields.setdefault("key", object_key)

        # Формируем список условий для политики загрузки. Всегда указываем ключ объекта.
        conditions = [{"key": object_key}]

        # Если заданы параметры контрольной суммы, задаем необходимые поля и условия.
        if checksum_algorithm and checksum_value:
            algo_lower = checksum_algorithm.lower()
            checksum_field = f"x-amz-checksum-{algo_lower}"
            extra_fields.setdefault(checksum_field, checksum_value)
            extra_fields.setdefault("x-amz-checksum-algorithm", algo_lower)

            # Добавляем условие для алгоритма контрольной суммы
            conditions.append({"x-amz-checksum-algorithm": algo_lower})
            # Добавляем условие для контрольной суммы (позволяем любое значение, начинающееся с пустой строки)
            conditions.append(["starts-with", f"${checksum_field}", ""])

        if max_file_size_bytes is not None:
            # Ограничение по размеру файла: от 1 байта до max_file_size байт
            conditions.append(["content-length-range", 1, max_file_size_bytes])
        if extra_conditions:
            conditions.extend(extra_conditions)

        async with cls.get_client() as client:
            response = await client.generate_presigned_post(
                Bucket=bucket_name,
                Key=object_key,
                Fields=extra_fields,
                Conditions=conditions,
                ExpiresIn=int(expiration)
            )
        return response

    @classmethod
    async def close(cls):
        if cls._session:
            await cls._session.close()
        cls._instance = None
        cls._session = None

    @staticmethod
    def get_media_url(base_url: str, file_id: str, variant: Union["MediaVariant", str]) -> str:
        if isinstance(variant, Enum):
            variant = variant.value
        res = f"{base_url}{settings.app_prefix}/files/s3/{file_id}/{variant}"
        return res
