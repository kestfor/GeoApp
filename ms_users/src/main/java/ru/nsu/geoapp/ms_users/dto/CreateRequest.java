package ru.nsu.geoapp.ms_users.dto;

import lombok.Data;

import java.util.Date;

@Data
public class CreateRequest {
    private String username;
    private String lastName;
    private String firstName;
    private String email;
    private String pictureUrl;
    private String bio;
    private Date birthDate;
}
