# Laboratório 1 — Docker básico

## Objetivo

Praticar imagens, containers, portas, logs, inspeção, volumes, redes e build de uma imagem própria.

## Pré-requisitos

- Docker Engine ou Docker Desktop instalado;
- terminal com acesso ao comando `docker`;
- porta 8080 livre;
- arquivos em `examples/docker/python-app`.

## Parte 1 — Validar a instalação

```bash
docker version
docker info
docker run --rm hello-world
```

### Resultado esperado

- cliente e servidor Docker são exibidos;
- `hello-world` é baixado, se necessário;
- o container imprime mensagem de sucesso e termina.

## Parte 2 — Executar Nginx

```bash
docker run \
  --name meu-nginx \
  -p 8080:80 \
  -d \
  nginx:stable-alpine
```

Verifique:

```bash
docker ps
docker port meu-nginx
curl http://localhost:8080
```

### Questão

Em `8080:80`, qual porta pertence ao host e qual pertence ao container?

**Resposta:** 8080 é a porta do host; 80 é a porta do container.

## Parte 3 — Logs e inspeção

```bash
docker logs meu-nginx
docker inspect meu-nginx
docker inspect --format '{{.State.Status}}' meu-nginx
```

Gere uma requisição e acompanhe o log:

```bash
docker logs -f meu-nginx
```

Em outro terminal:

```bash
curl http://localhost:8080
```

Interrompa o acompanhamento com `Ctrl+C`.

## Parte 4 — Entrar no container

```bash
docker exec -it meu-nginx sh
```

Dentro do container:

```sh
ps
ls -la /usr/share/nginx/html
cat /etc/os-release
exit
```

## Parte 5 — Parar e reiniciar

```bash
docker stop meu-nginx
docker ps
docker ps -a
docker start meu-nginx
```

O container mantém o mesmo nome e configuração porque foi apenas parado, não removido.

## Parte 6 — Volume persistente

```bash
docker volume create nginx-html
```

Copie conteúdo para o volume por meio de um container temporário:

```bash
docker run --rm \
  --mount source=nginx-html,target=/dados \
  alpine:3.21 \
  sh -c 'echo "<h1>Conteúdo persistente</h1>" > /dados/index.html'
```

Remova o Nginx anterior:

```bash
docker rm -f meu-nginx
```

Crie outro usando o volume:

```bash
docker run \
  --name meu-nginx \
  -p 8080:80 \
  --mount source=nginx-html,target=/usr/share/nginx/html,readonly \
  -d \
  nginx:stable-alpine
```

Teste:

```bash
curl http://localhost:8080
```

Remova e recrie o container. O conteúdo continuará no volume.

## Parte 7 — Rede definida pelo usuário

```bash
docker network create lab-net

docker run -d \
  --name servidor \
  --network lab-net \
  nginx:stable-alpine

docker run --rm \
  --network lab-net \
  curlimages/curl \
  http://servidor
```

### Resultado esperado

O cliente resolve `servidor` pelo DNS interno da rede Docker.

## Parte 8 — Limites e estatísticas

```bash
docker run -d \
  --name limitado \
  --memory=128m \
  --cpus=0.25 \
  nginx:stable-alpine

docker stats --no-stream limitado
```

Inspecione os limites:

```bash
docker inspect --format '{{.HostConfig.Memory}} {{.HostConfig.NanoCpus}}' limitado
```

## Parte 9 — Construir imagem própria

Entre no diretório:

```bash
cd examples/docker/python-app
```

Build:

```bash
docker build -t estudo/python-app:1.0.0 .
```

Execute:

```bash
docker run --rm -d \
  --name python-app \
  -p 8081:8080 \
  estudo/python-app:1.0.0
```

Teste:

```bash
curl http://localhost:8081/
curl http://localhost:8081/health
docker inspect --format '{{json .State.Health}}' python-app
```

## Parte 10 — Limpeza

```bash
docker rm -f meu-nginx limitado servidor python-app 2>/dev/null || true
docker network rm lab-net
docker volume rm nginx-html
```

## Evidências sugeridas

Registre:

- saída de `docker ps`;
- resposta do Nginx;
- resultado do volume após recriação;
- comunicação por nome na rede;
- imagem criada em `docker image ls`;
- status do health check.

## Perguntas finais

1. Qual a diferença entre remover e parar um container?
2. Por que o volume sobreviveu à remoção?
3. Por que `servidor` foi resolvido sem IP?
4. Qual é a função de `--rm`?
5. O que mantém o container Python em execução?
