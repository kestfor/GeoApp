package services

import (
	"context"
	. "ms_events_go/internal/models"
	"ms_events_go/internal/repository/postgres"
	"testing"
	"time"
)

var (
	eventsRepository, createEventsError = postgres.NewEventsRepository("postgres://postgres:postgres@localhost:5432/events_db?sslmode=disable")
	serviceEvent                        = NewEventsService(eventsRepository)
	mediaId                             = "0b0be500-4eb2-4ee1-9775-b91bbbc7a41d"
	commentsRepository, createError     = postgres.NewCommentsRepository("postgres://postgres:postgres@localhost:5432/events_db?sslmode=disable")
	service                             = NewCommentsService(commentsRepository)
	eventId                             = "0b0be500-4eb2-4ee1-9775-b91bbbc7a41d"
	authorId                            = "0b0be500-4eb2-4ee1-9775-b91bbbc7a41d"
	commentId                           string
)

func TestEventsService_Create(t *testing.T) {
	if createEventsError != nil {
		t.Fatalf("Failed to create events repository: %v", createEventsError)
	}

	pureEvent := PureEvent{
		OwnerId:      authorId,
		CoverMediaId: mediaId,
		Name:         "Test Event",
		Description:  "This is a test event.",
		Latitude:     0.0,
		Longitude:    0.0,
		CreatedAt:    time.Now(),
		CoverMedia:   map[string]any{"id": mediaId, "url": "http://example.com/media.jpg"},
	}

	event := &Event{
		PureEvent:    pureEvent,
		Participants: []string{authorId},
		MediaIds:     []string{mediaId},
		Media:        []map[string]any{{"id": mediaId, "url": "http://example.com/media.jpg"}},
		UpdatedAt:    time.Now(),
	}

	ctx := context.Background()
	createdEvent, err := serviceEvent.Create(ctx, event)
	if err != nil {
		t.Fatalf("Failed to create event: %v", err)
	}
	eventId = createdEvent.Id
	if createdEvent.Id == "" {
		t.Fatalf("Expected a new ID for the created event, got an empty ID")
	}
}

func TestEventsService_GetDetailed(t *testing.T) {
	ctx := context.Background()
	event, err := serviceEvent.GetDetailed(ctx, eventId)
	if err != nil {
		t.Fatalf("Failed to get detailed event: %v", err)
	}

	if event.Id != eventId {
		t.Errorf("Expected event ID %s, got %s", eventId, event.Id)
	}
	if event.OwnerId != authorId {
		t.Errorf("Expected owner ID %s, got %s", authorId, event.OwnerId)
	}
}

func TestEventsService_Update(t *testing.T) {
	ctx := context.Background()
	event, err := serviceEvent.GetDetailed(ctx, eventId)
	if err != nil {
		t.Fatalf("Failed to get detailed event: %v", err)
	}

	event.Name = "Updated Test Event"
	event.Description = "This is an updated test event."

	updatedEvent, err := serviceEvent.Update(ctx, event)
	if err != nil {
		t.Fatalf("Failed to update event: %v", err)
	}

	if updatedEvent.Name != "Updated Test Event" {
		t.Fatalf("Expected event name 'Updated Test Event', got '%s'", updatedEvent.Name)
	}
	if updatedEvent.Description != "This is an updated test event." {
		t.Fatalf("Expected event description 'This is an updated test event.', got '%s'", updatedEvent.Description)
	}
}

func TestEventsService_GetByUserId(t *testing.T) {
	ctx := context.Background()
	events, err := serviceEvent.GetByUserId(ctx, authorId)
	if err != nil {
		t.Fatalf("Failed to get events by user ID: %v", err)
	}

	if len(events) == 0 {
		t.Fatalf("Expected to find events for the user, but got none")
	}

	for _, event := range events {
		if event.OwnerId != authorId {
			t.Fatalf("Expected event owner ID %s, got %s", authorId, event.OwnerId)
		}
	}
}

func TestCommentsService_Create(t *testing.T) {
	if createError != nil {
		t.Fatalf("Failed to create comments repository: %v", createError)
	}

	comment := &Comment{
		Id:        "test-id",
		EventId:   eventId,
		AuthorId:  authorId,
		Text:      "This is a test comment",
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	ctx := context.Background()
	created, err := service.Create(ctx, comment)
	if err != nil {
		t.Fatalf("Failed to create comment: %v", err)
	}

	commentId = created.Id // Store the ID for later tests

	if created.Id == "test-id" {
		t.Fatalf("Expected a new ID for the created comment, got: %s", created.Id)
	}

}

func TestCommentsService_Update(t *testing.T) {
	comment := &Comment{
		Id:        commentId,
		EventId:   eventId,
		AuthorId:  authorId,
		Text:      "This is an updated test comment",
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
	ctx := context.Background()
	updated, err := service.Update(ctx, comment)
	if err != nil {
		t.Fatalf("Failed to update comment: %v", err)
	}

	if updated.Text != comment.Text {
		t.Fatalf("Expected updated text %s, got %s", comment.Text, updated.Text)
	}
}

func TestCommentsService_GetById(t *testing.T) {
	ctx := context.Background()
	retrieved, err := service.GetById(ctx, commentId)
	if err != nil {
		t.Fatalf("Failed to get comment by ID: %v", err)
	}

	if retrieved == nil {
		t.Fatalf("Expected to find a comment with ID %s, but got nil", commentId)
	}
	if retrieved.Id != commentId {
		t.Fatalf("Expected comment ID %s, got %s", commentId, retrieved.Id)
	}
}

func TestCommentsService_GetByEventId(t *testing.T) {
	ctx := context.Background()
	comments, err := service.GetByEventId(ctx, eventId)
	if err != nil {
		t.Fatalf("Failed to get comments by event ID: %v", err)
	}

	if len(comments) == 0 {
		t.Fatalf("Expected to find comments for event ID %s, but got none", eventId)
	}

	found := false
	for _, comment := range comments {
		if comment.Id == commentId {
			found = true
			break
		}
	}
	if !found {
		t.Fatalf("Expected to find comment with ID %s in comments for event ID %s", commentId, eventId)
	}
}

func TestCommentsService_Delete(t *testing.T) {
	ctx := context.Background()
	err := service.Delete(ctx, commentId)
	if err != nil {
		t.Fatalf("Failed to delete comment: %v", err)
	}

	// Verify deletion
	found, err := service.GetById(ctx, commentId)
	if err != nil {
		t.Fatalf("Failed to get comment by ID after deletion: %v", err)
	}
	if found != nil {
		t.Fatalf("Expected comment to be deleted, but found: %v", found)
	}

}

func TestEventsService_Delete(t *testing.T) {
	ctx := context.Background()
	err := serviceEvent.Delete(ctx, eventId)
	if err != nil {
		t.Fatalf("Failed to delete event: %v", err)
	}

	// Verify that the event was deleted
	found, err := serviceEvent.GetDetailed(ctx, eventId)
	if err != nil {
		t.Fatalf("Failed to verify event deletion: %v", err)
	}

	if found != nil {
		t.Fatalf("Expected event with ID %s to be deleted, but it was found", eventId)
	}
}
