package io.confluent.demo.datamesh.cc.ksqldb.api;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.web.client.RestTemplate;

public class KsqlDbService {
    private final RestTemplate restTemplate;

    public KsqlDbService(
            RestTemplateBuilder builder,
            @Value("${confluent.cloud.ksqldb.auth.key}") String ksqlAuthKey,
            @Value("${confluent.cloud.ksqldb.auth.secret}") String ksqlAuthSecret,
            @Value("${confluent.cloud.ksqldb.url}") String baseUrl) {
        restTemplate = builder
                .rootUri(baseUrl)
                .basicAuthentication(ksqlAuthKey, ksqlAuthSecret)
                .build();
    }
}
