#!/usr/bin/env bash
set -Eeuo pipefail

KUBECONFIG_PATH="${1:-../../.kube/kind-config}"
CLUSTER_NAME="${2:-microplatform-dev}"

command -v docker >/dev/null 2>&1 || {
  echo '[ERRO] Docker não encontrado.' >&2
  exit 1
}
command -v kind >/dev/null 2>&1 || {
  echo '[ERRO] Kind não encontrado.' >&2
  exit 1
}
command -v kubectl >/dev/null 2>&1 || {
  echo '[ERRO] kubectl não encontrado.' >&2
  exit 1
}

docker info >/dev/null 2>&1 || {
  echo '[ERRO] Docker Engine indisponível.' >&2
  exit 1
}

mapfile -t node_ids < <(
  docker ps -aq --filter "label=io.x-k8s.kind.cluster=$CLUSTER_NAME"
)

if (( ${#node_ids[@]} == 0 )); then
  printf '[ERRO] Não existem contêineres do cluster %s. Execute make cluster.\n' \
    "$CLUSTER_NAME" >&2
  exit 1
fi

printf 'Iniciando nós parados do cluster %s...\n' "$CLUSTER_NAME"
docker start "${node_ids[@]}" >/dev/null

mkdir -p "$(dirname "$KUBECONFIG_PATH")"
kind export kubeconfig \
  --name "$CLUSTER_NAME" \
  --kubeconfig "$KUBECONFIG_PATH"

printf 'Aguardando a API e os nós...\n'
for attempt in $(seq 1 30); do
  if KUBECONFIG="$KUBECONFIG_PATH" kubectl get nodes >/dev/null 2>&1; then
    break
  fi
  if (( attempt == 30 )); then
    echo '[ERRO] A API Kubernetes não respondeu após 150 segundos.' >&2
    exit 1
  fi
  sleep 5
done

KUBECONFIG="$KUBECONFIG_PATH" kubectl wait \
  --for=condition=Ready nodes --all --timeout=240s
KUBECONFIG="$KUBECONFIG_PATH" kubectl get nodes -o wide

printf '\n[OK] Cluster recuperado.\n'
printf 'export KUBECONFIG=%q\n' "$KUBECONFIG_PATH"
