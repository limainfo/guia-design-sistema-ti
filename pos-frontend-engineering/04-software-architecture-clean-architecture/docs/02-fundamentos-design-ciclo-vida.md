# 2. Fundamentos de Design, Ciclo de Vida e Escalabilidade

## Objetivos de aprendizagem

Ao concluir este capítulo, você deverá ser capaz de:

- diferenciar os paradigmas procedural, orientado a objetos e funcional;
- explicar o ciclo contínuo de desenvolvimento de software;
- relacionar CI/CD a uma esteira de produção automatizada;
- aplicar os conceitos de escopo, encapsulamento, dependência e inversão de dependência;
- avaliar acoplamento, coesão e granularidade;
- distinguir escalabilidade vertical e horizontal.

## 2.1 Paradigmas de programação

Um paradigma de programação oferece uma forma de organizar o raciocínio e expressar soluções. A disciplina destaca três paradigmas.

```mermaid
flowchart LR
    P[Paradigmas]
    P --> PR[Procedural]
    P --> OO[Orientado a objetos]
    P --> F[Funcional]

    PR --> PR1[Procedimentos e funções]
    PR --> PR2[Variáveis e fluxo de controle]

    OO --> OO1[Classes e objetos]
    OO --> OO2[Encapsulamento]
    OO --> OO3[Herança e polimorfismo]
    OO --> OO4[Abstração]

    F --> F1[Funções como elemento central]
    F --> F2[Funções puras]
    F --> F3[Imutabilidade]
    F --> F4[Composição]
```

### Paradigma procedural

Organiza o programa como uma sequência de instruções, procedimentos e funções. O material cita COBOL e C e lembra que comandos como `goto` dificultam manutenção, pois quebram o fluxo estruturado e aumentam o risco de efeitos inesperados.

### Paradigma orientado a objetos

Acrescenta semântica por meio de classes e objetos.

- **Encapsulamento:** protege detalhes internos.
- **Herança:** permite compartilhar características entre classes.
- **Polimorfismo:** possibilita comportamentos diferentes por meio de um contrato comum.
- **Abstração:** representa apenas o que é relevante para o problema.

### Paradigma funcional

Coloca a função no centro da solução e é relacionado no material a cenários de computação distribuída.

- **Função pura:** mesma entrada produz a mesma saída.
- **Imutabilidade:** evita alteração de estado já criado.
- **Composição:** combina funções menores em fluxos maiores.

> [!IMPORTANT]
> Paradigmas não são estilos arquiteturais. Eles influenciam como o código é estruturado, enquanto estilos arquiteturais organizam o sistema em nível mais amplo.

## 2.2 Ciclo de vida do desenvolvimento de software

O software não é apenas escrito uma vez. Ele nasce de uma necessidade, passa por construção, validação, implantação, manutenção e evolução.

```mermaid
flowchart LR
    A[Requisitos] --> B[Análise e design]
    B --> C[Implementação]
    C --> D[Testes]
    D --> E[Implantação]
    E --> F[Operação e monitoramento]
    F --> G[Feedback e evolução]
    G --> A
```

O material menciona diferentes abordagens para organizar esse ciclo:

- Waterfall;
- prototipação;
- incremental;
- metodologias ágeis.

A diferença está em como as etapas são ordenadas, repetidas e validadas. O ciclo, entretanto, continua enquanto o sistema existir.

## 2.3 CI/CD como linha de produção

A disciplina descreve Continuous Integration e Continuous Deployment como uma esteira de produção na qual etapas são automatizadas para entregar alterações de forma contínua e fluida.

```mermaid
flowchart LR
    A[Commit] --> B[Build]
    B --> C[Testes automatizados]
    C --> D[Análise de qualidade]
    D --> E[Empacotamento]
    E --> F[Deploy em ambiente]
    F --> G[Monitoramento]

    C -- falha --> H[Correção]
    D -- falha --> H
    F -- falha --> H
    H --> A
```

### Integração contínua

Alterações são integradas frequentemente e verificadas por build e testes automatizados.

### Entrega ou implantação contínua

O software validado avança pela esteira até ambientes de teste ou produção, de acordo com a política da organização.

> [!TIP]
> A arquitetura precisa favorecer automação. Um sistema que exige muitos passos manuais, dependências implícitas ou configurações não versionadas dificulta CI/CD.

## 2.4 Escopo e encapsulamento

Escopo é a abrangência em que um elemento pode ser acessado. Na arquitetura, isso se relaciona ao que um componente revela e ao que esconde.

O exemplo da aula usa uma conta corrente cujo saldo não deve ser alterado diretamente.

```java
public final class ContaCorrente {
    private BigDecimal saldo;

    public ContaCorrente(BigDecimal saldoInicial) {
        if (saldoInicial.signum() < 0) {
            throw new IllegalArgumentException("Saldo inicial inválido");
        }
        this.saldo = saldoInicial;
    }

    public void depositar(BigDecimal valor) {
        validarValorPositivo(valor);
        saldo = saldo.add(valor);
    }

    public void sacar(BigDecimal valor) {
        validarValorPositivo(valor);
        if (saldo.compareTo(valor) < 0) {
            throw new IllegalStateException("Saldo insuficiente");
        }
        saldo = saldo.subtract(valor);
    }

    public BigDecimal consultarSaldo() {
        return saldo;
    }

    private static void validarValorPositivo(BigDecimal valor) {
        if (valor == null || valor.signum() <= 0) {
            throw new IllegalArgumentException("O valor deve ser positivo");
        }
    }
}
```

> [!NOTE]
> O código é uma elaboração didática baseada no exemplo da aula. A ideia central do material é que o saldo permaneça protegido e só seja modificado por operações que preservem as regras.

```mermaid
classDiagram
    class ContaCorrente {
      -BigDecimal saldo
      +depositar(valor)
      +sacar(valor)
      +consultarSaldo() BigDecimal
      -validarValorPositivo(valor)
    }
```

Encapsular não significa apenas declarar atributos privados. Significa proteger invariantes e expor operações coerentes com o domínio.

## 2.5 Dependência

Um componente depende de outro quando precisa dele para cumprir sua responsabilidade.

```mermaid
flowchart LR
    P[PedidoService] --> R[PedidoRepository]
    P --> G[GatewayPagamento]
    P --> N[Notificador]
```

Ao modificar um componente, é necessário conhecer quem depende dele. Caso contrário, uma alteração aparentemente local pode provocar efeitos em cascata.

### Dependência direta e rigidez

```mermaid
classDiagram
    class RelatorioService
    class MySqlDatabase
    RelatorioService --> MySqlDatabase : instancia diretamente
```

Quando um módulo de alto nível conhece uma implementação específica, trocar essa implementação exige alterar o módulo consumidor.

## 2.6 Inversão de dependência

A aula usa o exemplo de um botão que não deveria conhecer diretamente uma lâmpada. O botão deveria depender de um contrato que pudesse ser implementado por diferentes dispositivos.

```mermaid
classDiagram
    class Acionavel {
      <<interface>>
      +acionar()
    }

    class Botao {
      -Acionavel dispositivo
      +pressionar()
    }

    class Lampada {
      +acionar()
    }

    class Ventilador {
      +acionar()
    }

    Botao --> Acionavel
    Acionavel <|.. Lampada
    Acionavel <|.. Ventilador
```

```java
public interface Acionavel {
    void acionar();
}

public final class Botao {
    private final Acionavel dispositivo;

    public Botao(Acionavel dispositivo) {
        this.dispositivo = Objects.requireNonNull(dispositivo);
    }

    public void pressionar() {
        dispositivo.acionar();
    }
}
```

O módulo de alto nível depende da abstração. A implementação concreta é fornecida externamente.

```mermaid
flowchart LR
    A[Sem inversão] --> B[Botão depende da lâmpada]
    B --> C[Troca exige modificar o botão]

    D[Com inversão] --> E[Botão depende de interface]
    E --> F[Lâmpada ou outro dispositivo implementa o contrato]
    F --> G[Troca preserva o botão]
```

## 2.7 Acoplamento e desacoplamento

Acoplamento expressa quanto um componente depende de outros.

- **Alto acoplamento:** muitas dependências, conhecimento de detalhes e mudanças em cascata.
- **Baixo acoplamento:** contratos claros, poucas dependências e maior substituibilidade.

```mermaid
flowchart TB
    subgraph AC[Alto acoplamento]
      A1[A] <--> B1[B]
      A1 <--> C1[C]
      B1 <--> C1
      B1 <--> D1[D]
      C1 <--> D1
    end

    subgraph BC[Baixo acoplamento]
      G[Gateway/Contrato]
      A2[A] --> G
      B2[B] --> G
      C2[C] --> G
      G --> D2[D]
    end
```

> [!WARNING]
> Desacoplamento não significa ausência de comunicação. Um sistema sem dependências úteis não realiza trabalho. O objetivo é controlar dependências e impedir que detalhes se espalhem.

## 2.8 Coesão

Coesão é o grau em que os elementos de um módulo trabalham para uma finalidade comum.

```mermaid
flowchart LR
    subgraph Baixa[Baixa coesão]
      X[Classe Utilidades]
      X --> X1[calcularFrete]
      X --> X2[gerarPDF]
      X --> X3[validarSenha]
      X --> X4[conectarBanco]
    end

    subgraph Alta[Alta coesão]
      Y[CalculadoraFrete]
      Y --> Y1[calcularPorPeso]
      Y --> Y2[calcularPorDistância]
      Y --> Y3[aplicarSeguro]
    end
```

Baixa coesão indica que responsabilidades sem relação foram agrupadas. Alta coesão indica que o componente possui um propósito reconhecível.

### Relação desejada

```mermaid
quadrantChart
    title Coesão e acoplamento
    x-axis Alto acoplamento --> Baixo acoplamento
    y-axis Baixa coesão --> Alta coesão
    quadrant-1 Arquitetura desejada
    quadrant-2 Coeso, porém rígido
    quadrant-3 Difícil de entender e mudar
    quadrant-4 Fragmentado sem propósito
    Módulo de domínio bem isolado: [0.84, 0.88]
    Classe utilitária gigante: [0.18, 0.14]
    Serviço centralizador: [0.22, 0.70]
```

O objetivo destacado na disciplina é **baixo acoplamento e alta coesão**.

## 2.9 Granularidade

Granularidade representa o nível de detalhe ou o tamanho das responsabilidades atribuídas a componentes.

```mermaid
flowchart LR
    G[Granularidade]
    G --> F[Fina<br/>muitos componentes pequenos]
    G --> R[Grossa<br/>poucos componentes grandes]

    F --> F1[Responsabilidades específicas]
    F --> F2[Mais comunicação e coordenação]

    R --> R1[Menor quantidade de limites]
    R --> R2[Mais responsabilidades por componente]
```

### Granularidade fina

- componentes menores;
- responsabilidades específicas;
- potencial de implantação e escala independentes;
- maior custo de coordenação.

### Granularidade grossa

- componentes maiores;
- mais funcionalidades agrupadas;
- menor complexidade de distribuição;
- maior risco de baixa coesão e impacto amplo de mudanças.

> [!IMPORTANT]
> Não existe uma granularidade correta de forma universal. Dividir demais cria complexidade distribuída; agrupar demais cria rigidez.

## 2.10 Escalabilidade

Escalabilidade é a capacidade de aumentar ou reduzir recursos para suportar variações de carga sem degradação incompatível com os requisitos.

### Escalabilidade vertical

Aumenta os recursos de uma única máquina.

```mermaid
flowchart LR
    A[Servidor<br/>4 CPU / 8 GB] --> B[Servidor maior<br/>16 CPU / 64 GB]
```

Vantagens:

- implementação geralmente mais simples;
- não exige necessariamente distribuição da aplicação.

Limitações:

- limite físico e financeiro;
- possibilidade de ponto único de falha;
- manutenção pode exigir interrupção.

### Escalabilidade horizontal

Adiciona máquinas ou instâncias para dividir o trabalho.

```mermaid
flowchart LR
    C[Clientes] --> LB[Balanceador]
    LB --> S1[Instância 1]
    LB --> S2[Instância 2]
    LB --> S3[Instância 3]
```

Vantagens:

- crescimento por adição de nós;
- maior potencial de disponibilidade;
- boa aderência a ambientes de nuvem.

Desafios:

- distribuição de estado;
- comunicação de rede;
- consistência;
- observabilidade e coordenação.

### Comparação

| Critério | Vertical | Horizontal |
|---|---|---|
| Ação principal | Aumentar máquina | Adicionar máquinas |
| Complexidade inicial | Menor | Maior |
| Limite de crescimento | Físico/financeiro | Potencialmente muito maior |
| Distribuição | Não é obrigatória | É parte central |
| Tolerância a falhas | Pode continuar centralizada | Pode ser distribuída |

## 2.11 Como os conceitos se conectam

```mermaid
flowchart TD
    A[Requisitos] --> B[Design]
    B --> C[Escopo e encapsulamento]
    B --> D[Dependências]
    B --> E[Granularidade]

    D --> F[Acoplamento]
    C --> G[Coesão]
    E --> F
    E --> G

    F --> H[Manutenibilidade]
    G --> H
    E --> I[Escalabilidade]
    D --> I

    H --> J[Evolução contínua]
    I --> J
    J --> K[CI/CD e operação]
```

## 2.12 Síntese para a prova

- O paradigma procedural organiza instruções e funções; orientação a objetos acrescenta classes, encapsulamento, herança, polimorfismo e abstração; funcional enfatiza funções puras, imutabilidade e composição.
- O ciclo de vida é contínuo e inclui requisitos, design, implementação, testes, implantação, operação e evolução.
- CI/CD automatiza a integração e a entrega/implantação.
- Escopo e encapsulamento determinam o que é visível e o que deve permanecer protegido.
- Dependência deve ser conhecida; inversão de dependência faz módulos dependerem de abstrações.
- A meta arquitetural apresentada é baixo acoplamento e alta coesão.
- Granularidade fina cria componentes menores e mais coordenação; grossa agrupa mais responsabilidades.
- Escala vertical aumenta recursos de uma máquina; horizontal adiciona máquinas.

## Questões de revisão

1. Qual é a diferença entre paradigma de programação e estilo arquitetural?
2. Por que o ciclo de vida do software não termina após o primeiro deploy?
3. Como CI/CD reduz risco de integração?
4. Qual a relação entre escopo e encapsulamento?
5. Por que dependência direta de uma implementação aumenta rigidez?
6. Como inversão de dependência reduz impacto de troca tecnológica?
7. Diferencie acoplamento, coesão e granularidade.
8. Em que cenário a escala horizontal é preferível à vertical?

## Referência no material da disciplina

- Aula 1 — e-book, partes 2 a 4;
- Aula 1 — slides, páginas sobre paradigmas, ciclo de vida, CI/CD, escopo, dependência, inversão, acoplamento, granularidade, coesão e escalabilidade.
