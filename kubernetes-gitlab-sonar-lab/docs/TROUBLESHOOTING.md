
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
make runner-check
# O script valida o Deployment, config.toml, executor e logs; não usa verify.
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


## `cannot re-use a name that is still in use`

Uma execução interrompida pode deixar a release `gitlab-runner` no Helm sem que
o Terraform tenha gravado o recurso no state. O alvo `make platform` atual detecta
e remove automaticamente essa release órfã antes do novo `terraform apply`.

Diagnóstico manual:

```bash
helm status gitlab-runner -n gitlab-runner
```

O `helm status` é suficiente e evita diferenças de flags entre versões do Helm.

## API Kubernetes em `127.0.0.1:<porta>` recusada

Isso normalmente indica que os contêineres Kind estão parados após reinício do
Docker/WSL, ou que o kubeconfig ficou desatualizado. Antes de destruir:

```bash
make recover
```

O comando inicia os nós existentes, exporta novamente o kubeconfig e aguarda os
nós ficarem `Ready`. Se os nós não existirem, execute `make cluster`.

## `make destroy` deixou contêineres Kind

O `destroy` atual não depende apenas do Terraform. Ele usa três camadas:

1. `terraform destroy` da plataforma;
2. `terraform destroy` e `kind delete cluster`;
3. remoção de contêineres residuais pelo label oficial do Kind e pelo nome.

Valide:

```bash
docker ps -a --filter 'label=io.x-k8s.kind.cluster=microplatform-dev'
```
