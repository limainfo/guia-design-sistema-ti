#!/usr/bin/env bash
set -Eeuo pipefail

KUBECONFIG_PATH="${1:-../../.kube/kind-config}"
CLUSTER_NAME="${2:-microplatform-dev}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLATFORM_DIR="$ROOT_DIR/infra/platform"
CLUSTER_DIR="$ROOT_DIR/infra/cluster"

warn() {
  printf '[AVISO] %s\n' "$*" >&2
}

printf '=== Remoção do laboratório %s ===\n' "$CLUSTER_NAME"

# A plataforma deve ser removida enquanto a API do Kubernetes ainda responde.
if [[ -f "$KUBECONFIG_PATH" ]] && \
   KUBECONFIG="$KUBECONFIG_PATH" kubectl version \
     --request-timeout=5s >/dev/null 2>&1; then
  printf '\nRemovendo recursos da plataforma pelo Terraform...\n'
  (
    cd "$PLATFORM_DIR"
    terraform init -input=false >/dev/null
    TF_VAR_gitlab_runner_token='' terraform destroy -auto-approve \
      -var="kubeconfig_path=$KUBECONFIG_PATH" \
      -var='install_gitlab_runner=false'
  ) || warn 'Terraform não concluiu a remoção da plataforma; o cluster será removido mesmo assim.'
else
  warn 'API Kubernetes indisponível; pulando o destroy da plataforma.'
fi

# Tenta primeiro manter o state do cluster coerente.
printf '\nRemovendo o cluster pelo Terraform...\n'
(
  cd "$CLUSTER_DIR"
  terraform init -input=false >/dev/null
  terraform destroy -auto-approve \
    -var="cluster_name=$CLUSTER_NAME" \
    -var="kubeconfig_path=$KUBECONFIG_PATH"
) || warn 'Terraform não removeu o cluster; será usado o fallback do Kind.'

# Fallback independente do state Terraform.
if command -v kind >/dev/null 2>&1; then
  printf '\nGarantindo a exclusão pelo Kind...\n'
  kind delete cluster --name "$CLUSTER_NAME" || true
else
  warn 'Comando kind não encontrado; usando somente o fallback Docker.'
fi

# Última barreira: remove nós residuais com o label oficial do Kind.
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  mapfile -t residual_ids < <(
    docker ps -aq \
      --filter "label=io.x-k8s.kind.cluster=$CLUSTER_NAME"
  )

  if (( ${#residual_ids[@]} > 0 )); then
    printf '\nRemovendo %d contêiner(es) Kind residual(is)...\n' "${#residual_ids[@]}"
    docker rm -f "${residual_ids[@]}" >/dev/null
  fi

  # Compatibilidade defensiva caso uma versão antiga não tenha preservado labels.
  mapfile -t named_ids < <(
    docker ps -a --format '{{.ID}} {{.Names}}' |
      awk -v prefix="${CLUSTER_NAME}-" '$2 ~ ("^" prefix "(control-plane|worker[0-9]*)$") {print $1}'
  )

  if (( ${#named_ids[@]} > 0 )); then
    printf 'Removendo %d contêiner(es) residual(is) identificado(s) pelo nome...\n' "${#named_ids[@]}"
    docker rm -f "${named_ids[@]}" >/dev/null
  fi

  remaining="$({
    docker ps -aq --filter "label=io.x-k8s.kind.cluster=$CLUSTER_NAME"
    docker ps -a --format '{{.ID}} {{.Names}}' |
      awk -v prefix="${CLUSTER_NAME}-" '$2 ~ ("^" prefix "(control-plane|worker[0-9]*)$") {print $1}'
  } | sort -u | sed '/^$/d')"

  if [[ -n "$remaining" ]]; then
    printf '[ERRO] Ainda existem contêineres do cluster %s:\n%s\n' \
      "$CLUSTER_NAME" "$remaining" >&2
    exit 1
  fi
fi

rm -f "$KUBECONFIG_PATH"
printf '\n[OK] Laboratório removido. Nenhum nó residual do cluster %s foi encontrado.\n' "$CLUSTER_NAME"
