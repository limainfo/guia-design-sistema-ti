# Laboratório Almoxarifado - Exemplo Java

Exemplo didático baseado no Contrato 3 do material de estudo.

Objetivo: mostrar como CDC e Design Patterns aparecem na prática:

- `Material`: contrato de domínio.
- `MaterialImpl`: implementação protegida do domínio.
- `MaterialFactory`: criação controlada.
- `MaterialRepository`: contrato de persistência.
- `MaterialRepositoryMemory`: persistência em memória para estudo/testes.
- `EstoqueService`: contrato de serviço.
- `EstoqueServiceImpl`: orquestra regras de entrada e saída.
- `EstoqueGateway`: adapter/gateway para integração externa.

Este código é propositalmente simples para revisão de prova.
