# Data Mesh Demo

An example implementation of Data Mesh on top of Confluent Cloud.

### Prerequisties
* Java 11
* Gradle

### Instructions (WIP during development)

* Clone the repository locally and change directories
  ```
  git clone https://github.com/confluentinc/data-mesh-demo
  cd data-mesh-demo
  ```

* Create the Data Mesh in Confluent Cloud. This script will take 10-15 minutes to complete.
  ```
  ./scripts/create-data-mesh.sh
  ```

* Build the web service with
   ```
   ./gradlew bootJar
   ```

* Run the web service passing in your ccloud configuration file (your file will have a different name):
  ```
  java -jar build/libs/datamesh-0.0.1-SNAPSHOT.jar --spring.config.location=file:$(pwd)/scripts/stack-configs/java-service-account-291352.config
  ```

  It is successful and will wait for requests when you see a log message similar to this:
  ```
	2021-08-06 14:31:22.531  INFO 42900 --- [           main] io.confluent.demo.datamesh.DataMeshDemo  : Started DataMeshDemo in 1.901 seconds (JVM running for 2.331)
  ```

* Use endpoint `localhost:8080` to interact with the REST API, for example with `curl` and `jq`
  ```
  curl -s localhost:8080/data-products | jq
  [
    {
      "qualifiedName": "lsrc-w8v85:.:users-value:1",
      "name": "users",
      "description": "website users",
      "owner": "yeva"
    },
    {
      "qualifiedName": "lsrc-w8v85:.:pageviews-value:1",
      "name": "pageviews",
      "description": "website pageviews",
      "owner": "adam"
    }
  ]
  ```

* Destroy the Data Mesh in Confluent Cloud.  Pass in as an argument the configuration file that was auto generated from `./scripts/create-data-mesh.sh`
  ```
  ./scripts/destroy-data-mesh.sh stack-configs/java-service-account-<SERVICE_ACCOUNT_ID>.config
  ```
