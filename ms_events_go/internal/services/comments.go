package services

import (
	"context"
	"github.com/google/uuid"
	"ms_events_go/internal/models"
	"ms_events_go/internal/repository"
)

type CommentsService struct {
	commentsRepository repository.CommentsRepository
}

func NewCommentsService(commentsRepository repository.CommentsRepository) *CommentsService {
	return &CommentsService{
		commentsRepository: commentsRepository,
	}
}

func (s *CommentsService) GetByEventId(ctx context.Context, eventId uuid.UUID) ([]models.Comment, error) {
	return s.commentsRepository.GetByEventId(ctx, eventId)
}

func (s *CommentsService) Create(ctx context.Context, comment *models.Comment) (*models.Comment, error) {
	return s.commentsRepository.Create(ctx, comment)
}

func (s *CommentsService) Update(ctx context.Context, comment *models.Comment) (*models.Comment, error) {
	return s.commentsRepository.Update(ctx, comment)
}

func (s *CommentsService) Delete(ctx context.Context, commentId uuid.UUID) error {
	return s.commentsRepository.Delete(ctx, commentId)
}

func (s *CommentsService) GetById(ctx context.Context, commentId uuid.UUID) (*models.Comment, error) {
	return s.commentsRepository.GetById(ctx, commentId)
}
