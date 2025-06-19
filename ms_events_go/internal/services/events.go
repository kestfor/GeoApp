package services

import (
	"context"
	. "ms_events_go/internal/models"
	. "ms_events_go/internal/repository"
)

type EventsService struct {
	eventsRepository EventsRepository
}

func NewEventsService(eventsRepository EventsRepository) *EventsService {
	return &EventsService{
		eventsRepository: eventsRepository,
	}
}

func (s *EventsService) GetDetailed(ctx context.Context, eventId string) (*Event, error) {
	return s.eventsRepository.GetDetailed(ctx, eventId)
}

func (s *EventsService) Create(ctx context.Context, event *Event) (*Event, error) {
	return s.eventsRepository.Create(ctx, event)
}

func (s *EventsService) Update(ctx context.Context, event *Event) (*Event, error) {
	return s.eventsRepository.Update(ctx, event)
}

func (s *EventsService) Delete(ctx context.Context, eventId string) error {
	return s.eventsRepository.Delete(ctx, eventId)
}

func (s *EventsService) GetByUserId(ctx context.Context, userId string) ([]PureEvent, error) {
	return s.eventsRepository.GetByUserId(ctx, userId)
}
