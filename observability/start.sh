mkdir -p ./docker_volumes/grafanadata \
         ./docker_volumes/prometheusdata \
         ./docker_volumes/tempodata \
         ./docker_volumes/lokidata
docker network create "shared-network"
docker compose up -d --build