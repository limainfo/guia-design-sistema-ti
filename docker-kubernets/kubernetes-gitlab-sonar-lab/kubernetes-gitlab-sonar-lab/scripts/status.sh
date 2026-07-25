#!/usr/bin/env bash
set -Eeuo pipefail

: "${KUBECONFIG:?Defina KUBECONFIG antes de executar este script}"

echo '=== Contexto ==='
kubectl config current-context

echo
echo '=== Nós ==='
kubectl get nodes -o wide

echo
echo '=== Namespaces ==='
kubectl get ns

echo
echo '=== Pods ==='
kubectl get pods -A -o wide

echo
echo '=== Serviços da aplicação ==='
kubectl get svc -n dev 2>/dev/null || true

echo
echo '=== Helm releases ==='
helm list -A
