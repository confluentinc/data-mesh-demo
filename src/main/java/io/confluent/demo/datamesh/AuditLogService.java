package io.confluent.demo.datamesh;

import io.confluent.demo.datamesh.model.AuditLogEntry;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class AuditLogService {

    Logger logger = LoggerFactory.getLogger(AuditLogService.class);

    @Autowired
    private AuditLogController controller;

    public void sendAuditLogEntry(String logMsg, String command) {
        this.sendAuditLogEntry(new AuditLogEntry(logMsg, new String[] { command }));
    }
    public void sendAuditLogEntry(String logMsg, String[] commands) {
        this.sendAuditLogEntry(new AuditLogEntry(logMsg, commands));
    }
    public void sendAuditLogEntry(String logMsg) {
        this.sendAuditLogEntry(new AuditLogEntry(logMsg));
    }
    public void sendAuditLogEntry(AuditLogEntry entry) {
        logger.info(String.format("Sending Audit Log Entry with message: %s", entry.getMessage()));
        controller.sendAuditLogEntry(entry);
    }
}
