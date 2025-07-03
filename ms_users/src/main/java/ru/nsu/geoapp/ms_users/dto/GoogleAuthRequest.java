package ru.nsu.geoapp.ms_users.dto;

import lombok.Data;

@Data
public class GoogleAuthRequest {
    private String token;

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }
}
