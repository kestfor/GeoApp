package ru.nsu.geoapp.ms_events.dto.comment;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import ru.nsu.geoapp.ms_events.dto.reaction.ReactionResponseDTO;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Data
@Schema(description = "Comment object with reactions for responses")
public class CommentWithReactionsDTO {

    @Schema(description = "Comment UUID")
    private UUID Id;

    @Schema(description = "UUID of the event that the comment was posted under")
    private UUID eventId;

    @Schema(description = "UUID of the author who wrote the comment")
    private UUID authorId;

    @Schema(description = "Text of the comment", example = "It's my first comment!")
    private String text;

    @Schema(description = "List of the reactions under the comment")
    private List<ReactionResponseDTO> reactions;

    @Schema(description = "Timestamp when event was created", example = "2024-12-03T10:15:30.")
    private LocalDateTime createdAt;

    @Schema(description = "Timestamp when event was updated last time", example = "2024-12-03T12:25:30.")
    private LocalDateTime updatedAt;
}
