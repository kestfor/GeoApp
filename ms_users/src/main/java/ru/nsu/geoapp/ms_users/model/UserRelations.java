package ru.nsu.geoapp.ms_users.model;

import jakarta.persistence.*;
import lombok.*;

import java.io.Serializable;
import java.util.Date;
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

    @Column(name = "updated_at")
    private Date updatedAt;

    @Column(nullable = false)
    private String status; // "friend", "request_sent", "request_received"
}
