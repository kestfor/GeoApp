package ru.nsu.geoapp.ms_events.dto.event;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.*;
import lombok.Data;

import java.util.List;
import java.util.UUID;

@Data
@Schema(description = "Detailed form event for requests")
public class EventCreateRequestDTO {

    @NotNull
    @Schema(description = "Event's owner UUID", requiredMode = Schema.RequiredMode.REQUIRED)
    private UUID ownerId;

    @NotBlank
    @Size(min = 1, max = 255, message = "The name must be between 1 and 255 characters long")
    @Schema(description = "Name of event", example = "My first post", requiredMode = Schema.RequiredMode.REQUIRED)
    private String name;

    @Size(max = 5000, message = "The description must be less than 5000 characters long")
    @Schema(description = "Description of the post", example = "Description for my first post")
    private String description;

    @Size(max = 100, message = "Event can contains 100 tags maximum")
    @Schema(description = "List of tags to this event", example = "[\"paris\", \"birthday\", \"18\"]")
    private List<String> tags;

    @NotNull
    @DecimalMin(value = "-90.0", message = "Latitude must be >= -90")
    @DecimalMax(value = "90.0", message = "Latitude must be <= 90")
    @Schema(description = "Latitude of the event location", example = "42.432864", requiredMode = Schema.RequiredMode.REQUIRED)
    private Double latitude;

    @NotNull
    @DecimalMin(value = "-180.0", message = "Longitude must be >= -180")
    @DecimalMax(value = "180.0", message = "Longitude must be <= 180")
    @Schema(description = "Longitude of the event location", example = "57.642354", requiredMode = Schema.RequiredMode.REQUIRED)
    private Double longitude;

    @NotNull
    @Size(min = 1, max = 10, message = "At least one media file is required to create an event")
    @Schema(description = "List of UUID of media files, associated with this event",
            requiredMode = Schema.RequiredMode.REQUIRED,
            example = """
                          [
                            "ef295653-3d7b-4f5c-8ca9-4fcd1b6ee1be",
                            "04c13e3c-030b-4ec1-b041-b98810bd4b80"
                          ]
                    """
    )
    private List<UUID> mediaIds;

    @Schema(description = "List of UUID of participant-users, associated with this event")
    private List<UUID> participantIds;

    //TODO: add metadata
}
