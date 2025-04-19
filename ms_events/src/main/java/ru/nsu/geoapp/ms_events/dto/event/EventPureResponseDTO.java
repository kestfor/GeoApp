package ru.nsu.geoapp.ms_events.dto.event;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;
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

    @Schema(description = "Timestamp when event was created", example = "2024-12-03T10:15:30.")
    private LocalDateTime createdAt;

    //TODO: add display_photo after integration
}