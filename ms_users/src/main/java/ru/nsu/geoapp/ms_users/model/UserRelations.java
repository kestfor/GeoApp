package ru.nsu.geoapp.ms_users.model;

import jakarta.persistence.*;
import lombok.*;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@NoArgsConstructor
@Entity
@Table(name = "users_relations")
public class UserRelations {
    @Getter
    @Setter
    @NoArgsConstructor
    @EqualsAndHashCode
    @Embeddable
    public static class UserRelationId implements Serializable {
        @Column(name = "user_id", nullable = false)
        private UUID userId;

        @Column(name = "other_id", nullable = false)
        private UUID otherId;
    }

    @EmbeddedId
    private UserRelationId id;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(nullable = false)
    private String status; // "PENDING", "FRIEND", "BLOCKED"
}
