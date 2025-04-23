package ru.nsu.geoapp.ms_events.dto.media;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.util.Map;
import java.util.UUID;

@Data
@Schema(description = "Media objects got from ContentProcessor")
public class MediaFileDTO {

    @Schema(description = "Type of media", example = "Photo")
    private String type;

    @JsonProperty("media_id")
    @Schema(description = "Media UUID")
    private UUID mediaId;

    @JsonProperty("author_id")
    @Schema(description = "Author Id (int??)")
    private int authorId;

    @Schema(description = "Meta information")
    private Map<String, Object> metadata;

    @Schema(description = "Different representations od object")
    private Map<String, RepresentationDTO> representations;

    @Data
    @Schema(description = "Representation object")
    public static class RepresentationDTO {
        @Schema(description = "Variant")
        private String variant;

        @Schema(description = "URL to file")
        private String url;

        @Schema(description = "File size in bytes")
        private long fileSizeBytes;
    }
}


