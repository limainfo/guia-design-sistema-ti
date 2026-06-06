# Design Patterns/CDC - Guia de Revisão para Prova

Material de estudo em português, organizado para consulta no GitHub, a partir dos e-books e slides das Aulas 1, 2 e 3 da disciplina **Design Patterns/CDC**.

> Objetivo: revisar rapidamente conceitos, identificar quando usar cada padrão, entender contratos de software e aplicar CDC em um exemplo prático de almoxarifado.

## Roteiro de estudo recomendado

1. Leia o resumo executivo em `docs/00-mapa-mental-da-disciplina.md`.
2. Estude os fundamentos e a taxonomia dos padrões em `docs/01-fundamentos-design-patterns.md`.
3. Revise anti-patterns e critérios de escolha em `docs/02-anti-patterns-e-escolha-consciente.md`.
4. Estude contratos, CDC, TDD e API-first em `docs/03-contratos-e-cdc.md`.
5. Feche com o laboratório em `docs/04-laboratorio-almoxarifado.md`.
6. Resolva as questões em `exercicios/questoes-revisao.md`.

## Estrutura

```text
.
├── README.md
├── docs
│   ├── 00-mapa-mental-da-disciplina.md
│   ├── 01-fundamentos-design-patterns.md
│   ├── 02-anti-patterns-e-escolha-consciente.md
│   ├── 03-contratos-e-cdc.md
│   ├── 04-laboratorio-almoxarifado.md
│   ├── 05-resumo-para-prova.md
│   └── diagramas
│       ├── 01-taxonomia-design-patterns.mmd
│       ├── 02-decisao-pattern.mmd
│       ├── 03-cdc-fluxo.mmd
│       └── 04-almoxarifado-arquitetura.mmd
└── exercicios
    └── questoes-revisao.md
```

## Observação importante sobre a sigla CDC

No material da disciplina, a sigla **CDC** é usada principalmente como **Contract-Driven Design**, isto é, desenvolvimento orientado por contratos. Em alguns pontos, especialmente quando aparecem Pact e microserviços, também surge a ideia de **Consumer-Driven Contracts**, que é uma forma específica de teste/validação de contrato em que o consumidor declara o que espera do provedor.

Para a prova, mantenha esta distinção:

- **Contract-Driven Design**: abordagem ampla. Primeiro define-se o contrato, depois o código.
- **Consumer-Driven Contracts**: prática/técnica de contrato, comum em microsserviços, onde consumidores definem expectativas e provedores validam se as cumprem.

## Como visualizar os diagramas Mermaid no GitHub

O GitHub renderiza blocos Mermaid diretamente em arquivos Markdown. Os arquivos `.mmd` em `docs/diagramas` também podem ser abertos por extensões como **Markdown Preview Mermaid Support** no VS Code.
