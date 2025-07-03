package models

import (
	"github.com/google/uuid"
	"time"
)

// Comment represents a user comment on an event
// swagger:model Comment
type Comment struct {
	// Unique identifier
	Id uuid.UUID `json:"id" format:"uuid"`

	// Event this comment belongs to
	EventId uuid.UUID `json:"eventId" format:"uuid"`

	// Author of the comment
	AuthorId uuid.UUID `json:"authorId" format:"uuid"`

	// Body text of the comment
	Text string `json:"text"`

	// When created
	CreatedAt time.Time `json:"createdAt" format:"date-time"`

	// When last updated
	UpdatedAt time.Time `json:"updatedAt" format:"date-time"`
}
