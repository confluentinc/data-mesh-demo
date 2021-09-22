package io.confluent.demo.datamesh;

import io.confluent.demo.datamesh.cc.datacatalog.api.SubjectVersionService;
import io.confluent.demo.datamesh.cc.datacatalog.model.SubjectVersionServiceResult;
import io.confluent.demo.datamesh.model.*;
import org.javatuples.Pair;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/priv/data-products")
public class DataProductsController {

    @Autowired
    private DataProductService dataProductService;
    @Autowired
    private SubjectVersionService subjectVersionService;
    @Autowired
    private AuditLogService auditLogService;

    @GetMapping
    public List<DataProduct> getDataProducts() {
        Pair<List<DataProduct>, Optional<AuditLogEntry>> response = dataProductService.getDataProducts();
        response.getValue1().ifPresent(auditLogService::sendAuditLogEntry);
        return new ArrayList<>(dataProductService.getDataProducts().getValue0());
    }

    @RequestMapping("/{qualifiedName}")
    public DataProduct getDataProduct(@PathVariable("qualifiedName") String qualifiedName) {
       Pair<DataProduct, Optional<AuditLogEntry>> response = dataProductService.get(qualifiedName);
       response.getValue1().ifPresent(auditLogService::sendAuditLogEntry);
       return response.getValue0();
    }

    @PostMapping
    public DataProduct postDataProduct(@RequestBody CreateDataProductRequest request) throws Exception {
        Pair<DataProduct, Optional<AuditLogEntry>> response = dataProductService.createDataProduct(request);
        response.getValue1().ifPresent(auditLogService::sendAuditLogEntry);
        return response.getValue0();
    }
    @DeleteMapping("/{qualifiedName}")
    public void deleteDataProduct(@PathVariable("qualifiedName") String qualifiedName) {
        dataProductService.deleteDataProduct(qualifiedName).ifPresent(auditLogService::sendAuditLogEntry);
    }

    @GetMapping(path = "/manage")
    public ArrayList<DataProductOrTopic> getProductsAndTopics() {
        List<DataProduct> dps = getDataProducts();

        SubjectVersionServiceResult subjectVersionServiceResult = subjectVersionService.getPotentialDataProducts();

        List<Topic> topics = subjectVersionServiceResult
            .getEntities()
            .stream()
            .map(Mapper::ccToTopic)
            .filter(topic -> !topic.getName().startsWith("_"))
            .collect(Collectors.toList());

        ArrayList<DataProductOrTopic> rv = new ArrayList<>();
        rv.addAll(dps);
        rv.addAll(topics);

        subjectVersionServiceResult.getAuditLogEntry().ifPresent(auditLogService::sendAuditLogEntry);

        return rv;
    }
}