package ru.nsu.geoapp.ms_users;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;
import ru.nsu.geoapp.ms_users.dto.AuthResponse;
import ru.nsu.geoapp.ms_users.dto.GoogleAuthRequest;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final GoogleTokenVerifier googleTokenVerifier;
    private final JwtTokenProvider jwtTokenProvider;

    private static final Logger LOGGER = LoggerFactory.getLogger(AuthController.class);


    public AuthController(GoogleTokenVerifier googleTokenVerifier,
                          JwtTokenProvider jwtTokenProvider) {
        this.googleTokenVerifier = googleTokenVerifier;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    @PostMapping("/google")
    public ResponseEntity<AuthResponse> authenticateWithGoogle(@RequestBody GoogleAuthRequest request) {
        try {
            LOGGER.debug("Starting to verify GJWT: {}", request.getToken());
            // Верификация Google токена
            GoogleIdToken.Payload payload = googleTokenVerifier.verify(request.getToken());
            LOGGER.debug("GJWT verified, seems legit. Generating local JWT");

            // Генерация внутреннего JWT
            JwtTokenProvider.JwtToken internalToken = jwtTokenProvider.generateToken(payload.getEmail());
            LOGGER.debug("Local JWT generated: {}", internalToken.asString());

            // Создание ответа
            AuthResponse response = new AuthResponse(
                    internalToken.asString(),
                    "refresh_token_here", //todo: refresh token
                    internalToken.getExpiryDate().getTime() / 1000,
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
}
