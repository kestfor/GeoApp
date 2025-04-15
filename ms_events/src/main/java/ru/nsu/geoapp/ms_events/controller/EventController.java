package ru.nsu.geoapp.ms_events.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import ru.nsu.geoapp.ms_events.dto.EventDetailedRequestDTO;
import ru.nsu.geoapp.ms_events.dto.EventDetailedResponseDTO;
import ru.nsu.geoapp.ms_events.dto.EventPureResponseDTO;
import ru.nsu.geoapp.ms_events.dto.EventUpdateRequestDTO;
import ru.nsu.geoapp.ms_events.service.EventService;

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
    @Operation(summary = "Create new event",
            description = "Creates an event based on the transmitted data"
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully"),
            @ApiResponse(responseCode = "400", description = "Invalid request parameters"),
    })
    public EventDetailedResponseDTO createEvent(@Valid @RequestBody EventDetailedRequestDTO requestDTO) {
        return eventService.createEvent(requestDTO);
    }

    @PutMapping("/{eventId}")
    @Operation(summary = "Update event",
            description = "Updates the transmitted event fields by its UUID"
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully"),
            @ApiResponse(responseCode = "400", description = "Invalid request parameters"),
            @ApiResponse(responseCode = "404", description = "Event not found")
    })
    public EventDetailedResponseDTO updateEvent(@PathVariable("eventId") UUID eventId,
                                                @Valid @RequestBody EventUpdateRequestDTO requestDTO
    ) {
        return eventService.updateEvent(eventId, requestDTO);
    }

    @GetMapping("/{eventId}")
    @Operation(summary = "Get detailed event",
            description = "Returns full information about the event by its UUID"
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully"),
            @ApiResponse(responseCode = "404", description = "Event not found")
    })
    public EventDetailedResponseDTO getEventDetailed(@PathVariable("eventId") UUID eventId) {
        return eventService.getEventDetailed(eventId);
    }

    @GetMapping("/{userId}/pure")
    @Operation(summary = "Get pure user events",
            description = "Returns a list of pure events for the specified user by UUID"
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully"),
    })
    public List<EventPureResponseDTO> getPureEventsByUserId(@PathVariable("userId") UUID userId) {
        return eventService.getPureEventsByUserId(userId);
    }

    @DeleteMapping("/{eventId}")
    @Operation(summary = "Delete event",
            description = "Deletes event by it's UUId"
    )
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteEvent(@PathVariable("eventId") UUID eventId) {
        eventService.deleteEvent(eventId);
    }
}
