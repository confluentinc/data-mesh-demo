package io.confluent.demo.datamesh;

import io.confluent.demo.datamesh.cc.datacatalog.api.SubjectVersionService;
import io.confluent.demo.datamesh.cc.datacatalog.api.TagService;
import io.confluent.demo.datamesh.cc.datacatalog.model.AtlasEntity;
import io.confluent.demo.datamesh.cc.datacatalog.model.AtlasEntityWithExtInfo;
import io.confluent.demo.datamesh.cc.datacatalog.model.DataProductEntity;
import io.confluent.demo.datamesh.cc.datacatalog.model.Tag;
import io.confluent.demo.datamesh.model.DataProduct;
import io.confluent.demo.datamesh.model.Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.ResponseStatus;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class DataProductService {

    @ResponseStatus(value= HttpStatus.NOT_FOUND)
    public class DataProductNotFoundException extends RuntimeException { }

    @Autowired
    private SubjectVersionService subjectVersionService;

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

}
