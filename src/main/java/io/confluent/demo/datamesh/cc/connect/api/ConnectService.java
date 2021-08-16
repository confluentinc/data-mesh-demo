package io.confluent.demo.datamesh.cc.connect.api;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.web.client.RestTemplate;

public class ConnectService {
    private final RestTemplate restTemplate;

    public ConnectService(
            RestTemplateBuilder builder,
            @Value("${confluent.cloud.schemaregistry.auth.key}") String srKey,
            @Value("${confluent.cloud.schemaregistry.auth.secret}") String srSecret,
            @Value("${confluent.cloud.schemaregistry.url}") String baseUrl,
            @Value("${confluent.cloud.environment.id}") String envId,
            @Value("${confluent.cloud.kafka.cluster.id}") String clusterId) {
        restTemplate = builder
                .rootUri(baseUrl + String.format("/connect/v1/environments/%s/clusters/%s/connectors",
                        envId, clusterId))
                .basicAuthentication(srKey, srSecret)
                .build();
    }
}
