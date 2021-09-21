package io.confluent.demo.datamesh;

import io.confluent.demo.datamesh.cc.datacatalog.api.SubjectVersionService;
import io.confluent.demo.datamesh.model.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.server.ServerErrorException;

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

    @GetMapping
    public List<DataProduct> getDataProducts() {
        return new ArrayList<>(dataProductService.getDataProducts());
    }

    @RequestMapping("/{qualifiedName}")
    public DataProduct getDataProduct(@PathVariable("qualifiedName") String qualifiedName) {
        return dataProductService.get(qualifiedName);
    }

    @PostMapping
    public DataProduct postDataProduct(@RequestBody CreateDataProductRequest request) throws Exception {
        return dataProductService.createDataProduct(request);
    }
    @DeleteMapping("/{qualifiedName}")
    public void deleteDataProduct(@PathVariable("qualifiedName") String qualifiedName) {
        dataProductService.deleteDataProduct(qualifiedName);
    }

    @GetMapping(path = "/manage")
    public ArrayList<DataProductOrTopic> getProductsAndTopics() {
        List<DataProduct> dps = getDataProducts();
        List<Topic> topics = subjectVersionService.getPotentialDataProducts()
            .stream()
            .map(Mapper::ccToTopic)
            .filter(topic -> !topic.getName().startsWith("_"))
            .collect(Collectors.toList());

        ArrayList<DataProductOrTopic> rv = new ArrayList<>();
        rv.addAll(dps);
        rv.addAll(topics);
        return rv;
    }
}