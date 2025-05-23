package ru.nsu.geoapp.ms_events.client.kafka;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import ru.nsu.geoapp.ms_events.client.kafka.messages.PostCreatedMessage;
import ru.nsu.geoapp.ms_events.model.Event;

import java.util.Map;
import java.util.UUID;

@Component
public class KafkaClient {
    private final KafkaMessageProducer<PostCreatedMessage> producer;
    private RestTemplate restTemplate;

    public KafkaClient(RestTemplate restTemplate,
                       @Value("${kafka.url}") String kafkaUrl) {
        this.producer = new KafkaMessageProducer<>(kafkaUrl
        );
    }


    public void sendNotification(Event event) {

        PostCreatedMessage notification = new PostCreatedMessage(
                event.getOwnerId().toString(),
                "",
                event.getId().toString(),
                event.getName(),
                event.getDescription(),
                event.getParticipantIds().stream().map(UUID::toString).toList()
        );
        String topicName = "posts.events";
        producer.send(topicName, event.getId().toString(), notification);
    }
}
