package ru.nsu.geoapp.ms_users;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import ru.nsu.geoapp.ms_users.dto.*;
import ru.nsu.geoapp.ms_users.model.User;
import ru.nsu.geoapp.ms_users.services.GoogleTokenVerifier;
import ru.nsu.geoapp.ms_users.services.JwtTokenService;

import java.util.Date;

@RestController
@RequestMapping("/auth")
@Tag(name = "Auth Controller", description = "Operations with user authentication")
public class AuthController {

    private final GoogleTokenVerifier googleTokenVerifier;
    private final JwtTokenService jwtTokenService;

    private static final Logger LOGGER = LoggerFactory.getLogger(AuthController.class);


    public AuthController(GoogleTokenVerifier googleTokenVerifier,
                          JwtTokenService jwtTokenService) {
        this.googleTokenVerifier = googleTokenVerifier;
        this.jwtTokenService = jwtTokenService;
    }

    @Operation(summary = "Get internal auth and refresh tokens from google auth")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Valid Google JWT, user authenticated"),
            @ApiResponse(responseCode = "401", description = "Invalid Google JWT", content = @Content)
    })
    @PostMapping("/google")
    public ResponseEntity<AuthResponse> authenticateWithGoogle(@RequestBody GoogleAuthRequest request) {
        try {
            LOGGER.debug("Starting to verify GJWT: {}", request.getToken());
            // Verify Google JWT
            GoogleIdToken.Payload payload = googleTokenVerifier.verify(request.getToken());
            LOGGER.debug("GJWT verified, seems legit. Generating internal JWTs");

            User user = jwtTokenService.getUserService().getOrCreateUser(payload);

            // Generate internal JWTs
            JwtTokenService.JwtToken accessToken = jwtTokenService.generateAccessToken(user.getId().toString());
            JwtTokenService.JwtToken refreshToken = jwtTokenService.generateRefreshToken(user.getId().toString());
            LOGGER.debug("Internal JWT pair generated: {} {}", accessToken, refreshToken);

            UserResponse userResponse = new UserResponse();
            userResponse.setId(user.getId());
            userResponse.setUsername(user.getUsername());
            userResponse.setFirstName(user.getFirstName());
            userResponse.setLastName(user.getLastName());
            userResponse.setPictureUrl(user.getPictureUrl());

            userResponse.setRelationType("NONE");
            userResponse.setBio(user.getBio());
            userResponse.setBirthDate(user.getBirthDate());

            // Generate response
            AuthResponse response = new AuthResponse(
                    accessToken.asString(),
                    refreshToken.asString(),
                    accessToken.getExpiryDate().getTime() / 1000,
                    userResponse
            );
            LOGGER.debug("Generated response: {}", response);

            return ResponseEntity.ok(response);
        } catch (ResponseStatusException e) {
            throw e;
        } catch (Exception e) {
            LOGGER.debug("Invalid Google token: {}", e.getMessage());
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Invalid Google token", e);
        }
    }

    @Operation(summary = "Refresh tokens' pair")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Tokens refreshed"),
            @ApiResponse(responseCode = "401", description = "Invalid refresh token", content = @Content)
    })
    @PostMapping("/refresh")
    public ResponseEntity<RefreshResponse> refreshTokenPair(@RequestBody RefreshRequest request) {
        try {
            LOGGER.debug("Starting token refresh with refresh token: {}", request.getRefresh());

            if (!jwtTokenService.validateToken(request.getRefresh())) {
                LOGGER.debug("Invalid refresh token");
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid refresh token");
            }

            String subject = jwtTokenService.getSubjectFromToken(request.getRefresh());
            JwtTokenService.JwtToken newAccessToken = jwtTokenService.generateAccessToken(subject);
            JwtTokenService.JwtToken newRefreshToken = jwtTokenService.generateRefreshToken(subject);

            RefreshResponse response = new RefreshResponse(
                    newAccessToken.asString(),
                    newAccessToken.getExpiryDate().getTime() / 1000,
                    newRefreshToken.asString()
            );
            return ResponseEntity.ok(response);
        } catch (ResponseStatusException e) {
            throw e;
        } catch (Exception e) {
            LOGGER.debug("Error upon refreshing token: {}", e.getMessage());
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Error upon refreshing token", e);
        }
    }

    @Operation(summary = "Revoke every valid token from user")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Tokens revoked"),
            @ApiResponse(responseCode = "401", description = "Invalid auth token", content = @Content),
            @ApiResponse(responseCode = "500", description = "Internal Server Error upon revoking tokens", content = @Content)
    })
    @PostMapping("/revokeall")
    public ResponseEntity<Void> revokeAllTokens(@RequestHeader("Authorization") String authHeader) {
        try {
            String token = extractBearerToken(authHeader);
            String subject = jwtTokenService.getSubjectFromToken(token);
            User user = jwtTokenService.getUserService().findBySubject(subject);
            if (user == null) {
                throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Could not find user with uuid " + subject);
            }
            jwtTokenService.getUserService().revokeAllTokensForUser(user);
            LOGGER.debug("Revoked tokens for {}", subject);
            return ResponseEntity.ok().build();
        } catch (ResponseStatusException e) {
            throw e;
        } catch (Exception e) {
            LOGGER.error("Could not revoke tokens: {}", e.getMessage());
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Error upon revokening tokens", e);
        }
    }

    @Operation(summary = "Validate any token (either auth or refresh)")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Token is valid"),
            @ApiResponse(responseCode = "401", description = "Token is invalid", content = @Content),
            @ApiResponse(responseCode = "500", description = "Internal Server Error upon validating token", content = @Content)
    })
    @PostMapping("/validate")
    public ResponseEntity<ValidateResponse> validateToken(@RequestBody ValidateRequest request) {
        try {
            LOGGER.debug("Starting token validation: {}", request.getToken());

            if (!jwtTokenService.validateToken(request.getToken())) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
            }

            Date issuedDate = jwtTokenService.getIssuedDateFromToken(request.getToken());
            Date expirationDate = jwtTokenService.getExpirationDateFromToken(request.getToken());
            ValidateResponse response = new ValidateResponse(
                    issuedDate.getTime() / 1000,
                    expirationDate.getTime() / 1000
            );
            return ResponseEntity.ok(response);
        } catch (ResponseStatusException e) {
            throw e;
        } catch (Exception e) {
            LOGGER.debug("Could not validate token: {}", e.getMessage());
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Exception upon validating token", e);
        }
    }

    @Operation(summary = "Get Public Key that is used to validate jwt sign")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Returns Public Key")
    })
    @GetMapping(value = "/validate", produces = MediaType.TEXT_PLAIN_VALUE)
    public ResponseEntity<?> getPublicKey() {
        return ResponseEntity.ok(jwtTokenService.getPublicKey());
    }

    String extractBearerToken(String authHeader) {
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            return authHeader.substring(7);
        }
        throw new IllegalArgumentException("Invalid Authorization header");
    }
}
