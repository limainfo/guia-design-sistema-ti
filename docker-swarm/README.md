# Laboratório Docker Swarm no WSL2

Laboratório prático e isolado para estudar Docker Swarm em uma única máquina com WSL2.

O ambiente cria **três Docker Engines independentes** dentro de contêineres Docker-in-Docker:

- `swarm-manager`: nó manager;
- `swarm-worker1`: nó worker;
- `swarm-worker2`: nó worker.

> **Importante:** os nós usam contêineres `privileged`. Esta abordagem é apropriada para laboratório local, mas não é recomendada para produção.

## 1. Objetivos

Ao concluir o laboratório, você terá praticado:

1. criação de um cluster Swarm;
2. associação de workers ao manager;
3. implantação declarativa com `docker stack deploy`;
4. redes `overlay` e routing mesh;
5. balanceamento entre réplicas;
6. escalabilidade horizontal;
7. atualização gradual e rollback;
8. uso de configs e secrets;
9. drenagem de nó;
10. recuperação automática após falha de um worker.

## 2. Arquitetura

```text
Windows / WSL2 / Ubuntu 24.04
└── Docker Engine principal
    ├── swarm-manager  172.30.0.10  -> localhost:8081
    │   └── Docker Engine 29.6.2 / Swarm manager
    ├── swarm-worker1  172.30.0.11  -> localhost:8082
    │   └── Docker Engine 29.6.2 / Swarm worker
    └── swarm-worker2  172.30.0.12  -> localhost:8083
        └── Docker Engine 29.6.2 / Swarm worker
```

A aplicação possui:

- serviço `web`, com seis réplicas da imagem `traefik/whoami`;
- serviço `observer`, que demonstra Docker Config e Docker Secret;
- rede `overlay` chamada `frontend`;
- porta publicada pelo routing mesh em todos os nós.

## 3. Requisitos

Execute no Ubuntu/WSL2:

```bash
docker version
docker compose version
curl --version
```

O Docker precisa estar em execução. O laboratório funciona tanto com Docker Desktop integrado ao WSL quanto com Docker Engine instalado diretamente na distribuição.

Verifique automaticamente:

```bash
make check
```

## 4. Estrutura do projeto

```text
docker-swarm-lab-wsl2/
├── infrastructure/
│   └── compose.cluster.yml
├── stack/
│   ├── configs/app_environment.txt
│   ├── secrets/demo_api_token.txt
│   └── stack.yml
├── scripts/
│   ├── check-prerequisites.sh
│   ├── up-cluster.sh
│   ├── deploy-stack.sh
│   ├── status.sh
│   ├── test-routing-mesh.sh
│   ├── scale.sh
│   ├── rolling-update.sh
│   ├── rollback.sh
│   ├── drain-worker.sh
│   ├── activate-worker.sh
│   ├── simulate-failure.sh
│   ├── recover-worker.sh
│   ├── inspect-config-secret.sh
│   └── cleanup.sh
├── Makefile
└── README.md
```

## 5. Execução rápida

Na raiz do projeto:

```bash
make check
make up
make deploy
make status
make test
```

Abra também no navegador:

- <http://localhost:8081>
- <http://localhost:8082>
- <http://localhost:8083>

Os três endereços chegam ao mesmo serviço Swarm. O campo `Hostname` varia porque as requisições são encaminhadas às diferentes réplicas.

## 6. Etapa 1 — criar o cluster

```bash
make up
```

O script:

1. inicia os três Docker Engines;
2. executa `docker swarm init` no manager;
3. obtém o token de worker;
4. associa os dois workers;
5. exibe `docker node ls`.

Resultado esperado:

```text
HOSTNAME        STATUS  AVAILABILITY  MANAGER STATUS
swarm-manager   Ready   Active        Leader
swarm-worker1   Ready   Active
swarm-worker2   Ready   Active
```

Para executar comandos manualmente no manager:

```bash
docker exec swarm-manager docker node ls
docker exec swarm-manager docker info
docker exec swarm-manager docker swarm join-token worker
```

## 7. Etapa 2 — implantar a stack

```bash
make deploy
```

O manifesto `stack/stack.yml` será copiado para o manager e implantado com:

```bash
docker stack deploy -c stack.yml swarm-lab
```

Consulte os objetos criados:

```bash
make status

docker exec swarm-manager docker stack ls
docker exec swarm-manager docker stack services swarm-lab
docker exec swarm-manager docker service ps swarm-lab_web
docker exec swarm-manager docker network ls
```

### Compose versus Stack

`docker compose up` cria contêineres no Docker Engine ao qual o cliente está conectado. Já `docker stack deploy` cria **serviços Swarm**, e o manager agenda as tarefas nos nós do cluster.

## 8. Etapa 3 — routing mesh e balanceamento

```bash
make test
```

O script envia várias requisições para as três portas externas:

```text
localhost:8081 -> manager
localhost:8082 -> worker1
localhost:8083 -> worker2
```

Mesmo quando um nó não executa a réplica escolhida, o routing mesh recebe a conexão e encaminha a requisição para uma tarefa ativa.

Teste manual:

```bash
for i in {1..12}; do
  curl -s http://localhost:8081 | grep '^Hostname:'
done
```

Observe que o hostname muda entre as respostas.

## 9. Etapa 4 — escalar horizontalmente

Reduza para três réplicas:

```bash
make scale N=3
```

Aumente para nove:

```bash
make scale N=9
```

Inspecione a distribuição:

```bash
docker exec swarm-manager docker service ps swarm-lab_web
```

O manager compara continuamente o estado atual com o estado desejado e cria ou remove tarefas para atingir o número solicitado.

## 10. Etapa 5 — atualização gradual

A stack começa com `traefik/whoami:v1.10.4`. Atualize para `v1.11.0`:

```bash
make update
```

A política do manifesto usa:

```yaml
update_config:
  parallelism: 1
  delay: 3s
  order: start-first
  failure_action: rollback
```

Isso significa que apenas uma tarefa é atualizada por vez. A nova tarefa inicia antes da antiga ser encerrada.

Acompanhe:

```bash
docker exec swarm-manager docker service ps swarm-lab_web --no-trunc
```

Volte à versão anterior:

```bash
make rollback
```

## 11. Etapa 6 — Docker Config e Docker Secret

```bash
make inspect
```

O serviço `observer` recebe:

- `/run/configs/app_environment`: configuração não sensível;
- `/run/secrets/demo_api_token`: segredo de treinamento.

O script mostra a configuração e apenas o tamanho/hash do segredo, evitando imprimi-lo diretamente.

Listagem administrativa:

```bash
docker exec swarm-manager docker config ls
docker exec swarm-manager docker secret ls
```

Secrets e configs são imutáveis. Em uma atualização real, crie um novo nome versionado, por exemplo `api_token_v2`, associe-o ao serviço e remova a versão antiga depois da migração.

## 12. Etapa 7 — drenar um worker

```bash
make drain
```

O manager altera `swarm-worker1` para `Drain`. As tarefas Swarm desse nó são realocadas para nós ativos.

Consulte:

```bash
docker exec swarm-manager docker node ls
docker exec swarm-manager docker service ps swarm-lab_web
```

Reative o nó:

```bash
make activate
```

A reativação permite receber novas tarefas, mas não provoca necessariamente um rebalanceamento imediato das tarefas já em execução.

## 13. Etapa 8 — simular falha real

Garanta primeiro que o worker esteja ativo:

```bash
make activate
```

Pare abruptamente o segundo worker:

```bash
make fail
```

O script interrompe o contêiner `swarm-worker2`. Após o manager detectar a indisponibilidade, novas tarefas são criadas nos nós restantes para restaurar o número desejado de réplicas.

Consulte:

```bash
make status
```

Recupere o worker:

```bash
make recover
```

Como o estado do Docker Engine está em volume persistente, o worker volta com a mesma identidade e se reconecta ao Swarm.

## 14. Comandos úteis

```bash
# Nós
docker exec swarm-manager docker node ls

# Serviços
docker exec swarm-manager docker service ls

# Tarefas de um serviço
docker exec swarm-manager docker service ps swarm-lab_web

# Logs agregados
docker exec swarm-manager docker service logs -f swarm-lab_web

# Inspeção completa
docker exec swarm-manager docker service inspect --pretty swarm-lab_web

# Forçar recriação gradual das tarefas
docker exec swarm-manager docker service update --force swarm-lab_web

# Remover somente a aplicação
docker exec swarm-manager docker stack rm swarm-lab
```

## 15. Limpeza completa

```bash
make clean
```

Isso remove:

- stack;
- nós Docker-in-Docker;
- rede externa do laboratório;
- volumes dos três daemons;
- estado do Swarm criado no laboratório.

Sua instalação Docker principal permanece fora do Swarm.

## 16. Solução de problemas

### `permission denied` no socket Docker

Teste:

```bash
sudo docker version
```

Caso funcione apenas com `sudo`, adicione seu usuário ao grupo Docker e reinicie a sessão do WSL:

```bash
sudo usermod -aG docker "$USER"
```

### Porta 8081, 8082 ou 8083 ocupada

Identifique o processo:

```bash
sudo ss -lntp | grep -E ':8081|:8082|:8083'
```

Altere o lado esquerdo dos mapeamentos em `infrastructure/compose.cluster.yml`.

### Conflito com a rede `172.30.0.0/24`

Altere o `subnet` e os três `ipv4_address` no arquivo de infraestrutura. Os endereços precisam permanecer na mesma rede.

### Réplicas em estado `Pending`

Verifique:

```bash
docker exec swarm-manager docker service ps swarm-lab_web --no-trunc
docker exec swarm-manager docker node ls
```

As causas mais comuns no laboratório são:

- worker parado;
- worker em `Drain`;
- falha no download da imagem;
- falta de recursos;
- cluster ainda inicializando.

### A aplicação não responde

Verifique os três níveis:

```bash
# Contêineres que representam os nós
docker compose -f infrastructure/compose.cluster.yml ps

# Nós do Swarm
docker exec swarm-manager docker node ls

# Serviços e tarefas
docker exec swarm-manager docker service ls
docker exec swarm-manager docker service ps swarm-lab_web --no-trunc
```

### Overlay ou routing mesh não funciona no ambiente

Este laboratório depende de Docker-in-Docker privilegiado e de recursos de rede do kernel WSL2. Confirme que você está usando contêineres Linux, que o Docker está atualizado e que nenhum software de segurança está bloqueando VXLAN/iptables no ambiente local.

## 17. Desafios adicionais

1. Crie uma restrição para executar o `observer` somente no manager.
2. Adicione um label ao `worker1` e restrinja um novo serviço a esse label.
3. Troque o endpoint de `vip` para `dnsrr` e observe a diferença.
4. Crie uma segunda rede overlay exclusiva para comunicação interna.
5. Provoque uma atualização inválida e confirme o rollback automático.
6. Promova um worker a manager e inspecione a mudança de papel.
7. Remova uma réplica manualmente e observe o Swarm recriá-la.

## 18. Referências oficiais

- Docker Swarm tutorial: <https://docs.docker.com/engine/swarm/swarm-tutorial/>
- Criar um Swarm: <https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/>
- Implantar stacks: <https://docs.docker.com/engine/swarm/stack-deploy/>
- Redes Swarm: <https://docs.docker.com/engine/swarm/networking/>
- Routing mesh: <https://docs.docker.com/engine/swarm/ingress/>
- Rolling updates: <https://docs.docker.com/engine/swarm/swarm-tutorial/rolling-update/>
- Secrets: <https://docs.docker.com/engine/swarm/secrets/>
- Configs: <https://docs.docker.com/engine/swarm/configs/>
