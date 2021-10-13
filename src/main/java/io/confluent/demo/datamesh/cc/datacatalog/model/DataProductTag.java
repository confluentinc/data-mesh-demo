package io.confluent.demo.datamesh.cc.datacatalog.model;

import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonPOJOBuilder;

@JsonDeserialize(builder = DataProductTag.DataProductTagBuilder.class)
public class DataProductTag {

    private final String owner;
    private final String description;
    private final String domain;
    private final String sla;
    private final String quality;

    private DataProductTag(DataProductTagBuilder builder)
    {
        this.owner = builder.owner;
        this.description = builder.description;
        this.sla = builder.sla;
        this.quality = builder.quality;
        this.domain = builder.domain;
    }

    public String getOwner() {return this.owner;}
    public String getDescription() {return this.description;}
    public String getDomain() {return this.domain;}
    public String getQuality() {return this.quality;}
    public String getSla() {return this.sla;}
    public DataProductTagBuilder builder() {
        return new DataProductTagBuilder(this);
    }

    @JsonPOJOBuilder
    public static class DataProductTagBuilder {
        private String owner;
        private String description;
        private String domain;
        private String sla;
        private String quality;

        public DataProductTagBuilder(DataProductTag tag) {
            this(tag.owner, tag.description, tag.domain, tag.sla, tag.quality);
        }
        public DataProductTagBuilder(final String owner,
                                     final String description,
                                     final String domain,
                                     final String sla,
                                     final String quality) {
            this.owner = owner;
            this.description = description;
            this.sla = sla;
            this.quality = quality;
            this.domain = domain;
        }
        public DataProductTagBuilder withDomain(String domain) {
            this.domain = domain;
            return this;
        }
        public DataProductTagBuilder withOwner(String owner) {
            this.owner = owner;
            return this;
        }
        public DataProductTagBuilder withDescription(String description) {
            this.description = description;
            return this;
        }
        public DataProductTagBuilder withSla(String sla) {
            this.sla = sla;
            return this;
        }
        public DataProductTagBuilder withQuality(String quality) {
            this.quality = quality;
            return this;
        }

        public DataProductTag build() {
            return new DataProductTag(this);
        }
    }
}
