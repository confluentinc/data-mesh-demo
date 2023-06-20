package io.confluent.demo.datamesh.cc.datacatalog.model;


import io.confluent.demo.datamesh.cc.schemaregistry.model.Schema;
import io.confluent.demo.datamesh.cc.urls.model.DataProductUrls;

public class DataProductEntity {
    private final AtlasEntityWithExtInfo entity;
    private final BusinessMetadata dataProductBusinessMetadata;
    private final DataProductUrls urls;
    private final Schema schema;

    public DataProductEntity(
            AtlasEntityWithExtInfo entity,
            BusinessMetadata dataProductBusinessMetadata,
            DataProductUrls urls,
            Schema schema) {
        this.entity = entity;
        this.dataProductBusinessMetadata = dataProductBusinessMetadata;
        this.urls = urls;
        this.schema = schema;
    }

    public AtlasEntity getEntity() { return this.entity.getEntity(); }
    public BusinessMetadata getDataProductBusinessMetadata() { return this.dataProductBusinessMetadata; }
    public DataProductUrls getUrls() {return this.urls;}
    public Schema getSchema() {return this.schema;}
}
