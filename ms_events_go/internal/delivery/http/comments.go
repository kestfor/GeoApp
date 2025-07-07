package http

import (
	"encoding/json"
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"log/slog"
	"ms_events_go/internal/models"
	"ms_events_go/internal/services"
	"ms_events_go/pkg/logger"
	"net/http"
	"os"
)

type CommentsHandler struct {
	commentsService services.CommentsService
	logger          logger.Logger
}

func NewCommentsHandler(router *gin.RouterGroup, service services.CommentsService) *CommentsHandler {
	res := &CommentsHandler{}
	res.registerRoutes(router)
	res.commentsService = service
	res.logger = logger.NewDefaultLogger("CommentsHandler", os.Stdout, slog.LevelDebug)
	return res
}

func (h *CommentsHandler) registerRoutes(r *gin.RouterGroup) {
	r.GET("events/:event_id/comments", h.getByEventId)
	r.POST("events/:event_id/comments", h.createComment)
	r.PUT("events/:event_id/comments/:comment_id", h.updateComment)
	r.DELETE("events/:event_id/comments/:comment_id", h.deleteComment)
}

// getByEventId возвращает комментарии для события.
// @Summary      List comments by event ID
// @Description  Получает все комментарии для указанного события.
// @Tags         comments
// @Accept       json
// @Produce      json
// @Param        event_id  path      string           true  "Event ID"
// @Success      200       {array}   models.Comment
// @Failure      400       {object}  models.ErrorResponse
// @Failure      500       {object}  models.ErrorResponse
// @Router       /events/{event_id}/comments [get]
func (h *CommentsHandler) getByEventId(c *gin.Context) {
	eventId, err := uuid.Parse(c.Param("event_id"))
	if err != nil {
		h.logger.Error("Invalid event ID: " + err.Error())
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid event ID"})
		return
	}

	comments, err := h.commentsService.GetByEventId(c.Request.Context(), eventId)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get comments"})
		h.logger.Error(err.Error())
	}

	h.logger.Info(fmt.Sprintf("Fetched comments for event with id: [%s], %s: %d", eventId, "total", len(comments)))
	c.JSON(http.StatusOK, comments)
}

// createComment добавляет новый комментарий к событию.
// @Summary      Create comment
// @Description  Добавляет комментарий к событию.
// @Tags         comments
// @Accept       json
// @Produce      json
// @Param        event_id  path      string           true  "Event ID"
// @Param        comment   body      models.Comment   true  "Comment payload"
// @Success      201       {object}  models.Comment
// @Failure      400       {object}  models.ErrorResponse
// @Failure      500       {object}  models.ErrorResponse
// @Router       /events/{event_id}/comments [post]
func (h *CommentsHandler) createComment(c *gin.Context) {
	eventId, err := uuid.Parse(c.Param("event_id"))
	if err != nil {
		h.logger.Error("Invalid event ID: " + err.Error())
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid event ID"})
		return
	}

	var comment models.Comment
	if err := c.ShouldBindJSON(&comment); err != nil {
		h.logger.Error("Failed to bind JSON" + err.Error())
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	comment.EventId = eventId
	createdComment, err := h.commentsService.Create(c.Request.Context(), &comment)
	if err != nil {
		h.logger.Error("Failed to create comment: " + err.Error())
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create comment"})
		return
	}

	h.logger.Info(fmt.Sprintf("Created comment for event with id: [%s], comment id: %s", eventId, createdComment.Id))
	c.JSON(http.StatusCreated, createdComment)
}

// updateComment изменяет существующий комментарий.
// @Summary      Update comment
// @Description  Обновляет комментарий по ID.
// @Tags         comments
// @Accept       json
// @Produce      json
// @Param        event_id    path      string           true  "Event ID"
// @Param        comment_id  path      string           true  "Comment ID"
// @Param        comment     body      models.Comment   true  "Updated comment payload"
// @Success      200         {object}  models.Comment
// @Failure      400         {object}  models.ErrorResponse
// @Failure      500         {object}  models.ErrorResponse
// @Router       /events/{event_id}/comments/{comment_id} [put]
func (h *CommentsHandler) updateComment(c *gin.Context) {
	eventId, err := uuid.Parse(c.Param("event_id"))
	if err != nil {
		h.logger.Error("Invalid event ID: " + err.Error())
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid event ID"})
		return
	}
	commentId, err := uuid.Parse(c.Param("comment_id"))
	if err != nil {
		h.logger.Error("Invalid comment ID: " + err.Error())
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid comment ID"})
		return
	}

	var comment models.Comment

	if err := json.NewDecoder(c.Request.Body).Decode(&comment); err != nil {
		h.logger.Error("Failed to bind JSON: " + err.Error())
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	comment.Id = commentId
	comment.EventId = eventId

	updatedComment, err := h.commentsService.Update(c.Request.Context(), &comment)
	if err != nil {
		h.logger.Error("Failed to update comment: " + err.Error())
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update comment"})
		return
	}

	h.logger.Info(fmt.Sprintf("Updated comment for event with id: [%s], comment id: %s", eventId, updatedComment.Id))
	c.JSON(http.StatusOK, updatedComment)
}

// deleteComment удаляет комментарий по ID.
// @Summary      Delete comment
// @Description  Удаляет комментарий.
// @Tags         comments
// @Accept       json
// @Produce      json
// @Param        event_id    path  string  true  "Event ID"
// @Param        comment_id  path  string  true  "Comment ID"
// @Success      204         {string}  string  "No Content"
// @Failure      500         {object}  models.ErrorResponse
// @Failure      400         {object}  models.ErrorResponse
// @Router       /events/{event_id}/comments/{comment_id} [delete]
func (h *CommentsHandler) deleteComment(c *gin.Context) {
	eventId, err := uuid.Parse(c.Param("event_id"))
	if err != nil {
		h.logger.Error("Invalid event ID: " + err.Error())
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid event ID"})
		return
	}

	commentId, err := uuid.Parse(c.Param("comment_id"))
	if err != nil {
		h.logger.Error("Invalid comment ID: " + err.Error())
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid comment ID"})
		return
	}

	err = h.commentsService.Delete(c.Request.Context(), commentId)
	if err != nil {
		h.logger.Error("Failed to delete comment: " + err.Error())
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete comment"})
		return
	}

	h.logger.Info(fmt.Sprintf("Deleted comment for event with id: [%s], comment id: %s", eventId, commentId))
	c.JSON(http.StatusNoContent, nil)
}
