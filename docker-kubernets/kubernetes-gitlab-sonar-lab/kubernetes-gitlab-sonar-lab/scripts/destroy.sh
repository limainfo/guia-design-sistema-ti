#!/usr/bin/env bash
set -Eeuo pipefail

KUBECONFIG_PATH="${1:-../../.kube/kind-config}"
CLUSTER_NAME="${2:-microplatform-dev}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -f "$KUBECONFIG_PATH" ]]; then
  echo 'Removendo recursos da plataforma...'
  (
    cd "$ROOT_DIR/infra/platform"
    terraform init -input=false >/dev/null
    terraform destroy -auto-approve \
      -var="kubeconfig_path=$KUBECONFIG_PATH" || true
  )
fi

echo 'Removendo cluster Kind...'
(
  cd "$ROOT_DIR/infra/cluster"
  terraform init -input=false >/dev/null
  terraform destroy -auto-approve \
    -var="cluster_name=$CLUSTER_NAME" \
    -var="kubeconfig_path=$KUBECONFIG_PATH" || true
)

rm -f "$KUBECONFIG_PATH"
echo 'Laboratório removido.'
