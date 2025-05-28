package ru.nsu.geoapp.ms_users.dto;

import lombok.Data;
import ru.nsu.geoapp.ms_users.model.User;

import java.util.UUID;

@Data
public class FriendResponseMessage {
    private UUID from_user_id;
    private UUID to_user_id;
    private String from_username;
    private String to_username;
    private String status;

    public FriendResponseMessage(User from, User to, String status) {
        this.from_user_id = from.getId();
        this.to_user_id = to.getId();
        this.from_username = from.getUsername();
        this.to_username = to.getUsername();
        this.status = status;
    }
}
