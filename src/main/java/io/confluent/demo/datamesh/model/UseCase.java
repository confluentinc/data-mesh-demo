package io.confluent.demo.datamesh.model;

public class UseCase {
    private final String description;
    private final String name;
    private final String inputs;
    private final String ksqlDbCommand;
    private final String outputTopic;
    private final String ksqlDbLaunchUrl;

    public UseCase(String description, String name, String inputs,
                   String ksqlDbCommand, String outputTopic, String ksqlDbLaunchUrl) {
        this.description = description;
        this.name = name;
        this.inputs = inputs;
        this.ksqlDbCommand = ksqlDbCommand;
        this.outputTopic = outputTopic;
        this.ksqlDbLaunchUrl = ksqlDbLaunchUrl;
    }
    public String getDescription() {return this.description;}
    public String getName() {return this.name;}
    public String getInputs() {return this.inputs;}
    public String getKsqlDbCommand() {return this.ksqlDbCommand;}
    public String getOutputTopic() {return this.outputTopic;}
    public String getKsqlDbLaunchUrl() {return this.ksqlDbLaunchUrl;}
}
