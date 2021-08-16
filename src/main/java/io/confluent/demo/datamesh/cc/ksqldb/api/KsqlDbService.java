package io.confluent.demo.datamesh.cc.ksqldb.api;

import io.confluent.ksql.api.client.Client;
import io.confluent.ksql.api.client.ClientOptions;
import io.confluent.ksql.api.client.ExecuteStatementResult;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.stereotype.Service;

import java.net.URL;
import java.util.concurrent.CompletableFuture;

@Service
public class KsqlDbService {
    private final Client ksqlClient;

    class PostRequest {
        private String sql;

        public PostRequest(String sql) {
            this.sql = sql;
        }

        public String getSql() {
           return sql;
        }
    }

    public KsqlDbService(
            RestTemplateBuilder builder,
            @Value("${confluent.cloud.ksqldb.auth.key}") String ksqlAuthKey,
            @Value("${confluent.cloud.ksqldb.auth.secret}") String ksqlAuthSecret,
            @Value("${confluent.cloud.ksqldb.url}") String baseUrl) throws Exception {
        java.net.URL url = new URL(baseUrl);
        ClientOptions options = ClientOptions
            .create()
            .setHost(url.getHost())
            .setPort(url.getPort())
            .setUseTls(true)
            .setUseAlpn(true)
            .setBasicAuthCredentials(ksqlAuthKey, ksqlAuthSecret);
        this.ksqlClient = Client.create(options);
    }

    public CompletableFuture<ExecuteStatementResult> execute(String request) throws Exception {
        return ksqlClient.executeStatement(request);
    }
}
