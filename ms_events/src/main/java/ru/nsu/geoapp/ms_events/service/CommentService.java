package ru.nsu.geoapp.ms_events.service;

import lombok.AllArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
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
import ru.nsu.geoapp.ms_events.client.kafka.messages.NewCommentMessage;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

@Service
@AllArgsConstructor(onConstructor = @__(@Autowired))
public class CommentService {

    private final CommentRepository commentRepository;
    private final EventRepository eventRepository;
    private final ValidationService validationService;
    private final KafkaTemplate<String, NewCommentMessage> kafkaTemplate;

    @Transactional
    public CommentResponseDTO createComment(UUID eventId, CommentCreateRequestDTO requestDTO) {
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

        CompletableFuture<SendResult<String, NewCommentMessage>> future = kafkaTemplate.send("comments.events", savedComment.getId().toString(), mapToPostCreatedMessage(event));

        future.whenComplete((result, ex) -> {
            if (ex == null) {
                System.out.println("INFO Message sent to topic 'comments.events' with commentId: " + savedComment.getId().toString());
            } else {
                System.out.println("ERROR Error sending message with commentId: " + savedComment.getId().toString() + ", error:" + ex.getMessage());
            }
        });

        return mapToResponseDTO(savedComment);
    }

    @Transactional
    public CommentResponseDTO updateComment(UUID eventId, UUID commentId, CommentUpdateRequestDTO requestDTO) {
        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new ObjectNotFoundException("Couldn't find event by" + eventId));

        Comment comment = validationService.getCommentIfBelongsToEvent(eventId, commentId);
        comment.setText(requestDTO.getText());
        comment.setUpdatedAt(LocalDateTime.now());

        Comment savedComment = commentRepository.save(comment);
        return mapToResponseDTO(savedComment);
    }

    public List<CommentResponseDTO> getCommentsByEventId(UUID eventId) {
        List<Comment> comments = commentRepository.findByEventId(eventId);

        return comments.stream()
                .map(this::mapToResponseDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public void deleteComment(UUID eventId, UUID commentId) {
        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new ObjectNotFoundException("Couldn't find event by" + eventId));

        Comment comment = validationService.getCommentIfBelongsToEvent(eventId, commentId);
        commentRepository.delete(comment);
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
