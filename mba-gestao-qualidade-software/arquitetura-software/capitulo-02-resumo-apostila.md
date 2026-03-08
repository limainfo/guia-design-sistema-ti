# 📘 Resumo – Capítulo 2
## ANÁLISE E PROJETO DE ARQUITETURAS DE SOFTWARE

## 🎯 Objetivo do Módulo

O módulo tem como finalidade:

* Contextualizar os conceitos essenciais de **arquitetura de software**
* Orientar a definição de **metas e escopo**
* Aprofundar em **padrões arquiteturais**
* Compreender como a arquitetura influencia todo o ciclo de vida do software

---

# 1️⃣ Fases da Concepção do Software

O desenvolvimento de software é estruturado em cinco etapas principais:

## 1. Análise

* Levantamento e refinamento de requisitos
* Entendimento do domínio do problema
* Alinhamento com stakeholders
* Criação de artefatos iniciais (diagramas, casos de uso, modelos)

👉 Aqui nasce a base da arquitetura.

---

## 2. Projeto (Design)

* Transformação dos requisitos em solução técnica
* Definição de:

  * Estrutura do sistema
  * Componentes
  * Tecnologias
  * Interfaces
  * Diagramas UML

👉 A arquitetura é consolidada nesta fase.

---

## 3. Desenvolvimento

* Implementação do que foi projetado
* Uso de boas práticas e padrões
* Garantia de alinhamento com requisitos

---

## 4. Testes

* Verificação e validação do software
* Testes unitários, integração e validação funcional
* Confirmação de que o sistema faz:

  * ✔ O que foi solicitado
  * ✔ Da maneira correta

---

## 5. Manutenção

* Correções
* Evoluções
* Refatorações
* Integração de novas funcionalidades

👉 Uma arquitetura bem definida reduz impactos nessa fase.

---

# 2️⃣ Papel da Análise na Arquitetura

A análise:

* Identifica problemas do domínio
* Refina requisitos
* Reduz retrabalho futuro
* Dá base para decisões arquiteturais

Quanto melhor a análise, menor o custo de mudanças posteriores.

---

# 3️⃣ Uso da UML na Análise

A UML é utilizada para representar o domínio sob duas perspectivas:

## 🔹 Estrutural

* Classes
* Atributos
* Relacionamentos
* Diagramas estáticos

## 🔹 Comportamental

* Interações
* Casos de uso
* Colaboração entre objetos

O diagrama de classes é central nessa modelagem.

---

# 4️⃣ Conceitos Fundamentais

## 🔐 Encapsulamento

* Atributos privados (-)
* Métodos públicos (+)
* Proteção do estado interno do objeto

Garante segurança e controle das alterações.

---

## 🔗 Associações e Multiplicidade

Relacionamentos entre classes podem ter cardinalidade:

* 1
* 0..1
* 1..*
* *

Isso orienta tanto o banco de dados quanto a programação.

---

# 5️⃣ Fase de Projeto (Design)

Objetivo principal:

👉 Criar uma estrutura implementável.

Inclui:

* Definição de componentes
* Separação modular
* Interfaces bem definidas
* Reutilização de componentes
* Integração contínua
* Uso de DevOps
* Ferramentas CASE

---

# 6️⃣ Modelos na Arquitetura

A arquitetura nasce da combinação de dois modelos:

## 📌 Modelo do Problema

* Mais textual
* Foco no domínio
* Requisitos
* Regras de negócio

## 📌 Modelo da Solução

* Mais técnico
* Estrutura física
* Componentes
* Banco de dados
* Interfaces
* Infraestrutura

A Arquitetura de Software integra ambos.

---

# 7️⃣ Perspectivas Arquiteturais

A arquitetura pode ser vista sob diferentes níveis:

## 🔹 Projeto Externo

Interfaces oferecidas ao ambiente:

* APIs
* Integrações
* Comunicação com outros sistemas

## 🔹 Projeto Interno

Organização dos componentes:

* Camadas
* Serviços
* Módulos
* Comunicação interna

---

# 8️⃣ Níveis de Abstração

## 🔵 Nível Estratégico

* Desenho arquitetônico
* Visão macro
* Estrutura global do sistema

## 🟢 Nível Tático

* Organização lógica
* Componentização
* Reuso

## 🟡 Nível Operacional

* Implementação detalhada
* Código
* Documentação técnica

---

# 9️⃣ Arquitetura e Domínio

Cada domínio influencia a arquitetura.

Exemplo:

* 🛒 E-commerce → foco em segurança e transações
* 📺 Streaming → foco em disponibilidade e performance

---

# 🔟 Princípio das Abstrações Estáveis (SAP)

Um conceito importante apresentado:

* Componentes estáveis → devem ser mais abstratos
* Componentes instáveis → devem ser mais concretos

Objetivo:

* Facilitar manutenção
* Permitir evolução
* Reduzir impacto de mudanças

---

# 📌 Síntese Final

O módulo 02 mostra que:

✔ Arquitetura não é apenas diagrama
✔ É resultado de análise bem feita
✔ Define qualidade futura do software
✔ Impacta diretamente manutenção e evolução
✔ Deve considerar domínio e contexto

A arquitetura é a ponte entre:

> Problema do negócio → Solução tecnológica
