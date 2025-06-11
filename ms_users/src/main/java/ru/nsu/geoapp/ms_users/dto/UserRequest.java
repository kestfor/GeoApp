package ru.nsu.geoapp.ms_users.dto;

import lombok.Data;
import java.util.Date;
import java.util.UUID;

@Data
public class UserRequest {
    private UUID id;
    private String username;
    private String lastName;
    private String firstName;
    private String email;
    private String pictureUrl;
    private String bio;
    private Date birthDate;
}
