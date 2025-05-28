package ru.nsu.geoapp.ms_events.dto.error;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.Map;

@Data
@Schema(description = "Validation Error")
public class ValidationErrorDTO {
    @Schema(description = "Error message", example = "Validation failed")
    private String message;

    @Schema(description = "HTTP status code", example = "400")
    private int status;

    @Schema(example = "{\"fieldName\": \"Error message\"}")
    private Map<String, String> errors;

    @Schema(description = "Timestamp of error")
    private LocalDateTime timestamp;
}
