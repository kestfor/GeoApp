package ru.nsu.geoapp.ms_users;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken.Payload;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.server.ResponseStatusException;
import ru.nsu.geoapp.ms_users.dto.*;
import ru.nsu.geoapp.ms_users.model.User;
import ru.nsu.geoapp.ms_users.services.GoogleTokenVerifier;
import ru.nsu.geoapp.ms_users.services.JwtTokenService;
import ru.nsu.geoapp.ms_users.services.UserService;

import java.util.Date;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthControllerTest {

    @Mock
    private GoogleTokenVerifier googleTokenVerifier;

    @Mock
    private JwtTokenService jwtTokenService;

    @Mock
    private UserService userService;

    @Mock
    private JwtTokenService.JwtToken mockAccessToken;

    @Mock
    private JwtTokenService.JwtToken mockRefreshToken;

    @InjectMocks
    private AuthController authController;

    private User testUser;
    private Payload testPayload;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(UUID.randomUUID());
        testUser.setUsername("testuser");
        testUser.setFirstName("Test");
        testUser.setLastName("User");
        testUser.setPictureUrl("http://example.com/pic.jpg");

        testPayload = new Payload();
        testPayload.setSubject(testUser.getId().toString());
        testPayload.setEmail("test@example.com");
    }

    @Test
    void authenticateWithGoogle_Success() throws Exception {
        // Arrange
        GoogleAuthRequest request = new GoogleAuthRequest();
        request.setToken("google-token");
        when(googleTokenVerifier.verify(anyString())).thenReturn(testPayload);
        when(jwtTokenService.getUserService()).thenReturn(userService);
        when(jwtTokenService.getUserService().getOrCreateUser(any(Payload.class))).thenReturn(testUser);
        when(jwtTokenService.generateAccessToken(anyString())).thenReturn(mockAccessToken);
        when(jwtTokenService.generateRefreshToken(anyString())).thenReturn(mockRefreshToken);

        when(mockAccessToken.asString()).thenReturn("access-token");
        when(mockRefreshToken.asString()).thenReturn("refresh-token");
        when(mockAccessToken.getExpiryDate()).thenReturn(new Date(System.currentTimeMillis() + 3600000));

        // Act
        ResponseEntity<AuthResponse> response = authController.authenticateWithGoogle(request);

        // Assert
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("access-token", response.getBody().getJwt().getToken());
        assertEquals("refresh-token", response.getBody().getJwt().getRefresh());
        assertNotNull(response.getBody().getUser());
        assertEquals(testUser.getId(), response.getBody().getUser().getId());

        verify(googleTokenVerifier).verify("google-token");
        verify(jwtTokenService.getUserService()).getOrCreateUser(testPayload);
    }

    @Test
    void authenticateWithGoogle_InvalidToken() throws Exception {
        // Arrange
        GoogleAuthRequest request = new GoogleAuthRequest();
        request.setToken("invalid-token");
        when(googleTokenVerifier.verify(anyString())).thenThrow(new ResponseStatusException(HttpStatus.UNAUTHORIZED));

        // Act & Assert
        assertThrows(ResponseStatusException.class, () -> {
            authController.authenticateWithGoogle(request);
        });
    }

    @Test
    void refreshTokenPair_Success() {
        // Arrange
        RefreshRequest request = new RefreshRequest();
        request.setRefresh("valid-refresh-token");
        when(jwtTokenService.validateToken("valid-refresh-token")).thenReturn(true);
        when(jwtTokenService.getSubjectFromToken("valid-refresh-token")).thenReturn(testUser.getId().toString());
        when(jwtTokenService.generateAccessToken(testUser.getId().toString())).thenReturn(mockAccessToken);
        when(jwtTokenService.generateRefreshToken(testUser.getId().toString())).thenReturn(mockRefreshToken);

        when(mockAccessToken.asString()).thenReturn("new-access-token");
        when(mockRefreshToken.asString()).thenReturn("new-refresh-token");
        when(mockAccessToken.getExpiryDate()).thenReturn(new Date(System.currentTimeMillis() + 3600000));

        // Act
        ResponseEntity<RefreshResponse> response = authController.refreshTokenPair(request);

        // Assert
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("new-access-token", response.getBody().getToken());
        assertEquals("new-refresh-token", response.getBody().getRefresh());
    }

    @Test
    void refreshTokenPair_InvalidToken() {
        // Arrange
        RefreshRequest request = new RefreshRequest();
        request.setRefresh("invalid-refresh-token");
        when(jwtTokenService.validateToken("invalid-refresh-token")).thenReturn(false);

        // Act & Assert
        assertThrows(ResponseStatusException.class, () -> {
            authController.refreshTokenPair(request);
        });
    }

    @Test
    void revokeAllTokens_Success() {
        // Arrange
        String authHeader = "Bearer valid-token";
        when(jwtTokenService.getSubjectFromToken("valid-token")).thenReturn(testUser.getId().toString());
        when(jwtTokenService.getUserService()).thenReturn(userService);
        when(userService.findBySubject(testUser.getId().toString())).thenReturn(testUser);
        doNothing().when(userService).revokeAllTokensForUser(testUser);

        // Act
        ResponseEntity<Void> response = authController.revokeAllTokens(authHeader);

        // Assert
        assertEquals(HttpStatus.OK, response.getStatusCode());
        verify(userService).revokeAllTokensForUser(testUser);
    }

    @Test
    void revokeAllTokens_InvalidHeader() {
        // Arrange
        String authHeader = "InvalidHeader";

        // Act & Assert
        assertThrows(ResponseStatusException.class, () -> {
            authController.revokeAllTokens(authHeader);
        });
    }

    @Test
    void revokeAllTokens_UserNotFound() {
        // Arrange
        String authHeader = "Bearer valid-token";
        when(jwtTokenService.getSubjectFromToken("valid-token")).thenReturn(testUser.getId().toString());
        when(jwtTokenService.getUserService()).thenReturn(userService);
        when(jwtTokenService.getUserService().findBySubject(testUser.getId().toString())).thenReturn(null);

        // Act & Assert
        assertThrows(ResponseStatusException.class, () -> {
            authController.revokeAllTokens(authHeader);
        });
    }

    @Test
    void validateToken_Success() {
        // Arrange
        ValidateRequest request = new ValidateRequest();
        request.setToken("valid-token");
        when(jwtTokenService.validateToken("valid-token")).thenReturn(true);
        Date issuedDate = new Date(System.currentTimeMillis() - 10000);
        Date expirationDate = new Date(System.currentTimeMillis() + 3600000);
        when(jwtTokenService.getIssuedDateFromToken("valid-token")).thenReturn(issuedDate);
        when(jwtTokenService.getExpirationDateFromToken("valid-token")).thenReturn(expirationDate);

        // Act
        ResponseEntity<ValidateResponse> response = authController.validateToken(request);

        // Assert
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals(issuedDate.getTime() / 1000, response.getBody().getIssuedAt());
        assertEquals(expirationDate.getTime() / 1000, response.getBody().getExpiresAt());
    }

    @Test
    void validateToken_InvalidToken() {
        // Arrange
        ValidateRequest request = new ValidateRequest();
        request.setToken("invalid-token");

        // Act & Assert
        assertThrows(ResponseStatusException.class, () -> {
            authController.validateToken(request);
        });
    }

    @Test
    void getPublicKey_Success() {
        // Arrange
        when(jwtTokenService.getPublicKey()).thenReturn("public-key");

        // Act
        ResponseEntity<?> response = authController.getPublicKey();

        // Assert
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("public-key", response.getBody());
    }

    @Test
    void extractBearerToken_ValidHeader() {
        // Act
        String result = authController.extractBearerToken("Bearer token123");

        // Assert
        assertEquals("token123", result);
    }

    @Test
    void extractBearerToken_InvalidHeader() {
        // Act & Assert
        assertThrows(IllegalArgumentException.class, () -> {
            authController.extractBearerToken("InvalidHeader");
        });
    }

    @Test
    void extractBearerToken_NullHeader() {
        // Act & Assert
        assertThrows(IllegalArgumentException.class, () -> {
            authController.extractBearerToken(null);
        });
    }
}
