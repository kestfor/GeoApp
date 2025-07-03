package postgres

import (
	"context"
	"errors"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	. "ms_events_go/internal/models"
)

type CommentsRepository struct {
	db *pgxpool.Pool
}

func NewCommentsRepository(connString string) (*CommentsRepository, error) {
	pool, err := pgxpool.New(context.Background(), connString)
	if err != nil {
		return nil, err
	}
	return &CommentsRepository{db: pool}, nil
}

func argsFromComment(comment *Comment) pgx.NamedArgs {
	return pgx.NamedArgs{
		"id":         comment.Id,
		"event_id":   comment.EventId,
		"author_id":  comment.AuthorId,
		"text":       comment.Text,
		"created_at": comment.CreatedAt,
		"updated_at": comment.UpdatedAt,
	}
}

func (r *CommentsRepository) Close() {
	if r.db != nil {
		r.db.Close()
	}
}

func (r *CommentsRepository) GetByEventId(ctx context.Context, eventId uuid.UUID) ([]Comment, error) {
	query := `SELECT id, event_id, author_id, text, created_at, updated_at FROM comment WHERE event_id = @event_id`
	args := pgx.NamedArgs{
		"event_id": eventId,
	}

	rows, err := r.db.Query(ctx, query, args)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	comments := make([]Comment, 0)
	scanComment := Comment{}
	_, err = pgx.ForEachRow(rows, []any{&scanComment.Id, &scanComment.EventId, &scanComment.AuthorId, &scanComment.Text, &scanComment.CreatedAt, &scanComment.UpdatedAt}, func() error {
		newComment := Comment{
			Id:        scanComment.Id,
			EventId:   scanComment.EventId,
			AuthorId:  scanComment.AuthorId,
			Text:      scanComment.Text,
			CreatedAt: scanComment.CreatedAt,
			UpdatedAt: scanComment.UpdatedAt,
		}
		comments = append(comments, newComment)
		return nil
	})
	return comments, err
}

func (r *CommentsRepository) Create(ctx context.Context, comment *Comment) (*Comment, error) {
	query := `insert into comment (event_id, author_id, text, created_at) values (@event_id, @author_id, @text, now()) returning id`
	args := argsFromComment(comment)

	var newId uuid.UUID
	err := r.db.QueryRow(ctx, query, args).Scan(&newId)
	if err != nil {
		return nil, err
	}

	comment.Id = newId
	return comment, nil
}

func (r *CommentsRepository) Update(ctx context.Context, comment *Comment) (*Comment, error) {
	query := `update comment set event_id = @event_id, author_id = @author_id, text = @text, created_at = @created_at, updated_at = @updated_at where id = @id`
	args := argsFromComment(comment)
	_, err := r.db.Exec(ctx, query, args)
	if err != nil {
		return nil, err
	}
	return comment, nil
}

func (r *CommentsRepository) Delete(ctx context.Context, commentId uuid.UUID) error {
	query := `delete from comment where id = @id`
	args := pgx.NamedArgs{
		"id": commentId,
	}

	_, err := r.db.Exec(ctx, query, args)
	if err != nil {
		return err
	}
	return nil
}

func (r *CommentsRepository) GetById(ctx context.Context, commentId uuid.UUID) (*Comment, error) {
	query := `SELECT id, event_id, author_id, text, created_at, updated_at FROM comment WHERE id = @id`
	args := pgx.NamedArgs{
		"id": commentId,
	}

	row := r.db.QueryRow(ctx, query, args)
	comment := &Comment{}
	err := row.Scan(&comment.Id, &comment.EventId, &comment.AuthorId, &comment.Text, &comment.CreatedAt, &comment.UpdatedAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	return comment, nil
}
