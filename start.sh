#!/usr/bin/env bash
set -euo pipefail

# 1) Create the shared network if it doesn't already exist
if ! docker network inspect shared_network >/dev/null 2>&1; then
  echo "Creating Docker network: shared_network"
  docker network create shared_network
else
  echo "Network shared_network already exists; skipping create."
fi

# 2) List of service directories (adjust names if needed)
services=(
  gateway
  content_processor
  ms_events
  ms_users
  notification_backend
  observability
)

# 3) For each service, cd in and invoke its start.sh
for service in "${services[@]}"; do
  echo
  echo "=== Starting service: $service ==="
  if [[ -d "$service" && -x "$service/start.sh" ]]; then
    # Run the service’s own start.sh (which does: docker compose up -d --build)
    ( cd "$service" && ./start.sh )
  else
    echo "Warning: '$service/start.sh' not found or not executable; skipping."
  fi
done

echo
echo "All services have been started."
