package ru.nsu.geoapp.ms_events.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.List;
import java.util.UUID;

@Data
@Schema(description = "Detailed form event with non-required fields for updates")
public class EventUpdateRequestDTO {

    @Schema(description = "Event's owner UUID")
    private UUID ownerId;

    @Size(min = 1, max = 255, message = "The name must be between 3 and 255 characters long")
    @Schema(description = "Name of event", example = "My first post")
    private String name;

    @Size(max = 5000, message = "The description must be less than 5000 characters long")
    @Schema(description = "Description of the post", example = "Description for my first post")
    private String description;

    @Size(max = 100, message = "Event can contains 100 tags maximum")
    @Schema(description = "List of tags to this event", examples = {"paris", "birthday", "18"})
    private List<String> tags;

    @Size(min = -90, max = 90, message = "Latitude must be between -90 and 90")
    @Schema(description = "Latitude of the event location", example = "42.432864")
    private Double latitude;

    @Size(min = -180, max = 180, message = "Longitude must be between -180 and 180")
    @Schema(description = "Longitude of the event location", example = "57.642354")
    private Double longitude;

    @Size(min = 1, max = 10, message = "At least one media file is required to create an event")
    @Schema(description = "List of UUID of media files, associated with this event")
    private List<UUID> mediaIds;

    @Schema(description = "List of UUID of participant-users, associated with this event")
    private List<UUID> participantIds;

    //TODO: add metadata
}