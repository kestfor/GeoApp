package services

import (
	"context"
	"errors"
	"testing"

	"github.com/golang/mock/gomock"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"

	"ms_events_go/internal/models"
	"ms_events_go/internal/repository/mocks"
)

func TestCommentsService_GetByEventId(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	mockRepo := mocks.NewMockCommentsRepository(ctrl)
	service := NewCommentsService(mockRepo)

	ctx := context.Background()
	eventID := uuid.New()
	expectedComments := []models.Comment{
		{Id: uuid.New(), EventId: eventID, Text: "Comment 1"},
	}

	mockRepo.
		EXPECT().
		GetByEventId(ctx, eventID).
		Return(expectedComments, nil)

	result, err := service.GetByEventId(ctx, eventID)

	assert.NoError(t, err)
	assert.Equal(t, expectedComments, result)
}

func TestCommentsService_Create(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	mockRepo := mocks.NewMockCommentsRepository(ctrl)
	service := NewCommentsService(mockRepo)

	ctx := context.Background()
	comment := &models.Comment{Id: uuid.New(), Text: "Test create"}

	mockRepo.
		EXPECT().
		Create(ctx, comment).
		Return(comment, nil)

	result, err := service.Create(ctx, comment)

	assert.NoError(t, err)
	assert.Equal(t, comment, result)
}

func TestCommentsService_Update(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	mockRepo := mocks.NewMockCommentsRepository(ctrl)
	service := NewCommentsService(mockRepo)

	ctx := context.Background()
	comment := &models.Comment{Id: uuid.New(), Text: "Updated"}

	mockRepo.
		EXPECT().
		Update(ctx, comment).
		Return(comment, nil)

	result, err := service.Update(ctx, comment)

	assert.NoError(t, err)
	assert.Equal(t, comment, result)
}

func TestCommentsService_Delete(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	mockRepo := mocks.NewMockCommentsRepository(ctrl)
	service := NewCommentsService(mockRepo)

	ctx := context.Background()
	commentID := uuid.New()

	mockRepo.
		EXPECT().
		Delete(ctx, commentID).
		Return(nil)

	err := service.Delete(ctx, commentID)

	assert.NoError(t, err)
}

func TestCommentsService_GetById(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	mockRepo := mocks.NewMockCommentsRepository(ctrl)
	service := NewCommentsService(mockRepo)

	ctx := context.Background()
	commentID := uuid.New()
	expected := &models.Comment{Id: commentID, Text: "By ID"}

	mockRepo.
		EXPECT().
		GetById(ctx, commentID).
		Return(expected, nil)

	result, err := service.GetById(ctx, commentID)

	assert.NoError(t, err)
	assert.Equal(t, expected, result)
}

func TestCommentsService_GetById_Error(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	mockRepo := mocks.NewMockCommentsRepository(ctrl)
	service := NewCommentsService(mockRepo)

	ctx := context.Background()
	commentID := uuid.New()
	expectedErr := errors.New("not found")

	mockRepo.
		EXPECT().
		GetById(ctx, commentID).
		Return(nil, expectedErr)

	result, err := service.GetById(ctx, commentID)

	assert.Nil(t, result)
	assert.Equal(t, expectedErr, err)
}
