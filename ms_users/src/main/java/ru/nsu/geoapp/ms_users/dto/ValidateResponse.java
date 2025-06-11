package ru.nsu.geoapp.ms_users.dto;

import lombok.Data;

@Data
public class ValidateResponse {
    private long issuedAt;
    private long expiresAt;

    public ValidateResponse(long issuedAt, long expiresAt) {
        this.issuedAt = issuedAt;
        this.expiresAt = expiresAt;
    }
}
