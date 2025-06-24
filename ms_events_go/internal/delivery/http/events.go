package http

import (
	"context"
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"log/slog"
	. "ms_events_go/internal/models"
	. "ms_events_go/internal/services"
	. "ms_events_go/pkg/logger"
	"net/http"
	"os"
)

type EventsHandler struct {
	eventsService EventsService
	logger        Logger
}

func NewEventsHandler(router *gin.RouterGroup, service EventsService) *EventsHandler {
	res := &EventsHandler{
		eventsService: service,
		logger:        NewDefaultLogger("EventsHandler", os.Stdout, slog.LevelDebug),
	}
	res.registerRoutes(router)
	return res
}

func setForwardedHost(c *gin.Context) context.Context {
	headers := make(map[string]string)
	headers["X-Forwarded-Host"] = c.Request.Host
	ctx := context.WithValue(c.Request.Context(), "headers", headers)
	return ctx
}

func (h *EventsHandler) registerRoutes(r *gin.RouterGroup) {
	r.GET("events/list/:user_id", h.getByUserId)
	r.GET("events/:event_id", h.getDetailed)
	r.POST("events", h.createEvent)
	r.PUT("events/:event_id", h.updateEvent)
	r.DELETE("events/:event_id", h.deleteEvent)
}

// getByUserId возвращает все события для пользователя.
// @Summary      Get events by user ID
// @Description  Возвращает список событий, принадлежащих указанному пользователю.
// @Tags         events
// @Accept       json
// @Produce      json
// @Param        user_id  path      string  true  "User ID"
// @Success      200      {array}   models.Event
// @Failure      500      {object}  models.ErrorResponse
// @Failure      400      {object}  models.ErrorResponse
// @Router       /events/list/{user_id} [get]
func (h *EventsHandler) getByUserId(c *gin.Context) {
	ctx := setForwardedHost(c)
	userId, err := uuid.Parse(c.Param("user_id"))
	if err != nil {
		h.logger.Error("Invalid user ID: " + err.Error())
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user ID"})
		return
	}

	events, err := h.eventsService.GetByUserId(ctx, userId)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get events"})
		h.logger.Error(err.Error())
		return
	}

	h.logger.Info(fmt.Sprintf("Fetched events for user, %s, %s", slog.String("user_id", userId.String()), slog.Int("total", len(events))))
	c.JSON(http.StatusOK, events)
}

// getDetailed возвращает подробную информацию о событии.
// @Summary      Get event details
// @Description  Возвращает расширенную информацию по событию.
// @Tags         events
// @Accept       json
// @Produce      json
// @Param        event_id  path      string  true  "Event ID"
// @Success      200       {object}  models.Event
// @Failure      500       {object}  models.ErrorResponse
// @Failure      400       {object}  models.ErrorResponse
// @Router       /events/{event_id} [get]
func (h *EventsHandler) getDetailed(c *gin.Context) {
	ctx := setForwardedHost(c)
	eventId, err := uuid.Parse(c.Param("event_id"))

	if err != nil {
		h.logger.Error("Invalid event ID: " + err.Error())
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid event ID"})
		return
	}

	event, err := h.eventsService.GetDetailed(ctx, eventId)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get event details"})
		h.logger.Error(err.Error())
		return
	}

	h.logger.Info(fmt.Sprintf("Fetched event details for id: [%s]", eventId))
	c.JSON(http.StatusOK, event)
}

// createEvent создаёт новое событие.
// @Summary      Create event
// @Description  Создаёт новое событие.
// @Tags         events
// @Accept       json
// @Produce      json
// @Param        event  body      models.Event  true  "Event payload"
// @Success      201    {object}  models.Event
// @Failure      400    {object}  models.ErrorResponse
// @Failure      500    {object}  models.ErrorResponse
// @Router       /events [post]
func (h *EventsHandler) createEvent(c *gin.Context) {
	ctx := setForwardedHost(c)
	var event Event
	if err := c.ShouldBindJSON(&event); err != nil {
		h.logger.Error("Failed to bind JSON: " + err.Error())
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data"})
		return
	}

	createdEvent, err := h.eventsService.Create(ctx, &event)
	if err != nil {
		h.logger.Error("Failed to create event: " + err.Error())
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create event"})
		return
	}

	h.logger.Info(fmt.Sprintf("Created event with id: [%s]", createdEvent.Id))
	c.JSON(http.StatusCreated, createdEvent)
}

// updateEvent обновляет существующее событие.
// @Summary      Update event
// @Description  Обновляет данные существующего события.
// @Tags         events
// @Accept       json
// @Produce      json
// @Param        event_id  path      string        true  "Event ID"
// @Param        event     body      models.Event  true  "Updated event payload"
// @Success      200       {object}  models.Event
// @Failure      400       {object}  models.ErrorResponse
// @Failure      500       {object}  models.ErrorResponse
// @Router       /events/{event_id} [put]
func (h *EventsHandler) updateEvent(c *gin.Context) {
	ctx := setForwardedHost(c)
	eventId, err := uuid.Parse(c.Param("event_id"))
	if err != nil {
		h.logger.Error("Invalid event ID: " + err.Error())
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid event ID"})
		return
	}

	var event Event
	if err := c.ShouldBindJSON(&event); err != nil {
		h.logger.Error("Failed to bind JSON: " + err.Error())
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data"})
		return
	}

	event.Id = eventId
	updatedEvent, err := h.eventsService.Update(ctx, &event)
	if err != nil {
		h.logger.Error("Failed to update event: " + err.Error())
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update event"})
		return
	}

	h.logger.Info(fmt.Sprintf("Updated event with id: [%s]", updatedEvent.Id))
	c.JSON(http.StatusOK, updatedEvent)
}

// deleteEvent удаляет событие по ID.
// @Summary      Delete event
// @Description  Удаляет событие.
// @Tags         events
// @Accept       json
// @Produce      json
// @Param        event_id  path     string  true  "Event ID"
// @Success      204       {string} string  "No Content"
// @Failure      500       {object} models.ErrorResponse
// @Failure      400       {object} models.ErrorResponse
// @Router       /events/{event_id} [delete]
func (h *EventsHandler) deleteEvent(c *gin.Context) {
	ctx := setForwardedHost(c)
	eventId, err := uuid.Parse(c.Param("event_id"))
	if err != nil {
		h.logger.Error("Invalid event ID: " + err.Error())
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid event ID"})
		return
	}
	if err := h.eventsService.Delete(ctx, eventId); err != nil {
		h.logger.Error("Failed to delete event: " + err.Error())
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete event"})
		return
	}

	h.logger.Info(fmt.Sprintf("Deleted event with id: [%s]", eventId))
	c.Status(http.StatusNoContent) // No Content
}
