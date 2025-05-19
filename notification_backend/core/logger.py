import datetime
import json
import logging
import sys
import traceback

from logging_loki import LokiHandler

from core.config import settings


class JsonFormatter(logging.Formatter):
    EXCLUDED_KEYS = {
        "msg", "args", "exc_info", "exc_text", "stack_info", "created",
        "msecs", "relativeCreated", "levelname", "thread", "threadName",
        "processName", "process", "message", "asctime", "taskName",
        "pathname", "levelno", "module", "funcName", "lineno",
    }

    def format(self, record):
        json_record = {
            "time": datetime.datetime.now().isoformat(),
            "message": record.getMessage().replace('\n', '\r'),
            "level": record.levelname.replace("WARNING", "WARN").replace("CRITICAL", "FATAL")
        }
        # include extra attributes
        for key in set(record.__dict__.keys()) - self.EXCLUDED_KEYS:
            json_record[key] = record.__dict__[key]
        if record.exc_info:
            json_record["traceback"] = self.formatException(record.exc_info)
        return json.dumps(json_record, ensure_ascii=False)

    def formatException(self, exc_info):
        return ''.join(traceback.format_exception(*exc_info))


class SafeLokiHandler(LokiHandler):
    """
    Обёртка над LokiHandler, которая гасит любые внутренние
    ошибки при отправке лога, чтобы не провоцировать рекурсию.
    """

    def emit(self, record):
        try:
            super().emit(record)
        except Exception:
            # здесь можно записать локально в stdout или stderr,
            # но главное — не давать исключению "уплыть" дальше
            sys.stderr.write(
                f"[SafeLokiHandler] ошибка при отправке лога: {traceback.format_exc()}\n"
            )

    def handleError(self, record):
        # Completely suppress any internal errors:
        # simply consume them so they never reach stderr.
        try:
            # Optional: record the occurrence in a counter or metric,
            # but do NOT call super().handleError()
            pass
        except Exception:
            # Even our “suppression” shouldn’t raise!
            return


def setup_logging():
    # Stream handler for stdout
    stream_handler = logging.StreamHandler(sys.stdout)
    stream_handler.setLevel(logging.DEBUG)
    stream_handler.setFormatter(JsonFormatter())

    # Loki handler
    loki_handler = None
    if settings.loki_settings.url:
        loki_handler = SafeLokiHandler(
            url=settings.loki_settings.url,
            auth=settings.loki_settings.auth,
            tags={"application": "notification_backend"},
            version="1"
        )
        loki_handler.setLevel(logging.DEBUG)
        loki_handler.setFormatter(JsonFormatter())

    root_logger = logging.getLogger()
    root_logger.setLevel(logging.INFO)
    root_logger.addHandler(stream_handler)
    if loki_handler:
        root_logger.addHandler(loki_handler)
