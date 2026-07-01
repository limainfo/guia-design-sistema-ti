# Checklist prático DevSecOps

## Código

- [ ] SAST integrado à IDE ou pipeline.
- [ ] SCA integrado ao pipeline.
- [ ] Secrets fora do repositório.
- [ ] Validação e sanitização de entradas não confiáveis.
- [ ] Consultas SQL parametrizadas.
- [ ] Tratamento de erro sem vazamento de stack.
- [ ] Logs sem dados sensíveis.

## APIs

- [ ] Autenticação obrigatória nos endpoints protegidos.
- [ ] Autorização por objeto contra BOLA.
- [ ] Autorização por propriedade contra mass assignment.
- [ ] Rate limiting por IP, usuário e cliente.
- [ ] Limite de tamanho de payload e uploads.
- [ ] CORS restrito.
- [ ] TLS configurado corretamente.
- [ ] Inventário de APIs com ambiente, versão, dono e exposição.
- [ ] Documentação protegida.

## Mobile

- [ ] Dados sensíveis em storage seguro.
- [ ] Chaves em Keystore/Keychain/Secure Enclave quando aplicável.
- [ ] Autenticação local segura.
- [ ] Step-up authentication em operações sensíveis.
- [ ] TLS e validação de certificados.
- [ ] Certificate pinning nos endpoints críticos.
- [ ] WebViews configuradas com segurança.
- [ ] Proteção contra screenshots em telas sensíveis.
- [ ] SCA para SDKs e dependências.
- [ ] Ofuscação, anti-tamper e RASP quando o risco justificar.

## Operação e governança

- [ ] API Gateway com políticas padronizadas.
- [ ] SIEM/SOAR recebendo eventos relevantes.
- [ ] Alertas de custos e picos de tráfego.
- [ ] Backups testados.
- [ ] Patches de infraestrutura aplicados.
- [ ] Ambientes de teste sem dados reais ou com dados mascarados.
- [ ] Plano de resposta a incidentes.
