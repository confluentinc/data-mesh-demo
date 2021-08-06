package io.confluent.demo.datamesh.model;

import java.util.List;

public class DataProduct {
    private final String qualifiedName;
    private final String name;
    private final String description;
    private final String owner;

    public DataProduct(String name, String qualifiedName, String owner, String description) {
        this.name = name;
        this.qualifiedName = qualifiedName;
        this.description = description;
        this.owner = owner;
    }

    public String getName() {
        // TODO: Should we infer a friendly name from the subject name.  For example,
        // the cloud quickstart creates a schema for the `pageviews' topic
        // `pageviews-value`, but the `-value` bit is an internal implementation detail.
        // I say we parse that out and return `pageviews` here
        return name;
    }

    /**
     * Qualified name is useful for further reference in the catalog API
     * @return
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
}
