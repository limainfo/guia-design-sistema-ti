
SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

KUBECONFIG_PATH := $(CURDIR)/.kube/kind-config
CLUSTER_DIR := $(CURDIR)/infra/cluster
PLATFORM_DIR := $(CURDIR)/infra/platform
CLUSTER_NAME ?= microplatform-dev

# A tag deve ser calculada somente uma vez por execução do Make.
# A atribuição recursiva (?=) fazia o timestamp mudar entre build e kind load.
ifeq ($(origin LOCAL_TAG), undefined)
LOCAL_TAG := local-$(shell date +%Y%m%d%H%M%S)
endif

.PHONY: help install-kind check cluster platform platform-local runner-check \
        runner-logs ci-check local-build local-deploy status watch sonar \
        destroy clean

help:
	@printf '%s\n' \
	  'make install-kind   - instala/repara o Kind oficial com validações' \
	  'make check          - valida binários, Docker e recursos básicos' \
	  'make cluster        - cria o Kubernetes Kind via Terraform' \
	  'make platform       - instala PostgreSQL, SonarQube e Runner (token obrigatório)' \
	  'make platform-local - instala PostgreSQL e SonarQube sem GitLab Runner' \
	  'make runner-check   - confirma que o Runner está vivo e registrado' \
	  'make runner-logs    - exibe os logs recentes do Runner' \
	  'make ci-check       - diagnostica jobs GitLab presos em Pending' \
	  'make local-build    - cria as imagens locais com uma única tag imutável' \
	  'make local-deploy   - carrega as imagens no Kind e atualiza o Helm release' \
	  'make status         - exibe nós, pods, serviços e releases' \
	  'make watch          - acompanha os pods da aplicação' \
	  'make sonar          - abre port-forward do SonarQube na porta 9000' \
	  'make destroy        - remove plataforma e cluster' \
	  'make clean          - remove artefatos locais de compilação'

install-kind:
	@./scripts/install-kind.sh

check:
	@./scripts/check-prerequisites.sh

cluster: check
	@mkdir -p .kube
	@cd $(CLUSTER_DIR) && terraform init && terraform apply -auto-approve \
	  -var='cluster_name=$(CLUSTER_NAME)' \
	  -var='kubeconfig_path=$(KUBECONFIG_PATH)'
	@KUBECONFIG='$(KUBECONFIG_PATH)' kubectl wait --for=condition=Ready nodes --all --timeout=180s
	@printf '\nCluster criado. Use:\nexport KUBECONFIG=%s\n' '$(KUBECONFIG_PATH)'

platform: check
	@test -f '$(KUBECONFIG_PATH)' || (echo 'Kubeconfig não encontrado. Execute make cluster.' >&2 && exit 1)
	@./scripts/require-runner-token.sh
	@cd $(PLATFORM_DIR) && terraform init && terraform apply -auto-approve \
	  -var='kubeconfig_path=$(KUBECONFIG_PATH)' \
	  -var='install_gitlab_runner=true'
	@KUBECONFIG='$(KUBECONFIG_PATH)' ./scripts/check-runner.sh

platform-local: check
	@test -f '$(KUBECONFIG_PATH)' || (echo 'Kubeconfig não encontrado. Execute make cluster.' >&2 && exit 1)
	@cd $(PLATFORM_DIR) && TF_VAR_gitlab_runner_token='' terraform init
	@cd $(PLATFORM_DIR) && TF_VAR_gitlab_runner_token='' terraform apply -auto-approve \
	  -var='kubeconfig_path=$(KUBECONFIG_PATH)' \
	  -var='install_gitlab_runner=false'
	@printf '\nPlataforma local instalada sem Runner. Jobs do GitLab permanecerão Pending.\n'

runner-check:
	@test -f '$(KUBECONFIG_PATH)' || (echo 'Kubeconfig não encontrado. Execute make cluster.' >&2 && exit 1)
	@KUBECONFIG='$(KUBECONFIG_PATH)' ./scripts/check-runner.sh

runner-logs:
	@test -f '$(KUBECONFIG_PATH)' || (echo 'Kubeconfig não encontrado. Execute make cluster.' >&2 && exit 1)
	@KUBECONFIG='$(KUBECONFIG_PATH)' kubectl logs -n gitlab-runner deployment/gitlab-runner --tail=200

ci-check:
	@test -f '$(KUBECONFIG_PATH)' || (echo 'Kubeconfig não encontrado. Execute make cluster.' >&2 && exit 1)
	@KUBECONFIG='$(KUBECONFIG_PATH)' ./scripts/diagnose-ci.sh

local-build: check
	@printf 'Tag local desta execução: %s\n' '$(LOCAL_TAG)'
	@docker build -t lab/backend:$(LOCAL_TAG) apps/backend
	@docker build -t lab/frontend:$(LOCAL_TAG) apps/frontend
	@docker image inspect lab/backend:$(LOCAL_TAG) >/dev/null
	@docker image inspect lab/frontend:$(LOCAL_TAG) >/dev/null

local-deploy: local-build
	@test -f '$(KUBECONFIG_PATH)' || (echo 'Kubeconfig não encontrado. Execute make cluster.' >&2 && exit 1)
	@kind get clusters | grep -Fxq '$(CLUSTER_NAME)' || (echo 'Cluster Kind $(CLUSTER_NAME) não encontrado.' >&2 && exit 1)
	@kind load docker-image --name $(CLUSTER_NAME) \
	  lab/backend:$(LOCAL_TAG) lab/frontend:$(LOCAL_TAG)
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
	@printf 'Observação: local-deploy não executa nem libera jobs do GitLab CI.\n'

status:
	@test -f '$(KUBECONFIG_PATH)' || (echo 'Kubeconfig não encontrado. Execute make cluster.' >&2 && exit 1)
	@KUBECONFIG='$(KUBECONFIG_PATH)' ./scripts/status.sh

watch:
	@test -f '$(KUBECONFIG_PATH)' || (echo 'Kubeconfig não encontrado. Execute make cluster.' >&2 && exit 1)
	@KUBECONFIG='$(KUBECONFIG_PATH)' kubectl get pods -n dev -w -o wide

sonar:
	@test -f '$(KUBECONFIG_PATH)' || (echo 'Kubeconfig não encontrado. Execute make cluster.' >&2 && exit 1)
	@KUBECONFIG='$(KUBECONFIG_PATH)' ./scripts/port-forward-sonar.sh

destroy:
	@./scripts/destroy.sh '$(KUBECONFIG_PATH)' '$(CLUSTER_NAME)'

clean:
	@rm -rf apps/backend/target apps/frontend/node_modules apps/frontend/dist apps/frontend/coverage
