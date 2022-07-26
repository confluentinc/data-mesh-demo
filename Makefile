.PHONY: *

HELP_TAB_WIDTH = 25

.DEFAULT_GOAL := help

MAKE_DIR := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

SHELL=/bin/bash -o pipefail

check-dependency = $(if $(shell command -v $(1)),,$(error Make sure $(1) is installed))

get_service_account_id = $(shell confluent kafka cluster list -o json | jq -r '.[0].name | ltrimstr("demo-kafka-cluster-")')
get_prototype_version = $(shell ./gradlew properties -q | grep "^version:" | cut -d ":" -f2 | xargs echo -n)

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

echo: SERVICE_ACCOUNT_ID = $(call get_service_account_id)
echo: CONFIG_FILE ?= ${MAKE_DIR}stack-configs/java-service-account-${SERVICE_ACCOUNT_ID}.config
echo: VERSION ?= $(call get_prototype_version)
echo:
	@:$(call check_defined, CONFIG_FILE, config file)
	@echo ${SERVICE_ACCOUNT_ID}
	@echo ${CONFIG_FILE}
	@echo ${VERSION}

clean: ## Clean build output
	@./gradlew clean

build: clean ## Clean and build the demo server
	@./gradlew bootjar

.PHONY: run-from-source
run-from-source: SERVICE_ACCOUNT_ID = $(call get_service_account_id)
run-from-source: CONFIG_FILE ?= ${MAKE_DIR}stack-configs/java-service-account-${SERVICE_ACCOUNT_ID}.config
run-from-source: ## Build and run the demo from source 
	@:$(call check_defined, CONFIG_FILE, config file)
	@./gradlew bootRun -Pargs=--spring.config.additional-location=file:${CONFIG_FILE}

.PHONY: run-docker
run-docker: SERVICE_ACCOUNT_ID = $(call get_service_account_id)
run-docker: CONFIG_FILE ?= ${MAKE_DIR}stack-configs/java-service-account-${SERVICE_ACCOUNT_ID}.config
run-docker: VERSION ?= $(call get_prototype_version)
run-docker: ## Run the demo in Docker
	@:$(call check_defined, CONFIG_FILE, config file)
	@docker run -it --rm -p 8080:8080 -v ${MAKE_DIR}stack-configs/java-service-account-${SERVICE_ACCOUNT_ID}.config:/java-service-account-${SERVICE_ACCOUNT_ID}.config:ro cnfldemos/data-mesh-demo:${VERSION} --spring.config.additional-location=file:/java-service-account-${SERVICE_ACCOUNT_ID}.config

.PHONY: data-mesh-from-source
data-mesh-from-source: ## Creates a new Data Mesh in Confluent Cloud then builds and runs the demo
	@./scripts/create-data-mesh.sh
	@make run-from-source

.PHONY: data-mesh
data-mesh: ## Creates a new Data Mesh in Confluent Cloud then builds and runs the demo
	@./scripts/validate-docker.sh
	@./scripts/create-data-mesh.sh
	@make run-docker

.PHONY: destroy
destroy: SERVICE_ACCOUNT_ID = $(call get_service_account_id)
destroy: CONFIG_FILE ?= ${MAKE_DIR}stack-configs/java-service-account-${SERVICE_ACCOUNT_ID}.config
destroy: ## Destroys the Data Mesh configured in the variable $CONFIG_FILE
	@:$(call check_defined, CONFIG_FILE, config file)
	@echo -n "Are you sure you want to destroy environment from config file: '${CONFIG_FILE}' [y/n] " && read ans && [ $${ans:-n} = y ]
	@./scripts/destroy-data-mesh.sh ${CONFIG_FILE}

.PHONY: test	
test:
	@./gradlew test

help:
	@$(foreach m,$(MAKEFILE_LIST),grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(m) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-$(HELP_TAB_WIDTH)s\033[0m %s\n", $$1, $$2}';)

