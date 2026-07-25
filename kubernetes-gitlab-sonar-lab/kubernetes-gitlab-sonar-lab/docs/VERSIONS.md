# Versões fixadas

Referência revisada em **25/07/2026**. O objetivo é evitar que o laboratório
mude silenciosamente entre execuções.

| Componente | Versão usada | Local da configuração |
|---|---:|---|
| Terraform CLI do pipeline | 1.15.8 | `.gitlab-ci.yml` |
| Provider Kind | 0.11.0 | `infra/cluster/versions.tf` |
| Kind CLI local | 0.32.0 | requisito para `kind load` com as imagens atuais |
| Kubernetes dos nós Kind | 1.35.5 por digest | `infra/cluster/variables.tf` |
| Provider Kubernetes | 3.2.1 | `infra/platform/versions.tf` |
| Provider Helm | 3.2.0 | `infra/platform/versions.tf` |
| Provider Random | 3.9.0 | `infra/platform/versions.tf` |
| Helm CLI do pipeline | 4.2.3 + SHA-256 | `.gitlab-ci.yml` |
| SonarScanner CLI image | 12.1.0.3233_8.0.1 | `.gitlab-ci.yml` |
| BuildKit rootless image | 0.31.2 | `.gitlab-ci.yml` |
| GitLab Runner chart | 0.91.0 | `infra/platform/variables.tf` |
| SonarQube chart | 2026.5.0 | `infra/platform/variables.tf` |
| PostgreSQL | 17 Alpine | `infra/platform/postgres.tf` |
| Java | 21 | `apps/backend/pom.xml` e Dockerfile |
| Spring Boot | 3.5.16 | `apps/backend/pom.xml` |
| Angular | 18.2.14 | `apps/frontend/package.json` |
| Node.js | 20 | `.gitlab-ci.yml` e Dockerfile |

## Atualização controlada

Atualize um componente por vez e execute, nesta ordem:

```bash
terraform fmt -recursive infra
helm lint deploy/helm/microplatform
mvn -f apps/backend/pom.xml clean verify
cd apps/frontend && npm install && npm run test:ci && npm run build
```

Para atualizar a imagem de nós Kind, copie a tag **e o digest** publicados na
release oficial do Kind. Não remova o digest: ele torna a imagem imutável.

Após alterar providers Terraform, execute `terraform init -upgrade` nos dois
diretórios e versione os arquivos `.terraform.lock.hcl` gerados.
