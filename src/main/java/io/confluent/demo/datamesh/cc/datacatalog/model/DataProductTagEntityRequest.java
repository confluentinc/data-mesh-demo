package io.confluent.demo.datamesh.cc.datacatalog.model;

public class DataProductTagEntityRequest {
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

    public DataProductTagEntityRequest(String entityName, DataProductTag tag) {
        this.entityName = entityName;
        this.attributes = new Attributes(
                tag.getOwner(), tag.getDescription(),
                tag.getDomain(), tag.getSla(), tag.getQuality());
    }

    public String getEntityType() {return "sr_subject_version";}
    public String getEntityName() {return this.entityName;}
    public String getTypeName() {return "DataProduct";}
    public Attributes getAttributes() {return this.attributes;}
}
