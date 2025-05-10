package ru.nsu.geoapp.ms_users.dto;

import lombok.Data;

@Data
public class AuthResponse {
    private String token;
    private String refresh;
    private long exp;
    private UserData user;

    @Data
    public static class UserData {
        private String email;
        private String name;
        private String picture;

        public UserData(String email, String name, String picture) {
            this.email = email;
            this.name = name;
            this.picture = picture;
        }
    }

    public AuthResponse(String token, String refresh, long exp, String email, String name, String picture) {
        this.token = token;
        this.refresh = refresh;
        this.exp = exp;
        this.user = new UserData(email, name, picture);
    }
}