# Используем официальный образ Python
FROM python:3.12-alpine
WORKDIR ./
COPY requirements.txt .
RUN pip install --no-cache-dir --prefer-binary -r requirements.txt
COPY .. .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
