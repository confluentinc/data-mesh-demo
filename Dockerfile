FROM cnfldemos/data-mesh-demo:0.0.14

ARG config

COPY $config /config.config

ENV PORT=8080

ENTRYPOINT ["java", "-Dserver.port=${PORT}", "-cp", "@/app/jib-classpath-file", "io.confluent.demo.datamesh.DataMeshDemo", "--spring.config.additional-location=file:/config.config"]
