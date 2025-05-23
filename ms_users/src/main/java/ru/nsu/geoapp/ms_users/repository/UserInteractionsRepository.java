package ru.nsu.geoapp.ms_users.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.nsu.geoapp.ms_users.model.UserRelations;

import java.util.List;
import java.util.UUID;

public interface UserInteractionsRepository extends JpaRepository<UserRelations, UserRelations.UserRelationId> {
    List<UserRelations> findById_UserId(UUID userId);
    List<UserRelations> findById_OtherId(UUID otherId);
}
