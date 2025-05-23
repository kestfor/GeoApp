package ru.nsu.geoapp.ms_events.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import ru.nsu.geoapp.ms_events.dto.error.NotFoundErrorDTO;
import ru.nsu.geoapp.ms_events.dto.error.ValidationErrorDTO;
import ru.nsu.geoapp.ms_events.dto.event.EventCreateRequestDTO;
import ru.nsu.geoapp.ms_events.dto.event.EventDetailedResponseDTO;
import ru.nsu.geoapp.ms_events.dto.event.EventPureResponseDTO;
import ru.nsu.geoapp.ms_events.dto.event.EventUpdateRequestDTO;
import ru.nsu.geoapp.ms_events.service.EventService;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/events")
@Tag(name = "Events", description = "API for event management")
public class EventController {

    private final EventService eventService;

    @Autowired
    public EventController(EventService eventService) {
        this.eventService = eventService;
    }


    @PostMapping
    @Operation(
            summary = "Create new event",
            description = "Creates an event based on the transmitted data"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "201",
                    description = "Successfully",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = EventDetailedResponseDTO.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Invalid input data",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = ValidationErrorDTO.class)
                    )
            ),
    })
    @ResponseStatus(HttpStatus.CREATED)
    public EventDetailedResponseDTO createEvent(@Valid @RequestBody EventCreateRequestDTO requestDTO) {
        return eventService.createEvent(requestDTO);
    }


    @PutMapping("/{event_id}")
    @Operation(
            summary = "Update event",
            description = "Updates the transmitted event fields by its UUID"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Successfully",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = EventDetailedResponseDTO.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Invalid request parameters",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = ValidationErrorDTO.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Event not found",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = NotFoundErrorDTO.class)
                    )
            )
    })
    public EventDetailedResponseDTO updateEvent(@PathVariable("event_id") UUID eventId,
                                                @Valid @RequestBody EventUpdateRequestDTO requestDTO
    ) {
        return eventService.updateEvent(eventId, requestDTO);
    }


    @GetMapping("/{eventId}")
    @Operation(
            summary = "Get detailed event",
            description = "Returns full information about the event by its UUID"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Successfully",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = EventDetailedResponseDTO.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Event not found",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = NotFoundErrorDTO.class)
                    )
            )
    })
    public EventDetailedResponseDTO getEventDetailed(@PathVariable("eventId") UUID eventId) {
        return eventService.getEventDetailed(eventId);
    }


    @GetMapping("/{user_id}/pure")
    @Operation(
            summary = "Get pure user events",
            description = "Returns a list of pure events for the specified user by UUID"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    content = @Content(
                            mediaType = "application/json",
                            array = @ArraySchema(schema = @Schema(implementation = EventPureResponseDTO.class))
                    )
            )
    })
    public List<EventPureResponseDTO> getPureEventsByUserId(
            @PathVariable("user_id") @Parameter(description = "User UUID")
            UUID userId,
            @RequestParam(value = "name", required = false)
            @Parameter(description = "Name filter")
            String name,
            @RequestParam(value = "description", required = false)
            @Parameter(description = "Description filter")
            String description,
            @RequestParam(value = "createdAfter", required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            @Parameter(description = "Minimum creation date", example = "2025-04-01T00:00:00")
            LocalDateTime createdAfter,
            @RequestParam(value = "createdBefore", required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            @Parameter(description = "Maximum creation date", example = "2025-04-30T23:59:59")
            LocalDateTime createdBefore
    ) {
        return eventService.getPureEventsByUserId(userId, name, description, createdAfter, createdBefore);
    }


    @DeleteMapping("/{event_id}")
    @Operation(
            summary = "Delete event",
            description = "Deletes event by it's UUId"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "204",
                    description = "Event successfully deleted"
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Event not found",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = NotFoundErrorDTO.class)
                    )
            )
    })
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteEvent(@PathVariable("event_id") UUID eventId) {
        eventService.deleteEvent(eventId);
    }
}
