package ru.nsu.geoapp.ms_events.client.kafka.messages;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.List;

/**
 * Сообщение о новом комментарии к событию.
 * Аналогично классу PostCreatedMessage :contentReference[oaicite:0]{index=0}.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public class NewCommentMessage {

    @JsonProperty("from_user_id")
    @NotBlank
    private String fromUserId;

    @JsonProperty("from_username")
    @NotBlank
    private String fromUsername;

    @JsonProperty("comment")
    @NotBlank
    private String comment;

    @JsonProperty("event_id")
    @NotBlank
    private String eventId;

    @JsonProperty("event_name")
    @NotBlank
    private String eventName;

    @JsonProperty("participant_ids")
    @NotNull
    private List<String> participantIds;

    // --- Constructors ---

    public NewCommentMessage() {
    }

    public NewCommentMessage(
            String fromUserId,
            String fromUsername,
            String comment,
            String eventId,
            String eventName,
            List<String> participantIds
    ) {
        this.fromUserId = fromUserId;
        this.fromUsername = fromUsername;
        this.comment = comment;
        this.eventId = eventId;
        this.eventName = eventName;
        this.participantIds = participantIds;
    }

    public String getFromUserId() {
        return fromUserId;
    }

    public void setFromUserId(String fromUserId) {
        this.fromUserId = fromUserId;
    }

    public String getFromUsername() {
        return fromUsername;
    }

    public void setFromUsername(String fromUsername) {
        this.fromUsername = fromUsername;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
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

    public List<String> getParticipantIds() {
        return participantIds;
    }

    public void setParticipantIds(List<String> participantIds) {
        this.participantIds = participantIds;
    }
}
