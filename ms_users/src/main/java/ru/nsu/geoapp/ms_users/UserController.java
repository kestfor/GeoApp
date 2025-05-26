package ru.nsu.geoapp.ms_users;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import jakarta.transaction.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import ru.nsu.geoapp.ms_users.dto.*;
import ru.nsu.geoapp.ms_users.model.User;
import ru.nsu.geoapp.ms_users.model.UserRelations;
import ru.nsu.geoapp.ms_users.repository.GoogleAuthRepository;
import ru.nsu.geoapp.ms_users.repository.UserRelationsRepository;
import ru.nsu.geoapp.ms_users.repository.UserRepository;

import java.util.*;

@RestController
@RequestMapping("/users")
public class UserController {

    private final UserRepository userRepository;
    private final GoogleAuthRepository googleAuthRepository;
    private final UserRelationsRepository userRelationsRepository;
    private final JwtTokenService jwtTokenService;

    private static final Logger LOGGER = LoggerFactory.getLogger(UserController.class);

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
    public ResponseEntity<CreatedUserResponse> createUser(@RequestHeader("Authorization") String authHeader, @RequestBody User user) {
        try {
            if (!isUserAuthorized(authHeader, null, true)) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
            }

            userRepository.save(user);

            CreatedUserResponse response = new CreatedUserResponse();
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
            @ApiResponse(responseCode = "401", description = "Unauthorized", content = @Content),
            @ApiResponse(responseCode = "403", description = "Malformed UUID", content = @Content),
            @ApiResponse(responseCode = "404", description = "User with this uuid was not found", content = @Content)
    })
    @GetMapping("/detailed/{userId}")
    public ResponseEntity<UserResponse> readUser(@RequestHeader("Authorization") String authHeader, @PathVariable UUID userId) {
        try {
            LOGGER.debug("Starting /detailed/<userId>");
            String token = extractBearerToken(authHeader);
            String subject = jwtTokenService.getSubjectFromToken(token);
            UUID requestingUserUUID = UUID.fromString(subject);
            LOGGER.debug("Requested by {}", requestingUserUUID);
            User requestedUser = userRepository.findById(userId).orElse(null);
            LOGGER.debug("Requested: {}", (requestedUser != null) ? requestedUser.toString() : null);
            User requestingUser = userRepository.findById(requestingUserUUID).orElse(null);
            LOGGER.debug("Requesting: {}", (requestingUser != null) ? requestingUser.toString() : null);
            if (requestedUser == null || requestingUser == null) {
                return ResponseEntity.notFound().build();
            }

            LOGGER.debug("Creating relationId...");
            UserRelations.UserRelationId relationId = new UserRelations.UserRelationId();
            LOGGER.debug("Empty relationId created...");
            relationId.setUserId(requestingUser.getId());
            LOGGER.debug("Success on relationId.setUserId(requestingUser.getId())");
            relationId.setOtherId(requestedUser.getId());
            LOGGER.debug("Success on relationId.setOtherId(requestedUser.getId());");
            UserRelations userRelations = userRelationsRepository.findById(relationId).orElse(null);
            LOGGER.debug("userRelations: {}", (userRelations != null) ? userRelations.toString() : null);

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
        //} catch (ResponseStatusException e) {
        //    throw e;
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Exception upon getting detailed info user", e);
        }
    }

    @Operation(summary = "Get pure users by their ids")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Success"),
            @ApiResponse(responseCode = "401", description = "Unauthorized", content = @Content)
    })
    @PostMapping("/list")
    public List<PureUserResponse> readUsers(@RequestHeader("Authorization") String authHeader, @RequestBody List<UUID> userUuids) {
        try {
            List<PureUserResponse> response = new ArrayList<>();
            for (UUID uuid : userUuids) {
                User user = userRepository.findById(uuid).orElse(null);
                if (user != null) {
                    PureUserResponse pureUser = new PureUserResponse();
                    pureUser.setId(user.getId());
                    pureUser.setUsername(user.getUsername());
                    pureUser.setFirstName(user.getFirstName());
                    pureUser.setLastName(user.getLastName());
                    pureUser.setPictureUrl(user.getPictureUrl());
                    response.add(pureUser);
                }
            }
            return response;
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Exception upon listing users", e);
        }
    }

    @Operation(summary = "Get pure users that are friends with specified user")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Success"),
            @ApiResponse(responseCode = "401", description = "Unauthorized", content = @Content)
    })
    @GetMapping("/friends/{userId}")
    public List<PureUserResponse> readUsersFriends(@RequestHeader("Authorization") String authHeader, @PathVariable UUID userId) {
        try {
            LOGGER.debug("Starting /friends/<userId>");
            List<PureUserResponse> response = new ArrayList<>();

            LOGGER.debug("Searching for relations of {}", userId);
            List<UserRelations> relations = userRelationsRepository.findById_UserId(userId);
            for (UserRelations relation : relations) {
                if (!relation.getStatus().equals("FRIEND")) {
                    continue;
                }
                LOGGER.debug("Found friend {}", relation.getId().getOtherId());
                User user = userRepository.findById(relation.getId().getOtherId()).orElse(null);
                LOGGER.debug("Friend: {}", (user != null) ? user.toString() : null);
                if (user != null) {
                    PureUserResponse pureUser = new PureUserResponse();
                    pureUser.setId(user.getId());
                    pureUser.setUsername(user.getUsername());
                    pureUser.setFirstName(user.getFirstName());
                    pureUser.setLastName(user.getLastName());
                    pureUser.setPictureUrl(user.getPictureUrl());
                    response.add(pureUser);
                }
            }
            return response;
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Exception upon listing user's friends", e);
        }
    }

    @Operation(summary = "Get pure users by their ids")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Success"),
            @ApiResponse(responseCode = "401", description = "Unauthorized", content = @Content)
    })
    @PostMapping("/search")
    public List<PureUserResponse> searchUsers(@RequestHeader("Authorization") String authHeader, @RequestBody SearchRequest request) {
        try {
            LOGGER.debug("Starting /search");
            LOGGER.debug("Searching for \"{}\"", request.getText());
            List<User> users = userRepository.searchUsers(request.getText());
            List<PureUserResponse> response = new ArrayList<>();
            for (User user : users) {
                LOGGER.debug("Found user: {}", user);
                PureUserResponse pureUser = new PureUserResponse();
                pureUser.setId(user.getId());
                pureUser.setUsername(user.getUsername());
                pureUser.setFirstName(user.getFirstName());
                pureUser.setLastName(user.getLastName());
                pureUser.setPictureUrl(user.getPictureUrl());
                response.add(pureUser);
            }
            return response;
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Exception upon listing users", e);
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
            LOGGER.debug("Starting PATCHing user");
            if (!isUserAuthorized(authHeader, request.getId())) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
            }

            LOGGER.debug("Searching for user {}", request.getId());
            User user = userRepository.findById(request.getId()).orElseThrow(
                    () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User with this uuid was not found")
            );

            LOGGER.debug("User found, patching...");
            if (request.getUsername() != null) {
                user.setUsername(request.getUsername());
                LOGGER.debug("Patched username: {}", user.getUsername());
            }
            if (request.getBirthDate() != null) {
                user.setBirthDate(request.getBirthDate());
                LOGGER.debug("Patched birthDate: {}", user.getBirthDate());
            }
            if (request.getBio() != null) {
                user.setBio(request.getBio());
                LOGGER.debug("Patched bio: {}", user.getBio());
            }
            if (request.getLastName() != null) {
                user.setLastName(request.getLastName());
                LOGGER.debug("Patched lastName: {}", user.getLastName());
            }
            if (request.getFirstName() != null) {
                user.setFirstName(request.getFirstName());
                LOGGER.debug("Patched firstName: {}", user.getFirstName());
            }
            if (request.getPictureUrl() != null) {
                user.setPictureUrl(request.getPictureUrl());
                LOGGER.debug("Patched pictureUrl: {}", user.getPictureUrl());
            }
            if (request.getEmail() != null) {
                user.setEmail(request.getEmail());
                LOGGER.debug("Patched email: {}", user.getEmail());
            }
            userRepository.save(user);
            LOGGER.debug("Saved patch!");

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
    @DeleteMapping("/{userId}")
    @Transactional
    public ResponseEntity<Void> deleteUser( @RequestHeader("Authorization") String authHeader, @PathVariable UUID userId) {
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
        LOGGER.debug("Checking if user {} is authorized to modify {}", uuidFromJWT, userId);
        return (!onlyAdmin && uuidFromJWT.equals(userId)) || false; // todo: replace with admins' privileges check
    }

    private String extractBearerToken(String authHeader) {
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            return authHeader.substring(7);
        }
        throw new IllegalArgumentException("Invalid Authorization header");
    }
}
