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
                "description",
                "pageviews_enriched",
                "pageviews,users",
                cmd,
                "pageviews_enriched",
                String.format("%s/editor?command=%s&ksqlClusterId=%s&properties=%s",
                        urlService.getKsqlDbUrl(), // &ksqlClusterId=lksqlc-1v2p6&properties=%7B%22auto.offset.reset%22%3A%22latest%22%7D
                        UriUtils.encode(cmd, StandardCharsets.UTF_8.name()),
                        UriUtils.encode(urlService.getKsqlDbId(), StandardCharsets.UTF_8.name()),
                        UriUtils.encode("{\"auto.offset.reset\":\"latest\"}", StandardCharsets.UTF_8.name())),
                "title");
    }
    private UseCase getFilterUseCase() throws UnsupportedEncodingException {
        String cmd = "CREATE STREAM IF NOT EXISTS PAGEVIEWS_FILTERED_USER_1\n    with (kafka_topic='pageviews_filtered_user_1')\n    AS SELECT * FROM PAGEVIEWS WHERE USERID = 'User_1';";
        return new UseCase(
                "description",
                "pageviews_filtered_user_1",
                "pageviews",
                cmd,
                "pageviews_filtered_user_1",
                String.format("%s/editor?command=%s&ksqlClusterId=%s&properties=%s",
                        urlService.getKsqlDbUrl(), // &ksqlClusterId=lksqlc-1v2p6&properties=%7B%22auto.offset.reset%22%3A%22latest%22%7D
                        UriUtils.encode(cmd, StandardCharsets.UTF_8.name()),
                        UriUtils.encode(urlService.getKsqlDbId(), StandardCharsets.UTF_8.name()),
                        UriUtils.encode("{\"auto.offset.reset\":\"latest\"}", StandardCharsets.UTF_8.name())),
                "title");
    }
    private UseCase getAggregateUseCase() throws UnsupportedEncodingException {
        String cmd = "CREATE TABLE IF NOT EXISTS PAGEVIEWS_COUNT_BY_USER\n    with (kafka_topic='pageviews_count_by_user')\n    AS SELECT USERID, COUNT(*) AS numusers\n    FROM PAGEVIEWS WINDOW TUMBLING (size 30 second)\n    GROUP BY USERID HAVING COUNT(*) > 1;";
        return new UseCase(
                "description",
                "pageviews_count_by_user",
                "pageviews",
                cmd,
                "pageviews_count_by_user",
                String.format("%s/editor?command=%s&ksqlClusterId=%s&properties=%s",
                        urlService.getKsqlDbUrl(), // &ksqlClusterId=lksqlc-1v2p6&properties=%7B%22auto.offset.reset%22%3A%22latest%22%7D
                        UriUtils.encode(cmd, StandardCharsets.UTF_8.name()),
                        UriUtils.encode(urlService.getKsqlDbId(), StandardCharsets.UTF_8.name()),
                        UriUtils.encode("{\"auto.offset.reset\":\"latest\"}", StandardCharsets.UTF_8.name())),
                "title");
    }
    private UseCase getStocksSoldUseCase() throws UnsupportedEncodingException {
        String cmd = "CREATE TABLE IF NOT EXISTS MOST_POPULAR_STOCK_SOLD\n    with (kafka_topic='most_popular_stock_sold')\n    AS SELECT SYMBOL, TOPK(COUNT(*), 1) AS numsold\n    FROM STOCKTRADES\n    WHERE SIDE = 'SELL'\n    WINDOW TUMBLING (size 60 second)\n    GROUP BY USERID HAVING COUNT(*) > 1;";
        return new UseCase(
                "Compute the most-sold stock in the last minute. This consumes data from the `stocktrades` topic, and emits results that can be published as their own data product.",
                "most_popular_stock_sold",
                "stocktrades",
                cmd,
                "most_popular_stock_sold",
                String.format("%s/editor?command=%s&ksqlClusterId=%s&properties=%s",
                        urlService.getKsqlDbUrl(), // &ksqlClusterId=lksqlc-1v2p6&properties=%7B%22auto.offset.reset%22%3A%22latest%22%7D
                        UriUtils.encode(cmd, StandardCharsets.UTF_8.name()),
                        UriUtils.encode(urlService.getKsqlDbId(), StandardCharsets.UTF_8.name()),
                        UriUtils.encode("{\"auto.offset.reset\":\"latest\"}", StandardCharsets.UTF_8.name())),
                "Most sold stock per minute");
    }
    private UseCase getHighValueStockTradesUseCase() throws UnsupportedEncodingException {
        String cmd = "CREATE STREAM IF NOT EXISTS high_value_stock_trades\n    WITH (KAFKA_TOPIC='high_value_stock_trades') AS\nSELECT U.ID USERID\n    U.REGIONID REGION,\n    T.SIDE SIDE,\n    T.QUANTITY QUANTITY,\n    T.SYMBOL SYMBOL,\n    T.PRICE PRICE,\n    T.ACCOUNT ACCOUNT\nFROM STOCKTRADES T\nINNER JOIN USERS U ON (T.USERID = U.ID)\nWHERE ((T.PRICE > 500) AND (T.QUANTITY > 2500))\nEMIT CHANGES;";
        return new UseCase(
                "Join the Users Data Product on the domain-internal Stock Trades topic. Find the largest trades, and emit the enriched trade for further review.",
                "high_value_stock_trades",
                "stocktrades, users",
                cmd,
                "high_value_stock_trades",
                String.format("%s/editor?command=%s&ksqlClusterId=%s&properties=%s",
                        urlService.getKsqlDbUrl(), // &ksqlClusterId=lksqlc-1v2p6&properties=%7B%22auto.offset.reset%22%3A%22latest%22%7D
                        UriUtils.encode(cmd, StandardCharsets.UTF_8.name()),
                        UriUtils.encode(urlService.getKsqlDbId(), StandardCharsets.UTF_8.name()),
                        UriUtils.encode("{\"auto.offset.reset\":\"latest\"}", StandardCharsets.UTF_8.name())),
                "Find high-value stock trades for review");
    }
    private UseCase getInfoSecUseCase() throws UnsupportedEncodingException {
        String cmd = "CREATE STREAM IF NOT EXISTS US_ENRICHED_STOCK_TRADES\n    WITH (KAFKA_TOPIC='us_enriched_stock_trades') AS SELECT\n    U.ID USERID, U.REGIONID REGION,\n    T.SIDE SIDE, T.QUANTITY QUANTITY, T.SYMBOL SYMBOL, T.PRICE PRICE, T.ACCOUNT ACCOUNT\n    FROM STOCKTRADES T\n    INNER JOIN USERS U ON T.USERID = U.ID\n    WHERE U.REGIONID = 'REGION_1'\n    EMIT CHANGES;";
        return new UseCase(
                "US (Region_1) and International data (Region_2 through Region_9) need to be treated separately. Ensure that all International users are filtered out, such that they are not retained in any US-domiciled datastores.",
                "us_enriched_stock_trades",
                "stocktrades, users",
                cmd,
                "us_enriched_stock_trades",
                String.format("%s/editor?command=%s&ksqlClusterId=%s&properties=%s",
                        urlService.getKsqlDbUrl(), // &ksqlClusterId=lksqlc-1v2p6&properties=%7B%22auto.offset.reset%22%3A%22latest%22%7D
                        UriUtils.encode(cmd, StandardCharsets.UTF_8.name()),
                        UriUtils.encode(urlService.getKsqlDbId(), StandardCharsets.UTF_8.name()),
                        UriUtils.encode("{\"auto.offset.reset\":\"latest\"}", StandardCharsets.UTF_8.name())),
                "Separate US Data for InfoSec management");
    }
    private UseCase getTrendingStocksUseCase() throws UnsupportedEncodingException {
        String cmd = "CREATE TABLE IF NOT EXISTS trending_stocks\n    WITH (kafka_topic='trending_stocks') AS\nSELECT symbol,\n    SUM(quantity) as total_quantity,\n    WINDOWSTART as window_start,\n    WINDOWEND as window_end\nFROM stocktrades\nWINDOW TUMBLING (SIZE 15 MINUTES)\nGROUP BY symbol;";
        return new UseCase(
                "Create a table of stocks that are trading at a greater rate than others over a window of time",
                "trending_stocks",
                "stocktrades",
                cmd,
                "trending_stocks",
                String.format("%s/editor?command=%s&ksqlClusterId=%s&properties=%s",
                        urlService.getKsqlDbUrl(), // &ksqlClusterId=lksqlc-1v2p6&properties=%7B%22auto.offset.reset%22%3A%22latest%22%7D
                        UriUtils.encode(cmd, StandardCharsets.UTF_8.name()),
                        UriUtils.encode(urlService.getKsqlDbId(), StandardCharsets.UTF_8.name()),
                        UriUtils.encode("{\"auto.offset.reset\":\"latest\"}", StandardCharsets.UTF_8.name())),
                "Calculate Trending Stocks");
    }
    @GetMapping
    public List<UseCase> getUseCases() throws UnsupportedEncodingException {
        return List.of(
                getTrendingStocksUseCase(),
                getHighValueStockTradesUseCase(),
                getInfoSecUseCase());
    }

}
