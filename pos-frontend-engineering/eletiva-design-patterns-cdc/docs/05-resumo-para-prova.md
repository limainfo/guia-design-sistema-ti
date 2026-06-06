# 05 - Resumo para Prova

## Definições essenciais

**Design Pattern**: solução conceitual, testada e reutilizável para problema recorrente de design de software.

**Anti-pattern**: solução comum que parece resolver, mas cria problemas de manutenção, acoplamento e evolução.

**Contrato**: acordo explícito sobre entradas, saídas, comportamentos, erros e invariantes.

**CDC / Contract-Driven Design**: abordagem em que o contrato vem antes da implementação e orienta design, testes e integração.

## Diferença entre famílias de patterns

| Família | Pergunta | Exemplos |
|---|---|---|
| Criacional | Como criar objetos? | Singleton, Factory, Builder |
| Estrutural | Como organizar objetos/classes? | Adapter, Facade, Composite |
| Comportamental | Como objetos cooperam? | Strategy, Observer, Command |

## Quando usar cada pattern

| Situação | Pattern mais provável |
|---|---|
| Uma única instância global obrigatória | Singleton |
| Muitos tipos concretos criados com `new` | Factory Method |
| Família de objetos compatíveis | Abstract Factory |
| Objeto com muitos parâmetros opcionais | Builder |
| Precisa clonar objeto complexo | Prototype |
| API externa incompatível | Adapter |
| Subsistema complexo exposto ao cliente | Facade |
| Adicionar comportamento sem alterar classe original | Decorator |
| Tratar item e grupo de forma igual | Composite |
| Controlar acesso/cache/log | Proxy |
| Evitar explosão de subclasses por combinação | Bridge |
| Muitos objetos repetidos consomem memória | Flyweight |
| Muitos if/else de algoritmos | Strategy |
| Um evento deve avisar vários objetos | Observer |
| Ação precisa ser enfileirada, logada ou desfeita | Command |
| Validações em cadeia | Chain of Responsibility |
| Objeto muda comportamento por status | State |
| Fluxo fixo com etapas variáveis | Template Method |
| Percorrer coleção sem expor estrutura | Iterator |
| Muitos objetos conversando entre si | Mediator |
| Salvar/restaurar estado | Memento |
| Nova operação sobre hierarquia existente | Visitor |
| Interpretar regra/linguagem simples | Interpreter |

## Anti-patterns

| Anti-pattern | Ideia | Risco |
|---|---|---|
| God Object | Classe faz tudo | Viola SRP, difícil testar |
| Spaghetti Code | Fluxo confuso e emaranhado | Bugs e regressões |
| Lava Flow | Código morto mantido por medo | Complexidade acidental |
| Big Ball of Mud | Sistema sem arquitetura | Evolução quase impossível |

## CDC em uma frase

> Primeiro vem o contrato. Depois vem o código.

## Contrato responde a quatro perguntas

1. O que faz?
2. O que precisa receber?
3. O que garante devolver?
4. O que nunca pode quebrar?

## CDC x TDD x API-first

| Conceito | Foco |
|---|---|
| TDD | Comportamento interno do método/classe |
| CDC | Fronteira entre componentes/sistemas |
| API-first | Definição prévia da API externa |

## Padrões e princípios SOLID

| Princípio | Relação com patterns |
|---|---|
| SRP | Evita God Object; favorece classes coesas |
| OCP | Strategy, Factory e State evitam modificar o core a cada regra |
| LSP | Subtipos devem cumprir o mesmo contrato |
| ISP | Interfaces pequenas e específicas reduzem acoplamento |
| DIP | Depender de abstrações favorece Repository, Adapter e Service Layer |

## Pegadinhas comuns de prova

- Design Pattern não é código pronto para copiar.
- Singleton não deve ser usado como variável global disfarçada.
- Strategy resolve variação de algoritmo, não criação de objeto.
- Factory resolve criação, não comportamento dinâmico.
- Adapter integra interfaces incompatíveis; Facade simplifica um subsistema.
- Decorator adiciona comportamento dinamicamente; herança não é a única forma de extensão.
- Observer notifica vários interessados; Command encapsula uma ação.
- CDC não é apenas Swagger/OpenAPI; ele também vale para interfaces, eventos e schemas.
- API-first é um caso de CDC, mas CDC é mais amplo.
- Patterns devem emergir da dor real, não ser impostos.
