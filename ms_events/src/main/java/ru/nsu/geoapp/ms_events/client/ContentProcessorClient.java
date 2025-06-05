package ru.nsu.geoapp.ms_events.client;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import ru.nsu.geoapp.ms_events.dto.media.MediaFileDTO;

import java.util.List;
import java.util.Map;
import java.util.Objects;
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

    public ResponseEntity<List<Map<String, Object>>> getMediaInfo(List<UUID> mediaIds, HttpHeaders headers) { // Изменен тип возврата
        String url = contentProcessorUrl + "/files/info";
        HttpHeaders newHeaders = new HttpHeaders();
        newHeaders.putAll(headers);
        newHeaders.remove("content-length");
        newHeaders.remove("user-agent");
        //TODO фиксануть костылькос
        newHeaders.put("X-Forwarded-Host", Objects.requireNonNull(headers.get("host")));
        HttpEntity<List<UUID>> requestEntity = new HttpEntity<>(mediaIds, newHeaders);
        return restTemplate.exchange(
                url,
                HttpMethod.POST,
                requestEntity,
                new ParameterizedTypeReference<List<MediaFileDTO>>() {
                }
        );
    }
}
