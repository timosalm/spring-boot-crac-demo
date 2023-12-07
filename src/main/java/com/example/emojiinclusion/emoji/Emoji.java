package com.example.emojiinclusion.emoji;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

import java.util.List;
import java.util.Random;

@Entity
public class Emoji {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private String stringValue;

    public Emoji() { }

    public Emoji(String value) {
        this.stringValue = value;
    }

    private static final List<String> gender = List.of("&#128104;","&#128105;");
    private static final List<String> colors = List.of("&#127999;","&#127998;","&#127997;","&#127996;","&#127995;");

    static Emoji random() {
        var random = new Random();
        var emojiValue = gender.get(random.nextInt(gender.size())) + colors.get(random.nextInt(colors.size()));
        return new Emoji(emojiValue);
    }

    public String getStringValue() {
        return stringValue;
    }

    public void setStringValue(String value) {
        this.stringValue = value;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }
}