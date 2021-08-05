package io.confluent.demo.datamesh;

import io.confluent.demo.datamesh.model.DataProduct;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collections;

@RestController
@RequestMapping("/data-products")
public class DataProductsController {

    @GetMapping
    public DataProduct[] getDataProducts() {
        // TODO: Load proper data product list from CC API
        return new DataProduct[] {
            new DataProduct("pageviews", "lsrc-78xpp:.:pageviews-value:1", Collections.emptyList()),
            new DataProduct("users", "lsrc-78xpp:.:users-value:1", Collections.emptyList())
        };
    }

    @RequestMapping("/{qualifiedName}")
    public DataProduct getDataProduct(@PathVariable("qualifiedName") String qualifiedName) {
        // TODO: Load proper data product from parameter
        return new DataProduct("users", "lsrc-78xpp:.:users-value:1", Collections.emptyList());
    }
}
