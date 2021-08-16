package io.confluent.demo.datamesh.cc.datacatalog.api;

import io.confluent.demo.datamesh.cc.datacatalog.model.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.client.RestTemplate;

import java.util.Arrays;

@Service
public class TagService {
    private final RestTemplate restTemplate;

    @ResponseStatus(value= HttpStatus.NOT_FOUND)
    public static class TagNotFoundException extends RuntimeException { }

    public TagService(
        RestTemplateBuilder builder,
        @Value("${confluent.cloud.schemaregistry.auth.key}") String srKey,
        @Value("${confluent.cloud.schemaregistry.auth.secret}") String srSecret,
        @Value("${confluent.cloud.schemaregistry.url}") String baseUrl) {
            restTemplate = builder
               .rootUri(baseUrl + "/catalog/v1")
               .basicAuthentication(srKey, srSecret)
               .build();
    }

    public Tag getDataProductTagForSubjectVersion(String subjectVersionQualifiedName) {
        String searchUrl = String.format("/entity/type/sr_subject_version/name/%s/tags", subjectVersionQualifiedName);
        return Arrays.stream(restTemplate.getForEntity(searchUrl, Tag[].class)
            .getBody())
            .filter(tag -> tag.getTypeName().equals("DataProduct"))
            .findFirst().orElseThrow(TagNotFoundException::new);
    }

    class DataProductTagEntityRequest {
        class Attributes {
            private final String owner;
            private final String description;
            public Attributes(String owner, String description) {
                this.owner = owner;
                this.description = description;
            }
            public String getOwner() {return this.owner;}
            public String getDescription() {return this.description;}
        }

        private final String entityName;
        private final Attributes attributes;

        public DataProductTagEntityRequest(String entityName, DataProductTag tag) {
            this.entityName = entityName;
            this.attributes = new Attributes(tag.getOwner(), tag.getDescription());
        }

        public String getEntityType() {return "sr_subject_version";}
        public String getEntityName() {return this.entityName;}
        public String getTypeName() {return "DataProduct";}
        public Attributes getAttributes() {return this.attributes;}
    }

    public void tagSubjectVersionWithDataProduct(String entityQualifiedName, DataProductTag tag) {
        String url = String.format("entity/tags");
        DataProductTagEntityRequest request = new DataProductTagEntityRequest(entityQualifiedName, tag);
        // TODO: Finish wiring up the POST to place the DataProduct tag on the given entity
        //String response = restTemplate.postForEntity(url, request, String.class);
    }

}
