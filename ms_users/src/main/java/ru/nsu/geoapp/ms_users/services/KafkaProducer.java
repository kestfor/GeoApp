package ru.nsu.geoapp.ms_users.services;

import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import ru.nsu.geoapp.ms_users.dto.FriendResponseMessage;

@Service
public class KafkaProducer {
    private final KafkaTemplate<String, FriendResponseMessage> kafkaTemplate;

    public KafkaProducer(KafkaTemplate<String, FriendResponseMessage> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    public void send(FriendResponseMessage event) {
        kafkaTemplate.send("user.events", event);
    }
}
