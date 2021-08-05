#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Source library
curl -sS -o ccloud_library.sh https://raw.githubusercontent.com/confluentinc/examples/latest/utils/ccloud_library.sh
source ./ccloud_library.sh
source ./helper.sh

# Setting default QUIET=false to surface potential errors
QUIET="${QUIET:-false}"
[[ $QUIET == "true" ]] &&
  REDIRECT_TO="/dev/null" ||
  REDIRECT_TO="/dev/stdout"

# Verifications
ccloud::validate_version_ccloud_cli $CCLOUD_MIN_VERSION \
  && print_pass "ccloud version ok" \
  || exit 1
ccloud::validate_logged_in_ccloud_cli \
  && print_pass "logged into ccloud CLI" \
  || exit 1
check_jq \
  && print_pass "jq installed" \
  || exit 1

# Confirmation
ccloud::prompt_continue_ccloud_demo || exit 1

# Create a new ccloud-stack
echo
echo "Configuring a new Confluent Cloud ccloud-stack (including a new Confluent Cloud ksqlDB application)"
echo "Note: real Confluent Cloud resources will be created and you are responsible for destroying them."
echo

printf "\n";print_process_start "====== Creating new ccloud-stack."
export EXAMPLE="data-mesh-demo"
ccloud::create_ccloud_stack true || exit 1
export SERVICE_ACCOUNT_ID=$(ccloud kafka cluster list -o json | jq -r '.[0].name' | awk -F'-' '{print $4;}')
CONFIG_FILE=stack-configs/java-service-account-$SERVICE_ACCOUNT_ID.config
CCLOUD_CLUSTER_ID=$(ccloud kafka cluster list -o json | jq -c -r '.[] | select (.name == "'"demo-kafka-cluster-$SERVICE_ACCOUNT_ID"'")' | jq -r .id)

# Create parameters customized for Confluent Cloud instance created above
ccloud::generate_configs $CONFIG_FILE
source "delta_configs/env.delta"

echo
echo "Sleep an additional 60s to wait for all Confluent Cloud metadata to propagate"
sleep 60

printf "\n";print_process_start "====== Pre-creating Kafka topics in Confluent Cloud."
CMD="ccloud kafka topic create pageviews"
$CMD &>"$REDIRECT_TO" \
  && print_pass -c "$CMD" \
  || exit_with_error -c $? -n "$NAME" -m "$CMD" -l $(($LINENO -3))
CMD="ccloud kafka topic create users"
$CMD &>"$REDIRECT_TO" \
  && print_pass -c "$CMD" \
  || exit_with_error -c $? -n "$NAME" -m "$CMD" -l $(($LINENO -3))
print_pass "Topics created"

printf "\n";print_process_start "====== Create Datagen Source Connectors to produce sample data into Kafka topics."
ccloud::create_connector connectors/ccloud-datagen-pageviews.json || exit 1
ccloud::create_connector connectors/ccloud-datagen-users.json || exit 1
ccloud::wait_for_connector_up connectors/ccloud-datagen-pageviews.json 600 || exit 1
ccloud::wait_for_connector_up connectors/ccloud-datagen-users.json 600 || exit 1
printf "\nSleeping 30 seconds to give the Datagen Source Connectors a chance to start producing messages\n"
sleep 30

printf "\n";print_process_start "====== Add tags to the Data Catalog for the subject that represents the Kafka topic called users."
echo "Subjects:"
curl -u ${SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO} "${SCHEMA_REGISTRY_URL}/catalog/v1/search/basic?types=sr_subject_version" | jq .
echo "Define Governance tag:"
curl -X PUT -u ${SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO} ${SCHEMA_REGISTRY_URL}/catalog/v1/types/tagdefs \
  --header 'Content-Type: application/json' \
  --data '[{ "entityTypes" : [ "sr_subject_version" ], "name" : "Governance", "description" : "Data Mesh Governance Attributes" , "attributeDefs" : [ { "name" : "owner", "cardinality" : "SINGLE", "typeName" : "string" }, { "name" : "description", "isOptional" : "true", "cardinality" : "SINGLE", "typeName" : "string" } ] }]'
echo "Tags:"
curl -u ${SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO} ${SCHEMA_REGISTRY_URL}/catalog/v1/types/tagdefs/Governance | jq .
echo "Get Qualified name for users (not working yet):"
QN=$(curl -u ${SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO} "${SCHEMA_REGISTRY_URL}/catalog/v1/search/basic?types=sr_subject_version" | jq -r 'map(select(.entities[].attributes.name == "users-value")) | .entities[].attributes.qualifiedName')
echo "Qualified Name: .$QN."
echo "Attach tag to subject for users"
curl -X PUT -u ${SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO} "${SCHEMA_REGISTRY_URL}/catalog/v1/entity/tags" \
  --header 'Content-Type: application/json' \
  --data '[ { "entityType" : "sr_subject_version", "entityName" : "${QN}", "typeName" : "Governance", "attributes" : { "owner":"yeva", "description":"foobar"} }]'
echo "Verify tag attached to subject"
curl -u ${SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO} "${SCHEMA_REGISTRY_URL}/catalog/v1/search/basic?types=sr_subject_version" | jq -r 'map(select(.entities[].attributes.name == "users-value"))'
sleep 5

printf "\n";print_process_start "====== Create ksqlDB entities for the Kafka topics."
MAX_WAIT=720
echo "Waiting up to $MAX_WAIT seconds for Confluent Cloud ksqlDB cluster to be UP"
ccloud::retry $MAX_WAIT ccloud::validate_ccloud_ksqldb_endpoint_ready $KSQLDB_ENDPOINT
CMD="ccloud ksql app list -o json | jq -r '.[].id'"
ksqlDBAppId=$(eval $CMD) \
  && print_pass "Retrieved ksqlDB application ID: $ksqlDBAppId" \
  || exit_with_error -c $? -n "$NAME" -m "$CMD" -l $(($LINENO -3))
CMD="ccloud ksql app configure-acls $ksqlDBAppId pageviews users"
$CMD \
  && print_pass "$CMD" \
  || exit_with_error -c $? -n "$NAME" -m "$CMD" -l $(($LINENO -3))
while read ksqlCmd; do # from statements-cloud.sql
        response=$(curl -w "\n%{http_code}" -X POST $KSQLDB_ENDPOINT/ksql \
               -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
               -u $KSQLDB_BASIC_AUTH_USER_INFO \
               --silent \
               -d @<(cat <<EOF
        {
          "ksql": "$ksqlCmd",
          "streamsProperties": {
                        "ksql.streams.auto.offset.reset":"earliest",
                        "ksql.streams.cache.max.bytes.buffering":"0"
                }
        }
EOF
        ))
        echo "$response"
        echo "$response" | {
          read body
          read code
          if [[ "$code" -gt 299 ]];
            then print_code_error -c "$ksqlCmd" -m "$(echo "$body" | jq .message)"
            else print_pass  -c "$ksqlCmd" -m "$(echo "$body" | jq -r .[].commandStatus.message)"
          fi
        }
sleep 3;
done < statements-cloud.sql

echo
echo
echo "Confluent Cloud Environment:"
echo
echo "  export CONFIG_FILE=$CONFIG_FILE"
echo "  export SERVICE_ACCOUNT_ID=$SERVICE_ACCOUNT_ID"
echo "  export CCLOUD_CLUSTER_ID=$CCLOUD_CLUSTER_ID"
echo
