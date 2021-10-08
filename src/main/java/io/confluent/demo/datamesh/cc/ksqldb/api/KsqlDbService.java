package io.confluent.demo.datamesh.cc.ksqldb.api;

import io.confluent.demo.datamesh.cc.ksqldb.model.ExecuteRequest;
import io.confluent.ksql.api.client.Client;
import io.confluent.ksql.api.client.ClientOptions;
import io.confluent.ksql.api.client.ExecuteStatementResult;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.net.URL;
import java.util.concurrent.CompletableFuture;

@Service
@RestController
public class KsqlDbService {
    private final Client ksqlClient;

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

    /**
     *
     *
     * Example return value from ksqlDB API (if needed or sdk handles)
     * {
     *   "@type": "currentStatus",
     *   "statementText": "CREATE STREAM PAGEVIEWS_USER3 WITH (KAFKA_TOPIC='pksqlc-w5q3gPAGEVIEWS_USER3', PARTITIONS=6, REPLICAS=3) AS SELECT *\nFROM PAGEVIEWS PAGEVIEWS\nWHERE (PAGEVIEWS.USERID = 'User_3')\nEMIT CHANGES;",
     *   "commandId": "stream/`PAGEVIEWS_USER3`/create",
     *   "commandStatus": {
     *     "status": "SUCCESS",
     *     "message": "Created query with ID CSAS_PAGEVIEWS_USER3_5",
     *     "queryId": "CSAS_PAGEVIEWS_USER3_5"
     *   },
     *   "commandSequenceNumber": 6,
     *   "warnings": []
     * }
     * @param request
     * @return
     * @throws Exception
     */
    @PostMapping(value = "/ksqldb/execute",
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public void execute(@RequestBody ExecuteRequest request) throws Exception {
        CompletableFuture<ExecuteStatementResult> result = ksqlClient.executeStatement(request.getSql());
        ExecuteStatementResult rv = result.get();
    }
}
