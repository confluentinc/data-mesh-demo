package io.confluent.demo.datamesh.cc.ksqldb.api;

import io.confluent.demo.datamesh.UseCasesController;
import io.confluent.demo.datamesh.model.UseCase;
import io.confluent.ksql.api.client.Client;
import io.confluent.ksql.api.client.ClientOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.*;

import java.net.URL;

@Service
@RestController
public class KsqlDbService {
    private final Client ksqlClient;

    @ResponseStatus(value= HttpStatus.BAD_REQUEST)
    public static class RestrictedStatement extends RuntimeException {
        public RestrictedStatement(String msg) {
            super(msg);
        }
    }

        @Autowired
    private UseCasesController useCasesController;

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

    @PostMapping(value = "/ksqldb/execute-use-case/{useCaseName}")
    public void execute(@PathVariable String useCaseName) throws Exception {
        UseCase foundUseCase = useCasesController.getUseCases()
            .stream()
            .filter( uc -> uc.getName().equals(useCaseName))
            .findFirst()
            .orElseThrow(() -> new RestrictedStatement("not allowed"));

        ksqlClient.executeStatement(foundUseCase.getKsqlDbCommand()).get();
    }
}
