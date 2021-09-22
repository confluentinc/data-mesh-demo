package io.confluent.demo.datamesh.cc.urls.api;

import io.confluent.demo.datamesh.cc.datacatalog.api.SubjectVersionService;
import io.confluent.demo.datamesh.cc.urls.model.DataProductUrls;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

/**
 * Provides endpoints that can serve user contextualized URLs
 * for Confluent Cloud Console pages.
 */
@RestController
public class UrlService {

    private String baseUrl = "https://confluent.cloud";
    @Value("${confluent.cloud.environment.id}")
    private String environmentId;
    @Value("${confluent.cloud.kafka.cluster.id}")
    private String clusterId;
    @Value("${confluent.cloud.ksqldb.id}")
    private String ksqlDbId;

    @GetMapping("/urls/cc")
    public String getConfluentCloudUrl() {
        return baseUrl;
    }

    @GetMapping("/urls/cc/environment")
    public String getEnvironmentUrl() {
       return String.format("%s/environments/%s", baseUrl, environmentId);
    }

    @GetMapping("/urls/cc/environment/cluster")
    public String getClusterUrl() {
        return String.format("%s/clusters/%s",
                getEnvironmentUrl(),
                clusterId);
    }
    @GetMapping("/urls/cc/environment/cluster/ksql")
    public String getKsqlDbUrl() {
        return String.format("%s/ksql/%s",
                getClusterUrl(),
                ksqlDbId);
    }
    public String getKsqlDbId() {return this.ksqlDbId;}
    @GetMapping("/urls/cc/environment/schema-registry")
    public String getSchemaRegistryUrl() {
        return String.format("%s/schema-registry", getEnvironmentUrl());
    }
    @GetMapping("/urls/cc/environment/schema-registry/schema/{schemaName}")
    public String getSchemaUrl(@PathVariable String schemaName) {
        return String.format("%s/schemas/%s", getSchemaRegistryUrl(), schemaName);
    }
    @GetMapping("/urls/cc/environment/cluster/topics/{topicName}")
    public String getTopicUrl(@PathVariable String topicName) {
        //https://confluent.cloud/environments/env-nq0gz/clusters/lkc-ypj7p/topics/pageviews/overview
        return String.format("%s/topics/%s", getClusterUrl(), topicName);
    }
    @GetMapping("/urls/cc/environment/cluster/lineage/{name}")
    public String getLineageUrl(@PathVariable String name) {
        //https://confluent.cloud/environments/env-z5187/clusters/lkc-md1o7/stream-lineage/stream/pageviews-value/n/pageviews-value/overview
        return String.format("%s/stream-lineage/stream/%s/n/%s/overview", getClusterUrl(), name, name);
    }
    @GetMapping("/urls/cc/environment/cluster/connectors")
    public String getConnectorUrl() {
        //https://confluent.cloud/environments/env-z5187/clusters/lkc-md1o7/connectors/browse
        return String.format("%s/connectors/browse", getClusterUrl());
    }

    @GetMapping("/urls/data-product/{dataProductFQN}")
    public DataProductUrls getDataProductUrls(@PathVariable String dataProductFQN) {
        String schemaName = SubjectVersionService.getQualifiedNameSchemaName(dataProductFQN);
        String topicName  = SubjectVersionService.getQualifiedNameTopicName(dataProductFQN);
        String schemaUrl  = getSchemaUrl(schemaName);
        String topicUrl   = getTopicUrl(topicName);
        String lineageUrl = getLineageUrl("topic-" + topicName);
        String exportUrl  = getConnectorUrl();

        return new DataProductUrls(schemaUrl, topicUrl, lineageUrl, exportUrl);
    }

}
