
# Versões fixadas

Referência revisada em **26/07/2026**.

| Componente | Versão usada | Local |
|---|---:|---|
| Terraform CLI do pipeline | 1.15.8 | `.gitlab-ci.yml` |
| Provider Kind | 0.11.0 | `infra/cluster/versions.tf` |
| Kind CLI local | 0.32.0 | `scripts/install-kind.sh` |
| Kubernetes dos nós | 1.35.5 por digest | `infra/cluster/variables.tf` |
| Provider Kubernetes | 3.2.1 | `infra/platform/versions.tf` |
| Provider Helm | 3.2.0 | `infra/platform/versions.tf` |
| Provider Random | 3.9.0 | `infra/platform/versions.tf` |
| GitLab Runner chart | 0.91.0 | `infra/platform/variables.tf` |
| SonarQube chart | 2026.4.0 | `infra/platform/variables.tf` |
| PostgreSQL | 17 Alpine | `infra/platform/postgres.tf` |
| Java | 21 | backend |
| Angular | 18.2.14 | frontend |

A versão Kind 0.32.0 é necessária para carregar corretamente as node images
atuais. A imagem Kubernetes está fixada também pelo digest publicado na release.

Após atualizar providers, execute `terraform init -upgrade` e versione os novos
`.terraform.lock.hcl`.
