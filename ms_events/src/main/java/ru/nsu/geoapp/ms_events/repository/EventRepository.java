package ru.nsu.geoapp.ms_events.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.nsu.geoapp.ms_events.model.Event;

import java.util.List;
import java.util.UUID;

public interface EventRepository extends JpaRepository<Event, UUID> {
    List<Event> findByOwnerId(UUID ownerId);
}
