package repository

import (
	"context"
	"github.com/google/uuid"
	. "ms_events_go/internal/models"
)

type EventsRepository interface {
	GetDetailed(ctx context.Context, eventId uuid.UUID) (*Event, error)
	Create(ctx context.Context, event *Event) (*Event, error)
	Update(ctx context.Context, event *Event) (*Event, error)
	Delete(ctx context.Context, eventId uuid.UUID) error
	GetByUserId(ctx context.Context, userId uuid.UUID) ([]PureEvent, error)
}
