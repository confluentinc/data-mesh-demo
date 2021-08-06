#!/bin/bash

echo -e "\nLet's go build a Data Mesh!\n"

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

printf "\n";print_process_start "====== Preflight Checks."
preflight_checks || exit 1

printf "\n";print_process_start "====== Create a new ccloud-stack to bootstrap the Data Mesh."
ccloud::prompt_continue_ccloud_demo || exit 1
export EXAMPLE="data-mesh-demo"
ccloud::create_ccloud_stack true || exit 1
export SERVICE_ACCOUNT_ID=$(ccloud kafka cluster list -o json | jq -r '.[0].name' | awk -F'-' '{print $4;}')
CONFIG_FILE=stack-configs/java-service-account-$SERVICE_ACCOUNT_ID.config
CCLOUD_CLUSTER_ID=$(ccloud kafka cluster list -o json | jq -c -r '.[] | select (.name == "'"demo-kafka-cluster-$SERVICE_ACCOUNT_ID"'")' | jq -r .id)
# Create parameters customized for Confluent Cloud instance created above
ccloud::generate_configs $CONFIG_FILE
source "delta_configs/env.delta"

echo
echo "Sleep an additional 90s to wait for all Confluent Cloud metadata to propagate"
sleep 90

printf "\n";print_process_start "====== Add new tag definition to the Data Catalog."
echo -e "\nDefine a new tag called DataProduct:"
curl -X POST -u ${SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO} ${SCHEMA_REGISTRY_URL}/catalog/v1/types/tagdefs \
  --header 'Content-Type: application/json' \
  --data '[{ "entityTypes" : [ "sr_subject_version" ], "name" : "DataProduct", "description" : "Data Product Attributes" , "attributeDefs" : [ { "name" : "owner", "cardinality" : "SINGLE", "typeName" : "string" }, { "name" : "description", "isOptional" : "true", "cardinality" : "SINGLE", "typeName" : "string" } ] }]'
echo -e "\nView the new tag definition:"
curl -s -u ${SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO} ${SCHEMA_REGISTRY_URL}/catalog/v1/types/tagdefs/DataProduct | jq .

# Create Data Products
create_data_product pageviews adam || exit 1
create_data_product users yeva || exit 1

printf "\n";print_process_start "====== Prepare ksqlDB entities for new Data Products."
create_ksqldb_app || exit 1

###########################################################################

echo
echo "Confluent Cloud Environment:"
echo
echo "  export SERVICE_ACCOUNT_ID=$SERVICE_ACCOUNT_ID"
echo "  export CCLOUD_CLUSTER_ID=$CCLOUD_CLUSTER_ID"
echo

echo
echo "To destroy the Data Mesh environment in Confluent Cloud run ->"
echo "    ./destroy-data-mesh.sh $CONFIG_FILE"
echo
