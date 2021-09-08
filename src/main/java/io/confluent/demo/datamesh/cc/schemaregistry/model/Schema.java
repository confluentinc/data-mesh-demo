package io.confluent.demo.datamesh.cc.schemaregistry.model;

public class Schema {
    public String subject;
    public int version;
    public int id;
    public String schema;

    public Schema(String subject, int version, int id, String schema) {
        this.id = id;
        this.subject = subject;
        this.schema = schema;
        this.version = version;
    }
    public String getSubject() {return this.subject;}
    public int getVersion() {return this.version;}
    public int getId() {return this.id;}
    public String getSchema(){return this.schema;}
}
