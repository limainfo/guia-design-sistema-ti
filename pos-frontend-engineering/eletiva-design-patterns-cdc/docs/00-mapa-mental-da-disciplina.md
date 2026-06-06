# 00 - Mapa Mental da Disciplina

## Ideia central

A disciplina conecta três assuntos:

1. **Design Patterns**: soluções conceituais reutilizáveis para problemas recorrentes de design de software.
2. **Anti-patterns**: soluções aparentes que parecem resolver no curto prazo, mas degradam manutenção, testabilidade e evolução.
3. **CDC / Contract-Driven Design**: abordagem em que o contrato vem antes do código e orienta implementação, testes, integração e evolução arquitetural.

## Mapa geral

```mermaid
mindmap
  root((Design Patterns / CDC))
    Design Patterns
      Criacionais
        Singleton
        Factory Method
        Abstract Factory
        Builder
        Prototype
      Estruturais
        Adapter
        Facade
        Decorator
        Composite
        Proxy
        Bridge
        Flyweight
      Comportamentais
        Strategy
        Observer
        Command
        Chain of Responsibility
        State
        Template Method
        Iterator
        Mediator
        Memento
        Visitor
        Interpreter
    Anti-patterns
      God Object
      Spaghetti Code
      Lava Flow
      Big Ball of Mud
      Overengineering
    CDC
      Contrato antes do código
      Pré-condições
      Pós-condições
      Invariantes
      API First
      Testes de contrato
      Mocks e stubs
      Evolução segura
    Laboratório
      Almoxarifado
      Contrato 1 frágil
      Contrato 2 estruturado
      Contrato 3 evoluído
```

## Três perguntas que resumem a disciplina

| Pergunta | Tema relacionado | Exemplo |
|---|---|---|
| Como crio objetos sem acoplar tudo? | Padrões criacionais | Factory, Builder, Singleton |
| Como organizo classes e integrações? | Padrões estruturais | Adapter, Facade, Repository |
| Como objetos se comunicam e variam comportamento? | Padrões comportamentais | Strategy, Observer, Command |
| Como garanto que módulos não quebrem entre si? | CDC | OpenAPI, interfaces, eventos, Pact |
| Como evito código que cresce sem controle? | Anti-patterns | God Object, Spaghetti Code, Big Ball of Mud |

## Linha de raciocínio para prova

```mermaid
flowchart TD
    A[Identificar a dor do código] --> B{A dor é de criação?}
    B -->|Sim| C[Usar padrões criacionais]
    B -->|Não| D{A dor é de estrutura?}
    D -->|Sim| E[Usar padrões estruturais]
    D -->|Não| F{A dor é de comportamento?}
    F -->|Sim| G[Usar padrões comportamentais]
    F -->|Não| H[Não force pattern]
    C --> I[Validar se reduziu complexidade]
    E --> I
    G --> I
    H --> I
    I --> J{Contrato está claro?}
    J -->|Sim| K[Implementar e testar]
    J -->|Não| L[Definir entradas, saídas, erros e invariantes]
    L --> K
```

## Frase-chave

> Design Patterns não são objetivo. São consequência de uma dor real de design. CDC ajuda a explicitar essa dor antes do código.
