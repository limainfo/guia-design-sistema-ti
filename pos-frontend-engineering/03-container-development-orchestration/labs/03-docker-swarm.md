# Laboratório 3 — Docker Swarm

## Objetivo

Criar um Swarm de laboratório, implantar um serviço, escalar, atualizar e realizar rollback.

## Ambiente

O laboratório pode ser executado em um único host para estudar os comandos. Um cluster real exige múltiplas máquinas ou VMs.

## Parte 1 — Inicializar

```bash
docker swarm init
```

Se houver múltiplas interfaces, informe o endereço:

```bash
docker swarm init --advertise-addr <IP_DO_HOST>
```

Verifique:

```bash
docker node ls
docker info --format '{{.Swarm.LocalNodeState}}'
```

## Parte 2 — Tokens de join

```bash
docker swarm join-token worker
docker swarm join-token manager
```

Não publique esses tokens em repositórios ou documentação pública.

## Parte 3 — Criar serviço

```bash
docker service create \
  --name web \
  --replicas 3 \
  --publish published=8080,target=80 \
  nginx:stable-alpine
```

Verifique:

```bash
docker service ls
docker service ps web
docker service inspect --pretty web
curl http://localhost:8080
```

Em cluster de um único nó, as três tarefas são executadas no mesmo host.

## Parte 4 — Escalar

```bash
docker service scale web=5
docker service ps web
```

Reduza:

```bash
docker service update --replicas 2 web
```

## Parte 5 — Logs

```bash
docker service logs --tail 50 web
docker service logs -f web
```

Gere requisições em outro terminal:

```bash
for i in $(seq 1 10); do curl -s http://localhost:8080 >/dev/null; done
```

## Parte 6 — Atualização controlada

Atualize a configuração do serviço:

```bash
docker service update \
  --update-parallelism 1 \
  --update-delay 5s \
  --update-failure-action rollback \
  --env-add VERSAO=2 \
  web
```

Acompanhe:

```bash
watch docker service ps web
```

## Parte 7 — Forçar nova implantação

```bash
docker service update --force web
```

Isso recria as tarefas mesmo sem mudar a imagem.

## Parte 8 — Rollback

```bash
docker service rollback web
```

Verifique o histórico:

```bash
docker service inspect --pretty web
```

## Parte 9 — Rede overlay

```bash
docker network create --driver overlay --attachable app-net

docker service create \
  --name backend \
  --network app-net \
  nginx:stable-alpine
```

Inspecione:

```bash
docker network inspect app-net
```

## Parte 10 — Secret

```bash
printf '%s' 'senha-laboratorio' | docker secret create senha_app -
```

Crie serviço que lê o secret:

```bash
docker service create \
  --name leitor-secret \
  --secret senha_app \
  alpine:3.21 \
  sh -c 'cat /run/secrets/senha_app; sleep 3600'
```

Verifique logs:

```bash
docker service logs leitor-secret
```

> Em um cenário real, não imprima segredos em logs. Isso é apenas uma demonstração local do caminho de montagem.

## Parte 11 — Limpeza

```bash
docker service rm web backend leitor-secret
docker secret rm senha_app
docker network rm app-net
docker swarm leave --force
```

## Extensão para múltiplos nós

1. crie três VMs Linux;
2. inicialize o manager;
3. adicione dois workers com o token;
4. execute `docker node ls`;
5. implante cinco réplicas;
6. desligue um worker;
7. observe o reagendamento das tarefas.

## Perguntas finais

1. Qual é a diferença entre service e task?
2. O que ocorreu ao aumentar réplicas?
3. O que `--update-parallelism 1` controla?
4. Por que os secrets devem ser lidos como arquivos?
5. Como o comportamento muda em um cluster com vários nós?
