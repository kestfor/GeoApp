package ru.nsu.geoapp.ms_users.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import ru.nsu.geoapp.ms_users.model.UserRelations;

import java.util.List;
import java.util.UUID;

public interface UserRelationsRepository extends JpaRepository<UserRelations, UserRelations.UserRelationId> {
    List<UserRelations> findById_UserId(UUID userId);
    List<UserRelations> findById_OtherId(UUID otherId);

    @Modifying
    @Query("DELETE FROM UserRelation ur WHERE ur.userId = :userId OR ur.otherId = :userId")
    void deleteByUserIdOrOtherId(@Param("userId") UUID userId);
}
