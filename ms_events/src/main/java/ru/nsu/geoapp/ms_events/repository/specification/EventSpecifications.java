package ru.nsu.geoapp.ms_events.repository.specification;

import org.springframework.data.jpa.domain.Specification;
import ru.nsu.geoapp.ms_events.model.Event;

import java.time.LocalDateTime;
import java.util.UUID;

public class EventSpecifications {
    public static Specification<Event> hasOwnerId(UUID ownerId) {
        return (root, query, cb) -> cb.equal(root.get("ownerId"), ownerId);
    }

    public static Specification<Event> containsName(String name) {
        return (root, query, cb) -> {
            if (name == null) return null;
            return cb.like(cb.lower(root.get("name")), "%" + name.toLowerCase() + "%");
        };
    }

    public static Specification<Event> hasParticipantId(UUID participantId) {
        return (root, query, cb) -> cb.isMember(participantId, root.get("participantIds"));
    }

    public static Specification<Event> containsDescription(String description) {
        return (root, query, cb) -> {
            if (description == null) return null;
            return cb.like(cb.lower(root.get("description")), "%" + description.toLowerCase() + "%");
        };
    }

    public static Specification<Event> createdAfter(LocalDateTime date) {
        return (root, query, cb) -> {
            if (date == null) return null;
            return cb.greaterThanOrEqualTo(root.get("createdAt"), date);
        };
    }

    public static Specification<Event> createdBefore(LocalDateTime date) {
        return (root, query, cb) -> {
            if (date == null) return null;
            return cb.lessThanOrEqualTo(root.get("createdAt"), date);
        };
    }
}
