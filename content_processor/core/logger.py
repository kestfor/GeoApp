import datetime
import json
import logging
import sys
import traceback


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
        for key in set(record.__dict__.keys()) - self.EXCLUDED_KEYS:
            json_record[key] = record.__dict__[key]
        if record.exc_info:
            json_record["traceback"] = self.formatException(record.exc_info)
        return json.dumps(json_record, ensure_ascii=False)

    def formatException(self, exc_info):
        return ''.join(traceback.format_exception(*exc_info))


def setup_logging():
    handler = logging.StreamHandler(sys.stdout)
    handler.setLevel(logging.DEBUG)
    handler.setFormatter(JsonFormatter())

    root_logger = logging.getLogger()
    root_logger.setLevel(logging.DEBUG)
    root_logger.addHandler(handler)
