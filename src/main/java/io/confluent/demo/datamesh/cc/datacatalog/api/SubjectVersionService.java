package io.confluent.demo.datamesh.cc.datacatalog.api;

import io.confluent.demo.datamesh.cc.datacatalog.model.AtlasEntityHeader;
import io.confluent.demo.datamesh.cc.datacatalog.model.AtlasEntityWithExtInfo;
import io.confluent.demo.datamesh.cc.datacatalog.model.SearchResult;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Objects;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class SubjectVersionService {
    private final RestTemplate restTemplate;

    public SubjectVersionService(
            RestTemplateBuilder builder,
            @Value("${confluent.cloud.schemaregistry.auth.key}") String srKey,
            @Value("${confluent.cloud.schemaregistry.auth.secret}") String srSecret,
            @Value("${confluent.cloud.schemaregistry.url}") String baseUrl) {
        restTemplate = builder
            .rootUri(baseUrl + "/catalog/v1")
            .basicAuthentication(srKey, srSecret)
            .build();
    }

    private static String getEntityName(AtlasEntityHeader header) {
        return (String)header.getAttributes().get("name");
    }
    public static AtlasEntityHeader getLatestHeader(AtlasEntityHeader h1, AtlasEntityHeader h2) {
        int r1Ver = (int)h1.getAttributes().get("version");
        int r2Ver = (int)h2.getAttributes().get("version");
        if (r2Ver > r1Ver)
            return h2;
        else
            return h1;
    }
    public AtlasEntityWithExtInfo getSubjectVersionEntity(String qualifiedName) {
        OffsetDateTime odt;
        String entityUrl = String.format("/entity/type/sr_subject_version/name/%s", qualifiedName);
        return restTemplate.getForObject(entityUrl, AtlasEntityWithExtInfo.class);
    }

    public List<AtlasEntityWithExtInfo> getAll() {
        String searchUrl = "/search/basic?types=sr_subject_version&tag=DataProduct&attrs=version";
        SearchResult result = restTemplate.getForObject(
            searchUrl,
            SearchResult.class);

        /**
         * Filters out the results by version taking the latest version for each search result
         */
        return result
            .getEntities()
            .stream()
            .collect(Collectors.toMap(
                    SubjectVersionService::getEntityName,
                    Function.identity(),
                    SubjectVersionService::getLatestHeader))
            .values()
            .stream()
            .map(header -> getSubjectVersionEntity(header.getAttributes().get("qualifiedName").toString()))
           .collect(Collectors.toList());
    }
}