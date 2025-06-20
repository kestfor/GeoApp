package http

import (
	"context"
	"fmt"
	"github.com/gin-gonic/gin"
	"log/slog"
	. "ms_events_go/internal/models"
	. "ms_events_go/internal/services"
	. "ms_events_go/pkg/logger"
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
	headers["X-Forwarded-For"] = c.Request.Host
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

func (h *EventsHandler) getByUserId(c *gin.Context) {
	ctx := setForwardedHost(c)
	userId := c.Param("user_id")
	events, err := h.eventsService.GetByUserId(ctx, userId)

	if err != nil {
		c.JSON(500, gin.H{"error": "Failed to get events"})
		h.logger.Error(err.Error())
		return
	}

	h.logger.Info(fmt.Sprintf("Fetched events for user, %s, %s", slog.String("user_id", userId), slog.Int("total", len(events))))
	c.JSON(200, events)
}

func (h *EventsHandler) getDetailed(c *gin.Context) {
	ctx := setForwardedHost(c)
	eventId := c.Param("event_id")
	event, err := h.eventsService.GetDetailed(ctx, eventId)

	if err != nil {
		c.JSON(500, gin.H{"error": "Failed to get event details"})
		h.logger.Error(err.Error())
		return
	}

	h.logger.Info(fmt.Sprintf("Fetched event details for id: [%s]", eventId))
	c.JSON(200, event)
}

func (h *EventsHandler) createEvent(c *gin.Context) {
	ctx := setForwardedHost(c)
	var event Event
	if err := c.ShouldBindJSON(&event); err != nil {
		h.logger.Error("Failed to bind JSON: " + err.Error())
		c.JSON(400, gin.H{"error": "Invalid request data"})
		return
	}

	createdEvent, err := h.eventsService.Create(ctx, &event)
	if err != nil {
		h.logger.Error("Failed to create event: " + err.Error())
		c.JSON(500, gin.H{"error": "Failed to create event"})
		return
	}

	h.logger.Info(fmt.Sprintf("Created event with id: [%s]", createdEvent.Id))
	c.JSON(201, createdEvent)
}

func (h *EventsHandler) updateEvent(c *gin.Context) {
	ctx := setForwardedHost(c)
	eventId := c.Param("event_id")
	c.Set("host", c.Request.Header.Get("host"))
	var event Event

	if err := c.ShouldBindJSON(&event); err != nil {
		h.logger.Error("Failed to bind JSON: " + err.Error())
		c.JSON(400, gin.H{"error": "Invalid request data"})
		return
	}

	event.Id = eventId
	updatedEvent, err := h.eventsService.Update(ctx, &event)
	if err != nil {
		h.logger.Error("Failed to update event: " + err.Error())
		c.JSON(500, gin.H{"error": "Failed to update event"})
		return
	}

	h.logger.Info(fmt.Sprintf("Updated event with id: [%s]", updatedEvent.Id))
	c.JSON(200, updatedEvent)
}

func (h *EventsHandler) deleteEvent(c *gin.Context) {
	ctx := setForwardedHost(c)
	eventId := c.Param("event_id")
	if err := h.eventsService.Delete(ctx, eventId); err != nil {
		h.logger.Error("Failed to delete event: " + err.Error())
		c.JSON(500, gin.H{"error": "Failed to delete event"})
		return
	}

	h.logger.Info(fmt.Sprintf("Deleted event with id: [%s]", eventId))
	c.Status(204) // No Content
}
