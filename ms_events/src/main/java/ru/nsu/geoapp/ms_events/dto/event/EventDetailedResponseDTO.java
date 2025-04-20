package ru.nsu.geoapp.ms_events.dto.event;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import ru.nsu.geoapp.ms_events.dto.media.MediaFileDTO;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Data
@Schema(description = "Detailed form event for responses")
public class EventDetailedResponseDTO {

    @Schema(description = "Event's UUID")
    private UUID eventId;

    @Schema(description = "Event's owner UUID")
    private UUID ownerId;

    @Schema(description = "Name of event", example = "My first post")
    private String name;

    @Schema(description = "Description of the post", example = "Description for my first post")
    private String description;

    @Schema(description = "List of tags to this event", example = "[\"paris\", \"birthday\", \"18\"]")
    private List<String> tags;

    @Schema(description = "Latitude of the event location", example = "42.432864")
    private Double latitude;

    @Schema(description = "Longitude of the event location", example = "57.642354")
    private Double longitude;

    private List<MediaFileDTO> media;

    @Schema(description = "List of UUID of participant-users, associated with this event")
    private List<UUID> participantIds;

    @Schema(description = "Timestamp when event was created", example = "2024-12-03T10:15:30.")
    private LocalDateTime createdAt;

    @Schema(description = "Timestamp when event was updated last time", example = "2024-12-03T12:25:30.")
    private LocalDateTime updatedAt;

    //TODO: add metadata
}