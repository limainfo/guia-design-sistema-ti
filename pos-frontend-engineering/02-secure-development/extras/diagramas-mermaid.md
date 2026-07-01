# Todos os diagramas Mermaid

## Capítulo 1 - Introdução ao Desenvolvimento Seguro

### Diagrama 1

```mermaid
flowchart LR
    Dev["Desenvolvimento\nCódigo seguro, validações, testes"]
    Sec["Segurança\nPolíticas, threat modeling, ferramentas"]
    Ops["Operações\nInfraestrutura, deploy, logs, backups"]
    Produto["Produto mais seguro"]

    Dev --> Produto
    Sec --> Produto
    Ops --> Produto

    Dev <-->|"feedback contínuo"| Sec
    Sec <-->|"monitoramento e resposta"| Ops
    Ops <-->|"observabilidade e automação"| Dev
```

### Diagrama 2

```mermaid
flowchart TB
    Atacante["Atacante / Bot / Ameaça externa"] --> WAF["WAF\nBloqueio de ataques web"]
    WAF --> Gateway["API Gateway\nAutenticação, rate limit, políticas"]
    Gateway --> IdP["Identity Provider\nLogin, MFA, tokens"]
    Gateway --> App["Aplicação / Backend\nValidações e autorização"]
    App --> DBGuard["Proteção de Banco\nPrivilégios mínimos e rede privada"]
    DBGuard --> DB[("Banco de Dados")]
    App --> Logs["Logs e eventos"]
    Logs --> SIEM["SIEM / SOAR\nCorrelação, alerta e resposta"]
    DB --> Backup["Backup e recuperação"]

    classDef danger fill:#ffe5e5,stroke:#d33,color:#111;
    classDef safe fill:#eaf7ea,stroke:#2b8a3e,color:#111;
    class Atacante danger;
    class WAF,Gateway,IdP,App,DBGuard,DB,Logs,SIEM,Backup safe;
```

## Capítulo 2 - Projeto OWASP

### Diagrama 1

```mermaid
mindmap
  root((OWASP))
    Guias e padrões
      OWASP Top 10 Web
      OWASP API Security Top 10
      OWASP MASVS
      Cheat Sheets
    Ferramentas
      Juice Shop
      ZAP
      Ferramentas de API Security
    Comunidade
      Capítulos locais
      Conferências
      Contribuição aberta
    Uso no mercado
      Referência estratégica
      Treinamento
      Auditoria e requisitos
```

### Diagrama 2

```mermaid
flowchart LR
    OWASP["OWASP"] --> Web["Top 10 Web\nRiscos gerais de aplicações web"]
    OWASP --> API["API Security Top 10\nRiscos específicos de APIs"]
    OWASP --> Mobile["MASVS / Mobile\nControles para apps móveis"]
    OWASP --> Training["Juice Shop\nAmbiente vulnerável de treinamento"]
```

## Capítulo 3 - Tornando o Código Fonte Mais Seguro

### Diagrama 1

```mermaid
flowchart LR
    Dev["Desenvolvedor"] --> Repo["Repositório Seguro"]
    Repo --> CI["Pipeline CI/CD"]
    CI --> SAST["SAST\nCódigo fonte"]
    CI --> SCA["SCA\nDependências"]
    SAST --> Report["Relatório de vulnerabilidades"]
    SCA --> Report
    Report --> Fix["Correção"]
    Fix --> CI
    CI --> Deploy["Deploy somente após gates"]
```

### Diagrama 2

```mermaid
flowchart TB
    Projeto["Projeto"] --> Manifestos["Manifestos\npackage.json, pom.xml, build.gradle"]
    Manifestos --> SCA["Ferramenta SCA"]
    SCA --> Bases["Bases públicas\nCVE, advisories, vendors"]
    Bases --> Achados["Dependências vulneráveis"]
    Achados --> Acao{Existe correção?}
    Acao -->|Sim| Upgrade["Atualizar versão"]
    Acao -->|Não| Mitigar["Mitigar, substituir ou aceitar risco formalmente"]
```

### Diagrama 3

```mermaid
flowchart LR
    CWE["CWE\nTipo de fraqueza"] --> Exemplo1["Validação de entrada insuficiente"]
    CWE --> Exemplo2["SQL Injection"]
    CVE["CVE\nVulnerabilidade específica"] --> Caso1["CVE em biblioteca X versão Y"]
    Caso1 --> Correcao["Atualizar / aplicar patch / mitigar"]
```

## Capítulo 4 - Ameaças em APIs e BOLA

### Diagrama 1

```mermaid
flowchart TB
    Internet["Internet\nAmbiente aberto e hostil"] --> Front["Frontend\nWeb / Mobile / IoT"]
    Front -->|"requisições HTTP/GraphQL"| API["APIs expostas"]
    subgraph Privada["Rede privada / Cloud / Datacenter"]
        API --> Gateway["API Gateway"]
        Gateway --> Backend["Backend / Microserviços"]
        Backend --> DB[("Banco de dados")]
    end
    Atacante["Atacante / Bot"] -.-> Front
    Atacante -.-> API
```

### Diagrama 2

```mermaid
sequenceDiagram
    participant U as Usuário autenticado
    participant API as API
    participant Auth as Serviço de autorização
    participant DB as Banco de dados

    U->>API: GET /employee/0036/salary com token de José
    API->>Auth: José pode acessar employee 0036?
    alt Permissão negada
        Auth-->>API: Não autorizado
        API-->>U: 403 Forbidden
    else Falha BOLA
        API->>DB: Busca salário do employee 0036
        DB-->>API: Dados de Maria
        API-->>U: Dados expostos indevidamente
    end
```

### Diagrama 3

```mermaid
flowchart TD
    Req["Requisição com token + ID do objeto"] --> Token["Validar token"]
    Token --> Perm["Verificar permissão no backend"]
    Perm --> Decision{Usuário pode acessar o objeto?}
    Decision -->|Sim| Dados["Retornar dados mínimos necessários"]
    Decision -->|Não| Bloqueio["403 Forbidden + log seguro"]
    Bloqueio --> SIEM["Evento para monitoração"]
```

## Capítulo 5 - Autenticação em APIs

### Diagrama 1

```mermaid
flowchart TB
    Ataque["Ataques comuns"] --> Brute["Força bruta"]
    Ataque --> Stuffing["Credential stuffing"]
    Ataque --> Token["Roubo ou manipulação de token"]
    Ataque --> Weak["Senhas fracas"]
    Ataque --> Email["Troca de e-mail sem confirmação"]

    Brute --> Mitigacao["Bloqueio, CAPTCHA, rate limit"]
    Stuffing --> Mitigacao
    Token --> TokenChecks["Validar assinatura, expiração, emissor, audience e scopes"]
    Weak --> PasswordPolicy["Política de senha e verificação de senhas fracas"]
    Email --> Reauth["Reautenticação em operação sensível"]
```

### Diagrama 2

```mermaid
flowchart LR
    User["Usuário"] --> Authn["Autenticação\nverifica identidade"]
    Authn --> Token["Token emitido"]
    Token --> Authz["Autorização\nverifica permissões"]
    Authz --> Recurso["Recurso protegido"]
```

### Diagrama 3

```mermaid
sequenceDiagram
    participant Usuario as Usuário
    participant IdP as Identity Server
    participant Gateway as API Gateway
    participant Backend as Backend Service

    Usuario->>IdP: 1. Envia usuário e senha
    IdP-->>Usuario: 2. Token criado
    Usuario->>Gateway: 3. Requisição com Bearer token
    Gateway->>IdP: 4. Valida token
    IdP-->>Gateway: 5. Token OK
    Gateway->>Backend: 6. Chama API interna com mTLS
    Backend-->>Gateway: 7. Resposta segura
    Gateway-->>Usuario: 8. Resposta da API
```

### Diagrama 4

```mermaid
sequenceDiagram
    participant Client as Cliente B2B
    participant IdP as Identity Server
    participant Gateway as API Gateway
    participant Backend as Backend Service

    Client->>IdP: 1. client_id + client_secret
    IdP-->>Client: 2. Token criado
    Client->>Gateway: 3. Requisição com token
    Gateway->>IdP: 4. Valida token
    IdP-->>Gateway: 5. OK
    Gateway->>Backend: 6. Chama API com mTLS
    Backend-->>Gateway: 7. Resposta
    Gateway-->>Client: 8. Resposta da API
```

## Capítulo 6 - Tampering e Consumo Irrestrito

### Diagrama 1

```mermaid
flowchart LR
    Client["Cliente / Frontend"] --> Payload["Payload manipulado"]
    Payload --> API["API"]
    API --> Bind["Auto-binding para objeto interno"]
    Bind --> Domain["Propriedade sensível alterada"]
    Domain --> Impacto["Bypass de regra de negócio"]

    API -.prevenção.-> DTO["DTO explícito\nSomente campos permitidos"]
    DTO -.-> Authz["Autorização por propriedade"]
```

### Diagrama 2

```mermaid
flowchart TD
    Request["Requisição do cliente"] --> SchemaIn["Validar schema de entrada"]
    SchemaIn --> Allowlist["Aplicar allowlist de campos alteráveis"]
    Allowlist --> AuthProp["Verificar autorização por propriedade"]
    AuthProp --> Business["Executar regra de negócio"]
    Business --> DTOOut["Montar DTO de resposta mínimo"]
    DTOOut --> SchemaOut["Validar schema de resposta"]
    SchemaOut --> Response["Responder sem dados excedentes"]
```

### Diagrama 3

```mermaid
flowchart TB
    Req["Requisições à API"] --> Gateway["API Gateway"]
    Gateway --> Rate["Rate limiting"]
    Gateway --> Size["Limite de tamanho de payload"]
    Gateway --> Auth["Autenticação e autorização"]
    Gateway --> Cost["Cotas e orçamento"]
    Rate --> Backend["Backend"]
    Size --> Backend
    Auth --> Backend
    Cost --> Alerts["Alertas de gasto e tráfego"]
    Backend --> Logs["Logs e métricas"]
    Logs --> SIEM["SIEM/SOAR"]
```

## Capítulo 7 - Governança e Segurança para APIs

### Diagrama 1

```mermaid
flowchart TD
    Misconfig["Security Misconfiguration"] --> HTTP["Verbos HTTP desnecessários"]
    Misconfig --> Auth["Proteções ausentes"]
    Misconfig --> CORS["CORS permissivo"]
    Misconfig --> Cloud["Permissões cloud excessivas"]
    Misconfig --> Error["Erros expõem detalhes internos"]
    Misconfig --> TLS["TLS ausente ou fraco"]

    HTTP --> Attack["Aumento da superfície de ataque"]
    Auth --> Attack
    CORS --> Attack
    Cloud --> Attack
    Error --> Attack
    TLS --> Attack
```

### Diagrama 2

```mermaid
flowchart LR
    Catalogo["Catálogo de APIs"] --> Ambientes["Ambientes\ndev, qa, prod"]
    Catalogo --> Versoes["Versões\nv1, v2, v3"]
    Catalogo --> Acesso["Exposição\npública, interna, parceiros"]
    Catalogo --> Dados["Classificação de dados"]
    Catalogo --> Owner["Dono técnico e de negócio"]
    Catalogo --> Politicas["Políticas de segurança"]
```

### Diagrama 3

```mermaid
flowchart LR
    Mobile["Mobile App"] --> IdP["Identity Provider"]
    Web["WebApp / SPA"] --> IdP
    IoT["Dispositivo IoT"] --> IdP
    IdP --> Gateway["API Gateway\nPolíticas 1..N"]
    Mobile --> Gateway
    Web --> Gateway
    IoT --> Gateway

    Gateway -->|"mTLS"| Partner["Backend parceiro"]
    Gateway -->|"link privado"| B1["Backend 1"]
    Gateway -->|"link privado"| B2["Backend 2"]
    Gateway --> Logs["Eventos e logs"]
    Gateway --> Vault["Key Vault"]
    Logs --> SIEM["Monitoramento / SIEM"]
```

## Capítulo 8 - Desenvolvimento Seguro para Aplicativos Mobile

### Diagrama 1

```mermaid
mindmap
  root((OWASP MASVS))
    STORAGE
      Dados sensíveis em repouso
      Prevenção de vazamentos
    CRYPTO
      Criptografia forte
      Gerenciamento de chaves
    AUTH
      Autenticação
      Autorização
    NETWORK
      TLS
      Pinning
    PLATFORM
      IPC
      WebViews
      UI segura
    CODE
      Plataforma atualizada
      SCA
      Sanitização
    RESILIENCE
      Anti-tamper
      Anti-reverse engineering
    PRIVACY
      Minimização
      Transparência
      Controle do usuário
```

### Diagrama 2

```mermaid
flowchart TB
    Dados["Dados sensíveis"] --> Store{Precisa armazenar?}
    Store -->|Não| NoStore["Não armazenar"]
    Store -->|Sim| Classificar["Classificar sensibilidade"]
    Classificar --> Secure["Armazenamento seguro\nKeystore / Keychain / storage criptografado"]
    Secure --> Leak["Prevenir vazamento\nlogs, backups, analytics, cache"]
    Leak --> Retention["Retenção mínima e descarte seguro"]
```

### Diagrama 3

```mermaid
stateDiagram-v2
    [*] --> Gerada: geração segura
    Gerada --> Armazenada: KeyStore / Keychain / Vault
    Armazenada --> EmUso: uso controlado
    EmUso --> Rotacionada: rotação periódica
    Rotacionada --> EmUso
    EmUso --> Revogada: incidente ou expiração
    Revogada --> Descartada: descarte seguro
    Descartada --> [*]
```

## Capítulo 9 - Autenticação Segura para Aplicativos

### Diagrama 1

```mermaid
flowchart TB
    AUTH["MASVS-AUTH"] --> A1["AUTH-1\nProtocolos seguros de autenticação e autorização"]
    AUTH --> A2["AUTH-2\nAutenticação local segura"]
    AUTH --> A3["AUTH-3\nAutenticação adicional em operações sensíveis"]
```

### Diagrama 2

```mermaid
sequenceDiagram
    participant User as Usuário
    participant App as App Mobile
    participant Local as Biometria/PIN
    participant API as Backend/API
    participant IdP as Identity Provider

    User->>App: Solicita operação sensível
    App->>Local: Exige autenticação local
    Local-->>App: Usuário confirmado
    App->>IdP: Reautenticação ou step-up MFA
    IdP-->>App: Confirmação / token com escopo forte
    App->>API: Envia operação com token válido
    API->>API: Valida autorização e risco
    API-->>App: Operação permitida ou negada
```

### Diagrama 3

```mermaid
flowchart LR
    App["App Mobile"] -->|"token + requisição"| Backend["Backend"]
    App --> Local["Proteções locais\nbiometria, storage seguro, UI segura"]
    Backend --> Server["Proteções servidor\nautorização, sessão, regras, auditoria"]
    Local --> Secure["Segurança composta"]
    Server --> Secure
```

## Capítulo 10 - Protegendo Rede e Plataforma

### Diagrama 1

```mermaid
sequenceDiagram
    participant App as App Mobile
    participant OS as Sistema Operacional
    participant API as API Remota

    App->>API: Inicia conexão TLS
    API-->>App: Envia certificado
    App->>OS: Valida cadeia do certificado
    OS-->>App: Cadeia válida
    App->>App: Verifica pinning da CA/chave esperada
    alt Pinning confere
        App->>API: Envia requisição segura
        API-->>App: Resposta segura
    else Pinning falha
        App-->>App: Bloqueia conexão e registra evento
    end
```

### Diagrama 2

```mermaid
flowchart TB
    Plataforma["MASVS-PLATFORM"] --> IPC["IPC seguro\nExpor apenas o necessário"]
    Plataforma --> WebView["WebViews seguras\nSem pontes perigosas e origens abertas"]
    Plataforma --> UI["UI segura\nSem vazamento por screenshot, multitarefa ou notificação"]
```

## Capítulo 11 - Protegendo Código e Versões do App

### Diagrama 1

```mermaid
flowchart TB
    CODE["MASVS-CODE"] --> C1["CODE-1\nVersão atualizada da plataforma"]
    CODE --> C2["CODE-2\nMecanismo para forçar atualização"]
    CODE --> C3["CODE-3\nComponentes sem vulnerabilidades conhecidas"]
    CODE --> C4["CODE-4\nValidação e sanitização de entradas"]
```

### Diagrama 2

```mermaid
sequenceDiagram
    participant App as App antigo
    participant Config as Serviço de configuração
    participant Store as Loja de aplicativos
    participant User as Usuário

    App->>Config: Consulta versão mínima permitida
    Config-->>App: Versão mínima = 5.2.0
    alt App abaixo da versão mínima
        App-->>User: Bloqueia uso e solicita atualização
        User->>Store: Atualiza aplicativo
    else App atualizado
        App-->>User: Permite uso normal
    end
```

### Diagrama 3

```mermaid
flowchart LR
    Commit["Commit"] --> SAST["SAST"]
    Commit --> SCA["SCA"]
    SAST --> Tests["Testes automatizados"]
    SCA --> Tests
    Tests --> Build["Build assinado"]
    Build --> RASP["Proteções runtime / ofuscação"]
    RASP --> Release["Publicação"]
    Release --> Monitor["Monitoramento de crash, fraude e versão"]
    Monitor --> Force["Atualização forçada se necessário"]
```

## Capítulo 12 - Engenharia Reversa e Resiliência

### Diagrama 1

```mermaid
flowchart TB
    RES["MASVS-RESILIENCE"] --> R1["RESILIENCE-1\nValidação da integridade da plataforma"]
    RES --> R2["RESILIENCE-2\nMecanismos anti-adulteração"]
    RES --> R3["RESILIENCE-3\nAnti-análise estática"]
    RES --> R4["RESILIENCE-4\nAnti-análise dinâmica"]
```

### Diagrama 2

```mermaid
flowchart LR
    Build["Build assinado"] --> RASP["Implantar RASP"]
    RASP --> Runtime["Executar app"]
    Runtime --> Detect["Detectar ameaças\nroot, hook, tamper, debugger"]
    Detect --> Decision{Ameaça?}
    Decision -->|Não| Continue["Continua execução"]
    Decision -->|Sim| Response["Bloqueia, encerra, reduz funcionalidade ou alerta"]
    Response --> SIEM["Evento para análise"]
    SIEM --> Improve["Aprimorar defesas"]
    Improve --> Build
```

### Diagrama 3

```mermaid
flowchart TB
    Obfuscate["Ofuscar código"] --> Rasp["Implantar RASP"]
    Rasp --> Detect["Detectar ameaças"]
    Detect --> Prevent["Prevenir ataques"]
    Prevent --> Learn["Analisar tentativas"]
    Learn --> Obfuscate
```

## Capítulo 13 - Controles sobre Privacidade

### Diagrama 1

```mermaid
flowchart TB
    Privacy["MASVS-PRIVACY"] --> P1["PRIVACY-1\nMinimização de acesso"]
    Privacy --> P2["PRIVACY-2\nPrevenção da identificação"]
    Privacy --> P3["PRIVACY-3\nTransparência sobre coleta e uso"]
    Privacy --> P4["PRIVACY-4\nControle do usuário sobre dados"]
```

### Diagrama 2

```mermaid
flowchart LR
    Real["Identidade real\nCPF, nome, e-mail"] --> Separacao["Separação de contexto"]
    Separacao --> Pseudo["ID pseudônimo"]
    Pseudo --> Analytics["Analytics / métricas"]
    Real -.restrito.-> Backend["Backend protegido"]
```

### Diagrama 3

```mermaid
flowchart TB
    User["Usuário"] --> Preferences["Gerenciar preferências"]
    User --> Consent["Revogar consentimento"]
    User --> Access["Acessar dados"]
    User --> Delete["Solicitar exclusão"]
    Delete --> Legal{Existe base legal de retenção?}
    Legal -->|Sim| Justify["Informar retenção necessária"]
    Legal -->|Não| Remove["Excluir ou anonimizar"]
```
