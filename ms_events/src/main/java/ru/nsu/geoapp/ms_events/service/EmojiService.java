package ru.nsu.geoapp.ms_events.service;

import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import ru.nsu.geoapp.ms_events.dto.reaction.EmojiResponseDTO;
import ru.nsu.geoapp.ms_events.model.Emoji;
import ru.nsu.geoapp.ms_events.repository.EmojiRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class EmojiService {

    private final EmojiRepository emojiRepository;

    @Autowired
    public EmojiService(EmojiRepository emojiRepository) {
        this.emojiRepository = emojiRepository;
    }

    @PostConstruct
    public void initializeEmojis() {
        if (emojiRepository.count() == 0) {
            List<Emoji> defaultEmojis = List.of(
                    new Emoji(null, "&#128077", "Like"),
                    new Emoji(null, "&#128151", "Heart"),
                    new Emoji(null, "&#128514", "Laugh"),
                    new Emoji(null, "&#128562", "Surprise"),
                    new Emoji(null, "&#128557", "Sadness"),
                    new Emoji(null, "&#128545", "Anger")
            );

            emojiRepository.saveAll(defaultEmojis);
        }
    }

    public List<EmojiResponseDTO> getAllAvailableEmojis() {
        return emojiRepository.findAll().stream()
                .map(this::mapToResponseDTO)
                .collect(Collectors.toList());
    }

    private EmojiResponseDTO mapToResponseDTO(Emoji emoji) {
        EmojiResponseDTO dto = new EmojiResponseDTO();
        dto.setId(emoji.getId());
        dto.setCode(emoji.getCode());
        dto.setDescription(emoji.getDescription());
        return dto;
    }
}
