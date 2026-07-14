# CWE-699 - Software Development

## Category: Credentials Management Errors - CWE-255

> **Objetivo do material:** documentar, de forma prática, as fraquezas relacionadas ao gerenciamento de credenciais na categoria **CWE-255**, pertencente à view **CWE-699 - Software Development**, usando exemplos em **Java** aplicáveis a sistemas web, APIs REST, Struts/Servlet/JSP, Spring, aplicações legadas, integrações, bancos de dados e application servers.

---

## 1. Visão geral

A categoria **CWE-255 - Credentials Management Errors** agrupa problemas no ciclo de vida de credenciais.

Uma credencial pode ser:

- senha de usuário;
- senha de conta técnica;
- chave de API;
- token de acesso;
- segredo de cliente OAuth;
- chave privada;
- certificado acompanhado da respectiva chave;
- credencial de banco de dados;
- credencial de integração;
- código ou token de recuperação;
- credencial inicial ou padrão;
- segredo usado para assinar ou criptografar informações.

O risco não se limita ao momento do login. O gerenciamento seguro precisa considerar todo o ciclo de vida:

1. criação;
2. transmissão;
3. armazenamento;
4. validação;
5. alteração;
6. recuperação;
7. rotação;
8. expiração ou revogação;
9. descarte;
10. auditoria.

### Impactos possíveis

Falhas desta categoria podem provocar:

- comprometimento de contas;
- escalação de privilégios;
- acesso não autorizado ao banco de dados;
- uso indevido de APIs e integrações;
- movimentação lateral entre sistemas;
- comprometimento em massa quando todos os ambientes usam o mesmo segredo;
- recuperação de senhas a partir do banco;
- reutilização de chaves já vencidas ou revogadas;
- exposição de credenciais em logs, arquivos, repositórios ou interfaces;
- impossibilidade de revogar uma credencial individual;
- permanência de acessos após troca de equipe ou encerramento de contrato.

---

## 2. Natureza da categoria e mapeamento

A **CWE-255** é uma **Category**, isto é, um agrupamento organizacional de fraquezas. Ela auxilia na navegação e no estudo, mas não representa uma causa raiz específica.

Por esse motivo, a CWE-255 não deve ser usada diretamente para mapear uma vulnerabilidade real. Deve-se selecionar a CWE Base mais específica.

Exemplos:

- senha armazenada diretamente na tabela: **CWE-256**;
- senha criptografada de forma reversível: **CWE-257**;
- segredo gravado no código-fonte: **CWE-798**;
- hash SHA-256 simples para senha: **CWE-916**;
- usuário `admin/admin` fornecido na instalação: **CWE-1392**;
- formulário de alteração que não verifica a identidade: **CWE-620**.

---

## 3. CWEs abordadas

| CWE | Nome | Aplicação prática em Java |
|---:|---|---|
| 256 | Plaintext Storage of a Password | Senha armazenada em tabela, arquivo, cache, sessão ou memória sem proteção |
| 257 | Storing Passwords in a Recoverable Format | Senha criptografada de forma reversível quando apenas a verificação é necessária |
| 260 | Password in Configuration File | Senha em `.properties`, YAML, XML, `web.xml`, script ou imagem de container |
| 261 | Weak Encoding for Password | Base64, hexadecimal, URL encoding ou transformação equivalente usada como proteção |
| 262 | Not Using Password Aging | Credencial comprometida ou temporária permanece válida indefinidamente |
| 263 | Password Aging with Long Expiration | Política de expiração tão longa que não reduz o risco pretendido |
| 324 | Use of a Key Past its Expiration Date | Chave criptográfica vencida, revogada ou fora da janela de validade continua aceita |
| 521 | Weak Password Requirements | Senhas curtas, comuns, vazias ou previsíveis são aceitas |
| 523 | Unprotected Transport of Credentials | Senha, token ou chave transmitida sem proteção adequada |
| 549 | Missing Password Field Masking | Campo de senha exibido como texto ou preenchido novamente na interface |
| 620 | Unverified Password Change | Alteração de senha sem reautenticação ou prova equivalente |
| 640 | Weak Password Recovery Mechanism | Token previsível, reutilizável, duradouro ou fluxo que revela contas |
| 798 | Use of Hard-coded Credentials | Senha, token, chave ou segredo fixo no código ou artefato |
| 916 | Password Hash with Insufficient Computational Effort | MD5, SHA-1, SHA-256 simples ou KDF com custo insuficiente |
| 1392 | Use of Default Credentials | Credenciais padrão conhecidas e não substituídas na implantação |

---

## 4. Conceitos fundamentais

### 4.1 Senha não é chave de criptografia nem token

Embora todos sejam segredos, possuem ciclos de vida e proteções diferentes.

| Item | Uso principal | Armazenamento recomendado |
|---|---|---|
| Senha humana | Autenticar uma pessoa | Hash lento, com salt único |
| Chave de API | Autenticar cliente ou integração | Secret manager; armazenar hash quando só é preciso validar |
| Token de acesso | Autorizar chamadas por tempo limitado | Vida curta; evitar persistência desnecessária |
| Refresh token | Obter novos tokens | Armazenamento protegido, rotação e revogação |
| Chave simétrica | Criptografar ou assinar | KMS/HSM/secret manager; versão e rotação |
| Chave privada | Assinatura ou autenticação | Keystore/KMS/HSM; acesso mínimo |
| Token de recuperação | Recuperar conta | Aleatório, uso único, curta duração e hash no banco |

### 4.2 Hash não é criptografia

**Hash de senha:**

- não deve ser reversível;
- serve para comparar uma senha apresentada com um verificador armazenado;
- deve usar algoritmo próprio para senhas;
- precisa de salt único;
- deve ter custo ajustável.

**Criptografia:**

- é reversível mediante uma chave;
- deve ser usada apenas quando o valor original realmente precisa ser recuperado;
- não é a opção correta para armazenar senha de autenticação.

### 4.3 Encoding não protege segredo

As seguintes transformações não fornecem confidencialidade:

- Base64;
- hexadecimal;
- URL encoding;
- ROT13;
- inversão da string;
- XOR com valor fixo;
- compressão;
- substituição de caracteres.

```java
String protegido = Base64.getEncoder()
        .encodeToString(senha.getBytes(StandardCharsets.UTF_8));
```

O resultado pode ser revertido sem qualquer chave.

### 4.4 Salt, pepper e fator de custo

**Salt:**

- valor aleatório e único para cada senha;
- pode ser armazenado junto com o hash;
- impede que senhas iguais gerem o mesmo resultado;
- dificulta tabelas pré-computadas.

**Pepper:**

- segredo adicional mantido fora do banco;
- opcional;
- deve ficar em secret manager, KMS ou serviço equivalente;
- sua rotação exige estratégia específica.

**Fator de custo:**

- torna cada tentativa de senha propositalmente cara;
- deve ser calibrado para o ambiente;
- precisa ser revisto conforme hardware e orientação técnica evoluem.

### 4.5 `String` versus `char[]`

Uma `String` é imutável e sua permanência em memória não pode ser controlada diretamente.

Quando a API permitir, prefira receber senhas em `char[]` e limpar o array após o uso:

```java
char[] senha = obterSenha();

try {
    autenticar(senha);
} finally {
    Arrays.fill(senha, '\0');
}
```

Isso reduz a janela de exposição, mas não elimina todos os riscos de memória, cópias internas, heap dump ou instrumentação.

### 4.6 Nunca registrar credenciais

Não registrar:

```java
log.debug("Login: usuario={}, senha={}", usuario, senha);
log.info("Authorization: {}", authorizationHeader);
log.error("Falha na integração. apiKey={}", apiKey);
```

Registrar apenas informações operacionais não sensíveis:

```java
log.warn(
    "Falha de autenticação. usuario={}, correlationId={}",
    usuarioNormalizado,
    correlationId
);
```

---

# 5. CWE-256 - Plaintext Storage of a Password

## 5.1 Conceito

O produto armazena uma senha em texto puro em recurso como:

- banco de dados;
- arquivo;
- cache;
- sessão;
- variável global;
- histórico;
- backup;
- log;
- fila;
- objeto serializado.

Se o recurso for acessado, a senha pode ser usada diretamente.

## 5.2 Exemplo vulnerável

```java
public void cadastrarUsuario(String login, String senha) throws SQLException {
    String sql =
        "INSERT INTO usuario (login, senha) "
      + "VALUES (?, ?)";

    try (Connection connection = dataSource.getConnection();
         PreparedStatement ps = connection.prepareStatement(sql)) {

        ps.setString(1, login);
        ps.setString(2, senha); // Senha em texto puro.
        ps.executeUpdate();
    }
}
```

Também é vulnerável:

```java
request.getSession().setAttribute("senhaUsuario", senha);
```

## 5.3 Solução

Armazenar um verificador produzido por algoritmo específico para senha:

```java
public void cadastrarUsuario(String login, char[] senha) throws SQLException {
    String verificador = passwordHasher.hash(senha);

    try {
        usuarioDAO.inserir(login, verificador);
    } finally {
        Arrays.fill(senha, '\0');
    }
}
```

Na autenticação:

```java
public boolean autenticar(String login, char[] senhaInformada) {
    Usuario usuario = usuarioDAO.obterPorLogin(login);

    if (usuario == null) {
        passwordHasher.executarHashFicticio(senhaInformada);
        return false;
    }

    return passwordHasher.matches(
        senhaInformada,
        usuario.getPasswordVerifier()
    );
}
```

A execução de hash fictício quando o usuário não existe ajuda a reduzir diferenças de tempo e evita tornar a enumeração de contas ainda mais simples.

## 5.4 Cuidados adicionais

- não copiar a senha para DTOs de resposta;
- não salvar senha em tabela de histórico;
- não armazenar a senha para “lembrar” ao usuário;
- não persistir senha em sessão HTTP;
- bloquear heap dumps não autorizados;
- proteger backups e réplicas;
- limitar acesso administrativo à coluna de verificadores.

---

# 6. CWE-257 - Storing Passwords in a Recoverable Format

## 6.1 Conceito

A senha é armazenada de uma forma que permite recuperar o valor original.

Exemplos:

- AES com chave conhecida pela própria aplicação;
- criptografia reversível com chave no mesmo servidor;
- banco que permite descriptografar todas as senhas;
- “esqueci minha senha” que envia a senha antiga por e-mail.

Se o sistema só precisa validar a senha, não existe justificativa para recuperá-la.

## 6.2 Exemplo vulnerável

```java
public void salvarSenha(Long idUsuario, String senha) {
    String senhaCriptografada = cryptoService.encrypt(senha);
    usuarioDAO.atualizarSenha(idUsuario, senhaCriptografada);
}

public String recuperarSenha(Long idUsuario) {
    String valor = usuarioDAO.obterSenha(idUsuario);
    return cryptoService.decrypt(valor);
}
```

Além da recuperação indevida, o comprometimento da chave pode expor todas as senhas.

## 6.3 Solução

```java
public void alterarSenha(Long idUsuario, char[] novaSenha) {
    validarPolitica(novaSenha);

    String verificador = passwordHasher.hash(novaSenha);

    try {
        usuarioDAO.atualizarPasswordVerifier(idUsuario, verificador);
        sessaoService.revogarSessoesDoUsuario(idUsuario);
    } finally {
        Arrays.fill(novaSenha, '\0');
    }
}
```

O fluxo “esqueci minha senha” deve permitir **definir uma nova senha**, nunca recuperar a anterior.

## 6.4 Quando criptografia reversível é necessária

Contas técnicas e integrações podem exigir recuperação do segredo original para autenticar em sistema externo. Nesse caso:

- não se trata de senha de usuário para validação local;
- armazenar em secret manager, KMS ou cofre;
- restringir a identidade que pode ler;
- versionar e rotacionar;
- auditar leituras;
- evitar disponibilizar o segredo para código que não precisa dele.

---

# 7. CWE-260 - Password in Configuration File

## 7.1 Conceito

Uma senha é incluída em arquivo de configuração.

Exemplos comuns:

```properties
db.user=app_user
db.password=Senha123
```

```yaml
integration:
  username: sistema
  password: segredo
```

```xml
<env-entry>
    <env-entry-name>apiPassword</env-entry-name>
    <env-entry-value>segredo</env-entry-value>
</env-entry>
```

Mesmo que o repositório seja privado, o segredo pode se espalhar para:

- histórico do Git;
- branches;
- pipelines;
- artefatos;
- backups;
- imagens de container;
- ambientes de desenvolvimento;
- estações de trabalho.

## 7.2 Exemplo vulnerável

```java
Properties properties = new Properties();

try (InputStream in = Files.newInputStream(Paths.get("config.properties"))) {
    properties.load(in);
}

String password = properties.getProperty("db.password");
Connection connection = DriverManager.getConnection(url, user, password);
```

O problema principal não é a leitura via `Properties`; é a credencial permanente gravada no arquivo.

## 7.3 Solução com provedor de segredo

```java
public interface SecretProvider {

    char[] obterSegredo(String identificador);
}
```

```java
public final class DatabaseConnectionFactory {

    private final SecretProvider secretProvider;
    private final DataSourceFactory dataSourceFactory;

    public DatabaseConnectionFactory(
            SecretProvider secretProvider,
            DataSourceFactory dataSourceFactory) {

        this.secretProvider = secretProvider;
        this.dataSourceFactory = dataSourceFactory;
    }

    public DataSource criar(DatabaseConfig config) {
        char[] password = secretProvider.obterSegredo(config.getSecretId());

        try {
            return dataSourceFactory.criar(
                config.getUrl(),
                config.getUsername(),
                password
            );
        } finally {
            Arrays.fill(password, '\0');
        }
    }
}
```

O arquivo pode conter apenas uma referência não secreta:

```properties
db.secret-id=prod/garh/database
```

## 7.4 Observação sobre variáveis de ambiente

Variável de ambiente pode ser melhor que segredo no repositório, mas não é automaticamente um cofre.

Riscos:

- inspeção por processos privilegiados;
- dump de diagnóstico;
- exibição em painel de implantação;
- vazamento em logs de pipeline;
- herança por subprocessos;
- valor exposto em manifesto.

Para segredos de alto impacto, prefira integração com secret manager/KMS e credenciais temporárias.

---

# 8. CWE-261 - Weak Encoding for Password

## 8.1 Conceito

O sistema usa uma transformação facilmente reversível como se fosse proteção de senha.

## 8.2 Exemplo vulnerável

```java
public String proteger(String senha) {
    return Base64.getEncoder()
        .encodeToString(senha.getBytes(StandardCharsets.UTF_8));
}

public boolean validar(String senhaInformada, String senhaArmazenada) {
    return proteger(senhaInformada).equals(senhaArmazenada);
}
```

Um invasor pode recuperar a senha:

```java
String senha = new String(
    Base64.getDecoder().decode(senhaArmazenada),
    StandardCharsets.UTF_8
);
```

## 8.3 Solução

```java
String verificador = passwordHasher.hash(senha);
boolean valido = passwordHasher.matches(senhaInformada, verificador);
```

### Regra prática

Caso o “mecanismo de proteção” não exija chave e possa ser revertido com uma função padrão, ele é encoding ou ofuscação, não proteção criptográfica.

---

# 9. CWE-262 e CWE-263 - Password Aging

## 9.1 Contexto histórico

A **CWE-262** trata da ausência de expiração de senha, enquanto a **CWE-263** trata de um prazo de expiração excessivamente longo.

Essas CWEs representam cenários em que uma credencial:

- é temporária;
- foi comprometida;
- pertence a conta técnica com política formal de rotação;
- deveria perder validade após determinado evento;
- continua utilizável por prazo incompatível com o risco.

## 9.2 Orientação moderna

Não se deve converter essas CWEs em uma regra genérica de “trocar todas as senhas a cada 30, 60 ou 90 dias”.

Orientações modernas, como NIST SP 800-63B, recomendam:

- não exigir mudança periódica arbitrária;
- exigir mudança quando houver evidência de comprometimento;
- bloquear senhas conhecidas como comprometidas;
- permitir senhas longas;
- evitar regras artificiais de composição que geram padrões previsíveis;
- usar MFA quando apropriado.

A troca arbitrária frequente pode induzir:

- pequenas variações da mesma senha;
- anotações em papel;
- senhas previsíveis;
- maior carga de suporte;
- falsa sensação de segurança.

## 9.3 Exemplo vulnerável: credencial inicial sem expiração

```java
public Usuario criarUsuario(String login) {
    Usuario usuario = new Usuario();
    usuario.setLogin(login);
    usuario.setPasswordVerifier(passwordHasher.hash("SenhaInicial123".toCharArray()));
    usuario.setTrocaObrigatoria(false); // Vulnerável.
    return usuarioDAO.salvar(usuario);
}
```

## 9.4 Solução

```java
public Usuario criarUsuario(String login, char[] senhaTemporaria) {
    Usuario usuario = new Usuario();
    usuario.setLogin(login);
    usuario.setPasswordVerifier(passwordHasher.hash(senhaTemporaria));
    usuario.setTrocaObrigatoria(true);
    usuario.setCredencialExpiraEm(Instant.now().plus(Duration.ofHours(24)));

    try {
        return usuarioDAO.salvar(usuario);
    } finally {
        Arrays.fill(senhaTemporaria, '\0');
    }
}
```

Na autenticação:

```java
if (usuario.isTrocaObrigatoria()
        || usuario.getCredencialExpiraEm().isBefore(Instant.now())
        || usuario.isCredencialComprometida()) {

    return AuthenticationResult.passwordChangeRequired();
}
```

## 9.5 Contas técnicas

Para contas técnicas, definir política baseada em risco:

- preferir credenciais temporárias;
- usar identidade de workload quando disponível;
- rotacionar sem indisponibilidade;
- manter versão ativa e versão anterior apenas durante janela controlada;
- revogar imediatamente quando houver comprometimento;
- não usar a mesma credencial em desenvolvimento e produção.

---

# 10. CWE-324 - Use of a Key Past its Expiration Date

## 10.1 Conceito

Uma chave criptográfica continua sendo usada ou aceita após:

- data de expiração;
- revogação;
- retirada operacional;
- comprometimento;
- substituição por nova versão;
- encerramento da finalidade ou do contrato.

Essa falha pode ocorrer em:

- assinatura de JWT;
- assinatura de webhook;
- criptografia de dados;
- certificados cliente;
- API keys;
- chaves de integração;
- chaves de sessão;
- chaves armazenadas em keystore.

## 10.2 Exemplo vulnerável

```java
public SecretKey obterChave(String keyId) {
    // Apenas localiza a chave. Não valida seu estado.
    return keyRepository.findById(keyId)
        .orElseThrow(() -> new IllegalArgumentException("Chave inexistente"))
        .toSecretKey();
}
```

## 10.3 Solução

```java
public SecretKey obterChaveAtiva(String keyId, Instant agora) {
    KeyRecord key = keyRepository.findById(keyId)
        .orElseThrow(() -> new SecurityException("Chave inválida"));

    if (key.isRevoked()) {
        throw new SecurityException("Chave revogada");
    }

    if (agora.isBefore(key.getNotBefore())) {
        throw new SecurityException("Chave ainda não está ativa");
    }

    if (!agora.isBefore(key.getExpiresAt())) {
        throw new SecurityException("Chave expirada");
    }

    if (!key.isAllowedFor(KeyUsage.SIGNING)) {
        throw new SecurityException("Uso da chave não autorizado");
    }

    return key.toSecretKey();
}
```

## 10.4 Rotação segura

Durante a rotação de assinatura:

- **emissão:** usar somente a chave atual;
- **validação:** aceitar a atual e, por janela limitada, a anterior;
- associar `keyId`/`kid` à mensagem;
- retirar a chave anterior após expiração dos artefatos emitidos;
- rejeitar chave revogada, mesmo dentro da janela;
- registrar versão e finalidade;
- impedir fallback silencioso para chave antiga.

---

# 11. CWE-521 - Weak Password Requirements

## 11.1 Conceito

O sistema permite senhas com baixa resistência a adivinhação.

Exemplos:

- senha vazia;
- senha igual ao login;
- `123456`;
- `admin`;
- nome do sistema;
- CPF ou matrícula;
- senha muito curta;
- senha encontrada em listas de credenciais comprometidas;
- credencial inicial igual para todos.

## 11.2 Exemplo vulnerável

```java
public boolean senhaValida(String senha) {
    return senha != null && senha.length() >= 4;
}
```

Uma regex como esta também não garante força real:

```java
return senha.matches("(?=.*[A-Z])(?=.*[a-z])(?=.*\\d).{8,}");
```

`Senha123` pode passar e continuar previsível.

## 11.3 Política prática

A política deve considerar:

- comprimento mínimo adequado ao risco;
- suporte a senhas longas e passphrases;
- bloqueio de senhas comuns e comprometidas;
- não truncar silenciosamente;
- aceitar espaços e caracteres Unicode quando a plataforma os trata de modo consistente;
- permitir uso de gerenciadores de senha;
- não exigir trocas arbitrárias;
- rate limiting;
- MFA para funções sensíveis;
- mensagens claras de rejeição sem revelar detalhes indevidos.

## 11.4 Exemplo

```java
public final class PasswordPolicy {

    private static final int MIN_LENGTH = 15;
    private static final int MAX_LENGTH = 128;

    private final CompromisedPasswordService compromisedPasswordService;

    public PasswordPolicy(
            CompromisedPasswordService compromisedPasswordService) {
        this.compromisedPasswordService = compromisedPasswordService;
    }

    public void validate(String login, char[] password) {
        if (password == null) {
            throw new PasswordPolicyException("Senha obrigatória");
        }

        if (password.length < MIN_LENGTH) {
            throw new PasswordPolicyException("Senha muito curta");
        }

        if (password.length > MAX_LENGTH) {
            throw new PasswordPolicyException("Senha excede o limite aceito");
        }

        String normalizedLogin = login == null
            ? ""
            : login.trim().toLowerCase(Locale.ROOT);

        String passwordText = new String(password);

        try {
            if (!normalizedLogin.isEmpty()
                    && passwordText.toLowerCase(Locale.ROOT)
                        .contains(normalizedLogin)) {
                throw new PasswordPolicyException(
                    "A senha não deve conter o identificador do usuário"
                );
            }

            if (compromisedPasswordService.isKnownCompromised(password)) {
                throw new PasswordPolicyException(
                    "Escolha uma senha que não tenha aparecido em vazamentos conhecidos"
                );
            }
        } finally {
            // passwordText é String e não pode ser zerada.
            // A conversão foi limitada a uma integração cuja API exige String.
        }
    }
}
```

Evite converter `char[]` em `String` quando a API utilizada puder trabalhar diretamente com array.

---

# 12. CWE-523 - Unprotected Transport of Credentials

## 12.1 Conceito

Credenciais são transmitidas por canal sem proteção suficiente.

Exemplos:

- login por HTTP;
- token em URL;
- API key em query string;
- FTP ou Telnet;
- certificado não validado;
- TLS desabilitado em ambiente interno;
- proxy que encerra TLS e encaminha credencial em rede não confiável;
- e-mail contendo senha permanente.

## 12.2 Exemplo vulnerável

```java
URL url = new URL(
    "http://integracao.exemplo/autenticar"
        + "?usuario=" + URLEncoder.encode(usuario, StandardCharsets.UTF_8)
        + "&senha=" + URLEncoder.encode(senha, StandardCharsets.UTF_8)
);

HttpURLConnection connection =
    (HttpURLConnection) url.openConnection();
```

Problemas:

- HTTP sem TLS;
- senha na URL;
- URL pode aparecer em logs, histórico, proxy e métricas;
- credencial pode ser capturada ou modificada.

## 12.3 Solução

```java
URL url = new URL("https://integracao.exemplo/autenticar");
HttpsURLConnection connection =
    (HttpsURLConnection) url.openConnection();

connection.setRequestMethod("POST");
connection.setRequestProperty(
    "Content-Type",
    "application/json; charset=UTF-8"
);
connection.setConnectTimeout(5_000);
connection.setReadTimeout(10_000);
connection.setDoOutput(true);

byte[] body = jsonBody.getBytes(StandardCharsets.UTF_8);

try (OutputStream output = connection.getOutputStream()) {
    output.write(body);
}

int status = connection.getResponseCode();
```

Além de HTTPS:

- validar certificado e hostname;
- não instalar `TrustManager` que aceita tudo;
- não desabilitar verificação em produção;
- preferir tokens de curta duração;
- não colocar credencial em query string;
- usar `Secure`, `HttpOnly` e `SameSite` para cookies de sessão;
- aplicar HSTS no contexto apropriado;
- proteger o canal entre proxy e backend.

## 12.4 Basic Authentication

Basic Authentication não cifra a senha; apenas codifica as credenciais em Base64. Só deve ser usado sobre TLS corretamente validado e, preferencialmente, com credencial técnica restrita e rotacionável.

---

# 13. CWE-549 - Missing Password Field Masking

## 13.1 Conceito

O campo de senha não esconde o valor digitado.

## 13.2 Exemplo vulnerável em JSP

```jsp
<input
    type="text"
    name="senha"
    value="${usuario.senha}">
```

Problemas:

- senha visível durante digitação;
- senha reapresentada pelo servidor;
- valor pode aparecer no HTML;
- navegador, extensão ou captura de tela pode expor o conteúdo;
- senha pode permanecer no bean de formulário.

## 13.3 Solução

```jsp
<input
    type="password"
    name="senha"
    id="senha"
    autocomplete="current-password"
    maxlength="128">
```

Para nova senha:

```jsp
<input
    type="password"
    name="novaSenha"
    id="novaSenha"
    autocomplete="new-password"
    maxlength="128">
```

### Regras importantes

- não preencher `value` com senha existente;
- em erro de validação, pedir nova digitação;
- não usar campo oculto para preservar senha;
- não enviar senha de volta no DTO;
- o botão “mostrar senha” deve exigir ação explícita e não alterar o valor;
- mascaramento visual não substitui TLS, hash ou controle de acesso.

## 13.4 Exemplo de botão mostrar/ocultar

```javascript
function alternarVisibilidadeSenha() {
    const campo = document.getElementById("senha");
    const exibir = campo.type === "password";
    campo.type = exibir ? "text" : "password";
}
```

O estado padrão deve ser `password`.

---

# 14. CWE-620 - Unverified Password Change

## 14.1 Conceito

A aplicação permite alterar senha sem verificar adequadamente que o solicitante controla a conta.

Cenários:

- sessão abandonada permite trocar senha;
- endpoint aceita apenas `idUsuario` e `novaSenha`;
- não pede senha atual;
- não exige step-up para operação sensível;
- administrador comum consegue trocar senha de outro usuário;
- token de recuperação não é validado.

## 14.2 Exemplo vulnerável

```java
@PostMapping("/usuario/alterar-senha")
public void alterarSenha(
        @RequestParam Long idUsuario,
        @RequestParam String novaSenha) {

    usuarioService.alterarSenha(idUsuario, novaSenha.toCharArray());
}
```

O usuário controla `idUsuario` e nenhuma prova adicional é exigida.

## 14.3 Solução para usuário autenticado

```java
public void alterarSenha(
        PrincipalContext principal,
        char[] senhaAtual,
        char[] novaSenha) {

    Usuario usuario = usuarioDAO.obterPorId(principal.userId())
        .orElseThrow(AuthenticationException::new);

    if (!passwordHasher.matches(
            senhaAtual,
            usuario.getPasswordVerifier())) {
        throw new AuthenticationException();
    }

    passwordPolicy.validate(usuario.getLogin(), novaSenha);

    String novoVerificador = passwordHasher.hash(novaSenha);

    usuarioDAO.atualizarPasswordVerifier(
        usuario.getId(),
        novoVerificador,
        Instant.now()
    );

    sessionService.revokeAllExceptCurrent(
        usuario.getId(),
        principal.sessionId()
    );

    auditService.passwordChanged(
        usuario.getId(),
        principal.sessionId()
    );
}
```

## 14.4 Operação administrativa

Quando um administrador redefine senha:

- exigir permissão específica;
- não permitir que ele veja a senha anterior;
- gerar fluxo temporário ou reset;
- obrigar troca no primeiro acesso;
- notificar o titular;
- registrar auditoria;
- impedir que perfis inferiores alterem contas superiores.

## 14.5 Reautenticação adaptativa

Para contas com MFA, uma operação crítica pode exigir:

- senha atual;
- novo desafio MFA;
- WebAuthn/passkey;
- autenticação recente;
- aprovação fora de banda.

---

# 15. CWE-640 - Weak Password Recovery Mechanism

## 15.1 Conceito

O fluxo de recuperação permite assumir a conta com esforço insuficiente.

Falhas comuns:

- pergunta secreta adivinhável;
- token sequencial;
- token baseado em timestamp;
- token curto;
- token reutilizável;
- token sem expiração;
- token armazenado em texto puro;
- resposta diferente para usuário existente;
- link construído com `Host` controlado pelo cliente;
- senha nova enviada por e-mail;
- alteração antes de validar o token.

## 15.2 Exemplo vulnerável

```java
public String gerarTokenRecuperacao(Long idUsuario) {
    return idUsuario + "-" + System.currentTimeMillis();
}
```

O valor é previsível.

Outro exemplo:

```java
if (usuarioDAO.existe(email)) {
    return "Enviamos o link para " + email;
}

return "Usuário não encontrado";
```

Isso facilita enumeração de contas.

## 15.3 Geração segura

```java
public final class ResetTokenGenerator {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final int TOKEN_BYTES = 32;

    public String generate() {
        byte[] bytes = new byte[TOKEN_BYTES];
        RANDOM.nextBytes(bytes);

        return Base64.getUrlEncoder()
            .withoutPadding()
            .encodeToString(bytes);
    }
}
```

## 15.4 Armazenar apenas o hash do token

```java
public void solicitarRecuperacao(String emailInformado) {
    String email = normalizeEmail(emailInformado);

    usuarioDAO.obterPorEmail(email).ifPresent(usuario -> {
        String token = tokenGenerator.generate();
        byte[] tokenHash = tokenHasher.sha256(token);

        resetTokenDAO.invalidateActiveTokens(usuario.getId());

        resetTokenDAO.save(new ResetTokenRecord(
            usuario.getId(),
            tokenHash,
            Instant.now().plus(Duration.ofMinutes(20)),
            false
        ));

        notificationService.sendResetLink(
            usuario.getEmail(),
            resetUrlBuilder.build(token)
        );
    });

    // A resposta externa deve ser igual existindo ou não a conta.
}
```

O SHA-256 pode ser usado para **token aleatório de alta entropia**, pois o token não é uma senha escolhida por humano. Para senhas, SHA-256 simples continua inadequado.

## 15.5 Consumo atômico

```java
@Transactional
public void redefinirSenha(String token, char[] novaSenha) {
    byte[] hash = tokenHasher.sha256(token);

    ResetTokenRecord record = resetTokenDAO
        .findValidForUpdate(hash, Instant.now())
        .orElseThrow(InvalidResetTokenException::new);

    passwordPolicy.validate(
        record.getLogin(),
        novaSenha
    );

    String verifier = passwordHasher.hash(novaSenha);

    int consumed = resetTokenDAO.consumeIfUnused(
        record.getId(),
        Instant.now()
    );

    if (consumed != 1) {
        throw new InvalidResetTokenException();
    }

    usuarioDAO.atualizarPasswordVerifier(
        record.getUserId(),
        verifier,
        Instant.now()
    );

    resetTokenDAO.invalidateAllForUser(record.getUserId());
    sessionService.revokeAll(record.getUserId());
    auditService.passwordReset(record.getUserId());
}
```

## 15.6 Requisitos do fluxo

- token criptograficamente aleatório;
- comprimento suficiente;
- uso único;
- curta duração;
- hash no banco;
- rate limit por conta, IP e contexto;
- resposta genérica;
- link HTTPS;
- origem fixa e configurada no servidor;
- não fazer login automático após reset;
- revogar sessões conforme política;
- enviar notificação;
- não usar perguntas pessoais como único fator.

---

# 16. CWE-798 - Use of Hard-coded Credentials

## 16.1 Conceito

A credencial está embutida no código-fonte ou no artefato.

## 16.2 Exemplo vulnerável

```java
public final class ProjudiClient {

    private static final String CLIENT_ID = "sistema-garh";
    private static final String CLIENT_SECRET = "prod-secret-123";

    public String obterToken() {
        return tokenClient.request(CLIENT_ID, CLIENT_SECRET);
    }
}
```

Mesmo um `private static final` pode ser extraído do bytecode, JAR, imagem ou memória.

## 16.3 Solução

```java
public final class ProjudiClient {

    private final SecretProvider secretProvider;
    private final TokenClient tokenClient;

    public ProjudiClient(
            SecretProvider secretProvider,
            TokenClient tokenClient) {
        this.secretProvider = secretProvider;
        this.tokenClient = tokenClient;
    }

    public String obterToken() {
        char[] secret = secretProvider.obterSegredo(
            "prod/projudi/client-secret"
        );

        try {
            return tokenClient.request(
                "sistema-garh",
                secret
            );
        } finally {
            Arrays.fill(secret, '\0');
        }
    }
}
```

## 16.4 O que procurar

- `password = "`;
- `secret = "`;
- `token = "`;
- `apiKey = "`;
- `Authorization: Bearer`;
- connection strings;
- certificados e chaves privadas;
- credenciais em testes que chegam ao pacote final;
- valores em Dockerfile;
- secrets em pipeline;
- senha em script SQL de carga.

## 16.5 Credenciais em histórico Git

Remover do arquivo atual não remove do histórico.

Ao identificar vazamento:

1. revogar ou rotacionar imediatamente;
2. avaliar uso indevido;
3. remover do código;
4. usar ferramenta de limpeza de histórico quando necessário;
5. revisar clones, forks, logs e artefatos;
6. implantar detecção de segredo no pipeline.

A rotação é mais importante que apenas “apagar o commit”.

---

# 17. CWE-916 - Password Hash with Insufficient Computational Effort

## 17.1 Conceito

O sistema usa hash rápido ou KDF configurada com esforço insuficiente.

Exemplos inadequados:

- MD5;
- SHA-1;
- SHA-256 simples;
- SHA-512 simples;
- hash sem salt;
- uma quantidade muito baixa de iterações;
- salt fixo para todos;
- algoritmo caseiro.

## 17.2 Exemplo vulnerável

```java
public String hash(String senha) throws NoSuchAlgorithmException {
    MessageDigest digest = MessageDigest.getInstance("SHA-256");

    byte[] hash = digest.digest(
        senha.getBytes(StandardCharsets.UTF_8)
    );

    StringBuilder result = new StringBuilder(hash.length * 2);

    for (byte value : hash) {
        result.append(String.format("%02x", value & 0xff));
    }

    return result.toString();
}
```

SHA-256 é adequado para diversas finalidades criptográficas, mas é rápido demais para armazenamento de senhas humanas.

## 17.3 Algoritmos apropriados

Opções comuns:

- Argon2id;
- scrypt;
- bcrypt;
- PBKDF2.

A escolha depende de:

- versão da plataforma;
- bibliotecas aprovadas;
- requisitos FIPS;
- memória disponível;
- capacidade operacional;
- política de atualização.

Parâmetros devem ser revistos periodicamente.

## 17.4 Exemplo PBKDF2 em Java

> O exemplo abaixo demonstra a estrutura. Em produção, prefira uma biblioteca de autenticação madura, formato versionado e parâmetros calibrados no ambiente.

```java
public final class Pbkdf2PasswordHasher {

    private static final SecureRandom RANDOM = new SecureRandom();

    private static final int SALT_BYTES = 16;
    private static final int HASH_BITS = 256;
    private static final int ITERATIONS = 600_000;

    public String hash(char[] password) {
        byte[] salt = new byte[SALT_BYTES];
        RANDOM.nextBytes(salt);

        byte[] derived = derive(password, salt, ITERATIONS, HASH_BITS);

        return String.join(
            "$",
            "pbkdf2-sha256",
            Integer.toString(ITERATIONS),
            Base64.getEncoder().encodeToString(salt),
            Base64.getEncoder().encodeToString(derived)
        );
    }

    public boolean matches(char[] password, String encoded) {
        String[] parts = encoded.split("\\$");

        if (parts.length != 5
                || !"pbkdf2-sha256".equals(parts[1])) {
            throw new IllegalArgumentException(
                "Formato de verificador inválido"
            );
        }

        int iterations = Integer.parseInt(parts[2]);
        byte[] salt = Base64.getDecoder().decode(parts[3]);
        byte[] expected = Base64.getDecoder().decode(parts[4]);

        byte[] actual = derive(
            password,
            salt,
            iterations,
            expected.length * Byte.SIZE
        );

        try {
            return MessageDigest.isEqual(expected, actual);
        } finally {
            Arrays.fill(actual, (byte) 0);
            Arrays.fill(salt, (byte) 0);
            Arrays.fill(expected, (byte) 0);
        }
    }

    private byte[] derive(
            char[] password,
            byte[] salt,
            int iterations,
            int keyLengthBits) {

        PBEKeySpec spec = new PBEKeySpec(
            password,
            salt,
            iterations,
            keyLengthBits
        );

        try {
            SecretKeyFactory factory = SecretKeyFactory.getInstance(
                "PBKDF2WithHmacSHA256"
            );

            return factory.generateSecret(spec).getEncoded();
        } catch (GeneralSecurityException e) {
            throw new IllegalStateException(
                "Falha ao calcular verificador de senha",
                e
            );
        } finally {
            spec.clearPassword();
        }
    }
}
```

### Observação sobre o formato

O valor armazenado precisa incluir:

- identificador do algoritmo;
- versão ou parâmetros;
- fator de custo;
- salt;
- resultado derivado.

Isso permite evolução futura.

## 17.5 Rehash progressivo

```java
public AuthenticationResult authenticate(
        Usuario usuario,
        char[] password) {

    if (!passwordHasher.matches(
            password,
            usuario.getPasswordVerifier())) {
        return AuthenticationResult.failure();
    }

    if (passwordHasher.needsRehash(
            usuario.getPasswordVerifier())) {

        String upgraded = passwordHasher.hash(password);

        usuarioDAO.updateVerifierIfUnchanged(
            usuario.getId(),
            usuario.getPasswordVerifier(),
            upgraded
        );
    }

    return AuthenticationResult.success(usuario.getId());
}
```

Após login bem-sucedido, hashes antigos podem ser atualizados sem exigir que o usuário troque a senha.

## 17.6 Cuidados

- limitar tamanho máximo antes da KDF para evitar abuso;
- usar comparação em tempo constante;
- calibrar custo sem causar DoS;
- rate limit no login;
- usar salt gerado por `SecureRandom`;
- não reutilizar salt fixo;
- não inventar algoritmo;
- versionar o formato;
- proteger parâmetros contra downgrade;
- medir desempenho em hardware real.

---

# 18. CWE-1392 - Use of Default Credentials

## 18.1 Conceito

O produto ou implantação usa credenciais padrão conhecidas.

Exemplos:

- `admin/admin`;
- `root/root`;
- `usuario/123456`;
- mesma senha inicial para todos;
- conta de suporte escondida;
- credencial padrão no banco;
- senha de exemplo mantida em produção;
- usuário de aplicação criado automaticamente sem troca obrigatória.

## 18.2 Exemplo vulnerável

```java
@PostConstruct
public void inicializarAdministrador() {
    if (!usuarioDAO.existeAdministrador()) {
        usuarioDAO.criar(
            "admin",
            passwordHasher.hash("admin".toCharArray())
        );
    }
}
```

## 18.3 Solução: segredo único de bootstrap

```java
@PostConstruct
public void inicializarAdministrador() {
    if (usuarioDAO.existeAdministrador()) {
        return;
    }

    char[] bootstrapSecret =
        secretProvider.obterSegredo("bootstrap/admin-password");

    try {
        passwordPolicy.validate("admin", bootstrapSecret);

        usuarioDAO.criarAdministrador(
            "admin",
            passwordHasher.hash(bootstrapSecret),
            true,
            Instant.now().plus(Duration.ofHours(2))
        );
    } finally {
        Arrays.fill(bootstrapSecret, '\0');
        secretProvider.revogar("bootstrap/admin-password");
    }
}
```

Alternativas melhores:

- fluxo de primeiro acesso;
- criação administrativa fora de banda;
- identidade federada;
- conta desabilitada até ativação segura;
- senha única aleatória por instalação;
- impedir inicialização se o segredo não foi configurado.

## 18.4 Falhar de forma segura

```java
String secretId = config.getBootstrapSecretId();

if (secretId == null || secretId.trim().isEmpty()) {
    throw new IllegalStateException(
        "Credencial inicial não configurada. "
        + "A aplicação não será iniciada com valor padrão."
    );
}
```

Nunca fazer fallback:

```java
String senha = Optional.ofNullable(config.getSenha())
    .orElse("admin"); // Vulnerável.
```

---

# 19. Componentes reutilizáveis

## 19.1 Modelo de verificador de senha

```java
public interface PasswordHasher {

    String hash(char[] password);

    boolean matches(char[] password, String verifier);

    boolean needsRehash(String verifier);

    default void executarHashFicticio(char[] password) {
        hash(password);
    }
}
```

## 19.2 Provedor de segredos

```java
public interface SecretProvider {

    char[] obterSegredo(String secretId);

    void revogar(String secretId);
}
```

A implementação pode integrar:

- HashiCorp Vault;
- AWS Secrets Manager;
- Azure Key Vault;
- Google Secret Manager;
- Kubernetes Secrets com proteção adequada;
- keystore do application server;
- serviço corporativo de cofres;
- HSM/KMS.

## 19.3 Serviço de alteração de credencial

```java
public final class CredentialChangeService {

    private final UsuarioDAO usuarioDAO;
    private final PasswordHasher passwordHasher;
    private final PasswordPolicy passwordPolicy;
    private final SessionService sessionService;
    private final AuditService auditService;

    @Transactional
    public void changePassword(
            AuthenticatedPrincipal principal,
            char[] currentPassword,
            char[] newPassword) {

        Usuario usuario = usuarioDAO
            .findByIdForUpdate(principal.userId())
            .orElseThrow(AuthenticationException::new);

        if (!passwordHasher.matches(
                currentPassword,
                usuario.getPasswordVerifier())) {
            auditService.passwordChangeRejected(
                usuario.getId(),
                principal.sessionId()
            );
            throw new AuthenticationException();
        }

        passwordPolicy.validate(
            usuario.getLogin(),
            newPassword
        );

        if (passwordHasher.matches(
                newPassword,
                usuario.getPasswordVerifier())) {
            throw new PasswordPolicyException(
                "A nova senha deve ser diferente da atual"
            );
        }

        String verifier = passwordHasher.hash(newPassword);

        usuarioDAO.updatePassword(
            usuario.getId(),
            verifier,
            Instant.now()
        );

        sessionService.revokeAllExceptCurrent(
            usuario.getId(),
            principal.sessionId()
        );

        auditService.passwordChanged(
            usuario.getId(),
            principal.sessionId()
        );
    }
}
```

## 19.4 Limpeza de parâmetros sensíveis

```java
public final class SensitiveData {

    private SensitiveData() {
    }

    public static void clear(char[] value) {
        if (value != null) {
            Arrays.fill(value, '\0');
        }
    }

    public static void clear(byte[] value) {
        if (value != null) {
            Arrays.fill(value, (byte) 0);
        }
    }
}
```

Uso:

```java
try {
    credentialService.changePassword(
        principal,
        senhaAtual,
        novaSenha
    );
} finally {
    SensitiveData.clear(senhaAtual);
    SensitiveData.clear(novaSenha);
}
```

---

# 20. Distinções importantes entre as CWEs

## 20.1 CWE-256 versus CWE-257

| Situação | CWE |
|---|---:|
| Senha gravada exatamente como foi digitada | 256 |
| Senha criptografada e recuperável | 257 |
| Senha em Base64 | 261 e possivelmente 256 |
| Hash rápido SHA-256 | 916 |
| Senha literal no código | 798 |

## 20.2 CWE-260 versus CWE-798

| Situação | CWE principal |
|---|---:|
| Senha em `application.properties` | 260 |
| Senha em constante Java | 798 |
| Senha no Dockerfile | 798 ou 260, conforme contexto |
| Referência a secret ID no arquivo | Normalmente não é credencial |
| Segredo injetado em runtime por cofre | Prática preferível |

## 20.3 CWE-521 versus CWE-916

- **CWE-521:** qualidade da senha escolhida.
- **CWE-916:** qualidade do mecanismo que protege a senha armazenada.

Uma senha forte ainda fica vulnerável se armazenada com SHA-256 simples.

## 20.4 CWE-620 versus CWE-640

- **CWE-620:** alteração de senha sem verificar o solicitante.
- **CWE-640:** fluxo de recuperação fraco.

O endpoint final de reset pode conter ambas se aceitar token fraco e não validar corretamente a conta.

## 20.5 CWE-262/263 versus política moderna

Não mapear automaticamente ausência de expiração periódica como vulnerabilidade.

Perguntar:

- a credencial era temporária?
- houve comprometimento?
- existe exigência de rotação por natureza da chave?
- a conta técnica continua ativa após mudança de equipe?
- o segredo possui prazo operacional definido?
- a chave foi revogada ou substituída?

---

# 21. Revisão de código

## 21.1 Perguntas

### Armazenamento

- Existe senha em texto puro?
- É possível recuperar a senha original?
- Há hash específico para senha?
- Cada senha recebe salt único?
- O formato permite evolução?
- Existe acesso excessivo à coluna de verificadores?
- Backups possuem a mesma proteção do banco principal?

### Configuração e código

- Existem segredos no repositório?
- Há credenciais em arquivos de configuração?
- O pipeline imprime variáveis sensíveis?
- Imagens ou pacotes carregam arquivos `.env`?
- Testes contêm credenciais reais?
- Existe fallback para senha padrão?

### Transporte

- Todo envio de credencial usa TLS validado?
- Há token em query string?
- Cookies de sessão possuem atributos seguros?
- O canal entre proxy e backend é protegido?
- O cliente valida certificado e hostname?
- Há `TrustManager` permissivo?

### Alteração e recuperação

- A troca exige senha atual ou step-up?
- O usuário pode alterar senha de outra conta?
- O token de reset é aleatório?
- O token expira?
- É de uso único?
- O banco armazena apenas seu hash?
- A resposta evita enumeração de contas?
- As sessões antigas são revogadas?

### Rotação

- Chaves têm versão, finalidade e validade?
- Credenciais técnicas podem ser rotacionadas sem downtime?
- Chaves revogadas são rejeitadas?
- Existe inventário de segredos?
- O mesmo segredo é usado em múltiplos ambientes?

---

# 22. Comandos de busca no código

Os comandos abaixo ajudam na triagem, mas produzem falsos positivos.

## 22.1 Possíveis credenciais

```bash
grep -RniE \
  '(password|passwd|pwd|senha|secret|token|api[_-]?key|client[_-]?secret)[[:space:]]*=' \
  src/ config/ .
```

## 22.2 Strings suspeitas

```bash
grep -RniE \
  '(password|senha|secret|token|apiKey)[[:space:]]*=[[:space:]]*"[^"]+"' \
  src/
```

## 22.3 Hashes inadequados

```bash
grep -RniE \
  'MessageDigest\.getInstance\("(MD5|SHA-1|SHA-256|SHA-512)"\)' \
  src/
```

O resultado não é sempre vulnerável: esses hashes podem ser apropriados para integridade, tokens aleatórios ou checksums. Deve-se verificar se o dado é uma senha humana.

## 22.4 Base64 aplicado a segredo

```bash
grep -RniE \
  'Base64\.(getEncoder|getDecoder)|DatatypeConverter' \
  src/
```

## 22.5 TLS inseguro

```bash
grep -RniE \
  'TrustAll|HostnameVerifier|setDefaultHostnameVerifier|X509TrustManager|http://' \
  src/ config/
```

## 22.6 Campos JSP

```bash
grep -RniE \
  '<input[^>]+(name|id)="[^"]*(senha|password)[^"]*"[^>]*type="text"' \
  web/ src/main/webapp/
```

## 22.7 Segredo em logs

```bash
grep -RniE \
  '(log|logger)\.(trace|debug|info|warn|error).*'\
'(senha|password|authorization|token|secret|apiKey)' \
  src/
```

## 22.8 Credenciais padrão

```bash
grep -RniE \
  '(admin|root|user)[/:_-](admin|root|1234|123456|password)|orElse\("(admin|123456|password)"\)' \
  src/ config/ scripts/
```

---

# 23. Testes sugeridos

## 23.1 Armazenamento

1. Criar dois usuários com a mesma senha.
2. Verificar que os valores armazenados são diferentes por causa do salt.
3. Confirmar que a senha original não aparece no banco.
4. Confirmar que o login funciona com a senha correta.
5. Confirmar rejeição para senha incorreta.
6. Verificar atualização progressiva de hash antigo.

## 23.2 Recuperação

1. Solicitar reset para conta existente e inexistente.
2. Confirmar resposta externa equivalente.
3. Confirmar que tokens são diferentes.
4. Tentar reutilizar token consumido.
5. Tentar token expirado.
6. Tentar token alterado.
7. Realizar duas requisições simultâneas com o mesmo token.
8. Confirmar que apenas uma conclui.
9. Confirmar revogação das sessões.
10. Confirmar notificação ao usuário.

## 23.3 Alteração de senha

1. Alterar com senha atual correta.
2. Tentar com senha atual incorreta.
3. Alterar `idUsuario` no request.
4. Tentar CSRF quando a aplicação usa sessão/cookie.
5. Tentar reutilizar sessão antiga após alteração.
6. Confirmar auditoria sem registrar a senha.
7. Validar permissão administrativa.

## 23.4 Transporte

1. Tentar acessar endpoint de autenticação via HTTP.
2. Confirmar redirect seguro ou rejeição.
3. Verificar se tokens aparecem em URL.
4. Testar certificado inválido.
5. Testar hostname divergente.
6. Inspecionar logs de proxy e access log.
7. Verificar cabeçalhos e cookies.

## 23.5 Segredos e rotação

1. Rotacionar chave sem reiniciar a aplicação.
2. Confirmar emissão apenas com a chave atual.
3. Confirmar validação temporária com chave anterior.
4. Revogar chave anterior e testar rejeição.
5. Tentar usar chave fora da validade.
6. Confirmar auditoria de leitura do segredo.
7. Confirmar segregação entre ambientes.

## 23.6 Credenciais padrão

1. Instalar a aplicação sem fornecer segredo inicial.
2. Confirmar que ela falha de forma segura.
3. Verificar que não existe `admin/admin`.
4. Confirmar troca obrigatória de credencial de bootstrap.
5. Confirmar expiração e revogação do segredo inicial.

---

# 24. Exemplo de testes unitários

## 24.1 Token de uso único

```java
@Test
void tokenDeResetSoPodeSerConsumidoUmaVez() {
    String token = resetService.requestReset("usuario@exemplo.com");

    resetService.resetPassword(
        token,
        "uma senha longa e exclusiva".toCharArray()
    );

    assertThrows(
        InvalidResetTokenException.class,
        () -> resetService.resetPassword(
            token,
            "outra senha longa e exclusiva".toCharArray()
        )
    );
}
```

## 24.2 Salt único

```java
@Test
void senhasIguaisDevemGerarVerificadoresDiferentes() {
    char[] password = "uma senha longa para teste".toCharArray();

    String first = passwordHasher.hash(password);
    String second = passwordHasher.hash(password);

    assertNotEquals(first, second);
    assertTrue(passwordHasher.matches(password, first));
    assertTrue(passwordHasher.matches(password, second));
}
```

## 24.3 Chave expirada

```java
@Test
void chaveExpiradaDeveSerRejeitada() {
    Instant now = Instant.parse("2026-07-14T12:00:00Z");

    keyRepository.save(new KeyRecord(
        "key-2025",
        now.minus(Duration.ofDays(400)),
        now.minus(Duration.ofDays(1)),
        false,
        KeyUsage.SIGNING
    ));

    assertThrows(
        SecurityException.class,
        () -> keyService.obterChaveAtiva("key-2025", now)
    );
}
```

---

# 25. Resumo para prova

## CWE-255

Categoria que agrupa erros de gerenciamento de credenciais. Não deve ser usada diretamente no mapeamento quando uma CWE Base mais específica estiver disponível.

## CWE-256

Senha armazenada em texto puro.

## CWE-257

Senha armazenada de forma reversível.

## CWE-260

Senha incluída em arquivo de configuração.

## CWE-261

Encoding ou ofuscação fraca usada como proteção.

## CWE-262

Credencial que deveria expirar ou ser trocada permanece válida indefinidamente. Não significa impor troca periódica arbitrária a todas as senhas.

## CWE-263

Prazo de expiração incompatível com o risco e com a finalidade da credencial.

## CWE-324

Uso de chave expirada, revogada ou retirada.

## CWE-521

Política permite senha fraca, curta, comum ou comprometida.

## CWE-523

Credencial transmitida por canal desprotegido.

## CWE-549

Campo de senha não é mascarado ou a senha é reapresentada na interface.

## CWE-620

Alteração de senha sem verificar adequadamente o solicitante.

## CWE-640

Fluxo de recuperação utiliza token, pergunta ou processo fraco.

## CWE-798

Credencial fixa embutida no código ou artefato.

## CWE-916

Hash de senha rápido, sem salt ou com custo insuficiente.

## CWE-1392

Uso de credenciais padrão conhecidas ou compartilhadas.

---

# 26. Quadro de decisão rápida

| Evidência encontrada | CWE mais provável |
|---|---:|
| Coluna `senha` contém valor original | 256 |
| Aplicação descriptografa senha de usuário | 257 |
| `db.password` está no `.properties` | 260 |
| Base64 foi usado para “proteger” senha | 261 |
| Senha temporária nunca expira | 262 |
| Conta técnica mantém segredo muito além da política | 263 |
| Chave vencida ainda valida assinatura | 324 |
| Sistema aceita `123456` | 521 |
| Token é transmitido por HTTP | 523 |
| JSP usa `type="text"` para senha | 549 |
| Troca de senha aceita apenas `id` e nova senha | 620 |
| Token de reset é previsível ou reutilizável | 640 |
| `CLIENT_SECRET` literal no Java | 798 |
| Senha usa SHA-256 simples | 916 |
| Instalação cria `admin/admin` | 1392 |

---

# 27. Referências

## MITRE CWE

- [CWE-255 - Credentials Management Errors](https://cwe.mitre.org/data/definitions/255.html)
- [CWE-256 - Plaintext Storage of a Password](https://cwe.mitre.org/data/definitions/256.html)
- [CWE-257 - Storing Passwords in a Recoverable Format](https://cwe.mitre.org/data/definitions/257.html)
- [CWE-260 - Password in Configuration File](https://cwe.mitre.org/data/definitions/260.html)
- [CWE-261 - Weak Encoding for Password](https://cwe.mitre.org/data/definitions/261.html)
- [CWE-262 - Not Using Password Aging](https://cwe.mitre.org/data/definitions/262.html)
- [CWE-263 - Password Aging with Long Expiration](https://cwe.mitre.org/data/definitions/263.html)
- [CWE-324 - Use of a Key Past its Expiration Date](https://cwe.mitre.org/data/definitions/324.html)
- [CWE-521 - Weak Password Requirements](https://cwe.mitre.org/data/definitions/521.html)
- [CWE-523 - Unprotected Transport of Credentials](https://cwe.mitre.org/data/definitions/523.html)
- [CWE-549 - Missing Password Field Masking](https://cwe.mitre.org/data/definitions/549.html)
- [CWE-620 - Unverified Password Change](https://cwe.mitre.org/data/definitions/620.html)
- [CWE-640 - Weak Password Recovery Mechanism for Forgotten Password](https://cwe.mitre.org/data/definitions/640.html)
- [CWE-798 - Use of Hard-coded Credentials](https://cwe.mitre.org/data/definitions/798.html)
- [CWE-916 - Use of Password Hash with Insufficient Computational Effort](https://cwe.mitre.org/data/definitions/916.html)
- [CWE-1392 - Use of Default Credentials](https://cwe.mitre.org/data/definitions/1392.html)

## Orientações complementares

- [NIST SP 800-63B - Authentication and Authenticator Management](https://pages.nist.gov/800-63-4/sp800-63b.html)
- [OWASP Password Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html)
- [OWASP Forgot Password Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Forgot_Password_Cheat_Sheet.html)
- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [OWASP REST Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/REST_Security_Cheat_Sheet.html)
- [Oracle Java Cryptography Architecture Reference Guide](https://docs.oracle.com/javase/8/docs/technotes/guides/security/crypto/CryptoSpec.html)

---

## 28. Conclusão

A proteção de credenciais não se resume a “criptografar a senha”.

Uma implementação segura precisa garantir:

- senha humana armazenada com hash lento e salt único;
- segredo técnico fora do código e do repositório;
- transporte somente por canal protegido;
- alteração e recuperação com verificação forte;
- tokens aleatórios, temporários e de uso único;
- chaves versionadas, rotacionadas e rejeitadas após expiração ou revogação;
- ausência de credenciais padrão;
- logs e interfaces sem exposição de segredo;
- capacidade operacional de revogar e rotacionar credenciais.

A regra central é:

> Uma credencial deve ser protegida durante todo o seu ciclo de vida e permanecer acessível somente às identidades, componentes e operações que realmente precisam utilizá-la.
