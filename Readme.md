# GeoAlbum

Мобильное приложение в рамках учебного проекта по командной разработке продукта для обмена медиа-контентом среди друзей
на карте мира с микросервисной архитектурой на стороне сервера и кросплатформенным flutter приложением на стороне
конечного пользователя.

Каждый микросервис изолирован, имеет собственную базу данных PostgreSQL и общается с остальными как через HTTP (синхронно,
через API Gateway), так и через брокер сообщений Apache Kafka (асинхронно, для событийного взаимодействия — например,
рассылки уведомлений).

## Технологический стек

| Компонент            | Технологии                                                          |
|----------------------|---------------------------------------------------------------------|
| Mobile App           | Flutter / Dart, Firebase Cloud Messaging, Google Maps               |
| Gateway              | nginx + Lua (OpenResty), JWT-аутентификация                         |
| MS Users             | Java 21, Spring Boot 3.4 (Web, Security, Data JPA, OAuth2), JWT, Kafka |
| MS Events (Legacy)   | Java, Spring Boot                                                   |
| MS Events Go         | Go 1.24, Gin, pgx (PostgreSQL), Swagger (swaggo)                    |
| Content Processor    | Python, FastAPI, SQLAlchemy/Alembic, AWS S3 (aioboto3)             |
| Notification Backend | Python, FastAPI, FastStream + aiokafka, Firebase Admin SDK         |
| Хранилища            | PostgreSQL (по БД на сервис), AWS S3, Apache Kafka                  |
| Observability        | Prometheus, Grafana, Loki, Tempo, Promtail                          |

## Структура проекта

```
.
├── .github/
│   ├── readme_images/     # Скриншоты для документации
│   └── workflows/         # GitHub Actions конфигурации (CD)
├── gateway/               # API Gateway для маршрутизации запросов (nginx)
├── mobile_app/            # Мобильное Flutter-приложение для обмена медиа-контентом
├── ms_users/              # Микросервис управления пользователями (java)
├── ms_events/             # Микросервис управления мероприятиями (Legacy, java)
├── ms_events_go/          # Новый микросервис управления мероприятиями (golang)
├── content_processor/     # Сервис обработки медиа-контента (python)
├── notification_backend/  # Сервис уведомлений (python)
├── observability/         # Инструменты мониторинга и логирования
└── start.sh               # Скрипт запуска всех сервисов
```

### Основные микросервисы имеют swagger документацию по пути /docs

![Пример документации](.github/readme_images/swagger_docs.png)

### Observability сервис доступен через grafana по порту 3000

![Логи](.github/readme_images/logs.png)

## Компоненты системы

### Gateway

API Gateway на базе nginx (OpenResty) служит единой точкой входа для всех клиентских запросов и обеспечивает:

- Маршрутизацию запросов к соответствующим микросервисам
- Аутентификацию и авторизацию через проверку JWT-токенов (Lua-скрипт `jwt_auth.lua`)
- Rate limiting

### Mobile App

Мобильное приложение для пользователей системы.

#### Основные экраны приложения:

<table>
  <tr>
    <td align="center">
      <p><strong>Экран входа</strong></p>
      <img src=".github/readme_images/login.png" height="500">
    </td>
    <td align="center">
      <p><strong>Профиль пользователя</strong></p>
      <img src=".github/readme_images/profile.png" height="500">
    </td>
  </tr>
  <tr>
    <td align="center">
      <p><strong>Карта контента</strong></p>
      <img src=".github/readme_images/map.png" height="500">
    </td>
    <td align="center">
      <p><strong>Выбор медиа-контента</strong></p>
      <img src=".github/readme_images/media_pick.png" height="500">
    </td>
  </tr>
  <tr>
    <td align="center">
      <p><strong>Уведомления</strong></p>
      <img src=".github/readme_images/notification.png" height="500">
    </td>
    <td align="center">
      <p><strong>Список созданных событий</strong></p>
      <img src=".github/readme_images/events_list.png" height="500">
    </td>
  </tr>
  <tr>
    <td align="center">
      <p><strong>Экран события</strong></p>
      <img src=".github/readme_images/detailed_event.png" height="500">
    </td>
    <td></td>
  </tr>
</table>

### Микросервисы

#### MS Users

Микросервис управления пользователями (Java 21, Spring Boot) отвечает за:

- Регистрацию и аутентификацию пользователей (в том числе через OAuth2 / Google) с выдачей JWT-токенов
- Управление профилями
- Взаимодействие между пользователями (друзья)

#### MS Events (Legacy)

Старая версия микросервиса управления событиями на Spring Boot. Сохранена в репозитории для истории и заменена
сервисом MS Events Go (не входит в скрипт запуска).

#### MS Events Go

Актуальная версия микросервиса управления мероприятиями, написанная на Go (Gin + PostgreSQL через pgx). Обеспечивает:

- CRUD операции с событиями
- CRUD операции с комментариями событий

#### Content Processor

Сервис обработки контента (Python, FastAPI) выполняет:

- Валидацию загружаемых файлов
- Выдачу pre-signed URL для загрузки и хранение медиа-контента в AWS S3

#### Notification Backend

Сервис уведомлений (Python, FastAPI + FastStream) обеспечивает:

- Push-уведомления через Google Firebase Cloud Messaging
- Управление токенами устройств и подписками на уведомления
- Потребление событий из Apache Kafka для рассылки уведомлений

### Observability

Стек мониторинга и отладки на базе:

- **Prometheus** — сбор метрик производительности
- **Grafana** — визуализация метрик и логов (дашборды)
- **Loki** + **Promtail** — централизованное логирование
- **Tempo** — распределённый трейсинг запросов

## Запуск проекта

Для запуска всех серверных компонентов системы используется скрипт `start.sh`. Он создаёт общую Docker-сеть
`shared_network` и поочерёдно поднимает сервисы (`gateway`, `content_processor`, `ms_events_go`, `ms_users`,
`notification_backend`, `observability`) через их собственные `docker-compose`. Мобильное приложение и legacy-сервис
`ms_events` запускаются отдельно.

## Контрибьютеры

Ниже приведен список участников, внесших вклад в различные компоненты системы:

### Gateway - https://github.com/kestfor

### Mobile App - https://github.com/kestfor

### MS Users - https://github.com/JsJustS

### MS Events (Legacy) - https://github.com/nextples

### MS Events Go - https://github.com/kestfor

### Content Processor - https://github.com/AntonAdonin

### Notification Backend - https://github.com/AntonAdonin

### Observability - https://github.com/AntonAdonin

Изначальные наброски, user-story, agile story и др. доступны на доске: https://miro.com/app/board/uXjVIZNGeJc=/
