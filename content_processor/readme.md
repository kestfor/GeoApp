Для деплоя через yappa, нужно пропатчить httpx client:

```python
async with httpx.AsyncClient(transport=transport, base_url=host_url) as client:
    request = client.build_request(
        method=event["httpMethod"],
        url=event["url"],
        headers=event["headers"],
        params=event["queryStringParameters"],
        content=event["body"],
    )
    response = await client.send(request, allow_redirects=False)
```