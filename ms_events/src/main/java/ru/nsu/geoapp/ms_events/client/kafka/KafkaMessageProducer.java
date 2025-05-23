package ru.nsu.geoapp.ms_events.client.kafka;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.StringSerializer;

import java.util.Map;
import java.util.Properties;
import java.util.concurrent.Future;

/**
 * Универсальный продюсер для отправки сообщений в Kafka.
 * @param <T> — тип полезной нагрузки сообщений.
 */
public class KafkaMessageProducer<T> implements AutoCloseable {

    private final Producer<String, String> producer;
    private final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * Создает продюсер с указанными настройками.
     *
     * @param bootstrapServers адреса Kafka-брокеров (например, "localhost:9092")
     */
    public KafkaMessageProducer(String bootstrapServers
    //                            Map<String, Object> additionalProps
    ) {
        Properties props = new Properties();
        // Обязательные настройки
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        // Опциональные: уровень подтверждений, retries, batching
        props.put(ProducerConfig.ACKS_CONFIG, "all");
        props.put(ProducerConfig.RETRIES_CONFIG, 3);
        props.put(ProducerConfig.LINGER_MS_CONFIG, 5);
        props.put(ProducerConfig.BATCH_SIZE_CONFIG, 32_768);
        // Подмешиваем дополнительные, если есть
//        if (additionalProps != null) {
//            props.putAll(additionalProps);
//        }
        this.producer = new KafkaProducer<>(props);
    }

    /**
     * Отправляет сообщение в указанный топик. Ключом выступает строка (можно задать null).
     *
     * @param topic   имя топика
     * @param key     ключ сообщения (для партиционирования), может быть null
     * @param payload полезная нагрузка (будет сериализована в JSON)
     * @return Future<RecordMetadata> для асинхронного получения результата
     * @throws RuntimeException если не удалось сериализовать payload
     */
    public Future<RecordMetadata> send(String topic, String key, T payload) {
        String json;
        try {
            json = objectMapper.writeValueAsString(payload);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Failed to serialize payload to JSON", e);
        }
        ProducerRecord<String, String> record = new ProducerRecord<>(topic, key, json);
        return producer.send(record, this::handleCallback);
    }

    /**
     * Обработчик результата отправки.
     */
    private void handleCallback(RecordMetadata metadata, Exception exception) {
        if (exception != null) {
            // тут можно логировать ошибку, например
            System.err.printf("Error sending message to topic %s: %s%n", metadata.topic(), exception.getMessage());
        } else {
            // опционально логирование успешной отправки
            System.out.printf("Message sent to %s[%d] @ offset %d%n",
                    metadata.topic(), metadata.partition(), metadata.offset());
        }
    }

    /**
     * Блочно отправляет сообщение и ждёт подтверждения (sync).
     *
     * @param topic   имя топика
     * @param key     ключ сообщения
     * @param payload полезная нагрузка
     * @throws RuntimeException при ошибках отправки
     */
    public void sendSync(String topic, String key, T payload) {
        try {
            send(topic, key, payload).get();
        } catch (Exception e) {
            throw new RuntimeException("Failed to send message synchronously", e);
        }
    }

    /**
     * Закрывает продюсер, освобождая ресурсы.
     */
    @Override
    public void close() {
        producer.flush();
        producer.close();
    }
}
