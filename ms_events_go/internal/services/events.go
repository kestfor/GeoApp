package services

import (
	"context"
	"errors"
	"fmt"
	"github.com/google/uuid"
	cp "ms_events_go/internal/api/content_processor"
	"ms_events_go/internal/models"
	"ms_events_go/internal/repository"
)

type EventsService struct {
	eventsRepository repository.EventsRepository
	contentProcessor cp.ContentProcessor
}

func NewEventsService(eventsRepository repository.EventsRepository, processor cp.ContentProcessor) *EventsService {
	return &EventsService{
		eventsRepository: eventsRepository,
		contentProcessor: processor,
	}
}

func (s *EventsService) GetDetailed(ctx context.Context, eventId uuid.UUID) (*models.Event, error) {
	event, err := s.eventsRepository.GetDetailed(ctx, eventId)
	if err != nil {
		return nil, err
	}
	if err := s.setMedia(ctx, event); err != nil {
		return nil, err
	}
	return event, nil
}

func (s *EventsService) Create(ctx context.Context, event *models.Event) (*models.Event, error) {
	event, err := s.eventsRepository.Create(ctx, event)
	if err != nil {
		return nil, err
	}
	if err := s.setMedia(ctx, event); err != nil {
		return nil, err
	}
	return event, err
}

func (s *EventsService) Update(ctx context.Context, event *models.Event) (*models.Event, error) {
	event, err := s.eventsRepository.Update(ctx, event)
	if err != nil {
		return nil, err
	}
	if err := s.setMedia(ctx, event); err != nil {
		return nil, err
	}
	return event, err
}

func (s *EventsService) Delete(ctx context.Context, eventId uuid.UUID) error {
	return s.eventsRepository.Delete(ctx, eventId)
}

func (s *EventsService) GetByUserId(ctx context.Context, userId uuid.UUID) ([]models.PureEvent, error) {
	events, err := s.eventsRepository.GetByUserId(ctx, userId)
	if err != nil {
		return nil, err
	}
	headers, ok := ctx.Value("headers").(map[string]string)
	if !ok {
		return nil, errors.New("context does not contain headers")
	}

	s.contentProcessor.SetHeaders(headers)

	//covers from all events group in one request, so it is important to check order of response
	covers := make([]uuid.UUID, 0, len(events))
	for _, event := range events {
		covers = append(covers, event.CoverMediaId)
	}

	medias, err := s.contentProcessor.GetMedia(ctx, covers)
	if err != nil {
		return nil, err
	}

	for i := range events {
		coverId := events[i].CoverMediaId
		cover := medias.GetMediaById(coverId)
		if cover == nil {
			return nil, fmt.Errorf("cover media with id [%s] not found", events[i].CoverMediaId)
		}
		events[i].CoverMedia = cover
	}

	return events, err
}

func (s *EventsService) setMedia(ctx context.Context, event *models.Event) error {
	if len(event.MediaIds) == 0 {
		return errors.New("cannot get media: event does not have mediaIds")
	}

	headers, ok := ctx.Value("headers").(map[string]string)
	if !ok {
		return errors.New("context does not contain headers")
	}

	s.contentProcessor.SetHeaders(headers)
	media, err := s.contentProcessor.GetMedia(ctx, event.MediaIds)
	if err != nil {
		return err
	}

	setCoverMedia(event, media)
	setMedia(event, media)
	return nil
}

func setCoverMedia(event *models.Event, response cp.Response) {
	event.CoverMediaId, event.CoverMedia = response.GetCoverMedia()
}

func setMedia(event *models.Event, response cp.Response) {
	event.MediaIds, event.Media = response.GetAllMedia()
}
