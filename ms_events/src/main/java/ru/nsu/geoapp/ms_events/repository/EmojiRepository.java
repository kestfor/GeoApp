package ru.nsu.geoapp.ms_events.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.nsu.geoapp.ms_events.model.Emoji;

import java.util.UUID;

public interface EmojiRepository extends JpaRepository<Emoji, UUID> {
}
