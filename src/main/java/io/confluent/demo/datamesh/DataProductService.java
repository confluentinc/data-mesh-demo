package io.confluent.demo.datamesh;

import io.confluent.demo.datamesh.cc.datacatalog.api.BusinessMetadataService;
import io.confluent.demo.datamesh.cc.datacatalog.api.TagService;
import io.confluent.demo.datamesh.cc.datacatalog.api.TopicService;
import io.confluent.demo.datamesh.cc.datacatalog.model.*;
import io.confluent.demo.datamesh.cc.ksqldb.api.KsqlDbService;
import io.confluent.demo.datamesh.cc.schemaregistry.api.SchemaRegistryService;
import io.confluent.demo.datamesh.cc.schemaregistry.model.Schema;
import io.confluent.demo.datamesh.cc.urls.api.UrlService;
import io.confluent.demo.datamesh.model.*;
import org.javatuples.Pair;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class DataProductService {

    @ResponseStatus(value=HttpStatus.NOT_FOUND)
    public static class DataProductNotFoundException extends RuntimeException { }
    @ResponseStatus(value=HttpStatus.INTERNAL_SERVER_ERROR)
    public static class DataProductCreateException extends RuntimeException {
        public DataProductCreateException(String msg) {
           super(msg);
        }
    }

    @Autowired
    private TopicService topicService;
    @Autowired
    private TagService tagService;
    @Autowired
    private KsqlDbService ksqlService;
    @Autowired
    private BusinessMetadataService businessMetadataService;
    @Autowired
    private SchemaRegistryService schemaService;
    @Autowired
    private UrlService urlService;

    private DataProductEntity buildDataProductEntityFromTopic(AtlasEntityWithExtInfo topic) {
        String qualifiedName = topic.getEntity().getAttributes().get("qualifiedName").toString();
        Schema schema = schemaService
                .getLatest((String)topic.getEntity().getAttributes().get("name") + "-value");
        return new DataProductEntity(
                topic,
                businessMetadataService.getDataProductBusinessMetadataForTopic(qualifiedName),
                urlService.getDataProductUrls(qualifiedName),
                schema);
    }

    private List<DataProduct> atlasEntitiesToDataProducts(List<AtlasEntityWithExtInfo> entities) {
        return entities.stream()
            .map(this::buildDataProductEntityFromTopic)
            .map(Mapper::ccToDataProduct)
            .collect(Collectors.toList());
    }
    public Pair<DataProduct, Optional<AuditLogEntry>> get(String qualifiedName) {
        // TODO: Filter on the server side instead of locally with all the results
        Pair<List<DataProduct>, Optional<AuditLogEntry>> response = getTopicsTaggedAsDataProducts();
        return new Pair<>(
                response.getValue0()
                    .stream()
                    .filter(dp -> dp.getQualifiedName().equals(qualifiedName))
                    .findFirst()
                    .orElseThrow(DataProductNotFoundException::new),
                response.getValue1());
    }

    public Pair<List<DataProduct>, Optional<AuditLogEntry>> getTopicsTaggedAsDataProducts() {
        TopicServiceResult result = topicService.getDataProductsByTag();
        return new Pair<>(
            atlasEntitiesToDataProducts(topicService.getDataProductsByTag().getEntities()),
            result.getAuditLogEntry());
    }
    public List<DataProduct> getAll() {
        return atlasEntitiesToDataProducts(topicService.getAll().getEntities());
    }

    public Pair<DataProduct, Optional<AuditLogEntry>> createDataProduct(CreateDataProductRequest request) throws Exception {
        if (request instanceof CreateTopicDataProductRequest) {
            return createTopicDataProduct((CreateTopicDataProductRequest)request);
        }
        else if (request instanceof CreateS3DataProductRequest) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Unknown type in request body. Expecting @type field = (TOPIC)");
        }
        else if (request instanceof CreateKsqlDbDataProductRequest) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Unknown type in request body. Expecting @type field = (TOPIC)");
        }
        else {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Unknown type in request body. Expecting @type field = (TOPIC)");
        }
    }
    public Optional<AuditLogEntry> deleteDataProduct(String qualifiedName) {
        tagService.unTagTopicAsDataProduct(qualifiedName);
        return businessMetadataService.removeDataProductBusinessMetadata(qualifiedName).getAuditLogEntry();
    }

    private Pair<DataProduct, Optional<AuditLogEntry>> createTopicDataProduct(final CreateTopicDataProductRequest request)
            throws Exception {

        BusinessMetadataServiceResponse response =
                businessMetadataService.businessMetadataTopicAsDataProduct(request.getQualifiedName(), request.getDataProductBusinessMetadata());

        //TODO - Eliminate topic-tagging when business metadata search is available.
        tagService.tagTopicAsDataProduct(request.getQualifiedName());

        Pair<DataProduct, Optional<AuditLogEntry>> getDataProductResponse =
                get(request.getQualifiedName());

        return new Pair<>(getDataProductResponse.getValue0(), response.getAuditLogEntry());
    }
}
