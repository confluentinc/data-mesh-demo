package io.confluent.demo.datamesh;

import io.confluent.demo.datamesh.model.DataProduct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/data-products")
public class DataProductsController {

    @Autowired
    private DataProductService dataProductService;

    @GetMapping
    public List<DataProduct> getDataProducts() {
        return new ArrayList<>(dataProductService.getAll());
    }

    @RequestMapping("/{qualifiedName}")
    public DataProduct getDataProduct(@PathVariable("qualifiedName") String qualifiedName) {
        return dataProductService.get(qualifiedName);
    }

}