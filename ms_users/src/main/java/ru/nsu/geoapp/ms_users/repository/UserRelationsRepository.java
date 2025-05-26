package ru.nsu.geoapp.ms_users.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import ru.nsu.geoapp.ms_users.model.UserRelations;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface UserRelationsRepository extends JpaRepository<UserRelations, UserRelations.UserRelationId> {
    List<UserRelations> findById_UserId(UUID userId);
    List<UserRelations> findById_OtherId(UUID otherId);

    @Modifying
    void deleteById_UserId(@Param("userId") UUID userId);
    @Modifying
    void deleteById_OtherId(@Param("otherId") UUID otherId);
}
