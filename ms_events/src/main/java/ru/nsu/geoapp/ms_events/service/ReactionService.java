package ru.nsu.geoapp.ms_events.service;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.nsu.geoapp.ms_events.dto.reaction.ReactionRequestDTO;
import ru.nsu.geoapp.ms_events.dto.reaction.ReactionResponseDTO;
import ru.nsu.geoapp.ms_events.exception.ObjectNotFoundException;
import ru.nsu.geoapp.ms_events.model.Comment;
import ru.nsu.geoapp.ms_events.model.Emoji;
import ru.nsu.geoapp.ms_events.model.Event;
import ru.nsu.geoapp.ms_events.model.Reaction;
import ru.nsu.geoapp.ms_events.repository.CommentRepository;
import ru.nsu.geoapp.ms_events.repository.EmojiRepository;
import ru.nsu.geoapp.ms_events.repository.EventRepository;
import ru.nsu.geoapp.ms_events.repository.ReactionRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@AllArgsConstructor(onConstructor = @__(@Autowired))
public class ReactionService {
    private final EventRepository eventRepository;
    private final ReactionRepository reactionRepository;
    private final EmojiRepository emojiRepository;
    private final ValidationService validationService;

    public ReactionResponseDTO createReaction(UUID eventId, UUID commentId, ReactionRequestDTO requestDTO) {
        log.info("Creating reaction [Event: {}, Comment: {}, Author: {}, Emoji: {}]",
                eventId, commentId, requestDTO.getAuthorId(), requestDTO.getEmojiId());

        try {
            Event event = eventRepository.findById(eventId)
                    .orElseThrow(() -> {
                        log.warn("Event not found for reaction: {}", eventId);
                        return new ObjectNotFoundException("Event not found: " + eventId);
                    });

            Comment comment = validationService.getCommentIfBelongsToEvent(eventId, commentId);
            log.debug("Comment validation passed [Comment: {}, Event: {}]", commentId, eventId);

            Emoji emoji = emojiRepository.findById(requestDTO.getEmojiId())
                    .orElseThrow(() -> {
                        log.warn("Emoji not found: {}", requestDTO.getEmojiId());
                        return new ObjectNotFoundException("Emoji not found: " + requestDTO.getEmojiId());
                    });

            Reaction reaction = new Reaction();
            reaction.setAuthorId(requestDTO.getAuthorId());
            reaction.setComment(comment);
            reaction.setEmoji(emoji);
            reaction.setCreatedAt(LocalDateTime.now());
            reaction.setUpdatedAt(LocalDateTime.now());

            Reaction savedReaction = reactionRepository.save(reaction);
            log.info("Reaction created [ID: {}, Author: {}, Emoji: {}]",
                    savedReaction.getId(), requestDTO.getAuthorId(), emoji.getDescription());
            return mapToResponseDTO(savedReaction);

        } catch (ObjectNotFoundException ex) {
            throw ex;
        } catch (Exception ex) {
            log.error("Failed to create reaction [Event: {}, Comment: {}]: {}",
                    eventId, commentId, ex.getMessage(), ex);
            throw ex;
        }
    }

    public List<ReactionResponseDTO> getReactionsByCommentId(UUID eventId, UUID commentId) {
        log.debug("Fetching reactions for comment [Event: {}, Comment: {}]", eventId, commentId);

        try {
            Event event = eventRepository.findById(eventId)
                    .orElseThrow(() -> {
                        log.warn("Event not found: {}", eventId);
                        return new ObjectNotFoundException("Event not found: " + eventId);
                    });

            validationService.checkCommentBelongsToEvent(eventId, commentId);
            log.debug("Comment validation passed [Comment: {}, Event: {}]", commentId, eventId);

            List<Reaction> reactions = reactionRepository.findByCommentId(commentId);
            log.info("Found {} reactions for comment [{}]", reactions.size(), commentId);

            if (log.isTraceEnabled()) {
                log.trace("Reaction details: {}",
                        reactions.stream()
                                .map(r -> r.getId() + ":" + r.getEmoji().getDescription())
                                .collect(Collectors.joining(", "))
                );
            }

            return reactions.stream()
                    .map(this::mapToResponseDTO)
                    .collect(Collectors.toList());

        } catch (ObjectNotFoundException ex) {
            throw ex;
        } catch (Exception ex) {
            log.error("Failed to get reactions [Event: {}, Comment: {}]: {}",
                    eventId, commentId, ex.getMessage(), ex);
            throw ex;
        }
    }

    @Transactional
    public void deleteReaction(UUID eventId, UUID commentId, UUID reactionId) {
        log.info("Deleting reaction [Event: {}, Comment: {}, Reaction: {}]",
                eventId, commentId, reactionId);

        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> {
                    log.warn("Event not found: {}", eventId);
                    return new ObjectNotFoundException("Event not found: " + eventId);
                });

        validationService.checkCommentBelongsToEvent(eventId, commentId);
        log.debug("Comment validation passed [Comment: {}, Event: {}]", commentId, eventId);

        Reaction reaction = validationService.getReactionIfBelongsToComment(commentId, reactionId);
        log.debug("Reaction validation passed [Reaction: {}, Comment: {}]", reactionId, commentId);

        reactionRepository.delete(reaction);
        log.info("Reaction deleted [ID: {}, Author: {}, Emoji: {}]",
                reactionId, reaction.getAuthorId(), reaction.getEmoji().getDescription());
    }

    private ReactionResponseDTO mapToResponseDTO(Reaction reaction) {
        ReactionResponseDTO dto = new ReactionResponseDTO();
        dto.setId(reaction.getId());
        dto.setAuthorId(reaction.getAuthorId());
        dto.setCommentId(reaction.getComment().getId());
        dto.setEmojiId(reaction.getEmoji().getId());
        dto.setCreatedAt(reaction.getCreatedAt());
        return dto;
    }
}
