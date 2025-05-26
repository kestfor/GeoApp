package ru.nsu.geoapp.ms_users.dto;

import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.Date;

@EqualsAndHashCode(callSuper = true)
@Data
public class UserResponse extends PureUserResponse {
    private String relationType;
    private String bio;
    private Date birthDate;
}
