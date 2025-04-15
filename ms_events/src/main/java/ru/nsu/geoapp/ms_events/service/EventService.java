package ru.nsu.geoapp.ms_events.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import ru.nsu.geoapp.ms_events.dto.EventDetailedRequestDTO;
import ru.nsu.geoapp.ms_events.dto.EventDetailedResponseDTO;
import ru.nsu.geoapp.ms_events.dto.EventPureResponseDTO;
import ru.nsu.geoapp.ms_events.dto.EventUpdateRequestDTO;
import ru.nsu.geoapp.ms_events.exception.EventNotFoundException;
import ru.nsu.geoapp.ms_events.model.Event;
import ru.nsu.geoapp.ms_events.repository.EventRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class EventService {

    private final EventRepository eventRepository;

    @Autowired
    public EventService(EventRepository eventRepository) {
        this.eventRepository = eventRepository;
    }

    public EventDetailedResponseDTO createEvent(EventDetailedRequestDTO requestDTO) {
        Event event = new Event();
        event.setOwnerId(requestDTO.getOwnerId());
        event.setName(requestDTO.getName());
        event.setDescription(requestDTO.getDescription());
        event.setTags(requestDTO.getTags());
        event.setLatitude(requestDTO.getLatitude());
        event.setLongitude(requestDTO.getLongitude());
        event.setMediaIds(requestDTO.getMediaIds());
        event.setParticipantIds(requestDTO.getParticipantIds());
        event.setCreatedAt(LocalDateTime.now());
        event.setUpdatedAt(LocalDateTime.now());

        Event savedEvent = eventRepository.save(event);
        return mapToDetailedResponseDTO(savedEvent);
    }

    public EventDetailedResponseDTO updateEvent(UUID eventId, EventUpdateRequestDTO requestDTO) {
        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new EventNotFoundException("Couldn't find event by" + eventId));

        if (requestDTO.getOwnerId() != null) {
            event.setOwnerId(requestDTO.getOwnerId());
        }
        if (requestDTO.getName() != null) {
            event.setName(requestDTO.getName());
        }
        if (requestDTO.getDescription() != null) {
            event.setDescription(requestDTO.getDescription());
        }
        if (requestDTO.getTags() != null) {
            event.setTags(requestDTO.getTags());
        }
        if (requestDTO.getLatitude() != null) {
            event.setLatitude(requestDTO.getLatitude());
        }
        if (requestDTO.getLongitude() != null) {
            event.setLongitude(requestDTO.getLongitude());
        }
        if (requestDTO.getMediaIds() != null) {
            event.setMediaIds(requestDTO.getMediaIds());
        }
        if (requestDTO.getParticipantIds() != null) {
            event.setParticipantIds(requestDTO.getParticipantIds());
        }
        event.setUpdatedAt(LocalDateTime.now());

        Event updatedEvent = eventRepository.save(event);
        return mapToDetailedResponseDTO(updatedEvent);
    }


    public EventDetailedResponseDTO getEventDetailed(UUID eventId) {
        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new EventNotFoundException("Couldn't find event by" + eventId));
        return mapToDetailedResponseDTO(event);
    }

    public List<EventPureResponseDTO> getPureEventsByUserId(UUID userId) {
        List<Event> events = eventRepository.findByOwnerId(userId);

        return events.stream()
                .map(this::mapToPureResponseDTO)
                .collect(Collectors.toList());
    }

    public void deleteEvent(UUID eventId) {
        eventRepository.deleteById(eventId);
    }

    private EventDetailedResponseDTO mapToDetailedResponseDTO(Event event) {
        EventDetailedResponseDTO dto = new EventDetailedResponseDTO();
        dto.setEventId(event.getId());
        dto.setOwnerId(event.getOwnerId());
        dto.setName(event.getName());
        dto.setDescription(event.getDescription());
        dto.setTags(event.getTags());
        dto.setLatitude(event.getLatitude());
        dto.setLongitude(event.getLongitude());
        dto.setParticipantIds(event.getParticipantIds());
        dto.setCreatedAt(event.getCreatedAt());
        dto.setUpdatedAt(event.getUpdatedAt());
        // TODO: Добавить логику для получения media objects
        return dto;
    }

    private EventPureResponseDTO mapToPureResponseDTO(Event event) {
        EventPureResponseDTO dto = new EventPureResponseDTO();
        dto.setId(event.getId());
        dto.setOwnerId(event.getOwnerId());
        dto.setName(event.getName());
        dto.setDescriptionShort(event.getDescription() != null ?
                event.getDescription().substring(0, Math.min(50, event.getDescription().length())) : "");
        dto.setCreatedAt(event.getCreatedAt());
        // TODO: Добавить логику для получения display_photo
        return dto;
    }
}