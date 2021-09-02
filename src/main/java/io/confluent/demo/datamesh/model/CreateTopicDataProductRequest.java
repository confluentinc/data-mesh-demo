package io.confluent.demo.datamesh.model;

import io.confluent.demo.datamesh.cc.datacatalog.model.DataProductTag;

public class CreateTopicDataProductRequest extends CreateDataProductRequest {
    private final String qualifiedName;
    private final DataProductTag dataProductTag;

    public CreateTopicDataProductRequest(
            String name, String qualifiedName, DataProductTag dataProductTag) {
        this.setDataProductTag(dataProductTag);
        this.qualifiedName = qualifiedName;
        this.dataProductTag = dataProductTag;
    }
    public String getQualifiedName() {
        return this.qualifiedName;
    }
    public DataProductTag getDataProductTag() {
        return this.dataProductTag;
    }
}