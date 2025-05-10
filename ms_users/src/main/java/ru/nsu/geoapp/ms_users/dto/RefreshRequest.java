package ru.nsu.geoapp.ms_users.dto;

import lombok.Data;

@Data
public class RefreshRequest {
    private String refresh;

    public String getRefresh() {
        return refresh;
    }
}
