# Capítulo 15 — Design Google Drive

Documentação em português baseada no capítulo 15 do PDF enviado. 

> Observação: o capítulo usa “Google Drive” como problema de entrevista de system design. A arquitetura abaixo não representa necessariamente a arquitetura interna real do Google Drive.

---

## 1. Objetivo do sistema

Projetar um sistema de armazenamento e sincronização de arquivos semelhante ao Google Drive, permitindo que usuários façam upload, download, sincronizem arquivos entre dispositivos, consultem versões e compartilhem arquivos.

O foco principal é suportar:

* upload e download de arquivos;
* sincronização entre dispositivos;
* histórico de versões;
* compartilhamento de arquivos;
* notificações quando arquivos forem alterados;
* alta disponibilidade;
* baixa latência de sincronização;
* economia de banda.

Fora do escopo do capítulo:

* edição colaborativa simultânea, como Google Docs;
* resolução sofisticada de conflitos em tempo real;
* algoritmos avançados de edição concorrente.

---

## 2. Requisitos

### Requisitos funcionais

| Requisito        | Descrição                                                                                |
| ---------------- | ---------------------------------------------------------------------------------------- |
| Upload           | Usuário pode enviar arquivos para a nuvem.                                               |
| Download         | Usuário pode baixar arquivos armazenados.                                                |
| Sincronização    | Arquivos enviados ou modificados em um dispositivo devem aparecer nos demais.            |
| Histórico        | Usuário pode consultar versões anteriores de arquivos.                                   |
| Compartilhamento | Usuário pode compartilhar arquivos com outras pessoas.                                   |
| Notificações     | Usuário deve ser avisado quando arquivos forem modificados, excluídos ou compartilhados. |

### Requisitos não funcionais

| Requisito            | Descrição                                                               |
| -------------------- | ----------------------------------------------------------------------- |
| Confiabilidade       | Arquivos não podem ser perdidos.                                        |
| Sincronização rápida | Alterações devem aparecer rapidamente nos dispositivos.                 |
| Baixo uso de banda   | O sistema deve evitar transferências desnecessárias.                    |
| Escalabilidade       | Deve suportar grande volume de usuários e arquivos.                     |
| Alta disponibilidade | Usuário deve conseguir acessar arquivos mesmo com falhas parciais.      |
| Segurança            | Arquivos devem ser transmitidos por HTTPS e armazenados criptografados. |

---

## 3. Estimativas iniciais

Premissas usadas no capítulo:

| Item                          |      Valor |
| ----------------------------- | ---------: |
| Usuários cadastrados          | 50 milhões |
| Usuários ativos diários       | 10 milhões |
| Espaço por usuário            |      10 GB |
| Uploads por usuário ativo/dia | 2 arquivos |
| Tamanho médio do arquivo      |     500 KB |
| Relação leitura/escrita       |        1:1 |

### Cálculos

```text
Espaço total = 50 milhões * 10 GB
Espaço total = 500 PB

Uploads por dia = 10 milhões * 2
Uploads por dia = 20 milhões

QPS upload = 20 milhões / 24 / 3600
QPS upload ≈ 240

Pico estimado = 240 * 2
Pico estimado ≈ 480 QPS
```

---

## 4. Modelo inicial simples

Uma primeira solução poderia usar apenas:

* um servidor web/API;
* um banco de dados para metadados;
* um sistema local de arquivos para armazenar os arquivos.

```mermaid
flowchart TD
    U["Usuário"] --> WEB["Servidor Web/API"]
    WEB --> DB["Banco de metadados"]
    WEB --> FS["Sistema local de arquivos"]

    DB --> META["Usuários, arquivos, versões, permissões"]
    FS --> DATA["Conteúdo binário dos arquivos"]
```

Essa solução funciona para poucos usuários, mas não escala bem.

Principais problemas:

* o servidor vira ponto único de falha;
* o disco local fica cheio rapidamente;
* o banco de dados cresce muito;
* falhas podem causar perda de arquivos;
* não há boa distribuição de carga.

---

## 5. Namespace de arquivos

O capítulo propõe organizar os arquivos em um namespace semelhante a um sistema de diretórios.

Exemplo:

```text
/drive
  /user1
    /recipes
      chicken_soup.txt
  /user2
    football.mov
    sports.txt
  /user3
    best_pic_ever.png
```

Cada arquivo pode ser identificado por:

```text
namespace + caminho relativo
```

Exemplo:

```text
/drive/user1/recipes/chicken_soup.txt
```

Representação em Mermaid:

```mermaid
flowchart TD
    D["/drive"] --> U1["user1"]
    D --> U2["user2"]
    D --> U3["user3"]

    U1 --> R["recipes"]
    R --> F1["chicken_soup.txt"]

    U2 --> F2["football.mov"]
    U2 --> F3["sports.txt"]

    U3 --> F4["best_pic_ever.png"]
```

---

## 6. APIs principais

O capítulo considera três APIs principais.

### 6.1 Upload de arquivo

Tipos de upload:

| Tipo             | Uso                                  |
| ---------------- | ------------------------------------ |
| Upload simples   | Arquivos pequenos.                   |
| Upload resumível | Arquivos grandes ou redes instáveis. |

Exemplo conceitual:

```http
POST /files/upload?uploadType=resumable
```

Parâmetros:

```json
{
  "uploadType": "resumable",
  "data": "conteúdo do arquivo"
}
```

Fluxo resumível:

```mermaid
sequenceDiagram
    participant C as Cliente
    participant API as API Server
    participant BS as Block Server
    participant CS as Cloud Storage

    C->>API: Solicita URL de upload resumível
    API-->>C: Retorna URL de upload
    C->>BS: Envia dados do arquivo
    BS->>BS: Divide, comprime e criptografa blocos
    BS->>CS: Envia blocos para armazenamento
    CS-->>BS: Confirma upload
    BS-->>API: Atualiza status do upload
```

---

### 6.2 Download de arquivo

Exemplo conceitual:

```http
GET /files/download
```

Parâmetros:

```json
{
  "path": "/recipes/soup/best_soup.txt"
}
```

---

### 6.3 Histórico de versões

Exemplo conceitual:

```http
GET /files/list_revisions
```

Parâmetros:

```json
{
  "path": "/recipes/soup/best_soup.txt",
  "limit": 20
}
```

---

## 7. Evolução da arquitetura

A arquitetura inicial precisa ser melhorada para suportar escala.

Melhorias propostas:

| Problema            | Solução                                        |
| ------------------- | ---------------------------------------------- |
| Servidor único      | Load balancer + múltiplos servidores API       |
| Disco local cheio   | Armazenamento em cloud storage                 |
| Banco único         | Banco de metadados separado e escalável        |
| Arquivos grandes    | Divisão em blocos                              |
| Sincronização lenta | Delta sync                                     |
| Uso alto de banda   | Compressão e upload apenas de blocos alterados |
| Falhas              | Replicação e failover                          |

---

## 8. Arquitetura de alto nível

```mermaid
flowchart TD
    subgraph CLIENTS["Clientes"]
        WEB["Web browser"]
        MOB["Mobile app"]
    end

    WEB --> LB["Load balancer"]
    MOB --> LB["Load balancer"]

    LB --> API["API servers"]

    API --> CACHE["Metadata cache"]
    API --> MDB["Metadata DB"]
    API --> NS["Notification service"]
    API --> Q["Offline backup queue"]

    WEB --> BS["Block servers"]
    MOB --> BS

    BS --> HOT["Cloud storage"]
    HOT --> COLD["Cold storage"]

    NS --> WEB
    NS --> MOB
```

### Responsabilidade dos componentes

| Componente           | Responsabilidade                                          |
| -------------------- | --------------------------------------------------------- |
| Cliente              | Aplicação web ou mobile usada pelo usuário.               |
| Load balancer        | Distribui tráfego entre servidores API.                   |
| API servers          | Autenticação, perfil, metadados, versões e permissões.    |
| Block servers        | Processam upload/download dos blocos de arquivos.         |
| Cloud storage        | Armazena blocos ativos dos arquivos.                      |
| Cold storage         | Armazena dados antigos ou pouco acessados.                |
| Metadata DB          | Guarda metadados de usuários, arquivos, versões e blocos. |
| Metadata cache       | Acelera leitura de metadados frequentes.                  |
| Notification service | Notifica clientes sobre alterações.                       |
| Offline backup queue | Guarda eventos para clientes offline.                     |

---

## 9. Block servers

Os block servers fazem o trabalho pesado do sistema.

Responsabilidades:

* dividir arquivos em blocos menores;
* comprimir blocos;
* criptografar blocos;
* enviar blocos para o cloud storage;
* baixar blocos quando necessário;
* permitir delta sync.

```mermaid
flowchart LR
    F["Arquivo"] --> SPLIT["Dividir em blocos"]

    SPLIT --> B1["Bloco 1"]
    SPLIT --> B2["Bloco 2"]
    SPLIT --> BN["Bloco N"]

    B1 --> C1["Comprimir"]
    B2 --> C2["Comprimir"]
    BN --> CN["Comprimir"]

    C1 --> E1["Criptografar"]
    C2 --> E2["Criptografar"]
    CN --> EN["Criptografar"]

    E1 --> CS["Cloud storage"]
    E2 --> CS
    EN --> CS
```

---

## 10. Delta sync

Em vez de reenviar o arquivo inteiro quando ele é alterado, o sistema envia apenas os blocos modificados.

Exemplo:

```mermaid
flowchart LR
    subgraph ORIGINAL["Arquivo original"]
        B1["Bloco 1"]
        B2["Bloco 2 alterado"]
        B3["Bloco 3"]
        B4["Bloco 4"]
        B5["Bloco 5 alterado"]
    end

    B2 --> UP["Upload apenas dos blocos alterados"]
    B5 --> UP

    UP --> CS["Cloud storage"]
```

Vantagens:

* reduz uso de banda;
* acelera sincronização;
* melhora experiência do usuário;
* reduz custo de transferência.

---

## 11. Consistência forte

O capítulo destaca que o sistema precisa de consistência forte para metadados.

Exemplo de problema:

* cliente A atualiza um arquivo;
* cliente B consulta o mesmo arquivo logo depois;
* o cliente B não deve enxergar uma versão antiga.

Para isso:

* o banco de metadados deve manter consistência forte;
* o cache deve ser invalidado quando houver escrita no banco;
* réplicas precisam estar consistentes com o nó principal;
* operações críticas devem ter comportamento transacional.

O capítulo sugere banco relacional porque bancos relacionais oferecem suporte nativo a propriedades ACID.

---

## 12. Modelo de dados

```mermaid
erDiagram
    USER ||--o{ DEVICE : possui
    USER ||--o{ WORKSPACE : possui
    WORKSPACE ||--o{ FILE : contem
    FILE ||--o{ FILE_VERSION : possui
    DEVICE ||--o{ FILE_VERSION : criou
    FILE_VERSION ||--o{ BLOCK : contem

    USER {
        bigint user_id PK
        varchar user_name
        timestamp created_at
    }

    DEVICE {
        uuid device_id PK
        bigint user_id FK
        timestamp last_logged_in_at
    }

    WORKSPACE {
        bigint id PK
        bigint owner_id FK
        boolean is_shared
        timestamp created_at
    }

    FILE {
        bigint id PK
        varchar file_name
        varchar relative_path
        boolean is_directory
        bigint latest_version
        bigint checksum
        bigint workspace_id FK
        timestamp created_at
        timestamp last_modified
    }

    FILE_VERSION {
        bigint id PK
        bigint file_id FK
        uuid device_id FK
        bigint version_number
        timestamp last_modified
    }

    BLOCK {
        bigint block_id PK
        bigint file_version_id FK
        int block_order
    }
```

### Descrição das tabelas

| Tabela         | Finalidade                                           |
| -------------- | ---------------------------------------------------- |
| `user`         | Dados básicos do usuário.                            |
| `device`       | Dispositivos associados ao usuário.                  |
| `workspace`    | Espaço raiz de arquivos do usuário ou compartilhado. |
| `file`         | Metadados da versão mais recente do arquivo.         |
| `file_version` | Histórico de versões de um arquivo.                  |
| `block`        | Blocos que compõem uma versão do arquivo.            |

---

## 13. Fluxo de upload

O upload possui dois fluxos paralelos:

1. criação dos metadados;
2. envio dos blocos para o cloud storage.

```mermaid
sequenceDiagram
    participant C1 as Cliente 1
    participant BS as Block servers
    participant CS as Cloud storage
    participant API as API servers
    participant DB as Metadata DB
    participant NS as Notification service
    participant C2 as Cliente 2

    par Criar metadados
        C1->>API: Adiciona metadados do novo arquivo
        API->>DB: Salva arquivo com status pending
        API->>NS: Notifica arquivo em upload
        NS-->>C2: Informa que há alteração pendente
    and Upload dos blocos
        C1->>BS: Envia conteúdo do arquivo
        BS->>BS: Divide, comprime e criptografa blocos
        BS->>CS: Envia blocos para storage
        CS-->>API: Callback de upload concluído
        API->>DB: Atualiza status para uploaded
        API->>NS: Notifica upload concluído
        NS-->>C2: Informa que arquivo está disponível
    end
```

---

## 14. Fluxo de download

Um cliente pode descobrir alterações de duas formas:

* se estiver online, recebe notificação;
* se estiver offline, consulta alterações acumuladas quando voltar.

```mermaid
sequenceDiagram
    participant C as Cliente
    participant NS as Notification service
    participant API as API servers
    participant DB as Metadata DB
    participant BS as Block servers
    participant CS as Cloud storage

    NS-->>C: Notifica que arquivo foi alterado
    C->>API: Solicita metadados atualizados
    API->>DB: Consulta metadados
    DB-->>API: Retorna metadados
    API-->>C: Retorna lista de blocos

    C->>BS: Solicita download dos blocos
    BS->>CS: Baixa blocos do cloud storage
    CS-->>BS: Retorna blocos
    BS-->>C: Envia blocos
    C->>C: Reconstrói arquivo localmente
```

---

## 15. Conflitos de sincronização

Conflitos acontecem quando dois usuários editam o mesmo arquivo ao mesmo tempo.

Estratégia apresentada:

* a primeira atualização processada vence;
* a segunda vira uma cópia conflitante;
* o usuário decide se quer mesclar ou sobrescrever.

```mermaid
sequenceDiagram
    participant U1 as Usuario 1
    participant U2 as Usuario 2
    participant S as Sistema

    U1->>S: Envia atualizacao do arquivo
    S-->>U1: Atualizacao sincronizada

    U2->>S: Envia atualizacao do mesmo arquivo
    S-->>U2: Conflito detectado

    S->>S: Mantem versao principal
    S->>S: Cria copia conflitante

    S-->>U1: Mostra arquivo principal
    S-->>U2: Mostra arquivo principal e copia conflitante
```

Exemplo de nomes:

```text
SystemDesignInterview
SystemDesignInterview_user_2_conflicted_copy_2019-05-01
```

---

## 16. Serviço de notificações

O serviço de notificações avisa os clientes quando arquivos mudam.

Opções consideradas:

| Opção        | Característica                                          |
| ------------ | ------------------------------------------------------- |
| Long polling | Cliente mantém uma requisição aberta esperando eventos. |
| WebSocket    | Conexão persistente bidirecional.                       |

O capítulo escolhe **long polling** porque:

* as notificações são pouco frequentes;
* o fluxo principal é servidor → cliente;
* não há grande necessidade de comunicação bidirecional;
* é suficiente para informar mudanças em arquivos.

```mermaid
sequenceDiagram
    participant C as Cliente
    participant NS as Notification service
    participant API as API servers

    C->>NS: Abre conexao long polling
    API->>NS: Informa alteracao em arquivo
    NS-->>C: Retorna notificacao
    C->>NS: Abre nova conexao long polling
```

---

## 17. Economia de armazenamento

O sistema pode economizar espaço com três estratégias principais.

| Estratégia        | Descrição                                             |
| ----------------- | ----------------------------------------------------- |
| Deduplicação      | Blocos idênticos são armazenados apenas uma vez.      |
| Limite de versões | Mantém apenas quantidade limitada de versões antigas. |
| Cold storage      | Move versões antigas para armazenamento mais barato.  |

```mermaid
flowchart TD
    FILE["Arquivo versionado"] --> BLOCKS["Blocos"]

    BLOCKS --> DEDUP["Deduplicacao de blocos"]
    BLOCKS --> LIMIT["Limite de versoes"]
    BLOCKS --> COLD["Mover versoes antigas para cold storage"]

    DEDUP --> SAVE["Economia de espaco"]
    LIMIT --> SAVE
    COLD --> SAVE
```

---

## 18. Tratamento de falhas

| Falha                | Estratégia                                   |
| -------------------- | -------------------------------------------- |
| Load balancer        | Usar par ativo/passivo com heartbeat.        |
| API server           | Servidores stateless atrás do load balancer. |
| Block server         | Outro servidor assume uploads pendentes.     |
| Cloud storage        | Replicação multi-região.                     |
| Metadata cache       | Réplicas múltiplas.                          |
| Metadata DB          | Failover com promoção de réplica.            |
| Notification service | Clientes reconectam em outro servidor.       |
| Offline queue        | Filas replicadas.                            |

```mermaid
flowchart TD
    LB1["Load balancer ativo"] -.heartbeat.-> LB2["Load balancer passivo"]

    LB1 --> API1["API server 1"]
    LB1 --> API2["API server 2"]

    API1 --> DBM["Metadata DB master"]
    API2 --> DBM

    DBM --> DBS1["Replica DB 1"]
    DBM --> DBS2["Replica DB 2"]

    API1 --> CACHE1["Cache 1"]
    API2 --> CACHE2["Cache 2"]

    API1 --> Q1["Offline queue 1"]
    Q1 --> Q2["Offline queue replica"]

    API1 --> NS1["Notification server 1"]
    API2 --> NS2["Notification server 2"]

    API1 --> BS1["Block server 1"]
    API2 --> BS2["Block server 2"]

    BS1 --> CS1["Cloud storage region A"]
    BS2 --> CS2["Cloud storage region B"]

    CS1 -.replicacao.-> CS2
```

---

## 19. Trade-off: upload direto para cloud storage

Uma alternativa seria o cliente enviar arquivos diretamente para o cloud storage.

### Vantagem

* upload mais rápido;
* arquivo trafega uma vez só até o storage;
* reduz carga nos block servers.

### Desvantagens

* lógica de divisão em blocos precisa existir em todos os clientes;
* compressão e criptografia também precisariam ser implementadas em web, iOS e Android;
* aumenta complexidade dos clientes;
* clientes podem ser adulterados ou comprometidos;
* concentrar a lógica nos block servers simplifica governança e segurança.

---

## 20. Resumo final

A arquitetura proposta combina:

* **block servers** para divisão, compressão, criptografia e delta sync;
* **cloud storage** para armazenamento durável dos blocos;
* **metadata DB relacional** para consistência forte;
* **cache** para acelerar leituras de metadados;
* **notification service** com long polling;
* **offline queue** para sincronizar clientes que ficaram offline;
* **cold storage** para reduzir custo com versões antigas;
* **replicação e failover** para alta disponibilidade.

A parte mais importante do design é separar claramente:

```text
metadados != conteúdo do arquivo
```

Metadados ficam no banco.
Conteúdo binário fica em blocos no cloud storage.
A sincronização é feita com notificações e delta sync.
