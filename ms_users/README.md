### Перед сборкой:
1. `./src/main/resources/keys` - поместите сюда `private_key.pem` и `public_key.pem` (сгенеренные с нуля или взятые из другого места)
2. `.` - поместите сюда `.env` с таким содержимым:
```commandline
POSTGRES_USER={{here_goes_username}}
POSTGRES_PASSWORD={{here_goes_password}}
POSTGRES_DB={{here_goes_db_name}}
POSTGRES_PORT={{here_goes_db_port}}
API_PORT={{microservice_api_port_goes_here}}
```

### Swagger:
Доступ к сваггеру: `/api/users_service/swagger-ui/index.html`

Доступ к JSON спецификации: `/api/users_service/v3/api-docs`

Перед выкладыванием в прод **обязательно** отключить swagger документацию, в `./src/main/resouces/application.properties` поставить значение
```commandline
springdoc.api-docs.enabled=false
springdoc.swagger-ui.enabled=false
```

### Собрать и запустить контейнер:
```commandline
docker-compose up -d --build
```

### Собрать контейнер для последующего использования, без запуска:
```commandline
docker-compose build
```