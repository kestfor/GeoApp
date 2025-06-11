package ru.nsu.geoapp.ms_events.dto.comment;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.UUID;

@Data
@Schema(description = "Object for creating a comment")
public class CommentCreateRequestDTO {

    @NotNull
    @Schema(description = "Comment author's UUID", requiredMode = Schema.RequiredMode.REQUIRED)
    private UUID authorId;

    @NotBlank
    @Size(max = 3000, message = "The maximum length of a comment is 3000 characters")
    @Schema(description = "Text of the comment", requiredMode = Schema.RequiredMode.REQUIRED)
    private String text;
}
