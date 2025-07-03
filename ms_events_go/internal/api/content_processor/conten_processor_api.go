package content_processor

import (
	"bytes"
	"encoding/json"
	"errors"
	"github.com/google/uuid"
	"net/http"
)

type ContentProcessorApi struct {
	ApiUrl  string
	headers map[string]string
}

func NewContentProcessorApi(url string) *ContentProcessorApi {
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

func (c *ContentProcessorApi) GetMedia(ids []uuid.UUID) ([]map[string]any, error) {
	// This method should interact with the content processor service to retrieve media details.
	// For now, we return an empty slice and nil error to indicate no media found.

	if len(ids) == 0 {
		return []map[string]any{}, nil
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

	addHeaders(request, c.headers)

	client := &http.Client{}
	response, err := client.Do(request)
	if err != nil {
		return nil, err
	}

	defer response.Body.Close()

	if response.StatusCode != http.StatusOK {
		return nil, errors.New("failed to get media from content processor with status: " + response.Status)
	}

	var media []map[string]any
	if err := json.NewDecoder(response.Body).Decode(&media); err != nil {
		return nil, err
	}
	return media, nil
}
