package io.confluent.demo.datamesh.cc.datacatalog.model;

public class DataProductTag {

    private final String owner;
    private final String description;
    public DataProductTag(String owner, String description) {
        this.owner = owner;
        this.description = description;
    }
    public String getOwner() {return this.owner;}
    public String getDescription() {return this.description;}
}
