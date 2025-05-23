package ru.nsu.geoapp.ms_events.client.kafka.messages;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.List;

/**
 * Сообщение о создании нового поста для события.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public class PostCreatedMessage {

    @JsonProperty("author_id")
    @NotBlank
    private String authorId;

    @JsonProperty("author_username")
    @NotBlank
    private String authorUsername;

    @JsonProperty("event_id")
    @NotBlank
    private String eventId;

    @JsonProperty("event_name")
    @NotBlank
    private String eventName;

    @JsonProperty("event_description")
    private String eventDescription;

    @JsonProperty("participant_ids")
    @NotNull
    private List<String> participantIds;

    // --- Constructors ---

    public PostCreatedMessage() {
    }

    public PostCreatedMessage(String authorId, String authorUsername, String eventId,
                              String eventName, String eventDescription, List<String> participantIds) {
        this.authorId = authorId;
        this.authorUsername = authorUsername;
        this.eventId = eventId;
        this.eventName = eventName;
        this.eventDescription = eventDescription;
        this.participantIds = participantIds;
    }

    public String getAuthorId() {
        return authorId;
    }

    public void setAuthorId(String authorId) {
        this.authorId = authorId;
    }

    public String getAuthorUsername() {
        return authorUsername;
    }

    public void setAuthorUsername(String authorUsername) {
        this.authorUsername = authorUsername;
    }

    public String getEventId() {
        return eventId;
    }

    public void setEventId(String eventId) {
        this.eventId = eventId;
    }

    public String getEventName() {
        return eventName;
    }

    public void setEventName(String eventName) {
        this.eventName = eventName;
    }

    public String getEventDescription() {
        return eventDescription;
    }

    public void setEventDescription(String eventDescription) {
        this.eventDescription = eventDescription;
    }

    public List<String> getParticipantIds() {
        return participantIds;
    }

    public void setParticipantIds(List<String> participantIds) {
        this.participantIds = participantIds;
    }
}
