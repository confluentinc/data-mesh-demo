package io.confluent.demo.datamesh;

import io.confluent.demo.datamesh.cc.datacatalog.api.SubjectVersionService;
import io.confluent.demo.datamesh.cc.datacatalog.api.TagService;
import io.confluent.demo.datamesh.cc.datacatalog.model.*;
import io.confluent.demo.datamesh.cc.ksqldb.api.KsqlDbService;
import io.confluent.demo.datamesh.cc.schemaregistry.api.SchemaRegistryService;
import io.confluent.demo.datamesh.cc.urls.api.UrlService;
import io.confluent.demo.datamesh.model.*;
import io.confluent.ksql.api.client.ExecuteStatementResult;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
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
        return new DataProductEntity(subjectVersion,
                tagService.getDataProductTagForSubjectVersion(qualifiedName),
                urlService.getDataProductUrls(qualifiedName));
    }

    private List<DataProduct> atlasEntitiesToDataProducts(List<AtlasEntityWithExtInfo> entities) {
        return entities.stream()
            .map(this::buildDataProductEntityFromSubjectVersion)
            .map(Mapper::ccToDataProduct)
            .collect(Collectors.toList());
    }
    public DataProduct get(String qualifiedName) {
        // TODO: Filter on the server side instead of locally with all the results
        return getDataProducts()
           .stream()
           .filter(dp -> dp.getQualifiedName().equals(qualifiedName))
           .findFirst()
           .orElseThrow(DataProductNotFoundException::new);
    }

    public List<DataProduct> getDataProducts() {
        return atlasEntitiesToDataProducts(subjectVersionService.getDataProducts());
    }
    public List<DataProduct> getAll() {
        return atlasEntitiesToDataProducts(subjectVersionService.getAll());
    }

    public DataProduct createDataProduct(CreateDataProductRequest request) throws Exception {
        if (request instanceof CreateS3DataProductRequest) {
            return null;
        }
        else if (request instanceof CreateTopicDataProductRequest) {
            return createTopicDataProduct((CreateTopicDataProductRequest)request);
        }
        else if (request instanceof CreateKsqlDbDataProductRequest) {
            return createKsqlDbDataProduct((CreateKsqlDbDataProductRequest) request);
        }
        else {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Unkonwn type in request body. Expecting @type field = (TOPIC | KSQLDB | S3)");
        }
    }
    public void deleteDataProduct(String qualifiedName) {
        tagService.unTagSubjectVersionAsDataProduct(qualifiedName);
    }

    private DataProduct createKsqlDbDataProduct(final CreateKsqlDbDataProductRequest request) throws Exception {
        // The following blocks until a result is obtained from the
        // ksqlDB service. The queryId will contain the ID of the new
        // persistent query that was created, and we'll use that to know if
        // we should crate a new Data Product in the subject service
        ExecuteStatementResult result = ksqlService.execute(request.getCommand()).get();
        if (result.queryId().isEmpty()) {
            throw new DataProductCreateException(result.toString());
        } else {
            String subjectName = request.getEventualSubjectName();
            int latestVersion = schemaService.getLatest(subjectName).version;
            String subjectFQN = String.format(":.:%s:%d", subjectName, latestVersion);
            TagResponse[] response = tagService.tagSubjectVersionAsDataProduct(
                    subjectFQN,
                    new DataProductTag(request.getOwner(), request.getDescription()));
            return get(response[0].getEntityName());
        }
    }
    private DataProduct createTopicDataProduct(final CreateTopicDataProductRequest request) throws Exception {
        tagService.tagSubjectVersionAsDataProduct(request.getQualifiedName(), request.getDataProductTag());
        return get(request.getQualifiedName());
    }
}
