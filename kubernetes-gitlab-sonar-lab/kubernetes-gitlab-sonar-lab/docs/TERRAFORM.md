# Terraform no laboratório

## Por que existem dois diretórios

A infraestrutura foi separada em:

```text
infra/cluster
infra/platform
```

A separação evita o problema de inicialização dos providers Kubernetes e Helm:
o cluster e o kubeconfig precisam existir antes que esses providers consigam
consultar a API Kubernetes.

## Camada cluster

O provider `tehcyx/kind` cria três nós Docker:

```text
microplatform-dev-control-plane
microplatform-dev-worker
microplatform-dev-worker2
```

O control plane publica dois NodePorts no WSL:

```text
127.0.0.1:8080 → 30080 (frontend)
127.0.0.1:8081 → 30081 (backend)
```

## Camada platform

Os providers oficiais Kubernetes e Helm instalam:

- namespaces `dev`, `sonarqube` e `gitlab-runner`;
- PostgreSQL como StatefulSet;
- SonarQube via chart oficial;
- GitLab Runner via chart oficial;
- Role e RoleBinding para deploy somente no namespace `dev`.

## Segredos

Os recursos `random_password` criam credenciais locais. Elas são gravadas no
state. Isso é aceitável para o lab, mas em ambiente real use Vault, External
Secrets Operator, SOPS ou o serviço de segredos da nuvem.

## Comandos úteis

```bash
cd infra/cluster
terraform init
terraform plan
terraform apply
terraform output

cd ../platform
terraform init
terraform plan
terraform apply
terraform output
```

Use `terraform state list` para relacionar os objetos HCL aos recursos criados.
