package io.confluent.demo.datamesh.cc.datacatalog.model;


public class DataProductEntity {
    private final AtlasEntityWithExtInfo entity;
    private final Tag dataProductTag;

    public DataProductEntity(AtlasEntityWithExtInfo entity, Tag dataProductTag) {
        this.entity = entity;
        this.dataProductTag = dataProductTag;
    }

    public AtlasEntity getEntity() { return this.entity.getEntity(); }
    public Tag getDataProductTag() { return this.dataProductTag; }
}
