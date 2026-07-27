
# Lab Kubernetes + Terraform + GitLab CI/CD + SonarQube

Laboratório local e descartável para reproduzir um ambiente de desenvolvimento
com microbackend Java, frontend Angular, análise de qualidade e deploy automático
após merge no GitLab.

## Arquitetura

```text
GitLab.com
   │  jobs e imagens
   ▼
GitLab Runner manager — pod no namespace gitlab-runner
   │ cria um pod temporário por job
   ├── testes Java/Angular
   ├── SonarQube + Quality Gate
   ├── BuildKit → GitLab Container Registry
   └── Helm upgrade → namespace dev

Kind no WSL2
├── control-plane
├── worker
├── worker2
├── namespace sonarqube: SonarQube + PostgreSQL
├── namespace gitlab-runner: manager + pods de CI
└── namespace dev: Spring Boot + Angular/Nginx
```

> **Conceito essencial:** o GitLab Runner deste laboratório não é instalado no
> WSL. Terraform e Helm o implantam dentro do Kubernetes. Quando o GitLab mostrar
> comandos para baixar o binário e executar `gitlab-runner register`, não use
> esses comandos neste roteiro.

> `make local-deploy` é um teste local do build/Helm. Ele não processa nem altera
> jobs GitLab em estado Pending.

## 1. Recursos recomendados

Para este lab, reserve pelo menos 12 GiB de RAM para WSL2/Docker. A máquina de
24 GiB informada é suficiente. O SonarQube pode usar até 4 GiB, além de
PostgreSQL, nós Kind e pods dos jobs.

## 2. Instalar e validar os pré-requisitos

São necessários Docker, Terraform, kubectl, Helm, Kind, Git e curl. Consulte
`docs/INSTALLATION.md` para detalhes.

Instale ou repare o Kind usando o script do pacote:

```bash
make install-kind
```

O script baixa a release oficial, valida o SHA-256, confirma que o arquivo é um
executável ELF e só então o instala. Isso evita instalar uma página HTML em
`/usr/local/bin/kind`.

Valide o ambiente:

```bash
make check
```

## 3. Criar o projeto vazio no GitLab

Crie um projeto vazio. Não inicialize com README, pois o diretório já contém os
arquivos do repositório.

Na raiz do laboratório:

```bash
git init --initial-branch=main --object-format=sha1
git remote add origin git@gitlab.com:SEU_GRUPO/SEU_PROJETO.git
```

Antes de continuar, valide o SSH:

```bash
ssh -T git@gitlab.com
git ls-remote origin
```

Em um repositório vazio, `git ls-remote` pode não imprimir refs, mas deve terminar
sem `Permission denied (publickey)`.

Ainda não faça o primeiro push. Primeiro deixe Runner, SonarQube e variáveis
prontos, para que a primeira pipeline não fique presa.

Para repetir o experimento do zero, prefira criar um projeto GitLab vazio novo ou
garanta que `main` seja a branch padrão. Não exclua a branch padrão durante o
roteiro. As branches `feature/*` devem ficar desprotegidas para poderem ser
recriadas e removidas normalmente.

## 4. Criar o Project Runner corretamente

No projeto GitLab:

1. Acesse **Settings > CI/CD > Runners**.
2. Selecione **New project runner**.
3. Informe a tag exata `kubernetes`.
4. Deixe **Run untagged jobs** desmarcado; todos os jobs já possuem a tag.
5. Deixe **Protected** desmarcado, pois branches `feature/*` e MRs normalmente
   não são protegidas.
6. Crie o Runner e copie o token com prefixo `glrt-`.

A tela seguinte do GitLab pode sugerir:

```text
Download the binary
Install and run as a service
gitlab-runner register
```

Ignore essa parte neste laboratório. Ela criaria um Runner no WSL, diferente da
arquitetura proposta. O token será entregue ao chart Helm pelo Terraform.

No mesmo terminal em que executará `make platform`:

```bash
export TF_VAR_gitlab_runner_token='glrt-SEU_TOKEN_REAL'
```

Confirme sem exibir o segredo:

```bash
test -n "$TF_VAR_gitlab_runner_token" && echo 'Token configurado'
```

## 5. Criar o cluster Kind com Terraform

```bash
make cluster
export KUBECONFIG="$PWD/.kube/kind-config"
kubectl get nodes -o wide
```

Resultado esperado: um control plane e dois workers em `Ready`.

## 6. Instalar a plataforma e o Runner

```bash
make platform
```

O alvo agora:

1. verifica se o token existe e começa com `glrt-`;
2. instala PostgreSQL e SonarQube;
3. instala o chart oficial do GitLab Runner;
4. aguarda o Deployment;
5. valida o `config.toml`, o executor Kubernetes e os logs de inicialização.

Não prossiga ao push enquanto isto não funcionar:

```bash
make runner-check
```

Resultado esperado:

```text
Deployment successfully rolled out
[OK] Executor Kubernetes configurado.
[OK] Runner registrado/configurado no GitLab.
```

Na interface do GitLab, o Project Runner deve aparecer **Online**. Caso os jobs
continuem Pending:

```bash
make ci-check
```

## 7. Configurar o SonarQube

Em outro terminal:

```bash
make sonar
```

Acesse `http://localhost:9000` com `admin/admin`, altere a senha e gere um token
em **My Account > Security**. O comando permanece no terminal porque executa
`kubectl port-forward`. Depois de gerar o token, pode encerrá-lo com `Ctrl+C`: isso
fecha apenas o túnel local, não o pod do SonarQube. A pipeline acessa o Service
pelo DNS interno do cluster.

No GitLab, em **Settings > CI/CD > Variables**, cadastre:

```text
SONAR_TOKEN=<token do SonarQube>
```

Marque como Masked. O Runner acessa o Sonar pelo DNS interno:

```text
http://sonarqube.sonarqube.svc.cluster.local:9000
```

## 8. Criar credencial de leitura do Container Registry

Em **Settings > Repository > Deploy tokens**:

1. crie `k8s-pull`;
2. habilite somente `read_registry`;
3. copie usuário e senha.

Cadastre como variáveis Masked:

```text
REGISTRY_DEPLOY_USER
REGISTRY_DEPLOY_PASSWORD
```

O build publica com credenciais temporárias do próprio job; o Deploy Token é
usado pelos pods para baixar as imagens depois do deploy/reagendamento.

## 9. Testar o deploy local

```bash
make local-deploy
```

O Makefile calcula uma única tag para toda a execução, constrói as duas imagens,
confirma que elas existem, carrega-as no Kind e executa `helm upgrade`.

Acesse:

```text
Frontend: http://localhost:8080
Backend:  http://localhost:8081/api/info
```

Este teste não depende do GitLab Runner e não altera jobs Pending.

## 10. Versionar todos os arquivos e fazer o primeiro push

Os `terraform init` anteriores geraram arquivos `.terraform.lock.hcl`. Eles devem
ser versionados para fixar providers.

```bash
git add .
git commit -m 'feat: adiciona laboratório Kubernetes CI/CD'
git push --set-upstream origin main
```

A primeira pipeline da `main` executa:

```text
validate → test → quality → build → deploy → verify
```

## 11. Simular uma merge request e rolling update

```bash
git switch -c feature/altera-saudacao
```

Altere a resposta em:

```text
apps/backend/src/main/java/br/com/lab/backend/GreetingController.java
```

Depois:

```bash
git add .
git commit -m 'feat: altera mensagem de saudação'
git push -u origin feature/altera-saudacao
```

Abra a MR. A pipeline de MR executa apenas validações e testes. Acompanhe os pods:

```bash
make watch
```

Após o merge na `main`, a pipeline executa Sonar, publica as imagens com a tag do
commit e aplica `helm upgrade`. O chart usa `maxUnavailable: 0` e `maxSurge: 1`,
portanto os pods novos ficam Ready antes da remoção dos anteriores.

## 12. Diagnóstico rápido

### Job Pending

```bash
make runner-check
make ci-check
make runner-logs
```

Revise no GitLab: Online, tag `kubernetes`, Protected desmarcado e runner não
pausado.

### Runner não foi instalado

Se uma execução anterior mostrou `runner_installed = false`:

```bash
export TF_VAR_gitlab_runner_token='glrt-SEU_TOKEN_REAL'
make platform
```

Não é necessário recriar o cluster.

### Kind contém HTML

```bash
make install-kind
hash -r
kind version
```

### Imagem local não encontrada

O Makefile revisado usa `LOCAL_TAG := ...`, calculada uma vez. Verifique:

```bash
make -n local-deploy | grep 'lab/backend\|lab/frontend'
```

## 13. Comandos úteis

```bash
make status
make runner-check
make runner-logs
make ci-check
make watch
helm history microplatform -n dev
kubectl rollout history deployment/microplatform-backend -n dev
```

Rollback didático:

```bash
helm rollback microplatform 1 -n dev --wait
```

## 14. Remover o laboratório

```bash
make destroy
```

O script tenta remover a plataforma e o cluster pelos respectivos states do
Terraform. Em seguida, executa `kind delete cluster` e remove por label/nome
qualquer contêiner de nó residual. Assim, o resultado não depende exclusivamente
do state presente na branch atual. Para conferir:

```bash
docker ps -a --filter 'label=io.x-k8s.kind.cluster=microplatform-dev'
```

Após reiniciar Docker/WSL, caso os contêineres existam apenas parados, use
`make recover` em vez de recriar o laboratório.

## 15. Documentação complementar

- `docs/INSTALLATION.md`
- `docs/PIPELINE.md`
- `docs/TERRAFORM.md`
- `docs/KUBERNETES.md`
- `docs/TROUBLESHOOTING.md`
- `docs/EXERCISES.md`
- `docs/VERSIONS.md`
- `docs/CHANGELOG.md`
- `docs/VALIDATION.md`
- `docs/CLEAN-START.md`

## Limitações didáticas

O SonarQube Community Build analisa a branch principal; o Quality Gate bloqueia
o deploy após o merge, mas não fornece análise nativa de MR. O Runner está
privilegiado para reduzir atritos com BuildKit em ambiente local. O state do
Terraform contém segredos locais. Essas escolhas não representam uma arquitetura
de produção.
