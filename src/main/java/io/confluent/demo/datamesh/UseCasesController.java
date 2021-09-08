package io.confluent.demo.datamesh;

import io.confluent.demo.datamesh.model.UseCase;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/use-cases")
public class UseCasesController {

    private UseCase getEnrichUseCase() {
        return new UseCase(
                "Enrich an event stream",
                "pageviews_enriched",
                "pageviews,users",
                "CREATE STREAM PAGEVIEWS_ENRICHED with (kafka_topic='pageviews_enriched') AS SELECT U.ID AS USERID, U.REGIONID AS REGION, U.GENDER AS GENDER, V.PAGEID AS PAGE FROM PAGEVIEWS V INNER JOIN USERS U ON V.USERID = U.ID;",
                "pageviews_enriched");
    }
    private UseCase getFilterUseCase() {
        return new UseCase(
                "Filter an event stream",
                "pageviews_filtered",
                "pageviews",
                "CREATE STREAM PAGEVIEWS_FILTERED with (kafka_topic='pageviews_filtered') AS SELECT * FROM PAGEVIEWS WHERE USERID = 'User_1';",
                "pageviews_filtered");
    }
    private UseCase getAggregateUseCase() {
        return new UseCase(
                "Aggrevate an event stream",
                "pageviews_aggregation",
                "pageviews",
                "CREATE TABLE PAGEVIEWS_AGGREGATION with (kafka_topic='pageviews_aggregation') AS SELECT USERID, COUNT(*) AS numusers FROM PAGEVIEWS WINDOW TUMBLING (size 30 second) GROUP BY USERID HAVING COUNT(*) > 1;",
                "pageviews_aggregation");
    }
    @GetMapping
    public List<UseCase> getDataProducts() {
        return List.of(
                getEnrichUseCase(),
                getFilterUseCase(),
                getAggregateUseCase());
    }

}
