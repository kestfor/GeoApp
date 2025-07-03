package repository

import (
	"context"
	"github.com/google/uuid"
	"ms_events_go/internal/models"
)

type EventsRepository interface {
	GetDetailed(ctx context.Context, eventId uuid.UUID) (*models.Event, error)
	Create(ctx context.Context, event *models.Event) (*models.Event, error)
	Update(ctx context.Context, event *models.Event) (*models.Event, error)
	Delete(ctx context.Context, eventId uuid.UUID) error
	GetByUserId(ctx context.Context, userId uuid.UUID) ([]models.PureEvent, error)
}
