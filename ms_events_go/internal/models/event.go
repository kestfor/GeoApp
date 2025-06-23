package models

import "time"

type PureEvent struct {
	Id           string         `json:"id"`
	OwnerId      string         `json:"ownerId"`
	Name         string         `json:"name"`
	Description  string         `json:"description"`
	CoverMediaId string         `json:"coverMediaId"`
	CoverMedia   map[string]any `json:"coverMedia"`
	Latitude     float64        `json:"latitude"`
	Longitude    float64        `json:"longitude"`
	CreatedAt    time.Time      `json:"createdAt"`
	Participants []string       `json:"participants"`
}

type Event struct {
	PureEvent
	MediaIds  []string         `json:"mediaIds"`
	Media     []map[string]any `json:"media"`
	UpdatedAt time.Time        `json:"updatedAt"`
}
