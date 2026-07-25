SHELL := /usr/bin/env bash
KUBECONFIG_PATH := $(CURDIR)/.kube/kind-config
CLUSTER_DIR := $(CURDIR)/infra/cluster
PLATFORM_DIR := $(CURDIR)/infra/platform
CLUSTER_NAME ?= microplatform-dev
LOCAL_TAG ?= local-$(shell date +%Y%m%d%H%M%S)

.PHONY: help check cluster platform local-build local-deploy status watch sonar destroy clean

help:
	@printf '%s\n' \
	  'make check          - valida os pré-requisitos' \
	  'make cluster        - cria o Kubernetes Kind via Terraform' \
	  'make platform       - instala PostgreSQL, SonarQube e GitLab Runner' \
	  'make local-build    - compila as imagens localmente' \
	  'make local-deploy   - carrega imagens no Kind e instala o Helm chart' \
	  'make status         - exibe nós, pods, serviços e releases' \
	  'make watch          - acompanha pods do namespace dev' \
	  'make sonar          - abre port-forward do SonarQube na porta 9000' \
	  'make destroy        - remove plataforma e cluster' \
	  'make clean          - remove artefatos locais não versionados'

check:
	@./scripts/check-prerequisites.sh

cluster:
	@mkdir -p .kube
	@cd $(CLUSTER_DIR) && terraform init && terraform apply -auto-approve \
	  -var='cluster_name=$(CLUSTER_NAME)' \
	  -var='kubeconfig_path=$(KUBECONFIG_PATH)'
	@printf '\nCluster criado. Use:\nexport KUBECONFIG=%s\n' '$(KUBECONFIG_PATH)'

platform:
	@test -f '$(KUBECONFIG_PATH)' || (echo 'Kubeconfig não encontrado. Execute make cluster.' && exit 1)
	@cd $(PLATFORM_DIR) && terraform init && terraform apply -auto-approve \
	  -var='kubeconfig_path=$(KUBECONFIG_PATH)'

local-build:
	@docker build -t lab/backend:$(LOCAL_TAG) apps/backend
	@docker build -t lab/frontend:$(LOCAL_TAG) apps/frontend

local-deploy: local-build
	@kind load docker-image --name $(CLUSTER_NAME) lab/backend:$(LOCAL_TAG) lab/frontend:$(LOCAL_TAG)
	@KUBECONFIG='$(KUBECONFIG_PATH)' helm upgrade --install microplatform deploy/helm/microplatform \
	  --namespace dev --create-namespace \
	  --set backend.image.repository=lab/backend \
	  --set backend.image.tag=$(LOCAL_TAG) \
	  --set backend.image.pullPolicy=IfNotPresent \
	  --set frontend.image.repository=lab/frontend \
	  --set frontend.image.tag=$(LOCAL_TAG) \
	  --set frontend.image.pullPolicy=IfNotPresent \
	  --atomic --timeout 5m
	@KUBECONFIG='$(KUBECONFIG_PATH)' kubectl -n dev rollout status deployment/microplatform-backend --timeout=180s
	@KUBECONFIG='$(KUBECONFIG_PATH)' kubectl -n dev rollout status deployment/microplatform-frontend --timeout=180s
	@printf '\nFrontend: http://localhost:8080\nBackend:  http://localhost:8081/api/info\n'

status:
	@KUBECONFIG='$(KUBECONFIG_PATH)' ./scripts/status.sh

watch:
	@KUBECONFIG='$(KUBECONFIG_PATH)' kubectl get pods -n dev -w -o wide

sonar:
	@KUBECONFIG='$(KUBECONFIG_PATH)' ./scripts/port-forward-sonar.sh

destroy:
	@./scripts/destroy.sh '$(KUBECONFIG_PATH)' '$(CLUSTER_NAME)'

clean:
	@rm -rf apps/backend/target apps/frontend/node_modules apps/frontend/dist apps/frontend/coverage
