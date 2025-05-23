package ru.nsu.geoapp.ms_users.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.nsu.geoapp.ms_users.model.GoogleAuthData;

import java.util.Optional;

public interface GoogleAuthRepository extends JpaRepository<GoogleAuthData, GoogleAuthData.GoogleAuthId> {
    Optional<GoogleAuthData> findById_GoogleSubject(String googleSubject);
}
