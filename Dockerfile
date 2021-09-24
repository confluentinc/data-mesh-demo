FROM cnfldemos/data-mesh-demo:0.0.2-SNAPSHOT

ARG config

COPY $config /config.config

ENTRYPOINT ["java", "-cp", "@/app/jib-classpath-file", "io.confluent.demo.datamesh.DataMeshDemo", "--spring.config.additional-location=file:/config.config"]
