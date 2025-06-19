package repository

import (
	"context"
	. "ms_events_go/internal/models"
)

type EventsRepository interface {
	GetDetailed(ctx context.Context, eventId string) (*Event, error)
	Create(ctx context.Context, event *Event) (*Event, error)
	Update(ctx context.Context, event *Event) (*Event, error)
	Delete(ctx context.Context, eventId string) error
	GetByUserId(ctx context.Context, userId string) ([]PureEvent, error)
}
