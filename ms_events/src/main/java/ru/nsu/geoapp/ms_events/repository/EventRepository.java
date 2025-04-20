package ru.nsu.geoapp.ms_events.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import ru.nsu.geoapp.ms_events.model.Event;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public interface EventRepository extends JpaRepository<Event, UUID> {
    List<Event> findByOwnerId(UUID ownerId);

    @Query("SELECT e FROM Event e WHERE e.ownerId = :userId " +
            "AND (:name IS NULL OR LOWER(e.name) LIKE LOWER(CONCAT('%', :name, '%'))) " +
            "AND (:description IS NULL OR LOWER(e.description) LIKE LOWER(CONCAT('%', :description, '%'))) " +
            "AND (:createdAfter IS NULL OR e.createdAt >= :createdAfter) " +
            "AND (:createdBefore IS NULL OR e.createdAt <= :createdBefore)")
    List<Event> findByOwnerIdWithFilters(
            @Param("userId") UUID ownerId,
            @Param("name") String name,
            @Param("description") String description,
            @Param("createdAfter") LocalDateTime createdAfter,
            @Param("createdBefore") LocalDateTime createdBefore
    );
}
