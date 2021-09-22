package io.confluent.demo.datamesh;

import io.confluent.demo.datamesh.model.UseCase;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/priv/use-cases")
public class UseCasesController {

    private UseCase getEnrichUseCase() {
        return new UseCase(
                "Enrich an event stream",
                "pageviews_enriched",
                "pageviews,users",
                "CREATE STREAM PAGEVIEWS_ENRICHED\n    with (kafka_topic='pageviews_enriched')\n    AS SELECT U.ID AS USERID, U.REGIONID AS REGION,\n        U.GENDER AS GENDER, V.PAGEID AS PAGE\n    FROM PAGEVIEWS V INNER JOIN USERS U \n    ON V.USERID = U.ID;",
                "pageviews_enriched");
    }
    private UseCase getFilterUseCase() {
        return new UseCase(
                "Filter an event stream",
                "pageviews_filtered_user_1",
                "pageviews",
                "CREATE STREAM PAGEVIEWS_FILTERED_USER_1\n    with (kafka_topic='pageviews_filtered_user_1')\n    AS SELECT * FROM PAGEVIEWS WHERE USERID = 'User_1';",
                "pageviews_filtered_user_1");
    }
    private UseCase getAggregateUseCase() {
        return new UseCase(
                "Aggregate an event stream",
                "pageviews_count_by_user",
                "pageviews",
                "CREATE TABLE PAGEVIEWS_COUNT_BY_USER\n    with (kafka_topic='pageviews_count_by_user')\n    AS SELECT USERID, COUNT(*) AS numusers\n    FROM PAGEVIEWS WINDOW TUMBLING (size 30 second)\n    GROUP BY USERID HAVING COUNT(*) > 1;",
                "pageviews_count_by_user");
    }
    @GetMapping
    public List<UseCase> getDataProducts() {
        return List.of(
                getEnrichUseCase(),
                getFilterUseCase(),
                getAggregateUseCase());
    }

}
