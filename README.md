# Confluent Data Mesh Demo

A Data Mesh prototype built on [Confluent Cloud](https://www.confluent.io/confluent-cloud/tryfree/).

![Preview](preview.png)

## Hosted Version

The Data Mesh demo is available in a hosted environment by visiting:

https://www.confluent-data-mesh-prototype.com

A companion blog post can be found here:

*TODO Blog Link*

## Running Locally 

###  Prerequisties
* [Confluent Cloud](https://www.confluent.io/confluent-cloud/tryfree/) account
* [Confluent Cloud CLI](https://docs.confluent.io/ccloud-cli/current/install.html) `v1.36.0` or later
* Java 11
* Gradle
* Node
* Yarn
* [jq](https://stedolan.github.io/jq/download/)

### Instructions

* Clone the repository and change into the project directory:
  ```
  git clone https://github.com/confluentinc/data-mesh-demo
  cd data-mesh-demo
  ```

* Ensure your `ccloud` CLI is logged into Confluent Cloud (`--save` prevents timeouts):
  ```
  ccloud login --save
  ```
  
* If you want to create a new Data Mesh on Confluent Cloud as well as build and run the demo run the following.
  This process creates Confluent Cloud resources, including an environment, Apache Kafka cluster, [ksqlDB](https://ksqldb.io/) Application, and sample Data Products.
  The script waits for all cloud resources to be fully provisioned and *can take 10-15 minutes to complete*.
 
  ```
  make data-mesh
  ```
  
  The script creates a configuration file for your new data mesh environment in the `stack-configs` folder 
  local to this project. The file path will resemble `stack-configs/java-service-account-1234567.config`. This file contains
  important security and configuration data for your new data mesh environment. You should protect this file and  
  retain it as you'll need it later to destroy the new data mehs environment.

 
* If you previously ran the `make data-mesh` command and still have the Confluent Cloud environemnt and 
configuration file, you can skip the previous data mesh creation step and just run the demo with:
  ```
  CONFIG_FILE=<path-to-config-file> make run
  ```
 
* Once the data mesh creation and demo run process is complete, you will see the Spring Boot banner 
  and a log entries that looks like:
  ```
  Log ....
  ```
 
* To view the data mesh demo, open a web browser to: http://localhost:8080

### Teardown

Once you are done with the Data Mesh demo you'll want to stop the server and destroy the cloud resources.

* Stop the demo web service by issuing `<ctrl-c>` in the terminal where you started it.

* Destroy the Data Mesh resources in Confluent Cloud (including the environment, cluster, and ksqlDB app).
 
  (_Note_: This command expects the path to the configuration file created during the `make data-mesh` 
  command to be present in the `CONFIG_FILE` environment variable. If you started a new terminal you may need to 
  set the value to the appropriate file):
  ```
  make destroy
  ```
  
### Data Mesh Demo API Usage

The Data Mesh Demo models a data mesh via a REST API. The following are examples of some functions you can perform
with the REST API directly. By default, the REST API listens on `localhost:8080`.

* Discover the existing data products:
  ```
  curl -s localhost:8080/priv/data-products | jq
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

* Get information on one data product. This requires the qualified name of the data product, 
which is the Schema Registry subject:

  ```
  curl -s localhost:8080/priv/data-products/lsrc-w8v85:.:users-value:1 | jq
  {
    "qualifiedName": "lsrc-w8v85:.:users-value:1",
    "name": "users",
    "description": "website users",
    "owner": "rick"
  }
  ```

* Get all the data products and topics in one list:
  ```
  curl -s localhost:8080/priv/data-products/manage | jq
  [
    {
      "@type": "DataProduct",
      "name": "users",
      "qualifiedName": "lsrc-7xxv2:.:users-value:1",
      "description": "website users",
      "owner": "rick",
      "urls": {
        "schemaUrl": "https://confluent.cloud/environments/env-6qx3j/schema-registry/schemas/users-value",
        "portUrl": "https://confluent.cloud/environments/env-6qx3j/clusters/lkc-1771v/topics/users",
        "lineageUrl": "https://confluent.cloud/environments/env-6qx3j/clusters/lkc-1771v/stream-lineage/view/users-value"
      }
    },
    ...
    {
      "@type": "Topic",
      "name": "pksqlc-09g26PAGEVIEWS_USER3",
      "qualifiedName": "lsrc-7xxv2:.:pksqlc-09g26PAGEVIEWS_USER3-value:2"
    }
  ]
  ```

* Create a new data product for an existing topic:
  ```
  curl -XPOST -H 'Content-Type: application/json' --data "@topicrequest.json" http://localhost:8080/priv/data-products
  ```
  Where the contents of `topicrequest.json` file are as below. The `qualifiedName` field must be a valid 
  `sr_subject_version` in the cc data catalog.
  ```
  {
    "@type": "TOPIC",
    "qualifiedName": "lsrc-7xxv2:.:pksqlc-09g26PAGEVIEWS_USER2-value:2",
    "dataProductTag": {
        "owner": "ybyzek",
        "description": "pageviews users 2"
    }
  }
  ```

* Delete a data product:
  ```
  curl -X DELETE http://localhost:8080/data-products/lsrc-7xxv2:.:pksqlc-09g26PAGEVIEWS_USER2-value:2
  ```


## Client Development Instructions

The client is built with [Elm](https://elm-lang.org/) and the source is build as part of the Java server build step. 
If you like to develop the client code independent, you can use the following.

To run a webserver hosting the client code that will watch for changes and load
connected browswers:
```sh
cd client
yarn
yarn dev
```

The website is now served at http://localhost:9000.