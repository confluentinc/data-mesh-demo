package io.confluent.demo.datamesh.cc.datacatalog.model;

import io.confluent.demo.datamesh.model.AuditLogEntry;

import java.util.Optional;

public class BusinessMetadataServiceResponse {
    private final Optional<BusinessMetadataResponse[]> responses;
    private final Optional<AuditLogEntry> auditLogEntry;
    public BusinessMetadataServiceResponse(Optional<BusinessMetadataResponse[]> responses, Optional<AuditLogEntry> auditLogEntry) {
        this.responses = responses;
        this.auditLogEntry = auditLogEntry;
    }
    public Optional<BusinessMetadataResponse[]> getResponses() {return this.responses;}
    public Optional<AuditLogEntry> getAuditLogEntry() {return this.auditLogEntry;}
}
