package io.confluent.demo.datamesh.cc.schemaregistry.api;

import io.confluent.demo.datamesh.cc.schemaregistry.model.Schema;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class SchemaRegistryService {

    private final RestTemplate restTemplate;
    private final String schemaRegistryId;

    public SchemaRegistryService(
            RestTemplateBuilder builder,
            @Value("${confluent.cloud.schemaregistry.id}") String srId,
            @Value("${confluent.cloud.schemaregistry.auth.key}") String srKey,
            @Value("${confluent.cloud.schemaregistry.auth.secret}") String srSecret,
            @Value("${confluent.cloud.schemaregistry.url}") String baseUrl) {

        this.schemaRegistryId = srId;

        restTemplate = builder
                .rootUri(baseUrl)
                .basicAuthentication(srKey, srSecret)
                .build();
    }

    public Schema getLatest(String name) {
        String url = String.format("/subjects/%s/versions/latest", name);
        return restTemplate.getForObject(url, Schema.class);
    }

}