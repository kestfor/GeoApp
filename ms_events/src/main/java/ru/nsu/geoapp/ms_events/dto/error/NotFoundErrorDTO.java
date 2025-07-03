package ru.nsu.geoapp.ms_events.dto.error;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Schema(description = "Not found error")
public class NotFoundErrorDTO {
    @Schema(description = "Error message", example = "Object not found")
    private String message;

    @Schema(description = "HTTP status code", example = "404")
    private int status;

    @Schema(description = "Timestamp of error")
    private LocalDateTime timestamp;
}
