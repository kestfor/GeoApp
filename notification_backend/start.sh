mkdir -p docker_volumes/kafka_volume
mkdir -p docker_volumes/pg_volume
mkdir -p docker_volumes/zookeeper_data
docker network create "shared_network"
docker compose up -d --build