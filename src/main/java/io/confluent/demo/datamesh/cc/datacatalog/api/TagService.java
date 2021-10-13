package io.confluent.demo.datamesh.cc.datacatalog.api;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;
import io.confluent.demo.datamesh.cc.datacatalog.model.*;
import io.confluent.demo.datamesh.model.AuditLogEntry;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.client.RestTemplate;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

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

    public TagServiceResponse unTagSubjectVersionAsDataProduct(String entityQualifiedName) {
        String url = String.format(
            "/entity/type/sr_subject_version/name/%s/tags/DataProduct",
            entityQualifiedName);

        restTemplate.delete(url);
        return new TagServiceResponse(
                Optional.empty(),
                Optional.of(new AuditLogEntry(
                        String.format("Delete DataProduct tag from entity '%s'", entityQualifiedName),
                        String.format("DELETE %s", url) )));
    }

    public TagServiceResponse tagSubjectVersionAsDataProduct(
            String entityQualifiedName,
            DataProductTag tag) throws JsonProcessingException
    {
        String url = String.format("/entity/tags");
        List<DataProductTagEntityRequest> request = Arrays.asList(
                new DataProductTagEntityRequest(entityQualifiedName, tag));

        /// 404 Not Found: [{"error_code":4040009,"message":
        // "Instance sr_subject_version with unique attribute
        // {qualifiedName=lsrc-7xxv2:.:rc-7xxv2:.:pksqlc-09g26PAGEVIEWS_USER2-value:2} does not exist"}]
        ResponseEntity<TagResponse[]> response = restTemplate.postForEntity(
                url, request, TagResponse[].class);

        return new TagServiceResponse(
                Optional.of(response.getBody()),
                Optional.of(new AuditLogEntry(
                    String.format("Tag entity '%s' with 'DataProduct' tag", entityQualifiedName),
                    String.format("POST %s\n%s",
                            url,
                            new ObjectMapper().writer().withDefaultPrettyPrinter().writeValueAsString(request)))));
    }

}
