package ru.nsu.geoapp.ms_users.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import ru.nsu.geoapp.ms_users.model.GoogleAuthData;

import java.util.Optional;
import java.util.UUID;

public interface GoogleAuthRepository extends JpaRepository<GoogleAuthData, GoogleAuthData.GoogleAuthId> {
    Optional<GoogleAuthData> findById_GoogleSubject(String googleSubject);

    @Modifying
    @Query("DELETE FROM GoogleAuth ga WHERE ga.userId = :userId")
    void deleteById_UserId(@Param("userId") UUID userId);
}
