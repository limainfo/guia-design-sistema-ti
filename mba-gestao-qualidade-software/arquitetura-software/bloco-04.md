# 📘 Conceitos Fundamentais

## 🔹 Desempenho

Capacidade do sistema responder rápido sob carga (tempo de resposta, throughput).

Depende de:

* Número de camadas atravessadas
* Latência de rede
* Processamento de dados
* Acesso a banco
* Serialização (JSON/XML)

---

## 🔹 Escalabilidade

Capacidade de aumentar recursos para suportar mais carga.

* **Vertical** → mais CPU/RAM
* **Horizontal** → mais instâncias

---

## 🔹 Flexibilidade

Capacidade de adaptação a:

* Novas regras de negócio
* Mudanças legais (ex: seu contexto público)
* Integração com novos sistemas
* Evolução tecnológica

---

## 🔹 Coesão

Grau de responsabilidade única dentro de um módulo.

* Alta coesão = módulo faz uma coisa bem definida
* Baixa coesão = módulo faz muitas coisas misturadas

---

## 🔹 Granularidade

Tamanho e responsabilidade da unidade arquitetural.

* Granularidade grossa → poucos módulos grandes
* Granularidade fina → muitos módulos pequenos

---

## 🔹 Acoplamento

Dependência entre módulos.

* Alto acoplamento → mudanças impactam muitos componentes
* Baixo acoplamento → maior independência

---

# 📊 TABELA COMPARATIVA

## 1️⃣ Desempenho | Escalabilidade | Flexibilidade

| Estilo                            | Desempenho                    | Escalabilidade                     | Flexibilidade |
| --------------------------------- | ----------------------------- | ---------------------------------- | ------------- |
| **Camadas (Monolito em camadas)** | BOM (baixa latência interna)  | LIMITADA (principalmente vertical) | MÉDIA         |
| **Cliente-Servidor**              | BOM (para pequenas cargas)    | RESTRITA                           | BAIXA         |
| **Serviços (SOA)**                | BOM (pode ter gargalo ESB/DB) | BOA                                | BOA           |
| **Microsserviços**                | VARIÁVEL (overhead de rede)   | MUITO ALTA                         | MUITO ALTA    |

---

### 🔎 Importante

> Microsserviços NÃO são automaticamente "melhor desempenho".

Eles:

* Podem ter **melhor escalabilidade**
* Mas podem ter **pior desempenho bruto** devido a:

  * chamadas HTTP
  * serialização
  * latência de rede
  * circuit breaker

---

## 2️⃣ Coesão | Granularidade | Acoplamento

| Estilo               | Coesão        | Granularidade | Acoplamento |
| -------------------- | ------------- | ------------- | ----------- |
| **Camadas**          | MÉDIA         | GROSSA        | ALTO        |
| **Cliente-Servidor** | BAIXA a MÉDIA | GROSSA        | ALTO        |
| **Serviços (SOA)**   | ALTA          | MÉDIA         | MÉDIO       |
| **Microsserviços**   | MUITO ALTA    | FINA          | BAIXO       |

---

Microsserviços são:

* Pequenos (granularidade fina)
* Especializados (alta coesão)
* Independentes (baixo acoplamento)

---

# 🧠 Visão Evolutiva da Arquitetura

A evolução normalmente segue:

Cliente-Servidor
⬇
Monolito em Camadas
⬇
SOA
⬇
Microsserviços

Mas isso **não significa que o último é sempre melhor**.

Exemplo prático:

* Sistema interno como GARH → muitas regras integradas → monolito pode ser mais simples.
* Plataforma aberta com alta escala → microsserviços faz mais sentido.

---

# 📌 Resumo Estratégico (para prova)

| Critério                       | Melhor Arquitetura     |
| ------------------------------ | ---------------------- |
| Desempenho bruto simples       | Monolito               |
| Alta Escalabilidade            | Microsserviços         |
| Alta Flexibilidade             | Microsserviços         |
| Baixo Acoplamento              | Microsserviços         |
| Simplicidade operacional       | Monolito               |
| Complexidade de infraestrutura | Microsserviços (maior) |

---

