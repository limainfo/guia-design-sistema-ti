# Aula 02 - Estruturas de Dados, Algoritmos e Cloud Computing

## 1. Objetivos da aula

Ao final desta aula, você deve conseguir:

- Explicar por que estruturas de dados ajudam a lidar com complexidade.
- Diferenciar listas, tuplas, dicionários, matrizes, conjuntos, filas, pilhas e hash tables.
- Entender a relação entre dicionários Python e hash tables.
- Comparar algoritmos de ordenação como TimSort, Merge Sort, Quick Sort e Heap Sort.
- Compreender o papel de APIs REST na comunicação entre sistemas.
- Explicar o que é computação em nuvem e diferenciar IaaS, PaaS e SaaS.

---

## 2. Mapa mental da aula

```mermaid
mindmap
  root((Aula 02\nDados, Algoritmos e Cloud))
    Estruturas de dados
      Lista
      Tupla
      Dicionário
      Matriz
      Conjunto
      Fila
      Pilha
      Hash Table
    Algoritmos
      Ordenação
        TimSort
        Merge Sort
        Quick Sort
        Heap Sort
      Busca
        Linear
        Binária
    APIs
      REST
      Cliente
      Servidor
      JSON
    Cloud Computing
      IaaS
      PaaS
      SaaS
      Escalabilidade
      Custo sob demanda
```

---

## 3. Estruturas de dados

Estruturas de dados são formas de organizar informações para que um programa consiga armazenar, acessar, modificar, buscar e processar dados com eficiência.

A ideia central da aula é: **composição é o primeiro passo para lidar com complexidade**.

Uma variável simples guarda um valor. Uma estrutura composta guarda vários valores ou organiza dados de forma mais rica.

```mermaid
flowchart LR
    Variaveis[Variáveis] --> Simples[Simples\nUm valor]
    Variaveis --> Compostas[Compostas\nVários valores]

    Simples --> Int[int]
    Simples --> Float[float]
    Simples --> Bool[bool]
    Simples --> Str[str]

    Compostas --> Lista[list]
    Compostas --> Tupla[tuple]
    Compostas --> Dict[dict]
    Compostas --> Set[set]
    Compostas --> Matriz[Matriz]
    Compostas --> Fila[Fila]
    Compostas --> Pilha[Pilha]
```

---

## 4. Listas

Listas são estruturas dinâmicas e mutáveis. Usam colchetes `[]`, permitem armazenar vários valores e acessar elementos por índice.

```python
alunos = ["Ana", "Bruno", "Carlos"]

print(alunos[0])  # Ana
print(alunos[1])  # Bruno

alunos[2] = "Clara"
print(alunos)
```

Características:

- índice começa em zero;
- permite alteração de elementos;
- aceita tipos diferentes;
- muito usada para coleções de dados.

```mermaid
flowchart LR
    Lista[Lista alunos] --> I0[Índice 0\nAna]
    Lista --> I1[Índice 1\nBruno]
    Lista --> I2[Índice 2\nCarlos]
    I2 --> Alteracao[Alteração\nalunos[2] = Clara]
    Alteracao --> Novo[Índice 2\nClara]
```

---

## 5. Tuplas

Tuplas são semelhantes às listas, mas são **imutáveis**. Usam parênteses `()` e não permitem alteração após a criação.

```python
data_nascimento = (25, 3, 1990)

print(data_nascimento[0])  # dia
print(data_nascimento[1])  # mês
print(data_nascimento[2])  # ano
```

Quando usar:

- coordenadas geográficas;
- datas fixas;
- constantes;
- dados que não devem ser alterados acidentalmente.

```python
coordenadas = (10.0, 20.0)
print(coordenadas[0])
print(coordenadas[1])
```

---

## 6. Dicionários

Dicionários armazenam pares **chave-valor**. Usam `{}` e permitem acesso rápido pelo nome da chave.

```python
usuario = {
    "nome": "Camila",
    "idade": 28,
    "email": "camila@email.com"
}

print(usuario["nome"])
print(usuario["idade"])
```

Uso comum:

- representar usuários;
- representar produtos;
- armazenar configurações;
- manipular dados de APIs em JSON.

```mermaid
flowchart LR
    Usuario[Usuário] --> Nome["nome" -> "Camila"]
    Usuario --> Idade["idade" -> 28]
    Usuario --> Email["email" -> "camila@email.com"]
```

---

## 7. Matrizes

Matrizes são listas dentro de listas. Organizam dados em linhas e colunas e usam dois índices: `[linha][coluna]`.

```python
matriz = [
    [1, 2],
    [3, 4]
]

print(matriz[1][1])  # 4
```

Exemplo com notas:

```python
notas = [
    [7.5, 8.0, 9.0],
    [6.0, 5.5, 7.0],
    [9.0, 8.5, 10.0]
]

print(notas[1][1])  # segunda prova do segundo aluno: 5.5
```

```mermaid
flowchart TB
    Matriz[Matriz notas] --> L0[Linha 0 - Aluno 1]
    Matriz --> L1[Linha 1 - Aluno 2]
    Matriz --> L2[Linha 2 - Aluno 3]

    L1 --> C0[Coluna 0 - Prova 1: 6.0]
    L1 --> C1[Coluna 1 - Prova 2: 5.5]
    L1 --> C2[Coluna 2 - Prova 3: 7.0]
```

Aplicações:

- cálculos matemáticos;
- tabuleiros de jogos;
- dados tabulares;
- visão computacional, em que imagens podem ser representadas por matrizes de pixels.

---

## 8. Conjuntos

Conjuntos (`set`) não aceitam duplicidade e permitem operações matemáticas.

```python
conjunto = {1, 2, 3, 4}
conjunto.add(4)  # não duplica

print(2 in conjunto)  # True
```

Operações principais:

| Operação | Símbolo | Exemplo |
|---|---|---|
| União | `|` | `a | b` |
| Interseção | `&` | `a & b` |
| Diferença | `-` | `a - b` |

```python
set1 = {1, 2, 3, 4}
set2 = {3, 4, 5, 6}

print(set1 & set2)  # {3, 4}
```

```mermaid
flowchart LR
    A[Set A\n1, 2, 3, 4] --> Inter[Interseção\n3, 4]
    B[Set B\n3, 4, 5, 6] --> Inter
    A --> Uniao[União\n1, 2, 3, 4, 5, 6]
    B --> Uniao
    A --> Dif[Diferença A-B\n1, 2]
```

---

## 9. Filas e pilhas

### Fila - FIFO

Fila segue o princípio **FIFO - First In, First Out**: o primeiro a entrar é o primeiro a sair.

Exemplos:

- fila de banco;
- atendimento em SAC;
- documentos enviados para impressora;
- agendamento de processos.

```python
from collections import deque

fila = deque()
fila.append("Ana")
fila.append("Bruno")
fila.append("Carlos")

print(fila.popleft())  # Ana
```

```mermaid
flowchart LR
    Entrada[Entrada] --> A[Ana]
    A --> B[Bruno]
    B --> C[Carlos]
    C --> Saida[Saída]
    note1[Primeiro que entra\né o primeiro que sai]
```

### Pilha - LIFO

Pilha segue o princípio **LIFO - Last In, First Out**: o último a entrar é o primeiro a sair.

Exemplos:

- pilha de pratos;
- histórico de navegação;
- desfazer ação (`Ctrl+Z`).

```python
pilha = []
pilha.append("abrir arquivo")
pilha.append("editar texto")
pilha.append("salvar")

print(pilha.pop())  # salvar
```

```mermaid
flowchart TB
    Topo[Topo da pilha] --> Item3[Salvar\núltimo a entrar]
    Item3 --> Item2[Editar texto]
    Item2 --> Item1[Abrir arquivo\nprimeiro a entrar]
    Pop[pop remove o topo] --> Item3
```

---

## 10. Hash Table

Hash table é uma estrutura eficiente para busca, inserção e remoção. Em Python, a implementação mais comum é o dicionário (`dict`).

A chave passa por uma função de hash, que gera um índice interno para localizar rapidamente o valor.

```python
agenda = {
    "Ana": "9999-1234",
    "Bruno": "9888-5678",
    "Carlos": "9777-0000"
}

print(agenda["Ana"])
```

```mermaid
flowchart LR
    Chave[Chave: Ana] --> Hash[Função hash]
    Hash --> Indice[Índice interno]
    Indice --> Valor[Valor: 9999-1234]
```

### Ideia para prova

Dicionário é a forma prática de usar hash table em Python.

---

## 11. Busca linear e busca binária

### Busca linear

Percorre item por item até encontrar o alvo.

```python
clientes = ["Ana", "Bruno", "Carlos"]

for cliente in clientes:
    if cliente == "Bruno":
        print("Encontrado")
        break
```

Complexidade: `O(n)`.

### Busca binária

Exige lista ordenada. Divide o espaço de busca pela metade a cada passo.

```python
def busca_binaria(lista, alvo):
    inicio = 0
    fim = len(lista) - 1

    while inicio <= fim:
        meio = (inicio + fim) // 2

        if lista[meio] == alvo:
            return meio
        elif lista[meio] < alvo:
            inicio = meio + 1
        else:
            fim = meio - 1

    return -1

print(busca_binaria([1, 3, 5, 7, 9], 7))
```

Complexidade: `O(log n)`.

```mermaid
flowchart TD
    Inicio([Início]) --> Ordenada{Lista está ordenada?}
    Ordenada -->|Não| Linear[Usar busca linear]
    Ordenada -->|Sim| Meio[Verificar elemento do meio]
    Meio --> Igual{É o alvo?}
    Igual -->|Sim| Achou[Encontrado]
    Igual -->|Não, alvo maior| Direita[Descartar metade esquerda]
    Igual -->|Não, alvo menor| Esquerda[Descartar metade direita]
    Direita --> Meio
    Esquerda --> Meio
```

---

## 12. Algoritmos de ordenação

Ordenar é organizar dados por um critério: nome, data, valor, prioridade etc.

```mermaid
flowchart LR
    Dados[Dados desordenados] --> Criterio[Critério\npreço, nome, data]
    Criterio --> Algoritmo[Algoritmo de ordenação]
    Algoritmo --> Ordenados[Dados ordenados]
```

### Comparativo

| Algoritmo | Estável? | Uso prático |
|---|---:|---|
| TimSort | Sim | Padrão do Python em `sorted()` e `.sort()`. |
| Merge Sort | Sim | Integração e mesclagem de dados. |
| Quick Sort | Não | Alta performance média em listas grandes. |
| Heap Sort | Não | Ordenação por prioridade. |

### Estabilidade

Um algoritmo estável preserva a ordem relativa de elementos equivalentes.

Exemplo: se dois produtos têm o mesmo preço, um algoritmo estável mantém a ordem original entre eles.

---

## 13. TimSort

TimSort é o algoritmo de ordenação usado internamente pelo Python para listas comuns.

```python
produtos = [("Mouse", 50), ("Monitor", 800), ("Teclado", 120)]

ordenados = sorted(produtos, key=lambda p: p[1])
print(ordenados)
```

### Lambda

`lambda` permite definir uma função curta no próprio argumento.

```python
key=lambda p: p[1]
```

Significa: ordene usando o segundo item da tupla, ou seja, o preço.

---

## 14. Merge Sort

Merge Sort divide a lista em partes menores, ordena e depois mescla.

```mermaid
flowchart TD
    Lista[Lista original] --> Divide[Dividir em partes]
    Divide --> Esq[Metade esquerda]
    Divide --> Dir[Metade direita]
    Esq --> OrdenaE[Ordenar esquerda]
    Dir --> OrdenaD[Ordenar direita]
    OrdenaE --> Merge[Mesclar ordenado]
    OrdenaD --> Merge
    Merge --> Final[Lista ordenada]
```

Exemplo simplificado de mesclagem:

```python
def merge(e, d):
    res = []

    while e and d:
        if e[0] < d[0]:
            res.append(e.pop(0))
        else:
            res.append(d.pop(0))

    return res + e + d

print(merge(["Ana", "Carlos"], ["Bruno", "João"]))
```

---

## 15. Quick Sort

Quick Sort escolhe um pivô e separa os elementos em dois grupos.

```python
def quick(lista):
    if len(lista) <= 1:
        return lista

    pivo = lista[0]
    maiores = [x for x in lista[1:] if x > pivo]
    menores_ou_iguais = [x for x in lista[1:] if x <= pivo]

    return quick(maiores) + [pivo] + quick(menores_ou_iguais)

print(quick([450, 120, 880, 300]))
```

```mermaid
flowchart TD
    Lista[Lista] --> Pivo[Escolher pivô]
    Pivo --> Menores[Itens menores ou iguais]
    Pivo --> Maiores[Itens maiores]
    Menores --> Rec1[Ordenar recursivamente]
    Maiores --> Rec2[Ordenar recursivamente]
    Rec1 --> Junta[Juntar resultado]
    Rec2 --> Junta
```

---

## 16. Heap Sort e fila de prioridade

Heap é adequado para cenários onde a prioridade importa.

```python
import heapq

pacientes = [(-82, "Carlos"), (-65, "Maria"), (-29, "João")]
heapq.heapify(pacientes)

print(heapq.heappop(pacientes))  # (-82, 'Carlos')
```

No exemplo, usa-se número negativo porque o `heapq` do Python trabalha como min-heap. Assim, `-82` vem antes de `-65`, representando maior prioridade para paciente mais velho.

---

## 17. APIs REST

API é uma interface de comunicação entre sistemas. REST é um estilo arquitetural muito usado para criar APIs web.

```mermaid
sequenceDiagram
    participant Cliente
    participant API
    participant Servidor
    participant Banco

    Cliente->>API: Requisição HTTP GET /tarefas
    API->>Servidor: Encaminha regra de negócio
    Servidor->>Banco: Consulta dados
    Banco-->>Servidor: Retorna registros
    Servidor-->>API: Monta resposta
    API-->>Cliente: JSON com resultado
```

Conceitos importantes:

- cliente faz requisição;
- servidor processa;
- API expõe endpoints;
- JSON é formato comum de troca;
- HTTP define métodos como GET, POST, PUT e DELETE.

---

## 18. Cloud Computing

Computação em nuvem permite acessar recursos de tecnologia pela internet, sem precisar comprar e manter infraestrutura física própria.

Recursos comuns:

- servidores;
- armazenamento;
- banco de dados;
- redes;
- serviços gerenciados.

```mermaid
flowchart LR
    Usuario[Usuário / Empresa] --> Internet[Internet]
    Internet --> Cloud[Nuvem]
    Cloud --> Compute[Servidores]
    Cloud --> Storage[Armazenamento]
    Cloud --> Database[Bancos de dados]
    Cloud --> Services[Serviços gerenciados]
```

---

## 19. On-premise x Cloud

```mermaid
flowchart TB
    subgraph OnPremise[On-premise]
        OP1[Comprar servidores]
        OP2[Manter sala física]
        OP3[Gerenciar energia e refrigeração]
        OP4[Fazer backup e manutenção]
    end

    subgraph Cloud[Cloud]
        C1[Provisionar recursos pela internet]
        C2[Pagar conforme uso]
        C3[Escalar sob demanda]
        C4[Usar serviços gerenciados]
    end
```

| Modelo | Característica |
|---|---|
| On-premise | Infraestrutura própria, maior responsabilidade operacional. |
| Cloud | Recursos sob demanda, elasticidade e pagamento pelo uso. |

---

## 20. IaaS, PaaS e SaaS

```mermaid
flowchart TB
    SaaS[SaaS\nSoftware pronto para uso\nEx: Gmail, Netflix] --> PaaS[PaaS\nPlataforma para rodar aplicações\nEx: Heroku, App Engine]
    PaaS --> IaaS[IaaS\nInfraestrutura virtual\nEx: EC2, Azure VM]
    IaaS --> Fisico[Data centers, rede, storage, servidores]
```

| Modelo | O que entrega | Exemplo |
|---|---|---|
| IaaS | Máquinas virtuais, rede e armazenamento. | Amazon EC2, Azure VM. |
| PaaS | Plataforma pronta para executar aplicações. | Heroku, Google App Engine. |
| SaaS | Software completo acessado pela internet. | Gmail, Netflix, Canva, Notion. |

---

## 21. Vantagens da nuvem

- Custo sob demanda.
- Escalabilidade automática.
- Flexibilidade.
- Segurança robusta quando bem configurada.
- Acesso global.
- Inovação acelerada.

```mermaid
mindmap
  root((Cloud Computing))
    Benefícios
      Custo sob demanda
      Escalabilidade
      Flexibilidade
      Acesso global
      Inovação
    Cuidados
      Arquitetura
      Segurança
      Backup
      Monitoramento
      Custos
```

---

## 22. Cuidados com cloud

A nuvem facilita o provisionamento de recursos, mas isso também exige controle.

Cuidados principais:

- boa arquitetura;
- controle de custos;
- monitoramento constante;
- backup;
- criptografia;
- gestão de acessos;
- desativação de recursos não utilizados.

```mermaid
flowchart TD
    Criar[Recurso criado na nuvem] --> Usar[Uso da aplicação]
    Usar --> Monitorar[Monitorar custo e disponibilidade]
    Monitorar --> Decisao{Está sendo usado?}
    Decisao -->|Sim| Otimizar[Otimizar escala e segurança]
    Decisao -->|Não| Desligar[Desligar ou remover]
```

---

## 23. Pontos de prova

- Lista é mutável e usa índice iniciado em zero.
- Tupla é imutável.
- Dicionário usa chave-valor.
- Matriz é lista dentro de lista e usa dois índices.
- Set não permite duplicados.
- Fila é FIFO.
- Pilha é LIFO.
- Hash table permite busca rápida por chave; em Python, `dict` é a estrutura prática.
- Busca linear é `O(n)`.
- Busca binária exige lista ordenada e é `O(log n)`.
- TimSort é o padrão de ordenação do Python.
- Merge Sort é estável e útil para mesclar dados.
- Quick Sort é rápido em média, mas não estável.
- Heap é útil para prioridade.
- API REST conecta clientes e servidores por HTTP.
- Cloud reduz necessidade de infraestrutura própria.
- IaaS entrega infraestrutura; PaaS entrega plataforma; SaaS entrega software pronto.
- Em cloud, monitoramento evita surpresa de custo.

---

## 24. Flashcards

| Pergunta | Resposta |
|---|---|
| Qual índice do primeiro item de uma lista Python? | `0`. |
| Lista é mutável? | Sim. |
| Tupla é mutável? | Não. |
| Dicionário armazena dados como? | Pares chave-valor. |
| Matriz usa quantos índices? | Dois: linha e coluna. |
| Set aceita duplicados? | Não. |
| FIFO é qual estrutura? | Fila. |
| LIFO é qual estrutura? | Pilha. |
| Qual estrutura Python representa hash table? | `dict`. |
| Busca binária precisa de lista ordenada? | Sim. |
| Algoritmo padrão de ordenação do Python? | TimSort. |
| Modelo cloud de máquina virtual? | IaaS. |
| Modelo cloud de plataforma pronta para app? | PaaS. |
| Modelo cloud de software pronto? | SaaS. |

---

## 25. Checklist final

- [ ] Sei escolher entre lista, tupla, dicionário e set.
- [ ] Sei explicar FIFO e LIFO.
- [ ] Sei explicar hash table e sua relação com `dict`.
- [ ] Sei diferenciar busca linear e busca binária.
- [ ] Sei comparar TimSort, Merge Sort, Quick Sort e Heap Sort.
- [ ] Sei explicar o que é uma API REST.
- [ ] Sei diferenciar IaaS, PaaS e SaaS.
- [ ] Sei citar vantagens e cuidados da cloud computing.
