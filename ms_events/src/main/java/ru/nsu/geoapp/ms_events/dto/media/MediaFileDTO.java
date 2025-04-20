package ru.nsu.geoapp.ms_events.dto.media;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.List;
import java.util.Map;

@Data
public class MediaFileDTO {
    private String type;

    @JsonProperty("media_id")
    private String mediaId;

    @JsonProperty("author_id")
    private int authorId;
    private Map<String, Object> metadata;
    private Map<String, RepresentationDTO> representations;

    @Data
    public static class RepresentationDTO {
        private String variant;
        private String url;
        private long fileSizeBytes;
    }
}


