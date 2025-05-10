package ru.nsu.geoapp.ms_users;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import ru.nsu.geoapp.ms_users.dto.*;

import java.util.Date;
import java.util.Map;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final GoogleTokenVerifier googleTokenVerifier;
    private final JwtTokenService jwtTokenService;

    private static final Logger LOGGER = LoggerFactory.getLogger(AuthController.class);


    public AuthController(GoogleTokenVerifier googleTokenVerifier,
                          JwtTokenService jwtTokenService) {
        this.googleTokenVerifier = googleTokenVerifier;
        this.jwtTokenService = jwtTokenService;
    }

    @PostMapping("/google")
    public ResponseEntity<AuthResponse> authenticateWithGoogle(@RequestBody GoogleAuthRequest request) {
        try {
            LOGGER.debug("Starting to verify GJWT: {}", request.getToken().substring(52, 60) + "...");
            // Verify Google JWT
            GoogleIdToken.Payload payload = googleTokenVerifier.verify(request.getToken());
            LOGGER.debug("GJWT verified, seems legit. Generating internal JWTs");

            // Generate internal JWTs
            JwtTokenService.JwtToken accessToken = jwtTokenService.generateAccessToken(payload.getEmail());
            JwtTokenService.JwtToken refreshToken = jwtTokenService.generateRefreshToken(payload.getEmail());
            LOGGER.debug(
                    "Internal JWT pair generated: {} {}",
                    accessToken.asString().substring(52, 60) + "...",
                    refreshToken.asString().substring(52, 60) + "..."
            );

            // Generate response
            AuthResponse response = new AuthResponse(
                    accessToken.asString(),
                    refreshToken.asString(),
                    accessToken.getExpiryDate().getTime() / 1000,
                    payload.getEmail(),
                    (String) payload.get("name"),
                    (String) payload.get("picture")
            );
            LOGGER.debug("Generated response: {}", response);

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            LOGGER.debug("Invalid Google token: {}", e.getMessage());
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid Google token", e);
        }
    }

    @PostMapping("/refresh")
    public ResponseEntity<RefreshResponse> refreshTokenPair(@RequestBody RefreshRequest request) {
        try {
            LOGGER.debug("Starting token refresh with refresh token: {}", request.getRefresh().substring(52, 60) + "...");

            if (!jwtTokenService.validateToken(request.getRefresh())) {
                LOGGER.debug("Invalid refresh token");
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid refresh token");
            }

            String subject = jwtTokenService.getSubjectFromToken(request.getRefresh());
            JwtTokenService.JwtToken newAccessToken = jwtTokenService.generateAccessToken(subject);
            JwtTokenService.JwtToken newRefreshToken = jwtTokenService.generateRefreshToken(subject);

            RefreshResponse response = new RefreshResponse(
                    newAccessToken.asString(),
                    newRefreshToken.asString()
            );
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            LOGGER.debug("Error upon refreshing token: {}", e.getMessage());
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Error upon refreshing token", e);
        }
    }

    @PostMapping("/revokeall")
    public ResponseEntity<Void> revokeAllTokens(@RequestHeader("Authorization") String authHeader) {
        try {
            String token = extractBearerToken(authHeader);
            String subject = jwtTokenService.getSubjectFromToken(token);
            jwtTokenService.getRedisTokenService().revokeAllTokensForUser(subject);
            LOGGER.debug("Revoked tokens for {}", subject);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            LOGGER.error("Could not revoke tokens: {}", e.getMessage());
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Error upon revokening tokens", e);
        }
    }

    @PostMapping("/validate")
    public ResponseEntity<ValidateResponse> validateToken(@RequestBody ValidateRequest request) {
        try {
            LOGGER.debug("Starting token validation: {}", request.getToken().substring(52, 60) + "...");

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
        } catch (Exception e) {
            LOGGER.debug("Could not validate token: {}", e.getMessage());
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Exception upon validating token", e);
        }
    }

    @GetMapping(value = "/validate", produces = MediaType.TEXT_PLAIN_VALUE)
    public ResponseEntity<?> getPublicKey() {
        return ResponseEntity.ok(jwtTokenService.getPublicKey());
    }

    private String extractBearerToken(String authHeader) {
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            return authHeader.substring(7);
        }
        throw new IllegalArgumentException("Invalid Authorization header");
    }
}
