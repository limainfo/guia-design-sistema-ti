# Capítulo 05 — Design Consistent Hashing

## 1. Objetivo do capítulo

Para escalar horizontalmente um sistema, é comum distribuir requisições ou dados entre vários servidores. O desafio é fazer essa distribuição de forma equilibrada e com o menor impacto possível quando servidores são adicionados ou removidos.

O **consistent hashing**, ou **hashing consistente**, é uma técnica usada para resolver esse problema, principalmente em sistemas distribuídos, caches, bancos chave-valor, balanceadores e mecanismos de particionamento de dados.

---

# 2. O problema do rehashing

Uma forma simples de distribuir chaves entre servidores é aplicar uma função de hash e usar o resto da divisão pelo número de servidores.

```text
serverIndex = hash(key) % N
```

Onde:

```text
N = quantidade de servidores
```

Exemplo com 4 servidores:

| key  |     hash | hash % 4 | servidor |
| ---- | -------: | -------: | -------- |
| key0 | 18358617 |        1 | server 1 |
| key1 | 26143584 |        0 | server 0 |
| key2 | 18131146 |        2 | server 2 |
| key3 | 35863496 |        0 | server 0 |
| key4 | 34085809 |        1 | server 1 |
| key5 | 27581703 |        3 | server 3 |
| key6 | 38164978 |        2 | server 2 |
| key7 | 22530351 |        3 | server 3 |

## Distribuição com 4 servidores

```mermaid
flowchart LR
    subgraph S0["server 0"]
        K1["key1"]
        K3["key3"]
    end

    subgraph S1["server 1"]
        K0["key0"]
        K4["key4"]
    end

    subgraph S2["server 2"]
        K2["key2"]
        K6["key6"]
    end

    subgraph S3["server 3"]
        K5["key5"]
        K7["key7"]
    end
```

Essa abordagem funciona bem enquanto a quantidade de servidores permanece fixa.

O problema aparece quando um servidor é removido ou adicionado. Se o número de servidores muda de `4` para `3`, a fórmula também muda:

```text
serverIndex = hash(key) % 3
```

Nova distribuição:

| key  |     hash | hash % 3 | novo servidor |
| ---- | -------: | -------: | ------------- |
| key0 | 18358617 |        0 | server 0      |
| key1 | 26143584 |        0 | server 0      |
| key2 | 18131146 |        1 | server 1      |
| key3 | 35863496 |        2 | server 2      |
| key4 | 34085809 |        1 | server 1      |
| key5 | 27581703 |        0 | server 0      |
| key6 | 38164978 |        1 | server 1      |
| key7 | 22530351 |        0 | server 0      |

## Redistribuição após remover um servidor

```mermaid
flowchart LR
    subgraph A["server 0"]
        A0["key0"]
        A1["key1"]
        A5["key5"]
        A7["key7"]
    end

    subgraph B["server 1"]
        B2["key2"]
        B4["key4"]
        B6["key6"]
    end

    subgraph C["server 2"]
        C3["key3"]
    end
```

O problema é que muitas chaves mudam de servidor, mesmo que apenas um servidor tenha sido removido.

Em um sistema de cache, isso causa muitas perdas de cache ao mesmo tempo. Os clientes passam a consultar servidores errados, gerando um grande volume de cache miss.

---

# 3. O que é Consistent Hashing

O **hashing consistente** é uma técnica em que, quando servidores são adicionados ou removidos, apenas uma pequena fração das chaves precisa ser redistribuída.

Em média, se existem:

```text
k = quantidade de chaves
n = quantidade de servidores
```

Apenas aproximadamente:

```text
k / n
```

chaves precisam ser remapeadas.

Isso é muito melhor do que a abordagem tradicional com módulo, na qual quase todas as chaves podem mudar de servidor.

---

# 4. Espaço de hash e anel de hash

No consistent hashing, o espaço de hash é tratado como um intervalo circular.

Exemplo: usando SHA-1, os valores possíveis vão de:

```text
0 até 2^160 - 1
```

Esse espaço pode ser representado como uma linha:

```mermaid
flowchart LR
    X0["0"] --> X1["..."] --> XN["2^160 - 1"]
```

Ao conectar o fim da linha ao início, formamos um **anel de hash**.

```mermaid
flowchart LR
    A["0"] --> B["..."]
    B --> C["2^160 - 1"]
    C --> A

    classDef point fill:#f8f8f8,stroke:#333,stroke-width:1px;
    class A,B,C point;
```

A ideia central é:

```text
servidores e chaves são posicionados no mesmo anel de hash.
```

---

# 5. Posicionando servidores no anel

Cada servidor é mapeado para uma posição no anel usando uma função de hash baseada, por exemplo, no IP ou no nome do servidor.

```mermaid
flowchart LR
    S0["s0<br/>server 0"] --> S1["s1<br/>server 1"]
    S1 --> S2["s2<br/>server 2"]
    S2 --> S3["s3<br/>server 3"]
    S3 --> S0

    classDef server fill:#e8f1ff,stroke:#3366cc,stroke-width:1px;
    class S0,S1,S2,S3 server;
```

---

# 6. Posicionando chaves no anel

As chaves também são mapeadas para posições no anel.

```mermaid
flowchart LR
    K0["k0<br/>key0"] --> S0["s0<br/>server 0"]
    S0 --> K1["k1<br/>key1"]
    K1 --> S1["s1<br/>server 1"]
    S1 --> K2["k2<br/>key2"]
    K2 --> S2["s2<br/>server 2"]
    S2 --> K3["k3<br/>key3"]
    K3 --> S3["s3<br/>server 3"]
    S3 --> K0

    classDef key fill:#ffffff,stroke:#333,stroke-width:1px;
    classDef server fill:#e8f1ff,stroke:#3366cc,stroke-width:1px;

    class K0,K1,K2,K3 key;
    class S0,S1,S2,S3 server;
```

Importante: nessa abordagem, não usamos:

```text
hash(key) % N
```

A chave é posicionada diretamente no anel.

---

# 7. Como localizar o servidor de uma chave

Para descobrir em qual servidor uma chave está armazenada:

1. Calcula-se a posição da chave no anel.
2. A partir dessa posição, anda-se no sentido horário.
3. O primeiro servidor encontrado será o responsável pela chave.

Exemplo:

```mermaid
flowchart LR
    K0["k0 / key0"] --> S0["s0 / server 0"]
    S0 --> K1["k1 / key1"]
    K1 --> S1["s1 / server 1"]
    S1 --> K2["k2 / key2"]
    K2 --> S2["s2 / server 2"]
    S2 --> K3["k3 / key3"]
    K3 --> S3["s3 / server 3"]
    S3 --> K0

    classDef key fill:#fff,stroke:#333;
    classDef server fill:#dff0ff,stroke:#3366cc;

    class K0,K1,K2,K3 key;
    class S0,S1,S2,S3 server;
```

Resultado conceitual:

| chave | primeiro servidor no sentido horário |
| ----- | ------------------------------------ |
| key0  | server 0                             |
| key1  | server 1                             |
| key2  | server 2                             |
| key3  | server 3                             |

---

# 8. Adicionando um servidor

Quando um novo servidor é adicionado, apenas as chaves que ficam no intervalo afetado precisam mudar.

Exemplo: adicionando `server 4`.

```mermaid
flowchart LR
    K0["k0 / key0"] --> S4["s4 / server 4"]
    S4 --> S0["s0 / server 0"]
    S0 --> K1["k1 / key1"]
    K1 --> S1["s1 / server 1"]
    S1 --> K2["k2 / key2"]
    K2 --> S2["s2 / server 2"]
    S2 --> K3["k3 / key3"]
    K3 --> S3["s3 / server 3"]
    S3 --> K0

    classDef newServer fill:#d9fdd3,stroke:#228b22,stroke-width:2px;
    classDef server fill:#dff0ff,stroke:#3366cc;
    classDef key fill:#fff,stroke:#333;

    class S4 newServer;
    class S0,S1,S2,S3 server;
    class K0,K1,K2,K3 key;
```

Antes:

```text
key0 estava em server 0
```

Depois:

```text
key0 passa para server 4
```

As demais chaves continuam nos mesmos servidores.

Esse é o principal ganho do consistent hashing: adicionar um servidor não exige redistribuir tudo.

---

# 9. Removendo um servidor

Quando um servidor é removido, apenas as chaves daquele servidor precisam ser redistribuídas para o próximo servidor no sentido horário.

Exemplo: removendo `server 1`.

```mermaid
flowchart LR
    K0["k0 / key0"] --> S0["s0 / server 0"]
    S0 --> K1["k1 / key1"]
    K1 --> X1["server 1 removido"]
    X1 --> S2["s2 / server 2"]
    S2 --> K2["k2 / key2"]
    K2 --> S3["s3 / server 3"]
    S3 --> K3["k3 / key3"]
    K3 --> K0

    classDef removed fill:#ffd6d6,stroke:#cc0000,stroke-width:2px;
    classDef server fill:#dff0ff,stroke:#3366cc;
    classDef key fill:#fff,stroke:#333;

    class X1 removed;
    class S0,S2,S3 server;
    class K0,K1,K2,K3 key;
```

Nesse exemplo:

```text
key1 sai de server 1 e vai para server 2
```

As outras chaves permanecem inalteradas.

---

# 10. Problemas da abordagem básica

Mesmo com consistent hashing, a abordagem básica possui dois problemas importantes.

## 10.1 Partições desbalanceadas

A distância entre dois servidores no anel pode variar muito.

Se os servidores ficarem mal distribuídos, um servidor pode assumir uma fatia muito maior do anel do que os demais.

```mermaid
flowchart LR
    S0["s0"] --> S1["s1"]
    S1 --> S2["s2"]
    S2 --> S3["s3"]
    S3 --> S0

    S1 -. "partição grande" .-> S2
    S3 -. "partição pequena" .-> S0

    classDef server fill:#dff0ff,stroke:#3366cc;
    class S0,S1,S2,S3 server;
```

Consequência:

```text
um servidor pode armazenar muito mais dados do que os outros.
```

---

## 10.2 Distribuição não uniforme de chaves

Outro problema é que as chaves podem se concentrar em uma região do anel.

Nesse caso, alguns servidores recebem muitas chaves, enquanto outros quase não recebem dados.

```mermaid
flowchart LR
    S0["s0 / server 0"] --> K1["key"]
    K1 --> K2["key"]
    K2 --> K3["key"]
    K3 --> K4["key"]
    K4 --> S1["s1 / server 1"]
    S1 --> S2["s2 / server 2"]
    S2 --> S3["s3 / server 3"]
    S3 --> S0

    classDef key fill:#fff,stroke:#333;
    classDef server fill:#dff0ff,stroke:#3366cc;

    class K1,K2,K3,K4 key;
    class S0,S1,S2,S3 server;
```

Consequência:

```text
server 0 e server 2 podem receber a maior parte dos dados,
enquanto server 1 e server 3 ficam quase vazios.
```

---

# 11. Virtual nodes ou réplicas

Para resolver esses problemas, usa-se a técnica de **virtual nodes**, também chamados de **vnodes** ou **réplicas**.

A ideia é representar cada servidor físico por vários nós virtuais no anel.

Exemplo:

```text
server 0 → s0_0, s0_1, s0_2
server 1 → s1_0, s1_1, s1_2
```

```mermaid
flowchart LR
    S00["s0_0<br/>server 0"] --> S10["s1_0<br/>server 1"]
    S10 --> S01["s0_1<br/>server 0"]
    S01 --> S11["s1_1<br/>server 1"]
    S11 --> S02["s0_2<br/>server 0"]
    S02 --> S12["s1_2<br/>server 1"]
    S12 --> S00

    classDef server0 fill:#eadcf8,stroke:#7b3fb2;
    classDef server1 fill:#d8f1ff,stroke:#2080b0;

    class S00,S01,S02 server0;
    class S10,S11,S12 server1;
```

Cada nó virtual aponta para um servidor real.

Assim, o anel fica mais bem distribuído e a carga tende a ser mais equilibrada.

---

# 12. Localizando uma chave com virtual nodes

O processo continua o mesmo:

1. Calcula-se a posição da chave.
2. Anda-se no sentido horário.
3. Encontra-se o primeiro nó virtual.
4. O nó virtual indica o servidor físico responsável.

```mermaid
flowchart LR
    K0["k0 / key0"] --> S11["s1_1<br/>virtual node"]
    S11 --> R1["server 1<br/>servidor real"]

    classDef key fill:#fff,stroke:#333;
    classDef vnode fill:#d8f1ff,stroke:#2080b0;
    classDef real fill:#e8ffe8,stroke:#228b22;

    class K0 key;
    class S11 vnode;
    class R1 real;
```

Nesse exemplo:

```text
key0 encontra s1_1 no sentido horário.
s1_1 pertence ao server 1.
Logo, key0 fica no server 1.
```

---

# 13. Quanto mais virtual nodes, melhor a distribuição

Quanto maior o número de virtual nodes, mais equilibrada tende a ser a distribuição das chaves.

Porém, existe um trade-off:

```text
mais virtual nodes = melhor balanceamento
mais virtual nodes = mais metadados para armazenar
```

O capítulo cita que, em sistemas reais, é comum usar muito mais virtual nodes do que nos exemplos didáticos.

---

# 14. Como encontrar as chaves afetadas

Quando um servidor é adicionado ou removido, precisamos identificar qual intervalo do anel será afetado.

## 14.1 Ao adicionar um servidor

Quando `server 4` é adicionado, a faixa afetada começa no novo servidor e anda no sentido anti-horário até encontrar o servidor anterior.

```mermaid
flowchart LR
    S3["s3 / server 3"] --> K0["key0"]
    K0 --> S4["s4 / novo server 4"]
    S4 --> S0["s0 / server 0"]

    S3 -. "faixa afetada" .-> S4

    classDef affected fill:#fff3cd,stroke:#cc9900,stroke-width:2px;
    classDef newServer fill:#d9fdd3,stroke:#228b22,stroke-width:2px;
    classDef server fill:#dff0ff,stroke:#3366cc;

    class K0 affected;
    class S4 newServer;
    class S0,S3 server;
```

Resultado:

```text
as chaves entre s3 e s4 passam para server 4.
```

---

## 14.2 Ao remover um servidor

Quando `server 1` é removido, a faixa afetada é a região que antes pertencia a ele.

```mermaid
flowchart LR
    S0["s0 / server 0"] --> K1["key1"]
    K1 --> X1["s1 / server 1 removido"]
    X1 --> S2["s2 / server 2"]

    S0 -. "faixa afetada" .-> X1

    classDef removed fill:#ffd6d6,stroke:#cc0000,stroke-width:2px;
    classDef affected fill:#fff3cd,stroke:#cc9900,stroke-width:2px;
    classDef server fill:#dff0ff,stroke:#3366cc;

    class X1 removed;
    class K1 affected;
    class S0,S2 server;
```

Resultado:

```text
as chaves entre s0 e s1 passam para server 2.
```

---

# 15. Benefícios do Consistent Hashing

O capítulo destaca três benefícios principais:

## 15.1 Menos redistribuição de chaves

Quando servidores são adicionados ou removidos, apenas uma parte das chaves precisa mudar de lugar.

Isso reduz:

```text
cache miss
movimentação de dados
custo de rebalanceamento
instabilidade do sistema
```

---

## 15.2 Melhor escalabilidade horizontal

É mais fácil adicionar novos servidores ao cluster, porque a redistribuição é limitada.

```mermaid
flowchart LR
    A["Cluster atual"] --> B["Adicionar servidor"]
    B --> C["Redistribuir apenas parte das chaves"]
    C --> D["Cluster expandido"]

    classDef step fill:#f8f8f8,stroke:#333;
    class A,B,C,D step;
```

---

## 15.3 Mitigação de hotspot

Um hotspot ocorre quando muitas requisições acessam a mesma região ou o mesmo shard.

O consistent hashing ajuda a distribuir melhor os dados e reduzir a chance de um servidor específico ficar sobrecarregado.

---

# 16. Onde o Consistent Hashing é usado

O capítulo cita exemplos reais de uso:

| Sistema          | Uso                                 |
| ---------------- | ----------------------------------- |
| Amazon Dynamo    | Particionamento de dados            |
| Apache Cassandra | Distribuição de dados no cluster    |
| Discord          | Escalabilidade de aplicação de chat |
| Akamai CDN       | Distribuição de conteúdo            |
| Google Maglev    | Balanceamento de carga              |

---

# 17. Resumo final

Consistent hashing é uma técnica para distribuir chaves entre servidores de forma eficiente em sistemas distribuídos.

A ideia principal é substituir a abordagem:

```text
hash(key) % N
```

por um modelo baseado em anel:

```text
hash(key) → posição no anel → próximo servidor no sentido horário
```

Com isso, quando servidores são adicionados ou removidos, apenas uma fração das chaves precisa ser remapeada.

A abordagem básica pode gerar desequilíbrio, mas isso é mitigado com **virtual nodes**, que espalham representações virtuais dos servidores pelo anel e tornam a distribuição mais uniforme.

---

# 18. Resumo em uma frase

**Consistent hashing permite escalar horizontalmente distribuindo dados entre servidores com baixa redistribuição quando o cluster muda de tamanho.**
