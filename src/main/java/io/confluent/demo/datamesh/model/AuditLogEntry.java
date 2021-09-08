package io.confluent.demo.datamesh.model;

public class AuditLogEntry {
    private final String message;
    public AuditLogEntry(String message) {
        this.message = message;
    }
    public String getMessage() {return this.message;}
}
