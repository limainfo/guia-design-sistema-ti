# Laboratório 2 — Docker Compose

## Objetivo

Executar uma aplicação multicontainer, verificar descoberta de serviços, health check, volumes, logs e ciclo de vida do projeto.

## Pré-requisitos

- Docker com Compose V2;
- arquivos em `examples/compose/wordpress-mysql`;
- porta 8000 livre.

## Parte 1 — Preparar os secrets

```bash
cd examples/compose/wordpress-mysql
cp secrets/db_password.txt.example secrets/db_password.txt
cp secrets/db_root_password.txt.example secrets/db_root_password.txt
```

Edite os dois arquivos e defina senhas locais de laboratório.

Verifique que não serão versionados:

```bash
git check-ignore secrets/db_password.txt secrets/db_root_password.txt
```

## Parte 2 — Validar o Compose

```bash
docker compose config
```

Analise:

- serviços;
- redes;
- volumes;
- secrets;
- dependência do WordPress em relação ao banco.

## Parte 3 — Subir os serviços

```bash
docker compose up -d
```

Acompanhe:

```bash
docker compose ps
docker compose logs -f db
```

Quando o banco estiver saudável:

```bash
docker compose logs -f wordpress
```

## Parte 4 — Acessar a aplicação

Abra:

```text
http://localhost:8000
```

Complete a instalação local do WordPress ou apenas confirme que a página inicial de configuração foi exibida.

## Parte 5 — Inspecionar rede

```bash
docker network ls
```

Descubra o nome do projeto:

```bash
docker compose ls
```

Inspecione as redes criadas:

```bash
docker network inspect wordpress-mysql_frontend
docker network inspect wordpress-mysql_backend
```

O nome exato pode mudar conforme o diretório/projeto.

### Verificação

- WordPress participa de `frontend` e `backend`;
- banco participa somente de `backend`;
- `backend` é interna;
- o banco não possui porta publicada no host.

## Parte 6 — Testar DNS entre serviços

```bash
docker compose exec wordpress getent hosts db
```

A aplicação usa `db:3306`, não `localhost:3306`.

## Parte 7 — Verificar volumes

```bash
docker volume ls
docker compose exec db sh -c 'ls -la /var/lib/mysql | head'
```

Pare e remova apenas os containers:

```bash
docker compose down
```

Suba novamente:

```bash
docker compose up -d
```

Os dados permanecem nos volumes.

## Parte 8 — Falha e recuperação

Interrompa o banco:

```bash
docker compose stop db
```

Observe o WordPress:

```bash
docker compose logs --tail 50 wordpress
```

Reinicie:

```bash
docker compose start db
docker compose ps
```

Discuta por que `depends_on` ajuda no startup, mas não elimina a necessidade de tratamento de falhas em runtime.

## Parte 9 — Atualizar um serviço

```bash
docker compose pull wordpress
docker compose up -d wordpress
```

Verifique se o serviço foi recriado:

```bash
docker compose ps
docker compose logs --tail 30 wordpress
```

## Parte 10 — Remover sem apagar dados

```bash
docker compose down
```

Confirme que volumes permanecem:

```bash
docker volume ls
```

## Parte 11 — Remover com dados

Somente quando desejar limpar tudo:

```bash
docker compose down --volumes
```

Remova os arquivos locais de secrets:

```bash
rm -f secrets/db_password.txt secrets/db_root_password.txt
```

## Perguntas finais

1. Por que a porta do MySQL não foi publicada?
2. Qual é a vantagem da rede backend interna?
3. Qual é a diferença entre `docker compose down` e `down --volumes`?
4. Por que `service_healthy` é superior a `service_started` nesse exemplo?
5. Por que a aplicação ainda precisa implementar retry?
