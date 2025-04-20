# core/exceptions.py

class ApplicationError(Exception):
    """
    Базовый класс для всех ошибок приложения.
    Можно использовать для группировки и отлавливания всех внутренних исключений.
    """
    pass


# --- Исключения для работы с S3 ---
class S3Error(ApplicationError):
    """Базовая ошибка для операций с S3."""
    pass


class S3ConnectionError(S3Error):
    """Ошибка подключения к S3."""

    def __init__(self, message: str = "Не удалось установить соединение с S3"):
        super().__init__(message)


class S3BucketNotFoundError(S3Error):
    """Ошибка, если заданный бакет не найден."""

    def __init__(self, bucket: str, message: str = None):
        if message is None:
            message = f"Бакет '{bucket}' не найден в S3."
        super().__init__(message)
        self.bucket = bucket


class S3UploadError(S3Error):
    """Ошибка при загрузке объекта в S3."""

    def __init__(self, key: str, message: str = None):
        if message is None:
            message = f"Ошибка при загрузке объекта с ключом '{key}' в S3."
        super().__init__(message)
        self.key = key


# --- Исключения для работы с Redis ---
class RedisError(ApplicationError):
    """Базовая ошибка для операций с Redis."""
    pass


class RedisConnectionError(RedisError):
    """Ошибка подключения к Redis."""

    def __init__(self, message: str = "Не удалось установить соединение с Redis"):
        super().__init__(message)


class RedisCacheError(RedisError):
    """Ошибка взаимодействия с кэшем Redis."""

    def __init__(self, message: str = "Ошибка работы с Redis кэшем"):
        super().__init__(message)


# --- Исключения для работы с Postgres ---
class PostgresError(ApplicationError):
    """Базовая ошибка для операций с Postgres."""
    pass


class PostgresConnectionError(PostgresError):
    """Ошибка подключения к Postgres."""

    def __init__(self, message: str = "Ошибка подключения к базе Postgres"):
        super().__init__(message)


class PostgresQueryError(PostgresError):
    """Ошибка выполнения SQL-запроса в Postgres."""

    def __init__(self, query: str, message: str = None):
        if message is None:
            message = f"Ошибка выполнения SQL-запроса: {query}"
        super().__init__(message)
        self.query = query
