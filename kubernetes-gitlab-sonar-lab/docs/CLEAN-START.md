# Reinício limpo do experimento

Use esta sequência quando desejar descartar completamente uma tentativa anterior.

## 1. Remover o cluster local

Na raiz do laboratório antigo:

```bash
make destroy

docker ps -a \
  --filter 'label=io.x-k8s.kind.cluster=microplatform-dev'
```

O segundo comando não deve listar contêineres.

## 2. Preparar um projeto GitLab limpo

A opção de menor risco é criar um novo projeto vazio. Caso reutilize o projeto:

- mantenha `main` como branch padrão;
- proteja somente `main`, se desejar;
- remova branches antigas pela interface quando estiverem protegidas;
- remova ou recrie o Project Runner antigo;
- revogue tokens que tenham sido exibidos em terminal, documentação ou conversa.

## 3. Descompactar em diretório novo

```bash
unzip kubernetes-gitlab-sonar-lab-final.zip
cd kubernetes-gitlab-sonar-lab
make install-kind
make check
```

Não copie `.git`, `.terraform`, `terraform.tfstate` ou `.kube` da tentativa anterior.

## 4. Ordem recomendada

```text
criar Project Runner no GitLab
→ exportar TF_VAR_gitlab_runner_token
→ make cluster
→ make platform
→ make runner-check
→ make sonar e gerar SONAR_TOKEN
→ cadastrar as três variáveis no GitLab
→ git init / commit / push main
→ criar feature / merge request
→ merge em main
→ quality / build / deploy / verify
```

As variáveis necessárias no GitLab são:

```text
SONAR_TOKEN
REGISTRY_DEPLOY_USER
REGISTRY_DEPLOY_PASSWORD
```
