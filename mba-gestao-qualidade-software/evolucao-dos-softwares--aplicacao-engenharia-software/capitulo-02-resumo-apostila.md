# Resumo técnico — Engenharia de Software em aplicativos móveis e aplicações Web

## 1. Visão geral

Aplicativos móveis e aplicações web são tratados como **sistemas emergentes**, pois surgem em um contexto de internet massificada, computação distribuída, mobilidade, integração entre serviços e necessidade de rápida adaptação às demandas do mercado. A consequência direta disso é que sua implementação não pode depender apenas de codificação: ela exige métodos, processos, ferramentas e práticas formais de Engenharia de Software. 

O ponto central do material é que, embora app móvel e aplicação web tenham diferenças técnicas importantes, ambos exigem:

* levantamento rigoroso de requisitos;
* modelagem adequada;
* definição arquitetural;
* escolhas conscientes de tecnologia;
* validação e testes;
* manutenção contínua.

---

## 2. Diferença entre aplicativo móvel e aplicação web

## 2.1 Aplicativo móvel

É um software executado em **dispositivo móvel**, como smartphone ou tablet, e normalmente depende de uma plataforma específica, como Android ou iOS. Pode utilizar recursos nativos do hardware, por exemplo:

* câmera;
* sensores;
* acelerômetro;
* barômetro;
* recursos do sistema operacional.

Quando é **nativo**, o aplicativo é desenvolvido especificamente para uma plataforma. Isso tende a gerar maior aderência ao ecossistema do dispositivo, mas reduz portabilidade. 

### Implicações técnicas

* forte dependência do SO;
* integração direta com APIs nativas;
* melhor exploração de hardware;
* maior custo de manutenção multiplataforma quando há versões separadas.

## 2.2 Aplicação móvel não nativa / híbrida

O material mostra que existem tecnologias capazes de gerar aplicações reutilizáveis entre plataformas, integrando posteriormente bibliotecas específicas no empacotamento final, como `.apk` no Android e `.ipa` no iOS. 

### Implicações técnicas

* maior reaproveitamento de código;
* redução de esforço multiplataforma;
* eventual dependência de camadas de abstração;
* necessidade de balancear portabilidade e acesso a recursos nativos.

## 2.3 Aplicação web

É um software executado no **navegador**. Seu acesso ocorre por browsers como Chrome, Edge, Safari e Firefox. A aplicação web pode refletir sistemas complexos e deve adaptar sua interface a diferentes resoluções e dispositivos, isto é, deve ser **responsiva**. 

### Implicações técnicas

* independência relativa de plataforma cliente;
* dependência de conectividade;
* foco em interoperabilidade e responsividade;
* tendência a arquiteturas orientadas a serviços e execução distribuída.

## 2.4 Relação entre ambos

O texto destaca que alguns “apps” móveis são, na prática, páginas web responsivas apresentadas como aplicação híbrida. Portanto, a fronteira entre web e mobile pode ser arquiteturalmente difusa, dependendo da tecnologia adotada. 

---

## 3. Evolução arquitetural: de cliente-servidor para serviços, microsserviços e nuvem

O material mostra a transição de arquiteturas centralizadas para modelos mais distribuídos. Na **Figura 1, página 26**, há uma comparação visual entre:

* arquitetura cliente-servidor;
* arquitetura orientada a serviços (SOA);
* organização distribuída de serviços em nuvem. 

## 3.1 Cliente-servidor

Modelo clássico em que clientes consomem funcionalidades concentradas em um servidor.

### Características

* centralização de processamento e dados;
* dependência de infraestrutura robusta;
* relação mais rígida entre cliente e backend;
* maior limitação para escalar partes específicas isoladamente.

## 3.2 SOA

Na arquitetura orientada a serviços, funcionalidades passam a ser expostas como **serviços independentes**, que podem se comunicar entre si.

### Características

* decomposição funcional;
* integração entre domínios relacionados;
* maior reuso;
* melhor distribuição de responsabilidades.

## 3.3 Microsserviços

O texto trata microsserviços como uma evolução de granularidade menor, em que cada componente geralmente concentra **uma funcionalidade específica**. 

### Características

* alta modularidade;
* escalabilidade seletiva;
* implantação independente;
* aumento de complexidade operacional e de integração.

## 3.4 Computação em nuvem

A nuvem é apresentada como infraestrutura sob demanda, em que o consumidor usa recursos computacionais sem gerenciá-los diretamente. A página 26 reforça isso ao explicar que armazenamento e capacidade computacional permanecem disponíveis sem que o usuário precise conhecer exatamente a localização dos servidores. 

### Consequências técnicas

* elasticidade;
* abstração da infraestrutura;
* suporte a serviços distribuídos;
* aderência natural a web apps e backends escaláveis.

---

## 4. Como a Engenharia de Software se aplica a apps móveis e web

O material reorganiza o ciclo clássico da Engenharia de Software para o contexto móvel e web:

* análise;
* projeto;
* desenvolvimento;
* testes;
* manutenção. 

A diferença não está no abandono dessas etapas, mas na necessidade de adaptá-las às particularidades de interface, plataforma, arquitetura distribuída e integração com serviços.

---

## 5. Etapa de análise

Na análise, o objetivo é transformar problemas e necessidades dos stakeholders em requisitos válidos.

## 5.1 Requisitos funcionais

São os comportamentos esperados visíveis aos usuários.

Exemplos:

* autenticar usuário;
* consultar dados;
* cadastrar entidade;
* executar operação de negócio.

## 5.2 Requisitos não funcionais

O material destaca que requisitos de qualidade são especialmente relevantes em aplicações móveis e web, como:

* tempo de resposta;
* facilidade de uso;
* integração com serviços de terceiros. 

Em leitura técnica, também se desdobram em:

* disponibilidade;
* escalabilidade;
* segurança;
* compatibilidade entre dispositivos;
* desempenho em redes variáveis.

## 5.3 Elicitação de requisitos

O texto menciona questionários, sessões com clientes e refinamento posterior das solicitações. Destaca também que essa é uma das fases mais delicadas, porque um requisito mal levantado propaga erro para todas as etapas seguintes. 

### Insight técnico

Erro em requisito custa mais caro conforme avança no ciclo. Em mobile e web isso piora porque:

* há múltiplos dispositivos;
* diferentes fluxos de navegação;
* forte dependência da experiência do usuário;
* integrações externas podem ser impactadas.

---

## 6. Prototipação e wireframes

O material valoriza a prototipação de telas como instrumento de comunicação com o cliente. Wireframes são tratados como protótipos de interface que ajudam a definir:

* estrutura da página ou tela;
* relacionamento entre páginas;
* fluxo de navegação;
* posicionamento de elementos visuais. 

Ferramentas citadas:

* Pidoco;
* Lucidchart.

### Importância técnica

Wireframe não é decoração visual. Ele reduz ambiguidade funcional, ajuda na elicitação e diminui retrabalho. Em apps móveis e web isso é ainda mais relevante porque a interface é parte central do produto.

### Observação importante

O texto também alerta que protótipos criados apenas para levantamento não devem ser reaproveitados automaticamente no produto final, por questões de qualidade. 

---

## 7. UML e modelagem no projeto

Após a análise, o documento de requisitos alimenta a etapa de projeto. O material destaca o uso de UML para apoiar a modelagem de soluções. Na **Figura 2, página 30**, aparecem exemplos dos principais diagramas usados:

* caso de uso;
* classes;
* sequência;
* componentes. 

## 7.1 Diagrama de caso de uso

Usado para representar funcionalidades do ponto de vista do ator.

### Papel técnico

* delimitar fronteira do sistema;
* mapear interações externas;
* apoiar comunicação com stakeholders.

## 7.2 Diagrama de classes

Representa classes, atributos, métodos e relacionamentos.

### Papel técnico

* modelar a estrutura estática;
* antecipar organização do código;
* apoiar implementação OO;
* servir como base para componentes e testes.

## 7.3 Diagrama de sequência

Representa a troca de mensagens entre objetos ao longo do tempo.

### Papel técnico

* modelar comportamento;
* explicitar fluxo de execução;
* facilitar entendimento de cenários de uso;
* apoiar design de APIs e orquestração de chamadas.

## 7.4 Diagrama de componentes

Mostra o acoplamento entre componentes e interfaces.

### Papel técnico

* evidenciar modularização;
* apoiar definição arquitetural;
* mostrar dependências e pontos de integração.

---

## 8. Projeto arquitetural

Antes do desenvolvimento, o material reforça a necessidade de um **diagrama arquitetural**. Essa etapa define o arranjo técnico global da solução e influencia diretamente:

* escolha de tecnologias;
* padrão de distribuição;
* integração entre componentes;
* estratégia de reuso;
* custo de evolução. 

### Para apps móveis

O projeto pode divergir bastante de web apps quando a solução usa tecnologia nativa.
Quando a estratégia é híbrida, a distância estrutural entre app e web pode diminuir.

### Para web apps

Há forte aderência a modelos orientados a serviços, microsserviços e nuvem, especialmente quando o sistema precisa escalar e integrar múltiplos domínios.

---

## 9. Desenvolvimento orientado a reuso

O texto destaca a importância de abordagens baseadas em reuso, especialmente apoiadas no paradigma orientado a objetos. Reuso não significa apenas copiar código; significa **reutilizar componentes de forma sistemática e coerente com a arquitetura**. 

### Benefícios técnicos

* redução de retrabalho;
* aumento de produtividade;
* padronização;
* menor esforço de manutenção;
* consistência estrutural.

### Restrição importante

O material alerta que o reuso deve estar em consonância com o projeto arquitetural. Se a arquitetura não foi concebida para isso, forçar reuso pode gerar acoplamento inadequado e degradação estrutural. 

---

## 10. Design Patterns

O texto apresenta padrões de projeto como soluções de alto nível para problemas recorrentes, e não como código pronto. Eles se articulam com arquitetura e codificação. 

## 10.1 Categorias mencionadas

* **criação**: ex. `singleton`
* **estruturais**: ex. `decorator`
* **comportamentais**: ex. `iterator`

## 10.2 Valor técnico

Padrões ajudam em:

* produtividade;
* organização do código;
* comunicação técnica da equipe;
* manutenção;
* padronização de decisões.

### Leitura crítica

Padrão não é sinônimo de qualidade automática. Seu valor depende de adequação ao contexto. Em app móvel e web, adoção excessiva ou inadequada pode piorar simplicidade, performance e legibilidade.

---

## 11. Verificação, validação e testes

Após o desenvolvimento, o material direciona para VV&T e divide as técnicas principais em dois grupos:

## 11.1 Técnica estrutural / caixa branca

Analisa o software sob a ótica interna:

* código-fonte;
* fluxos;
* trocas de mensagens entre classes e componentes.

### Aplicação

* testes unitários;
* cobertura de caminhos;
* validação estrutural;
* inspeção de lógica.

## 11.2 Técnica funcional / caixa preta

Analisa funcionalidades sem foco na estrutura interna.

### Aplicação

* validação de requisitos;
* cenários de uso;
* comportamento visível ao usuário;
* testes de aceitação. 

### Relevância para mobile e web

Nesses contextos, testes devem cobrir também:

* navegabilidade;
* usabilidade;
* comportamento responsivo;
* integração com APIs;
* compatibilidade entre ambientes;
* comportamento sob carga e latência.

---

## 12. Implantação e liberação controlada

O material menciona a possibilidade de disponibilização prévia para parte dos usuários antes da liberação total. Em termos técnicos, isso se aproxima de estratégias como:

* homologação assistida;
* piloto controlado;
* rollout gradual.

Objetivo:

* identificar falhas que escaparam da etapa formal de testes;
* coletar validação em uso real;
* reduzir risco de liberação ampla. 

---

## 13. Manutenção

A manutenção começa quando o software entra em uso real. Os usuários passam a demandar:

* correções;
* adaptações a legislação;
* adequações ao domínio;
* novas funcionalidades;
* ajustes de configuração. 

### Insight técnico

Em aplicações web e móveis, manutenção tende a ser constante porque:

* o ambiente tecnológico muda rápido;
* bibliotecas e plataformas evoluem;
* APIs externas mudam;
* requisitos de negócio são dinâmicos;
* a experiência do usuário precisa ser continuamente melhorada.

O texto enfatiza que alterações mais complexas reiniciam o ciclo completo: análise, planejamento, desenvolvimento e testes.

---

## 14. Gerenciamento de projetos como camada transversal

Na última página, o material destaca o gerenciamento de projetos como uma função integrada a todas as etapas, garantindo organização das tarefas e entrega dentro do cronograma contratado. 

### Papel técnico-gerencial

* coordenar pessoas e atividades;
* sincronizar dependências;
* controlar prazo e esforço;
* alinhar execução à expectativa do cliente;
* evitar que boas decisões técnicas se percam por falha organizacional.

Em leitura mais madura, isso significa que qualidade de software depende tanto de técnica quanto de coordenação.

---

## 15. Síntese técnica final

O conteúdo mostra que aplicações móveis e web não devem ser tratadas apenas como “interfaces modernas”, mas como produtos de software completos, submetidos aos mesmos fundamentos da Engenharia de Software, com complexidades adicionais de:

* plataforma;
* interface;
* conectividade;
* arquitetura distribuída;
* integração;
* escalabilidade;
* manutenção acelerada.

A Engenharia de Software entra justamente para reduzir esse risco estrutural, fornecendo base para:

* entender o problema corretamente;
* modelar o sistema adequadamente;
* escolher arquitetura e tecnologia com critério;
* construir com padrões e reuso quando fizer sentido;
* testar de modo sistemático;
* sustentar evolução do produto.

---

# Versão curta para revisão rápida

## Diferença principal

* **App móvel**: roda em dispositivo móvel, muitas vezes com forte dependência de plataforma.
* **Web app**: roda no navegador, com foco em responsividade e acesso distribuído.

## Tipos de app móvel

* Nativo
* Híbrido / multiplataforma

## Arquiteturas relevantes

* Cliente-servidor
* SOA
* Microsserviços
* Nuvem

## Etapas da Engenharia de Software

* Análise
* Projeto
* Desenvolvimento
* Testes
* Manutenção

## Artefatos importantes

* Documento de requisitos
* Wireframes
* Casos de uso
* Diagramas UML
* Projeto arquitetural

## Diagramas UML centrais

* Caso de uso
* Classes
* Sequência
* Componentes

## Desenvolvimento

* Reuso
* Orientação a objetos
* Design Patterns

## Testes

* Caixa branca
* Caixa preta

## Manutenção

* Correções
* Evolução
* Adequação ao domínio
* Reinício do ciclo quando necessário

---

