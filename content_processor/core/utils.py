import re

from fastapi import Request


def parse_file_size(size_str: str) -> int:
    size_str = size_str.strip().upper()
    match = re.match(r'^(\d+(?:\.\d+)?)([KMG]?B)$', size_str)

    if not match:
        raise ValueError(f"Invalid file size format: {size_str}")

    number, unit = match.groups()
    number = float(number)

    unit_multipliers = {
        'B': 1,
        'KB': 1024,
        'MB': 1024 ** 2,
        'GB': 1024 ** 3,
    }

    return int(number * unit_multipliers[unit])


def get_base_url(request: "Request") -> str:
    domain = f"{request.url.scheme}://{request.url.hostname}"
    if request.url.port:
        domain += f":{request.url.port}"
    if "X-Forwarded-Host" in request.headers:
        # TODO пофиксить костыль (nginx не ставит никакие доп хедеры которые я ему прописываю, этот вручную
        #  прокидываю через java, извлекая host хедер, port можно прописать в env и доставать оттуда)
        domain = request.headers["X-Forwarded-Host"] + ":8001"
    # if "host" in request.headers:
    #     domain = request.headers["host"] + ":8001"
    return domain
