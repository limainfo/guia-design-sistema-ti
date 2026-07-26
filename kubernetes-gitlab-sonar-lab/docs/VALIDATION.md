
# Validação realizada

## Verificações estáticas

- `bash -n` em todos os scripts;
- parsing dos YAML e JSON sem templates Go;
- leitura e expansão dos alvos principais do Makefile;
- consistência das stages e dependências `needs` da pipeline;
- revisão das tags de imagens e versões fixadas;
- busca por tokens reais e segredos acidentalmente incluídos;
- teste de que `LOCAL_TAG` é expandida uma única vez por execução;
- revisão do fluxo `install_gitlab_runner` e do token sensível;
- revisão dos passos de diagnóstico de Runner Pending.

## Validação obrigatória no ambiente do aluno

```bash
make install-kind
make check
make cluster
export KUBECONFIG="$PWD/.kube/kind-config"
export TF_VAR_gitlab_runner_token='glrt-...'
make platform
make runner-check
make local-deploy
make status
```

Antes do primeiro push, o Project Runner deve aparecer **Online** no GitLab.
