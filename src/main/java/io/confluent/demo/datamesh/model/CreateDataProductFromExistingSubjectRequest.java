package io.confluent.demo.datamesh.model;

import io.confluent.demo.datamesh.cc.datacatalog.model.DataProductTag;

public class CreateDataProductFromExistingSubjectRequest extends CreateDataProductRequest {
    private final String subjectQualifiedName;
    private final DataProductTag dataProductTag;

    public CreateDataProductFromExistingSubjectRequest(
            String name, String subjectQualifiedName, DataProductTag dataProductTag) {
        setName(name);
        this.subjectQualifiedName = subjectQualifiedName;
        this.dataProductTag = dataProductTag;
    }
    public String getSubjectQualifiedName() {
        return this.subjectQualifiedName;
    }
    public DataProductTag getDataProductTag() {
        return this.dataProductTag;
    }
}
