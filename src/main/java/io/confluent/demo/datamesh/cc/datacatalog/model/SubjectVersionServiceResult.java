package io.confluent.demo.datamesh.cc.datacatalog.model;

import io.confluent.demo.datamesh.model.AuditLogEntry;

import java.util.List;
import java.util.Optional;

public class SubjectVersionServiceResult {
    private List<AtlasEntityWithExtInfo> entities;
    private Optional<AuditLogEntry> auditLogEntry;
    public SubjectVersionServiceResult(List<AtlasEntityWithExtInfo> entities, Optional<AuditLogEntry> auditLogEntry) {
        this.entities = entities;
        this.auditLogEntry = auditLogEntry;
    }
    public List<AtlasEntityWithExtInfo> getEntities() {return this.entities;}
    public Optional<AuditLogEntry> getAuditLogEntry() {return this.auditLogEntry;}
}
