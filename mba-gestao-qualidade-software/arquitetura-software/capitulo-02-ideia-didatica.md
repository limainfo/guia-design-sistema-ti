# ANÁLISE E PROJETO DE ARQUITETURAS DE SOFTWARE

## Resumo Acadêmico – Padrão MBA

## 1. Introdução

A Arquitetura de Software constitui um dos pilares estratégicos da Engenharia de Software contemporânea, sendo responsável por estruturar a solução tecnológica que materializa os requisitos de negócio. O Módulo 02 apresenta a arquitetura como resultado de um processo sistemático que integra análise, projeto, desenvolvimento, testes e manutenção, demonstrando que decisões arquiteturais impactam diretamente qualidade, escalabilidade, manutenibilidade e evolução do sistema.

A arquitetura não se limita à representação gráfica do sistema, mas compreende um conjunto de decisões estruturais que organizam componentes, interfaces, padrões e tecnologias de modo coerente com o domínio do problema.

---

## 2. Fases da Concepção do Software e seu Impacto Arquitetural

O módulo estrutura o ciclo de desenvolvimento em cinco fases principais:

### 2.1 Análise

A fase de análise tem como objetivo compreender o domínio do problema, identificar e refinar requisitos funcionais e não funcionais e alinhar expectativas com stakeholders. É nesta etapa que se estabelecem as bases para decisões arquiteturais futuras.

Uma análise bem conduzida:

* Minimiza retrabalho;
* Reduz custos de mudança;
* Garante coerência entre solução técnica e necessidades do negócio.

A modelagem por meio da UML é utilizada para estruturar essa compreensão, tanto sob a perspectiva estrutural quanto comportamental.

---

### 2.2 Projeto (Design)

O projeto transforma os artefatos conceituais da análise em uma estrutura técnica implementável. Nesta fase são definidos:

* Componentes e módulos;
* Interfaces;
* Estrutura de camadas;
* Tecnologias adotadas;
* Estratégias de integração;
* Reuso de componentes.

A arquitetura é consolidada nesse momento, constituindo a base formal da solução.

---

### 2.3 Desenvolvimento

Na etapa de desenvolvimento ocorre a materialização do projeto arquitetural em código. A aderência aos padrões definidos na arquitetura garante:

* Consistência estrutural;
* Manutenção facilitada;
* Evolução controlada do sistema.

Boas práticas e padronização tornam-se fundamentais para manter a integridade da arquitetura ao longo da implementação.

---

### 2.4 Testes

Os testes realizam verificação e validação da solução desenvolvida. Confirmam:

* Conformidade com requisitos;
* Correção técnica;
* Estabilidade da integração.

A arquitetura influencia diretamente a testabilidade do sistema, especialmente quando favorece modularidade e desacoplamento.

---

### 2.5 Manutenção

Após a implantação, o software entra em fase evolutiva. Correções, refatorações e novas funcionalidades exigem que a arquitetura suporte mudanças com impacto mínimo.

Arquiteturas mal estruturadas tendem a gerar sistemas rígidos e de alto custo de manutenção, enquanto arquiteturas bem definidas favorecem adaptabilidade.

---

## 3. Modelagem Arquitetural e UML

A UML é apresentada como instrumento de representação do domínio sob duas perspectivas principais:

### 3.1 Perspectiva Estrutural

Representa:

* Classes;
* Atributos;
* Relacionamentos;
* Associações;
* Multiplicidade.

O diagrama de classes é central na definição do modelo estrutural do sistema.

---

### 3.2 Perspectiva Comportamental

Representa:

* Interações;
* Colaboração entre objetos;
* Casos de uso.

Essa visão auxilia na compreensão das funcionalidades e no refinamento dos requisitos.

---

## 4. Conceitos Fundamentais na Arquitetura

### 4.1 Encapsulamento

O encapsulamento assegura proteção do estado interno dos objetos por meio da definição adequada de visibilidade (atributos privados e métodos públicos). Esse princípio fortalece:

* Segurança;
* Controle de alterações;
* Coesão interna.

---

### 4.2 Associações e Multiplicidade

As relações entre classes são definidas por cardinalidades (1, 0..1, 1..*, *), que orientam tanto a modelagem conceitual quanto a implementação em banco de dados e código.

---

### 4.3 Modularização e Componentização

O projeto busca decompor o sistema em componentes independentes e integráveis, permitindo:

* Desenvolvimento paralelo;
* Testes isolados;
* Integração controlada.

Essa abordagem está alinhada com princípios modernos de engenharia, como DevOps e integração contínua.

---

## 5. Modelos do Problema e da Solução

A arquitetura integra dois modelos complementares:

### 5.1 Modelo do Problema

* Foco no domínio;
* Regras de negócio;
* Requisitos textuais;
* Modelagem conceitual.

### 5.2 Modelo da Solução

* Estrutura técnica;
* Componentes físicos e lógicos;
* Banco de dados;
* Interfaces e integrações.

A Arquitetura de Software surge da convergência desses dois modelos.

---

## 6. Perspectivas Arquiteturais

A arquitetura pode ser analisada sob diferentes níveis:

### 6.1 Projeto Externo

Define as interfaces oferecidas ao ambiente:

* APIs;
* Integrações;
* Comunicação intersistemas.

### 6.2 Projeto Interno

Define a organização estrutural:

* Camadas;
* Componentes;
* Colaboração entre módulos.

---

## 7. Níveis de Abstração

O módulo organiza a arquitetura em três níveis:

* **Estratégico:** visão macro da estrutura do sistema.
* **Tático:** organização lógica de componentes.
* **Operacional:** detalhamento técnico e implementação.

Essa separação permite melhor governança arquitetural.

---

## 8. Arquitetura Orientada ao Domínio

O domínio do negócio influencia diretamente a arquitetura. Exemplos:

* Sistemas de e-commerce → foco em segurança e transações.
* Sistemas de streaming → foco em disponibilidade e desempenho.

A arquitetura deve refletir as prioridades estratégicas do domínio.

---

## 9. Princípio das Abstrações Estáveis (SAP)

O módulo apresenta o Stable Abstractions Principle (SAP), segundo o qual:

* Componentes estáveis devem ser mais abstratos.
* Componentes instáveis devem ser mais concretos.

Esse princípio equilibra estabilidade e extensibilidade, favorecendo manutenção e evolução.

---

## 10. Considerações Críticas e Complementares

Além do conteúdo do módulo, é importante destacar que arquiteturas modernas devem considerar:

* Atributos de qualidade (ISO/IEC 25010), como:

  * Confiabilidade;
  * Segurança;
  * Desempenho;
  * Escalabilidade;
  * Manutenibilidade.
* Governança arquitetural;
* Documentação contínua;
* Avaliação arquitetural (ATAM);
* Alinhamento com estratégias organizacionais.

Arquitetura de software é, portanto, um elemento estratégico e não apenas técnico.

---

## 11. Conclusão

O Módulo 02 evidencia que a arquitetura de software representa a ponte entre o problema de negócio e a solução tecnológica. Uma análise adequada fundamenta decisões arquiteturais consistentes; um projeto bem estruturado assegura qualidade e sustentabilidade do sistema.

A arquitetura deve:

* Ser alinhada ao domínio;
* Ser modular e testável;
* Facilitar evolução;
* Reduzir riscos;
* Sustentar a estratégia organizacional.

Em síntese, a arquitetura não é apenas um desenho técnico, mas um instrumento de gestão da complexidade e de garantia de qualidade ao longo de todo o ciclo de vida do software.
