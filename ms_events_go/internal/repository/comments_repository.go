package repository

import (
	"context"
	"github.com/google/uuid"
	. "ms_events_go/internal/models"
)

type CommentsRepository interface {
	GetByEventId(ctx context.Context, eventId uuid.UUID) ([]Comment, error)
	Create(ctx context.Context, comment *Comment) (*Comment, error)
	Update(ctx context.Context, comment *Comment) (*Comment, error)
	Delete(ctx context.Context, commentId uuid.UUID) error
	GetById(ctx context.Context, commentId uuid.UUID) (*Comment, error)
}
