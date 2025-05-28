package ru.nsu.geoapp.ms_users.dto;

import lombok.Data;

@Data
public class RefreshResponse {
    private String token;
    private long exp;
    private String refresh;


    public RefreshResponse(String token, long exp, String refresh) {
        this.token = token;
        this.exp = exp;
        this.refresh = refresh;
    }
}
