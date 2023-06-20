package io.confluent.demo.datamesh.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
import io.confluent.demo.datamesh.cc.datacatalog.model.DataProductBusinessMetadata;

@JsonIgnoreProperties(ignoreUnknown = true)
@JsonTypeInfo(use = JsonTypeInfo.Id.NAME, include = JsonTypeInfo.As.PROPERTY)
@JsonSubTypes( {
        @JsonSubTypes.Type(value = CreateTopicDataProductRequest.class,  name = "TOPIC"),
        @JsonSubTypes.Type(value = CreateS3DataProductRequest.class,     name = "S3"),
        @JsonSubTypes.Type(value = CreateKsqlDbDataProductRequest.class, name = "KSQLDB")
})
public abstract class CreateDataProductRequest {
    private DataProductBusinessMetadata dataProductBusinessMetadata;

    public CreateDataProductRequest(DataProductBusinessMetadata tag) {
        this.setDataProductBusinessMetadata(tag);
    }
    public CreateDataProductRequest() {
    }

    public void setDataProductBusinessMetadata(DataProductBusinessMetadata dp) { this.dataProductBusinessMetadata = dp;}
    public DataProductBusinessMetadata getDataProductBusinessMetadata() {return this.dataProductBusinessMetadata;}

    public String getDescription() { return this.dataProductBusinessMetadata.getDescription(); }
    public String getOwner() { return this.dataProductBusinessMetadata.getOwner(); }

    @Override
    public String toString() {
        return "CreateDataProductRequest{" +
                "dataProductBusinessMetadata=" + dataProductBusinessMetadata +
                '}';
    }
}
