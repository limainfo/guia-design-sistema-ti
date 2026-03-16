# Resumo Didático – Capítulo 3: Processos de Software

## 1. O que é um Processo de Software

Um **processo de software** é um conjunto estruturado de atividades executadas para produzir um sistema de software.

Ele representa uma **sequência organizada de passos**, realizada por pessoas e ferramentas, que transforma insumos em produtos de software. 

### Elementos básicos de um processo

Um processo normalmente é composto por:

* **Insumos** – informações ou artefatos utilizados no processo
* **Papéis** – responsabilidades atribuídas às pessoas envolvidas
* **Etapas** – atividades executadas ao longo do processo
* **Produtos de trabalho** – resultados gerados em cada etapa

Esses elementos formam a **arquitetura do processo**, que define como as atividades são organizadas e interagem.

---

## 2. Classificação de Processos (CMMI)

O modelo **CMMI (Capability Maturity Model Integration)** classifica processos segundo seu nível de definição e controle.

### Principais tipos de processos

| Tipo de Processo                  | Característica                              |
| --------------------------------- | ------------------------------------------- |
| Processo incompleto               | Não executa todas as atividades necessárias |
| Processo efetuado                 | Produz os produtos de trabalho esperados    |
| Processo planejado                | Possui planejamento documentado             |
| Processo gerido                   | É monitorado e controlado                   |
| Processo definido                 | Segue padrões organizacionais               |
| Processo gerido quantitativamente | Usa métricas e controle estatístico         |
| Processo otimizado                | Melhorado continuamente                     |

Esses níveis refletem o **grau de maturidade organizacional na engenharia de software**.

---

# 3. Modelos de Ciclo de Vida de Software

O **ciclo de vida do software** descreve como as etapas do desenvolvimento são organizadas ao longo do tempo.

Em geral, o desenvolvimento envolve atividades como:

* levantamento de requisitos
* análise
* projeto (design)
* implementação
* testes

Cada modelo organiza essas etapas de maneira diferente.

---

# 4. Modelo Codificar e Remendar

Este é o modelo mais simples e informal.

### Características

* começa diretamente pela codificação
* os problemas são corrigidos conforme aparecem
* pouca ou nenhuma documentação

### Problemas

* alto risco
* difícil manutenção
* baixa previsibilidade

Por isso, **não é considerado um modelo adequado para projetos profissionais**.

---

# 5. Modelo Cascata

O **modelo cascata** organiza o desenvolvimento em fases sequenciais.

### Etapas principais

1. Requisitos
2. Análise
3. Projeto (design)
4. Implementação
5. Testes

Cada fase só começa quando a anterior termina.
Esse modelo foi um dos primeiros utilizados na engenharia de software.

### Vantagens

* organização clara do projeto
* documentação estruturada
* fácil gerenciamento

### Limitações

* pouca flexibilidade
* difícil lidar com mudanças de requisitos
* feedback do usuário ocorre apenas no final

Na prática, muitas organizações utilizam **cascata com realimentação**, permitindo revisões entre fases. 

---

# 6. Modelo em Espiral

O **modelo em espiral** combina desenvolvimento incremental com análise de riscos.

### Características principais

* desenvolvimento ocorre em **iterações**
* cada ciclo produz uma nova versão do sistema
* cada etapa envolve análise de riscos

Cada volta da espiral inclui:

1. planejamento
2. análise de riscos
3. desenvolvimento
4. avaliação do usuário

### Vantagens

* melhor controle de riscos
* adaptação a mudanças
* maior participação do cliente

---

# 7. Entrega Evolutiva

Nesse modelo, o sistema é construído em **incrementos sucessivos**.

Cada ciclo entrega uma versão funcional do software.

### Características

* partes do sistema são liberadas gradualmente
* o usuário avalia cada versão
* requisitos podem evoluir com o tempo

Esse modelo permite maior **flexibilidade e adaptação às necessidades do usuário**.

---

# 8. Outros Modelos

O capítulo também menciona outras abordagens, como:

* **Modelos dirigidos por prazo (time-boxed)**
* **Processos baseados em ferramentas (CASE)**
* **Modelos híbridos** usados em metodologias modernas

Esses modelos procuram equilibrar **planejamento, controle e adaptação às mudanças**.

---

# 9. Processos de Humphrey (PSP)

Watts Humphrey propôs o **Personal Software Process (PSP)** para melhorar a qualidade do trabalho individual dos desenvolvedores.

O PSP introduz práticas como:

* registro de tempo gasto nas atividades
* registro e análise de defeitos
* planejamento detalhado
* revisões de código e projeto
* estimativas baseadas em dados históricos

### Objetivo

Melhorar a **disciplina individual de desenvolvimento**, aumentando a qualidade e previsibilidade dos projetos.

---

# 10. Estrutura do PSP

O PSP evolui em níveis:

| Nível  | Característica               |
| ------ | ---------------------------- |
| PSP0   | registro de tempo e defeitos |
| PSP0.1 | padronização e medição       |
| PSP1   | planejamento e estimativas   |
| PSP1.1 | planejamento de cronograma   |
| PSP2   | revisões de código e design  |
| PSP3   | desenvolvimento em ciclos    |

O processo termina com uma fase chamada **post-mortem**, na qual os resultados do projeto são analisados para melhoria contínua.

---

# Conclusão

O capítulo demonstra que o desenvolvimento de software **não deve ser realizado de forma improvisada**, mas sim por meio de processos bem definidos.

Os principais pontos são:

* processos organizam atividades de desenvolvimento
* modelos de ciclo de vida definem a estrutura do projeto
* modelos clássicos incluem cascata e espiral
* abordagens evolutivas e iterativas permitem maior flexibilidade
* processos como PSP buscam melhorar a qualidade do trabalho individual

Assim, **processos de software são fundamentais para garantir qualidade, previsibilidade e controle no desenvolvimento de sistemas**.

---
