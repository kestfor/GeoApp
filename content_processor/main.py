from core.exceptions.handlers import setup_exception_handlers
from core.logger import setup_logging

setup_logging()
from dotenv import load_dotenv

load_dotenv()
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from core.config import settings
from routers import routers

app = FastAPI(root_path=settings.app_prefix, docs_url=None, redoc_url=None, openapi_url=None)
setup_exception_handlers(app)

app.add_middleware(
    CORSMiddleware,
    **settings.cors.model_dump()
)


@app.get("/")
async def root():
    return {"message": "Hello from root"}


@app.get("/redirect")
async def redirect_resp():
    return {
        "statusCode": 301,
        "headers": {
            "Location": "https://vk.com"  # Абсолютный URL, например "https://example.com/image.jpg"
        },
        "body": ""
    }


for router in routers:
    app.include_router(router)

# EVENT SERVICE
# TUSOVKA
# [uuid4_1, uuid4_2, uuid4_3, uuid4_4]
# ЗАПРОС ССЫЛОК ПО ЮИД
# retun [url]

# PHOTO
# backend.ru/files/uuid4/{size}.jpg/.png #

# VIDEO
# backend.ru/files/uuid4/thumbnail.mp4
# backend.ru/files/uuid4/video.mp4
# from mangum import Mangum
#
# handler = Mangum(app, lifespan="off")

if __name__ == "__main__":
    import uvicorn
    import logging

    logging.basicConfig(level=logging.DEBUG)
    uvicorn.run(app, host="0.0.0.0", port=8000)
