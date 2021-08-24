package io.confluent.demo.datamesh.cc.connect.api;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class ConnectService {
    private final RestTemplate restTemplate;

    public ConnectService(
            RestTemplateBuilder builder,
            @Value("${confluent.cloud.auth.key}") String srKey,
            @Value("${confluent.cloud.auth.secret}") String srSecret,
            @Value("${confluent.cloud.environment.id}") String envId,
            @Value("${confluent.cloud.kafka.cluster.id}") String clusterId) {
        restTemplate = builder
                .rootUri(String.format("/connect/v1/environments/%s/clusters/%s/connectors",
                        envId, clusterId))
                .basicAuthentication(srKey, srSecret)
                .build();
    }
}
