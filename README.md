# Data Mesh Demo

An example implementation of Data Mesh on top of [Confluent Cloud](https://www.confluent.io/confluent-cloud/tryfree/).

### Prerequisties
* Java 11
* Gradle
* jq
* A user account in [Confluent Cloud](https://www.confluent.io/confluent-cloud/tryfree/)
* Local install of [Confluent Cloud CLI](https://docs.confluent.io/ccloud-cli/current/install.html) v1.36.0 or later

### Instructions (WIP during development)

#### Bringup

* Clone the repository locally and change directories
  ```
  git clone https://github.com/confluentinc/data-mesh-demo
  cd data-mesh-demo
  ```

* Create the Data Mesh in Confluent Cloud, bootstrapped with two data products `users` and `pageviews`, by running the following command. This script will take 10-15 minutes to complete.
  ```
  ./scripts/create-data-mesh.sh
  ```

  It is successful when you see the following message:
  ```
  Congrats! You are ready to start using the data products in the Data Mesh.
  ```

* Build a local web service by running the following command:
   ```
   ./gradlew bootJar
   ```

  Ensure you see the message:
  ```
  BUILD SUCCESSFUL in 22s
  ```

* Start the web service, passing in as an argument the configuration file that was auto generated from `./scripts/create-data-mesh.sh`.
  ```
  java -jar build/libs/datamesh-0.0.1-SNAPSHOT.jar --spring.config.location=file:$(pwd)/stack-configs/java-service-account-<SERVICE_ACCOUNT_ID>.config
  ```

  It is successful and will wait for requests when you see a log message similar to this:
  ```
	2021-08-06 14:31:22.531  INFO 42900 --- [           main] io.confluent.demo.datamesh.DataMeshDemo  : Started DataMeshDemo in 1.901 seconds (JVM running for 2.331)
  ```

* Use endpoint `localhost:8080` to interact with the REST API.

  Example: discover the existing data products:
  ```
  curl -s localhost:8080/data-products | jq
  [
    {
      "qualifiedName": "lsrc-w8v85:.:users-value:1",
      "name": "users",
      "description": "website users",
      "owner": "rick"
    },
    {
      "qualifiedName": "lsrc-w8v85:.:pageviews-value:1",
      "name": "pageviews",
      "description": "website pageviews",
      "owner": "adam"
    }
  ]
  ```

  Example: get one information on one data product. This requires the qualified name of the data product, which is the Schema Registry subject:
  ```
  curl -s localhost:8080/data-products/lsrc-w8v85:.:users-value:1 | jq
  {
    "qualifiedName": "lsrc-w8v85:.:users-value:1",
    "name": "users",
    "description": "website users",
    "owner": "rick"
  }
  ```

  Example: Create a new data product using ksqlDB:
  ```
  curl -XPOST -H 'Content-Type: application/json' --data "@ksqldbrequest.json" http://localhost:8080/data-products
  ```
    where the contents of the `ksqldbrequest.json` file are:
    ```
    {
      "@type": "KSQLDB",
      "name": "pageviews_user3",
      "owner": "owner value here",
      "description": "description value here",
      "dataProductName": "lsrc-xgw2k:.:pageviews_user3-value:1",
      "command": "CREATE STREAM PAGEVIEWS_USER3 WITH (KAFKA_TOPIC='pageviews_user3', PARTITIONS=3, REPLICAS=3) AS SELECT * FROM PAGEVIEWS WHERE (PAGEVIEWS.USERID = 'User_3') EMIT CHANGES;"
    }
    ```
  For now, the user must provide the fully qualified name of the expected subject version that the SQL command will create, so that the data mesh server can tag the subject version appropriately.

#### Teardown

* Stop the web service by issuing `<ctrl-c>` in the window where you started it.

* Destroy the Data Mesh in Confluent Cloud.  Pass in as an argument the configuration file that was auto generated from `./scripts/create-data-mesh.sh`
  ```
  ./scripts/destroy-data-mesh.sh stack-configs/java-service-account-<SERVICE_ACCOUNT_ID>.config
  ```
