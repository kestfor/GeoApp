from pathlib import Path
from typing import Dict

from pydantic import BaseModel, computed_field, Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict
from sqlalchemy import URL

from core.utils import parse_file_size

BASE_DIR = Path(__file__).parent.parent


class PostgresSettings(BaseSettings):
    host: str = Field(default='localhost', alias='PG_HOST')
    port: int = Field(default=5432, alias='PG_PORT')
    user: str = Field(default='postgres', alias='PG_USER')
    password: str = Field(default='postgres', alias='PG_PASSWORD')
    database: str = Field(default='content_processor', alias='PG_DATABASE')
    echo: bool = Field(default=True, alias='PG_ECHO')
    model_config = SettingsConfigDict(env_file="./.env", extra='ignore')

    @computed_field
    @property
    def url_kwargs(self) -> Dict:
        return dict(host=self.host, port=self.port,
                    username=self.user,
                    password=self.password, database=self.database)

    @computed_field
    @property
    def url_async(self) -> str:
        return URL.create(drivername='postgresql+asyncpg', **self.url_kwargs).render_as_string(
            hide_password=False)

    @computed_field
    @property
    def url_sync(self) -> str:
        return URL.create(drivername="postgresql", **self.url_kwargs).render_as_string(
            hide_password=False)


class RedisSettings(BaseSettings):
    HOST: str = Field(default='localhost', alias="REDIS_HOST")
    PORT: int = Field(default=6379, alias="REDIS_PORT")
    PASSWORD: str = Field(default='password', alias="REDIS_PASSWORD")
    DB: int = Field(default=0, alias="REDIS_DB")

    model_config = SettingsConfigDict(env_file="./.env", extra='ignore')


class S3Settings(BaseSettings):
    BUCKET: str = Field(default='bucket-name', alias='S3_BUCKET')
    ENDPOINT_URL: str = Field(default='https://storage.yandexcloud.net', alias='S3_ENDPOINT_URL')
    ACCESS_KEY: str = Field(default='ACCESS_KEY', alias='S3_ACCESS_KEY')
    ACCESS_SECRET: str = Field(default='ACCESS_SECRET', alias='S3_SECRET_KEY')
    TTL_SEC: int = Field(default=3600, alias='S3_TTL_SEC')

    MAX_SIZE_VIDEO_BYTES: int = Field(default=1048576, alias='S3_MAX_SIZE_VIDEO')
    MAX_SIZE_PHOTO_BYTES: int = Field(default=1048576, alias='S3_MAX_SIZE_PHOTO')

    model_config = SettingsConfigDict(env_file="./.env", extra='ignore')

    @field_validator('MAX_SIZE_VIDEO_BYTES', 'MAX_SIZE_PHOTO_BYTES', mode='before')
    @classmethod
    def parse_size_string(cls, v):
        if isinstance(v, str):
            return parse_file_size(v)
        return v


class SecureDocs(BaseSettings):
    USERNAME: str = Field(default="admin", alias='SECURE_DOCS_USERNAME')
    PASSWORD: str = Field(default="admin", alias='SECURE_DOCS_PASSWORD')
    IS_ENABLED: bool = Field(default=True, alias='SECURE_DOCS_ENABLED')

    model_config = SettingsConfigDict(env_file="./.env", extra='ignore')


class CORSSettings(BaseModel):
    allow_origins: list[str] = ["*"]
    allow_credentials: bool = True
    allow_methods: list[str] = ["*"]
    allow_headers: list[str] = ["*"]


class Settings(BaseSettings):
    app_prefix: str = "/api/content_processor"

    postgres: PostgresSettings = PostgresSettings()

    redis: RedisSettings = RedisSettings()

    secure_docs: SecureDocs = SecureDocs()

    s3_settings: S3Settings = S3Settings()

    cors: CORSSettings = CORSSettings()


settings = Settings()

print(settings)
