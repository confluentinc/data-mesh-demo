package io.confluent.demo.datamesh.model;

public class Label {
    private final String name;
    public Label(String name) {
        this.name = name;
    }
    public String getName() {
        return name;
    }
}
