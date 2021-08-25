package io.confluent.demo.datamesh.cc.datacatalog.model;

import io.confluent.demo.datamesh.cc.datacatalog.model.DataProductTag;

public class DataProductTagEntityRequest {
    class Attributes {
        private final String owner;
        private final String description;
        public Attributes(String owner, String description) {
            this.owner = owner;
            this.description = description;
        }
        public String getOwner() {return this.owner;}
        public String getDescription() {return this.description;}
    }

    private final String entityName;
    private final Attributes attributes;

    public DataProductTagEntityRequest(String entityName, DataProductTag tag) {
        this.entityName = entityName;
        this.attributes = new Attributes(tag.getOwner(), tag.getDescription());
    }

    public String getEntityType() {return "sr_subject_version";}
    public String getEntityName() {return this.entityName;}
    public String getTypeName() {return "DataProduct";}
    public Attributes getAttributes() {return this.attributes;}
}
