package io.confluent.demo.datamesh.model;

import io.confluent.demo.datamesh.cc.urls.model.DataProductUrls;

public class DataProduct {
    private final String qualifiedName;
    private final String name;
    private final String description;
    private final String owner;
    private final DataProductUrls urls;

    public DataProduct(String name, String qualifiedName, String owner, String description,
                       DataProductUrls urls) {
        this.name = name;
        this.qualifiedName = qualifiedName;
        this.description = description;
        this.owner = owner;
        this.urls = urls;
    }

    public String getName() { return name; }

    /**
     * Qualified name is useful for further reference in the catalog API
     */
    public String getQualifiedName() {
        return qualifiedName;
    }

    public String getOwner() {
        return owner;
    }

    public String getDescription() {
        return description;
    }

    public DataProductUrls getUrls() {return urls;}
}
