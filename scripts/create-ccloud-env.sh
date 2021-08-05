#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Source library
curl -sS -o ccloud_library.sh https://raw.githubusercontent.com/confluentinc/examples/latest/utils/ccloud_library.sh
curl -sS -o helper.sh https://raw.githubusercontent.com/confluentinc/examples/latest/utils/helper.sh
source ./helper.sh
source ./ccloud_library.sh

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

printf "\n";print_process_start "====== Pre-creating topics"
CMD="ccloud kafka topic create pageviews"
$CMD &>"$REDIRECT_TO" \
  && print_code_pass -c "$CMD" \
  || exit_with_error -c $? -n "$NAME" -m "$CMD" -l $(($LINENO -3))
CMD="ccloud kafka topic create users"
$CMD &>"$REDIRECT_TO" \
  && print_code_pass -c "$CMD" \
  || exit_with_error -c $? -n "$NAME" -m "$CMD" -l $(($LINENO -3))
print_pass "Topics created"

printf "\n";print_process_start "====== Create fully-managed Datagen Source Connectors to produce sample data."
ccloud::create_connector connectors/ccloud-datagen-pageviews.json || exit 1
ccloud::create_connector connectors/ccloud-datagen-users.json || exit 1
ccloud::wait_for_connector_up connectors/ccloud-datagen-pageviews.json 300 || exit 1
ccloud::wait_for_connector_up connectors/ccloud-datagen-users.json 300 || exit 1
printf "\nSleeping 30 seconds to give the Datagen Source Connectors a chance to start producing messages\n"
sleep 30

printf "\n";print_process_start "====== Create ksqlDB STREAMs for the Kafka topics."
MAX_WAIT=720
echo "Waiting up to $MAX_WAIT seconds for Confluent Cloud ksqlDB cluster to be UP"
retry $MAX_WAIT ccloud::validate_ccloud_ksqldb_endpoint_ready $KSQLDB_ENDPOINT
printf "Obtaining the ksqlDB App Id\n"
CMD="ccloud ksql app list -o json | jq -r '.[].id'"
ksqlDBAppId=$(eval $CMD) \
  && print_code_pass -c "$CMD" -m "$ksqlDBAppId" \
  || exit_with_error -c $? -n "$NAME" -m "$CMD" -l $(($LINENO -3))
printf "\nConfiguring ksqlDB ACLs\n"
CMD="ccloud ksql app configure-acls $ksqlDBAppId pageviews users"
$CMD \
  && print_code_pass -c "$CMD" \
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
        echo "$response" | {
          read body
          read code
          if [[ "$code" -gt 299 ]];
            then print_code_error -c "$ksqlCmd" -m "$(echo "$body" | jq .message)"
            else print_code_pass  -c "$ksqlCmd" -m "$(echo "$body" | jq -r .[].commandStatus.message)"
          fi
        }
sleep 3;
done < statements-cloud.sql

printf "\n";print_process_start "====== Add tags to the Data Catalog."

echo
echo
echo "Confluent Cloud Environment:"
echo
echo "  export CONFIG_FILE=$CONFIG_FILE"
echo "  export SERVICE_ACCOUNT_ID=$SERVICE_ACCOUNT_ID"
echo "  export CCLOUD_CLUSTER_ID=$CCLOUD_CLUSTER_ID"
echo
