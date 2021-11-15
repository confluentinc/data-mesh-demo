package io.confluent.demo.datamesh.cc.datacatalog.api;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.json.JsonMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import io.confluent.demo.datamesh.cc.datacatalog.model.AtlasEntityWithExtInfo;
import io.confluent.demo.datamesh.cc.datacatalog.model.SubjectVersionServiceResult;
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

@RestClientTest({SubjectVersionService.class})
public class SubjectVersionServiceTest {

    @Autowired
    private MockRestServiceServer mockServer;
    @Autowired
    private SubjectVersionService svsService;

    @Test
    public void getSubjectVersionEntityTest() throws IOException {

        final var qualifiedName = "lsrc-jpz2w:.:stocktrades-value:1";
        final var response = new ClassPathResource("svsEntitySrSubjectVersionResponse.json");

        ObjectMapper mapper = JsonMapper
                .builder()
                .addModule(new JavaTimeModule())
                .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false)
                .build();

        final AtlasEntityWithExtInfo expected = mapper.readValue(
                response.getFile(), AtlasEntityWithExtInfo.class);

        mockServer
            .expect(requestTo("/entity/type/sr_subject_version/name/" + qualifiedName))
            .andRespond(withSuccess(response, MediaType.APPLICATION_JSON));

        AtlasEntityWithExtInfo result =
                svsService.getSubjectVersionEntity("lsrc-jpz2w:.:stocktrades-value:1");

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
                .expect(requestTo("/search/basic?types=sr_subject_version&attrs=version"))
                .andRespond(withSuccess(response, MediaType.APPLICATION_JSON));
        mockServer
                .expect(requestTo("/entity/type/sr_subject_version/name/lsrc-jpz2w:.:users-value:1"))
                .andRespond(withSuccess(usersResponse, MediaType.APPLICATION_JSON));
        mockServer
                .expect(requestTo("/entity/type/sr_subject_version/name/lsrc-jpz2w:.:stocktrades-value:1"))
                .andRespond(withSuccess(stockTradesResponse, MediaType.APPLICATION_JSON));
        mockServer
                .expect(requestTo("/entity/type/sr_subject_version/name/lsrc-jpz2w:.:pageviews-value:1"))
                .andRespond(withSuccess(pageViewsResponse, MediaType.APPLICATION_JSON));

        SubjectVersionServiceResult result = svsService.getAll();

        mockServer.verify();
    }
}
