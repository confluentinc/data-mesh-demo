package io.confluent.demo.datamesh.cc.datacatalog.api;

import io.confluent.demo.datamesh.cc.datacatalog.model.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.client.RestTemplate;

import java.util.Arrays;
import java.util.List;

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

    public TagResponse[] tagSubjectVersionWithDataProduct(String entityQualifiedName,
                                                 DataProductTag tag) {
        String url = String.format("/entity/tags");
        List<DataProductTagEntityRequest> request = Arrays.asList(
                new DataProductTagEntityRequest(entityQualifiedName, tag));

        ResponseEntity<TagResponse[]> response = restTemplate.postForEntity(
                url, request, TagResponse[].class);

        return response.getBody();
    }

}
