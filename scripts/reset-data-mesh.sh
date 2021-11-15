#!/bin/bash

function drop_ksql_component() {
  curl -s --http1.1 -XPOST "$KSQLDB_ENDPOINT/ksql" -H "Accept: application/json" -H "Content-Type: application/json" -d '{"ksql":"DROP '"$TYPE"' IF EXISTS '"$NAME"';","streamsProperties": {}}' -u "$KSQLDB_BASIC_AUTH_USER_INFO"
}
function drop_topic() {
  ccloud kafka topic delete $NAME --environment $ENVIRONMENT_ID --cluster $CLUSTER_ID
}
function drop_schema() {
  ccloud schema-registry schema delete --subject $NAME --version all
  ccloud schema-registry schema delete --subject $NAME --version all -P
}
function drop_data_product() {
  NAME=$NAME TYPE=$TYPE drop_ksql_component
  NAME=$NAME drop_topic
  NAME="${NAME}-value" drop_schema
}

CONFIG_FILE=$1

KSQLDB_ENDPOINT=$( grep "^ksql.endpoint" $CONFIG_FILE | awk -F'=' '{print $2;}' )
KSQLDB_BASIC_AUTH_USER_INFO=$( grep "^ksql.basic.auth.user.info" $CONFIG_FILE | awk -F'=' '{print $2;}' )
ENVIRONMENT_ID=$( grep "^confluent.cloud.environment.id" $CONFIG_FILE | awk -F'=' '{print $2;}' )
CLUSTER_ID=$( grep "^confluent.cloud.kafka.cluster.id" $CONFIG_FILE | awk -F'=' '{print $2;}' )

# Delete any data products that might have been created by users
NAME="us_enriched_stock_trades" TYPE="STREAM" drop_data_product
NAME="trending_stocks" TYPE="TABLE" drop_data_product
NAME="high_value_stock_trades" TYPE="STREAM" drop_data_product
