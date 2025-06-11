package ru.nsu.geoapp.ms_users.dto;

import lombok.Data;

import java.util.UUID;

@Data
public class RelationRequest {
    private UUID id;
    private boolean befriend;
}
