package events_app

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
	"ms_events_go/docs"
	"ms_events_go/internal/api/content_processor"
	"ms_events_go/internal/delivery/http"
	. "ms_events_go/internal/repository/postgres"
	. "ms_events_go/internal/services"
	net "net/http"
	"os"
)

const (
	basePath = "/api/events_service"
)

func Run(configPath string) {
	// Initialize repositories
	if err := godotenv.Load(configPath); err != nil {
		panic("Error loading .env file: " + err.Error())
	}

	user, password, dbName := os.Getenv("POSTGRES_USER"), os.Getenv("POSTGRES_PASSWORD"), os.Getenv("POSTGRES_DB")
	postgresHost, postgresPort := os.Getenv("POSTGRES_HOST"), os.Getenv("POSTGRES_PORT")
	cpApi := os.Getenv("CONTENT_PROCESSOR_URL")

	connStringPostgres := fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable", user, password, postgresHost, postgresPort, dbName)
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
	contentProcessor := content_processor.NewContentProcessorApi(cpApi)
	eventsService := NewEventsService(eventsRepository, contentProcessor)
	commentsService := NewCommentsService(commentsRepository)

	router := gin.Default()
	api := router.Group(basePath)

	// Set up Swagger documentation
	docs.SwaggerInfo.BasePath = basePath
	api.GET("/docs/", func(c *gin.Context) {
		c.Redirect(net.StatusMovedPermanently, basePath+"/swagger/index.html")
	})
	api.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// Initialize handlers
	http.NewCommentsHandler(api, *commentsService)
	http.NewEventsHandler(api, *eventsService)

	servicePort := os.Getenv("SERVICE_PORT")
	if servicePort == "" {
		panic("SERVICE_PORT environment variable is not set")
	}

	if err := router.Run(":" + servicePort); err != nil {
		panic("Error starting server: " + err.Error())
	}

}
