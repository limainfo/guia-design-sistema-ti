# Questões de revisão - Secure Development

## Capítulo 1

1. Qual alternativa descreve DevSecOps?
   - A) Segurança é responsabilidade exclusiva da equipe de segurança.
   - B) Desenvolvimento deve proteger tudo sozinho.
   - C) Operações é a única equipe responsável por banco e firewall.
   - D) Desenvolvimento, segurança e operações colaboram para proteger sistemas.

**Resposta:** D.

2. O que é defesa em profundidade?

**Resposta:** Estratégia de múltiplas camadas de segurança para que uma falha isolada não comprometa todo o ecossistema.

## Capítulo 2

1. Qual é o objetivo do OWASP?

**Resposta:** Melhorar a segurança de software por meio de recursos abertos e gratuitos.

2. Cite três projetos OWASP.

**Resposta esperada:** OWASP Top 10 Web, OWASP API Security Top 10, OWASP MASVS, OWASP Juice Shop, ZAP ou Cheat Sheets.

## Capítulo 3

1. SAST analisa o quê?

**Resposta:** Código fonte estático, sem executar a aplicação.

2. SCA analisa o quê?

**Resposta:** Bibliotecas, dependências e componentes de terceiros.

3. Qual a diferença entre CVE e CWE?

**Resposta:** CVE identifica vulnerabilidades específicas; CWE classifica tipos de fraqueza.

## Capítulo 4

1. O que é BOLA?

**Resposta:** Falha de autorização no nível de objeto que permite acesso indevido por manipulação de identificadores.

2. Autenticação impede BOLA sozinha?

**Resposta:** Não. Usuário autenticado ainda precisa ser autorizado para acessar cada objeto.

## Capítulo 5

1. OAuth 2.0 é autenticação?

**Resposta:** Não. OAuth 2.0 é autorização; autenticação de identidade normalmente usa OpenID Connect.

2. Por que API key não deve autenticar usuário final?

**Resposta:** Porque API keys identificam clientes/aplicações, não usuários humanos, e podem ser extraídas de apps ou frontends.

## Capítulo 6

1. O que é mass assignment?

**Resposta:** Quando campos do payload são vinculados automaticamente a propriedades internas, permitindo alterar campos não autorizados.

2. Como prevenir consumo irrestrito de recursos?

**Resposta:** Rate limiting, cotas, autenticação, autorização, limites de payload, alertas de gasto e monitoramento.

## Capítulo 7

1. O que é Security Misconfiguration?

**Resposta:** Configuração insegura ou incompleta que expõe dados, detalhes internos ou serviços indevidos.

2. O que deve existir em um inventário de APIs?

**Resposta:** Ambiente, versão, exposição, dono, documentação, políticas e classificação de dados.

## Capítulo 8

1. O que é MASVS?

**Resposta:** Padrão OWASP para verificar e melhorar a segurança de aplicativos móveis.

2. Por que KeyStore/Keychain são importantes?

**Resposta:** Protegem chaves e segredos usando mecanismos seguros da plataforma.

## Capítulo 9

1. Operações sensíveis precisam de autenticação adicional?

**Resposta:** Sim, como reautenticação, MFA, biometria ou PIN seguro.

## Capítulo 10

1. O que é certificate pinning?

**Resposta:** Fixar confiança em CAs ou chaves específicas para endpoints remotos controlados.

2. Para que serve FLAG_SECURE?

**Resposta:** Impedir captura de tela e exposição em multitarefa no Android.

## Capítulo 11

1. Por que forçar atualização pode ser necessário?

**Resposta:** Para bloquear versões vulneráveis em produção após descoberta de falha crítica.

## Capítulo 12

1. O que é RASP?

**Resposta:** Proteção da aplicação em tempo de execução capaz de detectar e prevenir ataques durante a execução.

## Capítulo 13

1. O que é minimização de dados?

**Resposta:** Coletar e acessar apenas dados estritamente necessários para a funcionalidade e finalidade informada.
