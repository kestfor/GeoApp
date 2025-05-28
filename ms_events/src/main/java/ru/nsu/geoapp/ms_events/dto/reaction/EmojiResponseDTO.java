package ru.nsu.geoapp.ms_events.dto.reaction;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.util.UUID;

@Data
@Schema(description = "Emoji object for responses")
public class EmojiResponseDTO {
    @Schema(description = "Emoji UUID")
    private UUID id;

    @Schema(description = "Emoji HTML code", example = "&#128077")
    private String code;

    @Schema(description = "Emoji description", example = "Like")
    private String description;
}