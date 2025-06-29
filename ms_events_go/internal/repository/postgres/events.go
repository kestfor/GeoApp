package postgres

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"log"
	. "ms_events_go/internal/models"
)

type EventsRepository struct {
	db *pgxpool.Pool
}

func NewEventsRepository(connString string) (*EventsRepository, error) {
	pool, err := pgxpool.New(context.Background(), connString)
	if err != nil {
		return nil, err
	}
	return &EventsRepository{db: pool}, nil
}

func (r *EventsRepository) Close() {
	if r.db != nil {
		r.db.Close()
	}
}

func argsFromEvent(event *Event) pgx.NamedArgs {
	return pgx.NamedArgs{
		"id":           event.Id,
		"owner_id":     event.OwnerId,
		"name":         event.Name,
		"description":  event.Description,
		"cover_url":    event.CoverMedia,
		"latitude":     event.Latitude,
		"longitude":    event.Longitude,
		"created_at":   event.CreatedAt,
		"updated_at":   event.UpdatedAt,
		"participants": event.Participants,
		"media_ids":    event.MediaIds,
		"media":        event.Media,
	}
}

func rollbackUnlessCommitted(ctx context.Context, tx pgx.Tx) {
	if err := tx.Rollback(ctx); err != nil && !errors.Is(err, pgx.ErrTxClosed) {
		log.Printf("tx rollback error: %v", err)
	}
}

func (r *EventsRepository) Create(ctx context.Context, event *Event) (*Event, error) {
	queryEvent := `INSERT INTO event (owner_id, name, description, latitude, longitude, created_at)
		VALUES (@owner_id, @name, @description, @latitude, @longitude, now())
			  RETURNING id`

	tx, err := r.db.Begin(ctx)
	defer rollbackUnlessCommitted(ctx, tx)

	if err != nil {
		return nil, err
	}

	args := argsFromEvent(event)

	if err := r.db.QueryRow(context.Background(), queryEvent, args).Scan(&(event.Id)); err != nil {
		return nil, errors.Join(errors.New("failed to scan of new event"), err)
	}

	participantsRows := make([][]any, len(event.Participants))

	// Ensure the owner is included in the participants
	isWithOwner := false

	for i := range event.Participants {
		if event.Participants[i] == event.OwnerId {
			isWithOwner = true
		}
		participantsRows[i] = []any{event.Id, event.Participants[i]}
	}
	if !isWithOwner {
		participantsRows = append(participantsRows, []any{event.Id, event.OwnerId})
	}

	mediaRows := make([][]any, len(event.MediaIds))
	for i := range event.MediaIds {
		mediaRows[i] = []any{event.Id, event.MediaIds[i]}
	}

	_, err = tx.CopyFrom(
		ctx,
		pgx.Identifier{"event_participant"},
		[]string{"event_id", "participant_id"},
		pgx.CopyFromRows(participantsRows),
	)
	if err != nil {
		return nil, errors.Join(err, errors.New("failed to copy participants"))
	}

	_, err = tx.CopyFrom(
		ctx,
		pgx.Identifier{"event_media"},
		[]string{"event_id", "media_id"},
		pgx.CopyFromRows(mediaRows),
	)
	if err != nil {
		return nil, errors.Join(err, errors.New("failed to copy media"))
	}

	return event, tx.Commit(ctx)
}

func (r *EventsRepository) Update(ctx context.Context, event *Event) (*Event, error) {
	query := `UPDATE event SET owner_id = @owner_id, name = @name, description = @description, latitude = @latitude, longitude = @longitude, updated_at = now() WHERE id = @id`

	tx, err := r.db.Begin(ctx)
	defer rollbackUnlessCommitted(ctx, tx)

	if err != nil {
		return nil, err
	}

	args := argsFromEvent(event)

	if _, err := tx.Exec(ctx, query, args); err != nil {
		return nil, err
	}

	_, err = tx.Exec(ctx, `DELETE FROM event_participant WHERE event_id = @id`, pgx.NamedArgs{"id": event.Id})
	if err != nil {
		return nil, err
	}

	_, err = tx.Exec(ctx, `DELETE FROM event_media WHERE event_id = @id`, pgx.NamedArgs{"id": event.Id})
	if err != nil {
		return nil, err
	}

	participantsRows := make([][]any, len(event.Participants))
	for i := range event.Participants {
		participantsRows[i] = []any{event.Id, event.Participants[i]}
	}

	mediaRows := make([][]any, len(event.MediaIds))
	for i := range event.MediaIds {
		mediaRows[i] = []any{event.Id, event.MediaIds[i]}
	}

	if len(participantsRows) > 0 {
		if _, err := tx.CopyFrom(
			ctx,
			pgx.Identifier{"event_participant"},
			[]string{"event_id", "participant_id"},
			pgx.CopyFromRows(participantsRows),
		); err != nil {
			return nil, err
		}
	}

	if len(mediaRows) > 0 {
		if _, err := tx.CopyFrom(
			ctx,
			pgx.Identifier{"event_media"},
			[]string{"event_id", "media_id"},
			pgx.CopyFromRows(mediaRows),
		); err != nil {
			return nil, err
		}
	}

	return event, tx.Commit(ctx)
}

func (r *EventsRepository) Delete(ctx context.Context, eventId uuid.UUID) error {
	query := `DELETE FROM event WHERE id = @id`
	args := pgx.NamedArgs{"id": eventId}

	tx, err := r.db.Begin(ctx)
	defer rollbackUnlessCommitted(ctx, tx)

	if err != nil {
		return err
	}

	if _, err := tx.Exec(ctx, query, args); err != nil {
		return err
	}

	return tx.Commit(ctx)
}

func (r *EventsRepository) GetDetailed(ctx context.Context, eventId uuid.UUID) (*Event, error) {
	query := `SELECT id, owner_id, name, description, latitude, longitude, created_at, updated_at FROM event WHERE id = @id`
	args := pgx.NamedArgs{"id": eventId}

	tx, err := r.db.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer rollbackUnlessCommitted(ctx, tx)

	row := tx.QueryRow(ctx, query, args)

	var event Event
	err = row.Scan(&event.Id, &event.OwnerId, &event.Name, &event.Description,
		&event.Latitude, &event.Longitude, &event.CreatedAt, &event.UpdatedAt)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil // No event found
		}
		return nil, err
	}

	// Fetch participants
	participantsQuery := `SELECT participant_id FROM event_participant WHERE event_id = @id`
	rows, err := tx.Query(ctx, participantsQuery, args)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var participantId uuid.UUID
		if err := rows.Scan(&participantId); err != nil {
			return nil, err
		}
		event.Participants = append(event.Participants, participantId)
	}

	// Fetch media
	mediaQuery := `SELECT media_id FROM event_media WHERE event_id = @id`
	rowsMedia, err := tx.Query(ctx, mediaQuery, args)
	if err != nil {
		return nil, err
	}
	defer rowsMedia.Close()

	for rowsMedia.Next() {
		var mediaId uuid.UUID
		if err := rowsMedia.Scan(&mediaId); err != nil {
			return nil, err
		}
		event.MediaIds = append(event.MediaIds, mediaId)
	}

	return &event, tx.Commit(ctx)
}

func (r *EventsRepository) GetByUserId(ctx context.Context, userId uuid.UUID) ([]PureEvent, error) {
	args := pgx.NamedArgs{"user_id": userId}
	eventsWhereUserIsParticipant :=
		`SELECT e.id,
			   e.owner_id,
			   e.name,
			   e.description,
			   COALESCE(
					   (SELECT jsonb_agg(em.media_id)
						FROM event_media em
						WHERE em.event_id = e.id), '[]'
			   ) AS mediaIds,
			   e.latitude,
			   e.longitude,
			   e.created_at,
			   COALESCE(
					   (SELECT jsonb_agg(ep.participant_id)
						FROM event_participant ep
						WHERE ep.event_id = e.id), '[]'
			   ) AS participants
		FROM event e
		WHERE e.owner_id = @user_id
		   OR EXISTS (
			 SELECT 1
			 FROM event_participant ep
			 WHERE ep.event_id       = e.id
			   AND ep.participant_id = @user_id
		   )
		ORDER BY e.created_at DESC;
		`

	rows, err := r.db.Query(ctx, eventsWhereUserIsParticipant, args)

	if err != nil {
		return nil, err
	}

	defer rows.Close()
	events := make([]PureEvent, 0)
	scanEvent := PureEvent{}
	var coverMediaJSON []byte
	var participantsJSON []byte
	_, err = pgx.ForEachRow(rows, []any{&scanEvent.Id, &scanEvent.OwnerId, &scanEvent.Name, &scanEvent.Description, &coverMediaJSON, &scanEvent.Latitude, &scanEvent.Longitude, &scanEvent.CreatedAt, &participantsJSON}, func() error {
		event := PureEvent{
			Id:          scanEvent.Id,
			OwnerId:     scanEvent.OwnerId,
			Name:        scanEvent.Name,
			Description: scanEvent.Description,
			Latitude:    scanEvent.Latitude,
			Longitude:   scanEvent.Longitude,
			CreatedAt:   scanEvent.CreatedAt,
		}

		if coverMediaJSON != nil {
			var medias []uuid.UUID
			if err := json.Unmarshal(coverMediaJSON, &medias); err != nil {
				return fmt.Errorf("unmarshal coverMedia: %s", err.Error())
			}
			if len(medias) > 0 {
				event.CoverMediaId = medias[0]
			}
		}

		if err := json.Unmarshal(participantsJSON, &event.Participants); err != nil {
			return fmt.Errorf("unmarshal participants: %s", err.Error())
		}

		events = append(events, event)
		return nil
	})

	if err != nil {
		return nil, err
	}

	return events, nil
}
