# Stage 1: build Go и получаем bundle корневых сертификатов
FROM golang:1.24-alpine AS builder

WORKDIR /ms_events_go

COPY go.mod ./

COPY . .

RUN go mod tidy
RUN go mod download


# Сборка Go-приложения
RUN CGO_ENABLED=0 GOOS=linux go build -o app ./cmd/main.go

# Установка сертификатов и копирование их в файл
RUN apk add --no-cache ca-certificates && \
    cp /etc/ssl/certs/ca-certificates.crt ./ca-certificates.crt

# Stage 2: финальный минимальный образ
FROM scratch

COPY --from=builder /ms_events_go/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

COPY --from=builder /ms_events_go/configs /configs
COPY --from=builder /ms_events_go/app /app

ENTRYPOINT ["/app"]
