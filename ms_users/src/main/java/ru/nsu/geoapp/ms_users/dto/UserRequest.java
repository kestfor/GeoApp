package ru.nsu.geoapp.ms_users.dto;

import lombok.Data;
import java.util.Date;
import java.util.UUID;

@Data
public class UserRequest {
    private UUID userId;
    private String username;
    private Date birthDate;
}
