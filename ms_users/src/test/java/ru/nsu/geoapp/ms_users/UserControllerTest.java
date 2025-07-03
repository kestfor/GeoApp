package ru.nsu.geoapp.ms_users;

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
import ru.nsu.geoapp.ms_users.model.UserRelations;
import ru.nsu.geoapp.ms_users.repository.GoogleAuthRepository;
import ru.nsu.geoapp.ms_users.repository.UserRelationsRepository;
import ru.nsu.geoapp.ms_users.repository.UserRepository;
import ru.nsu.geoapp.ms_users.services.JwtTokenService;
import ru.nsu.geoapp.ms_users.services.KafkaProducer;

import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserControllerTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private GoogleAuthRepository googleAuthRepository;

    @Mock
    private UserRelationsRepository userRelationsRepository;

    @Mock
    private JwtTokenService jwtTokenService;

    @Mock
    private KafkaProducer kafkaProducer;

    @InjectMocks
    private UserController userController;

    private User testUser;
    private User anotherUser;
    private UserRelations.UserRelationId relationIdA2B;
    private UserRelations.UserRelationId relationIdB2A;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(UUID.randomUUID());
        testUser.setUsername("testuser");
        testUser.setFirstName("Test");
        testUser.setLastName("User");
        testUser.setEmail("test@example.com");
        testUser.setPictureUrl("http://example.com/pic.jpg");

        anotherUser = new User();
        anotherUser.setId(UUID.randomUUID());
        anotherUser.setUsername("anotheruser");
        anotherUser.setFirstName("Another");
        anotherUser.setLastName("User");
        anotherUser.setEmail("another@example.com");

        relationIdA2B = new UserRelations.UserRelationId();
        relationIdA2B.setUserId(testUser.getId());
        relationIdA2B.setOtherId(anotherUser.getId());

        relationIdB2A = new UserRelations.UserRelationId();
        relationIdB2A.setUserId(anotherUser.getId());
        relationIdB2A.setOtherId(testUser.getId());
    }

    @Test
    void createUser_Success() {
        // Arrange
        CreateRequest request = new CreateRequest();
        request.setUsername("newuser");
        request.setEmail("new@example.com");
        request.setFirstName("New");
        request.setLastName("User");

        when(jwtTokenService.getSubjectFromToken(anyString())).thenReturn(testUser.getId().toString());
        /*when(userRepository.save(any(User.class))).thenAnswer(invocation -> {
            User user = invocation.getArgument(0);
            user.setId(UUID.randomUUID());
            return user;
        });*/

        // Act & Assert
        assertThrows(ResponseStatusException.class, () -> {
            userController.createUser("Bearer token", request);
        });

        // todo: replace with check for admin privileges
        /*
        // Act
        ResponseEntity<CreatedUserResponse> response = userController.createUser("Bearer token", request);

        // Assert
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertNotNull(response.getBody().getId());

        verify(userRepository).save(any(User.class));*/
    }

    @Test
    void createUser_Unauthorized() {
        // Arrange
        CreateRequest request = new CreateRequest();
        request.setUsername("newuser");
        request.setEmail("new@example.com");
        request.setFirstName("New");
        request.setLastName("User");

        when(jwtTokenService.getSubjectFromToken(anyString())).thenReturn(testUser.getId().toString());

        // Act & Assert
        assertThrows(ResponseStatusException.class, () -> {
            userController.createUser("Bearer token", request);
        });
    }

    @Test
    void readUser_Success() {
        // Arrange
        when(jwtTokenService.getSubjectFromToken(anyString())).thenReturn(testUser.getId().toString());
        when(userRepository.findById(testUser.getId())).thenReturn(Optional.of(testUser));
        when(userRepository.findById(anotherUser.getId())).thenReturn(Optional.of(anotherUser));
        when(userRelationsRepository.findById(any())).thenReturn(Optional.empty());

        // Act
        ResponseEntity<UserResponse> response = userController.readUser("Bearer token", anotherUser.getId());

        // Assert
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals(anotherUser.getId(), response.getBody().getId());
        assertEquals("NONE", response.getBody().getRelationType());
    }

    @Test
    void readUser_NotFound() {
        // Arrange
        when(jwtTokenService.getSubjectFromToken(anyString())).thenReturn(testUser.getId().toString());
        when(userRepository.findById(testUser.getId())).thenReturn(Optional.of(testUser));
        when(userRepository.findById(anotherUser.getId())).thenReturn(Optional.empty());

        // Act
        ResponseEntity<UserResponse> response = userController.readUser("Bearer token", anotherUser.getId());

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
    }

    @Test
    void readUsers_Success() {
        // Arrange
        List<UUID> userIds = Arrays.asList(testUser.getId(), anotherUser.getId());
        when(userRepository.findById(testUser.getId())).thenReturn(Optional.of(testUser));
        when(userRepository.findById(anotherUser.getId())).thenReturn(Optional.of(anotherUser));

        // Act
        List<PureUserResponse> response = userController.readUsers("Bearer token", userIds);

        // Assert
        assertEquals(2, response.size());
        assertEquals(testUser.getId(), response.get(0).getId());
        assertEquals(anotherUser.getId(), response.get(1).getId());
    }

    @Test
    void readUsersFriends_Success() {
        // Arrange
        UserRelations relation = new UserRelations();
        relation.setId(relationIdA2B);
        relation.setStatus("friends");

        when(userRelationsRepository.findById_UserId(testUser.getId())).thenReturn(Collections.singletonList(relation));
        when(userRepository.findById(anotherUser.getId())).thenReturn(Optional.of(anotherUser));

        // Act
        List<PureUserResponse> response = userController.readUsersFriends("Bearer token", testUser.getId());

        // Assert
        assertEquals(1, response.size());
        assertEquals(anotherUser.getId(), response.get(0).getId());
    }

    @Test
    void searchUsers_Success() {
        // Arrange
        SearchRequest request = new SearchRequest();
        request.setText("test");
        when(userRepository.searchUsers("test")).thenReturn(Collections.singletonList(testUser));

        // Act
        List<PureUserResponse> response = userController.searchUsers("Bearer token", request);

        // Assert
        assertEquals(1, response.size());
        assertEquals(testUser.getId(), response.get(0).getId());
    }

    @Test
    void updateUser_Success() {
        // Arrange
        UserRequest request = new UserRequest();
        request.setId(testUser.getId());
        request.setUsername("updateduser");
        request.setFirstName("Updated");

        when(jwtTokenService.getSubjectFromToken(anyString())).thenReturn(testUser.getId().toString());
        when(userRepository.findById(testUser.getId())).thenReturn(Optional.of(testUser));
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        // Act
        ResponseEntity<Void> response = userController.updateUser("Bearer token", request);

        // Assert
        assertEquals(HttpStatus.OK, response.getStatusCode());
        verify(userRepository).save(any(User.class));
    }

    @Test
    void updateUser_Unauthorized() {
        // Arrange
        UserRequest request = new UserRequest();
        request.setId(anotherUser.getId());
        request.setUsername("updateduser");

        when(jwtTokenService.getSubjectFromToken(anyString())).thenReturn(testUser.getId().toString());

        // Act & Assert
        assertThrows(ResponseStatusException.class, () -> {
            userController.updateUser("Bearer token", request);
        });
    }

    @Test
    void deleteUser_Success() {
        // Arrange
        when(jwtTokenService.getSubjectFromToken(anyString())).thenReturn(testUser.getId().toString());
        when(userRepository.existsById(testUser.getId())).thenReturn(true);

        // Act
        ResponseEntity<Void> response = userController.deleteUser("Bearer token", testUser.getId());

        // Assert
        assertEquals(HttpStatus.OK, response.getStatusCode());
        verify(userRepository).deleteById(testUser.getId());
        verify(googleAuthRepository).deleteById_UserId(testUser.getId());
        verify(userRelationsRepository).deleteById_UserId(testUser.getId());
        verify(userRelationsRepository).deleteById_OtherId(testUser.getId());
    }

    @Test
    void deleteUser_NotFound() {
        // Arrange
        when(jwtTokenService.getSubjectFromToken(anyString())).thenReturn(testUser.getId().toString());
        when(userRepository.existsById(testUser.getId())).thenReturn(false);

        // Act & Assert
        assertThrows(ResponseStatusException.class, () -> {
            userController.deleteUser("Bearer token", testUser.getId());
        });
    }

    @Test
    void updateRelation_Befriend_Success() {
        // Arrange
        RelationRequest request = new RelationRequest();
        request.setId(anotherUser.getId());
        request.setBefriend(true);

        when(jwtTokenService.getSubjectFromToken(anyString())).thenReturn(testUser.getId().toString());
        when(userRepository.findById(testUser.getId())).thenReturn(Optional.of(testUser));
        when(userRepository.findById(anotherUser.getId())).thenReturn(Optional.of(anotherUser));
        when(userRelationsRepository.findById(any())).thenReturn(Optional.empty());

        // Act
        ResponseEntity<Void> response = userController.updateRelation("Bearer token", request);

        // Assert
        assertEquals(HttpStatus.OK, response.getStatusCode());
        verify(userRelationsRepository, times(2)).save(any(UserRelations.class));
        verify(kafkaProducer, times(2)).send(any(FriendResponseMessage.class));
    }

    @Test
    void updateRelation_Unfriend_Success() {
        // Arrange
        RelationRequest request = new RelationRequest();
        request.setId(anotherUser.getId());
        request.setBefriend(false);

        UserRelations relationA2B = new UserRelations();
        relationA2B.setId(relationIdA2B);
        relationA2B.setStatus("friends");
        UserRelations relationB2A = new UserRelations();
        relationB2A.setId(relationIdB2A);
        relationB2A.setStatus("friends");

        when(jwtTokenService.getSubjectFromToken(anyString())).thenReturn(testUser.getId().toString());
        when(userRepository.findById(testUser.getId())).thenReturn(Optional.of(testUser));
        when(userRepository.findById(anotherUser.getId())).thenReturn(Optional.of(anotherUser));
        when(userRelationsRepository.findById(relationIdA2B)).thenReturn(Optional.of(relationA2B));
        when(userRelationsRepository.findById(relationIdB2A)).thenReturn(Optional.of(relationB2A));

        // Act
        ResponseEntity<Void> response = userController.updateRelation("Bearer token", request);

        // Assert
        assertEquals(HttpStatus.OK, response.getStatusCode());
        verify(userRelationsRepository, times(2)).deleteById(any());
        verify(kafkaProducer, times(2)).send(any(FriendResponseMessage.class));
    }

    @Test
    void extractBearerToken_ValidHeader() {
        // Act
        String result = userController.extractBearerToken("Bearer token123");

        // Assert
        assertEquals("token123", result);
    }

    @Test
    void extractBearerToken_InvalidHeader() {
        // Act & Assert
        assertThrows(IllegalArgumentException.class, () -> {
            userController.extractBearerToken("InvalidHeader");
        });
    }
}