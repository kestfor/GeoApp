package ru.nsu.geoapp.ms_events.service;

import lombok.AllArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;
import ru.nsu.geoapp.ms_events.client.ContentProcessorClient;
import ru.nsu.geoapp.ms_events.client.kafka.messages.PostCreatedMessage;
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
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;
import java.util.Map;

@Service
@AllArgsConstructor(onConstructor = @__(@Autowired))
public class EventService {

    private final EventRepository eventRepository;
    private final ContentProcessorClient contentProcessorClient;
    private final KafkaTemplate<String, PostCreatedMessage> kafkaTemplate;

    public EventDetailedResponseDTO createEvent(EventCreateRequestDTO requestDTO, HttpHeaders headers) {
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

        CompletableFuture<SendResult<String, PostCreatedMessage>> future = kafkaTemplate.send("post.events", savedEvent.getId().toString(), mapToPostCreatedMessage(event));

        future.whenComplete((result, ex) -> {
            if (ex == null) {
                System.out.println("INFO Message sent to topic 'posts.events' with eventId: " + savedEvent.getId().toString());
            } else {
                System.out.println("ERROR Error sending message with eventId: " + savedEvent.getId().toString() + ", error:" + ex.getMessage());
            }
        });

        return mapToDetailedResponseDTO(savedEvent, headers);
    }

    public EventDetailedResponseDTO updateEvent(UUID eventId, EventUpdateRequestDTO requestDTO, HttpHeaders headers) {
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
        return mapToDetailedResponseDTO(updatedEvent, headers);
    }

    public EventDetailedResponseDTO getEventDetailed(UUID eventId, HttpHeaders headers) {
        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new ObjectNotFoundException("Couldn't find event by" + eventId));
        return mapToDetailedResponseDTO(event, headers);
    }

    public List<EventPureResponseDTO> getPureEventsByOwnerId(
            UUID ownerId,
            String name,
            String description,
            LocalDateTime createdAfter,
            LocalDateTime createdBefore,
            HttpHeaders headers
    ) {
        Specification<Event> spec = Specification.where(EventSpecifications.hasOwnerId(ownerId))
                .and(EventSpecifications.containsName(name))
                .and(EventSpecifications.containsDescription(description))
                .and(EventSpecifications.createdAfter(createdAfter))
                .and(EventSpecifications.createdBefore(createdBefore));

        return eventRepository.findAll(spec).stream()
                .map(event -> mapToPureResponseDTO(event, headers)) // Передача заголовков
                .collect(Collectors.toList());
    }

    public List<EventPureResponseDTO> getPureEventsByUserId(
            UUID userId,
            String name,
            String description,
            LocalDateTime createdAfter,
            LocalDateTime createdBefore,
            HttpHeaders headers
    ) {
        Specification<Event> ownerSpec = EventSpecifications.hasOwnerId(userId);
        Specification<Event> participantSpec = EventSpecifications.hasParticipantId(userId);

        Specification<Event> combinedSpec = ownerSpec.or(participantSpec)
                .and(EventSpecifications.containsName(name))
                .and(EventSpecifications.containsDescription(description))
                .and(EventSpecifications.createdAfter(createdAfter))
                .and(EventSpecifications.createdBefore(createdBefore));

        return eventRepository.findAll(combinedSpec).stream()
                .map(event -> mapToPureResponseDTO(event, headers)) // Передача заголовков
                .collect(Collectors.toList());
    }

    public void deleteEvent(UUID eventId) {
        eventRepository.deleteById(eventId);
    }

    private PostCreatedMessage mapToPostCreatedMessage(Event event) {
        return new PostCreatedMessage(event.getOwnerId().toString(),
                "",
                event.getId().toString(),
                event.getName(),
                event.getDescription(),
                event.getParticipantIds().stream().map(UUID::toString).toList());
    }

    private EventDetailedResponseDTO mapToDetailedResponseDTO(Event event, HttpHeaders headers) {
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
        dto.setMedia(getMediaObjects(event.getMediaIds(), headers));
        return dto;
    }

    private EventPureResponseDTO mapToPureResponseDTO(Event event, HttpHeaders headers) {
        EventPureResponseDTO dto = new EventPureResponseDTO();
        dto.setId(event.getId());
        dto.setOwnerId(event.getOwnerId());
        dto.setName(event.getName());
        dto.setDescriptionShort(event.getDescription() != null ?
                event.getDescription().substring(0, Math.min(50, event.getDescription().length())) : "");
        dto.setCreatedAt(event.getCreatedAt());
        dto.setDisplayPhoto(getDisplayPhoto(event, headers));
        dto.setLatitude(event.getLatitude());
        dto.setLongitude(event.getLongitude());
        dto.setParticipantIds(event.getParticipantIds());
        return dto;
    }

    private List<Map<String, Object>> getMediaObjects(List<UUID> mediaIds, HttpHeaders headers) { // Изменен тип
        if (mediaIds == null || mediaIds.isEmpty()) {
            return List.of();
        }
        ResponseEntity<List<Map<String, Object>>> response = contentProcessorClient.getMediaInfo(mediaIds, headers); // Изменен тип
        if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
            return response.getBody();
        }
        return List.of();
    }

    private Map<String, Object> getDisplayPhoto(Event event, HttpHeaders headers) { // Изменен тип
        if (event.getMediaIds() == null || event.getMediaIds().isEmpty()) {
            return null;
        }
        List<Map<String, Object>> mediaFiles = getMediaObjects(event.getMediaIds(), headers); // Изменен тип
        if (!mediaFiles.isEmpty()) {
            return mediaFiles.get(0); // Берем первый элемент
        }
        return null;
    }
}