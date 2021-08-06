package io.confluent.demo.datamesh.cc.datacatalog.api;

import io.confluent.demo.datamesh.cc.datacatalog.model.AtlasEntityWithExtInfo;
import io.confluent.demo.datamesh.cc.datacatalog.model.SearchResult;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class SubjectVersionService {
    private final RestTemplate restTemplate;

    public SubjectVersionService(
            RestTemplateBuilder builder,
            @Value("${confluent.cloud.schemaregistry.auth.key}") String ccKey,
            @Value("${confluent.cloud.schemaregistry.auth.secret}") String ccValue,
            @Value("${confluent.cloud.schemaregistry.baseurl}") String baseUrl) {
        restTemplate = builder
            .rootUri(baseUrl + "/catalog/v1")
            .basicAuthentication(ccKey, ccValue)
            .build();
    }

    public AtlasEntityWithExtInfo getSubjectVersionEntity(String qualifiedName) {
        OffsetDateTime odt;
        String entityUrl = String.format("/entity/type/sr_subject_version/name/%s", qualifiedName);
        return restTemplate.getForObject(entityUrl, AtlasEntityWithExtInfo.class);
    }

    public List<AtlasEntityWithExtInfo> getAll() {
        String searchUrl = "/search/basic?types=sr_subject_version&tag=DataProduct";
        SearchResult result = restTemplate.getForObject(
            searchUrl,
            SearchResult.class);

        return result.getEntities().stream()
           .map(header -> getSubjectVersionEntity(header.getAttributes().get("qualifiedName").toString()))
           .collect(Collectors.toList());
    }
}
