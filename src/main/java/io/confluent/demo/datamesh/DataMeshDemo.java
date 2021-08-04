package io.confluent.demo.datamesh;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class DataMeshDemo {

	public static void main(String[] args) {
		SpringApplication.run(DataMeshDemo.class, args);
	}

	@GetMapping("/ruok")
	public String hello() {
		return String.format("imok");
	}
}