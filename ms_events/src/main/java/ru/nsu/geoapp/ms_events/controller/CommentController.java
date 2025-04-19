package ru.nsu.geoapp.ms_events.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import ru.nsu.geoapp.ms_events.dto.comment.CommentCreateRequestDTO;
import ru.nsu.geoapp.ms_events.dto.comment.CommentResponseDTO;
import ru.nsu.geoapp.ms_events.dto.comment.CommentUpdateRequestDTO;
import ru.nsu.geoapp.ms_events.dto.error.ForbiddenErrorDTO;
import ru.nsu.geoapp.ms_events.dto.error.NotFoundErrorDTO;
import ru.nsu.geoapp.ms_events.dto.error.ValidationErrorDTO;
import ru.nsu.geoapp.ms_events.service.CommentService;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/events")
@Tag(name = "Comments", description = "API for comment management")
public class CommentController {

    private final CommentService commentService;

    @Autowired
    public CommentController(CommentService commentService) {
        this.commentService = commentService;
    }


    @PostMapping("/{event_id}/comments")
    @Operation(
            summary = "Create comment",
            description = "Creates a new comment under specified event"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "201",
                    description = "Comment created successfully",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = CommentResponseDTO.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Invalid input data",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = ValidationErrorDTO.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Event not found",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = NotFoundErrorDTO.class)
                    )
            )
    })
    @ResponseStatus(HttpStatus.CREATED)
    public CommentResponseDTO createComment(@PathVariable("event_id") UUID eventId,
                                            @Valid @RequestBody CommentCreateRequestDTO requestDTO
    ) {
        return commentService.createComment(eventId, requestDTO);
    }


    @PutMapping("/{event_id}/comments/{comment_id}")
    @Operation(
            summary = "Update comment",
            description = "Updates existing comment by its ID"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Comment updated successfully",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = CommentResponseDTO.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Invalid input data",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = ValidationErrorDTO.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "403",
                    description = "Forbidden request",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = ForbiddenErrorDTO.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Comment or event not found",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = NotFoundErrorDTO.class)
                    )
            )
    })
    public CommentResponseDTO updateComment(@PathVariable("event_id") UUID eventId,
                                            @PathVariable("comment_id") UUID commentId,
                                            @Valid @RequestBody CommentUpdateRequestDTO requestDTO
    ) {
        return commentService.updateComment(eventId, commentId, requestDTO);
    }


    //TODO: limit number of comments
    @GetMapping("/{event_id}/comments")
    @Operation(
            summary = "Get event comments",
            description = "Returns list of comments for specified event"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Successfully retrieved comments",
                    content = @Content(
                            mediaType = "application/json",
                            array = @ArraySchema(schema = @Schema(implementation = CommentResponseDTO.class))
                    )
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Comment or event not found",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = NotFoundErrorDTO.class)
                    )
            )
    })
    public List<CommentResponseDTO> getCommentsByEventId(@PathVariable("event_id") UUID eventId) {
        return commentService.getCommentsByEventId(eventId);
    }


    @DeleteMapping("/{event_id}/comments/{comment_id}")
    @Operation(
            summary = "Delete comment",
            description = "Deletes comment by its ID"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "204",
                    description = "Comment deleted successfully"
            ),
            @ApiResponse(
                    responseCode = "403",
                    description = "Forbidden request",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = ForbiddenErrorDTO.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Comment or event not found",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = NotFoundErrorDTO.class)
                    )
            )
    })
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteComment(@PathVariable("event_id") UUID eventId, @PathVariable("comment_id") UUID commentId) {
        commentService.deleteComment(eventId, commentId);
    }
}
