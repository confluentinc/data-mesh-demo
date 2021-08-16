package io.confluent.demo.datamesh.model;

public class CreateKsqlDbDataProductRequest extends CreateDataProductRequest {
    private final String command;
    private final String dataProductName;
    public CreateKsqlDbDataProductRequest(String name, String command, String dataProductName) {
        setName(name);
        this.command = command;
        this.dataProductName = dataProductName;
    }
    public String getCommand() {
        return this.command;
    }
    public String getDataProductName() {return this.dataProductName;}
}
