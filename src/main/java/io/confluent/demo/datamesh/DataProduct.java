package io.confluent.demo.datamesh;

import java.util.List;

public class DataProduct {
    private final String qualifiedName;
    private final String name;
    private final List<Label> lables;

    public DataProduct(String name, String qualifiedName, List<Label> labels) {
        this.name = name;
        this.qualifiedName = qualifiedName;
        this.lables = labels;
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
        // TODO: read from a well known label / attribute
        return "@web";
    }

    public String getDescription() {
        // TODO: read from a well knkown label / attribute
        return "description here";
    }
}
