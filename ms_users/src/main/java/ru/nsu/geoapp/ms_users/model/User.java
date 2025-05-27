package ru.nsu.geoapp.ms_users.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;
import java.util.UUID;

@Data
@NoArgsConstructor
@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, unique = true)
    private String username;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(name = "first_name", nullable = false)
    private String firstName;

    @Column(name = "last_name", nullable = false)
    private String lastName;

    @Column(name = "picture_url")
    private String pictureUrl;

    @Column(name = "birth_date")
    private Date birthDate;

    @Column(name = "bio")
    private String bio;

    @Column(name = "revoked_UTC", nullable = false)
    private Long revokedUTC;
}
