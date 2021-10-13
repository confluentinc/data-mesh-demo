package io.confluent.demo.datamesh.model;

import java.util.Optional;

public class AuditLogEntry {
    private final String message;
    private final String[] commands;

    public AuditLogEntry(String message, String command) {
        this(message, new String[]{command});
    }
    public AuditLogEntry(String message) {
        this(message, new String[0]);
    }
    public AuditLogEntry(String message, String[] commands) {
        this.message = message;
        this.commands = commands;
    }
    public String getMessage() { return this.message; }
    public String[] getCommands() { return this.commands; }
}
