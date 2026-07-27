#!/usr/bin/env bash
set -Eeuo pipefail

: "${KUBECONFIG:?Defina KUBECONFIG antes de executar este script}"
PLATFORM_DIR="${1:?Informe o diretório Terraform da plataforma}"

release="gitlab-runner"
namespace="gitlab-runner"
address='helm_release.gitlab_runner[0]'

if ! helm status "$release" -n "$namespace" >/dev/null 2>&1; then
  exit 0
fi

if (
  cd "$PLATFORM_DIR"
  terraform state show "$address" >/dev/null 2>&1
); then
  exit 0
fi

cat <<'EOF'
[AVISO] Foi encontrada uma release Helm gitlab-runner sem vínculo com o state
Terraform atual. Ela será removida para evitar:
  cannot re-use a name that is still in use
EOF

helm uninstall "$release" -n "$namespace"
