package ru.nsu.geoapp.ms_events.service;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
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

@Slf4j
@Service
@AllArgsConstructor(onConstructor = @__(@Autowired))
public class EventService {

    private final EventRepository eventRepository;
    private final ContentProcessorClient contentProcessorClient;
    private final KafkaTemplate<String, PostCreatedMessage> kafkaTemplate;

    public EventDetailedResponseDTO createEvent(EventCreateRequestDTO requestDTO, HttpHeaders headers) {
        log.info("Creating new event for owner: {}", requestDTO.getOwnerId());
        log.debug("Event details - Name: {}, Description length: {}, Media count: {}",
                requestDTO.getName(),
                requestDTO.getDescription() != null ? requestDTO.getDescription().length() : 0,
                requestDTO.getMediaIds() != null ? requestDTO.getMediaIds().size() : 0);

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
        log.info("Event created successfully [ID: {}, Owner: {}]", savedEvent.getId(), savedEvent.getOwnerId());

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
        log.info("Updating event: {}", eventId);
        try {
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
            log.info("Event updated [ID: {}]", eventId);
            return mapToDetailedResponseDTO(updatedEvent, headers);

        } catch (ObjectNotFoundException ex) {
            throw ex;
        } catch (Exception ex) {
            log.error("Event update failed [{}]: {}", eventId, ex.getMessage(), ex);
            throw ex;
        }
    }

    public EventDetailedResponseDTO getEventDetailed(UUID eventId, HttpHeaders headers) {
        log.debug("Fetching detailed event: {}", eventId);
        try {
            Event event = eventRepository.findById(eventId)
                    .orElseThrow(() -> {
                        log.warn("Event not found: {}", eventId);
                        return new ObjectNotFoundException("Event not found: " + eventId);
                    });

            log.info("Returning detailed event [ID: {}, Name: {}]", eventId, event.getName());
            return mapToDetailedResponseDTO(event, headers);
        } catch (Exception ex) {
            log.error("Failed to get event [{}]: {}", eventId, ex.getMessage(), ex);
            throw ex;
        }
    }

    public List<EventPureResponseDTO> getPureEventsByOwnerId(
            UUID ownerId,
            String name,
            String description,
            LocalDateTime createdAfter,
            LocalDateTime createdBefore,
            HttpHeaders headers
    ) {
        log.debug("Fetching pure events for owner: {}", ownerId);
        log.trace("Filter params - name: {}, desc: {}, createdAfter: {}, createdBefore: {}",
                name, description, createdAfter, createdBefore);
        Specification<Event> spec = Specification.where(EventSpecifications.hasOwnerId(ownerId))
                .and(EventSpecifications.containsName(name))
                .and(EventSpecifications.containsDescription(description))
                .and(EventSpecifications.createdAfter(createdAfter))
                .and(EventSpecifications.createdBefore(createdBefore));

        List<Event> events = eventRepository.findAll(spec);
        log.info("Found {} events for owner {}", events.size(), ownerId);
        return events.stream()
                .map(event -> mapToPureResponseDTO(event, headers))
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
        log.debug("Fetching events for user: {}", userId);
        Specification<Event> ownerSpec = EventSpecifications.hasOwnerId(userId);
        Specification<Event> participantSpec = EventSpecifications.hasParticipantId(userId);

        Specification<Event> combinedSpec = ownerSpec.or(participantSpec)
                .and(EventSpecifications.containsName(name))
                .and(EventSpecifications.containsDescription(description))
                .and(EventSpecifications.createdAfter(createdAfter))
                .and(EventSpecifications.createdBefore(createdBefore));

        List<Event> events = eventRepository.findAll(combinedSpec);
        log.info("Found {} events related to user {}", events.size(), userId);
        return events.stream()
                .map(event -> mapToPureResponseDTO(event, headers))
                .collect(Collectors.toList());
    }

    public void deleteEvent(UUID eventId) {
        log.info("Deleting event: {}", eventId);
        try {
            eventRepository.deleteById(eventId);
            log.info("Event deleted: {}", eventId);
        } catch (Exception ex) {
            log.error("Failed to delete event {}: {}", eventId, ex.getMessage(), ex);
            throw ex;
        }
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

    private List<MediaFileDTO> getMediaObjects(List<UUID> mediaIds, HttpHeaders headers) {
        if (mediaIds == null || mediaIds.isEmpty()) {
            log.debug("No media IDs provided for media fetch");
            return List.of();
        }

        log.debug("Fetching media info for {} media IDs", mediaIds.size());
        if (log.isTraceEnabled()) {
            log.trace("Media IDs: {}", mediaIds);
        }

        try {

            ResponseEntity<List<MediaFileDTO>> response = contentProcessorClient.getMediaInfo(mediaIds, headers);

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                log.debug("Successfully fetched {} media items", response.getBody().size());
                return response.getBody();
            } else {
                log.warn("Failed to fetch media. Status: {}, Response: {}",
                        response.getStatusCode(), response.getBody());
                return List.of();
            }

        } catch (Exception ex) {
            log.error("Media fetch error: {}", ex.getMessage(), ex);
            return List.of();
        }
    }

    private MediaFileDTO getDisplayPhoto(Event event, HttpHeaders headers) {
        log.debug("Finding display photo for event: {}", event.getId());
        if (event.getMediaIds() == null || event.getMediaIds().isEmpty()) {
            log.debug("No media available for event: {}", event.getId());
            return null;
        }

        List<MediaFileDTO> mediaFiles = getMediaObjects(event.getMediaIds(), headers);
        for (MediaFileDTO file : mediaFiles) {
            if ("photo".equals(file.getType())) {
                log.debug("Selected display photo [ID: {}] for event {}", file.getMediaId(), event.getId());
                return file;
            }
        }

        log.debug("No suitable photo found for event: {}", event.getId());
        return null;
    }
}