package io.confluent.demo.datamesh.cc.datacatalog.model;

import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonPOJOBuilder;

@JsonDeserialize(builder = DataProductBusinessMetadata.DataProductBusinessMetadataBuilder.class)
public class DataProductBusinessMetadata {

    private final String owner;
    private final String description;
    private final String domain;
    private final String sla;
    private final String quality;

    @Override
    public String toString() {
        return "DataProductBusinessMetadata{" +
                "owner='" + owner + '\'' +
                ", description='" + description + '\'' +
                ", domain='" + domain + '\'' +
                ", sla='" + sla + '\'' +
                ", quality='" + quality + '\'' +
                '}';
    }

    private DataProductBusinessMetadata(DataProductBusinessMetadataBuilder builder)
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
    public DataProductBusinessMetadataBuilder builder() {
        return new DataProductBusinessMetadataBuilder(this);
    }

    @JsonPOJOBuilder
    public static class DataProductBusinessMetadataBuilder {
        private String owner;
        private String description;
        private String domain;
        private String sla;
        private String quality;

        public DataProductBusinessMetadataBuilder(DataProductBusinessMetadata bm) {
            this(bm.owner, bm.description, bm.domain, bm.sla, bm.quality);
        }
        public DataProductBusinessMetadataBuilder(final String owner,
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
        public DataProductBusinessMetadataBuilder withDomain(String domain) {
            this.domain = domain;
            return this;
        }
        public DataProductBusinessMetadataBuilder withOwner(String owner) {
            this.owner = owner;
            return this;
        }
        public DataProductBusinessMetadataBuilder withDescription(String description) {
            this.description = description;
            return this;
        }
        public DataProductBusinessMetadataBuilder withSla(String sla) {
            this.sla = sla;
            return this;
        }
        public DataProductBusinessMetadataBuilder withQuality(String quality) {
            this.quality = quality;
            return this;
        }

        public DataProductBusinessMetadata build() {
            return new DataProductBusinessMetadata(this);
        }
    }
}
