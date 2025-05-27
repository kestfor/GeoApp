package ru.nsu.geoapp.ms_users.dto;

import lombok.Data;

@Data
public class AuthResponse {
    private JWTData jwt;
    private UserResponse user;

    @Data
    public static class JWTData {
        private String token;
        private long exp;
        private String refresh;

        public JWTData(String token, long exp, String refresh) {
            this.token = token;
            this.exp = exp;
            this.refresh = refresh;
        }
    }

    public AuthResponse(String token, String refresh, long exp, UserResponse user) {
        this.jwt = new JWTData(token, exp, refresh);
        this.user = user;
    }
}