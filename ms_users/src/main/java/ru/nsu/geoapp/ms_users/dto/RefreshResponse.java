package ru.nsu.geoapp.ms_users.dto;

import lombok.Data;

@Data
public class RefreshResponse {
    private String token;
    private String refresh;


    public RefreshResponse(String token, String refresh) {
        this.token = token;
        this.refresh = refresh;
    }
}
