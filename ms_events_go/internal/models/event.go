package models

import "time"

type PureEvent struct {
	Id           string    `json:"id"`
	OwnerId      string    `json:"owner_id"`
	Name         string    `json:"name"`
	Description  string    `json:"description"`
	CoverMediaId string    `json:"cover_media_id"`
	CoverUrl     string    `json:"cover_url"`
	Latitude     float64   `json:"latitude"`
	Longitude    float64   `json:"longitude"`
	CreatedAt    time.Time `json:"created_at"`
}

type Event struct {
	PureEvent
	Participants []string         `json:"participants"`
	MediaIds     []string         `json:"media_ids"`
	Media        []map[string]any `json:"media"`
	UpdatedAt    time.Time        `json:"updated_at"`
}
