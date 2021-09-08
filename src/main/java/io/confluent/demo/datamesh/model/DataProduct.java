package io.confluent.demo.datamesh.model;

import io.confluent.demo.datamesh.cc.schemaregistry.model.Schema;
import io.confluent.demo.datamesh.cc.urls.model.DataProductUrls;

public class DataProduct extends DataProductOrTopic {
    private final String description;
    private final String owner;
    private final DataProductUrls urls;
    private final Schema schema;

    public DataProduct(String name, String qualifiedName, String owner, String description,
                       DataProductUrls urls, Schema schema) {
        super(name, qualifiedName);
        this.description = description;
        this.owner = owner;
        this.urls = urls;
        this.schema = schema;
    }

    public String getOwner() {
        return owner;
    }

    public String getDescription() {
        return description;
    }

    public DataProductUrls getUrls() {return urls;}

    public Schema getSchema() {return schema;}
}
