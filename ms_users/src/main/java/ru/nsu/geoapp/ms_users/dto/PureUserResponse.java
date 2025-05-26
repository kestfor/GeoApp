package ru.nsu.geoapp.ms_users.dto;

import lombok.Data;

import java.util.UUID;

@Data
public class PureUserResponse {
    private UUID id;
    private String username;
    private String firstName;
    private String lastName;
    private String pictureUrl;
}
