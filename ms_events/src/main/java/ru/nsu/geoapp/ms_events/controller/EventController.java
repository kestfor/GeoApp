package ru.nsu.geoapp.ms_events.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import ru.nsu.geoapp.ms_events.dto.EventPureDTO;
import ru.nsu.geoapp.ms_events.model.Event;
import ru.nsu.geoapp.ms_events.service.EventService;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api")
public class EventController {

    @Autowired
    private EventService eventService;

    @GetMapping("/users/{userId}/events/pure")
    public List<EventPureDTO> getPureEvents(@PathVariable UUID userId) {
        return eventService.getPureEventsByUserId(userId);
    }

    @PostMapping("/events")
    public Event createEvent(@RequestBody Event event) {
        return eventService.createEvent(event);
    }
}
