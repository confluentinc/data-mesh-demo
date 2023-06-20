#!/bin/bash

echo -e "\nLet's go build a Data Mesh!\n"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# ccloud_library contains function for creating
# Confluent Cloud resources
# For now a copy of ccloud_library is copied locally until examples
#		CLI-1399 is tested and merged
curl -sS -o ${DIR}/ccloud_library.sh https://raw.githubusercontent.com/confluentinc/examples/7.3.1-post/utils/ccloud_library.sh
source ${DIR}/ccloud_library.sh
source ${DIR}/helper.sh

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
export SERVICE_ACCOUNT_ID=$(confluent kafka cluster list -o json | jq -r '.[0].name | ltrimstr("demo-kafka-cluster-")')
export CONFIG_FILE=stack-configs/java-service-account-$SERVICE_ACCOUNT_ID.config
CCLOUD_CLUSTER_ID=$(confluent kafka cluster list -o json | jq -c -r '.[] | select (.name == "'"demo-kafka-cluster-$SERVICE_ACCOUNT_ID"'")' | jq -r .id)
# Create parameters customized for Confluent Cloud instance created above
ccloud::generate_configs $CONFIG_FILE
source "delta_configs/env.delta"
augment_config_file $CONFIG_FILE

#Update the governance package to ADVANCED using the CLI.
#Could also have created the cluster with package set to ADVANCED by default: https://docs.confluent.io/cloud/current/stream-governance/clusters-regions-api.html#create-a-cluster
echo "Upgrade the governance package to ADVANCED. This is necessary to use Business Metadata types."
CC_ENV=$(confluent environment list -o json | jq -c -r '.[] | select (.name == "'"ccloud-stack-$SERVICE_ACCOUNT_ID-data-mesh-demo"'")' | jq -r .id)
echo "cc_env = $CC_ENV"
UPDATED_GOV=$(confluent schema-registry cluster upgrade --package advanced --environment $CC_ENV)

echo
echo "Sleep an additional 30 seconds"
sleep 30
echo "Did updating the governance package work?: $UPDATED_GOV"

echo
echo "Sleep an additional 90 seconds to wait for all Confluent Cloud metadata to propagate"
sleep 90

printf "\n";print_process_start "====== Add new business metadata definition to the Data Catalog."
echo -e "\nDefine a new business metadata in the Data Catalog called DataProduct:"
curl -X POST -u ${SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO} ${SCHEMA_REGISTRY_URL}/catalog/v1/types/businessmetadatadefs \
  --header 'Content-Type: application/json' \
  --data '[{ "entityTypes" : [ "kafka_topic" ], "name" : "DataProduct", "description" : "Data Product Attributes" , "attributeDefs" : [ { "name" : "owner", "cardinality" : "SINGLE", "typeName" : "string" }, { "name" : "description", "isOptional" : "true", "cardinality" : "SINGLE", "typeName" : "string" }, { "name" : "domain", "isOptional" : "true", "cardinality" : "SINGLE", "typeName" : "string" }, { "name" : "sla", "isOptional" : "true", "cardinality" : "SINGLE", "typeName" : "string" }, { "name" : "quality", "isOptional" : "true", "cardinality" : "SINGLE", "typeName" : "string" } ] }]'
echo -e "\n\nView the new business metadata definition:"
curl -s -u ${SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO} ${SCHEMA_REGISTRY_URL}/catalog/v1/types/businessmetadatadefs/DataProduct | jq .

echo -e "\nDefine a new Tag in the Data Catalog called ProdDP:"
curl -X POST -u ${SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO} ${SCHEMA_REGISTRY_URL}/catalog/v1/types/tagdefs \
  --header 'Content-Type: application/json' \
  --data '[{ "entityTypes" : [ "kafka_topic" ], "name" : "ProdDP", "description" : "Production ready Data Product", "attributeDefs" : [ ] }]'
echo -e "\n\nView the new tag definition:"
curl -s -u ${SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO} ${SCHEMA_REGISTRY_URL}/catalog/v1/types/tagdefs/ProdDP | jq .

# Create Data Products
create_data_product stocktrades @execution-team tier-1 authoritative execution "Includes all BUY and SELL trades, as well as trades from all regions (both national and international)" || exit 1
create_data_product pageviews @edge-team tier-2 curated edge "Website page views" || exit 1
create_data_product users @membership-team tier-1 authoritative membership "All users from all regions (both national and international)" || exit 1

printf "\n";print_process_start "====== Prepare ksqlDB entities for new Data Products."
create_ksqldb_app || exit 1

###########################################################################

echo
echo
echo "Confluent Cloud Environment:"
echo
echo "Service Account         = $SERVICE_ACCOUNT_ID"
echo "Confluent Cloud Cluster = $CCLOUD_CLUSTER_ID"
echo

echo "Congrats! The Data Mesh is ready to explore."
echo
echo "To destroy the Data Mesh environment including all resources in Confluent Cloud, run ->"
echo "    ${DIR}/destroy-data-mesh.sh $CONFIG_FILE"
echo
