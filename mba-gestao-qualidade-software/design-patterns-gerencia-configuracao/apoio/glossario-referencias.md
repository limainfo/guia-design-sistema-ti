# Glossário, Fontes e Notas Técnicas

[← Início](../README.md)

## Glossário técnico

| Termo | Significado no contexto da disciplina |
|---|---|
| **Adapter** | Padrão estrutural que adapta uma interface a outra esperada pelo cliente. |
| **ADR** | *Architecture Decision Record*; registro sucinto de uma decisão de arquitetura e sua justificativa. |
| **Artefato** | Código, pacote, documento, script, configuração ou outro produto controlado do desenvolvimento. |
| **Baseline** | Estado de referência identificado para controle de mudanças e comparação. |
| **Branch** | Referência a uma linha de evolução do histórico Git. |
| **CI** | *Continuous Integration*: integração frequente com validações automáticas. |
| **CD** | *Continuous Delivery* ou *Continuous Deployment*, conforme contexto: práticas de preparação contínua ou implantação automatizada. |
| **Cherry-pick** | Reaplicação de mudança originada em um commit selecionado. |
| **Commit** | Registro de um estado do projeto, associado a metadados e identidade. |
| **Decorator** | Padrão estrutural que agrega comportamentos por composição. |
| **DIP** | Princípio da inversão de dependência: políticas dependem de abstrações. |
| **Factory Method** | Padrão criacional que delega às subclasses a definição do produto concreto. |
| **GCS** | Gerência de Configuração de Software. |
| **Git Flow** | Estratégia de branching com linhas de desenvolvimento, releases e hotfixes. |
| **GitHub Flow** | Estratégia simplificada de branch principal e branches curtas integradas por PR. |
| **GoF** | *Gang of Four*, autores do catálogo clássico de 23 padrões orientados a objetos. |
| **Issue/Ticket** | Registro de necessidade, defeito, tarefa ou solicitação de alteração. |
| **LSP** | Princípio de substituição de Liskov: subtipos preservam contratos de comportamento. |
| **Merge** | Integração de históricos de desenvolvimento. |
| **OCP** | Princípio aberto/fechado: favorecer extensão sem alterar continuamente partes estáveis. |
| **Observer** | Padrão comportamental para notificar assinantes de alterações/eventos. |
| **Pull Request** | Proposta revisável para integrar alterações de uma branch em outra; *merge request* em plataformas com outra nomenclatura. |
| **Rebase** | Reaplicação de commits sobre uma base diferente. |
| **Release** | Versão liberada de um produto para determinado público ou ambiente. |
| **Revert** | Operação que cria commit para reverter o efeito de mudança anterior. |
| **Singleton** | Padrão criacional para controle de uma instância por escopo apropriado. |
| **SOLID** | Cinco princípios de projeto orientado a objetos: SRP, OCP, LSP, ISP e DIP. |
| **SRP** | Princípio da responsabilidade única: uma razão principal para mudar. |
| **Strategy** | Padrão comportamental que encapsula algoritmos intercambiáveis. |
| **SVN** | Subversion, sistema de controle de versão centralizado. |
| **Tag** | Referência nomeada para determinado ponto no histórico. |
| **Trunk-Based** | Estratégia de integração frequente em uma linha principal com branches curtas. |

## Inventário das fontes fornecidas

| Arquivo PDF | Tratamento nesta documentação |
|---|---|
| `ebook-00.pdf` | Visão geral e organização dos quatro temas. |
| `ebook-01.pdf` | Tema 01: origem GoF, tipos, SOLID, Singleton, exemplos e boas práticas. |
| `slides-01.pdf` | Tema 01: quatro blocos didáticos e estudo de caso de pedidos. |
| `ebook-02.pdf` | Tema 02: pilares de GCS, processos, CI e aplicação. |
| `slides-02.pdf` | Tema 02: padronização, auditoria e estudo de caso com microsserviços. |
| `ebook-03.pdf` | Tema 03: Git e SVN, estratégias Git, ferramentas e automação. |
| `slides-03.pdf` | Tema 03: Git Flow, Trunk-Based, comandos e caso multiplataforma. |
| `ebook-04.pdf` | Tema 04: adoção conjunta, fluxo de mudanças e boas práticas. |
| `slides-04.pdf` | Tema 04: aplicação em pipelines, microsserviços e miniprojeto. |
| `podcast-tema-01.pdf` | Exemplos de e-commerce, Strategy, Observer, Adapter e GCS. |
| `podcast-tema-02.pdf` | Seis exercícios com gabarito sobre GoF, SOLID, Git e GCS. |

### Reconstrução das principais figuras acadêmicas

| Figura da fonte | Diagrama equivalente nesta documentação |
|---|---|
| `ebook-01.pdf`, Figura 1 — Diagrama UML Singleton | Tema 01, seção 4: `classDiagram` do Singleton. |
| `ebook-02.pdf`, Figura 1 — Fluxo de integração contínua | Tema 02, seção 5: `flowchart` de CI. |
| `ebook-04.pdf`, Figura 1 — Fluxo de trabalho | Tema 04, seção 4.4: `flowchart` de pattern, branch, PR, CI e release. |
| `slides-01.pdf`, diagrama Singleton | Tema 01, seção 4. |
| `slides-02.pdf`, fluxo de CI | Tema 02, seção 5. |
| `slides-04.pdf`, fluxo de trabalho integrado | Tema 04, seção 4.4. |

Os diagramas adicionais do repositório (classificações GoF, ciclo GCS, Git versus SVN, fluxo de Git, decisão de patterns e ADR) são **modelos autorais complementares** para reforço didático.

## Referências bibliográficas de estudo

As obras abaixo são referências de aprofundamento citadas ou pertinentes ao conjunto de materiais, não fontes externas verificadas em tempo real:

- **Gamma, Erich; Helm, Richard; Johnson, Ralph; Vlissides, John.** *Design Patterns: Elements of Reusable Object-Oriented Software*. Addison-Wesley, edição original de 1994; existem reimpressões e edições posteriores.
- **Freeman, Eric; Robson, Elisabeth.** *Head First Design Patterns*. 2. ed. O'Reilly, 2020.
- **Chacon, Scott; Straub, Ben.** *Pro Git*. Apress, 2. ed., 2014; disponibilizado também em formato online.
- **Sommerville, Ian.** *Software Engineering* (Engenharia de Software).
- **Pressman, Roger; Maxim, Bruce.** *Software Engineering: A Practitioner's Approach* (Engenharia de Software: uma abordagem profissional).

## Fontes técnicas oficiais consultadas em 19/10/2026

- [actions/checkout (GitHub)](https://github.com/actions/checkout): exemplo atualizado de `actions/checkout@v7`.
- [actions/setup-java (GitHub)](https://github.com/actions/setup-java): exemplo atualizado de `actions/setup-java@v6`.
- [Mermaid — GitGraph](https://mermaid.js.org/syntax/gitgraph): sintaxe de branches, commits e merges do diagrama de Git Flow.

## Esclarecimentos e atualização técnica

1. **A fábrica simples é diferente do Factory Method GoF.** Exemplo didático com `criarPedido(tipo)` é útil, mas não exige sobrescrita em subclasses.
2. **Lint não comprova conformidade SOLID.** Regras automatizadas podem apoiar a análise, porém não a substituem.
3. **Singleton depende do escopo de execução.** Não é mecanismo de unicidade distribuída.
4. **Integração contínua não equivale a implantação contínua.** Preparar, aprovar e entregar releases são etapas distintas.
5. **Git suporta rastreabilidade, mas não substitui a governança de mudanças.** Builds, aprovações, inventário de artefatos e deploy devem ser correlacionados.
6. **Trunk-Based e GitHub Flow são alternativas legítimas ao Git Flow.** A seleção não pode ser feita somente pela popularidade do nome.
7. **Tags marcam código; não são garantia de reversão operacional.** Dados, configurações, dependências e artefatos de implantação também importam.
8. **Percentuais genéricos de ganho de produtividade** presentes em apresentações foram intencionalmente omitidos como evidência quantitativa, por não haver base metodológica demonstrada nos documentos fornecidos.

[← Início](../README.md)
