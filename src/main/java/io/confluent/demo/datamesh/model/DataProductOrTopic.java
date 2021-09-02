package io.confluent.demo.datamesh.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
import io.confluent.demo.datamesh.cc.urls.model.DataProductUrls;

@JsonIgnoreProperties(ignoreUnknown = true)
@JsonTypeInfo(use = JsonTypeInfo.Id.NAME, include = JsonTypeInfo.As.PROPERTY)
@JsonSubTypes( {
        @JsonSubTypes.Type(value = DataProduct.class, name = "DataProduct"),
        @JsonSubTypes.Type(value = Topic.class, name = "Topic")
})
public abstract class DataProductOrTopic {
    private final String name;
    private final String qualifiedName;
    public DataProductOrTopic(String name, String qualifiedName) {
        this.name = name;
        this.qualifiedName = qualifiedName;
    }
    public String getName() { return name; }
    public String getQualifiedName() {
        return qualifiedName;
    }
}
