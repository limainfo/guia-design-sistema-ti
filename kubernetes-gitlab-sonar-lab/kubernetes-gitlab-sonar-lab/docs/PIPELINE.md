# Pipeline GitLab CI/CD

## Fluxo de merge request

A regra `CI_PIPELINE_SOURCE == "merge_request_event"` cria uma pipeline própria
para a merge request. Ela executa validações e testes sem alterar o cluster.

```text
terraform-format
helm-lint
backend-test
frontend-test
```

## Fluxo após merge

Quando o merge cria um novo commit na branch padrão, a regra
`CI_COMMIT_BRANCH == CI_DEFAULT_BRANCH` habilita o fluxo completo:

```text
validate
  └─ test
      └─ quality
          └─ build
              └─ deploy
                  └─ verify
```

A dependência entre `quality` e `build` é explícita por `needs`. Uma reprovação
no Quality Gate impede a publicação das imagens e o deploy.

## Build de imagens

O lab usa BuildKit rootless e o comando `buildctl-daemonless.sh`. Ele não depende
do socket Docker do host. A autenticação é escrita em `~/.docker/config.json`
com as variáveis predefinidas do GitLab Registry.

Há um exemplo alternativo de Docker-in-Docker em:

```text
ci/examples/dind-build.yml
```

## Deploy

O job de deploy roda dentro do cluster. O Kubernetes executor monta
automaticamente o token do ServiceAccount do job. Por isso, `kubectl` utiliza a
autenticação in-cluster, sem arquivo kubeconfig no GitLab.

O Terraform cria uma Role limitada ao namespace `dev`. O runner não recebe
permissões administrativas nos outros namespaces.

## Tags imutáveis

As imagens recebem a tag `CI_COMMIT_SHA`. O Helm chart grava a mesma tag no
Deployment, permitindo rastrear exatamente qual commit está em execução.

Evite depender apenas de tags mutáveis como `latest`, pois elas dificultam
rollback e auditoria.
