package io.confluent.demo.datamesh;

import io.confluent.demo.datamesh.cc.datacatalog.api.SubjectVersionService;
import io.confluent.demo.datamesh.cc.datacatalog.model.AtlasEntity;
import io.confluent.demo.datamesh.cc.datacatalog.model.AtlasEntityHeader;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@SpringBootApplication
@RestController
public class DataMeshDemo {
	@Autowired
	SubjectVersionService svc;

	public static void main(String[] args) {
		SpringApplication.run(DataMeshDemo.class, args);
	}

	private static void test(String[] args) {
	}

	@GetMapping("/testme")
	public List<AtlasEntityHeader> testMe() {
		return svc.getAll();
	}
	@GetMapping("/ruok")
	public String hello() {
		return String.format("imok");
	}
}