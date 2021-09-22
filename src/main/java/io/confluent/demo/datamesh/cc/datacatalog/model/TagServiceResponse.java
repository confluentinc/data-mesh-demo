package io.confluent.demo.datamesh.cc.datacatalog.model;

import io.confluent.demo.datamesh.model.AuditLogEntry;

import java.util.Optional;

public class TagServiceResponse {
    private final Optional<TagResponse[]> responses;
    private final Optional<AuditLogEntry> auditLogEntry;
    public TagServiceResponse(Optional<TagResponse[]> responses, Optional<AuditLogEntry> auditLogEntry) {
        this.responses = responses;
        this.auditLogEntry = auditLogEntry;
    }
    public Optional<TagResponse[]> getResponses() {return this.responses;}
    public Optional<AuditLogEntry> getAuditLogEntry() {return this.auditLogEntry;}
}
