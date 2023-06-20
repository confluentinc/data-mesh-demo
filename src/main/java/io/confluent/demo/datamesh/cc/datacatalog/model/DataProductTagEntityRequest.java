package io.confluent.demo.datamesh.cc.datacatalog.model;

import io.confluent.demo.datamesh.model.DataProduct;

public class DataProductTagEntityRequest {
    private final String entityName;

    public DataProductTagEntityRequest(String entityName) {
        this.entityName = entityName;
    }
    public String getEntityType() {return "kafka_topic";}
    public String getEntityName() {return this.entityName;}
    public String getTypeName() {return DataProduct.DataProductTagName;}
}