package com.example.emojiinclusion.emoji;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;

@Component
public class EmojiRepositoryPopulator implements ApplicationListener<ApplicationReadyEvent> {

    @Autowired
    DataSource dataSource;

    private final EmojiRepository emojiRepository;

    public EmojiRepositoryPopulator(EmojiRepository emojiRepository) {
        this.emojiRepository = emojiRepository;
    }

    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        this.emojiRepository.save(Emoji.random());
    }
}
