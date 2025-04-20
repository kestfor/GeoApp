from enum import Enum


class HashType(str, Enum):
    MD5 = "md5"
    SHA1 = "sha1"
    SHA256 = "sha256"
    SHA512 = "sha512"


EXTENSION_MAPPING = {
    # Images
    "image/jpeg": "jpeg",
    "image/jpg": "jpg",
    "image/png": "png",
    "image/webp": "webp",
    "image/heic": "heic",  # Apple HEIF format
    "image/heif": "heif",  # Альтернативное название
    "image/gif": "gif",
    "image/bmp": "bmp",
    "image/tiff": "tiff",

    # Video
    "video/mp4": "mp4",
    "video/quicktime": "mov",  # Apple .mov
    "video/x-matroska": "mkv",
    "video/webm": "webm",
    "video/3gpp": "3gp",
    "video/x-msvideo": "avi",

    # Audio (может пригодиться)
    "audio/mpeg": "mp3",
    "audio/aac": "aac",
    "audio/x-aac": "aac",  # Вариант для Android/iOS
    "audio/x-m4a": "m4a",  # Apple M4A
    "audio/mp4": "m4a",  # Часто тоже .m4a
    "audio/ogg": "ogg",
    "audio/wav": "wav",
    "audio/webm": "webm",
}


class MimeType(str, Enum):
    JPEG = "image/jpeg"
    JPG = "image/jpg"
    PNG = "image/png"
    MP4 = "video/mp4"

    def get_extension(self) -> str:
        return EXTENSION_MAPPING.get(self.value, "bin")


class MediaVariant(str, Enum):
    THUMBNAIL = "thumbnail"
    MEDIUM = "medium"
    ORIGINAL = "original"


class MediaType(str, Enum):
    PHOTO = "photo"
    VIDEO = "video"
