package services

import (
	"context"
	"errors"
	"fmt"
	"github.com/google/uuid"
	"ms_events_go/internal/api/content_processor"
	. "ms_events_go/internal/models"
	. "ms_events_go/internal/repository"
	"os"
)

type EventsService struct {
	eventsRepository    EventsRepository
	contentProcessorUrl string
}

func NewEventsService(eventsRepository EventsRepository) *EventsService {
	return &EventsService{
		eventsRepository:    eventsRepository,
		contentProcessorUrl: os.Getenv("CONTENT_PROCESSOR_URL"),
	}
}

func (s *EventsService) GetDetailed(ctx context.Context, eventId uuid.UUID) (*Event, error) {
	event, err := s.eventsRepository.GetDetailed(ctx, eventId)
	if err != nil {
		return nil, err
	}
	if err := s.setMedia(ctx, event); err != nil {
		return nil, err
	}
	return event, nil
}

func (s *EventsService) Create(ctx context.Context, event *Event) (*Event, error) {
	event, err := s.eventsRepository.Create(ctx, event)
	if err != nil {
		return nil, err
	}
	if err := s.setMedia(ctx, event); err != nil {
		return nil, err
	}
	return event, err
}

func (s *EventsService) Update(ctx context.Context, event *Event) (*Event, error) {
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

func (s *EventsService) GetByUserId(ctx context.Context, userId uuid.UUID) ([]PureEvent, error) {
	events, err := s.eventsRepository.GetByUserId(ctx, userId)
	if err != nil {
		return nil, err

	}
	covers := make([]uuid.UUID, 0, len(events))
	for _, event := range events {
		covers = append(covers, event.CoverMediaId)
	}

	medias, err := s.getMedia(ctx, covers)
	if err != nil {
		return nil, err
	}

	for i := range events {
		events[i].CoverMedia = medias[events[i].CoverMediaId]
		if events[i].CoverMedia == nil {
			return nil, errors.New(fmt.Sprintf("cover media with id [%s] not found", events[i].CoverMediaId))
		}
	}

	return events, err
}

func (s *EventsService) setMedia(ctx context.Context, event *Event) error {
	if len(event.MediaIds) == 0 {
		return errors.New("cannot get media: event does not have mediaIds")
	}

	headers, ok := ctx.Value("headers").(map[string]string)
	if !ok {
		return errors.New("context does not contain headers")
	}

	contentProcessorApi := content_processor.NewContentProcessorApi(s.contentProcessorUrl)
	contentProcessorApi.SetHeaders(headers)
	media, err := contentProcessorApi.GetMedia(event.MediaIds)
	if err != nil {
		return err
	}

	if len(media) == 0 {
		return errors.New(fmt.Sprintf("no media found for the provided mediaIds: [%v]", event.MediaIds))
	}

	event.CoverMediaId = media[0]["media_id"].(uuid.UUID)
	event.Media = media
	return s.setCoverMediaFromJson(event, media)
}

func (s *EventsService) setCoverMediaFromJson(event *Event, json []map[string]any) error {
	if len(json) == 0 {
		return errors.New(fmt.Sprintf("no media found for the provided coverMediaId: [%s]", event.CoverMediaId))
	}

	var file map[string]any
	for _, f := range json {
		if f["media_id"] == event.CoverMediaId {
			file = f
		}
	}

	if file == nil {
		return errors.New(fmt.Sprintf("media with id [%s] not found in the provided media list", event.CoverMediaId))
	}

	event.CoverMedia = file
	return nil

}

func (s *EventsService) getMedia(ctx context.Context, ids []uuid.UUID) (map[uuid.UUID]map[string]any, error) {
	headers, ok := ctx.Value("headers").(map[string]string)
	if !ok {
		return nil, errors.New("context does not contain headers")
	}

	contentProcessorApi := content_processor.NewContentProcessorApi(s.contentProcessorUrl)
	contentProcessorApi.SetHeaders(headers)
	media, err := contentProcessorApi.GetMedia(ids)
	if err != nil {
		return nil, err
	}

	res := make(map[uuid.UUID]map[string]any)
	for _, m := range media {
		if m["media_id"] == nil {
			return nil, errors.New("media item does not have a media_id field")
		}
		res[m["media_id"].(uuid.UUID)] = m
	}
	return res, nil
}

//func (s *EventsService) setCoverMedia(ctx context.Context, event *Event) error {
//	if event.CoverMediaId == "" {
//		return errors.New("cannot get cover media: event does not have a coverMediaId")
//	}
//
//	headers, ok := ctx.Value("headers").(map[string]string)
//	if !ok {
//		return errors.New("context does not contain headers")
//	}
//
//	contentProcessorApi := content_processor.NewContentProcessorApi(s.contentProcessorUrl)
//	contentProcessorApi.SetHeaders(headers)
//	media, err := contentProcessorApi.GetMedia([]string{event.CoverMediaId})
//	if err != nil {
//		return err
//	}
//
//	return s.setCoverMediaFromJson(event, media)
//
//}
