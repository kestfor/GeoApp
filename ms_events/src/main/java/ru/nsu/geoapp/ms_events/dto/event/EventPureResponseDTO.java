package ru.nsu.geoapp.ms_events.dto.event;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import ru.nsu.geoapp.ms_events.dto.media.MediaFileDTO;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Data
@Schema(description = "Pure form event for responses")
public class EventPureResponseDTO {
    @Schema(description = "Event UUID")
    private UUID id;

    @Schema(description = "Event's owner UUID")
    private UUID ownerId;

    @Schema(description = "Name of event", example = "My first post")
    private String name;

    @Schema(description = "First 50 chars of description", example = "Description for my first post")
    private String descriptionShort;

//    @Schema(description = "First photo from event", implementation = MediaFileDTO.class)
//    private MediaFileDTO displayPhoto;

    @Schema(description = "First photo from event")
    private Map<String, Object> displayPhoto; // Изменено на Map

    @Schema(description = "Timestamp when event was created", example = "2024-12-03T10:15:30.")
    private LocalDateTime createdAt;

    @Schema(description = "Latitude of the event location", example = "42.432864")
    private Double latitude;

    @Schema(description = "Longitude of the event location", example = "57.642354")
    private Double longitude;

    @Schema(description = "List of UUID of participant-users, associated with this event")
    private List<UUID> participantIds;
}