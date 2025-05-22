from dotenv import load_dotenv

load_dotenv()
from core.logger import setup_logging

setup_logging()

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from core.config import settings
from routers import routers
from event_consumer import router as kafka_router
app = FastAPI(root_path=settings.app_prefix, docs_url=None, redoc_url=None, openapi_url=None)

app.add_middleware(
    CORSMiddleware,
    **settings.cors.model_dump()
)


@app.get("/")
async def root():
    return {"message": "Hello from root"}


app.include_router(kafka_router)
for router in routers:
    app.include_router(router)

if __name__ == "__main__":
    import uvicorn
    import logging

    logging.basicConfig(level=logging.DEBUG)
    uvicorn.run(app, host="0.0.0.0", port=8000)
