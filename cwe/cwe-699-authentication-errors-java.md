# CWE-699 — Software Development

## Categoria: CWE-1211 — Authentication Errors

> **Objetivo:** material prático para revisão e uso em GitHub, com foco em sistemas Java web, APIs REST, Struts/Servlet/JSP e backends corporativos.

> **Fonte principal:** MITRE CWE — `https://cwe.mitre.org/data/definitions/1211.html`  
> A CWE-1211 é uma **Category** dentro da view **CWE-699 - Software Development**. Por ser categoria, não deve ser usada diretamente para mapear vulnerabilidades reais. Para mapeamento e análise prática, use as CWEs Base listadas nesta documentação.

---

## 1. Visão geral

A categoria **Authentication Errors** reúne fraquezas relacionadas à autenticação, ou seja, à capacidade do sistema verificar que uma entidade realmente é quem afirma ser.

Em aplicações Java, esses problemas aparecem com frequência em:

- filtros de autenticação incompletos;
- Actions Struts acessíveis diretamente;
- endpoints REST administrativos sem proteção;
- autenticação baseada em IP, header, `Referer` ou parâmetro de request;
- uso de senha ou hash como credencial reaproveitável;
- ausência de MFA em funções críticas;
- validação incorreta de certificados TLS;
- ausência de limitação de tentativas de login;
- mecanismos de bloqueio que permitem negação de serviço contra usuários legítimos;
- protocolos caseiros de autenticação.

---

## 2. Mapa rápido da categoria

| CWE | Nome | Ideia central | Exemplo típico em Java |
|---:|---|---|---|
| 289 | Authentication Bypass by Alternate Name | autentica ou autoriza usando nome alternativo, caminho, alias ou variação de representação | `/admin`, `/Admin`, `%2Fadmin`, usuário `admin ` |
| 290 | Authentication Bypass by Spoofing | confia em dado falsificável como IP, header ou origem | `X-Forwarded-For`, `Referer`, `User-Agent` |
| 294 | Authentication Bypass by Capture-replay | aceita a repetição de uma mensagem válida capturada | token HMAC sem nonce/timestamp |
| 295 | Improper Certificate Validation | ignora ou valida incorretamente certificado TLS | `TrustManager` que aceita tudo |
| 301 | Reflection Attack in an Authentication Protocol | protocolo de desafio-resposta permite refletir o desafio para autenticar indevidamente | autenticação mútua caseira com mesma chave nos dois sentidos |
| 303 | Incorrect Implementation of Authentication Algorithm | algoritmo esperado é correto, mas foi implementado errado | valida assinatura **ou** expiração em vez de validar ambos |
| 305 | Authentication Bypass by Primary Weakness | autenticação é burlada por outra falha primária | SQL Injection no login |
| 306 | Missing Authentication for Critical Function | função crítica não exige autenticação | Action administrativa pública |
| 307 | Improper Restriction of Excessive Authentication Attempts | não limita tentativas excessivas de autenticação | brute force sem rate limit |
| 308 | Use of Single-factor Authentication | usa apenas um fator quando deveria exigir mais | operação sensível só com senha |
| 309 | Use of Password System for Primary Authentication | depende de senhas como mecanismo principal, com limitações inerentes | login apenas por senha em área crítica |
| 322 | Key Exchange without Entity Authentication | troca chave sem autenticar a entidade | Diffie-Hellman puro sem TLS/certificado |
| 603 | Use of Client-Side Authentication | autentica no cliente, mas não no servidor | JavaScript decide se usuário é admin |
| 645 | Overly Restrictive Account Lockout Mechanism | bloqueio de conta pode virar DoS | trava conta por 24h após 3 erros |
| 804 | Guessable CAPTCHA | CAPTCHA previsível ou automatizável | pergunta matemática simples ou resposta no HTML |
| 836 | Use of Password Hash Instead of Password for Authentication | cliente envia hash e servidor compara o hash como se fosse senha | “pass-the-hash” em aplicação web |

---

## 3. Princípios seguros para autenticação em Java

Antes das CWEs específicas, estes princípios evitam várias falhas da categoria:

1. **Autenticação centralizada:** use filtro, interceptor, framework de segurança ou gateway. Não espalhe `if (session != null)` em cada Action.
2. **Autorização separada da autenticação:** estar logado não significa poder executar função administrativa.
3. **Nada crítico apenas no cliente:** JavaScript, hidden field, cookie manipulável e parâmetro de request não autenticam ninguém.
4. **Sessão e token no servidor:** valide sessão, token, assinatura, expiração, audiência, emissor e revogação quando aplicável.
5. **TLS correto:** nunca use `TrustManager` ou `HostnameVerifier` que aceita tudo em produção.
6. **Rate limit e auditoria:** login, recuperação de senha, MFA e CAPTCHA devem ter controle de frequência e log de evento de segurança.
7. **MFA/step-up:** funções críticas devem exigir fator adicional ou reautenticação.
8. **Senha nunca é logada, retornada ou usada fora do fluxo de autenticação.**

---

## 4. Base de apoio para os exemplos

Os exemplos abaixo usam classes simples para representar padrões que podem ser adaptados para Struts, Servlet, Spring MVC ou REST.

### 4.1 Usuário autenticado

```java
public final class UsuarioAutenticado {
    private final Long id;
    private final String login;
    private final Set<String> permissoes;
    private final boolean mfaValidado;

    public UsuarioAutenticado(Long id, String login, Set<String> permissoes, boolean mfaValidado) {
        this.id = id;
        this.login = login;
        this.permissoes = permissoes;
        this.mfaValidado = mfaValidado;
    }

    public Long getId() {
        return id;
    }

    public String getLogin() {
        return login;
    }

    public boolean possuiPermissao(String permissao) {
        return permissoes != null && permissoes.contains(permissao);
    }

    public boolean isMfaValidado() {
        return mfaValidado;
    }
}
```

### 4.2 Guarda de autenticação e autorização

```java
public final class AuthGuard {

    private AuthGuard() {
    }

    public static UsuarioAutenticado exigirUsuario(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            throw new SecurityException("Usuário não autenticado.");
        }

        Object usuario = session.getAttribute("USUARIO_AUTENTICADO");
        if (!(usuario instanceof UsuarioAutenticado)) {
            throw new SecurityException("Usuário não autenticado.");
        }

        return (UsuarioAutenticado) usuario;
    }

    public static UsuarioAutenticado exigirPermissao(HttpServletRequest request, String permissao) {
        UsuarioAutenticado usuario = exigirUsuario(request);
        if (!usuario.possuiPermissao(permissao)) {
            throw new SecurityException("Usuário sem permissão: " + permissao);
        }
        return usuario;
    }

    public static UsuarioAutenticado exigirMfa(HttpServletRequest request, String permissao) {
        UsuarioAutenticado usuario = exigirPermissao(request, permissao);
        if (!usuario.isMfaValidado()) {
            throw new SecurityException("MFA obrigatório para esta operação.");
        }
        return usuario;
    }
}
```

### 4.3 Filtro centralizado

```java
public class AuthenticationFilter implements Filter {

    private static final Set<String> ROTAS_PUBLICAS = new HashSet<>(Arrays.asList(
            "/login.do",
            "/logout.do",
            "/recuperarSenha.do",
            "/assets/"
    ));

    @Override
    public void doFilter(ServletRequest servletRequest,
                         ServletResponse servletResponse,
                         FilterChain chain) throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;

        String path = normalizarPath(request);

        if (isRotaPublica(path)) {
            chain.doFilter(request, response);
            return;
        }

        try {
            AuthGuard.exigirUsuario(request);
            chain.doFilter(request, response);
        } catch (SecurityException e) {
            response.sendRedirect(request.getContextPath() + "/login.do");
        }
    }

    private String normalizarPath(HttpServletRequest request) {
        String contextPath = request.getContextPath();
        String uri = request.getRequestURI();
        String path = uri.substring(contextPath.length());
        return path.replaceAll("/{2,}", "/");
    }

    private boolean isRotaPublica(String path) {
        return ROTAS_PUBLICAS.stream().anyMatch(path::startsWith);
    }
}
```

---

# 5. CWE-289 — Authentication Bypass by Alternate Name

## Descrição prática

Ocorre quando o sistema toma decisão de autenticação/autorização com base no nome de um recurso ou ator, mas não considera nomes alternativos, alias, diferenças de caixa, URL encoding, caminhos equivalentes ou normalização.

## Exemplo vulnerável

```java
public boolean exigeLogin(HttpServletRequest request) {
    String uri = request.getRequestURI();

    // Vulnerável: só protege exatamente /admin/.
    // Pode falhar com /Admin/, /admin, /admin//, /%61dmin/, etc.
    return uri.startsWith("/sistema/admin/");
}
```

Problemas:

- confia no texto bruto da URI;
- não canonicaliza a entrada;
- trata caminhos equivalentes como diferentes;
- pode permitir bypass por variação de nome.

## Solução segura

```java
public final class RotaSeguraService {

    private static final Set<String> ROTAS_ADMIN = new HashSet<>(Arrays.asList(
            "/admin/manterUsuarios.do",
            "/admin/reprocessarIntegracao.do",
            "/admin/limparCache.do"
    ));

    public boolean isRotaAdmin(HttpServletRequest request) {
        String path = normalizarPath(request);
        return ROTAS_ADMIN.contains(path);
    }

    private String normalizarPath(HttpServletRequest request) {
        try {
            URI uri = new URI(request.getRequestURI()).normalize();
            String contextPath = request.getContextPath();
            String path = uri.getPath().substring(contextPath.length());
            path = URLDecoder.decode(path, StandardCharsets.UTF_8.name());
            path = path.replaceAll("/{2,}", "/");
            return path;
        } catch (Exception e) {
            throw new SecurityException("URI inválida.", e);
        }
    }
}
```

## Checklist de revisão

- Existe comparação direta com `request.getRequestURI()`?
- Existe regra baseada em `contains("admin")`, `startsWith(...)` ou sufixo de arquivo?
- O sistema normaliza URI antes de validar?
- A proteção está em filtro/interceptor central ou espalhada em métodos?

---

# 6. CWE-290 — Authentication Bypass by Spoofing

## Descrição prática

Ocorre quando o sistema autentica uma entidade usando informação falsificável. Em aplicações web, os casos comuns são IP, `X-Forwarded-For`, `Referer`, `Origin`, `User-Agent` ou nome de máquina.

## Exemplo vulnerável

```java
public boolean isServicoInterno(HttpServletRequest request) {
    String ip = request.getHeader("X-Forwarded-For");

    // Vulnerável: o cliente pode forjar esse header.
    return "10.0.0.15".equals(ip);
}

public void reprocessar(HttpServletRequest request) {
    if (!isServicoInterno(request)) {
        throw new SecurityException("Acesso negado.");
    }

    executarReprocessamento();
}
```

## Solução segura

Use autenticação real entre sistemas: mTLS, token assinado, OAuth2 client credentials, chave de API com HMAC ou JWT validado corretamente.

```java
public final class ServiceTokenValidator {

    private final JwtVerifier jwtVerifier;

    public ServiceTokenValidator(JwtVerifier jwtVerifier) {
        this.jwtVerifier = jwtVerifier;
    }

    public void exigirServicoAutenticado(HttpServletRequest request, String escopoObrigatorio) {
        String authorization = request.getHeader("Authorization");
        if (authorization == null || !authorization.startsWith("Bearer ")) {
            throw new SecurityException("Token ausente.");
        }

        String token = authorization.substring("Bearer ".length());
        JwtClaims claims = jwtVerifier.validar(token);

        if (!claims.getScopes().contains(escopoObrigatorio)) {
            throw new SecurityException("Escopo insuficiente.");
        }
    }
}
```

## Checklist de revisão

- Algum endpoint confia em IP como autenticação?
- Algum método confia em `Referer` ou `Origin` para dizer que a chamada é legítima?
- `X-Forwarded-For` é usado sem proxy confiável?
- Existe autenticação forte serviço-a-serviço?

---

# 7. CWE-294 — Authentication Bypass by Capture-replay

## Descrição prática

Ocorre quando uma mensagem de autenticação válida pode ser capturada e reenviada depois, com o mesmo efeito.

## Exemplo vulnerável

```java
public boolean validarAssinatura(HttpServletRequest request, String body) {
    String clientId = request.getHeader("X-Client-Id");
    String assinaturaRecebida = request.getHeader("X-Signature");

    String segredo = buscarSegredoDoCliente(clientId);
    String assinaturaEsperada = hmacSha256(segredo, body);

    // Vulnerável: a mesma assinatura pode ser repetida indefinidamente.
    return MessageDigest.isEqual(
            assinaturaEsperada.getBytes(StandardCharsets.UTF_8),
            assinaturaRecebida.getBytes(StandardCharsets.UTF_8)
    );
}
```

## Solução segura

Inclua timestamp, nonce e armazenamento temporário de nonces já usados.

```java
public final class ReplayProtectionService {

    private static final long JANELA_SEGUNDOS = 300;
    private final NonceRepository nonceRepository;

    public ReplayProtectionService(NonceRepository nonceRepository) {
        this.nonceRepository = nonceRepository;
    }

    public void validar(HttpServletRequest request, String body) {
        String clientId = exigirHeader(request, "X-Client-Id");
        String nonce = exigirHeader(request, "X-Nonce");
        String timestamp = exigirHeader(request, "X-Timestamp");
        String assinaturaRecebida = exigirHeader(request, "X-Signature");

        Instant instante = Instant.parse(timestamp);
        long diferenca = Math.abs(Duration.between(instante, Instant.now()).getSeconds());
        if (diferenca > JANELA_SEGUNDOS) {
            throw new SecurityException("Mensagem fora da janela permitida.");
        }

        if (!nonceRepository.registrarSeNovo(clientId, nonce, instante.plusSeconds(JANELA_SEGUNDOS))) {
            throw new SecurityException("Nonce já utilizado.");
        }

        String segredo = buscarSegredoDoCliente(clientId);
        String baseAssinatura = clientId + "\n" + nonce + "\n" + timestamp + "\n" + body;
        String assinaturaEsperada = hmacSha256(segredo, baseAssinatura);

        if (!compararConstante(assinaturaEsperada, assinaturaRecebida)) {
            throw new SecurityException("Assinatura inválida.");
        }
    }

    private String exigirHeader(HttpServletRequest request, String nome) {
        String valor = request.getHeader(nome);
        if (valor == null || valor.trim().isEmpty()) {
            throw new SecurityException("Header obrigatório ausente: " + nome);
        }
        return valor;
    }

    private boolean compararConstante(String a, String b) {
        return MessageDigest.isEqual(
                a.getBytes(StandardCharsets.UTF_8),
                b.getBytes(StandardCharsets.UTF_8)
        );
    }
}
```

## Checklist de revisão

- Token, assinatura ou código pode ser usado mais de uma vez?
- Existe nonce?
- Existe validade temporal curta?
- O servidor guarda nonces já utilizados?
- A assinatura cobre método HTTP, path, body, timestamp e nonce?

---

# 8. CWE-295 — Improper Certificate Validation

## Descrição prática

Ocorre quando o sistema não valida corretamente o certificado TLS. Em Java, isso aparece com `TrustManager` que aceita qualquer certificado ou `HostnameVerifier` que sempre retorna `true`.

## Exemplo vulnerável

```java
public SSLContext criarSslContextInseguro() throws Exception {
    TrustManager[] trustAll = new TrustManager[] {
            new X509TrustManager() {
                public void checkClientTrusted(X509Certificate[] chain, String authType) {
                }

                public void checkServerTrusted(X509Certificate[] chain, String authType) {
                }

                public X509Certificate[] getAcceptedIssuers() {
                    return new X509Certificate[0];
                }
            }
    };

    SSLContext context = SSLContext.getInstance("TLS");
    context.init(null, trustAll, new SecureRandom());
    return context;
}

public HostnameVerifier hostnameVerifierInseguro() {
    return (hostname, session) -> true;
}
```

## Solução segura

Prefira a validação padrão da JVM ou configure um truststore confiável.

```java
public HttpClient criarHttpClientSeguro() {
    return HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .version(HttpClient.Version.HTTP_2)
            .build();
}
```

Quando houver certificado interno, use truststore específico:

```bash
keytool -importcert \
  -alias api-interna \
  -file api-interna.crt \
  -keystore truststore.jks
```

```java
public SSLContext criarSslContextComTruststore(Path truststorePath, char[] senha) throws Exception {
    KeyStore truststore = KeyStore.getInstance("JKS");
    try (InputStream in = Files.newInputStream(truststorePath)) {
        truststore.load(in, senha);
    }

    TrustManagerFactory tmf = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
    tmf.init(truststore);

    SSLContext sslContext = SSLContext.getInstance("TLS");
    sslContext.init(null, tmf.getTrustManagers(), new SecureRandom());
    return sslContext;
}
```

## Checklist de revisão

Procure por:

```bash
grep -R "TrustManager" src/main/java
grep -R "HostnameVerifier" src/main/java
grep -R "return true" src/main/java | grep -i hostname
grep -R "checkServerTrusted" src/main/java
```

Atenção especial a código “temporário” criado para ambiente de homologação.

---

# 9. CWE-301 — Reflection Attack in an Authentication Protocol

## Descrição prática

Ocorre quando um protocolo de autenticação mútua permite que um atacante reflita um desafio recebido de volta para a própria vítima, conseguindo se autenticar sem conhecer o segredo.

Esse problema aparece principalmente em protocolos caseiros de desafio-resposta.

## Exemplo vulnerável

```java
public class ProtocoloMutuoInseguro {

    private final MacService macService;

    public boolean autenticarParceiro(Conexao conexao, String segredoCompartilhado) {
        String desafioServidor = gerarNonce();
        conexao.enviar("DESAFIO:" + desafioServidor);

        String respostaCliente = conexao.receber();
        String esperado = macService.hmac(segredoCompartilhado, desafioServidor);

        if (!esperado.equals(respostaCliente)) {
            return false;
        }

        String desafioCliente = conexao.receber();
        String respostaServidor = macService.hmac(segredoCompartilhado, desafioCliente);
        conexao.enviar(respostaServidor);

        return true;
    }
}
```

Problema: o mesmo segredo e o mesmo tipo de resposta são usados nos dois sentidos. Um atacante pode abrir duas conexões e usar o servidor como oráculo para responder ao próprio desafio do servidor.

## Solução segura

Evite protocolo caseiro. Use TLS/mTLS, OIDC, OAuth2, Kerberos ou outro protocolo revisado.

Se um protocolo próprio for inevitável, separe papéis, chaves e contexto criptográfico:

```java
public class ProtocoloMutuoComSeparacaoDeDominio {

    private final MacService macService;

    public boolean autenticarCliente(Conexao conexao, Chaves chaves) {
        String desafioServidor = gerarNonce();
        conexao.enviar("SERVER_CHALLENGE:" + desafioServidor);

        String respostaCliente = conexao.receber();
        String esperado = macService.hmac(
                chaves.getChaveClienteParaServidor(),
                "CLIENT_TO_SERVER\n" + desafioServidor
        );

        if (!compararConstante(esperado, respostaCliente)) {
            return false;
        }

        String desafioCliente = conexao.receber();
        String respostaServidor = macService.hmac(
                chaves.getChaveServidorParaCliente(),
                "SERVER_TO_CLIENT\n" + desafioCliente
        );
        conexao.enviar(respostaServidor);

        return true;
    }

    private boolean compararConstante(String a, String b) {
        return MessageDigest.isEqual(
                a.getBytes(StandardCharsets.UTF_8),
                b.getBytes(StandardCharsets.UTF_8)
        );
    }
}
```

## Checklist de revisão

- Existe protocolo de autenticação próprio?
- O mesmo segredo é usado nos dois sentidos?
- O desafio do cliente e do servidor têm formatos diferentes?
- Há separação de contexto como `CLIENT_TO_SERVER` e `SERVER_TO_CLIENT`?
- É possível substituir por mTLS ou OAuth2?

---

# 10. CWE-303 — Incorrect Implementation of Authentication Algorithm

## Descrição prática

O algoritmo de autenticação escolhido pode ser adequado, mas a implementação erra uma etapa, uma condição, uma validação ou a ordem das verificações.

## Exemplo vulnerável

```java
public boolean validarToken(Token token) {
    boolean assinaturaValida = verificarAssinatura(token);
    boolean naoExpirado = token.getExpiracao().isAfter(Instant.now());

    // Vulnerável: basta uma das condições ser verdadeira.
    return assinaturaValida || naoExpirado;
}
```

Problema: um token não expirado, mas com assinatura inválida, seria aceito.

## Solução segura

```java
public boolean validarToken(Token token) {
    boolean assinaturaValida = verificarAssinatura(token);
    boolean naoExpirado = token.getExpiracao().isAfter(Instant.now());
    boolean emissorValido = "https://auth.exemplo.gov.br".equals(token.getIssuer());
    boolean audienciaValida = token.getAudiences().contains("sistema-interno");

    return assinaturaValida && naoExpirado && emissorValido && audienciaValida;
}
```

Melhor ainda: use biblioteca consolidada para validação de token e configure explicitamente emissor, audiência, algoritmo e chaves aceitas.

```java
public UsuarioAutenticado autenticar(String jwt) {
    JwtClaims claims = jwtVerifier
            .requireIssuer("https://auth.exemplo.gov.br")
            .requireAudience("sistema-interno")
            .requireAlgorithm("RS256")
            .verify(jwt);

    return montarUsuario(claims);
}
```

## Checklist de revisão

- Há uso de `||` em validações de autenticação?
- O código valida assinatura, expiração, emissor e audiência?
- Existe teste negativo para token expirado?
- Existe teste negativo para token com assinatura inválida?
- Existe teste negativo para token de outro sistema?

---

# 11. CWE-305 — Authentication Bypass by Primary Weakness

## Descrição prática

A autenticação é burlada por causa de outra fraqueza primária, como SQL Injection, path traversal, falha de comparação, desserialização insegura ou manipulação de sessão.

## Exemplo vulnerável: SQL Injection no login

```java
public Usuario login(Connection conn, String login, String senha) throws SQLException {
    String sql = "SELECT id, login, perfil FROM usuario "
            + "WHERE login = '" + login + "' "
            + "AND senha = '" + senha + "'";

    try (Statement st = conn.createStatement();
         ResultSet rs = st.executeQuery(sql)) {
        if (rs.next()) {
            return montarUsuario(rs);
        }
        return null;
    }
}
```

Entrada maliciosa:

```text
login: admin' --
senha: qualquer
```

## Solução segura

```java
public Usuario login(Connection conn, String login, String senhaInformada) throws SQLException {
    String sql = "SELECT id, login, perfil, senha_hash FROM usuario WHERE login = ?";

    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, login);

        try (ResultSet rs = ps.executeQuery()) {
            if (!rs.next()) {
                return null;
            }

            String hashArmazenado = rs.getString("senha_hash");
            if (!passwordService.verificar(senhaInformada, hashArmazenado)) {
                return null;
            }

            return montarUsuario(rs);
        }
    }
}
```

## Checklist de revisão

- Login usa `Statement` em vez de `PreparedStatement`?
- A senha é comparada direto no SQL?
- Existe concatenação de `login`, `senha`, CPF ou matrícula na query?
- A autenticação depende de dados que podem ser manipulados por outra falha?

---

# 12. CWE-306 — Missing Authentication for Critical Function

## Descrição prática

Uma função crítica não exige autenticação. É comum em rotas administrativas, URLs chamadas por Ajax, Actions Struts, endpoints de manutenção ou integrações assumidas como “internas”.

## Exemplo vulnerável

```java
public ActionForward limparCache(ActionMapping mapping,
                                ActionForm form,
                                HttpServletRequest request,
                                HttpServletResponse response) throws Exception {

    // Vulnerável: qualquer chamada direta para a action executa a função.
    cacheService.limparTodosOsCaches();
    response.getWriter().write("Cache limpo com sucesso.");
    return null;
}
```

## Solução segura

```java
public ActionForward limparCache(ActionMapping mapping,
                                ActionForm form,
                                HttpServletRequest request,
                                HttpServletResponse response) throws Exception {

    UsuarioAutenticado usuario = AuthGuard.exigirPermissao(request, "ADMIN_CACHE_LIMPAR");

    auditoriaService.registrar(
            "CACHE_LIMPO",
            usuario.getId(),
            request.getRemoteAddr()
    );

    cacheService.limparTodosOsCaches();
    response.getWriter().write("Cache limpo com sucesso.");
    return null;
}
```

## Checklist de revisão

- Toda Action pública foi classificada como pública intencionalmente?
- Todo método administrativo exige usuário autenticado?
- Existe permissão específica para função crítica?
- Chamadas Ajax também passam pelo filtro?
- Existe teste acessando a URL diretamente sem sessão?

---

# 13. CWE-307 — Improper Restriction of Excessive Authentication Attempts

## Descrição prática

O sistema permite muitas tentativas de autenticação em pouco tempo. Isso facilita brute force, password spraying e enumeração de contas.

## Exemplo vulnerável

```java
public Usuario autenticar(String login, String senha) {
    Usuario usuario = usuarioDao.buscarPorLogin(login);
    if (usuario == null) {
        return null;
    }

    if (!passwordService.verificar(senha, usuario.getSenhaHash())) {
        return null;
    }

    return usuario;
}
```

Problema: não há limite por conta, IP, dispositivo ou intervalo de tempo.

## Solução segura

```java
public Usuario autenticar(HttpServletRequest request, String login, String senha) {
    String ip = request.getRemoteAddr();

    if (tentativasService.estaTemporariamenteBloqueado(login, ip)) {
        throw new SecurityException("Muitas tentativas. Aguarde antes de tentar novamente.");
    }

    Usuario usuario = usuarioDao.buscarPorLogin(login);
    boolean sucesso = usuario != null && passwordService.verificar(senha, usuario.getSenhaHash());

    if (!sucesso) {
        tentativasService.registrarFalha(login, ip);
        auditoriaService.registrarFalhaLogin(login, ip);
        return null;
    }

    tentativasService.registrarSucesso(login, ip);
    auditoriaService.registrarSucessoLogin(usuario.getId(), ip);
    return usuario;
}
```

Exemplo simples de política:

```java
public class TentativasLoginService {

    public boolean estaTemporariamenteBloqueado(String login, String ip) {
        int falhasConta = contarFalhasRecentesPorConta(login, Duration.ofMinutes(15));
        int falhasIp = contarFalhasRecentesPorIp(ip, Duration.ofMinutes(15));

        return falhasConta >= 10 || falhasIp >= 100;
    }

    public Duration calcularBackoff(int falhasRecentes) {
        long segundos = Math.min(300, (long) Math.pow(2, Math.min(falhasRecentes, 8)));
        return Duration.ofSeconds(segundos);
    }
}
```

## Checklist de revisão

- Existe limite por conta?
- Existe limite por IP/origem?
- O retorno evita informar se o login existe?
- Eventos de falha são auditados?
- Há proteção contra password spraying em vários usuários?

---

# 14. CWE-308 — Use of Single-factor Authentication

## Descrição prática

O sistema usa apenas um fator de autenticação, como senha, em contexto que deveria exigir mais de um fator.

## Exemplo vulnerável

```java
public void alterarEmailPrincipal(HttpServletRequest request, String novoEmail) {
    UsuarioAutenticado usuario = AuthGuard.exigirUsuario(request);

    // Vulnerável: função sensível protegida apenas por sessão/senha.
    usuarioService.alterarEmail(usuario.getId(), novoEmail);
}
```

## Solução segura: step-up authentication

```java
public void alterarEmailPrincipal(HttpServletRequest request, String novoEmail) {
    UsuarioAutenticado usuario = AuthGuard.exigirMfa(request, "USUARIO_ALTERAR_EMAIL_PRINCIPAL");

    usuarioService.alterarEmail(usuario.getId(), novoEmail);

    auditoriaService.registrar(
            "EMAIL_PRINCIPAL_ALTERADO",
            usuario.getId(),
            request.getRemoteAddr()
    );
}
```

Exemplos de funções que normalmente justificam MFA ou reautenticação:

- alteração de senha;
- alteração de e-mail principal;
- alteração de telefone de recuperação;
- geração de token de API;
- criação de usuário administrador;
- transferência financeira;
- exportação de dados sensíveis;
- alteração de permissões.

## Checklist de revisão

- Funções críticas exigem MFA?
- O MFA é validado no servidor?
- Existe reautenticação para operações sensíveis?
- O sistema diferencia login normal de login com step-up?

---

# 15. CWE-309 — Use of Password System for Primary Authentication

## Descrição prática

A dependência exclusiva de senhas como autenticação principal pode ser frágil, pois senhas são reutilizadas, vazadas, adivinhadas, compartilhadas ou capturadas por phishing.

Essa CWE é próxima da CWE-308, mas destaca as limitações do próprio modelo baseado em senha.

## Exemplo vulnerável

```java
public Usuario autenticar(String login, String senha) {
    Usuario usuario = usuarioDao.buscarPorLogin(login);
    if (usuario == null) {
        return null;
    }

    if (senha.equals(usuario.getSenhaEmTextoClaro())) {
        return usuario;
    }

    return null;
}
```

Problemas:

- senha em texto claro;
- autenticação apenas por senha;
- sem MFA;
- sem verificação de senha comprometida;
- sem política de risco.

## Solução segura

```java
public Usuario autenticar(HttpServletRequest request, String login, String senha) {
    Usuario usuario = usuarioDao.buscarPorLogin(login);

    // Resposta genérica para não facilitar enumeração.
    if (usuario == null) {
        passwordService.verificar(senha, PasswordService.HASH_DUMMY);
        return null;
    }

    if (!passwordService.verificar(senha, usuario.getSenhaHash())) {
        return null;
    }

    if (riscoService.exigeMfa(usuario, request)) {
        mfaService.iniciarDesafio(usuario);
        throw new MfaObrigatorioException();
    }

    return usuario;
}
```

Exemplo de hashing seguro no servidor:

```java
public class PasswordService {

    public static final String HASH_DUMMY = "$2a$12$abcdefghijklmnopqrstuu3sqzV...";

    public String gerarHash(String senha) {
        return BCrypt.hashpw(senha, BCrypt.gensalt(12));
    }

    public boolean verificar(String senhaInformada, String hashArmazenado) {
        if (senhaInformada == null || hashArmazenado == null) {
            return false;
        }
        return BCrypt.checkpw(senhaInformada, hashArmazenado);
    }
}
```

## Checklist de revisão

- Existe senha em texto claro?
- O hash é feito no servidor?
- Há MFA para contexto crítico?
- Há política para senha comprometida/fraca?
- Há auditoria de login suspeito?

---

# 16. CWE-322 — Key Exchange without Entity Authentication

## Descrição prática

O sistema troca chaves criptográficas com uma entidade sem verificar quem é essa entidade. A comunicação pode até ser criptografada, mas com a pessoa errada.

## Exemplo vulnerável

```java
public SecretKey trocarChave(Socket socket) throws Exception {
    KeyPair parLocal = gerarDiffieHellman();

    enviarChavePublica(socket, parLocal.getPublic());
    PublicKey chaveRemota = receberChavePublica(socket);

    // Vulnerável: a chave remota não foi autenticada.
    return derivarSegredo(parLocal.getPrivate(), chaveRemota);
}
```

Problema: um atacante no meio da comunicação pode trocar chaves com as duas pontas e interceptar tudo.

## Solução segura

Use TLS com validação de certificado ou mTLS quando o cliente também precisa ser autenticado.

```java
public HttpClient criarClienteHttpsSeguro() {
    return HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .followRedirects(HttpClient.Redirect.NEVER)
            .build();
}
```

Para autenticação mútua, configure keystore do cliente e truststore confiável:

```java
public SSLContext criarSslContextMutuo(Path keyStorePath,
                                      char[] keyStoreSenha,
                                      Path trustStorePath,
                                      char[] trustStoreSenha) throws Exception {
    KeyStore keyStore = KeyStore.getInstance("PKCS12");
    try (InputStream in = Files.newInputStream(keyStorePath)) {
        keyStore.load(in, keyStoreSenha);
    }

    KeyManagerFactory kmf = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
    kmf.init(keyStore, keyStoreSenha);

    KeyStore trustStore = KeyStore.getInstance("JKS");
    try (InputStream in = Files.newInputStream(trustStorePath)) {
        trustStore.load(in, trustStoreSenha);
    }

    TrustManagerFactory tmf = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
    tmf.init(trustStore);

    SSLContext context = SSLContext.getInstance("TLS");
    context.init(kmf.getKeyManagers(), tmf.getTrustManagers(), new SecureRandom());
    return context;
}
```

## Checklist de revisão

- Existe troca de chave manual?
- A chave pública remota é autenticada?
- Há validação de certificado?
- O código ignora erro TLS?
- mTLS seria mais adequado?

---

# 17. CWE-603 — Use of Client-Side Authentication

## Descrição prática

O sistema faz autenticação no cliente, mas não no servidor. Qualquer regra no cliente pode ser removida, alterada ou simulada.

## Exemplo vulnerável: JSP/JavaScript

```jsp
<script>
function acessarAdmin() {
    if (document.getElementById("senhaAdmin").value === "admin123") {
        document.getElementById("adminLiberado").value = "S";
        document.forms[0].submit();
    } else {
        alert("Senha inválida.");
    }
}
</script>

<input type="hidden" id="adminLiberado" name="adminLiberado" value="N" />
```

```java
public ActionForward executarRotinaAdmin(ActionMapping mapping,
                                        ActionForm form,
                                        HttpServletRequest request,
                                        HttpServletResponse response) {

    // Vulnerável: usuário pode enviar adminLiberado=S manualmente.
    if ("S".equals(request.getParameter("adminLiberado"))) {
        rotinaAdminService.executar();
    }

    return mapping.findForward("sucesso");
}
```

## Solução segura

```java
public ActionForward executarRotinaAdmin(ActionMapping mapping,
                                        ActionForm form,
                                        HttpServletRequest request,
                                        HttpServletResponse response) {

    UsuarioAutenticado usuario = AuthGuard.exigirPermissao(request, "ROTINA_ADMIN_EXECUTAR");

    rotinaAdminService.executar();
    auditoriaService.registrar("ROTINA_ADMIN_EXECUTADA", usuario.getId(), request.getRemoteAddr());

    return mapping.findForward("sucesso");
}
```

O JavaScript pode melhorar usabilidade, mas nunca substituir validação do servidor.

## Checklist de revisão

- Existe `hidden` que decide permissão?
- Existe JavaScript validando senha, perfil ou autorização?
- O servidor repete todas as validações críticas?
- O endpoint funciona corretamente quando chamado direto por Insomnia/cURL?

---

# 18. CWE-645 — Overly Restrictive Account Lockout Mechanism

## Descrição prática

O bloqueio de conta é tão rígido que permite ataque de negação de serviço: o atacante erra senhas propositalmente e bloqueia usuários legítimos.

## Exemplo vulnerável

```java
public void registrarFalha(String login) {
    int falhas = loginDao.incrementarFalhas(login);

    // Vulnerável: atacante pode bloquear qualquer conta sabendo o login.
    if (falhas >= 3) {
        loginDao.bloquearContaPorHoras(login, 24);
    }
}
```

## Solução segura

Use bloqueio progressivo, análise por IP/dispositivo, notificação e recuperação segura.

```java
public ResultadoTentativa avaliarTentativa(String login, String ip) {
    int falhasConta = loginDao.contarFalhas(login, Duration.ofMinutes(15));
    int falhasIp = loginDao.contarFalhasPorIp(ip, Duration.ofMinutes(15));

    if (falhasIp > 200) {
        return ResultadoTentativa.bloqueioOrigem(Duration.ofMinutes(30));
    }

    if (falhasConta >= 10) {
        return ResultadoTentativa.exigirMfaOuCaptcha();
    }

    if (falhasConta >= 5) {
        return ResultadoTentativa.backoff(Duration.ofSeconds(30L * falhasConta));
    }

    return ResultadoTentativa.permitir();
}
```

## Checklist de revisão

- O atacante consegue bloquear qualquer conta sabendo o login?
- O bloqueio diferencia falhas por conta e por IP?
- Há desbloqueio seguro?
- Há notificação ao usuário?
- Existe alternativa como backoff, CAPTCHA adaptativo ou MFA?

---

# 19. CWE-804 — Guessable CAPTCHA

## Descrição prática

O sistema usa CAPTCHA, mas ele é previsível, fácil de reconhecer automaticamente ou tem resposta exposta.

## Exemplo vulnerável

```jsp
<%
    int a = 2;
    int b = 3;
    String resposta = String.valueOf(a + b);
%>

<label>Quanto é <%= a %> + <%= b %>?</label>
<input type="text" name="captcha" />
<input type="hidden" name="captchaResposta" value="<%= resposta %>" />
```

```java
public boolean validarCaptcha(HttpServletRequest request) {
    // Vulnerável: resposta correta vem do próprio cliente.
    return request.getParameter("captcha")
            .equals(request.getParameter("captchaResposta"));
}
```

## Solução segura

Armazene o desafio no servidor, use expiração curta e considere serviço especializado.

```java
public class CaptchaService {

    public void gerar(HttpServletRequest request) {
        String desafioId = UUID.randomUUID().toString();
        String resposta = gerarRespostaSegura();

        captchaRepository.salvar(desafioId, hash(resposta), Instant.now().plusSeconds(120));
        request.getSession().setAttribute("CAPTCHA_ID", desafioId);
    }

    public boolean validar(HttpServletRequest request, String respostaInformada) {
        String desafioId = (String) request.getSession().getAttribute("CAPTCHA_ID");
        if (desafioId == null) {
            return false;
        }

        Captcha desafio = captchaRepository.buscar(desafioId);
        if (desafio == null || desafio.getExpiracao().isBefore(Instant.now())) {
            return false;
        }

        captchaRepository.invalidar(desafioId);
        return verificarHash(respostaInformada, desafio.getRespostaHash());
    }
}
```

Importante: CAPTCHA não substitui autenticação, rate limit nem auditoria.

## Checklist de revisão

- A resposta está em hidden field?
- A resposta aparece no HTML, nome de imagem, cookie ou URL?
- O desafio expira?
- O mesmo CAPTCHA pode ser reutilizado?
- O CAPTCHA é usado junto com rate limit?

---

# 20. CWE-836 — Use of Password Hash Instead of Password for Authentication

## Descrição prática

O cliente calcula o hash da senha e envia esse hash ao servidor. O servidor compara o hash recebido com o hash armazenado. Nesse modelo, o hash vira a própria senha: quem roubar o hash consegue autenticar sem saber a senha original.

## Exemplo vulnerável

```javascript
async function login() {
    const senha = document.getElementById("senha").value;
    const hash = await sha256(senha);

    fetch("/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
            login: document.getElementById("login").value,
            senhaHash: hash
        })
    });
}
```

```java
public Usuario autenticar(String login, String hashRecebidoDoCliente) {
    Usuario usuario = usuarioDao.buscarPorLogin(login);

    // Vulnerável: o hash é aceito como credencial reutilizável.
    if (usuario != null && usuario.getSenhaHash().equals(hashRecebidoDoCliente)) {
        return usuario;
    }

    return null;
}
```

## Solução segura

Envie a senha pelo canal TLS e faça a verificação do hash no servidor com algoritmo apropriado.

```java
public Usuario autenticar(String login, String senhaInformada) {
    Usuario usuario = usuarioDao.buscarPorLogin(login);
    if (usuario == null) {
        passwordService.verificar(senhaInformada, PasswordService.HASH_DUMMY);
        return null;
    }

    if (!passwordService.verificar(senhaInformada, usuario.getSenhaHash())) {
        return null;
    }

    return usuario;
}
```

```java
public class PasswordService {

    public String gerarHash(String senha) {
        return BCrypt.hashpw(senha, BCrypt.gensalt(12));
    }

    public boolean verificar(String senhaInformada, String hashArmazenado) {
        return BCrypt.checkpw(senhaInformada, hashArmazenado);
    }
}
```

Para autenticação sem enviar senha ao servidor, use protocolos apropriados como SRP/OPAQUE, não um SHA-256 simples no cliente.

## Checklist de revisão

- O frontend calcula hash da senha?
- O servidor recebe `senhaHash`, `passwordHash` ou equivalente?
- O hash pode ser reutilizado em outra requisição?
- O hash armazenado no banco permitiria login direto se vazasse?

---

# 21. Comandos úteis para revisão de código

```bash
# Possíveis validações por IP/header
grep -R "X-Forwarded-For\|getRemoteAddr\|Referer\|User-Agent\|Origin" src/main/java

# Certificado TLS inseguro
grep -R "TrustManager\|HostnameVerifier\|checkServerTrusted\|return true" src/main/java

# Autenticação/autorização em hidden fields ou parâmetros
grep -R "adminLiberado\|isAdmin\|perfil\|permissao\|autorizado" src/main/webapp src/main/java

# Possível autenticação ausente em Actions/endpoints
grep -R "ActionForward .*HttpServletRequest" src/main/java | grep -i "admin\|cache\|reprocess\|excluir\|gerar\|exportar"

# SQL Injection em login
grep -R "createStatement\|SELECT .*usuario\|senha" src/main/java

# Hash calculado/recebido como credencial
grep -R "senhaHash\|passwordHash\|sha256\|SHA-256" src/main/java src/main/webapp

# Validações de token com lógica suspeita
grep -R "verificarAssinatura\|validarToken\|expires\|issuer\|audience" src/main/java
```

---

# 22. Checklist geral da categoria CWE-1211

## Arquitetura

- [ ] Rotas públicas, autenticadas, privilegiadas e administrativas estão separadas.
- [ ] Autenticação é centralizada em filtro/interceptor/framework.
- [ ] Autorização é feita no servidor.
- [ ] Funções críticas têm permissão específica.
- [ ] Funções críticas usam MFA ou reautenticação.
- [ ] Integrações serviço-a-serviço usam autenticação forte.
- [ ] TLS/certificados são validados corretamente.

## Implementação

- [ ] Não há autenticação baseada apenas em IP, header ou nome de recurso.
- [ ] Não há `TrustManager` aceitando tudo.
- [ ] Não há `HostnameVerifier` retornando sempre `true`.
- [ ] Tokens validam assinatura, expiração, emissor e audiência.
- [ ] Login usa `PreparedStatement` ou ORM parametrizado.
- [ ] Senha é verificada no servidor.
- [ ] Hash de senha não é aceito como senha.
- [ ] Há limitação de tentativas de autenticação.
- [ ] O bloqueio de conta não permite DoS simples.

## Testes

- [ ] Teste sem sessão em endpoint crítico retorna 401/403/redirect.
- [ ] Teste com usuário sem permissão retorna 403.
- [ ] Teste de token expirado falha.
- [ ] Teste de token sem assinatura válida falha.
- [ ] Teste de replay com mesmo nonce falha.
- [ ] Teste de brute force aciona rate limit.
- [ ] Teste de bloqueio não trava conta de forma abusiva.
- [ ] Teste com hidden field manipulado não concede privilégio.

---

# 23. Resumo para prova

- **CWE-1211** é categoria de erros de autenticação dentro da **CWE-699 Software Development**.
- **CWE-289**: cuidado com nomes alternativos, encoding, alias e canonicalização.
- **CWE-290**: IP, header e origem não são autenticação confiável.
- **CWE-294**: replay é evitado com nonce, timestamp, assinatura e armazenamento de uso.
- **CWE-295**: nunca ignore validação de certificado TLS.
- **CWE-301**: protocolos caseiros de desafio-resposta podem sofrer reflexão.
- **CWE-303**: algoritmo correto pode ser quebrado por implementação errada.
- **CWE-305**: outra falha, como SQL Injection, pode permitir bypass de autenticação.
- **CWE-306**: função crítica sempre deve exigir autenticação.
- **CWE-307**: login precisa limitar tentativas excessivas.
- **CWE-308**: funções sensíveis podem exigir mais de um fator.
- **CWE-309**: senha como fator principal tem limitações e deve ser reforçada.
- **CWE-322**: criptografia sem autenticação da entidade não impede MITM.
- **CWE-603**: autenticação no cliente não protege o servidor.
- **CWE-645**: bloqueio de conta mal calibrado vira DoS.
- **CWE-804**: CAPTCHA previsível é burlável por automação.
- **CWE-836**: hash enviado pelo cliente vira uma senha reutilizável.

---

# 24. Referências oficiais

- CWE-699 — Software Development: `https://cwe.mitre.org/data/definitions/699.html`
- CWE-1211 — Authentication Errors: `https://cwe.mitre.org/data/definitions/1211.html`
- CWE-289 — Authentication Bypass by Alternate Name: `https://cwe.mitre.org/data/definitions/289.html`
- CWE-290 — Authentication Bypass by Spoofing: `https://cwe.mitre.org/data/definitions/290.html`
- CWE-294 — Authentication Bypass by Capture-replay: `https://cwe.mitre.org/data/definitions/294.html`
- CWE-295 — Improper Certificate Validation: `https://cwe.mitre.org/data/definitions/295.html`
- CWE-301 — Reflection Attack in an Authentication Protocol: `https://cwe.mitre.org/data/definitions/301.html`
- CWE-303 — Incorrect Implementation of Authentication Algorithm: `https://cwe.mitre.org/data/definitions/303.html`
- CWE-305 — Authentication Bypass by Primary Weakness: `https://cwe.mitre.org/data/definitions/305.html`
- CWE-306 — Missing Authentication for Critical Function: `https://cwe.mitre.org/data/definitions/306.html`
- CWE-307 — Improper Restriction of Excessive Authentication Attempts: `https://cwe.mitre.org/data/definitions/307.html`
- CWE-308 — Use of Single-factor Authentication: `https://cwe.mitre.org/data/definitions/308.html`
- CWE-309 — Use of Password System for Primary Authentication: `https://cwe.mitre.org/data/definitions/309.html`
- CWE-322 — Key Exchange without Entity Authentication: `https://cwe.mitre.org/data/definitions/322.html`
- CWE-603 — Use of Client-Side Authentication: `https://cwe.mitre.org/data/definitions/603.html`
- CWE-645 — Overly Restrictive Account Lockout Mechanism: `https://cwe.mitre.org/data/definitions/645.html`
- CWE-804 — Guessable CAPTCHA: `https://cwe.mitre.org/data/definitions/804.html`
- CWE-836 — Use of Password Hash Instead of Password for Authentication: `https://cwe.mitre.org/data/definitions/836.html`
