package io.confluent.demo.datamesh;

import io.confluent.demo.datamesh.cc.datacatalog.api.SubjectVersionService;
import io.confluent.demo.datamesh.cc.datacatalog.api.TagService;
import io.confluent.demo.datamesh.cc.datacatalog.model.AtlasEntityWithExtInfo;
import io.confluent.demo.datamesh.cc.datacatalog.model.DataProductEntity;
import io.confluent.demo.datamesh.cc.datacatalog.model.Tag;
import io.confluent.demo.datamesh.cc.ksqldb.api.KsqlDbService;
import io.confluent.demo.datamesh.model.*;
import io.confluent.ksql.api.client.ExecuteStatementResult;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

@Service
public class DataProductService {

    @ResponseStatus(value=HttpStatus.NOT_FOUND)
    public static class DataProductNotFoundException extends RuntimeException { }
    @ResponseStatus(value=HttpStatus.INTERNAL_SERVER_ERROR)
    public static class DataProductCreateException extends RuntimeException {}

    @Autowired
    private SubjectVersionService subjectVersionService;
    @Autowired
    private KsqlDbService ksqlService;

    @Autowired
    private TagService tagService;

    private DataProductEntity buildDataProductEntityFromSubjectVersion(AtlasEntityWithExtInfo subjectVersion) {
        Tag dataProductTag = tagService.getDataProductTagForSubjectVersion(
                subjectVersion.getEntity().getAttributes().get("qualifiedName").toString());
        return new DataProductEntity(subjectVersion, dataProductTag);
    }

    public DataProduct get(String qualifiedName) {
        // TODO: Filter on the server side instead of locally with all the results
        return getAll()
           .stream()
           .filter(dp -> dp.getQualifiedName().equals(qualifiedName))
           .findFirst()
           .orElseThrow(DataProductNotFoundException::new);
    }

    public List<DataProduct> getAll() {
        return subjectVersionService.getAll()
            .stream()
            .map(this::buildDataProductEntityFromSubjectVersion)
            .map(Mapper::ccToDataProduct)
            .collect(Collectors.toList());
    }

    public DataProduct createDataProduct(CreateDataProductRequest request) throws Exception {
        if (request instanceof CreateS3DataProductRequest) {
            return null;
        }
        else if (request instanceof CreateKsqlDbDataProductRequest) {
            CreateKsqlDbDataProductRequest ksqlRequest = (CreateKsqlDbDataProductRequest)request;
            ExecuteStatementResult result = ksqlService.execute(ksqlRequest.getCommand()).get();
            if (result.queryId().isEmpty()) {
                throw new DataProductCreateException();
            } else {
                // TODO: Implement tagging of new data product
                return new DataProduct("Fixme", "qualifiedName",
                        "owner", "description");
            }
        }
        else {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Unkonwn type in request body. Expecting @type field = (KSQLDB | S3)");
        }
    }
}
