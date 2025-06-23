package models

import "time"

// Comment represents a user comment on an event
// swagger:model Comment
type Comment struct {
	// Unique identifier
	Id string `json:"id"`
	// Event this comment belongs to
	EventId  string `json:"eventId"`
	AuthorId string `json:"authorId"`
	// Body text of the comment
	Text string `json:"text"`
	// When created
	CreatedAt time.Time `json:"createdAt"`
	// When last updated
	UpdatedAt time.Time `json:"updatedAt"`
}
