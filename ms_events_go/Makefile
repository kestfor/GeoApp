build_mocks:
	go tool mockgen -source=internal/api/content_processor/content_processor_api.go -destination=internal/api/content_processor/mocks/content_processor_mock.go -package=mocks
	go tool mockgen -source=internal/repository/comments_repository.go -destination=internal/repository/mocks/comments_repository_mock.go -package=mocks
	go tool mockgen -source=internal/repository/events_repository.go -destination=internal/repository/mocks/events_repository_mock.go -package=mocks

test:
	go test -v ./...


