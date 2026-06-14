# 99 - Fontes e Atualizações

## Arquivos usados como base

Material principal enviado para consolidação:

- `Aula 1 - Ebook (PDF).pdf`
- `Aula 2 - Ebook (PDF).pdf`
- `Aula 3 - Ebook (PDF).pdf`
- `Introdução a integração de sistemas - Eduardo Galego.pdf`
- `Estilos de Arquitetura de Integração - Eduardo Galego.pdf`
- `Segurança, Cloud e Testes - Eduardo Galego.pdf`

## Organização adotada

O conteúdo foi consolidado por módulo:

1. **Introdução à Integração de Sistemas**
   - motivação;
   - comunicação;
   - API e contrato;
   - síncrono/assíncrono;
   - stateless/stateful;
   - modelos de integração;
   - protocolos;
   - formatos de dados;
   - microsserviços, EDA e mensageria.

2. **Estilos de Arquitetura de Integração**
   - REST;
   - SOAP;
   - GraphQL;
   - gRPC;
   - WebSocket;
   - WebHook;
   - MQTT;
   - AMQP;
   - paginação;
   - cache/CDN;
   - compressão;
   - rate limit.

3. **Segurança, Cloud e Testes**
   - princípios de segurança;
   - OWASP API Security Top 10 2023;
   - TLS;
   - autenticação;
   - OAuth2;
   - JWT;
   - Cloud Services;
   - API First;
   - API as a Product;
   - Developer Experience;
   - API Gateway;
   - Portal de APIs;
   - testes de integração com Postman, MockAPI e GitHub Actions.

## Ajustes técnicos e padronizações

Foram feitas pequenas padronizações de nomenclatura técnica para manter o material correto e consistente:

- `Roy Fielding` foi usado como referência para REST.
- `TLS` foi usado no lugar de grafias inconsistentes como `TSL`.
- `QUIC` foi usado no contexto de HTTP/3.
- `AMQP` foi descrito como **Advanced Message Queuing Protocol**.
- `OpenAPI` foi separado de `Swagger`: OpenAPI é a especificação; Swagger é o conjunto/ecossistema de ferramentas.

## Atualização pontual

O material da aula indicava OpenAPI 3.1.1 como versão atual. A especificação oficial mais recente publicada pela OpenAPI Initiative é a **OpenAPI Specification v3.2.0**, publicada em **19 de setembro de 2025**.

Para prova, priorize a nomenclatura e abordagem do professor. Para uso profissional, consulte sempre a especificação oficial atual.

## Como evoluir este repositório

Sugestões de próximos arquivos:

- `exemplos/openapi.yaml` com uma API REST simples;
- `exemplos/schema.graphql` com types, query e mutation;
- `exemplos/hello.proto` com serviço gRPC;
- `exemplos/postman-collection.json` para testes de integração;
- `diagramas/*.mmd` caso prefira separar os diagramas Mermaid dos capítulos.
