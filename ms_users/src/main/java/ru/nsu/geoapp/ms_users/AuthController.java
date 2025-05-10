package ru.nsu.geoapp.ms_users;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
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

    public AuthController(GoogleTokenVerifier googleTokenVerifier,
                          JwtTokenProvider jwtTokenProvider) {
        this.googleTokenVerifier = googleTokenVerifier;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    @PostMapping("/google")
    public ResponseEntity<AuthResponse> authenticateWithGoogle(@RequestBody GoogleAuthRequest request) {
        try {
            // Верификация Google токена
            GoogleIdToken.Payload payload = googleTokenVerifier.verify(request.getGoogleToken());

            // Генерация внутреннего JWT
            String internalToken = jwtTokenProvider.generateToken(payload.getEmail());

            // Создание ответа
            AuthResponse response = new AuthResponse();
            response.setToken(internalToken);
            response.setEmail(payload.getEmail());
            response.setName((String) payload.get("name"));
            response.setName((String) payload.get("picture"));

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid Google token", e);
        }
    }
}
