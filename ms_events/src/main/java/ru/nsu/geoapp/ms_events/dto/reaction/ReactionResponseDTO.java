package ru.nsu.geoapp.ms_events.dto.reaction;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Schema(description = "Reaction object for responses")
public class ReactionResponseDTO {

    @Schema(description = "Reaction UUID")
    private UUID id;

    @Schema(description = "UUID of the comment that the reaction was left under")
    private UUID commentId;

    @Schema(description = "UUID of the user who posted the reaction")
    private UUID authorId;

    @Schema(description = "UUID of the reaction emoji")
    private UUID emojiId;

    @Schema(description = "Timestamp when reaction was created", example = "2024-12-03T10:15:30.")
    private LocalDateTime createdAt;
}
