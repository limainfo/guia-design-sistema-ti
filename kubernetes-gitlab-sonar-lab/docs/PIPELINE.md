
# Pipeline GitLab CI/CD

## Runner usado pelo laboratório

O Runner não é um serviço instalado no WSL. O Terraform instala o chart oficial
`gitlab-runner` no namespace `gitlab-runner`. O manager do Runner consulta o
GitLab por HTTPS e cria um pod Kubernetes temporário para cada job.

Com um Runner authentication token (`glrt-`), as propriedades abaixo pertencem
ao objeto criado na interface do GitLab:

- tags;
- execução de jobs sem tag;
- acesso apenas a branches protegidas;
- pausa/ativação do runner.

Por isso, crie o Project Runner com a tag exata `kubernetes` e deixe **Protected**
desmarcado para que pipelines de branches `feature/*` e merge requests sejam
executados.

## Fluxo de merge request

A regra `CI_PIPELINE_SOURCE == "merge_request_event"` cria uma pipeline própria
para a merge request. Ela executa validações e testes sem alterar o cluster:

```text
terraform-format
helm-lint
backend-test
frontend-test
```

## Fluxo após merge

Quando o merge cria um commit na branch padrão:

```text
validate → test → quality → build → deploy → verify
```

Uma reprovação no Quality Gate impede a publicação das imagens e o deploy.

## Build de imagens

O lab usa BuildKit rootless e `buildctl-daemonless.sh`. O build não depende do
socket Docker do WSL. A autenticação no GitLab Registry usa as variáveis
predefinidas `CI_REGISTRY_USER` e `CI_REGISTRY_PASSWORD`.

## Deploy

O pod do job utiliza o ServiceAccount `gitlab-runner`. O Terraform concede a ele
uma Role limitada ao namespace `dev`, suficiente para criar o Secret do Registry
e executar `helm upgrade`.

## Por que um job fica Pending

O GitLab cria o job antes de um Runner aceitá-lo. `Pending` não é um erro do
Kubernetes da aplicação. As causas mais comuns são:

- o Runner não foi instalado porque o token não estava exportado;
- o Runner está offline ou pausado;
- o pipeline exige a tag `kubernetes`, mas o Runner tem outra tag;
- o Runner está configurado como Protected e a branch feature não é protegida.

Use:

```bash
make runner-check
make ci-check
```

`make local-deploy` não processa jobs do GitLab; ele é um teste local independente.
