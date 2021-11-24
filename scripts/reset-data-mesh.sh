#!/bin/bash

function drop_ksql_component() {
  curl --http1.1 -XPOST "$KSQLDB_ENDPOINT/ksql" -H "Accept: application/json" -H "Content-Type: application/json" -d '{"ksql":"DROP '"$TYPE"' IF EXISTS '"$NAME"';","streamsProperties": {}}' -u "$KSQLDB_BASIC_AUTH_USER_INFO"
	echo ""
}
function drop_topic() {
	curl --request DELETE -u "${KAFKA_AUTH_KEY}:${KAFKA_AUTH_SECRET}" \
		"https://${KAFKA_REST_HOSTNAME}/kafka/v3/clusters/${CLUSTER_ID}/topics/$NAME"
	echo ""
}
function drop_schema() {
  curl --request DELETE -u "${SCHEMA_REGISTRY_AUTH}" "${SCHEMA_REGISTRY_URL}/subjects/${NAME}"
  curl --request DELETE -u "${SCHEMA_REGISTRY_AUTH}" "${SCHEMA_REGISTRY_URL}/subjects/${NAME}?permanent=true"
	echo ""
}
function drop_data_product() {
	echo "drop_ksql_component $NAME"
  NAME=$NAME TYPE=$TYPE drop_ksql_component
	echo "drop_topic $NAME"
  NAME=$NAME drop_topic
	echo "drop_schema $NAME"
  NAME="${NAME}-value" drop_schema
	echo "*************************************"
}

CONFIG_FILE=$1

KSQLDB_ENDPOINT=$( grep "^ksql.endpoint" $CONFIG_FILE | awk -F'=' '{print $2;}' )
KSQLDB_BASIC_AUTH_USER_INFO=$( grep "^ksql.basic.auth.user.info" $CONFIG_FILE | awk -F'=' '{print $2;}' )
ENVIRONMENT_ID=$( grep "^confluent.cloud.environment.id" $CONFIG_FILE | awk -F'=' '{print $2;}' )
CLUSTER_ID=$( grep "^confluent.cloud.kafka.cluster.id" $CONFIG_FILE | awk -F'=' '{print $2;}' )
CLOUD_AUTH_KEY=$( grep "^confluent.cloud.auth.key" $CONFIG_FILE | awk -F'=' '{print $2;}' ) 
CLOUD_AUTH_SECRET=$( grep "^confluent.cloud.auth.secret" $CONFIG_FILE | awk -F'=' '{print $2;}' ) 
SCHEMA_REGISTRY_URL=$( grep "^confluent.cloud.schemaregistry.url" $CONFIG_FILE | awk -F'=' '{print $2;}' )
SCHEMA_REGISTRY_AUTH=$( grep "^basic.auth.user.info" $CONFIG_FILE | awk -F'=' '{print $2;}' )
KAFKA_REST_HOSTNAME=$( grep "^bootstrap.servers" $CONFIG_FILE | awk -F'=' '{print $2;}' | awk -F':' '{print $1;}' )
KAFKA_AUTH_KEY=$( grep "^confluent.cloud.kafka.auth.key" $CONFIG_FILE | awk -F'=' '{print $2;}' )
KAFKA_AUTH_SECRET=$( grep "^confluent.cloud.kafka.auth.secret" $CONFIG_FILE | awk -F'=' '{print $2;}' )

# Delete any data products that might have been created by users
NAME="us_enriched_stock_trades" TYPE="STREAM" drop_data_product
NAME="trending_stocks" TYPE="TABLE" drop_data_product
NAME="high_value_stock_trades" TYPE="STREAM" drop_data_product

