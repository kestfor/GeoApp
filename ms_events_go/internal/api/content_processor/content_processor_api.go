package content_processor

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"github.com/google/uuid"
	"io"
	"net/http"
)

type Response interface {
	GetAllMedia() ([]uuid.UUID, []map[string]any)
	GetCoverMedia() (uuid.UUID, map[string]any)
	GetMediaById(mediaId uuid.UUID) map[string]any
}

type ContentProcessorResponse map[uuid.UUID]map[string]any

type ContentProcessor interface {
	GetMedia(ctx context.Context, ids []uuid.UUID) (Response, error)
	SetHeaders(map[string]string)
}

type ContentProcessorApi struct {
	ApiUrl  string
	headers map[string]string
}

func NewContentProcessorApi(url string) ContentProcessor {
	return &ContentProcessorApi{ApiUrl: url, headers: make(map[string]string)}
}

func (c *ContentProcessorApi) SetHeaders(headers map[string]string) {
	for key, value := range headers {
		c.headers[key] = value
	}
}

func addHeaders(request *http.Request, headers map[string]string) {
	for key, value := range headers {
		request.Header.Set(key, value)
	}
	request.Header.Set("Content-Type", "application/json")
	//TODO add X-Forwarded-Host header
}

func (c *ContentProcessorApi) GetMedia(ctx context.Context, ids []uuid.UUID) (Response, error) {
	// This method should interact with the content processor service to retrieve media details.
	// For now, we return an empty slice and nil error to indicate no media found.

	if len(ids) == 0 {
		return ContentProcessorResponse{}, nil
	}

	body, err := json.Marshal(ids)
	if err != nil {
		return nil, err
	}

	request, err := http.NewRequest(
		http.MethodPost, c.ApiUrl+"/files/info", bytes.NewReader(body),
	)
	if err != nil {
		return nil, err
	}

	request = request.WithContext(ctx)

	addHeaders(request, c.headers)

	client := &http.Client{}
	response, err := client.Do(request)
	if err != nil {
		return nil, err
	}

	defer func(Body io.ReadCloser) {
		if er := Body.Close(); er != nil {
			err = er
		}
	}(response.Body)

	if response.StatusCode != http.StatusOK {
		return nil, errors.New("failed to get media from content processor with status: " + response.Status)
	}

	parsed := make(ContentProcessorResponse)
	var media []map[string]any
	if err := json.NewDecoder(response.Body).Decode(&media); err != nil {
		return nil, err
	}
	for _, m := range media {
		if m["media_id"] == nil {
			return nil, errors.New("media item does not have a media_id field")
		}
		id, ok := m["media_id"].(uuid.UUID)
		if !ok {
			return nil, errors.New("can't convert media item id to uuid")
		}
		parsed[id] = m
	}
	return parsed, nil
}

func (rp ContentProcessorResponse) GetAllMedia() ([]uuid.UUID, []map[string]any) {
	ids := make([]uuid.UUID, 0, len(rp))
	media := make([]map[string]any, len(rp))
	for id, m := range rp {
		ids = append(ids, id)
		media = append(media, m)
	}
	return ids, media
}

func (rp ContentProcessorResponse) GetCoverMedia() (uuid.UUID, map[string]any) {
	for id, media := range rp {
		return id, media
	}
	return uuid.UUID{}, nil
}

func (rp ContentProcessorResponse) GetMediaById(mediaId uuid.UUID) map[string]any {
	item, ok := rp[mediaId]
	if !ok {
		return nil
	}
	return item
}
