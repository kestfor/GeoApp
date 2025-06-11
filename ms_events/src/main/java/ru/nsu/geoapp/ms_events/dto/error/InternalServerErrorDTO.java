package ru.nsu.geoapp.ms_events.dto.error;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Schema(description = "Internal Server Error")
public class InternalServerErrorDTO {
    @Schema(description = "Error message", example = "Something went wrong")
    private String message;

    @Schema(description = "HTTP status code", example = "500")
    private int status;

    @Schema(description = "Timestamp of error")
    private LocalDateTime timestamp;
}