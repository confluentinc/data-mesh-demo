package io.confluent.demo.datamesh.model;

public class UseCase {
    private final String description;
    private final String name;
    private final String inputs;
    private final String ksqlDbCommand;
    private final String outputTopic;
    private final String ksqlDbLaunchUrl;
    private final String title;

    public UseCase(String description, String name, String inputs,
                   String ksqlDbCommand, String outputTopic, String ksqlDbLaunchUrl,
                   String title) {
        this.description = description;
        this.name = name;
        this.inputs = inputs;
        this.ksqlDbCommand = ksqlDbCommand;
        this.outputTopic = outputTopic;
        this.ksqlDbLaunchUrl = ksqlDbLaunchUrl;
        this.title = title;
    }
    public String getDescription() {return this.description;}
    public String getName() {return this.name;}
    public String getInputs() {return this.inputs;}
    public String getKsqlDbCommand() {return this.ksqlDbCommand;}
    public String getOutputTopic() {return this.outputTopic;}
    public String getKsqlDbLaunchUrl() {return this.ksqlDbLaunchUrl;}
    public String getTitle() {return this.title;}
}
