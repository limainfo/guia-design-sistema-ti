Os comandos `docker swarm` não aparecem nos arquivos `compose.cluster.yml` nem `stack.yml`. Porém, eles existem no script:

```text
scripts/up-cluster.sh
```

O fluxo está escondido pelo comando:

```bash
make up
```

O `Makefile` chama:

```makefile
up:
	@./scripts/up-cluster.sh
```

## Onde o Swarm é criado

No `scripts/up-cluster.sh`, o manager é inicializado com:

```bash
docker exec "$MANAGER_CONTAINER" \
  docker swarm init --advertise-addr "$MANAGER_IP"
```

Considerando os valores usados pelo laboratório, isso equivale a:

```bash
docker exec swarm-manager \
  docker swarm init --advertise-addr 172.30.0.10
```

Depois, o token de worker é obtido com:

```bash
docker exec "$MANAGER_CONTAINER" \
  docker swarm join-token -q worker
```

Equivalente a:

```bash
docker exec swarm-manager \
  docker swarm join-token -q worker
```

Por fim, cada worker entra no cluster com:

```bash
docker exec "$node" \
  docker swarm join \
  --token "$WORKER_TOKEN" \
  "$MANAGER_IP:2377"
```

Equivalente a algo como:

```bash
docker exec swarm-worker1 \
  docker swarm join \
  --token SWMTKN-1-... \
  172.30.0.10:2377
```

E:

```bash
docker exec swarm-worker2 \
  docker swarm join \
  --token SWMTKN-1-... \
  172.30.0.10:2377
```

## Por que existe `docker exec` antes de `docker swarm`

O laboratório utiliza **Docker-in-Docker**.

Sua instalação Docker principal cria três contêineres:

```text
swarm-manager
swarm-worker1
swarm-worker2
```

Cada um desses contêineres executa seu próprio Docker Engine. Por isso, executar isto no WSL:

```bash
docker swarm init
```

colocaria o Docker principal do WSL no Swarm.

No laboratório, executamos:

```bash
docker exec swarm-manager docker swarm init
```

Isso significa:

> Entre no contêiner `swarm-manager` e execute `docker swarm init` no Docker Engine que está dentro dele.

A arquitetura fica assim:

```text
Docker principal do WSL
│
├── swarm-manager
│   └── Docker Engine
│       └── docker swarm init
│
├── swarm-worker1
│   └── Docker Engine
│       └── docker swarm join
│
└── swarm-worker2
    └── Docker Engine
        └── docker swarm join
```

## Como verificar no código

Na raiz do laboratório:

```bash
grep -RIn "docker swarm" scripts
```

O resultado deve apontar para estas linhas do `up-cluster.sh`:

```text
docker swarm init
docker swarm join-token
docker swarm join
```

Também pode visualizar diretamente:

```bash
sed -n '13,38p' scripts/up-cluster.sh
```

## Como comprovar que o cluster é realmente Swarm

Execute:

```bash
docker exec swarm-manager docker node ls
```

O esperado é algo semelhante a:

```text
ID                            HOSTNAME        STATUS  AVAILABILITY  MANAGER STATUS
xxxxxxxxxxxxxxxxxxxxxxxxx *   swarm-manager   Ready   Active        Leader
xxxxxxxxxxxxxxxxxxxxxxxxx     swarm-worker1   Ready   Active
xxxxxxxxxxxxxxxxxxxxxxxxx     swarm-worker2   Ready   Active
```

No manager:

```bash
docker exec swarm-manager \
  docker info --format 'Estado={{.Swarm.LocalNodeState}} Controle={{.Swarm.ControlAvailable}}'
```

Resultado esperado:

```text
Estado=active Controle=true
```

Em um worker:

```bash
docker exec swarm-worker1 \
  docker info --format 'Estado={{.Swarm.LocalNodeState}} Controle={{.Swarm.ControlAvailable}}'
```

Resultado esperado:

```text
Estado=active Controle=false
```

## Onde ocorre o deploy Swarm

O arquivo `scripts/deploy-stack.sh` executa:

```bash
docker exec -w /lab-stack swarm-manager \
  docker stack deploy \
  --prune \
  --resolve-image always \
  -c stack.yml \
  swarm-lab
```

`docker stack deploy` só funciona com o Docker Engine operando em modo Swarm e precisa ser executado em um manager.

## Conclusão

O laboratório está **tecnicamente usando Docker Swarm**. Entretanto, sua observação é válida: para um material didático, a inicialização ficou escondida demais atrás de:

```bash
make up
```

O roteiro deveria apresentar primeiro os comandos manualmente:

```bash
docker swarm init
docker swarm join-token worker
docker swarm join
docker node ls
docker stack deploy
```

e somente depois introduzir os scripts e o `Makefile` como automação. Portanto, o código está correto, mas a abordagem pode ser melhorada didaticamente.
