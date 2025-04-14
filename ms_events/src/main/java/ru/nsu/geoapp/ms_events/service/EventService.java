package ru.nsu.geoapp.ms_events.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import ru.nsu.geoapp.ms_events.dto.EventPureDTO;
import ru.nsu.geoapp.ms_events.model.Event;
import ru.nsu.geoapp.ms_events.repository.EventRepository;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class EventService {

    @Autowired
    private EventRepository eventRepository;

    public List<EventPureDTO> getPureEventsByUserId(UUID userId) {
        List<Event> events = eventRepository.findByOwnerId(userId);
        return events.stream().map(this::mapToPureDTO).collect(Collectors.toList());
    }

    private EventPureDTO mapToPureDTO(Event event) {
        EventPureDTO dto = new EventPureDTO();
        dto.setId(event.getId());
        dto.setOwnerId(event.getOwnerId());
        dto.setName(event.getName());
        dto.setDescriptionShort(event.getDescription() != null
                ? event.getDescription().substring(0, Math.min(50, event.getDescription().length()))
                : "");
        dto.setCreatedAt(event.getCreatedAt());
        return dto;
    }

    public Event createEvent(Event event) {
        return eventRepository.save(event);
    }
}