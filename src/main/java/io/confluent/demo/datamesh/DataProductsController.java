package io.confluent.demo.datamesh;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collections;

@RestController
public class DataProductsController {

    @GetMapping("/data-products")
    public DataProduct[] getDataProducts() {
        return new DataProduct[] {
            new DataProduct("pageviews", "lsrc-78xpp:.:pageviews-value:1", Collections.emptyList()),
            new DataProduct("users", "lsrc-78xpp:.:users-value:1", Collections.emptyList())
        };
    }
}
