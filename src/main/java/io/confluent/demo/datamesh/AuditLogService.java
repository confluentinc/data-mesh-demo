package io.confluent.demo.datamesh;

import io.confluent.demo.datamesh.model.AuditLogEntry;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpRequest;
import org.springframework.http.client.ClientHttpRequestExecution;
import org.springframework.http.client.ClientHttpRequestInterceptor;
import org.springframework.http.client.ClientHttpResponse;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@Service
public class AuditLogService implements ClientHttpRequestInterceptor {

    @Autowired
    private AuditLogController controller;

    public void sendAuditLogEntry(String logMsg) {
        this.sendAuditLogEntry(new AuditLogEntry(logMsg));
    }
    public void sendAuditLogEntry(AuditLogEntry entry) {
        controller.sendAuditLogEntry(entry);
    }

    @Override
    public ClientHttpResponse intercept(
            final HttpRequest request, final byte[] body,
            final ClientHttpRequestExecution execution) throws IOException {

        sendAuditLogEntry(String.format("%s: %s", request.getMethod().name(), request.getURI().toString()));
        ClientHttpResponse response = execution.execute(request, body);
        return response;

        //LOGGER.debug("Request body: {}", new String(reqBody, StandardCharsets.UTF_8));
        //InputStreamReader isr = new InputStreamReader(response.getBody(), StandardCharsets.UTF_8);
        //String body = new BufferedReader(isr).lines().collect(Collectors.joining("\n"));
        //LOGGER.debug("Response body: {}", body);
    }
}
