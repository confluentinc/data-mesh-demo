package io.confluent.demo.datamesh.cc.datacatalog.model;


import io.confluent.demo.datamesh.cc.urls.model.DataProductUrls;

public class DataProductEntity {
    private final AtlasEntityWithExtInfo entity;
    private final Tag dataProductTag;
    private final DataProductUrls urls;

    public DataProductEntity(
            AtlasEntityWithExtInfo entity,
            Tag dataProductTag,
            DataProductUrls urls) {
        this.entity = entity;
        this.dataProductTag = dataProductTag;
        this.urls = urls;
    }

    public AtlasEntity getEntity() { return this.entity.getEntity(); }
    public Tag getDataProductTag() { return this.dataProductTag; }
    public DataProductUrls getUrls() {return this.urls;}
}
