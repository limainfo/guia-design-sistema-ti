
#!/usr/bin/env bash
set -Eeuo pipefail

runner_token="${TF_VAR_gitlab_runner_token:-}"

if [[ -z "$runner_token" ]]; then
  cat >&2 <<'EOF'
[ERRO] TF_VAR_gitlab_runner_token não está exportado.

Crie um Project Runner no GitLab com a tag exata "kubernetes", copie o token
com prefixo glrt- e execute, no mesmo terminal:

  export TF_VAR_gitlab_runner_token='glrt-COLE_O_TOKEN_AQUI'
  make platform

Não execute "gitlab-runner register" no WSL neste laboratório. O Terraform e o
Helm instalarão e registrarão o Runner dentro do Kubernetes.
EOF
  exit 1
fi

if [[ "$runner_token" != glrt-* ]]; then
  printf '[ERRO] O token deve ser um Runner authentication token com prefixo glrt-.\n' >&2
  exit 1
fi

if [[ "$runner_token" == *'COLE_O_TOKEN'* || ${#runner_token} -lt 15 ]]; then
  printf '[ERRO] O valor parece ser um exemplo, não um token real.\n' >&2
  exit 1
fi

printf '[OK] Token do Project Runner encontrado e formato validado.\n'
