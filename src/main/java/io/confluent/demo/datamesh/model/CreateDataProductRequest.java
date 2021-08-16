package io.confluent.demo.datamesh.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;

@JsonIgnoreProperties(ignoreUnknown = true)
@JsonTypeInfo(use = JsonTypeInfo.Id.NAME, include = JsonTypeInfo.As.PROPERTY)
@JsonSubTypes( {
        @JsonSubTypes.Type(value = CreateS3DataProductRequest.class,     name = "S3"),
        @JsonSubTypes.Type(value = CreateKsqlDbDataProductRequest.class, name = "KSQLDB")
})
public abstract class CreateDataProductRequest {
    private String name;

    public CreateDataProductRequest() { }

    public void setName(String name) {
        this.name = name;
    }
    public String getName() {
        return name;
    }
}
