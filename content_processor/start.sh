mkdir -p docker_volumes/pg_volume
docker compose --env-file .env up -d --build