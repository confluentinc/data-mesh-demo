package io.confluent.demo.datamesh;

import io.confluent.demo.datamesh.cc.urls.api.UrlService;
import io.confluent.demo.datamesh.model.UseCase;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.util.UriUtils;

import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;
import java.util.List;

@RestController
@RequestMapping("/priv/use-cases")
public class UseCasesController {

    @Autowired
    private UrlService urlService;

    private UseCase getEnrichUseCase() throws UnsupportedEncodingException {

        /**
         * https://confluent.cloud/environments/env-rxyo9/clusters/lkc-wg7d5/ksql/lksqlc-1v2p6/editor?command=CREATE%20STREAM%20PAGEVIEWS_ENRICHED%0A%20%20%20%20with%20%28kafka_topic%3D%27pageviews_enriched%27%29%0A%20%20%20%20AS%20SELECT%20U.ID%20AS%20USERID%2C%20U.REGIONID%20AS%20REGION%2C%0A%20%20%20%20%20%20%20%20U.GENDER%20AS%20GENDER%2C%20V.PAGEID%20AS%20PAGE%0A%20%20%20%20FROM%20PAGEVIEWS%20V%20INNER%20JOIN%20USERS%20U%20%0A%20%20%20%20ON%20V.USERID%20%3D%20U.ID%3B&ksqlClusterId=lksqlc-1v2p6&properties=%7B%22auto.offset.reset%22%3A%22latest%22%7D
         */
        String cmd = "CREATE STREAM IF NOT EXISTS PAGEVIEWS_ENRICHED\n    with (kafka_topic='pageviews_enriched')\n    AS SELECT U.ID AS USERID, U.REGIONID AS REGION,\n        U.GENDER AS GENDER, V.PAGEID AS PAGE\n    FROM PAGEVIEWS V INNER JOIN USERS U \n    ON V.USERID = U.ID;";
        return new UseCase(
                "Enrich an event stream",
                "pageviews_enriched",
                "pageviews,users",
                cmd,
                "pageviews_enriched",
                String.format("%s/editor?command=%s&ksqlClusterId=%s&properties=%s",
                        urlService.getKsqlDbUrl(), // &ksqlClusterId=lksqlc-1v2p6&properties=%7B%22auto.offset.reset%22%3A%22latest%22%7D
                        UriUtils.encode(cmd, StandardCharsets.UTF_8.name()),
                        UriUtils.encode(urlService.getKsqlDbId(), StandardCharsets.UTF_8.name()),
                        UriUtils.encode("{\"auto.offset.reset\":\"latest\"}", StandardCharsets.UTF_8.name())));
    }
    private UseCase getFilterUseCase() throws UnsupportedEncodingException {
        String cmd = "CREATE STREAM IF NOT EXISTS PAGEVIEWS_FILTERED_USER_1\n    with (kafka_topic='pageviews_filtered_user_1')\n    AS SELECT * FROM PAGEVIEWS WHERE USERID = 'User_1';";
        return new UseCase(
                "Filter an event stream",
                "pageviews_filtered_user_1",
                "pageviews",
                cmd,
                "pageviews_filtered_user_1",
                String.format("%s/editor?command=%s&ksqlClusterId=%s&properties=%s",
                        urlService.getKsqlDbUrl(), // &ksqlClusterId=lksqlc-1v2p6&properties=%7B%22auto.offset.reset%22%3A%22latest%22%7D
                        UriUtils.encode(cmd, StandardCharsets.UTF_8.name()),
                        UriUtils.encode(urlService.getKsqlDbId(), StandardCharsets.UTF_8.name()),
                        UriUtils.encode("{\"auto.offset.reset\":\"latest\"}", StandardCharsets.UTF_8.name())));
    }
    private UseCase getAggregateUseCase() throws UnsupportedEncodingException {
        String cmd = "CREATE TABLE IF NOT EXISTS PAGEVIEWS_COUNT_BY_USER\n    with (kafka_topic='pageviews_count_by_user')\n    AS SELECT USERID, COUNT(*) AS numusers\n    FROM PAGEVIEWS WINDOW TUMBLING (size 30 second)\n    GROUP BY USERID HAVING COUNT(*) > 1;";
        return new UseCase(
                "Aggregate an event stream",
                "pageviews_count_by_user",
                "pageviews",
                cmd,
                "pageviews_count_by_user",
                String.format("%s/editor?command=%s&ksqlClusterId=%s&properties=%s",
                        urlService.getKsqlDbUrl(), // &ksqlClusterId=lksqlc-1v2p6&properties=%7B%22auto.offset.reset%22%3A%22latest%22%7D
                        UriUtils.encode(cmd, StandardCharsets.UTF_8.name()),
                        UriUtils.encode(urlService.getKsqlDbId(), StandardCharsets.UTF_8.name()),
                        UriUtils.encode("{\"auto.offset.reset\":\"latest\"}", StandardCharsets.UTF_8.name())));
    }
    @GetMapping
    public List<UseCase> getUseCases() throws UnsupportedEncodingException {
        return List.of(
                getEnrichUseCase(),
                getFilterUseCase(),
                getAggregateUseCase());
    }

}
