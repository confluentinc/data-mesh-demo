package io.confluent.demo.datamesh.model;

import io.confluent.demo.datamesh.cc.schemaregistry.model.Schema;
import io.confluent.demo.datamesh.cc.urls.model.DataProductUrls;

public class DataProduct extends DataProductOrTopic {
    public static String DataProductTagName = "ProdDP";
    public static String DataProductBusinessMetadataName = "DataProduct";
    private final String description;
    private final String owner;
    private final String domain;
    private final String sla;
    private final String quality;
    private final DataProductUrls urls;
    private final Schema schema;

    public DataProduct(String name, String qualifiedName, String owner, String description,
                       DataProductUrls urls, Schema schema, String domain, String sla, String quality) {
        super(name, qualifiedName);
        this.description = description;
        this.owner = owner;
        this.urls = urls;
        this.schema = schema;
        this.domain = domain;
        this.sla = sla;
        this.quality = quality;
    }

    public String getOwner() {
        return this.owner;
    }
    public String getDescription() {
        return this.description;
    }
    public DataProductUrls getUrls() {return this.urls;}
    public Schema getSchema() {return this.schema;}
    public String getDomain() {return this.domain;}
    public String getSla() {return this.sla;}
    public String getQuality() {return this.quality;}
}
