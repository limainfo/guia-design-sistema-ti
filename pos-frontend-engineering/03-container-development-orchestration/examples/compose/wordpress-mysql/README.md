# Exemplo Compose — WordPress e MySQL

Crie os arquivos de secrets a partir dos exemplos:

```bash
cp secrets/db_password.txt.example secrets/db_password.txt
cp secrets/db_root_password.txt.example secrets/db_root_password.txt
```

Suba a aplicação:

```bash
docker compose config
docker compose up -d
docker compose ps
docker compose logs -f
```

Acesse `http://localhost:8000`.

Remova os containers sem apagar os dados:

```bash
docker compose down
```

Remova também os volumes:

```bash
docker compose down --volumes
```
