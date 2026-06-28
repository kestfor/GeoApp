#!/usr/bin/env bash
set -euo pipefail
chmod +x */start.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 1) Create the shared network if it doesn't already exist
if ! docker network inspect shared_network >/dev/null 2>&1; then
  echo "Создание Docker сети: shared_network"
  docker network create shared_network
else
  echo "Сеть shared_network уже существует; пропуск создания."
fi

# 2) List of service directories (adjust names if needed)
services=(
  gateway
  content_processor
  #ms_events replaced by golang implementation
  ms_events_go
  ms_users
  notification_backend
  observability
)

for service in "${services[@]}"; do
  echo
  echo "🚀 Запуск сервиса: $service"
  SERVICE_DIR="${SCRIPT_DIR}/${service}"
  START_SCRIPT="${SERVICE_DIR}/start.sh"

  if [[ -d "$SERVICE_DIR" && -x "$START_SCRIPT" ]]; then
    (cd "$SERVICE_DIR" && bash start.sh)
  else
    echo "⚠️  Сервис '$service' не найден или файл start.sh не исполняемый. Пропуск."
  fi
done

echo
echo "✅ Все сервисы были запущены."
