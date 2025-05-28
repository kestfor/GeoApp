package ru.nsu.geoapp.ms_users.model;

import jakarta.persistence.*;
import lombok.*;

import java.io.Serializable;
import java.util.UUID;

@Data
@NoArgsConstructor
@Entity
@Table(name = "google_auth")
public class GoogleAuthData {
    @Getter
    @Setter
    @NoArgsConstructor
    @EqualsAndHashCode
    @Embeddable
    public static class GoogleAuthId implements Serializable {
        @Column(name = "user_id", nullable = false)
        private UUID userId;

        @Column(name = "google_subject", nullable = false)
        private String googleSubject;
    }

    @EmbeddedId
    private GoogleAuthId id;
}
