package ru.nsu.geoapp.ms_events.dto;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class EventPureDTO {
    private UUID id;
    private UUID ownerId;
    private String name;
    private String descriptionShort;
    private LocalDateTime createdAt;
    //TODO: add display_photo after integration
}