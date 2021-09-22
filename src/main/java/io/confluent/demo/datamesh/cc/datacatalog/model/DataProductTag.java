package io.confluent.demo.datamesh.cc.datacatalog.model;

public class DataProductTag {

    private final String owner;
    private final String description;
    private final String domain;
    private final String sla;
    private final String quality;

    public DataProductTag(String owner, String description, String domain, String sla, String quality) {
        this.owner = owner;
        this.description = description;
        this.domain = domain;
        this.sla = sla;
        this.quality = quality;
    }

    public String getOwner() {return this.owner;}
    public String getDescription() {return this.description;}
    public String getDomain() {return this.domain;}
    public String getQuality() {return this.quality;}
    public String getSla() {return this.sla;}
}
