package io.confluent.demo.datamesh.cc.datacatalog.api;

import io.confluent.demo.datamesh.cc.datacatalog.model.AtlasEntity;
import io.confluent.demo.datamesh.cc.datacatalog.model.AtlasEntityHeader;
import io.confluent.demo.datamesh.cc.datacatalog.model.SearchResult;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.Collections;
import java.util.List;

@Service
public class SubjectVersionService {
    private final RestTemplate restTemplate;

    public SubjectVersionService(
            RestTemplateBuilder builder,
            @Value("${confluent.cloud.auth.key}") String ccKey,
            @Value("${confluent.cloud.auth.secret}") String ccValue) {
        restTemplate = builder
                .basicAuthentication(ccKey, ccValue)
                .build();
    }
    public List<AtlasEntityHeader> getAll(String baseUrlBits) {
        String searchUrlBits = "/search/basic?types=sr_subject_version";
        String fullUrl = baseUrlBits + searchUrlBits;
        SearchResult result = restTemplate.getForObject(
                fullUrl,
                SearchResult.class);

        return result.getEntities();
    }
}
