package ru.nsu.geoapp.ms_events.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.nsu.geoapp.ms_events.model.Reaction;

import java.util.List;
import java.util.UUID;

public interface ReactionRepository extends JpaRepository<Reaction, UUID> {
    List<Reaction> findByCommentId(UUID commentId);
}
