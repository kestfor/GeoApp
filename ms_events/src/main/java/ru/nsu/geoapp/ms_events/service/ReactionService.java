package ru.nsu.geoapp.ms_events.service;

import lombok.AllArgsConstructor;
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

@Service
@AllArgsConstructor(onConstructor = @__(@Autowired))
public class ReactionService {
    private final EventRepository eventRepository;
    private final ReactionRepository reactionRepository;
    private final EmojiRepository emojiRepository;
    private final ValidationService validationService;

    public ReactionResponseDTO createReaction(UUID eventId, UUID commentId, ReactionRequestDTO requestDTO) {
        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new ObjectNotFoundException("Couldn't find event by" + eventId));

        Comment comment = validationService.getCommentIfBelongsToEvent(eventId, commentId);
        Emoji emoji = emojiRepository.findById(requestDTO.getEmojiId())
                .orElseThrow(() -> new ObjectNotFoundException("Couldn't find emoji by" + requestDTO.getEmojiId()));

        Reaction reaction = new Reaction();
        reaction.setAuthorId(requestDTO.getAuthorId());
        reaction.setComment(comment);
        reaction.setEmoji(emoji);
        reaction.setCreatedAt(LocalDateTime.now());
        reaction.setUpdatedAt(LocalDateTime.now());

        Reaction savedReaction = reactionRepository.save(reaction);
        return mapToResponseDTO(savedReaction);
    }

    public List<ReactionResponseDTO> getReactionsByCommentId(UUID eventId, UUID commentId) {
        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new ObjectNotFoundException("Couldn't find event by" + eventId));

        validationService.checkCommentBelongsToEvent(eventId, commentId);
        List<Reaction> reactions = reactionRepository.findByCommentId(commentId);

        return reactions.stream()
                .map(this::mapToResponseDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public void deleteReaction(UUID eventId, UUID commentId, UUID reactionId) {
        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new ObjectNotFoundException("Couldn't find event by" + eventId));

        validationService.checkCommentBelongsToEvent(eventId, commentId);
        Reaction reaction = validationService.getReactionIfBelongsToComment(commentId, reactionId);

        reactionRepository.delete(reaction);
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
