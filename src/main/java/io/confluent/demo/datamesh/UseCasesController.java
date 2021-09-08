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
                "CREATE STREAM PAGEVIEWS_ENRICHED AS SELECT U.ID AS USERID, U.REGIONID AS REGION, U.GENDER AS GENDER, V.PAGEID AS PAGE FROM PAGEVIEWS V INNER JOIN USERS U ON V.USERID = U.ID EMIT CHANGES;",
                "pageviews_enriched");
    }
    private UseCase getFilterUseCase() {
        return new UseCase(
                "Filter an event stream",
                "filtered_pageviews",
                "pageviews",
                "CREATE STREAM...",
                "filtered_pageviews");
    }
    private UseCase getAggregateUseCase() {
        return new UseCase(
                "Aggrevate an event stream",
                "aggregation",
                "pageviews",
                "CREATE STREAM...",
                "aggregation");
    }
    @GetMapping
    public List<UseCase> getDataProducts() {
        return List.of(
                getEnrichUseCase(),
                getFilterUseCase(),
                getAggregateUseCase());
    }

}
