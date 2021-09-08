package io.confluent.demo.datamesh;

import io.confluent.demo.datamesh.cc.schemaregistry.api.SchemaRegistryService;
import io.confluent.demo.datamesh.cc.schemaregistry.model.Schema;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class DataMeshDemo {
	//@Autowired
	//SubjectVersionService svc;
	//@Autowired
	//TagService tsvc;
	//@Autowired
	//DataProductService testDpService;
	@Autowired
	SchemaRegistryService testSchemaService;

	public static void main(String[] args) {
		SpringApplication.run(DataMeshDemo.class, args);
	}

	@GetMapping("/testme")
	public Schema testMe() throws Exception {
		return testSchemaService.getLatest("pageviews-value");
		//return testDpService.createDataProduct(request);

		//return tsvc.getDataProductTagForSubjectVersion("lsrc-w8v85:.:users-value:1").toString();
		//return "no test function setup";
		//return tsvc.tagSubjectVersionWithDataProduct(
		//		"lsrc-r3ww0:.:pksqlc-w5q3gPAGEVIEWS_USER3-value:1",
		//		new DataProductTag("bbecker", "she is user 3"));
	}

	@GetMapping("/ruok")
	public String ruok() {
		return "imok";
	}
}