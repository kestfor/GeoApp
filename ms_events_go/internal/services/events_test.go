package services

import (
	"context"
	"github.com/golang/mock/gomock"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"ms_events_go/internal/api/content_processor"
	cpMock "ms_events_go/internal/api/content_processor/mocks"
	"ms_events_go/internal/models"
	"ms_events_go/internal/repository/mocks"
	"testing"
)

var mockMediaId = uuid.New()
var mockMedia content_processor.ContentProcessorResponse = map[uuid.UUID]map[string]any{
	mockMediaId: {"media_id": mockMediaId},
}
var headers = map[string]string{
	"content-type":     "application/json",
	"X-Forwarded-Host": "127.0.0.1",
}

func TestEventsService_Create(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	mockRepo := mocks.NewMockEventsRepository(ctrl)
	mockCont := cpMock.NewMockContentProcessor(ctrl)
	service := NewEventsService(mockRepo, mockCont)
	ctx := context.Background()
	ctx = context.WithValue(ctx, "headers", headers)

	eventID := uuid.New()

	pureEvent := models.PureEvent{
		Id:           eventID,
		CoverMediaId: mockMediaId,
	}
	expectedEvent := &models.Event{
		PureEvent: pureEvent,
		MediaIds:  []uuid.UUID{mockMediaId},
	}

	mockCont.EXPECT().SetHeaders(headers).Return()
	mockRepo.EXPECT().Create(ctx, expectedEvent).Return(expectedEvent, nil)
	mockCont.EXPECT().GetMedia(ctx, []uuid.UUID{mockMediaId}).Return(mockMedia, nil)
	result, err := service.Create(ctx, expectedEvent)
	assert.NoError(t, err)
	assert.Equal(t, expectedEvent, result)
}

func TestEventsService_Update(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	mockRepo := mocks.NewMockEventsRepository(ctrl)
	mockCont := cpMock.NewMockContentProcessor(ctrl)
	service := NewEventsService(mockRepo, mockCont)
	ctx := context.Background()
	ctx = context.WithValue(ctx, "headers", headers)
	eventID := uuid.New()
	pureEvent := models.PureEvent{
		Id:           eventID,
		CoverMediaId: mockMediaId,
		Name:         "New Name",
	}

	expectedEvent := &models.Event{
		PureEvent: pureEvent,
		MediaIds:  []uuid.UUID{mockMediaId},
	}
	mockCont.EXPECT().SetHeaders(headers).Return()
	mockRepo.EXPECT().Update(ctx, expectedEvent).Return(expectedEvent, nil)
	mockCont.EXPECT().GetMedia(ctx, []uuid.UUID{mockMediaId}).Return(mockMedia, nil)
	res, err := service.Update(ctx, expectedEvent)
	assert.NoError(t, err)
	assert.Equal(t, expectedEvent, res)
}

func TestEventsService_Delete(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	mockRepo := mocks.NewMockEventsRepository(ctrl)
	mockCont := cpMock.NewMockContentProcessor(ctrl)
	service := NewEventsService(mockRepo, mockCont)
	ctx := context.Background()
	ctx = context.WithValue(ctx, "headers", headers)
	eventID := uuid.New()

	mockRepo.EXPECT().Delete(ctx, eventID).Return(nil)

	err := service.Delete(ctx, eventID)
	assert.NoError(t, err)
}

func TestEventsService_GetByUserId(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()
	mockRepo := mocks.NewMockEventsRepository(ctrl)
	mockCont := cpMock.NewMockContentProcessor(ctrl)
	service := NewEventsService(mockRepo, mockCont)
	ctx := context.Background()
	ctx = context.WithValue(ctx, "headers", headers)
	eventID := uuid.New()
	ownerId := uuid.New()
	pureEvent := models.PureEvent{
		OwnerId:      ownerId,
		Id:           eventID,
		CoverMediaId: mockMediaId,
		Participants: []uuid.UUID{ownerId},
	}

	expected := []models.PureEvent{{OwnerId: ownerId,
		Id:           eventID,
		CoverMediaId: mockMediaId,
		Participants: []uuid.UUID{ownerId},
		CoverMedia:   mockMedia[mockMediaId]},
	}

	mockCont.EXPECT().SetHeaders(headers).Return()
	mockCont.EXPECT().GetMedia(ctx, []uuid.UUID{mockMediaId}).Return(mockMedia, nil)
	mockRepo.EXPECT().GetByUserId(ctx, ownerId).Return([]models.PureEvent{pureEvent}, nil)

	result, err := service.GetByUserId(ctx, ownerId)
	assert.NoError(t, err)
	assert.Equal(t, expected, result)
}
