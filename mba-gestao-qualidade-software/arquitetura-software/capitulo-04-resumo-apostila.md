# Resumo Didático – Módulo 04

## Estilos e Projetos Arquiteturais integrados a Requisitos de Qualidade

## 1. Qualidade em Software e Arquitetura

A qualidade de um software é definida por **requisitos funcionais e não funcionais** que representam as expectativas dos usuários e stakeholders.

A qualidade deve ser considerada **desde a arquitetura do sistema**, pois decisões arquiteturais influenciam diretamente:

* desempenho
* segurança
* escalabilidade
* disponibilidade
* manutenibilidade

Ou seja, **a arquitetura é o principal ponto onde os atributos de qualidade são definidos e viabilizados**. 

---

# 2. Modelos de Qualidade de Software

Diversos modelos foram propostos para padronizar a avaliação da qualidade.

Principais modelos:

* **McCall e Matsumoto (1980)**
* **Dromey**
* **ISO/IEC 25010**
* **ISO/IEC 25023**

O padrão mais utilizado atualmente é o **SQuaRE (Software Quality Requirements and Evaluation)**.

Ele inclui três padrões principais:

| Norma         | Objetivo                           |
| ------------- | ---------------------------------- |
| ISO/IEC 25040 | Processo de avaliação de qualidade |
| ISO/IEC 25010 | Modelo de qualidade do produto     |
| ISO/IEC 25023 | Métricas de qualidade              |

---

# 3. Características de Qualidade (ISO/IEC 25010)

A norma ISO/IEC 25010 define **características e subcaracterísticas de qualidade** que devem ser consideradas na arquitetura de software.

## 3.1 Adequação Funcional

Avalia se o software atende corretamente às necessidades do usuário.

Subcaracterísticas:

* integridade funcional
* correção funcional
* adequação funcional

Relaciona-se diretamente aos **requisitos funcionais do sistema**.

---

## 3.2 Eficiência de Desempenho

Relacionada ao desempenho do sistema considerando o ambiente de uso.

Aspectos avaliados:

* tempo de resposta
* uso de recursos
* capacidade de processamento

Subcaracterísticas:

* comportamento temporal
* utilização de recursos
* capacidade

Essa característica é crítica em **sistemas distribuídos e aplicações web**.

---

## 3.3 Compatibilidade

Avalia a capacidade de um sistema **interagir com outros sistemas**.

Subcaracterísticas:

* interoperabilidade
* coexistência
* funcionalidade integrada

É essencial em arquiteturas modernas como:

* microsserviços
* sistemas distribuídos
* integração via APIs

---

## 3.4 Usabilidade

Refere-se à facilidade de uso e interação do usuário com o sistema.

Subcaracterísticas:

* adequação ao uso
* aprendizado
* operabilidade
* proteção contra erros
* acessibilidade
* estética da interface

A usabilidade impacta diretamente a **experiência do usuário (UX)**.

---

## 3.5 Confiabilidade

Refere-se à capacidade do sistema **operar corretamente ao longo do tempo**.

Subcaracterísticas:

* maturidade
* disponibilidade
* tolerância a falhas
* recuperabilidade

Muito importante em sistemas:

* críticos
* financeiros
* serviços online

---

## 3.6 Segurança

Relaciona-se à proteção de dados e controle de acesso.

Subcaracterísticas:

* confidencialidade
* integridade
* autenticidade
* não repúdio
* responsabilização

Arquiteturas modernas frequentemente incluem **camadas de segurança dedicadas**.

---

## 3.7 Manutenibilidade

Avalia a facilidade de modificar ou evoluir o software.

Subcaracterísticas:

* modularidade
* reutilização
* analisabilidade
* modificabilidade
* testabilidade

Arquiteturas bem projetadas facilitam manutenção e reduzem custos.

---

## 3.8 Portabilidade

Avalia a facilidade de transferir o sistema entre ambientes.

Subcaracterísticas:

* adaptabilidade
* instalabilidade
* capacidade de substituição

Muito importante em ambientes:

* cloud
* containers
* multiplataforma

---

# 4. Requisitos de Qualidade nas Arquiteturas Modernas

Arquiteturas atuais consideram:

* computação em nuvem
* integração contínua
* DevOps
* sistemas distribuídos

Esses ambientes exigem **métricas específicas para avaliar qualidade**.

Exemplos:

* tempo de resposta
* número de requisições por segundo
* uso de CPU e memória
* disponibilidade do sistema

---

# 5. Métricas para Avaliação de Qualidade

Para medir qualidade são utilizados dois tipos principais de métodos.

## Métodos Analíticos

Baseados em análises estruturais do sistema.

Exemplos:

* análise de arquitetura
* revisão de código
* análise de métricas de software

---

## Métodos Empíricos

Baseados em observação prática.

Exemplos:

* testes de desempenho
* questionários com usuários
* análise de uso real do sistema

---

# 6. Modelo de Qualidade para Arquitetura de Microsserviços

O material apresenta um **modelo de qualidade para arquiteturas baseadas em microsserviços**.

Principais atributos avaliados:

* eficiência de desempenho
* compatibilidade
* confiabilidade
* usabilidade
* segurança
* manutenibilidade
* portabilidade

A figura apresentada na apostila mostra a relação desses atributos na arquitetura de microsserviços (Figura 1). 

---

# 7. Uso de Métricas na Arquitetura

Para avaliar a arquitetura, é necessário:

1. Definir atributos de qualidade
2. Definir métricas de medição
3. Coletar dados do sistema
4. Analisar os resultados

Exemplos de métricas:

* requisições por segundo
* uso de memória RAM
* estabilidade de conexão
* disponibilidade de serviços
* tempo de resposta de APIs

Essas métricas ajudam a **avaliar se a arquitetura atende aos requisitos de qualidade definidos**.

---

# 8. Relação entre Arquitetura e Qualidade

A arquitetura deve ser projetada considerando:

* requisitos funcionais
* requisitos de qualidade
* métricas de avaliação

Uma arquitetura bem definida permite:

* melhor desempenho
* maior segurança
* facilidade de manutenção
* melhor experiência do usuário

---

# Conclusão

A qualidade de software não depende apenas da implementação, mas principalmente da **arquitetura do sistema**.

Modelos como **ISO/IEC 25010** permitem identificar atributos de qualidade e criar métricas para avaliar se a arquitetura atende às necessidades do sistema.

Assim, integrar **requisitos de qualidade às decisões arquiteturais** é essencial para garantir sistemas confiáveis, escaláveis e eficientes.

---
