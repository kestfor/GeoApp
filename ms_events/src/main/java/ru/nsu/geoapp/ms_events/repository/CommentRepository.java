package ru.nsu.geoapp.ms_events.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.nsu.geoapp.ms_events.model.Comment;

import java.util.List;
import java.util.UUID;

public interface CommentRepository extends JpaRepository<Comment, UUID> {
    List<Comment> findByEventId(UUID eventId);
}
