package ru.nsu.geoapp.ms_events.service;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.nsu.geoapp.ms_events.dto.comment.CommentCreateRequestDTO;
import ru.nsu.geoapp.ms_events.dto.comment.CommentResponseDTO;
import ru.nsu.geoapp.ms_events.dto.comment.CommentUpdateRequestDTO;
import ru.nsu.geoapp.ms_events.exception.ObjectNotFoundException;
import ru.nsu.geoapp.ms_events.model.Comment;
import ru.nsu.geoapp.ms_events.model.Event;
import ru.nsu.geoapp.ms_events.repository.CommentRepository;
import ru.nsu.geoapp.ms_events.repository.EventRepository;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@AllArgsConstructor(onConstructor = @__(@Autowired))
public class CommentService {

    private final CommentRepository commentRepository;
    private final EventRepository eventRepository;
    private final ValidationService validationService;

    @Transactional
    public CommentResponseDTO createComment(UUID eventId, CommentCreateRequestDTO requestDTO) {
        log.debug("Creating comment for event [{}] by author [{}]", eventId, requestDTO.getAuthorId());
        try {

            Event event = eventRepository.findById(eventId)
                    .orElseThrow(() -> new ObjectNotFoundException("Couldn't find event by" + eventId));

            Comment comment = new Comment();
            comment.setAuthorId(requestDTO.getAuthorId());
            comment.setEvent(event);
            comment.setText(requestDTO.getText());
            comment.setReactions(new ArrayList<>());
            comment.setCreatedAt(LocalDateTime.now());
            comment.setUpdatedAt(LocalDateTime.now());
            Comment savedComment = commentRepository.save(comment);
            log.info("Comment created successfully [ID: {}, Event: {}, Author: {}]",
                    savedComment.getId(), eventId, requestDTO.getAuthorId());
            return mapToResponseDTO(savedComment);

        } catch (ObjectNotFoundException ex) {
            log.error("Create comment failed: Event {} not found", eventId);
            throw ex;
        } catch (Exception ex) {
            log.error("Unexpected error when creating comment for event {}: {}", eventId, ex.getMessage(), ex);
            throw ex;
        }
    }

    @Transactional
    public CommentResponseDTO updateComment(UUID eventId, UUID commentId, CommentUpdateRequestDTO requestDTO) {
        log.debug("Updating comment [{}] for event [{}]", commentId, eventId);
        try {
            Event event = eventRepository.findById(eventId)
                    .orElseThrow(() -> new ObjectNotFoundException("Couldn't find event by" + eventId));

            Comment comment = validationService.getCommentIfBelongsToEvent(eventId, commentId);
            comment.setText(requestDTO.getText());
            comment.setUpdatedAt(LocalDateTime.now());

            Comment savedComment = commentRepository.save(comment);
            log.info("Comment updated [ID: {}, Event: {}]", commentId, eventId);
            return mapToResponseDTO(savedComment);

        } catch (ObjectNotFoundException ex) {
            log.warn("Update failed: {} for event {}", ex.getMessage(), eventId);
            throw ex;
        } catch (Exception ex) {
            log.error("Error updating comment {}: {}", commentId, ex.getMessage(), ex);
            throw ex;
        }
    }

    public List<CommentResponseDTO> getCommentsByEventId(UUID eventId) {
        log.debug("Fetching comments for event [{}]", eventId);
        try {
            List<Comment> comments = commentRepository.findByEventId(eventId);

            log.debug("Found {} comments for event [{}]", comments.size(), eventId);
            return comments.stream()
                    .map(this::mapToResponseDTO)
                    .collect(Collectors.toList());
        } catch (Exception ex) {
            log.error("Error fetching comments for event {}: {}", eventId, ex.getMessage(), ex);
            throw ex;
        }
    }

    @Transactional
    public void deleteComment(UUID eventId, UUID commentId) {
        log.debug("Deleting comment [{}] from event [{}]", commentId, eventId);
        try {

            Event event = eventRepository.findById(eventId)
                    .orElseThrow(() -> new ObjectNotFoundException("Couldn't find event by" + eventId));

            Comment comment = validationService.getCommentIfBelongsToEvent(eventId, commentId);
            commentRepository.delete(comment);
            log.info("Comment deleted [ID: {}, Event: {}]", commentId, eventId);

        } catch (ObjectNotFoundException ex) {
            log.warn("Delete failed: {} for comment {}", ex.getMessage(), commentId);
            throw ex;
        } catch (Exception ex) {
            log.error("Error deleting comment {}: {}", commentId, ex.getMessage(), ex);
            throw ex;
        }
    }

    private CommentResponseDTO mapToResponseDTO(Comment comment) {
        CommentResponseDTO dto = new CommentResponseDTO();
        dto.setId(comment.getId());
        dto.setEventId(comment.getEvent().getId());
        dto.setAuthorId(comment.getAuthorId());
        dto.setText(comment.getText());
        dto.setCreatedAt(comment.getCreatedAt());
        dto.setUpdatedAt(comment.getUpdatedAt());
        return dto;
    }
}
