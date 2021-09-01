package io.confluent.demo.datamesh;

import io.confluent.demo.datamesh.model.CreateKsqlDbDataProductRequest;
import io.confluent.demo.datamesh.model.CreateS3DataProductRequest;
import io.confluent.demo.datamesh.model.DataProduct;
import io.confluent.demo.datamesh.model.CreateDataProductRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.server.ServerErrorException;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/data-products")
public class DataProductsController {

    @Autowired
    private DataProductService dataProductService;

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
    @DeleteMapping
    public void deleteDataProduct(@PathVariable("qualifiedName") String qualifiedName) {

    }

}