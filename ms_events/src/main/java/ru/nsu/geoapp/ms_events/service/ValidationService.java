package ru.nsu.geoapp.ms_events.service;

import lombok.AllArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import ru.nsu.geoapp.ms_events.exception.ForbiddenException;
import ru.nsu.geoapp.ms_events.exception.ObjectNotFoundException;
import ru.nsu.geoapp.ms_events.model.Comment;
import ru.nsu.geoapp.ms_events.model.Event;
import ru.nsu.geoapp.ms_events.model.Reaction;
import ru.nsu.geoapp.ms_events.repository.CommentRepository;
import ru.nsu.geoapp.ms_events.repository.EventRepository;
import ru.nsu.geoapp.ms_events.repository.ReactionRepository;

import java.util.List;
import java.util.UUID;

@Service
@AllArgsConstructor(onConstructor_ = {@Autowired})
public class ValidationService {
    private final CommentRepository commentRepository;
    private final ReactionRepository reactionRepository;

    public Comment getCommentIfBelongsToEvent(UUID eventId, UUID commentId) {
        Comment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new ObjectNotFoundException("Couldn't find comment by" + commentId));

        if (!comment.getEvent().getId().equals(eventId)) {
            throw new ObjectNotFoundException(
                    "Comment with UUID " + commentId + " does not belong to the event with UUID " + eventId
            );
        }

        return comment;
    }

    public void checkCommentBelongsToEvent(UUID eventId, UUID commentId) {
        Comment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new ObjectNotFoundException("Couldn't find comment by" + commentId));

        if (!comment.getEvent().getId().equals(eventId)) {
            throw new ObjectNotFoundException(
                    "Comment with UUID " + commentId + " does not belong to the event with UUID " + eventId
            );
        }
    }

    public Reaction getReactionIfBelongsToComment(UUID commentId, UUID reactionId) {
        Reaction reaction = reactionRepository.findById(reactionId)
                .orElseThrow(() -> new ObjectNotFoundException("Couldn't find reaction by" + reactionId));

        if (!reaction.getComment().getId().equals(commentId)) {
            throw new ObjectNotFoundException(
                    "Reaction with UUID " + reactionId + " does not belong to the comment with UUID " + commentId
            );
        }

        return reaction;
    }
}
