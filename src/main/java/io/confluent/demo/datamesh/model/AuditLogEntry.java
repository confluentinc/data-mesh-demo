package io.confluent.demo.datamesh.model;

import java.util.Optional;

public class AuditLogEntry {
    private final String message;
    private final Optional<String[]> commands;

    public AuditLogEntry(String message) {
        this.message = message;
       this.commands = Optional.empty() ;
    }
    public AuditLogEntry(String message, String[] commands) {
        this.message = message;
        this.commands = Optional.of(commands);
    }
    public String getMessage() { return this.message; }
    public Optional<String[]> getCommands() { return this.commands; }
}
