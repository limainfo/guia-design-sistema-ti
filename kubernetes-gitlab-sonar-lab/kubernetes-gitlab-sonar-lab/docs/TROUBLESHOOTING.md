# Troubleshooting

## SonarQube não fica Ready

```bash
kubectl get pods -n sonarqube
kubectl describe pod -n sonarqube -l app=sonarqube
kubectl logs -n sonarqube -l app=sonarqube --all-containers
kubectl logs -n sonarqube postgres-0
```

Verifique RAM disponível e se o PostgreSQL está pronto.

## Runner não aparece online

```bash
kubectl get pods -n gitlab-runner
kubectl logs -n gitlab-runner deployment/gitlab-runner
```

Confirme o token `glrt-`, a URL do GitLab e a conectividade HTTPS de saída.

## Job fica Pending

```bash
kubectl get pods -n gitlab-runner
kubectl describe pod -n gitlab-runner <pod-do-job>
kubectl get events -A --sort-by=.lastTimestamp
```

As causas comuns são falta de memória, pull de imagem ou runner sem tag
compatível.

## BuildKit: operation not permitted

O lab habilita runner privilegiado. Reaplique a plataforma depois de alterar o
values e recrie o pod do runner. Como alternativa didática, use o exemplo DIND
em `ci/examples/dind-build.yml`.

## ImagePullBackOff

```bash
kubectl describe pod -n dev <pod>
kubectl get secret gitlab-registry -n dev
```

Confirme as variáveis `REGISTRY_DEPLOY_USER` e `REGISTRY_DEPLOY_PASSWORD` e se o
Deploy Token possui `read_registry`.

## GitLab hosted runner executou o job

Os hosted runners não alcançam o cluster local. Desabilite-os para o projeto ou
garanta que todos os jobs tenham a tag `kubernetes` associada somente ao runner
local.

## Frontend abre, mas API falha

```bash
kubectl get svc -n dev
kubectl exec -n dev deployment/microplatform-frontend --   wget -qO- http://microplatform-backend:8080/api/info
```

Confirme que o release se chama `microplatform`, porque o Nginx usa o Service
`microplatform-backend`.

## Terraform não conecta ao cluster

Execute as camadas na ordem:

```bash
make cluster
make platform
```

Não destrua o cluster antes da camada platform. O script `make destroy` já usa a
ordem correta.
