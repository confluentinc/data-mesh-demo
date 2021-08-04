# Data Mesh Demo

An example implementation of Data Mesh on top of Confluent Cloud.

### Prerequisties
* Java 11

### Instructions (WIP during development)

* Clone the repository locally
* Run the web service with
   ```
   ./gradlew bootRun
   ```
 * Point http client to `localhost:8080`, for example with `curl` and `jq`
   ```
   curl -s localhost:8080/data-products | jq
   [
     {
       "qualifiedName": "lsrc-78xpp:.:pageviews-value:1",
       "name": "pageviews",
       "owner": "@web",
       "version": 1
     },
     {
       "qualifiedName": "lsrc-78xpp:.:users-value:1",
       "name": "users",
       "owner": "@web",
       "version": 1
     }
   ]
   ```