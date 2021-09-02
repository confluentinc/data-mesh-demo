package io.confluent.demo.datamesh.model;

public class CreateS3DataProductRequest extends CreateDataProductRequest {
    private final String config;
    public CreateS3DataProductRequest(String config) {
        this.config = config;
    }

    public String getConfig() {
        return this.config;
    }
}
