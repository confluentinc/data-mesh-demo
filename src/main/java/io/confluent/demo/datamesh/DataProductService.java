package io.confluent.demo.datamesh;

import io.confluent.demo.datamesh.cc.datacatalog.api.SubjectVersionService;
import io.confluent.demo.datamesh.cc.datacatalog.api.TagService;
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
    private SubjectVersionService subjectVersionService;
    @Autowired
    private KsqlDbService ksqlService;
    @Autowired
    private TagService tagService;
    @Autowired
    private SchemaRegistryService schemaService;
    @Autowired
    private UrlService urlService;

    private DataProductEntity buildDataProductEntityFromSubjectVersion(AtlasEntityWithExtInfo subjectVersion) {
        String qualifiedName = subjectVersion.getEntity().getAttributes().get("qualifiedName").toString();
        Schema schema = schemaService
                .getLatest((String)subjectVersion.getEntity().getAttributes().get("name"));
        return new DataProductEntity(
                subjectVersion,
                tagService.getDataProductTagForSubjectVersion(qualifiedName),
                urlService.getDataProductUrls(qualifiedName),
                schema);
    }

    private List<DataProduct> atlasEntitiesToDataProducts(List<AtlasEntityWithExtInfo> entities) {
        return entities.stream()
            .map(this::buildDataProductEntityFromSubjectVersion)
            .map(Mapper::ccToDataProduct)
            .collect(Collectors.toList());
    }
    public Pair<DataProduct, Optional<AuditLogEntry>> get(String qualifiedName) {
        // TODO: Filter on the server side instead of locally with all the results
        Pair<List<DataProduct>, Optional<AuditLogEntry>> response = getDataProducts();
        return new Pair<>(
                response.getValue0()
                    .stream()
                    .filter(dp -> dp.getQualifiedName().equals(qualifiedName))
                    .findFirst()
                    .orElseThrow(DataProductNotFoundException::new),
                response.getValue1());
    }

    public Pair<List<DataProduct>, Optional<AuditLogEntry>> getDataProducts() {
        SubjectVersionServiceResult result = subjectVersionService.getDataProducts();
        return new Pair<>(
            atlasEntitiesToDataProducts(subjectVersionService.getDataProducts().getEntities()),
            result.getAuditLogEntry());
    }
    public List<DataProduct> getAll() {
        return atlasEntitiesToDataProducts(subjectVersionService.getAll().getEntities());
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
        return tagService.unTagSubjectVersionAsDataProduct(qualifiedName).getAuditLogEntry();
    }

    private Pair<DataProduct, Optional<AuditLogEntry>> createTopicDataProduct(final CreateTopicDataProductRequest request)
            throws Exception {

        TagServiceResponse tagResponse =
                tagService.tagSubjectVersionAsDataProduct(request.getQualifiedName(), request.getDataProductTag());

        Pair<DataProduct, Optional<AuditLogEntry>> getDataProductResponse =
                get(request.getQualifiedName());

        return new Pair<>(getDataProductResponse.getValue0(), tagResponse.getAuditLogEntry());
    }
}
