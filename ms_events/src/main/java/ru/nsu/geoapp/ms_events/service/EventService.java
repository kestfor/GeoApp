package ru.nsu.geoapp.ms_events.service;

import lombok.AllArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import ru.nsu.geoapp.ms_events.client.ContentProcessorClient;
import ru.nsu.geoapp.ms_events.dto.event.EventCreateRequestDTO;
import ru.nsu.geoapp.ms_events.dto.event.EventDetailedResponseDTO;
import ru.nsu.geoapp.ms_events.dto.event.EventPureResponseDTO;
import ru.nsu.geoapp.ms_events.dto.event.EventUpdateRequestDTO;
import ru.nsu.geoapp.ms_events.dto.media.MediaFileDTO;
import ru.nsu.geoapp.ms_events.exception.ObjectNotFoundException;
import ru.nsu.geoapp.ms_events.model.Event;
import ru.nsu.geoapp.ms_events.repository.EventRepository;
import ru.nsu.geoapp.ms_events.repository.specification.EventSpecifications;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@AllArgsConstructor(onConstructor = @__(@Autowired))
public class EventService {

    private final EventRepository eventRepository;
    private final ContentProcessorClient contentProcessorClient;

    public EventDetailedResponseDTO createEvent(EventCreateRequestDTO requestDTO) {
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
                .orElseThrow(() -> new ObjectNotFoundException("Couldn't find event by" + eventId));

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
                .orElseThrow(() -> new ObjectNotFoundException("Couldn't find event by" + eventId));
        return mapToDetailedResponseDTO(event);
    }

    public List<EventPureResponseDTO> getPureEventsByOwnerId(
            UUID ownerId,
            String name,
            String description,
            LocalDateTime createdAfter,
            LocalDateTime createdBefore
    ) {
        Specification<Event> spec = Specification.where(EventSpecifications.hasOwnerId(ownerId))
                .and(EventSpecifications.containsName(name))
                .and(EventSpecifications.containsDescription(description))
                .and(EventSpecifications.createdAfter(createdAfter))
                .and(EventSpecifications.createdBefore(createdBefore));

        return eventRepository.findAll(spec).stream()
                .map(this::mapToPureResponseDTO)
                .collect(Collectors.toList());
    }

    public List<EventPureResponseDTO> getPureEventsByUserId(
            UUID userId,
            String name,
            String description,
            LocalDateTime createdAfter,
            LocalDateTime createdBefore
    ) {
        Specification<Event> ownerSpec = EventSpecifications.hasOwnerId(userId);
        Specification<Event> participantSpec = EventSpecifications.hasParticipantId(userId);

        Specification<Event> combinedSpec = ownerSpec.or(participantSpec)
                .and(EventSpecifications.containsName(name))
                .and(EventSpecifications.containsDescription(description))
                .and(EventSpecifications.createdAfter(createdAfter))
                .and(EventSpecifications.createdBefore(createdBefore));

        return eventRepository.findAll(combinedSpec).stream()
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
        dto.setMedia(getMediaObjects(event.getMediaIds()));
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
        dto.setDisplayPhoto(getDisplayPhoto(event));
        return dto;
    }

    private List<MediaFileDTO> getMediaObjects(List<UUID> mediaIds) {
        if (mediaIds.isEmpty()) {
            return List.of();
        }
        ResponseEntity<List<MediaFileDTO>> response = contentProcessorClient.getMediaInfo(mediaIds);
        if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
            return response.getBody();
        }
        return List.of();
    }

    private MediaFileDTO getDisplayPhoto(Event event) {
        if (event.getMediaIds() == null || event.getMediaIds().isEmpty()) {
            return null;
        }
        List<MediaFileDTO> mediaFiles = getMediaObjects(event.getMediaIds());
        for (MediaFileDTO file : mediaFiles) {
            if ("photo".equals(file.getType())) {
                return file;
            }
        }
        return null;
    }
}