from pathlib import Path
from typing import Dict

from pydantic import BaseModel, computed_field, Field
from pydantic_settings import BaseSettings, SettingsConfigDict
from sqlalchemy import URL

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



class FirebaseSettings(BaseSettings):
    cred_path: str = Field(alias="FIREBASE_CRED_PATH")

    model_config = SettingsConfigDict(env_file="./.env", extra='ignore')


class KafkaSettings(BaseSettings):
    host: str = Field(default='localhost', alias='KAFKA_HOST')
    port: int = Field(default=9090, alias='KAFKA_PORT')

    @property
    def url(self) -> str:
        return f"{self.host}:{self.port}"


class Settings(BaseSettings):
    app_prefix: str = "/api/notifications/"

    postgres: PostgresSettings = PostgresSettings()

    secure_docs: SecureDocs = SecureDocs()

    cors: CORSSettings = CORSSettings()

    kafka: KafkaSettings = KafkaSettings()

    firebase_settings: FirebaseSettings = FirebaseSettings()


settings = Settings()

print(settings)
