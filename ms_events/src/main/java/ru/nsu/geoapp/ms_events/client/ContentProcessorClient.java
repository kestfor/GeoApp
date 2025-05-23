package ru.nsu.geoapp.ms_events.client;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import ru.nsu.geoapp.ms_events.dto.media.MediaFileDTO;

import java.util.List;
import java.util.UUID;

@Component
public class ContentProcessorClient {
    private final RestTemplate restTemplate;
    private final String contentProcessorUrl;


    public ContentProcessorClient(RestTemplate restTemplate,
                                  @Value("${content-processor.url}") String contentProcessorUrl
    ) {
        this.restTemplate = restTemplate;
        this.contentProcessorUrl = contentProcessorUrl;
    }

    public ResponseEntity<List<MediaFileDTO>> getMediaInfo(List<UUID> mediaIds, HttpHeaders headers) {
        String url = contentProcessorUrl + "/files/info";
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<List<UUID>> requestEntity = new HttpEntity<>(mediaIds, headers);
        return restTemplate.exchange(
                url,
                HttpMethod.POST,
                requestEntity,
                new ParameterizedTypeReference<List<MediaFileDTO>>() {}
        );
    }
}
