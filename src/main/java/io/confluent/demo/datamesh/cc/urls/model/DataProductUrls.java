package io.confluent.demo.datamesh.cc.urls.model;

public class DataProductUrls {

    private final String schemaUrl;
    private final String portUrl;
    private final String lineageUrl;
    private final String exportUrl;

    public DataProductUrls(String schemaUrl, String portUrl, String lineageUrl, String exportUrl) {
        this.schemaUrl  = schemaUrl;
        this.portUrl    = portUrl;
        this.lineageUrl = lineageUrl;
        this.exportUrl  = exportUrl;
    }

    public String getSchemaUrl() {return this.schemaUrl;}
    public String getPortUrl() {return this.portUrl;}
    public String getLineageUrl() {return this.lineageUrl;}
    public String getExportUrl() {return this.exportUrl;}
}
