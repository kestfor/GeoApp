import asyncio
from collections import defaultdict
from typing import TYPE_CHECKING, List, Dict

from sqlmodel import select

from core.models import StorageBucket

if TYPE_CHECKING:
    from sqlalchemy.ext.asyncio import AsyncSession
    from routers.upload_urls.schemas import MediaFull
    from core.services.s3 import S3Service


async def resolve_bucket_for_upload(session: "AsyncSession") -> "StorageBucket":
    stmt = select(StorageBucket).where(StorageBucket.storage_class == "STANDARD")
    result = (await session.scalar(stmt))
    return result


def generate_keys(files: List["MediaFull"]) -> Dict[str, Dict[str, str]]:
    keys = defaultdict(dict)
    for file in files:
        for rep in file.representations:
            keys[file.uuid][
                rep.hash] = f"{file.media_type.value}/{file.uuid}/{rep.variant.value}.{rep.mime_type.get_extension()}"
    return keys


async def get_upload_urls(s3_service: "S3Service", bucket_name: str, files: List["MediaFull"],
                          keys: Dict[str, Dict[str, str]]) -> Dict[str, Dict[str, str] | str]:
    tasks = []
    mapping = []  # Будет содержать кортежи вида (file_uuid, rep_hash)

    # Формируем задачи и сопоставляем их с нужными метаданными
    for file in files:
        file_uuid = file.uuid
        for rep in file.representations:
            object_key = keys[file_uuid][rep.hash]
            mapping.append(rep.hash)
            task = s3_service.generate_upload_presigned_url(
                bucket_name=bucket_name,
                object_key=object_key,
                max_file_size_bytes=rep.file_size_bytes,
                checksum_algorithm=rep.hash_type,
                checksum_value=rep.hash,
            )
            tasks.append(task)

    # Запуск всех задач параллельно
    results = await asyncio.gather(*tasks)

    # Собираем результаты в итоговый словарь
    upload_urls = {}
    for rep_hash, resp in zip(mapping, results):
        # Из полученного ответа берём нужный URL. Здесь предполагается, что в ответе есть ключ 'url'
        upload_urls[rep_hash] = resp

    return upload_urls
