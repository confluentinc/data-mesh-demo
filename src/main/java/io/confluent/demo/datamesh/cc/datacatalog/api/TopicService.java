package io.confluent.demo.datamesh.cc.datacatalog.api;

import io.confluent.demo.datamesh.cc.datacatalog.model.*;
import io.confluent.demo.datamesh.model.AuditLogEntry;
import io.confluent.demo.datamesh.model.DataProduct;
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
import java.util.Optional;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RestController
@RequestMapping("/priv/topics")
public class TopicService {
    private final RestTemplate restTemplate;

    public TopicService(
            RestTemplateBuilder builder,
            @Value("${confluent.cloud.schemaregistry.auth.key}") String srKey,
            @Value("${confluent.cloud.schemaregistry.auth.secret}") String srSecret,
            @Value("${confluent.cloud.schemaregistry.url}") String baseUrl) {

        restTemplate = builder
                .rootUri(baseUrl + "/catalog/v1")
                .basicAuthentication(srKey, srSecret)
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
                        TopicService::getEntityName,
                        Function.identity(),
                        TopicService::getLatestHeader))
                .values()
                .stream()
                .map(header -> getTopicEntity(header.getAttributes().get("qualifiedName").toString()))
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
    public static String getSchemaNameFromQualifiedName(String srSchemaFQN) {
        // Must match the pattern: "lsrc-wqxng:.:pageviews-value:1"
        return srSchemaFQN.split(":")[2];
    }
    public static String getTopicNameFromQualifiedName(String srTopicFQN) {
        // Must match the pattern: "lsrc-wqxng:.:pageviews"
        return srTopicFQN.split(":")[2];
    }

    public AtlasEntityWithExtInfo getTopicEntity(String qualifiedName) {
        OffsetDateTime odt;
        String entityUrl = String.format("/entity/type/kafka_topic/name/%s", qualifiedName);
        return restTemplate.getForObject(entityUrl, AtlasEntityWithExtInfo.class);
    }

    public TopicServiceResult getAll() {
        return getAll(Optional.empty(), Optional.empty());
    }

    public TopicServiceResult getPotentialDataProductsByTag() {
        return getAll(Optional.empty(), Optional.of(DataProduct.DataProductTagName));
    }
    public TopicServiceResult getDataProductsByTag() {
        return getAll(Optional.of(DataProduct.DataProductTagName), Optional.empty());
    }

    @GetMapping
    public TopicServiceResult getAll(
            @RequestParam Optional<String> includeTag,
            @RequestParam Optional<String> excludeTag) {

        Optional<AuditLogEntry> auditLogEntry = Optional.empty();

        String searchUrl = "/search/basic?types=kafka_topic";
        if(!includeTag.isEmpty() && includeTag.get().trim().length() > 0) {
            searchUrl = searchUrl + "&tag=" + includeTag.get();
            auditLogEntry = Optional.of(new AuditLogEntry(
                    "Get all Topics from Confluent Data Catalog with tag '" + includeTag.get() + "'",
                    new String[]{ String.format("GET %s", searchUrl) }));
        }
        else {
            auditLogEntry = Optional.of(new AuditLogEntry(
                    "Get all Topics from Confluent Data Catalog",
                    new String[]{ String.format("GET %s", searchUrl) }));
        }

        SearchResult result = restTemplate.getForObject(
                searchUrl,
                SearchResult.class);

        List<AtlasEntityWithExtInfo> found = filterForDuplicates(result);

        // TODO: Figure out if it's possible to both filter including and excluding tags on the server side
        if (excludeTag.isPresent()) {
            found = found
                    .stream()
                    .filter(entry -> {
                        return Optional.ofNullable(entry.getEntity().getClassifications())
                                .orElse(Collections.emptyList())
                                .stream()
                                .filter(c -> excludeTag.get().equals(c.getTypeName()))
                                .findAny()
                                .isEmpty(); })
                    .collect(Collectors.toList());
        }


        return new TopicServiceResult(found, auditLogEntry);
    }


}