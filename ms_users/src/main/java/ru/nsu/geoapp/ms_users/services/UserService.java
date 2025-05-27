package ru.nsu.geoapp.ms_users.services;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ru.nsu.geoapp.ms_users.model.GoogleAuthData;
import ru.nsu.geoapp.ms_users.model.User;
import ru.nsu.geoapp.ms_users.repository.GoogleAuthRepository;
import ru.nsu.geoapp.ms_users.repository.UserRepository;

import java.util.List;
import java.util.UUID;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final GoogleAuthRepository googleAuthRepository;

    public UserService(UserRepository userRepository, GoogleAuthRepository googleAuthRepository) {
        this.userRepository = userRepository;
        this.googleAuthRepository = googleAuthRepository;
    }

    public List<User> findAll() {
        return userRepository.findAll();
    }

    public User save(User user) {
        return userRepository.save(user);
    }

    public User findBySubject(String subject) {
        return userRepository.findById(UUID.fromString(subject)).orElse(null);
    }

    public void revokeAllTokensForUser(User user) {
        long currentTime = System.currentTimeMillis() / 1000;
        user.setRevokedUTC(currentTime);
    }

    @Transactional
    public User getOrCreateUser(GoogleIdToken.Payload payload) {
        String subject = payload.getSubject();
        GoogleAuthData googleAuthData = googleAuthRepository.findById_GoogleSubject(subject).orElse(null);
        User user;
        if (googleAuthData != null) {
            user = userRepository.findById(googleAuthData.getId().getUserId()).orElseThrow(
                    () -> new RuntimeException("Could not retrieve authorized user from db")
            );
        } else {
            user = new User();
            //user.setId(UUID.randomUUID());
            user.setEmail(payload.getEmail());
            user.setUsername((String) payload.get("name"));
            user.setFirstName((String) payload.get("given_name"));
            user.setLastName((String) payload.get("family_name"));
            user.setPictureUrl((String) payload.get("picture"));
            user.setRevokedUTC(System.currentTimeMillis()/1000 - 1);
            userRepository.save(user);

            GoogleAuthData.GoogleAuthId googleAuthId = new GoogleAuthData.GoogleAuthId();
            googleAuthId.setUserId(user.getId());
            googleAuthId.setGoogleSubject(subject);
            googleAuthData = new GoogleAuthData();
            googleAuthData.setId(googleAuthId);
            googleAuthRepository.save(googleAuthData);
        }
        return user;
    }
}