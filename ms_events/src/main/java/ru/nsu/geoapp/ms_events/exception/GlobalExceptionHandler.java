package ru.nsu.geoapp.ms_events.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import ru.nsu.geoapp.ms_events.dto.error.InternalServerErrorDTO;
import ru.nsu.geoapp.ms_events.dto.error.NotFoundErrorDTO;
import ru.nsu.geoapp.ms_events.dto.error.ValidationErrorDTO;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@ControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(ObjectNotFoundException.class)
    public ResponseEntity<NotFoundErrorDTO> handleEventNotFound(ObjectNotFoundException ex) {
        NotFoundErrorDTO error = new NotFoundErrorDTO();
        error.setMessage(ex.getMessage());
        error.setStatus(HttpStatus.NOT_FOUND.value());
        error.setTimestamp(LocalDateTime.now());
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ValidationErrorDTO> handleValidation(MethodArgumentNotValidException ex) {
        ValidationErrorDTO error = new ValidationErrorDTO();
        error.setMessage("Validation failed");
        error.setStatus(HttpStatus.BAD_REQUEST.value());

        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getFieldErrors().forEach(e -> errors.put(e.getField(), e.getDefaultMessage()));
        error.setErrors(errors);

        error.setTimestamp(LocalDateTime.now());

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }

//    @ExceptionHandler(Exception.class)
//    public ResponseEntity<InternalServerErrorDTO> handleAllExceptions(Exception ex) {
//        InternalServerErrorDTO error = new InternalServerErrorDTO();
//        error.setMessage("Internal server error");
//        error.setStatus(HttpStatus.INTERNAL_SERVER_ERROR.value());
//        error.setTimestamp(LocalDateTime.now());
//        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
//    }
}