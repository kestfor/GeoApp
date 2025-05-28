package ru.nsu.geoapp.ms_events.dto.reaction;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.UUID;

@Data
@Schema(description = "Object for creating a reaction")
public class ReactionRequestDTO {

    @NotNull
    @Schema(description = "UUID of the author of the reaction", requiredMode = Schema.RequiredMode.REQUIRED)
    private UUID authorId;

    @NotNull
    @Schema(description = "UUID of the emoji of the reaction", requiredMode = Schema.RequiredMode.REQUIRED)
    private UUID emojiId;
}
