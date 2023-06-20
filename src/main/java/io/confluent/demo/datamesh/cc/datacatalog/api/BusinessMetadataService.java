package io.confluent.demo.datamesh.cc.datacatalog.api;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.confluent.demo.datamesh.cc.datacatalog.model.*;
import io.confluent.demo.datamesh.model.AuditLogEntry;
import io.confluent.demo.datamesh.model.DataProduct;
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

import static io.confluent.demo.datamesh.model.DataProduct.DataProductTagName;

@Service
public class BusinessMetadataService {
    private final RestTemplate restTemplate;

    @ResponseStatus(value= HttpStatus.NOT_FOUND)
    public static class BusinessMetadataNotFoundException extends RuntimeException { }

    public BusinessMetadataService(
        RestTemplateBuilder builder,
        @Value("${confluent.cloud.schemaregistry.auth.key}") String srKey,
        @Value("${confluent.cloud.schemaregistry.auth.secret}") String srSecret,
        @Value("${confluent.cloud.schemaregistry.url}") String baseUrl) {
            restTemplate = builder
               .rootUri(baseUrl + "/catalog/v1")
               .basicAuthentication(srKey, srSecret)
               .build();
    }

    public BusinessMetadata getDataProductBusinessMetadataForTopic(String topicName) {
        String searchUrl = String.format("/entity/type/kafka_topic/name/%s/businessmetadata", topicName);
        return Arrays.stream(restTemplate.getForEntity(searchUrl, BusinessMetadata[].class)
            .getBody())
            .filter(bm -> bm.getTypeName().equals(DataProduct.DataProductBusinessMetadataName))
            .findFirst().orElseThrow(BusinessMetadataNotFoundException::new);
    }

    public BusinessMetadataServiceResponse removeDataProductBusinessMetadata(String entityQualifiedName) {
        String url = String.format(
            "/entity/type/kafka_topic/name/%s/businessmetadata/%s",
            entityQualifiedName,
                DataProduct.DataProductBusinessMetadataName);

        restTemplate.delete(url);
        return new BusinessMetadataServiceResponse(
                Optional.empty(),
                Optional.of(new AuditLogEntry(
                        String.format("Delete %s Business Metadata from entity '%s'",
                                DataProduct.DataProductBusinessMetadataName, entityQualifiedName),
                        String.format("DELETE %s", url) )));
    }

    public BusinessMetadataServiceResponse businessMetadataTopicAsDataProduct(
            String entityQualifiedName,
            DataProductBusinessMetadata dpbm) throws JsonProcessingException
    {
        String url = String.format("/entity/businessmetadata");
        List<DataProductBusinessMetadataEntityRequest> request = Arrays.asList(
                new DataProductBusinessMetadataEntityRequest(entityQualifiedName, dpbm));

        ResponseEntity<BusinessMetadataResponse[]> response = restTemplate.postForEntity(
                url, request, BusinessMetadataResponse[].class);

        return new BusinessMetadataServiceResponse(
                Optional.of(response.getBody()),
                Optional.of(new AuditLogEntry(
                    String.format("BusinessMetadata entity '%s' as '%s'", entityQualifiedName,
                            DataProduct.DataProductBusinessMetadataName),
                    String.format("POST %s\n%s",
                            url,
                            new ObjectMapper().writer().withDefaultPrettyPrinter().writeValueAsString(request)))));
    }

}
