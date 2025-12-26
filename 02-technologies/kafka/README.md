# Kafka — System Design Deep Dive (PT-BR)

## O que é Kafka

O **Apache Kafka** é uma plataforma open-source de **event streaming distribuído**, usada tanto como **fila de mensagens** quanto como **sistema de streams**.
Ele foi projetado para **alto desempenho**, **escala horizontal** e **durabilidade**, sendo capaz de processar volumes massivos de eventos em tempo real.

---

## Exemplo Motivador — Visão Simples (Producer → Queue → Consumer)

Imagine um site da **Copa do Mundo** que precisa atualizar estatísticas em tempo real:

* Gol
* Cartão
* Substituição

Cada evento é enviado para uma fila por um **producer** e processado por um **consumer**.

### Visão inicial (fila simples)

```mermaid
flowchart LR
    Producer[Producer<br/>Eventos do jogo]
    Queue[Fila de eventos]
    Consumer[Consumer<br/>Atualiza site]

    Producer --> Queue --> Consumer
```

⚠️ Problema: **não escala**.

---

## Escalando o Exemplo — Muitos Jogos, Muitos Eventos

Agora imagine:

* 1.000 jogos
* Todos ao mesmo tempo
* Milhões de eventos

Uma única fila vira gargalo.

---

## Particionamento — Garantindo Ordem por Jogo

A solução é **distribuir eventos por chave** (ex: `game_id`).
Eventos do mesmo jogo **sempre vão para a mesma partição**, preservando a ordem.

### Partições por chave (conceito central do Kafka)

```mermaid
flowchart LR
    Producer -->|key=game_1| P1[Partition 1]
    Producer -->|key=game_2| P2[Partition 2]
    Producer -->|key=game_3| P3[Partition 3]

    P1 --> Consumer
    P2 --> Consumer
    P3 --> Consumer
```

✔️ Ordem garantida **dentro da partição**
✔️ Processamento em paralelo **entre partições**

---

## Consumer Groups — Escalando o Consumo

Mesmo com partições, um único consumer pode não aguentar a carga.
Kafka resolve isso com **Consumer Groups**:

* Cada **partição é consumida por apenas um consumer do grupo**
* Kafka faz o balanceamento automaticamente

### Consumer Group em ação

```mermaid
flowchart LR
    subgraph Topic
        P1[Partition 1]
        P2[Partition 2]
        P3[Partition 3]
    end

    subgraph ConsumerGroup[Consumer Group]
        C1[Consumer 1]
        C2[Consumer 2]
        C3[Consumer 3]
    end

    P1 --> C1
    P2 --> C2
    P3 --> C3
```

✔️ Cada evento é processado **uma única vez por grupo**
✔️ Escala horizontal simples

---

## Topics — Separando Domínios (Futebol vs Basquete)

Para evitar misturar dados:

* Futebol → `soccer-topic`
* Basquete → `basketball-topic`

Consumers assinam apenas os tópicos relevantes.

### Múltiplos tópicos

```mermaid
flowchart LR
    Producer --> SoccerTopic[soccer-topic]
    Producer --> BasketTopic[basketball-topic]

    SoccerTopic --> SoccerConsumers[Soccer Consumers]
    BasketTopic --> BasketConsumers[Basketball Consumers]
```

---

## Arquitetura Kafka — Brokers, Topics e Partitions

### Cluster Kafka

* Um **cluster** é composto por vários **brokers**
* Cada broker armazena **partições**
* Tópicos são apenas **agrupamentos lógicos**

### Visão realista do cluster

```mermaid
flowchart LR
    subgraph Broker1
        P1[Topic A - Partition 1]
        P2[Topic B - Partition 1]
    end

    subgraph Broker2
        P3[Topic A - Partition 2]
        P4[Topic B - Partition 2]
    end

    subgraph Broker3
        P5[Topic A - Partition 3]
    end
```

📌 **Tópico ≠ Partição**

* Tópico: conceito lógico
* Partição: unidade física de escala

---

## Como Kafka Escreve Mensagens

Uma mensagem (record) possui:

* **value** (obrigatório)
* **key** (opcional, mas altamente recomendado)
* timestamp
* headers

### Roteamento da mensagem

```mermaid
flowchart LR
    Producer -->|hash(key)| PartitionSelector
    PartitionSelector --> Partition
    Partition --> Broker
```

📌 Regra clássica:

```
partition = hash(key) % número_de_partições
```

---

## Partição como Commit Log (Append-Only)

Cada partição é um **log imutável**, apenas append.

```mermaid
flowchart TB
    P[Partition Log]
    O1[offset 0]
    O2[offset 1]
    O3[offset 2]
    O4[offset 3]

    P --> O1 --> O2 --> O3 --> O4
```

✔️ Imutável
✔️ Altíssimo throughput
✔️ Fácil replicação

---

## Offsets — Controle do Consumo

Consumers **controlam seus próprios offsets**.

```mermaid
flowchart LR
    Partition -->|offset 10| Consumer
    Consumer -->|commit offset 11| Kafka
```

✔️ Retomada após falha
✔️ Exactly-once / At-least-once depende da estratégia

---

## Replicação — Leader e Followers

Kafka usa **Leader–Follower replication**.

```mermaid
flowchart LR
    Producer --> Leader[Leader Partition]
    Leader --> F1[Follower 1]
    Leader --> F2[Follower 2]
```

* Producer escreve **somente no leader**
* Followers replicam passivamente
* Se o leader cair → follower assume

---

## Consumo — Modelo Pull (Não Push)

Kafka **não empurra** mensagens.

```mermaid
flowchart LR
    Consumer -->|poll| Broker
    Broker --> Messages
```

✔️ Controle de backpressure
✔️ Batch eficiente
✔️ Consumers lentos não derrubam o sistema

---

## Quando Usar Kafka em Entrevistas

### Use Kafka quando:

* Processamento assíncrono
* Ordem importa
* Producer e consumer precisam escalar independentemente

### Streams:

* Processamento contínuo
* Múltiplos consumidores
* Near real-time

---

## Escalabilidade — O Ponto Central da Entrevista

### Estratégias

```mermaid
flowchart LR
    IncreasePartitions[Aumentar Partições]
    AddBrokers[Adicionar Brokers]
    BetterKeys[Escolher boas keys]

    IncreasePartitions --> Scale
    AddBrokers --> Scale
    BetterKeys --> Scale
```

📌 **Particionamento é a decisão mais importante**

---

## Hot Partitions — Problema Clássico

Exemplo: anúncios da Nike explodindo em cliques.

### Estratégias

```mermaid
flowchart LR
    HotKey[AdID Popular]
    SaltedKey[AdID + Random Salt]
    CompoundKey[AdID + Região]

    HotKey --> Problem[Hot Partition]
    SaltedKey --> Solution
    CompoundKey --> Solution
```

---

## Confiabilidade — E se o Consumer cair?

Kafka lida bem com isso:

```mermaid
flowchart LR
    ConsumerCrash[Consumer cai]
    Kafka --> Rebalance
    Rebalance --> OtherConsumers
```

✔️ Offset salvo
✔️ Rebalance automático

---

## Retentativas e DLQ

Kafka não tem retry nativo no consumer.

### Padrão comum

```mermaid
flowchart LR
    MainTopic --> Consumer
    Consumer -->|erro| RetryTopic
    RetryTopic --> RetryConsumer
    RetryConsumer -->|falha final| DLQ
```

---

## Retention Policy

Mensagens não são apagadas ao consumir.

```mermaid
flowchart LR
    Topic -->|7 dias| Expiration
```

* Baseado em tempo ou tamanho
* Default: 7 dias

---

## Resumo Final

* Kafka é um **log distribuído**
* Escala via **partições**
* Ordem garantida **por partição**
* Consumer Groups garantem **processamento único**
* Sempre disponível, **às vezes consistente** 😄

---
