
# Troubleshooting

## Job GitLab fica Pending

Execute primeiro:

```bash
make runner-check
make ci-check
```

Na interface do GitLab, confirme:

1. Project Runner com status **Online**;
2. tag exata `kubernetes`;
3. opção **Protected** desmarcada para branches feature/MR;
4. runner não pausado.

Se `make platform` havia mostrado `runner_installed = false`, o token não foi
fornecido. Corrija sem recriar o cluster:

```bash
export TF_VAR_gitlab_runner_token='glrt-SEU_TOKEN_REAL'
make platform
make runner-check
```

`make local-deploy` não libera pipeline Pending. Ele não se comunica com a fila
de jobs do GitLab.

## Instalei o Runner manualmente no WSL

Os comandos de download e `gitlab-runner register` exibidos pelo GitLab são para
um Runner instalado diretamente na máquina. Eles não fazem parte deste lab. O
Runner correto é instalado pelo Helm dentro do Kubernetes.

Um runner manual não é necessário. Para evitar confusão, pare-o caso o tenha
instalado:

```bash
sudo gitlab-runner stop 2>/dev/null || true
sudo gitlab-runner uninstall 2>/dev/null || true
```

Não remova a conta ou binário se eles forem usados por outros projetos.

## Kind imprime HTML ou erro próximo de `<`

O arquivo `/usr/local/bin/kind` recebeu HTML em vez do executável. Reinstale com
validação de SHA-256 e ELF:

```bash
make install-kind
hash -r
kind version
```

## `image ... not present locally` no local-deploy

Versões antigas do Makefile recalculavam o timestamp a cada uso. O Makefile atual
usa `LOCAL_TAG := ...`, calculado uma vez. Confirme:

```bash
make -n local-deploy | grep 'lab/backend\|lab/frontend'
```

Todas as linhas devem usar exatamente a mesma tag.

## SonarQube não fica Ready

```bash
kubectl get pods -n sonarqube
kubectl logs -n sonarqube -l app=sonarqube --all-containers
kubectl logs -n sonarqube postgres-0
```

## Runner não aparece online

```bash
kubectl get deployment,pods -n gitlab-runner -o wide
kubectl logs -n gitlab-runner deployment/gitlab-runner --tail=200
kubectl exec -n gitlab-runner deployment/gitlab-runner -- gitlab-runner verify
```

## ImagePullBackOff

```bash
kubectl describe pod -n dev <pod>
kubectl get secret gitlab-registry -n dev
```

Confirme as variáveis `REGISTRY_DEPLOY_USER` e
`REGISTRY_DEPLOY_PASSWORD` e o escopo `read_registry`.

## Terraform não conecta ao cluster

Execute na ordem:

```bash
make cluster
export KUBECONFIG="$PWD/.kube/kind-config"
make platform
```
