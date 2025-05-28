package ru.nsu.geoapp.ms_events.dto.error;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Schema(description = "Forbidden Error")
public class ForbiddenErrorDTO {
    @Schema(description = "Error message", example = "Comment does not belong to event")
    private String message;

    @Schema(description = "HTTP status code", example = "403")
    private int status;

    @Schema(description = "Timestamp of error")
    private LocalDateTime timestamp;
}
