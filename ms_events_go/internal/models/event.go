package models

import (
	"github.com/google/uuid"
	"time"
)

// PureEvent represents a user event with minimal details.
// swagger:model PureEvent
type PureEvent struct {
	// Unique identifier for the event
	Id uuid.UUID `json:"id" format:"uuid"`

	// Owner of the event
	OwnerId uuid.UUID `json:"ownerId" format:"uuid"`

	// Name of the event
	Name string `json:"name"`

	// Description of the event
	Description string `json:"description"`

	// CoverMediaId is the uuid4 ID of the cover media for the event
	CoverMediaId uuid.UUID `json:"coverMediaId" format:"uuid"`

	// CoverMedia contains full cover media information for the event
	CoverMedia map[string]any `json:"coverMedia"`

	// Latitude and Longitude of the event location
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`

	// CreatedAt is the timestamp when the event was created
	CreatedAt time.Time `json:"createdAt" format:"date-time"`

	// Participants is a list of user IDs who are participants in the event
	Participants []uuid.UUID `json:"participants"`
}

// Event represents a user event with detailed information, including media.
// swagger:model Event
type Event struct {
	PureEvent

	// MediaIds is a list of media IDs associated with the event
	MediaIds []uuid.UUID `json:"mediaIds"`

	// Media contains full media information for the event
	Media []map[string]any `json:"media"`

	// UpdatedAt is the timestamp when the event was last updated
	UpdatedAt time.Time `json:"updatedAt" format:"date-time"`
}
