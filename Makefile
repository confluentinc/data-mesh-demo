.PHONY: *

HELP_TAB_WIDTH = 25

.DEFAULT_GOAL := help

MAKE_DIR := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

SHELL=/bin/bash -o pipefail

check-dependency = $(if $(shell command -v $(1)),,$(error Make sure $(1) is installed))

clean: ## Clean build output
	@./gradlew clean

build: clean ## Clean and build the demo server
	@./gradlew bootjar

.PHONY: run
run: SERVICE_ACCOUNT_ID = $(shell ccloud kafka cluster list -o json | jq -r '.[0].name' | awk -F'-' '{print $$4;}')
run: CONFIG_FILE ?= ${MAKE_DIR}/stack-configs/java-service-account-${SERVICE_ACCOUNT_ID}.config
run: clean ## Run the demo server
ifeq ($(strip $(SERVICE_ACCOUNT_ID)),)
	$(error Could not determine CONFIG_FILE path)
endif
	@./gradlew bootRun -Pargs=--spring.config.additional-location=file:${CONFIG_FILE}

.PHONY: data-mesh
data-mesh: ## Creates a new Data Mesh in Confluent Cloud then builds and runs the demo
	@./scripts/create-data-mesh.sh
	@make run

.PHONY: destroy
destroy: SERVICE_ACCOUNT_ID = $(shell ccloud kafka cluster list -o json | jq -r '.[0].name' | awk -F'-' '{print $$4;}')
destroy: CONFIG_FILE ?= ${MAKE_DIR}/stack-configs/java-service-account-${SERVICE_ACCOUNT_ID}.config
destroy: ## Destroys the Data Mesh configured in the variable $CONFIG_FILE
ifeq ($(strip $(SERVICE_ACCOUNT_ID)),)
	$(error Could not determine CONFIG_FILE path)
endif
	@echo -n "Are you sure you want to destroy environment from config file: '${CONFIG_FILE}' [y/n] " && read ans && [ $${ans:-n} = y ]
	@./scripts/destroy-data-mesh.sh ${CONFIG_FILE}

help:
	@$(foreach m,$(MAKEFILE_LIST),grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(m) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-$(HELP_TAB_WIDTH)s\033[0m %s\n", $$1, $$2}';)

