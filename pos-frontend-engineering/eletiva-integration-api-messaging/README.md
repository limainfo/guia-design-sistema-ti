# Eletiva - Integration, APIs & Messaging

Material de estudo em português, estruturado para consulta no GitHub e revisão para prova.

Este repositório consolida os três módulos da disciplina:

1. **Introdução à Integração de Sistemas**
2. **Estilos de Arquitetura de Integração**
3. **Segurança, Cloud, API como Produto e Testes**

O conteúdo foi organizado com um padrão único por capítulo:

- objetivo do capítulo;
- mapa mental em Mermaid;
- conceitos essenciais;
- diagramas Mermaid equivalentes aos fluxos e imagens conceituais;
- tabelas comparativas;
- pontos de atenção para prova;
- questões de revisão com gabarito.

> Observação: os diagramas foram escritos em Mermaid para renderização direta no GitHub.

## Navegação rápida

| Documento | Conteúdo |
|---|---|
| [01 - Introdução à Integração de Sistemas](docs/01-introducao-integracao-sistemas.md) | API, comunicação, contratos, síncrono/assíncrono, stateful/stateless, formatos de dados, protocolos, MSA, EDA e mensageria |
| [02 - Estilos de Arquitetura de Integração](docs/02-estilos-arquitetura-integracao.md) | REST, SOAP, GraphQL, gRPC, WebSocket, WebHook, MQTT, AMQP, paginação, cache, compressão e rate limit |
| [03 - Segurança, Cloud e Testes](docs/03-seguranca-cloud-testes.md) | OWASP API Security Top 10, TLS, autenticação, OAuth2, JWT, cloud, API First, API as a Product, API Gateway, Portal de APIs e testes |
| [04 - Revisão para Prova](docs/04-revisao-prova.md) | Resumo de alta prioridade, questões objetivas e questões discursivas |
| [05 - Glossário](docs/05-glossario.md) | Termos essenciais da disciplina |
| [99 - Fontes e Atualizações](docs/99-fontes-e-atualizacoes.md) | Arquivos usados, ajustes técnicos e atualizações pontuais |

## Como usar para estudar

1. Leia o capítulo correspondente à aula.
2. Refaça mentalmente os diagramas Mermaid.
3. Responda às questões sem olhar o gabarito.
4. Use o glossário para revisar termos curtos.
5. Antes da prova, leia primeiro o arquivo de revisão.

## Padrão visual dos diagramas

Todos os diagramas seguem a mesma lógica didática:

- **Cliente / produtor** à esquerda;
- **camada intermediária** ao centro, quando existir;
- **servidor / consumidor / persistência** à direita;
- setas indicam fluxo principal;
- anotações destacam contrato, protocolo, formato, segurança ou estado.

