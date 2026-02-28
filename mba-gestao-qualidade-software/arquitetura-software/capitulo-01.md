# 📘 Resumo – Capítulo 1

## Conceitos Fundamentais sobre Arquitetura de Software

## 1. Introdução à Arquitetura de Software

A arquitetura de software pode ser comparada à arquitetura de uma construção civil: antes de edificar uma casa ou prédio, é necessário definir estrutura, componentes, normas e integrações. Da mesma forma, o software exige planejamento, definição de componentes e organização estrutural.

A arquitetura é responsável por:

* Definir os principais elementos do sistema;
* Estabelecer como esses elementos se comunicam;
* Garantir qualidade, integração e coerência entre as partes.

Ela surge durante a fase de análise e projeto e orienta a implementação do sistema.

---

## 1.1 Arquitetura de Software e seus Componentes

A arquitetura resulta da interação entre diversos artefatos da Engenharia de Software.

Conforme o **modelo apresentado na Figura 1 (p. 9)** , o processo envolve:

### 🔹 Entradas do projeto:

* Informação da plataforma (hardware, ambiente)
* Especificação de requisitos
* Descrição de dados

### 🔹 Atividades do projeto:

* Projeto de arquitetura
* Projeto de interface
* Projeto de componentes
* Projeto de banco de dados

### 🔹 Saídas:

* Arquitetura do sistema
* Especificação do banco de dados
* Especificação de interface
* Especificação de componentes

### Tipos de Requisitos

* **Funcionais:** o que o sistema deve fazer.
* **Não funcionais:** desempenho, segurança, usabilidade, disponibilidade etc.
* **De domínio:** regras específicas do contexto do negócio.

---

### Elementos Abrangidos pela Arquitetura

A arquitetura inclui decisões de alto nível como:

* Estrutura do sistema
* Gerenciamento e controle
* Protocolos de comunicação
* Distribuição física dos componentes
* Atributos de qualidade (desempenho, escalabilidade, flexibilidade)

Ela fornece uma visão global do sistema, antecipando impactos de mudanças e reduzindo riscos.

---

## 1.2 Principais Estilos e Padrões Arquiteturais

A escolha da arquitetura influencia diretamente:

* Performance
* Qualidade
* Manutenibilidade
* Escalabilidade
* Sucesso do projeto a longo prazo

O capítulo apresenta os principais estilos arquiteturais:

---

### 🔹 Arquitetura em Camadas (Layers)

Organiza o sistema em camadas interligadas por interfaces bem definidas.

Exemplo apresentado na **Figura 2 (p. 14)** :

* Camada de Domínio
* Camada de Serviços

Características:

* Baixo acoplamento entre camadas
* Alta coesão interna
* Facilita manutenção e evolução

---

### 🔹 Arquitetura Cliente-Servidor

Divide o sistema em:

* Cliente (interface)
* Servidor (processamento e dados)

Conforme ilustrado na **Figura 3 (p. 15)** .

Muito utilizada em:

* Sistemas web
* Aplicações bancárias
* Sistemas corporativos

---

### 🔹 MVC (Model-View-Controller)

Divide o sistema em:

* **Model:** regras de negócio e dados
* **View:** interface gráfica
* **Controller:** fluxo e controle

Muito utilizado em aplicações web.

---

### 🔹 SOA (Arquitetura Orientada a Serviços)

Baseia-se em serviços reutilizáveis e integrados.
Possui maior granularidade que microsserviços.

---

### 🔹 Microsserviços

Evolução do SOA:

* Serviços menores
* Baixo acoplamento
* Alta escalabilidade
* Atualizações independentes
* Forte integração com práticas DevOps (CI/CD)

---

### 🔹 Pipes and Filters

Fluxo linear de processamento de dados por meio de filtros sequenciais.
Muito comum em sistemas Linux e processamento de dados.

---

### 🔹 Peer-to-Peer (P2P)

Cada nó pode atuar como cliente e servidor.
Exemplo: sistemas de compartilhamento de arquivos (torrent).

---

### 🔹 Publish-Subscribe (Pub/Sub)

Modelo baseado em eventos:

* Produtor publica conteúdo
* Consumidores inscritos recebem notificações

Muito utilizado em redes sociais e sistemas orientados a eventos.

---

## Atributos de Qualidade Destacados

O capítulo enfatiza três atributos principais:

### ✅ Desempenho (Performance)

Capacidade de atender múltiplas demandas com eficiência.

### ✅ Escalabilidade

Capacidade de crescer sem comprometer o funcionamento.

### ✅ Flexibilidade

Facilidade de adaptação a mudanças.

---

## Conclusão do Capítulo

A arquitetura de software:

* Define a estrutura macro do sistema;
* Reduz riscos e custos;
* Garante qualidade;
* Facilita manutenção e evolução;
* Deve considerar requisitos técnicos e de negócio.

As arquiteturas estão em constante evolução, acompanhando novas tecnologias e necessidades.
