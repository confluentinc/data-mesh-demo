#!/bin/bash

################################################################
# Source Confluent Platform versions
################################################################
DIR_HELPER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

function check_jq() {
  if [[ $(type jq 2>&1) =~ "not found" ]]; then
    echo "'jq' is not found. Install 'jq' and try again"
    exit 1
  fi

  return 0
}

function preflight_checks() {
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
}

function create_data_product () {
  dp=$1
  owner=$2
  sla=$3
  quality=$4
  domain=$5
  description=$6

  printf "\n";print_process_start "====== Create a new Data Product called $dp."

  CMD="ccloud kafka topic create $dp"
  $CMD &>"$REDIRECT_TO" \
    && print_pass "$CMD" \
    || exit_with_error -c $? -n "$NAME" -m "$CMD" -l $(($LINENO -3))

  CONNECTOR_CONFIG="${DIR_HELPER}/connectors/ccloud-datagen-${dp}.json"
  ccloud::create_connector $CONNECTOR_CONFIG || exit 1
  ccloud::wait_for_connector_up $CONNECTOR_CONFIG 600 || exit 1
  printf "\nSleeping 60 seconds until the datagen source connector starts producing records for ${dp}\n"
  sleep 60

  # Get the qualified name
  QN=$(curl -s -u ${SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO} "${SCHEMA_REGISTRY_URL}/catalog/v1/search/basic?types=sr_subject_version" | jq -r --arg dp "${dp}-value" '.entities[].attributes | select(.name==$dp) | .qualifiedName ')
  echo "Qualified name for Kafka subject $dp: $QN"

  echo -e "\nAdd tag to ${dp}"
  curl -X POST -u ${SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO} "${SCHEMA_REGISTRY_URL}/catalog/v1/entity/tags" \
    --header 'Content-Type: application/json' \
    --data '[ { "entityType" : "sr_subject_version", "entityName" : "'"${QN}"'", "typeName" : "DataProduct", "attributes" : { "owner":"'"${owner}"'", "description":"'"${description}"'", "domain": "'"${domain}"'", "quality": "'"${quality}"'", "sla" : "'"${sla}"'" } }]'
  echo -e "\nVerify tag is attached to ${dp}"
  curl -s -u ${SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO} "${SCHEMA_REGISTRY_URL}/catalog/v1/search/basic?types=sr_subject_version" | jq -r --arg dp "${dp}-value" '.entities[] | select(.attributes.name==$dp) | .classificationNames[] '
  echo -e "\nView tag details"
  curl -s -u ${SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO} "${SCHEMA_REGISTRY_URL}/catalog/v1/entity/type/sr_subject_version/name/${QN}/tags" | jq .

  return 0
}

function create_ksqldb_app() {
  MAX_WAIT=720
  echo "Waiting up to $MAX_WAIT seconds for Confluent Cloud ksqlDB cluster to be UP"
  ccloud::retry $MAX_WAIT ccloud::validate_ccloud_ksqldb_endpoint_ready $KSQLDB_ENDPOINT || exit 1
  CMD="ccloud ksql app list -o json | jq -r '.[].id'"
  ksqlDBAppId=$(eval $CMD) \
    && print_pass "Retrieved ksqlDB application ID: $ksqlDBAppId" \
    || exit_with_error -c $? -n "$NAME" -m "$CMD" -l $(($LINENO -3))
  CMD="ccloud ksql app configure-acls $ksqlDBAppId pageviews users"
  $CMD \
    && print_pass "$CMD" \
    || exit_with_error -c $? -n "$NAME" -m "$CMD" -l $(($LINENO -3))
  while read ksqlCmd; do
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
  done < ${DIR_HELPER}/statements-cloud.sql
}

function augment_config_file() {
  file=$1

  # Determine IDs for environment and Kafka cluster
  ENVIRONMENT_NAME_PREFIX=${ENVIRONMENT_NAME_PREFIX:-"ccloud-stack-$SERVICE_ACCOUNT_ID"}
  ENVIRONMENT_ID=$(ccloud environment list -o json | jq -r 'map(select(.name | startswith("'"$ENVIRONMENT_NAME_PREFIX"'"))) | .[].id')
  KAFKA_CLUSTER_NAME=${KAFKA_CLUSTER_NAME:-"demo-kafka-cluster-$SERVICE_ACCOUNT_ID"}
  KAFKA_CLUSTER_ID=$(ccloud kafka cluster list -o json | jq -r 'map(select(.name | startswith("'"$KAFKA_CLUSTER_NAME"'"))) | .[].id')
  SCHEMA_REGISTRY_ID=$(ccloud schema-registry cluster describe -o json | jq -r ".cluster_id")
  KSQLDB_ID=$(ccloud ksql app list -o json | jq -r 'map(select(.name == "demo-ksqldb-'"$SERVICE_ACCOUNT_ID"'")) | .[].id')

  # Create credentials for the cloud resource for the Connector REST API
  REST_API_AUTH_USER_INFO=$(ccloud api-key create --resource cloud -o json) || exit 1
  REST_API_KEY=$(echo "$REST_API_AUTH_USER_INFO" | jq -r .key)
  REST_API_SECRET=$(echo "$REST_API_AUTH_USER_INFO" | jq -r .secret)

  # Split other credentials into key and secret
  IFS=":" read -r SCHEMA_REGISTRY_KEY SCHEMA_REGISTRY_SECRET <<< "$SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO"
  IFS=":" read -r KSQLDB_KEY KSQLDB_SECRET <<< "$KSQLDB_BASIC_AUTH_USER_INFO"

  cat <<EOF >> $file

# Data Mesh demo specifics
confluent.cloud.environment.id=${ENVIRONMENT_ID}
confluent.cloud.kafka.cluster.id=${KAFKA_CLUSTER_ID}
confluent.cloud.kafka.auth.key=${CLOUD_KEY}
confluent.cloud.kafka.auth.secret=${CLOUD_SECRET}
confluent.cloud.schemaregistry.id=${SCHEMA_REGISTRY_ID}
confluent.cloud.schemaregistry.url=${SCHEMA_REGISTRY_URL}
confluent.cloud.schemaregistry.auth.key=${SCHEMA_REGISTRY_KEY}
confluent.cloud.schemaregistry.auth.secret=${SCHEMA_REGISTRY_SECRET}
confluent.cloud.ksqldb.id=${KSQLDB_ID}
confluent.cloud.ksqldb.url=${KSQLDB_ENDPOINT}
confluent.cloud.ksqldb.auth.key=${KSQLDB_KEY}
confluent.cloud.ksqldb.auth.secret=${KSQLDB_SECRET}
confluent.cloud.auth.key=${REST_API_KEY}
confluent.cloud.auth.secret=${REST_API_SECRET}
EOF

  return 0
}

PRETTY_PASS="\e[32m✔ \e[0m"
function print_pass() {
  printf "${PRETTY_PASS}%s\n" "${1}"
}
PRETTY_ERROR="\e[31m✘ \e[0m"
function print_error() {
  printf "${PRETTY_ERROR}%s\n" "${1}"
}
PRETTY_CODE="\e[1;100;37m"
function print_code() {
  printf "${PRETTY_CODE}%s\e[0m\n" "${1}"
}
function print_process_start() {
  printf "⌛ %s\n" "${1}"
}
function print_code_pass() {
  local MESSAGE=""
  local CODE=""
  OPTIND=1
  while getopts ":c:m:" opt; do
    case ${opt} in
      c ) CODE=${OPTARG};;
      m ) MESSAGE=${OPTARG};;
    esac
  done
  shift $((OPTIND-1))
  printf "${PRETTY_PASS}${PRETTY_CODE}%s\e[0m\n" "${CODE}"
  [[ -z "$MESSAGE" ]] || printf "\t$MESSAGE\n"      
}
function print_code_error() {
  local MESSAGE=""
  local CODE=""
  OPTIND=1
  while getopts ":c:m:" opt; do
    case ${opt} in
      c ) CODE=${OPTARG};;
      m ) MESSAGE=${OPTARG};;
    esac
  done
  shift $((OPTIND-1))
  printf "${PRETTY_ERROR}${PRETTY_CODE}%s\e[0m\n" "${CODE}"
  [[ -z "$MESSAGE" ]] || printf "\t$MESSAGE\n"      
}

