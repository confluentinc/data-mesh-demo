package io.confluent.demo.datamesh.cc.urls.model;

public class DataProductUrls {

    private final String schemaUrl;
    private final String portUrl;
    private final String lineageUrl;

    public DataProductUrls(String schemaUrl, String portUrl, String lineageUrl) {
        this.schemaUrl = schemaUrl;
        this.portUrl = portUrl;
        this.lineageUrl = lineageUrl;
    }

    public String getSchemaUrl() {return this.schemaUrl;}
    public String getPortUrl() {return this.portUrl;}
    public String getLineageUrl() {return this.lineageUrl;}
}
