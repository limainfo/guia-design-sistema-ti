A seguir está a **tradução completa e fiel para o português** do material sobre **Consistent Hashing**, mantendo o tom didático e o foco em *system design interviews*.

---

# Consistent Hashing (Hashing Consistente)

**Que problema o consistent hashing resolve, como ele funciona e como você pode usá-lo em entrevistas.**

---

## Visão Geral

Ao se preparar para entrevistas de *system design*, é quase certo que você já tenha se deparado com **consistent hashing**. Trata-se de um algoritmo fundamental em sistemas distribuídos, usado para distribuir dados entre um cluster de servidores.

Existem literalmente milhares de materiais explicando esse conceito na internet, mas muitos acabam sendo excessivamente acadêmicos.
Neste guia, vamos apresentar uma visão **direta e objetiva** sobre consistent hashing: **qual problema ele resolve, como funciona e como explicá-lo bem em entrevistas**.

---

## Consistent Hashing por Meio de um Exemplo

Vamos construir a intuição com um exemplo prático.

Imagine que você está projetando um sistema de venda de ingressos, como o *TicketMaster*. Inicialmente, o sistema é simples:

* Um único banco de dados armazenando todos os eventos
* Clientes fazem requisições para consultar informações dos eventos

Tudo funciona bem no começo.

![Image](https://images.wondershare.com/edrawmax/templates/network-diagram-for-client-server.png)

![Image](https://media.geeksforgeeks.org/wp-content/uploads/20230509110722/DBMS-1-Tier-Architecture.webp)

Mas o sucesso traz novos desafios.

À medida que a plataforma cresce e passa a hospedar mais eventos, **um único banco de dados não consegue mais suportar a carga**. Surge então a necessidade de distribuir os dados entre múltiplos bancos — processo conhecido como **sharding**.

---

## Sharding

A grande pergunta passa a ser:

> **Como decidir qual evento deve ser armazenado em qual instância de banco de dados?**

---

## Primeira Tentativa: Hashing Simples com Módulo

A abordagem mais direta é o **hashing com operador módulo**:

1. Aplicamos uma função de hash sobre o `event_id`, gerando um número
2. Aplicamos o operador módulo (%) usando o número de bancos disponíveis
3. O resultado indica o banco de dados responsável pelo evento

Em código:

```text
database_id = hash(event_id) % number_of_databases
```

### Exemplo com 3 bancos de dados

* Evento `#1234` → `hash(1234) % 3 = 1` → Banco 1
* Evento `#5678` → `hash(5678) % 3 = 0` → Banco 0
* Evento `#9012` → `hash(9012) % 3 = 2` → Banco 2

À primeira vista, parece perfeito.

---

## Problema ao Adicionar um Novo Nó

Agora imagine que você precise adicionar um **quarto banco de dados**.

O cálculo muda para:

```text
database_id = hash(event_id) % 4
```

Você faz o deploy… e de repente **a atividade no banco de dados explode** — em todos os nós, não apenas no novo.

![Image](https://miro.medium.com/v2/resize%3Afit%3A1400/1%2AUp-E-fdOegkltj4FlSypjw.png)

![Image](https://miro.medium.com/0%2AT-jz4NLW7xhiT9rR)

### O que aconteceu?

A simples mudança no divisor do módulo **alterou o destino de quase todos os eventos**.

Exemplo:

* Antes: `hash(1234) % 3 = 1` → Banco 1
* Agora: `hash(1234) % 4 = 0` → Banco 0

Isso significa mover dados do Banco 1 para o Banco 0.
E esse não é um caso isolado — **quase todos os dados precisam ser redistribuídos**, causando:

* Pico de carga
* Lentidão
* Indisponibilidade temporária para os usuários

---

## Problema ao Remover um Nó

O mesmo problema ocorre quando um banco falha.

Se um banco cai:

* Antes: `hash(event_id) % 3`
* Depois: `hash(event_id) % 2`

Resultado? **Redistribuição massiva de dados novamente.**

Fica claro que **hashing simples com módulo não é suficiente**.

---

## Entra em Cena: Consistent Hashing

O **consistent hashing** resolve exatamente esse problema:
👉 **minimizar a redistribuição de dados quando nós entram ou saem do sistema**.

### A ideia central

* Tanto os **dados** quanto os **servidores** são posicionados em um **espaço circular**, chamado de **hash ring**.

---

## O Hash Ring

Funcionamento básico:

1. Criamos um anel de hash com um espaço fixo (por simplicidade, 0 a 100)
2. Distribuímos os bancos de dados nesse anel

   * Exemplo com 4 bancos: posições `0`, `25`, `50` e `75`
3. Para armazenar um evento:

   * Aplicamos o hash no `event_id`
   * Caminhamos no sentido horário no anel
   * O primeiro banco encontrado é o responsável pelo dado

![Image](https://assets.bytebytego.com/diagrams/0151-consistent-hashing.png)

![Image](https://i.sstatic.net/LtNuJ.jpg)

> Na prática, o espaço de hash costuma ser de `0` a `2³² - 1`, mas o conceito é o mesmo.

---

## Adicionando um Banco de Dados

Suponha que adicionamos um novo banco na posição `90`.

![Image](https://ik.imagekit.io/ably/ghost/prod/2022/07/node-c-added%402x.png)

![Image](https://substackcdn.com/image/fetch/%24s_%21SIxn%21%2Cf_auto%2Cq_auto%3Agood%2Cfl_progressive%3Asteep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F9509965c-dc33-4f80-8bc6-9eb2d2275295_800x640.png)

O que acontece?

* **Somente os eventos entre 75 e 90 precisam ser movidos**
* Antes, eles iam para o banco da posição 0
* Todos os outros dados permanecem exatamente onde estavam

Resultado:

* Em vez de mover quase 100% dos dados
* Movemos apenas ~15% do total

---

## Removendo um Banco de Dados

Agora imagine que o banco da posição `25` falhe.

![Image](https://substackcdn.com/image/fetch/%24s_%21-1Fg%21%2Cf_auto%2Cq_auto%3Agood%2Cfl_progressive%3Asteep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F606d0829-347a-49a9-8f7b-b7c9d45c5bff_800x640.png)

![Image](https://media.licdn.com/dms/image/v2/D5612AQFBGRogyvHq9g/article-inline_image-shrink_1000_1488/article-inline_image-shrink_1000_1488/0/1666714208557?e=2147483647\&t=_txBOfnE54AXuOtGAnRYesHafLRd2z3WTW2iQlEODII\&v=beta)

* Apenas os dados mapeados para esse banco precisam ser movidos
* Eles passam a ir para o próximo banco no sentido horário (`50`)
* Todo o resto permanece intacto

---

## Nós Virtuais (Virtual Nodes)

Ainda existe um problema.

Quando um banco falha, **todo o seu tráfego pode ir para um único vizinho**, causando desequilíbrio de carga.

### Solução: Nós Virtuais

Em vez de posicionar cada banco em **um único ponto** do anel, nós o posicionamos em **vários pontos**, usando variações do nome:

* `"DB1-vn1"`
* `"DB1-vn2"`
* `"DB1-vn3"`

![Image](https://substackcdn.com/image/fetch/%24s_%212Bh4%21%2Cf_auto%2Cq_auto%3Agood%2Cfl_progressive%3Asteep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fb6a01929-75d6-4885-a400-602f588b0f69_1636x1362.png)

![Image](https://towardsdatascience.com/wp-content/uploads/2024/03/17LVorrsJU4a94kyOO6UCPw.png)

Isso faz com que os nós virtuais fiquem espalhados pelo anel.

### Benefício

Se um banco falhar:

* Cada nó virtual redistribui sua carga para bancos diferentes
* A carga é espalhada de forma muito mais equilibrada

Quanto mais nós virtuais por banco, **mais uniforme é a distribuição**.

---

## Consistent Hashing no Mundo Real

Embora o exemplo tenha usado bancos de dados, o consistent hashing se aplica a vários cenários:

* Bancos de dados distribuídos
* Caches distribuídos
* Filas e brokers de mensagens
* Servidores de aplicação

### Exemplos reais:

* **Apache Cassandra** — distribuição de dados em anel
* **Amazon DynamoDB** — usa consistent hashing internamente
* **CDNs** — decidem qual servidor de borda armazena determinado conteúdo

---

## Quando Usar Consistent Hashing em Entrevistas

Na maioria dos sistemas modernos, **essa complexidade já vem embutida**.

Se você estiver usando:

* DynamoDB
* Cassandra
* Redis Cluster

Normalmente basta mencionar que **o sistema usa consistent hashing internamente**.

### Quando aprofundar?

Em entrevistas focadas em **infraestrutura**, onde você precisa projetar tudo do zero:

* Banco de dados distribuído
* Cache distribuído
* Message broker distribuído

Nesses casos, esteja pronto para explicar:

* Por que hashing simples com módulo falha
* Como o hash ring funciona
* O papel dos nós virtuais
* Estratégias para lidar com falhas e escalabilidade
* Como evitar *hot spots*

---

## Conclusão

O **consistent hashing** revolucionou sistemas distribuídos ao resolver um problema aparentemente simples:

> **Como distribuir dados entre servidores sem precisar redistribuir tudo quando o cluster muda?**

A solução é elegante:

👉 **Organize tudo em um círculo e caminhe no sentido horário.**

Hoje, esse conceito está presente em diversos sistemas críticos que usamos diariamente.

Em entrevistas de *system design*, lembre-se:

* Na maioria das vezes, você **não precisa implementar** consistent hashing
* Basta reconhecer **quando ele está sendo usado**
* E aprofundar apenas quando o cenário exigir

Se quiser, posso:

* Gerar **diagramas Mermaid** do hash ring
* Criar um **resumo de entrevista (cheat sheet)**
* Comparar **consistent hashing vs rendezvous hashing**
* Ou adaptar esse conteúdo para **material de estudo em Markdown**
