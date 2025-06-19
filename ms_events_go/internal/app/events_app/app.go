package events_app

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"ms_events_go/internal/delivery/http"
	. "ms_events_go/internal/repository/postgres"
	. "ms_events_go/internal/services"
	"os"
)

func Run(configPath string) {
	// Initialize repositories
	if err := godotenv.Load(configPath); err != nil {
		panic("Error loading .env file: " + err.Error())
	}

	user, password, db_name := os.Getenv("POSTGRES_USER"), os.Getenv("POSTGRES_PASSWORD"), os.Getenv("POSTGRES_DB")
	postgresHost, postgresPort := os.Getenv("POSTGRES_HOST"), os.Getenv("POSTGRES_PORT")

	connStringPostgres := fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable", user, password, postgresHost, postgresPort, db_name)
	var err error

	eventsRepository, err := NewEventsRepository(connStringPostgres)
	if err != nil {
		panic("Error initializing events repository: " + err.Error())
	}

	commentsRepository, err := NewCommentsRepository(connStringPostgres)
	if err != nil {
		panic("Error initializing comments repository: " + err.Error())
	}

	// Initialize services
	NewEventsService(eventsRepository)
	commentsService := NewCommentsService(commentsRepository)

	router := gin.Default()
	api := router.Group("/events_service")

	// Initialize handlers
	http.NewCommentsHandler(api, *commentsService)

	if err := router.Run(); err != nil {
		panic("Error starting server: " + err.Error())
	}

}
