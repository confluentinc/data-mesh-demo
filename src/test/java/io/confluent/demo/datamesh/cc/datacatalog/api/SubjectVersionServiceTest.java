package io.confluent.demo.datamesh.cc.datacatalog.api;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.json.JsonMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import io.confluent.demo.datamesh.cc.datacatalog.model.AtlasEntityWithExtInfo;
import io.confluent.demo.datamesh.cc.datacatalog.model.TopicServiceResult;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.client.RestClientTest;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;

import java.io.IOException;

import static org.assertj.core.api.AssertionsForClassTypes.assertThat;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

@RestClientTest({TopicService.class})
public class SubjectVersionServiceTest {

    @Autowired
    private MockRestServiceServer mockServer;
    @Autowired
    private TopicService svsService;

    @Test
    public void getTopicEntityTest() throws IOException {

        final var qualifiedName = "lsrc-jpz2w:.:stocktrades";
        final var response = new ClassPathResource("svsEntityTopicResponse.json");

        ObjectMapper mapper = JsonMapper
                .builder()
                .addModule(new JavaTimeModule())
                .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false)
                .build();

        final AtlasEntityWithExtInfo expected = mapper.readValue(
                response.getFile(), AtlasEntityWithExtInfo.class);

        mockServer
            .expect(requestTo("/entity/type/kafka_topic/name/" + qualifiedName))
            .andRespond(withSuccess(response, MediaType.APPLICATION_JSON));

        AtlasEntityWithExtInfo result =
                svsService.getTopicEntity("lsrc-jpz2w:.:stocktrades");

        assertThat(expected).usingRecursiveComparison().isEqualTo(result);
        mockServer.verify();
    }
    @Test
    public void getAllTest() throws IOException {

        final var response = new ClassPathResource("svsSearchResponse.json");
        final var usersResponse = new ClassPathResource("svsUsersValueResponse.json");
        final var pageViewsResponse = new ClassPathResource("svsPageviewsValueResponse.json");
        final var stockTradesResponse = new ClassPathResource("svsStockTradesValueResponse.json");

        ObjectMapper mapper = JsonMapper
                .builder()
                .addModule(new JavaTimeModule())
                .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false)
                .build();

        mockServer
                .expect(requestTo("/search/basic?types=kafka_topic"))
                .andRespond(withSuccess(response, MediaType.APPLICATION_JSON));
        mockServer
                .expect(requestTo("/entity/type/kafka_topic/name/lsrc-jpz2w:.:users"))
                .andRespond(withSuccess(usersResponse, MediaType.APPLICATION_JSON));
        mockServer
                .expect(requestTo("/entity/type/kafka_topic/name/lsrc-jpz2w:.:stocktrades"))
                .andRespond(withSuccess(stockTradesResponse, MediaType.APPLICATION_JSON));
        mockServer
                .expect(requestTo("/entity/type/kafka_topic/name/lsrc-jpz2w:.:pageviews"))
                .andRespond(withSuccess(pageViewsResponse, MediaType.APPLICATION_JSON));

        TopicServiceResult result = svsService.getAll();

        mockServer.verify();
    }
}
