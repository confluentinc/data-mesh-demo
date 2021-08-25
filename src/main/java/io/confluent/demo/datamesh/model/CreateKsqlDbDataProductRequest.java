package io.confluent.demo.datamesh.model;

public class CreateKsqlDbDataProductRequest extends CreateDataProductRequest {
    private final String command;

    public CreateKsqlDbDataProductRequest(String name, String command) {
        setName(name);
        this.command = command;
    }
    public String getCommand() {
        return this.command;
    }
}
