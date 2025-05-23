package ru.nsu.geoapp.ms_users;

import org.springframework.stereotype.Service;
import ru.nsu.geoapp.ms_users.model.User;
import ru.nsu.geoapp.ms_users.repository.UserRepository;

import java.util.List;

@Service
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public List<User> findAll() {
        return userRepository.findAll();
    }

    public User save(User user) {
        return userRepository.save(user);
    }

    public User findBySubject(String subject) {
        return userRepository.findByUsername(subject);
    }

    public void revokeAllTokensForUser(User user) {
        long currentTime = System.currentTimeMillis();
        user.setRevokenDate(currentTime);
    }
}