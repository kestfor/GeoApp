package ru.nsu.geoapp.ms_events.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import ru.nsu.geoapp.ms_events.dto.error.NotFoundErrorDTO;
import ru.nsu.geoapp.ms_events.dto.error.ValidationErrorDTO;
import ru.nsu.geoapp.ms_events.dto.reaction.ReactionRequestDTO;
import ru.nsu.geoapp.ms_events.dto.reaction.ReactionResponseDTO;
import ru.nsu.geoapp.ms_events.service.ReactionService;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/events/{event_id}/comments/{comment_id}")
@Tag(name = "Reactions", description = "API for managing reactions to comments")
public class ReactionController {

    private final ReactionService reactionService;

    @Autowired
    public ReactionController(ReactionService reactionService) {
        this.reactionService = reactionService;
    }

    @PostMapping("/reactions")
    @Operation(
            summary = "Add reaction to comment",
            description = "Creates a new reaction to specified comment"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "201",
                    description = "Reaction created successfully",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = ReactionResponseDTO.class)
                    )
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Invalid request body",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = ValidationErrorDTO.class)
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
    @ResponseStatus(HttpStatus.CREATED)
    public ReactionResponseDTO createReaction(@PathVariable("event_id") UUID eventId,
                                              @PathVariable("comment_id") UUID commentId,
                                              @RequestBody ReactionRequestDTO requestDTO) {
        return reactionService.createReaction(eventId, commentId, requestDTO);
    }


    @GetMapping("/reactions")
    @Operation(
            summary = "Get comment reactions",
            description = "Returns all reactions for specified comment"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Successfully retrieved reactions",
                    content = @Content(
                            mediaType = "application/json",
                            array = @ArraySchema(schema = @Schema(implementation = ReactionResponseDTO.class))
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
    public List<ReactionResponseDTO> getReactionsByCommentId(@PathVariable("event_id") UUID eventId,
                                                             @PathVariable("comment_id") UUID commentId) {
        return reactionService.getReactionsByCommentId(eventId, commentId);
    }


    @DeleteMapping("/reactions/{reaction_id}")
    @Operation(
            summary = "Remove reaction",
            description = "Deletes reaction by its ID"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "204",
                    description = "Reaction deleted successfully"
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Reaction, comment or event not found",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = NotFoundErrorDTO.class)
                    )
            )
    })
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteReaction(@PathVariable("event_id") UUID eventId,
                               @PathVariable("comment_id") UUID commentId,
                               @PathVariable("reaction_id") UUID reactionId) {
        reactionService.deleteReaction(eventId, commentId, reactionId);
    }
}
