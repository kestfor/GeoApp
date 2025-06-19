package repository

import (
	"context"
	. "ms_events_go/internal/models"
)

type CommentsRepository interface {
	GetByEventId(ctx context.Context, eventId string) ([]Comment, error)
	Create(ctx context.Context, comment *Comment) (*Comment, error)
	Update(ctx context.Context, comment *Comment) (*Comment, error)
	Delete(ctx context.Context, commentId string) error
	GetById(ctx context.Context, commentId string) (*Comment, error)
}
