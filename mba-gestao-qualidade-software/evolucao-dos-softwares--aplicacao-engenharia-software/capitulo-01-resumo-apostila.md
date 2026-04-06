# Resumo técnico — Fundamentos de Engenharia de Software

## 1. Visão geral

A Engenharia de Software surgiu para tratar o desenvolvimento de software como uma atividade de engenharia, isto é, **disciplinada, sistemática, mensurável e orientada à qualidade**. A motivação histórica está ligada à chamada **crise do software**, em que abordagens ad hoc passaram a ser insuficientes diante do aumento da complexidade, custo, risco e necessidade de manutenção dos sistemas. 

Diferentemente de produtos puramente físicos, o software é um artefato **intangível**, evolutivo e fortemente dependente do domínio de negócio. Por isso, além de análise, projeto, construção e testes, ele exige **manutenção contínua**, adaptação e controle de qualidade ao longo de seu ciclo de vida. 

---

## 2. O que a Engenharia de Software realmente faz

Em termos técnicos, a Engenharia de Software organiza a produção de software por meio de:

* **métodos** para especificar, projetar, construir e validar sistemas;
* **processos** para estruturar atividades e definir fluxo de trabalho;
* **ferramentas** para apoiar automação, documentação, modelagem, versionamento, integração e testes;
* **práticas de qualidade** para garantir confiabilidade, manutenibilidade, proteção, eficiência e aceitabilidade. 

Ela atua como camada integradora entre:

* necessidade do negócio,
* requisitos do sistema,
* arquitetura,
* implementação,
* testes,
* operação e evolução.

Em outras palavras, a Engenharia de Software transforma uma necessidade organizacional em um produto de software operacional, rastreável e sustentável.

---

## 3. Diferença entre programa, software e aplicativo

### Programa

É uma **sequência de instruções** voltada à execução de uma tarefa específica.
Exemplo técnico: uma função que verifica se um número é primo.

### Software

É um conceito mais amplo que inclui:

* programas,
* estruturas de dados,
* documentação,
* instruções de operação e uso.

Ou seja, **software não é apenas código-fonte**; ele engloba todos os artefatos necessários para que a solução funcione e possa ser usada, mantida e evoluída corretamente. 

### Aplicativo

É um software empacotado para atender diretamente uma necessidade do usuário final.
Todo aplicativo é software, mas nem todo software é um aplicativo.

---

## 4. Papéis profissionais na concepção de software

A apostila destaca uma divisão funcional clássica de equipes, que tecnicamente pode ser interpretada assim: 

### Analista de sistemas

Responsável por:

* compreender o problema;
* levantar e estruturar requisitos;
* traduzir necessidades de negócio em artefatos de análise;
* apoiar modelagem funcional.

### Arquiteto de software

Responsável por:

* definir a estrutura de alto nível do sistema;
* selecionar estilos arquiteturais e tecnologias;
* tratar requisitos não funcionais críticos;
* tomar decisões estruturais com impacto em escalabilidade, integração e manutenção.

### Desenvolvedor / programador

Responsável por:

* implementar os artefatos definidos no projeto;
* materializar regras de negócio em código;
* aplicar padrões, tecnologias e práticas de construção.

### Analista de qualidade / testador

Responsável por:

* verificar conformidade;
* validar comportamento esperado;
* executar estratégia de testes;
* apoiar controle de defeitos e critérios de aceitação.

### Gerência de projetos

Responsável por:

* coordenar recursos humanos e financeiros;
* controlar escopo, prazo, custo e risco;
* integrar as frentes técnicas e organizacionais.

---

## 5. Os quatro pilares destacados

A apostila organiza a Engenharia de Software sobre quatro pilares centrais. Em uma leitura técnica:

## 5.1 Ferramentas

São os meios de apoio operacional ao processo.

Exemplos:

* CASE tools;
* repositórios de código;
* sistemas de rastreamento de requisitos;
* bancos de dados;
* ferramentas de testes;
* gerenciadores de projeto;
* pipelines de integração e entrega.

Função técnica: **reduzir esforço manual, padronizar atividades e aumentar rastreabilidade**.

## 5.2 Métodos

São os procedimentos formais usados em cada atividade.

Exemplos:

* elicitação de requisitos;
* modelagem UML;
* padrões de projeto;
* técnicas de teste;
* métricas de qualidade;
* métodos de decomposição arquitetural.

Função técnica: **garantir repetibilidade e coerência na execução**.

## 5.3 Processo

É a estrutura macro que organiza os métodos em fluxo.

Exemplos:

* processo de análise;
* processo de projeto;
* processo de desenvolvimento;
* processo de validação;
* processo de manutenção.

Função técnica: **ordenar o trabalho e definir dependências, entradas, saídas e critérios de passagem**.

## 5.4 Qualidade

É o resultado da integração entre pessoas, métodos, ferramentas e processo.

Do ponto de vista técnico, qualidade não é apenas “software funcionando”, mas a capacidade do produto de atender:

* requisitos funcionais;
* requisitos não funcionais;
* expectativas dos stakeholders;
* manutenção e evolução futura. 

---

## 6. Atributos de um software bem-sucedido

Segundo a linha conceitual apresentada na apostila, um software bem-sucedido deve atender aos usuários e stakeholders e sustentar operação adequada ao longo do tempo. Os atributos centrais mencionados incluem: 

* **manutenibilidade**: facilidade para corrigir, adaptar e evoluir;
* **confiança / confiabilidade**: operação correta e previsível;
* **proteção**: segurança e preservação de informações;
* **eficiência**: bom uso de tempo e recursos computacionais;
* **aceitabilidade**: aderência ao contexto e facilidade de uso.

Tecnicamente, isso significa que a qualidade do software depende tanto da solução do problema quanto da forma como ela foi estruturada.

---

## 7. Classificação técnica dos tipos de software

A apostila apresenta uma taxonomia útil para revisão conceitual. 

## 7.1 Software básico

Software de apoio a outros programas e de interação com hardware.

Exemplos:

* componentes de sistema operacional;
* drivers;
* compiladores.

Características:

* forte proximidade com recursos computacionais;
* concorrência e compartilhamento de recursos;
* dependência de ambiente de execução.

## 7.2 Software de tempo real

Monitora e reage a eventos do mundo real sob restrições temporais.

Exemplos:

* controle de tráfego aéreo;
* automação industrial;
* controle crítico.

Características:

* deadlines;
* previsibilidade;
* tolerância mínima a falhas;
* importância de determinismo e disponibilidade.

## 7.3 Software comercial

Suporta operações organizacionais e tomada de decisão.

Exemplos:

* folha de pagamento;
* contas a pagar e receber;
* sistemas de compra e venda.

Características:

* forte aderência a regras de negócio;
* integração com dados corporativos;
* necessidade de auditabilidade e manutenção contínua.

## 7.4 Software científico e de engenharia

Voltado a computação numérica, simulação e análise.

Exemplos:

* astronomia;
* biologia molecular;
* dinâmica orbital.

Características:

* alta carga computacional;
* precisão algorítmica;
* validação matemática.

## 7.5 Software embutido / embarcado

Acoplado a produtos físicos com funções específicas.

Exemplos:

* eletrodomésticos;
* automóveis;
* dispositivos eletrônicos.

Características:

* restrições de memória e processamento;
* proximidade com hardware;
* comportamento dedicado.

## 7.6 Software para computador pessoal

Apoia atividades cotidianas do usuário.

Exemplos:

* planilhas;
* editores de texto;
* editores de imagem;
* jogos.

Características:

* foco em experiência do usuário;
* variedade funcional;
* ampla distribuição.

## 7.7 Software de Inteligência Artificial

Emprega algoritmos para resolver problemas complexos não trivialmente programáveis por regras explícitas.

Exemplos:

* reconhecimento de voz;
* reconhecimento de imagem;
* redes neurais.

Características:

* uso intensivo de dados;
* inferência probabilística;
* comportamento não estritamente determinístico em alguns contextos.

---

## 8. Software genérico vs software sob encomenda

### Software genérico

É produzido para mercado amplo e vendido a diversos clientes.

Exemplo:

* pacote de escritório;
* software de prateleira.

### Software sob encomenda

É desenvolvido para atender necessidades específicas de um cliente ou domínio.

Exemplo:

* sistema corporativo customizado;
* solução interna de negócio.

Diferença técnica central:

* o software genérico privilegia **reusabilidade de mercado**;
* o software sob encomenda privilegia **aderência específica ao domínio**. 

---

## 9. Sistemas emergentes

A apostila trata como sistemas emergentes aqueles construídos com base em tecnologias modernas, especialmente:

* web,
* mobile,
* soluções híbridas,
* computação em nuvem,
* componentes reutilizáveis,
* serviços,
* microsserviços,
* inteligência artificial e machine learning. 

### Características técnicas desses sistemas

* grande diversidade de usuários e contextos de uso;
* distribuição geográfica;
* dependência de rede;
* necessidade de escalabilidade;
* alta disponibilidade;
* integração com múltiplos serviços;
* forte exposição a requisitos de segurança;
* evolução frequente.

Esses sistemas ampliam o desafio da Engenharia de Software porque exigem que análise, projeto, desenvolvimento, testes e manutenção ocorram com maior rigor técnico e maior capacidade de adaptação.

---

## 10. Requisitos de qualidade em sistemas emergentes

A apostila enfatiza especialmente três preocupações:

### Escalabilidade

Capacidade de o sistema continuar atendendo com desempenho aceitável à medida que a carga aumenta.

Exemplo prático:

* um e-commerce em período promocional.

### Disponibilidade

Capacidade de manter o serviço operacional e acessível.

Soluções técnicas típicas:

* replicação;
* balanceamento;
* nuvem;
* elasticidade de infraestrutura;
* redundância.

### Segurança

Proteção torna-se central porque sistemas web e móveis estão expostos por URLs, interfaces públicas e acessos distribuídos. Logo, o software deve ser pensado desde o início considerando riscos, controle de acesso, integridade e evolução segura. 

---

## 11. Etapas principais do processo de software

A figura apresentada na apostila, nas páginas finais, organiza o processo em cinco grandes etapas: **análise, projeto, desenvolvimento, testes e manutenção**, todas atravessadas por **abordagens de gerenciamento**. Essa estrutura é central para revisão. 

## 11.1 Análise

Objetivo: compreender o problema e levantar requisitos.

Atividades principais:

* identificação do problema;
* elicitação de requisitos;
* prototipação;
* modelagem de casos de uso.

Saídas típicas:

* documento de requisitos funcionais;
* requisitos não funcionais;
* visão inicial do sistema.

Ponto técnico importante:
os requisitos não funcionais incluem atributos como escalabilidade, disponibilidade e tempo de resposta.

## 11.2 Projeto

Objetivo: transformar requisitos em solução técnica.

Atividades principais:

* elaboração do projeto;
* modelagem UML;
* definição da arquitetura;
* seleção de abordagens, técnicas e tecnologias.

Saídas típicas:

* projeto arquitetural;
* projeto de software;
* diagramas estruturais e comportamentais;
* decisões tecnológicas.

## 11.3 Desenvolvimento

Objetivo: implementar o software.

Atividades principais:

* programação;
* aplicação de padrões e técnicas;
* produção de artefatos;
* documentação técnica.

Ponto técnico:
é a etapa em que decisões arquiteturais são materializadas em código.

## 11.4 Testes

Objetivo: verificar e validar o produto.

Atividades principais:

* testes unitários;
* testes de integração;
* verificação progressiva dos componentes;
* validação do software antes da disponibilização.

A apostila destaca que desenvolvimento e testes ocorrem de forma paralela e iterativa. 

## 11.5 Manutenção

Objetivo: corrigir, adaptar e evoluir o software após a entrega.

Atividades principais:

* identificação de melhorias;
* adequação a novas regras de negócio;
* reinício do ciclo a partir de novas demandas.

Ponto técnico:
a manutenção não é exceção; ela é parte inerente do ciclo de vida do software.

---

## 12. Papel da UML no contexto apresentado

A UML é apresentada como linguagem amplamente utilizada para **padronizar a elaboração de artefatos de projeto**. Seu papel não é “programar”, mas representar o sistema em diferentes níveis de abstração. 

No fluxo mostrado:

* **casos de uso** ajudam na compreensão funcional;
* diagramas da UML apoiam o **projeto**;
* os artefatos gerados devem refletir posteriormente no código.

Em termos técnicos, a UML é uma ferramenta de **comunicação, documentação e apoio ao projeto**, especialmente útil para reduzir ambiguidade.

---

## 13. Síntese técnica final

A mensagem central do material é esta:

> software de qualidade não surge apenas da programação; ele depende de um arranjo disciplinado entre requisitos, arquitetura, implementação, testes, manutenção e gerenciamento.

Logo, a Engenharia de Software deve ser entendida como:

* disciplina de organização da complexidade;
* mecanismo de redução de risco;
* ponte entre negócio e tecnologia;
* base para sustentabilidade do produto;
* fator essencial em sistemas modernos, distribuídos e escaláveis.

---

# Versão curta para revisão rápida

## Conceitos-chave

* **Programa**: instruções para executar uma tarefa.
* **Software**: programas + dados + documentação.
* **Aplicativo**: software voltado ao usuário final.

## Pilares

* Ferramentas
* Métodos
* Processo
* Qualidade

## Etapas do processo

* Análise
* Projeto
* Desenvolvimento
* Testes
* Manutenção

## Atributos de qualidade

* Manutenibilidade
* Confiabilidade
* Proteção
* Eficiência
* Aceitabilidade

## Tipos de software

* Básico
* Tempo real
* Comercial
* Científico/engenharia
* Embarcado
* Computador pessoal
* IA

## Sistemas emergentes

* Web
* Mobile
* Nuvem
* Serviços / microsserviços
* IA / ML

## Requisitos críticos em sistemas emergentes

* Escalabilidade
* Disponibilidade
* Segurança

---
