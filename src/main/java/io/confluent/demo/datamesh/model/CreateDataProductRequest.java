package io.confluent.demo.datamesh.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
import io.confluent.demo.datamesh.cc.datacatalog.model.DataProductTag;

@JsonIgnoreProperties(ignoreUnknown = true)
@JsonTypeInfo(use = JsonTypeInfo.Id.NAME, include = JsonTypeInfo.As.PROPERTY)
@JsonSubTypes( {
        @JsonSubTypes.Type(value = CreateTopicDataProductRequest.class,  name = "TOPIC"),
        @JsonSubTypes.Type(value = CreateS3DataProductRequest.class,     name = "S3"),
        @JsonSubTypes.Type(value = CreateKsqlDbDataProductRequest.class, name = "KSQLDB")
})
public abstract class CreateDataProductRequest {
    private DataProductTag dataProductTag;

    public CreateDataProductRequest(DataProductTag tag) {
        this.setDataProductTag(tag);
    }
    public CreateDataProductRequest() {
    }

    public void setDataProductTag(DataProductTag tag) { this.dataProductTag = tag;}
    public DataProductTag getDataProductTag() {return this.dataProductTag;}

    public String getDescription() { return this.dataProductTag.getDescription(); }
    public String getOwner() { return this.dataProductTag.getOwner(); }
}
