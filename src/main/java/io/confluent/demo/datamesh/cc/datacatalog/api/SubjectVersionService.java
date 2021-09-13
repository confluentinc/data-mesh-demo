package io.confluent.demo.datamesh.cc.datacatalog.api;

import io.confluent.demo.datamesh.AuditLogController;
import io.confluent.demo.datamesh.AuditLogService;
import io.confluent.demo.datamesh.cc.datacatalog.model.AtlasClassification;
import io.confluent.demo.datamesh.cc.datacatalog.model.AtlasEntityHeader;
import io.confluent.demo.datamesh.cc.datacatalog.model.AtlasEntityWithExtInfo;
import io.confluent.demo.datamesh.cc.datacatalog.model.SearchResult;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import java.time.OffsetDateTime;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RestController
@RequestMapping("/subjects")
public class SubjectVersionService {
    private final RestTemplate restTemplate;

    public SubjectVersionService(
            RestTemplateBuilder builder,
            AuditLogService auditService,
            @Value("${confluent.cloud.schemaregistry.auth.key}") String srKey,
            @Value("${confluent.cloud.schemaregistry.auth.secret}") String srSecret,
            @Value("${confluent.cloud.schemaregistry.url}") String baseUrl) {

        restTemplate = builder
            .rootUri(baseUrl + "/catalog/v1")
            .basicAuthentication(srKey, srSecret)
            .additionalInterceptors(auditService)
            .build();
    }

    private List<AtlasEntityWithExtInfo> filterForDuplicates(SearchResult result) {
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
    public static String getQualifiedNameSchemaName(String srSubjectVersionFQN) {
        // Must match the pattern: "lsrc-wqxng:.:pageviews-value:1"
        return srSubjectVersionFQN.split(":")[2];
    }

    public AtlasEntityWithExtInfo getSubjectVersionEntity(String qualifiedName) {
        OffsetDateTime odt;
        String entityUrl = String.format("/entity/type/sr_subject_version/name/%s", qualifiedName);
        return restTemplate.getForObject(entityUrl, AtlasEntityWithExtInfo.class);
    }
    public List<AtlasEntityWithExtInfo> getAll() {
        return getAll(Optional.empty(), Optional.empty());
    }
    @GetMapping
    public List<AtlasEntityWithExtInfo> getAll(
            @RequestParam Optional<String> includeTag,
            @RequestParam Optional<String> excludeTag) {

        String searchUrl = "/search/basic?types=sr_subject_version&attrs=version";
        if(!includeTag.isEmpty() && includeTag.get().trim().length() > 0)
            searchUrl = searchUrl + "&tag=" + includeTag.get();

        SearchResult result = restTemplate.getForObject(
                searchUrl,
                SearchResult.class);

        List<AtlasEntityWithExtInfo> found = filterForDuplicates(result);
        if (excludeTag.isEmpty()) {
            return found;
        } else {
            return found.stream()
                .filter(entry -> {
                    return Optional.ofNullable(entry.getEntity().getClassifications())
                        .orElse(Collections.<AtlasClassification> emptyList())
                        .stream()
                        .filter(c -> excludeTag.get().equals(c.getTypeName()))
                        .findAny()
                        .isEmpty();
                })
                .collect(Collectors.toList());
        }
    }
    public List<AtlasEntityWithExtInfo> getPotentialDataProducts() {
        return getAll(Optional.empty(), Optional.of("DataProduct"));
    }
    public List<AtlasEntityWithExtInfo> getDataProducts() {
        return getAll(Optional.of("DataProduct"), Optional.empty());
    }

}