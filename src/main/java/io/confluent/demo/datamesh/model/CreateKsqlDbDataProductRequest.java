package io.confluent.demo.datamesh.model;

import io.confluent.demo.datamesh.cc.datacatalog.model.DataProductTag;

public class CreateKsqlDbDataProductRequest extends CreateDataProductRequest {
    private final String command;
    private final String eventualSubjectName;

    public CreateKsqlDbDataProductRequest(String eventualSubjectName,
                                          String command,
                                          DataProductTag dataProductTag) {
        this.eventualSubjectName = eventualSubjectName;
        this.command = command;
    }
    public String getCommand() {
        return this.command;
    }
    public String getEventualSubjectName() {return this.eventualSubjectName;}
}
