package ru.nsu.geoapp.ms_events.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import ru.nsu.geoapp.ms_events.model.Event;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public interface EventRepository extends JpaRepository<Event, UUID>, JpaSpecificationExecutor<Event> {
    List<Event> findByOwnerId(UUID ownerId);

//    List<Event> findByOwnerIdWithFilters(
//            @Param("userId") UUID ownerId,
//            @Param("name") String name,
//            @Param("description") String description,
//            @Param("createdAfter") LocalDateTime createdAfter,
//            @Param("createdBefore") LocalDateTime createdBefore
//    );
}
