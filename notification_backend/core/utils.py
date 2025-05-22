from typing import TYPE_CHECKING, Optional

if TYPE_CHECKING:
    from fastapi import Request


def get_base_url(request: "Request") -> str:
    domain = f"{request.url.scheme}://{request.url.hostname}"
    if request.url.port:
        domain += f":{request.url.port}"
    return domain


def get_user_id(request: "Request") -> Optional[str]:
    return request.headers.get("X-User-Id")