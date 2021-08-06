/*
 * Confluent Data Catalog
 * No description provided (generated by Swagger Codegen https://github.com/swagger-api/swagger-codegen)
 *
 * OpenAPI spec version: v1
 * 
 *
 * NOTE: This class is auto generated by the swagger code generator program.
 * https://github.com/swagger-api/swagger-codegen.git
 * Do not edit the class manually.
 */

package io.confluent.demo.datamesh.cc.datacatalog.model;

import java.util.Objects;
import java.util.Arrays;
import com.google.gson.TypeAdapter;
import com.google.gson.annotations.JsonAdapter;
import com.google.gson.annotations.SerializedName;
import com.google.gson.stream.JsonReader;
import com.google.gson.stream.JsonWriter;
import io.confluent.demo.datamesh.cc.datacatalog.model.AtlasAttributeDef;
import io.swagger.v3.oas.annotations.media.Schema;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
//import org.threeten.bp.OffsetDateTime;
import java.time.OffsetDateTime;
/**
 * TagDef
 */

@javax.annotation.Generated(value = "io.swagger.codegen.v3.generators.java.JavaClientCodegen", date = "2021-08-05T12:27:07.994303-05:00[America/Chicago]")
public class TagDef {
  /**
   * Gets or Sets category
   */
  @JsonAdapter(CategoryEnum.Adapter.class)
  public enum CategoryEnum {
    PRIMITIVE("PRIMITIVE"),
    OBJECT_ID_TYPE("OBJECT_ID_TYPE"),
    ENUM("ENUM"),
    STRUCT("STRUCT"),
    CLASSIFICATION("CLASSIFICATION"),
    ENTITY("ENTITY"),
    ARRAY("ARRAY"),
    MAP("MAP"),
    RELATIONSHIP("RELATIONSHIP"),
    BUSINESS_METADATA("BUSINESS_METADATA");

    private String value;

    CategoryEnum(String value) {
      this.value = value;
    }
    public String getValue() {
      return value;
    }

    @Override
    public String toString() {
      return String.valueOf(value);
    }
    public static CategoryEnum fromValue(String text) {
      for (CategoryEnum b : CategoryEnum.values()) {
        if (String.valueOf(b.value).equals(text)) {
          return b;
        }
      }
      return null;
    }
    public static class Adapter extends TypeAdapter<CategoryEnum> {
      @Override
      public void write(final JsonWriter jsonWriter, final CategoryEnum enumeration) throws IOException {
        jsonWriter.value(enumeration.getValue());
      }

      @Override
      public CategoryEnum read(final JsonReader jsonReader) throws IOException {
        Object value = jsonReader.nextString();
        return CategoryEnum.fromValue(String.valueOf(value));
      }
    }
  }  @SerializedName("category")
  private CategoryEnum category = null;

  @SerializedName("guid")
  private String guid = null;

  @SerializedName("createdBy")
  private String createdBy = null;

  @SerializedName("updatedBy")
  private String updatedBy = null;

  @SerializedName("createTime")
  private OffsetDateTime createTime = null;

  @SerializedName("updateTime")
  private OffsetDateTime updateTime = null;

  @SerializedName("version")
  private Long version = null;

  @SerializedName("name")
  private String name = null;

  @SerializedName("description")
  private String description = null;

  @SerializedName("typeVersion")
  private String typeVersion = null;

  @SerializedName("serviceType")
  private String serviceType = null;

  @SerializedName("options")
  private Map<String, String> options = null;

  @SerializedName("attributeDefs")
  private List<AtlasAttributeDef> attributeDefs = null;

  @SerializedName("superTypes")
  private List<String> superTypes = null;

  @SerializedName("entityTypes")
  private List<String> entityTypes = null;

  @SerializedName("subTypes")
  private List<String> subTypes = null;

  public TagDef category(CategoryEnum category) {
    this.category = category;
    return this;
  }

   /**
   * Get category
   * @return category
  **/
  @Schema(description = "")
  public CategoryEnum getCategory() {
    return category;
  }

  public void setCategory(CategoryEnum category) {
    this.category = category;
  }

  public TagDef guid(String guid) {
    this.guid = guid;
    return this;
  }

   /**
   * Get guid
   * @return guid
  **/
  @Schema(description = "")
  public String getGuid() {
    return guid;
  }

  public void setGuid(String guid) {
    this.guid = guid;
  }

  public TagDef createdBy(String createdBy) {
    this.createdBy = createdBy;
    return this;
  }

   /**
   * Get createdBy
   * @return createdBy
  **/
  @Schema(description = "")
  public String getCreatedBy() {
    return createdBy;
  }

  public void setCreatedBy(String createdBy) {
    this.createdBy = createdBy;
  }

  public TagDef updatedBy(String updatedBy) {
    this.updatedBy = updatedBy;
    return this;
  }

   /**
   * Get updatedBy
   * @return updatedBy
  **/
  @Schema(description = "")
  public String getUpdatedBy() {
    return updatedBy;
  }

  public void setUpdatedBy(String updatedBy) {
    this.updatedBy = updatedBy;
  }

  public TagDef createTime(OffsetDateTime createTime) {
    this.createTime = createTime;
    return this;
  }

   /**
   * Get createTime
   * @return createTime
  **/
  @Schema(description = "")
  public OffsetDateTime getCreateTime() {
    return createTime;
  }

  public void setCreateTime(OffsetDateTime createTime) {
    this.createTime = createTime;
  }

  public TagDef updateTime(OffsetDateTime updateTime) {
    this.updateTime = updateTime;
    return this;
  }

   /**
   * Get updateTime
   * @return updateTime
  **/
  @Schema(description = "")
  public OffsetDateTime getUpdateTime() {
    return updateTime;
  }

  public void setUpdateTime(OffsetDateTime updateTime) {
    this.updateTime = updateTime;
  }

  public TagDef version(Long version) {
    this.version = version;
    return this;
  }

   /**
   * Get version
   * @return version
  **/
  @Schema(description = "")
  public Long getVersion() {
    return version;
  }

  public void setVersion(Long version) {
    this.version = version;
  }

  public TagDef name(String name) {
    this.name = name;
    return this;
  }

   /**
   * Get name
   * @return name
  **/
  @Schema(description = "")
  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public TagDef description(String description) {
    this.description = description;
    return this;
  }

   /**
   * Get description
   * @return description
  **/
  @Schema(description = "")
  public String getDescription() {
    return description;
  }

  public void setDescription(String description) {
    this.description = description;
  }

  public TagDef typeVersion(String typeVersion) {
    this.typeVersion = typeVersion;
    return this;
  }

   /**
   * Get typeVersion
   * @return typeVersion
  **/
  @Schema(description = "")
  public String getTypeVersion() {
    return typeVersion;
  }

  public void setTypeVersion(String typeVersion) {
    this.typeVersion = typeVersion;
  }

  public TagDef serviceType(String serviceType) {
    this.serviceType = serviceType;
    return this;
  }

   /**
   * Get serviceType
   * @return serviceType
  **/
  @Schema(description = "")
  public String getServiceType() {
    return serviceType;
  }

  public void setServiceType(String serviceType) {
    this.serviceType = serviceType;
  }

  public TagDef options(Map<String, String> options) {
    this.options = options;
    return this;
  }

  public TagDef putOptionsItem(String key, String optionsItem) {
    if (this.options == null) {
      this.options = new HashMap<String, String>();
    }
    this.options.put(key, optionsItem);
    return this;
  }

   /**
   * Get options
   * @return options
  **/
  @Schema(description = "")
  public Map<String, String> getOptions() {
    return options;
  }

  public void setOptions(Map<String, String> options) {
    this.options = options;
  }

  public TagDef attributeDefs(List<AtlasAttributeDef> attributeDefs) {
    this.attributeDefs = attributeDefs;
    return this;
  }

  public TagDef addAttributeDefsItem(AtlasAttributeDef attributeDefsItem) {
    if (this.attributeDefs == null) {
      this.attributeDefs = new ArrayList<AtlasAttributeDef>();
    }
    this.attributeDefs.add(attributeDefsItem);
    return this;
  }

   /**
   * Get attributeDefs
   * @return attributeDefs
  **/
  @Schema(description = "")
  public List<AtlasAttributeDef> getAttributeDefs() {
    return attributeDefs;
  }

  public void setAttributeDefs(List<AtlasAttributeDef> attributeDefs) {
    this.attributeDefs = attributeDefs;
  }

  public TagDef superTypes(List<String> superTypes) {
    this.superTypes = superTypes;
    return this;
  }

  public TagDef addSuperTypesItem(String superTypesItem) {
    if (this.superTypes == null) {
      this.superTypes = new ArrayList<String>();
    }
    this.superTypes.add(superTypesItem);
    return this;
  }

   /**
   * Get superTypes
   * @return superTypes
  **/
  @Schema(description = "")
  public List<String> getSuperTypes() {
    return superTypes;
  }

  public void setSuperTypes(List<String> superTypes) {
    this.superTypes = superTypes;
  }

  public TagDef entityTypes(List<String> entityTypes) {
    this.entityTypes = entityTypes;
    return this;
  }

  public TagDef addEntityTypesItem(String entityTypesItem) {
    if (this.entityTypes == null) {
      this.entityTypes = new ArrayList<String>();
    }
    this.entityTypes.add(entityTypesItem);
    return this;
  }

   /**
   * Get entityTypes
   * @return entityTypes
  **/
  @Schema(description = "")
  public List<String> getEntityTypes() {
    return entityTypes;
  }

  public void setEntityTypes(List<String> entityTypes) {
    this.entityTypes = entityTypes;
  }

  public TagDef subTypes(List<String> subTypes) {
    this.subTypes = subTypes;
    return this;
  }

  public TagDef addSubTypesItem(String subTypesItem) {
    if (this.subTypes == null) {
      this.subTypes = new ArrayList<String>();
    }
    this.subTypes.add(subTypesItem);
    return this;
  }

   /**
   * Get subTypes
   * @return subTypes
  **/
  @Schema(description = "")
  public List<String> getSubTypes() {
    return subTypes;
  }

  public void setSubTypes(List<String> subTypes) {
    this.subTypes = subTypes;
  }


  @Override
  public boolean equals(java.lang.Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    TagDef tagDef = (TagDef) o;
    return Objects.equals(this.category, tagDef.category) &&
        Objects.equals(this.guid, tagDef.guid) &&
        Objects.equals(this.createdBy, tagDef.createdBy) &&
        Objects.equals(this.updatedBy, tagDef.updatedBy) &&
        Objects.equals(this.createTime, tagDef.createTime) &&
        Objects.equals(this.updateTime, tagDef.updateTime) &&
        Objects.equals(this.version, tagDef.version) &&
        Objects.equals(this.name, tagDef.name) &&
        Objects.equals(this.description, tagDef.description) &&
        Objects.equals(this.typeVersion, tagDef.typeVersion) &&
        Objects.equals(this.serviceType, tagDef.serviceType) &&
        Objects.equals(this.options, tagDef.options) &&
        Objects.equals(this.attributeDefs, tagDef.attributeDefs) &&
        Objects.equals(this.superTypes, tagDef.superTypes) &&
        Objects.equals(this.entityTypes, tagDef.entityTypes) &&
        Objects.equals(this.subTypes, tagDef.subTypes);
  }

  @Override
  public int hashCode() {
    return Objects.hash(category, guid, createdBy, updatedBy, createTime, updateTime, version, name, description, typeVersion, serviceType, options, attributeDefs, superTypes, entityTypes, subTypes);
  }


  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class TagDef {\n");
    
    sb.append("    category: ").append(toIndentedString(category)).append("\n");
    sb.append("    guid: ").append(toIndentedString(guid)).append("\n");
    sb.append("    createdBy: ").append(toIndentedString(createdBy)).append("\n");
    sb.append("    updatedBy: ").append(toIndentedString(updatedBy)).append("\n");
    sb.append("    createTime: ").append(toIndentedString(createTime)).append("\n");
    sb.append("    updateTime: ").append(toIndentedString(updateTime)).append("\n");
    sb.append("    version: ").append(toIndentedString(version)).append("\n");
    sb.append("    name: ").append(toIndentedString(name)).append("\n");
    sb.append("    description: ").append(toIndentedString(description)).append("\n");
    sb.append("    typeVersion: ").append(toIndentedString(typeVersion)).append("\n");
    sb.append("    serviceType: ").append(toIndentedString(serviceType)).append("\n");
    sb.append("    options: ").append(toIndentedString(options)).append("\n");
    sb.append("    attributeDefs: ").append(toIndentedString(attributeDefs)).append("\n");
    sb.append("    superTypes: ").append(toIndentedString(superTypes)).append("\n");
    sb.append("    entityTypes: ").append(toIndentedString(entityTypes)).append("\n");
    sb.append("    subTypes: ").append(toIndentedString(subTypes)).append("\n");
    sb.append("}");
    return sb.toString();
  }

  /**
   * Convert the given object to string with each line indented by 4 spaces
   * (except the first line).
   */
  private String toIndentedString(java.lang.Object o) {
    if (o == null) {
      return "null";
    }
    return o.toString().replace("\n", "\n    ");
  }

}
