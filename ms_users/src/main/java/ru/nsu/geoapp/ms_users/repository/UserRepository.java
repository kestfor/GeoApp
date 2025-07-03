package ru.nsu.geoapp.ms_users.repository;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import ru.nsu.geoapp.ms_users.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface UserRepository extends JpaRepository<User, UUID> {
    User findByUsername(String username);
    User findByEmail(String email);
    @Query("SELECT u FROM User u WHERE " +
            "CAST(u.id AS string) LIKE %:text% OR " +
            "LOWER(u.username) LIKE LOWER(CONCAT('%', :text, '%')) OR " +
            "LOWER(u.firstName) LIKE LOWER(CONCAT('%', :text, '%')) OR " +
            "LOWER(u.lastName) LIKE LOWER(CONCAT('%', :text, '%'))")
    List<User> searchUsers(@Param("text") String text);
}
