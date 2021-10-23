.PHONY: *

HELP_TAB_WIDTH = 25

.DEFAULT_GOAL := help

SHELL=/bin/bash -o pipefail

check-dependency = $(if $(shell command -v $(1)),,$(error Make sure $(1) is installed))

clean: ## Clean build output
	@./gradlew clean

build: clean ## Clean and build the demo server
	@./gradlew bootjar

run: build ## Clean, build and run the demo server
	@./gradlew bootRun -Pargs=--spring.config.additional-location=file:${CONFIG_FILE}

data-mesh: ## Creates a new Data Mesh in Confluent Cloud then builds and runs the demo
	@./scripts/create-data-mesh.sh
	@make run

destroy: ## Destroys the Data Mesh configured in the variable $CONFIG_FILE
	@./scripts/destroy-data-mesh.sh ${CONFIG_FILE}

help:
	@$(foreach m,$(MAKEFILE_LIST),grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(m) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-$(HELP_TAB_WIDTH)s\033[0m %s\n", $$1, $$2}';)

