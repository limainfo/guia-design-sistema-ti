
#!/usr/bin/env bash
set -Eeuo pipefail

: "${KUBECONFIG:?Defina KUBECONFIG antes de executar este script}"
namespace="gitlab-runner"
deployment="gitlab-runner"

if ! kubectl get namespace "$namespace" >/dev/null 2>&1; then
  printf '[ERRO] Namespace %s não existe. Reexecute make platform com o token glrt-.\n' "$namespace" >&2
  exit 1
fi

if ! helm status gitlab-runner -n "$namespace" >/dev/null 2>&1; then
  cat >&2 <<'EOF'
[ERRO] O Helm release gitlab-runner não está instalado.
Isso normalmente acontece quando make platform foi executado sem
TF_VAR_gitlab_runner_token. Exporte o token e reexecute make platform.
EOF
  exit 1
fi

printf 'Aguardando o Deployment do Runner...\n'
kubectl rollout status "deployment/$deployment" -n "$namespace" --timeout=240s

printf '\n=== Deployment e pods ===\n'
kubectl get deployment,pods -n "$namespace" -o wide

printf '\n=== Verificação de registro junto ao GitLab ===\n'
if ! kubectl exec -n "$namespace" "deployment/$deployment" -- gitlab-runner verify; then
  printf '\n[ERRO] O pod existe, mas o GitLab não reconheceu o Runner como válido.\n' >&2
  printf 'Confira o token, a conectividade HTTPS e os logs: make runner-logs\n' >&2
  exit 1
fi

printf '\n[OK] Runner implantado e autenticado.\n'
printf 'No GitLab, confirme ainda: status Online, tag kubernetes e Protected desmarcado.\n'
