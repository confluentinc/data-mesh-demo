package io.confluent.demo.datamesh;

import io.confluent.demo.datamesh.cc.datacatalog.api.SubjectVersionService;
import io.confluent.demo.datamesh.cc.datacatalog.model.DataProductTag;
import io.confluent.demo.datamesh.cc.datacatalog.model.SubjectVersionServiceResult;
import io.confluent.demo.datamesh.model.*;
import org.javatuples.Pair;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
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
    @Value("${info.domain}")
    private String domain;

    @ResponseStatus(value= HttpStatus.UNAUTHORIZED)
    public static class RestrictedDataProductException extends RuntimeException {
        public RestrictedDataProductException(String dpName) {
            super(String.format("Cannot delete %s Data Product", dpName));
        }
    }
    private final List<String> protectedOwners = List.of("@edge-team");
    private final List<String> allowedDescriptions = List.of(
            "Stock trades of a high combined monetary value.",
            "Stocks that are trending based on 15 minute tumbling windows.",
            "Enriched stock trades performed by accounts domiciled within the USA.");
    private final List<String> allowedOwners = List.of(
            "@analytics-team",
            "@stock-trades-team",
            "@user-management-team",
            "@accounting-team");
    private final List<String> allowedSLAs = List.of("tier-1", "tier-2", "tier-3");
    private final List<String> allowedQualities = List.of("authoritative", "curated", "raw");

    private void validateCreateDataProductRequest(CreateDataProductRequest request) {
        DataProductTag incomingTag = request.getDataProductTag();

        if ( !allowedDescriptions.contains(incomingTag.getDescription()) ) {
            throw new RestrictedDataProductException(
                    String.format("Unauthorized Data Product description"));
        }

        if ( !allowedOwners.contains(incomingTag.getOwner()) ) {
            throw new RestrictedDataProductException(
                    String.format("Unauthorized Data Product owner"));
        }

        if ( !allowedSLAs.contains(incomingTag.getSla()) ) {
            throw new RestrictedDataProductException(
                    String.format("Unauthorized Data Product SLA"));
        }

        if ( !allowedQualities.contains(incomingTag.getQuality()) ) {
            throw new RestrictedDataProductException(
                    String.format("Unauthorized Data Product Quality"));
        }

        if ( !incomingTag.getDomain().equals(domain) ) {
            throw new RestrictedDataProductException(
                    String.format("Unauthorized Data Product domain: %s", request.getDataProductTag().getDomain()));
        }

        if ( protectedOwners.contains(incomingTag.getOwner()) ) {
            throw new RestrictedDataProductException(
                    String.format("Unauthorized Data Product owner: %s", request.getDataProductTag().getOwner()));
        }
    }

    @GetMapping
    public List<DataProduct> getDataProducts() {
        Pair<List<DataProduct>, Optional<AuditLogEntry>> response = dataProductService.getDataProducts();
        response.getValue1().ifPresent(auditLogService::sendAuditLogEntry);
        return new ArrayList<>(
                dataProductService.getDataProducts().getValue0()
                    .stream()
                    .filter(dp -> !dp.getName().startsWith("_"))
                    .collect(Collectors.toList()));
    }

    @RequestMapping("/{qualifiedName}")
    public DataProduct getDataProduct(@PathVariable("qualifiedName") String qualifiedName) {
       Pair<DataProduct, Optional<AuditLogEntry>> response = dataProductService.get(qualifiedName);
       response.getValue1().ifPresent(auditLogService::sendAuditLogEntry);
       return response.getValue0();
    }

    @PostMapping
    public DataProduct postDataProduct(@RequestBody CreateDataProductRequest request) throws Exception {

        if ( !StringUtils.hasText(request.getDataProductTag().getDomain()) ) {
            request.setDataProductTag(
                request.getDataProductTag().builder().withDomain(this.domain).build());
        }

        validateCreateDataProductRequest(request);

        Pair<DataProduct, Optional<AuditLogEntry>> response = dataProductService.createDataProduct(request);
        response.getValue1().ifPresent(auditLogService::sendAuditLogEntry);
        return response.getValue0();
    }
    @DeleteMapping("/{qualifiedName}")
    public void deleteDataProduct(@PathVariable("qualifiedName") String qualifiedName) {
        DataProduct dp = getDataProduct(qualifiedName);
        if (!dp.getDomain().equals(domain)) {
            throw new RestrictedDataProductException(qualifiedName);
        }
        else if (protectedOwners.contains(dp.getOwner())) {
            throw new RestrictedDataProductException(qualifiedName);
        }

        dataProductService
            .deleteDataProduct(qualifiedName)
            .ifPresent(auditLogService::sendAuditLogEntry);
    }

    @GetMapping(path = "/manage")
    public ArrayList<DataProductOrTopic> getProductsAndTopics() {
        List<DataProduct> allDataProducts = getDataProducts();

        SubjectVersionServiceResult subjectVersionServiceResult = subjectVersionService.getPotentialDataProducts();

        List<Topic> topics = subjectVersionServiceResult
            .getEntities()
            .stream()
            .map(Mapper::ccToTopic)
            .filter(topic -> !topic.getName().startsWith("_"))
            .filter(topic -> {
                return allDataProducts.stream().filter(dp -> dp.getName().equals(topic.getName()))
                        .collect(Collectors.toList()).size() == 0;
            })
            .collect(Collectors.toList());

        ArrayList<DataProductOrTopic> rv = new ArrayList<>();
        rv.addAll(allDataProducts);
        rv.addAll(topics);

        subjectVersionServiceResult.getAuditLogEntry().ifPresent(auditLogService::sendAuditLogEntry);

        return rv;
    }
}