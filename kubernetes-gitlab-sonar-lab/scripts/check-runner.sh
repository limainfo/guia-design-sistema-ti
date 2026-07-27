#!/usr/bin/env bash
set -Eeuo pipefail

: "${KUBECONFIG:?Defina KUBECONFIG antes de executar este script}"

namespace="gitlab-runner"
release="gitlab-runner"
deployment="gitlab-runner"

if ! kubectl get namespace "$namespace" >/dev/null 2>&1; then
  printf '[ERRO] Namespace %s não existe. Execute make platform.\n' "$namespace" >&2
  exit 1
fi

if ! helm status "$release" -n "$namespace" >/dev/null 2>&1; then
  printf '[ERRO] Helm release %s não está instalada no namespace %s.\n' \
    "$release" "$namespace" >&2
  exit 1
fi

printf 'Aguardando o Deployment do Runner...\n'
kubectl rollout status "deployment/$deployment" \
  -n "$namespace" \
  --timeout=240s

printf '\n=== Deployment e pods ===\n'
kubectl get deployment,pods -n "$namespace" -o wide

printf '\n=== Configuração do Runner ===\n'
kubectl exec -n "$namespace" "deployment/$deployment" -- sh -ec '
  config="/home/gitlab-runner/.gitlab-runner/config.toml"

  if [ ! -s "$config" ]; then
    echo "[ERRO] config.toml não encontrado ou vazio: $config" >&2
    exit 20
  fi

  if ! grep -Fq "[[runners]]" "$config"; then
    echo "[ERRO] O config.toml não contém uma seção [[runners]]." >&2
    exit 21
  fi

  if ! grep -Fq "executor = \"kubernetes\"" "$config"; then
    echo "[ERRO] O Runner não usa o executor Kubernetes." >&2
    exit 22
  fi

  echo "[OK] config.toml encontrado."
  echo "[OK] Seção [[runners]] encontrada."
  echo "[OK] Executor Kubernetes configurado."
'

printf '\n=== Inicialização do Runner ===\n'
runner_logs="$(kubectl logs -n "$namespace" "deployment/$deployment" --tail=300)"

if ! grep -Eq 'Runner registered successfully|Configuration loaded' <<<"$runner_logs"; then
  printf '[ERRO] Os logs não confirmam registro ou carregamento da configuração.\n' >&2
  tail -n 100 <<<"$runner_logs" >&2
  exit 1
fi

if ! grep -Eq 'Starting multi-runner|Initializing executor providers' <<<"$runner_logs"; then
  printf '[ERRO] Os logs não confirmam que o processo do Runner foi iniciado.\n' >&2
  tail -n 100 <<<"$runner_logs" >&2
  exit 1
fi

printf '[OK] Runner registrado/configurado no GitLab.\n'
printf '[OK] Processo do Runner iniciado.\n'
printf '[OK] Deployment disponível no Kubernetes.\n'
printf '\nNo GitLab, confirme: Online, tag kubernetes, não pausado e não protegido.\n'
