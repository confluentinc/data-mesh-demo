package io.confluent.demo.datamesh.cc.datacatalog.model;

import io.confluent.demo.datamesh.model.DataProduct;

public class DataProductBusinessMetadataEntityRequest {
    class Attributes {

        private final String owner;
        private final String description;
        private final String domain;
        private final String sla;
        private final String quality;

        public Attributes(String owner, String description, String domain, String sla, String quality) {
            this.owner = owner;
            this.description = description;
            this.domain = domain;
            this.sla = sla;
            this.quality = quality;
        }
        public String getOwner() {return this.owner;}
        public String getDescription() {return this.description;}
        public String getDomain() {return this.domain;}
        public String getSla() {return this.sla;}
        public String getQuality() {return this.quality;}
    }

    private final String entityName;
    private final Attributes attributes;

    public DataProductBusinessMetadataEntityRequest(String entityName, DataProductBusinessMetadata tag) {
        this.entityName = entityName;
        this.attributes = new Attributes(
                tag.getOwner(), tag.getDescription(),
                tag.getDomain(), tag.getSla(), tag.getQuality());
    }

    public String getEntityType() {return "kafka_topic";}
    public String getEntityName() {return this.entityName;}
    public String getTypeName() {return DataProduct.DataProductBusinessMetadataName;}
    public Attributes getAttributes() {return this.attributes;}
}
