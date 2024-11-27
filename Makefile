.ONESHELL:
.SHELL := /usr/bin/bash
.PHONY: deploy remove output clean

ROOTPATH=$(shell pwd)

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

set-env:
	@if [ -z $(env) ]; then \
		echo "argument env was not set"; \
		exit 1; \
	 fi

set-stack:
	@if [ -z $(stack) ]; then \
		echo "argument stack was not set"; \
		exit 1; \
	 fi

confirm: set-env set-stack
	@read -p "Are you sure want to proceed $(OPERATION) for $(stack) in $(env)? [Y/n]" choice && \
	case "$$choice" in \
		y|Y ) echo "Proceed $(OPERATION) for $(stack) in $(env)";; \
		* ) echo "Aborted..."; exit 1;; \
	esac

confirm-clean: set-stack
	@read -p "Are you sure want to proceed $(OPERATION) for $(stack)? [Y/n]" choice && \
	case "$$choice" in \
		y|Y ) echo "Proceed $(OPERATION) for $(stack)";; \
		* ) echo "Aborted..."; exit 1;; \
	esac



clean: OPERATION="clean"
clean: confirm-clean ## Clean all charts
	@rm -rf $(stack)/base/charts

deploy: OPERATION="deploy"
deploy: confirm ## Deploy the manifest
	@kubectl kustomize $(ROOTPATH)/$(stack)/overlays/$(env) --enable-helm | kubectl apply -f -

remove: OPERATION="remove"
remove: confirm ## Remove the manifest
	@kubectl kustomize $(ROOTPATH)/$(stack)/overlays/$(env) --enable-helm | kubectl delete -f -

output: set-env ## Get output of the manifest
	@kustomize build $(ROOTPATH)/$(stack)/overlays/$(env) --enable-helm > $(ROOTPATH)/$(stack)/overlays/$(env)/output.yaml
