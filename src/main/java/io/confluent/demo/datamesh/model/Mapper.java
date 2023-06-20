package io.confluent.demo.datamesh.model;

import io.confluent.demo.datamesh.cc.datacatalog.model.AtlasEntityWithExtInfo;
import io.confluent.demo.datamesh.cc.datacatalog.model.DataProductEntity;

import java.util.Map;
import java.util.Optional;

/**
 * Place to house functions which map various objects into the
 * Data Mesh Demo data model
 */
public class Mapper {

    public static Topic ccToTopic(AtlasEntityWithExtInfo entity) {
        String name = entity.getEntity().getAttributes()
                .get("name")
                .toString();

        // Strips off the topic naming scheme to set a more friendly name
        int i = name.indexOf("-value");
        if (i > -1) {
            name = name.substring(0, i);
        }

        return new Topic(
                name,
                entity.getEntity().getAttributes().get("qualifiedName").toString());
    }

    /**
     * Converts the Confluent Cloud representation of a data product
     * (Topic + Data Product Tag + Data Product Business Metadata) into a DataProduct instance
     * @param dpEntity The CC representation of the Topic data and Business Metadata
     * @return A new DataProduct instance
     */
    public static DataProduct ccToDataProduct(DataProductEntity dpEntity) {
        String name = dpEntity.getEntity().getAttributes()
          .get("name")
          .toString();

        // Strips off the topic naming scheme to set a more friendly name
        int i = name.indexOf("-value");
        if (i > -1) {
           name = name.substring(0, i);
        }

        Map<String, Object> dataProductAttributes = dpEntity.getDataProductBusinessMetadata().getAttributes();

        return new DataProduct(
            name,
            dpEntity.getEntity().getAttributes().get("qualifiedName").toString(),
            (String)Optional.ofNullable(dataProductAttributes.getOrDefault("owner", "n/a")).orElse("n/a"),
            (String)Optional.ofNullable(dataProductAttributes.getOrDefault("description", "n/a")).orElse("n/a"),
            dpEntity.getUrls(),
            dpEntity.getSchema(),
            (String)Optional.ofNullable(dataProductAttributes.getOrDefault("domain", "n/a")).orElse("n/a"),
            (String)Optional.ofNullable(dataProductAttributes.getOrDefault("sla", "n/a")).orElse("n/a"),
            (String)Optional.ofNullable(dataProductAttributes.getOrDefault("quality", "n/a")).orElse("n/a"));
    }
}