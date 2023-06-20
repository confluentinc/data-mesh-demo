package io.confluent.demo.datamesh;

import io.confluent.demo.datamesh.cc.datacatalog.api.TopicService;
import io.confluent.demo.datamesh.cc.datacatalog.model.DataProductBusinessMetadata;
import io.confluent.demo.datamesh.model.CreateDataProductRequest;
import io.confluent.demo.datamesh.model.CreateTopicDataProductRequest;
import io.confluent.demo.datamesh.model.DataProduct;
import org.javatuples.Pair;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.autoconfigure.web.client.RestClientTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.util.Assert;


import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

@RestClientTest({DataProductsController.class})
public class DataProductsControllerTests {

    @Autowired
    private MockRestServiceServer mockServer;
    @MockBean
    private AuditLogService auditLogService;
    @MockBean
    private TopicService svsService;
    @MockBean
    private DataProductService dpService;
    @Autowired
    private DataProductsController controller;
    @Value("${info.domain}")
    private String domain;

    private final DataProductBusinessMetadata.DataProductBusinessMetadataBuilder builder
            = new DataProductBusinessMetadata.DataProductBusinessMetadataBuilder(
                    "@analytics-team",
                    "Stock trades of a high combined monetary value.",
                    domain,
                    "tier-1",
                    "curated");

    @Test
    public void getDataProductsTest() throws Exception {
        Mockito
            .when(dpService.getTopicsTaggedAsDataProducts())
            .thenReturn(new Pair<>(Collections.emptyList(), Optional.empty()));
        List<DataProduct> result = controller.getDataProducts();
        Assert.notNull(result, "result of getting data products should be non-null");
    }

    @Test
    public void invalidOwnerDataProductRequestTest() {
        CreateDataProductRequest badRequest = new CreateTopicDataProductRequest(
                "pretend:qualified:name",
                builder.withOwner("mean-owner-name").build());

        DataProductsController.RestrictedDataProductException exception = assertThrows(
                DataProductsController.RestrictedDataProductException.class, () -> {
            controller.postDataProduct(badRequest);
        });

        assertTrue(exception.getMessage().contains("Unauthorized Data Product owner"));
    }
    @Test
    public void invalidDescriptionDataProductRequestTest() {
        CreateDataProductRequest badRequest = new CreateTopicDataProductRequest(
            "pretend:qualified:name",
            builder.withDescription("nasty description").build());

        DataProductsController.RestrictedDataProductException exception = assertThrows(
                DataProductsController.RestrictedDataProductException.class, () -> {
                    controller.postDataProduct(badRequest);
                });

        assertTrue(exception.getMessage().contains("Unauthorized Data Product description"));
    }
    @Test
    public void invalidSlaDataProductRequestTest() {
        CreateDataProductRequest badRequest = new CreateTopicDataProductRequest(
                "pretend:qualified:name",
        builder.withSla("ugly sla").build());

        DataProductsController.RestrictedDataProductException exception = assertThrows(
                DataProductsController.RestrictedDataProductException.class, () -> {
                    controller.postDataProduct(badRequest);
                });

        assertTrue(exception.getMessage().contains("Unauthorized Data Product SLA"));
    }
    @Test
    public void invalidQualityDataProductRequestTest() {
        CreateDataProductRequest badRequest = new CreateTopicDataProductRequest(
                "pretend:qualified:name",
                builder.withQuality("gross quality").build());

        DataProductsController.RestrictedDataProductException exception = assertThrows(
                DataProductsController.RestrictedDataProductException.class, () -> {
                    controller.postDataProduct(badRequest);
                });

        assertTrue(exception.getMessage().contains("Unauthorized Data Product Quality"));
    }
    @Test
    public void invalidDomainDataProductRequestTest() {
        CreateDataProductRequest badRequest = new CreateTopicDataProductRequest(
                "pretend:qualified:name",
                builder.withDomain("invalid Domain").build());

        DataProductsController.RestrictedDataProductException exception = assertThrows(
                DataProductsController.RestrictedDataProductException.class, () -> {
                    controller.postDataProduct(badRequest);
                });

        assertTrue(exception.getMessage().contains("domain"));
    }
}