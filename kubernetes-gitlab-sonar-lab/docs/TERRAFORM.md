
# Terraform no laboratório

## Duas camadas

A infraestrutura foi separada em:

```text
infra/cluster
infra/platform
```

O cluster e o kubeconfig precisam existir antes de os providers Kubernetes e
Helm consultarem a API.

## Camada cluster

O provider `tehcyx/kind` cria um control plane e dois workers. As portas do WSL
são mapeadas para os NodePorts da aplicação:

```text
127.0.0.1:8080 → 30080
127.0.0.1:8081 → 30081
```

## Camada platform

A camada instala namespaces, PostgreSQL, SonarQube, RBAC e, quando
`install_gitlab_runner=true`, o chart do GitLab Runner.

O alvo principal executa:

```bash
export TF_VAR_gitlab_runner_token='glrt-...'
make platform
```

O Makefile valida o token e passa `install_gitlab_runner=true`. Para estudar
somente Kubernetes/Sonar, sem CI remoto:

```bash
make platform-local
```

Nesse modo, jobs enviados ao GitLab ficam Pending porque nenhum Runner é criado.

## Lock files

Os comandos `make cluster` e `make platform` criam `.terraform.lock.hcl`. Eles
não são ignorados e devem ser versionados para manter os providers reproduzíveis.

## Segredos e state

O token do Runner e as senhas locais podem aparecer no state. Isso é aceitável
somente para o laboratório. Em produção, use backend remoto criptografado e um
gerenciador de segredos.
