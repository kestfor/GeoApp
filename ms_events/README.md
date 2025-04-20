# GeoApp Events-microservice 

Микросервис для работы с событиями и комментариями. 
Документация API доступна по адресу `/docs` (Swagger UI).

## 🚀 Быстрый старт

### 1. Настройка окружения
Создайте .env файл из шаблона:

```bash
    cp .env.example .env
```
Отредактируйте параметры в .env  
Заполните поля:
```
POSTGRES_DB
POSTGRES_USER
POSTGRES_PASSWORD
```

### 2. Запуск сервисов

```bash
docker-compose -p ms_events up -d --build
```

### 3. Использование
Сервис будет доступен на http://localhost:8080  
UI-Документация Swagger доступна на http://localhost:8080/docs  
Документация OpenApi доступна на http://localhost:8080/v3/api-docs  

