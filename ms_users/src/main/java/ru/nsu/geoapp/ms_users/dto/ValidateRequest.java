package ru.nsu.geoapp.ms_users.dto;

import lombok.Data;

@Data
public class ValidateRequest {
    private String token;

    public String getToken() {
        return token;
    }
}
