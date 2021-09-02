package io.confluent.demo.datamesh.model;

import io.confluent.demo.datamesh.cc.urls.model.DataProductUrls;

public class DataProduct extends DataProductOrTopic {
    private final String description;
    private final String owner;
    private final DataProductUrls urls;

    public DataProduct(String name, String qualifiedName, String owner, String description,
                       DataProductUrls urls) {
        super(name, qualifiedName);
        this.description = description;
        this.owner = owner;
        this.urls = urls;
    }

    public String getOwner() {
        return owner;
    }

    public String getDescription() {
        return description;
    }

    public DataProductUrls getUrls() {return urls;}
}
