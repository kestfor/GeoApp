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
import ru.nsu.geoapp.ms_users.dto.UserResponse;
import ru.nsu.geoapp.ms_users.model.User;
import ru.nsu.geoapp.ms_users.model.UserRelations;
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

    @Operation(summary = "Create user with specified params")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Success, returns created user's uuid"),
            @ApiResponse(responseCode = "401", description = "JWT Token without privileges", content = @Content)
    })
    @PostMapping()
    public ResponseEntity<UserResponse> createUser(@RequestHeader("Authorization") String authHeader, @RequestBody User user) {
        try {
            if (!isUserAuthorized(authHeader, null, true)) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
            }

            userRepository.save(user);

            UserResponse response = new UserResponse();
            response.setId(user.getId());

            return ResponseEntity.ok(response);
        } catch (ResponseStatusException e) {
            throw e;
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Exception upon deleting user", e);
        }
    }

    @Operation(summary = "Get detailed info about user")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Success"),
            @ApiResponse(responseCode = "401", description = "JWT Token without privileges", content = @Content),
            @ApiResponse(responseCode = "404", description = "User with this uuid was not found", content = @Content)
    })
    @GetMapping("/detailed/{userId}")
    public ResponseEntity<UserResponse> readUser(@PathVariable UUID userId, @RequestHeader("Authorization") String authHeader) {
        try {
            User requestedUser = userRepository.findById(userId).orElseThrow(
                    () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Requested user with this uuid was not found")
            );
            User requestingUser = userRepository.findById(userId).orElseThrow(
                    () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Requesting user with this uuid was not found")
            );

            UserRelations.UserRelationId relationId = new UserRelations.UserRelationId();
            relationId.setUserId(requestingUser.getId());
            relationId.setOtherId(requestedUser.getId());
            UserRelations userRelations = userRelationsRepository.findById(relationId).orElse(null);

            UserResponse response = new UserResponse();
            response.setId(requestedUser.getId());
            response.setUsername(requestedUser.getUsername());
            response.setFirstName(requestedUser.getFirstName());
            response.setLastName(requestedUser.getLastName());
            response.setPictureUrl(requestedUser.getPictureUrl());

            response.setRelationType((userRelations == null) ? "NONE" : userRelations.getStatus());
            response.setBio(requestedUser.getBio());
            response.setBirthDate(requestedUser.getBirthDate());

            return ResponseEntity.ok(response);
        } catch (ResponseStatusException e) {
            throw e;
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Exception upon getting detailed info user", e);
        }
    }

    @Operation(summary = "Updates users' info")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Success", content = @Content),
            @ApiResponse(responseCode = "401", description = "JWT Token without privileges", content = @Content),
            @ApiResponse(responseCode = "404", description = "User with this uuid was not found", content = @Content)
    })
    @PatchMapping()
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
            if (request.getBio() != null) {
                user.setBio(request.getBio());
            }
            userRepository.save(user);

            return ResponseEntity.ok().build();
        } catch (ResponseStatusException e) {
            throw e;
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Exception upon updating user", e);
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
            userRelationsRepository.deleteById_UserId(userId);
            userRelationsRepository.deleteById_OtherId(userId);

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
        return (!onlyAdmin && uuidFromJWT.equals(userId)) || false; // todo: replace with admins' privileges check
    }

    private String extractBearerToken(String authHeader) {
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            return authHeader.substring(7);
        }
        throw new IllegalArgumentException("Invalid Authorization header");
    }
}
