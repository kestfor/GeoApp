package ru.nsu.geoapp.ms_users.dto;

import lombok.Data;

@Data
public class GoogleAuthRequest {
    private String googleToken;

    public String getGoogleToken() {
        return googleToken;
    }

    public void setGoogleToken(String googleToken) {
        this.googleToken = googleToken;
    }
}
