package io.confluent.demo.datamesh;

import io.confluent.demo.datamesh.model.AuditLogEntry;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

@Controller
public class AuditLogController {

    private final SimpMessagingTemplate messagingTemplate;

    public AuditLogController(SimpMessagingTemplate msgTemplate) {
        this.messagingTemplate = msgTemplate;
    }

    public void sendAuditLogEntry(AuditLogEntry entry) {
        messagingTemplate.convertAndSend("/topic/audit-log", entry);
    }
}
