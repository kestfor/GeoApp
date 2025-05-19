from pydantic import BaseModel

from core.schemas.general import DevicePlatform


class DeviceTokenCreate(BaseModel):
    token: str
    platform: DevicePlatform


class DeviceTokenDelete(BaseModel):
    token: str