package io.confluent.demo.datamesh.model;

import io.confluent.demo.datamesh.cc.datacatalog.model.DataProductTag;

public class CreateTopicDataProductRequest extends CreateDataProductRequest {
    private final String qualifiedName;
    public CreateTopicDataProductRequest(
            String qualifiedName, DataProductTag dataProductTag) {
        this.setDataProductTag(dataProductTag);
        this.qualifiedName = qualifiedName;
    }
    public String getQualifiedName() {
        return this.qualifiedName;
    }
}