#!/usr/bin/env bash
set -Eeuo pipefail

: "${KUBECONFIG:?Defina KUBECONFIG antes de executar este script}"

printf 'Aguardando o SonarQube ficar disponível...
'
kubectl -n sonarqube wait --for=condition=Ready pod -l app=sonarqube --timeout=900s 2>/dev/null || true

printf 'SonarQube: http://localhost:9000
'
printf 'Login inicial padrão: admin / admin
'
printf 'Pressione Ctrl+C para encerrar o redirecionamento.

'

kubectl -n sonarqube port-forward service/sonarqube 9000:9000
