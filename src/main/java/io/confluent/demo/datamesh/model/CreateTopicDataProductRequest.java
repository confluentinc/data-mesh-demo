package io.confluent.demo.datamesh.model;

import io.confluent.demo.datamesh.cc.datacatalog.model.DataProductBusinessMetadata;

public class CreateTopicDataProductRequest extends CreateDataProductRequest {
    private final String qualifiedName;

    public CreateTopicDataProductRequest(
            String qualifiedName, DataProductBusinessMetadata dataProductBusinessMetadata) {
        this.setDataProductBusinessMetadata(dataProductBusinessMetadata);
        this.qualifiedName = qualifiedName;
    }
    public String getQualifiedName() {
        return this.qualifiedName;
    }

    public String getTopicName() { return this.qualifiedName.split(":")[2];}
}