# Matriz de rastreabilidade do material

Esta matriz indica quais páginas dos arquivos-fonte sustentam cada capítulo da documentação. A numeração considera a página do PDF, incluindo capa.

| Documento desta documentação | E-book principal | Slides principais | Observações |
|---|---|---|---|
| [01 — Introdução à Arquitetura](01-introducao-arquitetura-software.md) | Aula 1, p. 2–12 e 17–19 | Aula 1, p. 8–32 e 44–49 | Motivação, comunicação, conceitos, execução, monitoramento e requisitos |
| [02 — Fundamentos, Ciclo de Vida e Escalabilidade](02-fundamentos-design-ciclo-vida.md) | Aula 1, p. 12–16 | Aula 1, p. 31–42 | Paradigmas, SDLC, CI/CD, escopo, dependência, acoplamento, coesão e escala |
| [03 — Padrões Arquiteturais](03-padroes-arquiteturais.md) | Aula 1, p. 20–26; Aula 2, p. 2–6 | Aula 2, p. 6–25 | Conceito de padrão, monólito, MVC, microsserviços, eventos, SOA e estudo hospitalar |
| [04 — Domain-Driven Design](04-domain-driven-design.md) | Aula 2, p. 7–15 | Aula 2, p. 27–52 | Domínio, modelo, contextos, building blocks, camadas e estudo do Poupatempo |
| [05 — Clean Architecture](05-clean-architecture.md) | Aula 2, p. 16–18 | Aula 2, p. 54–68 | Regra de dependência e quatro camadas |
| [06 — Documentação Arquitetural](06-documentacao-arquitetural.md) | Aula 2, p. 19–23 | Aula 2, p. 69–89 | ADR, C4, UML, arc42 e riscos de frameworks |
| [07 — Princípios de Design](07-principios-design.md) | Aula 3, p. 2–13 | Aula 3, p. 6–24 | SOLID, DRY, KISS, YAGNI, nomes e exercícios |
| [08 — Design Patterns](08-design-patterns.md) | Aula 3, p. 14–24 | Aula 3, p. 25–48 | GoF, categorias e padrões abordados |
| [09 — Testes e Papel do Arquiteto](09-testes-papel-arquiteto.md) | Aula 3, p. 25–31 | Aula 3, p. 49–84 | Testes, pirâmide, TDD, BDD, ATDD, carreira e IA |
| [10 — Revisão para a Prova](10-revisao-prova.md) | Síntese dos três e-books | Síntese dos três conjuntos de slides | Questões e diagramas de consolidação |

## Critérios de fidelidade

- A terminologia principal segue os materiais da disciplina.
- Diagramas Mermaid são reconstruções didáticas dos conceitos e figuras.
- Exemplos de código são identificados como elaboração didática quando não são transcrições do slide.
- Conteúdo não apresentado em profundidade no material não é transformado em requisito de prova.
- Divergências internas são registradas, em vez de corrigidas silenciosamente.

## Divergências observadas

### Taxa de sucesso de projetos menores que US$ 1 milhão

- Aula 1 — slides, página 14: **76%** bem-sucedidos.
- Aula 1 — e-book, página 6: o texto menciona **70%**.

### Exercícios de Design Patterns

Os cenários de linha automotiva e métodos de pagamento são apresentados como perguntas, mas o e-book não traz gabarito textual. As interpretações no capítulo 8 estão marcadas como inferências didáticas.

### Simplificações conceituais

Os materiais possuem finalidade introdutória. Por isso, temas como consistência distribuída, semântica de eventos, níveis de testes, DDD estratégico e detalhes do C4 são resumidos. A documentação mantém o escopo da disciplina e identifica complementos didáticos.
