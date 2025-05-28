package ru.nsu.geoapp.ms_events.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.ErrorResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import ru.nsu.geoapp.ms_events.dto.error.InternalServerErrorDTO;
import ru.nsu.geoapp.ms_events.dto.reaction.EmojiResponseDTO;
import ru.nsu.geoapp.ms_events.service.EmojiService;

import java.util.List;

@RestController
@RequestMapping("/emojis")
@Tag(name = "Emojis", description = "API for managing available emojis")
public class EmojiController {
    private final EmojiService emojiService;

    @Autowired
    public EmojiController(EmojiService emojiService) {
        this.emojiService = emojiService;
    }

    @GetMapping
    @Operation(
            summary = "Get all available emojis",
            description = "Returns a list of all available emojis in the system"
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Successfully retrieved emoji list",
                    content = @Content(
                            mediaType = "application/json",
                            array = @ArraySchema(schema = @Schema(implementation = EmojiResponseDTO.class))
                    )
            ),
            @ApiResponse(
                    responseCode = "500",
                    description = "Internal server error",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = InternalServerErrorDTO.class)
                    )
            )
    })
    @ResponseStatus(HttpStatus.OK)
    public List<EmojiResponseDTO> getAllEmojis() {
        return emojiService.getAllAvailableEmojis();
    }
}
