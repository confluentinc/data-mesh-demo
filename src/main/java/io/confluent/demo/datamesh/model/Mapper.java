package io.confluent.demo.datamesh.model;

import io.confluent.demo.datamesh.cc.datacatalog.model.DataProductEntity;

/**
 * Place to house functions which map various objects into the
 * Data Mesh Demo data model
 */
public class Mapper {

    /**
     * Converts the Confluent Cloud representation of a data product
     * (Subject Version + Data Product Tag) into a DataProduct instance
     * @param dpEntity The CC representation of the Subject Version and Tag
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

        return new DataProduct(
           name,
           dpEntity.getEntity().getAttributes().get("qualifiedName").toString(),
           dpEntity.getDataProductTag().getAttributes().get("owner").toString(),
           dpEntity.getDataProductTag().getAttributes().get("description").toString());
    }
}
