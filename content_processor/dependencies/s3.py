# dependencies/s3.py

from core.services.s3 import S3Service


def get_s3_service() -> S3Service:
    return S3Service()  # лениво создается при первом обращении
