# Validação realizada

O pacote foi revisado estaticamente antes da entrega.

## Verificações concluídas

- sintaxe dos scripts Bash com `bash -n`;
- leitura do `Makefile` e expansão dos principais alvos com `make -n`;
- parsing de JSON, XML e dos YAML que não contêm templates Go;
- consistência das stages e dependências `needs` dos 10 jobs do GitLab CI;
- balanceamento dos delimitadores dos templates Helm;
- balanceamento estrutural dos arquivos Terraform;
- transpilação sintática dos arquivos TypeScript;
- busca por tokens GitLab reais ou segredos incluídos acidentalmente;
- revisão de UID/GID numéricos nas imagens executadas com `runAsNonRoot`;
- revisão das tags e versões fixadas em `docs/VERSIONS.md`.

## Verificações que dependem do ambiente local

Os comandos abaixo precisam ser executados na máquina que possui Docker,
Terraform, Kind, kubectl e Helm, porque criam containers, baixam providers,
charts e dependências de aplicação:

```bash
make check
make cluster
export KUBECONFIG="$PWD/.kube/kind-config"
make platform
make local-deploy
make status
```

O primeiro pipeline no GitLab também valida o chart com `helm lint`, executa os
testes Maven e Angular, faz as análises SonarQube, cria as imagens e testa o
rollout no cluster.
