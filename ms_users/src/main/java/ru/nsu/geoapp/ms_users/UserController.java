package ru.nsu.geoapp.ms_users;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import jakarta.transaction.Transactional;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import ru.nsu.geoapp.ms_users.dto.UserRequest;
import ru.nsu.geoapp.ms_users.model.User;
import ru.nsu.geoapp.ms_users.repository.GoogleAuthRepository;
import ru.nsu.geoapp.ms_users.repository.UserRelationsRepository;
import ru.nsu.geoapp.ms_users.repository.UserRepository;

import java.util.UUID;

@RestController
@RequestMapping("/users")
public class UserController {

    private final UserRepository userRepository;
    private final GoogleAuthRepository googleAuthRepository;
    private final UserRelationsRepository userRelationsRepository;
    private final JwtTokenService jwtTokenService;

    public UserController(UserRepository userRepository,
                          GoogleAuthRepository googleAuthRepository,
                          UserRelationsRepository userRelationsRepository,
                          JwtTokenService jwtTokenService) {
        this.userRepository = userRepository;
        this.googleAuthRepository = googleAuthRepository;
        this.userRelationsRepository = userRelationsRepository;
        this.jwtTokenService = jwtTokenService;
    }

    @Operation(summary = "Updates users' info")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Success", content = @Content),
            @ApiResponse(responseCode = "401", description = "JWT Token without privileges", content = @Content),
            @ApiResponse(responseCode = "404", description = "User with this uuid was not found", content = @Content)
    })
    @PatchMapping("/users/")
    public ResponseEntity<Void> updateUser(@RequestHeader("Authorization") String authHeader, @RequestBody UserRequest request) {
        try {
            if (!isUserAuthorized(authHeader, request.getUserId())) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
            }

            User user = userRepository.findById(request.getUserId()).orElseThrow(
                    () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User with this uuid was not found")
            );

            if (request.getUsername() != null) {
                user.setUsername(request.getUsername());
            }
            if (request.getBirthDate() != null) {
                user.setBirthDate(request.getBirthDate());
            }
            userRepository.save(user);

            return ResponseEntity.ok().build();
        } catch (ResponseStatusException e) {
            throw e;
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Exception upon deleting user", e);
        }
    }

    @Operation(summary = "Deletes the user and all associated entries in google_auth and user_relations tables")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Success", content = @Content),
            @ApiResponse(responseCode = "401", description = "JWT Token without privileges", content = @Content),
            @ApiResponse(responseCode = "404", description = "User with this uuid was not found", content = @Content)
    })
    @DeleteMapping("/users/{userId}")
    @Transactional
    public ResponseEntity<Void> deleteUser(@PathVariable UUID userId, @RequestHeader("Authorization") String authHeader) {
        try {
            if (!isUserAuthorized(authHeader, userId)) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
            }

            if (!userRepository.existsById(userId)) {
                throw new ResponseStatusException(HttpStatus.NOT_FOUND, "User with this uuid was not found");
            }

            googleAuthRepository.deleteById_UserId(userId);
            userRelationsRepository.deleteByUserIdOrOtherId(userId);

            userRepository.deleteById(userId);

            return ResponseEntity.ok().build();
        } catch (ResponseStatusException e) {
            throw e;
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Exception upon deleting user", e);
        }
    }

    private boolean isUserAuthorized(String authHeader, UUID userId) {
        return isUserAuthorized(authHeader, userId, false);
    }

    /**
     * Checks if request's author is actually able to modify the user with specified ID
     * He should be either the same user or a privileged admin
     * */
    private boolean isUserAuthorized(String authHeader, UUID userId, boolean onlyAdmin) {
        String token = extractBearerToken(authHeader);
        String uuidAsString = jwtTokenService.getSubjectFromToken(token);
        UUID uuidFromJWT = UUID.fromString(uuidAsString);
        return (uuidFromJWT.equals(userId) && !onlyAdmin) || false; // todo: replace with admins' privileges check
    }

    private String extractBearerToken(String authHeader) {
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            return authHeader.substring(7);
        }
        throw new IllegalArgumentException("Invalid Authorization header");
    }
}
