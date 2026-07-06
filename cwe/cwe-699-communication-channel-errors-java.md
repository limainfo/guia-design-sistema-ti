# CWE-699 - Software Development

## Category: Communication Channel Errors - CWE-417

> **Objetivo deste material:** documentar, de forma prática, as fraquezas da categoria **Communication Channel Errors** da view **CWE-699 - Software Development**, com exemplos em **Java** voltados para aplicações web, APIs REST, integrações, jobs, Struts/Servlet/JSP e sistemas legados.

A **CWE-417** é uma **categoria**, não uma vulnerabilidade diretamente mapeável. Ela agrupa problemas relacionados ao uso incorreto de canais de comunicação, caminhos alternativos, origem, destino, integridade, SSRF, canais encobertos e exposição indevida de serviços.

---

## 1. Visão geral

### Estrutura analisada

```text
699 - Software Development

+ Category Communication Channel Errors - (417)
  * Base Key Exchange without Entity Authentication - (322)
  * Class Origin Validation Error - (346)
  * Base Covert Timing Channel - (385)
  * Base Unprotected Primary Channel - (419)
  * Base Unprotected Alternate Channel - (420)
  * Base Direct Request ('Forced Browsing') - (425)
  * Base Covert Storage Channel - (515)
  * Base Server-Side Request Forgery (SSRF) - (918)
  * Base Improper Enforcement of Message Integrity During Transmission in a Communication Channel - (924)
  * Base Improper Verification of Source of a Communication Channel - (940)
  * Base Incorrectly Specified Destination in a Communication Channel - (941)
  * Base Binding to an Unrestricted IP Address - (1327)
```

### Ideia central

Erros de canal de comunicação ocorrem quando a aplicação:

- comunica-se pelo canal errado;
- aceita origem não confiável;
- envia dados sensíveis por canal sem proteção;
- confia em destino informado pelo usuário;
- expõe porta, endpoint ou caminho alternativo;
- não garante integridade da mensagem durante o tráfego;
- permite que diferenças de tempo ou armazenamento virem canal indireto de vazamento.

Em Java web, esses problemas costumam aparecer em:

- `HttpURLConnection`, `HttpClient`, `RestTemplate`, `WebClient`;
- endpoints REST internos;
- integração com webhooks;
- filtros CORS;
- callbacks configuráveis;
- download de arquivos por URL;
- jobs que chamam serviços externos;
- serviços administrativos expostos em porta errada;
- uso de headers como `Origin`, `Referer`, `X-Forwarded-For` e `Host` sem validação.

---

## 2. Checklist rápido

Antes de revisar os exemplos, pergunte:

| Pergunta | Risco associado |
|---|---|
| A URL de destino pode ser informada pelo usuário? | SSRF, destino incorreto |
| O sistema permite callback/webhook configurável? | SSRF, origem/destino incorretos |
| Existe endpoint alternativo para a mesma função? | bypass, canal alternativo desprotegido |
| O canal usa HTTP em vez de HTTPS? | canal primário desprotegido |
| O sistema valida assinatura/HMAC da mensagem? | integridade fraca |
| O sistema confia em `Origin`, `Referer` ou `X-Forwarded-For`? | origem falsificável |
| Porta administrativa escuta em `0.0.0.0`? | exposição indevida |
| Tokens são comparados com `String.equals`? | timing attack em casos sensíveis |
| Arquivos/JSPs podem ser acessados diretamente? | forced browsing |

---

# CWE-322 - Key Exchange without Entity Authentication

## Explicação prática

Ocorre quando existe troca de chave criptográfica, mas a aplicação **não verifica quem está do outro lado**.

Criptografia sem autenticação da entidade pode dar uma falsa sensação de segurança. A comunicação pode estar cifrada, mas com um atacante no meio, porque a chave foi negociada com a entidade errada.

### Exemplo comum em Java

- aceitar uma chave pública enviada no request;
- gerar segredo compartilhado com essa chave;
- não validar certificado, assinatura ou identidade da entidade;
- confiar em chave pública armazenada em parâmetro, banco ou arquivo sem cadeia de confiança.

## Código vulnerável

```java
public class TrocaChaveService {

    public byte[] criptografarResposta(HttpServletRequest request, byte[] resposta) throws Exception {
        String chavePublicaBase64 = request.getParameter("publicKey");

        byte[] chaveBytes = Base64.getDecoder().decode(chavePublicaBase64);
        X509EncodedKeySpec spec = new X509EncodedKeySpec(chaveBytes);
        PublicKey chavePublicaCliente = KeyFactory.getInstance("RSA").generatePublic(spec);

        Cipher cipher = Cipher.getInstance("RSA/ECB/OAEPWithSHA-256AndMGF1Padding");
        cipher.init(Cipher.ENCRYPT_MODE, chavePublicaCliente);

        return cipher.doFinal(resposta);
    }
}
```

### Problema

A aplicação cifra a resposta para a chave pública recebida, mas não sabe se a chave realmente pertence ao cliente legítimo.

Um atacante pode enviar a própria chave pública e receber a resposta cifrada para ele.

## Solução segura

Use TLS/mTLS, certificado confiável, keystore, assinatura ou vínculo prévio entre cliente e chave.

```java
public class TrocaChaveSeguraService {

    private final CertificadoClienteRepository repository;

    public TrocaChaveSeguraService(CertificadoClienteRepository repository) {
        this.repository = repository;
    }

    public PublicKey obterChavePublicaConfiavel(String clientId) {
        CertificadoCliente certificado = repository.buscarAtivoPorClientId(clientId);

        if (certificado == null || certificado.expirado() || certificado.revogado()) {
            throw new SecurityException("Certificado de cliente inválido.");
        }

        return certificado.getPublicKey();
    }

    public byte[] criptografarResposta(String clientId, byte[] resposta) throws Exception {
        PublicKey chavePublicaCliente = obterChavePublicaConfiavel(clientId);

        Cipher cipher = Cipher.getInstance("RSA/ECB/OAEPWithSHA-256AndMGF1Padding");
        cipher.init(Cipher.ENCRYPT_MODE, chavePublicaCliente);

        return cipher.doFinal(resposta);
    }
}
```

## Como revisar

Procure por:

```bash
grep -R "getParameter(.*public" -n src/
grep -R "X509EncodedKeySpec" -n src/
grep -R "KeyAgreement" -n src/
grep -R "TrustManager" -n src/
grep -R "HostnameVerifier" -n src/
```

## Correção esperada

- Não aceitar chave pública arbitrária como prova de identidade.
- Validar certificado e cadeia de confiança.
- Usar TLS com validação adequada.
- Considerar mTLS para integrações sensíveis.
- Vincular `clientId`, certificado e permissão no backend.

---

# CWE-346 - Origin Validation Error

## Explicação prática

Ocorre quando a aplicação não valida corretamente a **origem** de uma comunicação.

Em aplicações web, aparece com frequência em:

- CORS permissivo;
- validação fraca de `Origin`;
- confiança indevida em `Referer`;
- confiança em `Host`;
- webhooks sem assinatura;
- callback sem validação de origem.

## Código vulnerável

```java
public class CorsInseguroFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String origin = request.getHeader("Origin");

        response.setHeader("Access-Control-Allow-Origin", origin);
        response.setHeader("Access-Control-Allow-Credentials", "true");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

        chain.doFilter(req, res);
    }
}
```

### Problema

O filtro reflete qualquer `Origin` recebido e ainda permite credenciais.

Isso pode permitir que uma origem maliciosa acesse recursos autenticados do usuário.

## Solução segura

```java
public class CorsSeguroFilter implements Filter {

    private static final Set<String> ORIGENS_PERMITIDAS = Collections.unmodifiableSet(new HashSet<>(Arrays.asList(
            "https://app.exemplo.gov.br",
            "https://admin.exemplo.gov.br"
    )));

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String origin = request.getHeader("Origin");

        if (origin != null && ORIGENS_PERMITIDAS.contains(origin)) {
            response.setHeader("Access-Control-Allow-Origin", origin);
            response.setHeader("Vary", "Origin");
            response.setHeader("Access-Control-Allow-Credentials", "true");
            response.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
            response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        }

        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            response.setStatus(HttpServletResponse.SC_NO_CONTENT);
            return;
        }

        chain.doFilter(req, res);
    }
}
```

## Como revisar

```bash
grep -R "Access-Control-Allow-Origin" -n src/
grep -R "getHeader(\"Origin\")" -n src/
grep -R "getHeader(\"Referer\")" -n src/
grep -R "getHeader(\"Host\")" -n src/
```

## Correção esperada

- Validar `Origin` por allowlist exata.
- Não usar `*` com credenciais.
- Não confiar em `Referer` como controle de segurança principal.
- Validar origem de webhook com assinatura ou mTLS.
- Centralizar regras CORS em filtro/configuração única.

---

# CWE-385 - Covert Timing Channel

## Explicação prática

Ocorre quando diferenças de tempo permitem inferir informação sensível.

Em Java, isso pode ocorrer em:

- comparação de token com `String.equals`;
- login que responde mais rápido para usuário inexistente;
- validação de assinatura que encerra no primeiro byte diferente;
- APIs que têm tempos muito diferentes para dados existentes/inexistentes.

## Código vulnerável

```java
public class TokenService {

    public boolean tokenValido(String tokenRecebido, String tokenEsperado) {
        return tokenEsperado.equals(tokenRecebido);
    }
}
```

### Problema

Dependendo do caso, comparações que terminam mais cedo podem expor informação por tempo de resposta.

Esse risco é mais relevante para tokens, assinaturas, MACs, códigos de recuperação e segredos de curta duração.

## Solução segura

```java
public class TokenServiceSeguro {

    public boolean tokenValido(String tokenRecebido, String tokenEsperado) {
        if (tokenRecebido == null || tokenEsperado == null) {
            return false;
        }

        byte[] recebido = tokenRecebido.getBytes(StandardCharsets.UTF_8);
        byte[] esperado = tokenEsperado.getBytes(StandardCharsets.UTF_8);

        return MessageDigest.isEqual(recebido, esperado);
    }
}
```

## Exemplo em login

### Vulnerável

```java
public boolean autenticar(String login, String senha) {
    Usuario usuario = usuarioDAO.buscarPorLogin(login);

    if (usuario == null) {
        return false;
    }

    return passwordEncoder.matches(senha, usuario.getHashSenha());
}
```

### Melhor abordagem

```java
public boolean autenticar(String login, String senha) {
    Usuario usuario = usuarioDAO.buscarPorLogin(login);

    String hashParaComparar = usuario != null
            ? usuario.getHashSenha()
            : "$2a$10$abcdefghijklmnopqrstuu8i3vVwG8pP7X9FicticioFicticioFic";

    boolean senhaOk = passwordEncoder.matches(senha, hashParaComparar);

    return usuario != null && senhaOk && usuario.isAtivo();
}
```

## Como revisar

```bash
grep -R "\.equals(.*token" -n src/
grep -R "\.equals(.*assin" -n src/
grep -R "MessageDigest.isEqual" -n src/
grep -R "return false" -n src/ | grep -i login
```

## Correção esperada

- Usar comparação constante para segredos.
- Uniformizar mensagens de erro.
- Evitar diferenças grandes de tempo entre usuário existente e inexistente.
- Registrar tentativa sem expor se o usuário existe.

---

# CWE-419 - Unprotected Primary Channel

## Explicação prática

Ocorre quando o canal principal de comunicação não possui proteção adequada.

Exemplos:

- enviar token por HTTP;
- chamar API externa por `http://`;
- trafegar senha em socket sem TLS;
- expor endpoint administrativo sem HTTPS;
- usar FTP em vez de SFTP/HTTPS.

## Código vulnerável

```java
public class ConsultaExternaService {

    public String consultar(String cpf) throws IOException {
        URL url = new URL("http://api.exemplo.gov.br/pessoa?cpf=" + URLEncoder.encode(cpf, "UTF-8"));
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setRequestMethod("GET");
        con.setRequestProperty("Authorization", "Bearer " + obterToken());

        return lerResposta(con);
    }
}
```

### Problema

A aplicação envia token e dados pessoais por HTTP, sem confidencialidade nem integridade de transporte.

## Solução segura

```java
public class ConsultaExternaSeguraService {

    public String consultar(String cpf) throws IOException {
        URI uri = URI.create("https://api.exemplo.gov.br/pessoa?cpf=" + URLEncoder.encode(cpf, "UTF-8"));
        validarHttps(uri);

        HttpsURLConnection con = (HttpsURLConnection) uri.toURL().openConnection();
        con.setRequestMethod("GET");
        con.setConnectTimeout(5000);
        con.setReadTimeout(10000);
        con.setRequestProperty("Authorization", "Bearer " + obterToken());

        return lerResposta(con);
    }

    private void validarHttps(URI uri) {
        if (!"https".equalsIgnoreCase(uri.getScheme())) {
            throw new SecurityException("Canal inseguro. Use HTTPS.");
        }
    }
}
```

## Como revisar

```bash
grep -R "http://" -n src/ resources/
grep -R "new URL" -n src/
grep -R "openConnection" -n src/
grep -R "Authorization" -n src/ | grep -i http
```

## Correção esperada

- Usar HTTPS para canais externos e internos sensíveis.
- Validar certificado corretamente.
- Configurar timeout.
- Não enviar token por canal inseguro.
- Bloquear downgrade para HTTP.

---

# CWE-420 - Unprotected Alternate Channel

## Explicação prática

Ocorre quando a aplicação possui um canal alternativo com proteção inferior ao canal principal.

Exemplos:

- tela principal exige autenticação, mas endpoint Ajax alternativo não exige;
- API pública usa HTTPS, mas job interno usa HTTP;
- endpoint `/debug`, `/status`, `/admin`, `/export` sem autenticação;
- funcionalidade disponível por JSP direto, fora do fluxo normal;
- porta administrativa exposta sem controle.

## Código vulnerável

```java
public class ExportacaoAction extends Action {

    public ActionForward exportarPublico(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) throws Exception {

        Long idRelatorio = Long.valueOf(request.getParameter("idRelatorio"));
        Arquivo arquivo = relatorioService.gerarArquivo(idRelatorio);

        escreverArquivo(response, arquivo);
        return null;
    }
}
```

### Problema

A exportação está disponível por um caminho alternativo que não aplica autenticação nem autorização.

## Solução segura

```java
public class ExportacaoAction extends Action {

    public ActionForward exportar(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) throws Exception {

        Usuario usuario = obterUsuarioAutenticado(request);
        Long idRelatorio = Long.valueOf(request.getParameter("idRelatorio"));

        if (!relatorioService.usuarioPodeExportar(usuario, idRelatorio)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }

        Arquivo arquivo = relatorioService.gerarArquivo(idRelatorio, usuario);
        escreverArquivo(response, arquivo);
        return null;
    }
}
```

## Como revisar

```bash
grep -R "debug" -n src/ webapp/
grep -R "admin" -n src/ webapp/
grep -R "export" -n src/ webapp/
grep -R "status" -n src/ webapp/
grep -R "sendRedirect" -n src/
```

## Correção esperada

- Aplicar o mesmo controle no canal principal e alternativo.
- Proteger endpoints Ajax, download, exportação e callback.
- Evitar JSP acessível diretamente.
- Colocar páginas sensíveis em `WEB-INF`.
- Bloquear endpoints de debug em produção.

---

# CWE-425 - Direct Request ('Forced Browsing')

## Explicação prática

Forced browsing ocorre quando o usuário acessa diretamente uma URL, Action, JSP, arquivo ou endpoint que deveria ser alcançado apenas por um fluxo controlado.

## Código vulnerável

```jsp
<!-- webapp/admin/relatorioSigiloso.jsp -->
<html>
<body>
    Relatório sigiloso: ${dados}
</body>
</html>
```

Se esse JSP estiver em uma pasta pública, o usuário pode tentar acessar:

```text
https://sistema.exemplo.gov.br/admin/relatorioSigiloso.jsp
```

## Solução segura

Coloque JSPs internos em `WEB-INF` e sirva apenas via Action/Controller autorizado.

```text
/WEB-INF/jsp/admin/relatorioSigiloso.jsp
```

```java
public class RelatorioSigilosoAction extends Action {

    public ActionForward iniciar(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) throws Exception {

        Usuario usuario = obterUsuarioAutenticado(request);

        if (!usuario.temPermissao("RELATORIO_SIGILOSO_CONSULTAR")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }

        request.setAttribute("dados", relatorioService.obterDados(usuario));
        return mapping.findForward("relatorioSigiloso");
    }
}
```

## Como revisar

```bash
find src/main/webapp -name "*.jsp" | grep -v WEB-INF
grep -R "forward" -n src/main/resources/struts-config.xml
grep -R "\.do?action=" -n src/main/webapp
```

## Correção esperada

- Nenhum JSP sensível público.
- Toda URL sensível passa por autenticação e autorização.
- O backend valida permissões mesmo se a tela esconder o botão.
- Arquivos privados não ficam em pasta pública.

---

# CWE-515 - Covert Storage Channel

## Explicação prática

Um canal encoberto de armazenamento ocorre quando componentes usam um recurso compartilhado para transmitir informação de forma não prevista pela política de segurança.

Em Java corporativo, aparece como:

- módulo de baixo privilégio grava comando em tabela compartilhada;
- job de alto privilégio lê esse comando e executa;
- uso de arquivo temporário compartilhado como sinalização;
- metadados, comentários ou campos livres usados para transferir instruções;
- cache global usado como canal entre usuários ou contextos.

## Código vulnerável

```java
public class SolicitacaoService {

    public void salvarObservacao(Long idSolicitacao, String observacao) {
        Solicitacao s = dao.buscar(idSolicitacao);
        s.setObservacao(observacao);
        dao.atualizar(s);
    }
}
```

```java
public class JobAdministrativo {

    public void executar() {
        List<Solicitacao> solicitacoes = dao.buscarPendentes();

        for (Solicitacao s : solicitacoes) {
            if (s.getObservacao().startsWith("EXECUTAR:")) {
                executarComandoAdministrativo(s.getObservacao().substring(9));
            }
        }
    }
}
```

### Problema

Um campo aparentemente inofensivo, `observacao`, vira canal de comunicação para um job privilegiado.

## Solução segura

```java
public class JobAdministrativoSeguro {

    private static final Set<String> COMANDOS_PERMITIDOS = Collections.unmodifiableSet(new HashSet<>(Arrays.asList(
            "REENVIAR_EMAIL",
            "REPROCESSAR_GUIA"
    )));

    public void executar() {
        List<ComandoAdministrativo> comandos = comandoDAO.buscarPendentesAutorizados();

        for (ComandoAdministrativo comando : comandos) {
            if (!COMANDOS_PERMITIDOS.contains(comando.getTipo())) {
                auditoria.warn("Comando administrativo inválido: " + comando.getId());
                continue;
            }

            executarComandoPermitido(comando);
        }
    }
}
```

## Como revisar

```bash
grep -R "startsWith(\"EXEC" -n src/
grep -R "observacao" -n src/ | grep -i job
grep -R "comentario" -n src/ | grep -i exec
grep -R "System.getProperty" -n src/
grep -R "File.createTempFile" -n src/
```

## Correção esperada

- Não usar campos livres como comandos.
- Separar dados de usuário de comandos administrativos.
- Validar origem, perfil e autorização de comandos.
- Auditar ações privilegiadas.
- Evitar cache/global state como canal entre usuários.

---

# CWE-918 - Server-Side Request Forgery (SSRF)

## Explicação prática

SSRF ocorre quando o servidor faz uma requisição para um destino controlado pelo usuário.

O atacante pode tentar fazer o servidor acessar:

- `localhost`;
- rede interna;
- metadados de cloud;
- serviços administrativos;
- endpoints não expostos externamente;
- arquivos via esquemas perigosos, dependendo da API usada.

## Código vulnerável

```java
public class DownloadRemotoAction extends Action {

    public ActionForward baixar(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) throws Exception {

        String urlDocumento = request.getParameter("url");

        URL url = new URL(urlDocumento);
        HttpURLConnection con = (HttpURLConnection) url.openConnection();

        try (InputStream in = con.getInputStream()) {
            copiarParaResponse(in, response);
        }

        return null;
    }
}
```

### Problema

O usuário controla a URL que o servidor acessará.

Exemplos perigosos:

```text
http://localhost:8080/admin
http://127.0.0.1:9990/management
http://169.254.169.254/latest/meta-data/
http://10.0.0.5:8080/interno
```

## Solução segura

```java
public class UrlDestinoValidator {

    private static final Set<String> HOSTS_PERMITIDOS = Collections.unmodifiableSet(new HashSet<>(Arrays.asList(
            "documentos.exemplo.gov.br",
            "arquivos.exemplo.gov.br"
    )));

    public void validar(URI uri) throws UnknownHostException {
        if (uri == null || uri.getScheme() == null || uri.getHost() == null) {
            throw new SecurityException("URL inválida.");
        }

        if (!"https".equalsIgnoreCase(uri.getScheme())) {
            throw new SecurityException("Somente HTTPS é permitido.");
        }

        String host = uri.getHost().toLowerCase(Locale.ROOT);

        if (!HOSTS_PERMITIDOS.contains(host)) {
            throw new SecurityException("Host não permitido.");
        }

        InetAddress[] enderecos = InetAddress.getAllByName(host);
        for (InetAddress endereco : enderecos) {
            if (isEnderecoPrivadoOuLocal(endereco)) {
                throw new SecurityException("Destino interno não permitido.");
            }
        }
    }

    private boolean isEnderecoPrivadoOuLocal(InetAddress endereco) {
        return endereco.isAnyLocalAddress()
                || endereco.isLoopbackAddress()
                || endereco.isLinkLocalAddress()
                || endereco.isSiteLocalAddress()
                || endereco.isMulticastAddress();
    }
}
```

```java
public class DownloadRemotoSeguroService {

    private final UrlDestinoValidator validator = new UrlDestinoValidator();

    public byte[] baixarDocumento(String urlDocumento) throws Exception {
        URI uri = new URI(urlDocumento).normalize();
        validator.validar(uri);

        HttpsURLConnection con = (HttpsURLConnection) uri.toURL().openConnection();
        con.setInstanceFollowRedirects(false);
        con.setConnectTimeout(5000);
        con.setReadTimeout(10000);
        con.setRequestMethod("GET");

        int status = con.getResponseCode();
        if (status >= 300 && status < 400) {
            throw new SecurityException("Redirect não permitido para download remoto.");
        }

        if (status != 200) {
            throw new IOException("Falha ao baixar documento. Status: " + status);
        }

        try (InputStream in = con.getInputStream()) {
            return lerComLimite(in, 5 * 1024 * 1024);
        }
    }

    private byte[] lerComLimite(InputStream in, int limiteBytes) throws IOException {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        byte[] buffer = new byte[8192];
        int total = 0;
        int lidos;

        while ((lidos = in.read(buffer)) != -1) {
            total += lidos;
            if (total > limiteBytes) {
                throw new IOException("Arquivo excede limite permitido.");
            }
            out.write(buffer, 0, lidos);
        }

        return out.toByteArray();
    }
}
```

## Observações importantes

A validação de SSRF é difícil. Cuidado com:

- redirecionamentos;
- DNS rebinding;
- IPv6;
- URLs com usuário/senha;
- encoding;
- IP em decimal, octal ou hexadecimal;
- host permitido que redireciona para rede interna;
- `file://`, `jar://`, `gopher://`, `ftp://`.

## Como revisar

```bash
grep -R "new URL" -n src/
grep -R "URI.create" -n src/
grep -R "openConnection" -n src/
grep -R "RestTemplate" -n src/
grep -R "WebClient" -n src/
grep -R "HttpClient" -n src/
grep -R "getParameter(.*url" -n src/
grep -R "callback" -n src/
grep -R "webhook" -n src/
```

## Correção esperada

- Nunca acessar URL arbitrária do usuário.
- Usar allowlist de hosts.
- Bloquear IPs privados, loopback e link-local.
- Bloquear redirects para destino não validado.
- Usar timeout e limite de tamanho.
- Não anexar credenciais automaticamente em chamadas arbitrárias.

---

# CWE-924 - Improper Enforcement of Message Integrity During Transmission in a Communication Channel

## Explicação prática

Ocorre quando a mensagem trafega por um canal, mas a aplicação não garante que ela não foi alterada.

Mesmo com HTTPS, em integrações assíncronas, filas, webhooks ou callbacks, pode ser necessário validar a integridade da mensagem no nível da aplicação.

## Código vulnerável

```java
public class WebhookPagamentoAction extends Action {

    public ActionForward receber(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) throws Exception {

        PagamentoDTO dto = objectMapper.readValue(request.getInputStream(), PagamentoDTO.class);

        pagamentoService.marcarComoPago(dto.getIdPagamento(), dto.getValor());

        response.setStatus(HttpServletResponse.SC_OK);
        return null;
    }
}
```

### Problema

A aplicação aceita qualquer payload enviado ao endpoint.

Não há assinatura, HMAC, timestamp, nonce ou validação de origem confiável.

## Solução segura com HMAC

```java
public class AssinaturaMensagemService {

    private static final String HMAC_ALGORITHM = "HmacSHA256";
    private final byte[] segredo;

    public AssinaturaMensagemService(byte[] segredo) {
        this.segredo = Arrays.copyOf(segredo, segredo.length);
    }

    public boolean assinaturaValida(byte[] payload, String assinaturaRecebida) {
        if (assinaturaRecebida == null || assinaturaRecebida.trim().isEmpty()) {
            return false;
        }

        byte[] assinaturaCalculada = calcularHmac(payload);
        byte[] assinaturaInformada = hexParaBytes(assinaturaRecebida);

        return MessageDigest.isEqual(assinaturaCalculada, assinaturaInformada);
    }

    private byte[] calcularHmac(byte[] payload) {
        try {
            Mac mac = Mac.getInstance(HMAC_ALGORITHM);
            mac.init(new SecretKeySpec(segredo, HMAC_ALGORITHM));
            return mac.doFinal(payload);
        } catch (GeneralSecurityException e) {
            throw new IllegalStateException("Erro ao calcular HMAC.", e);
        }
    }

    private byte[] hexParaBytes(String hex) {
        if (hex.length() % 2 != 0) {
            return new byte[0];
        }

        byte[] bytes = new byte[hex.length() / 2];
        for (int i = 0; i < hex.length(); i += 2) {
            bytes[i / 2] = (byte) Integer.parseInt(hex.substring(i, i + 2), 16);
        }
        return bytes;
    }
}
```

```java
public class WebhookPagamentoSeguroAction extends Action {

    private final AssinaturaMensagemService assinaturaService;

    public WebhookPagamentoSeguroAction(AssinaturaMensagemService assinaturaService) {
        this.assinaturaService = assinaturaService;
    }

    public ActionForward receber(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) throws Exception {

        byte[] payload = lerBodyComLimite(request.getInputStream(), 1024 * 1024);
        String assinatura = request.getHeader("X-Signature-SHA256");

        if (!assinaturaService.assinaturaValida(payload, assinatura)) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return null;
        }

        PagamentoDTO dto = objectMapper.readValue(payload, PagamentoDTO.class);
        pagamentoService.marcarComoPago(dto.getIdPagamento(), dto.getValor());

        response.setStatus(HttpServletResponse.SC_OK);
        return null;
    }
}
```

## Como revisar

```bash
grep -R "webhook" -n src/
grep -R "callback" -n src/
grep -R "X-Signature" -n src/
grep -R "HmacSHA" -n src/
grep -R "MessageDigest.isEqual" -n src/
```

## Correção esperada

- Usar HMAC, assinatura digital ou mTLS.
- Validar timestamp e nonce para evitar replay.
- Comparar assinaturas com `MessageDigest.isEqual`.
- Rejeitar mensagens sem assinatura.
- Auditar falhas de integridade.

---

# CWE-940 - Improper Verification of Source of a Communication Channel

## Explicação prática

Ocorre quando a aplicação não verifica adequadamente a fonte de uma comunicação.

Exemplos:

- confiar em `X-Forwarded-For` vindo direto do cliente;
- aceitar webhook sem assinatura;
- liberar função administrativa por IP informado em header;
- confiar em `User-Agent`;
- confiar em `Host` para montar link sensível.

## Código vulnerável

```java
public class IpPermissaoService {

    public boolean origemInterna(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        return ip != null && ip.startsWith("10.");
    }
}
```

### Problema

O cliente pode enviar o header `X-Forwarded-For` com valor falso.

```text
X-Forwarded-For: 10.0.0.10
```

## Solução segura

```java
public class OrigemConfiavelService {

    private static final Set<String> PROXIES_CONFIAVEIS = Collections.unmodifiableSet(new HashSet<>(Arrays.asList(
            "192.168.10.10",
            "192.168.10.11"
    )));

    public String obterIpCliente(HttpServletRequest request) {
        String remoteAddr = request.getRemoteAddr();

        if (!PROXIES_CONFIAVEIS.contains(remoteAddr)) {
            return remoteAddr;
        }

        String xff = request.getHeader("X-Forwarded-For");
        if (xff == null || xff.trim().isEmpty()) {
            return remoteAddr;
        }

        return xff.split(",")[0].trim();
    }

    public boolean origemInterna(HttpServletRequest request) {
        String ipCliente = obterIpCliente(request);
        return ipCliente.startsWith("10.");
    }
}
```

## Melhor prática

Não use apenas IP como autenticação para função crítica. Combine:

- autenticação forte;
- autorização;
- mTLS ou assinatura;
- allowlist de rede;
- auditoria.

## Como revisar

```bash
grep -R "X-Forwarded-For" -n src/
grep -R "getRemoteAddr" -n src/
grep -R "User-Agent" -n src/
grep -R "getHeader(\"Host\")" -n src/
grep -R "getHeader(\"Referer\")" -n src/
```

## Correção esperada

- Só confiar em headers de proxy quando o request vem de proxy confiável.
- Não usar header falsificável como autenticação.
- Validar webhooks com assinatura.
- Validar origem e identidade em canais internos.

---

# CWE-941 - Incorrectly Specified Destination in a Communication Channel

## Explicação prática

Ocorre quando a aplicação envia dados para o destino errado.

Em Java, isso aparece quando:

- ambiente de homologação aponta para produção;
- parâmetro define host de destino;
- callback usa URL errada;
- fila/tópico errado recebe dados sensíveis;
- tenant errado recebe notificação;
- configuração usa endpoint genérico demais.

## Código vulnerável

```java
public class NotificacaoService {

    public void enviarNotificacao(Long idUsuario, String mensagem) throws IOException {
        Usuario usuario = usuarioDAO.buscar(idUsuario);

        String endpoint = System.getProperty("notificacao.url");

        HttpURLConnection con = (HttpURLConnection) new URL(endpoint).openConnection();
        con.setRequestMethod("POST");
        con.setDoOutput(true);

        String json = "{\"email\":\"" + usuario.getEmail() + "\",\"mensagem\":\"" + mensagem + "\"}";
        con.getOutputStream().write(json.getBytes(StandardCharsets.UTF_8));
    }
}
```

### Problemas

- destino genérico e sem validação;
- risco de ambiente errado;
- risco de endpoint alterado por configuração;
- envio de dado sensível para destino indevido.

## Solução segura

```java
public enum CanalNotificacao {
    EMAIL("https://notificacao.exemplo.gov.br/email"),
    SMS("https://notificacao.exemplo.gov.br/sms");

    private final URI uri;

    CanalNotificacao(String uri) {
        this.uri = URI.create(uri);
    }

    public URI getUri() {
        return uri;
    }
}
```

```java
public class NotificacaoSeguraService {

    public void enviarNotificacao(Long idUsuario, String mensagem, CanalNotificacao canal) throws IOException {
        Usuario usuario = usuarioDAO.buscar(idUsuario);
        URI destino = canal.getUri();

        validarDestino(destino);

        HttpsURLConnection con = (HttpsURLConnection) destino.toURL().openConnection();
        con.setRequestMethod("POST");
        con.setDoOutput(true);
        con.setConnectTimeout(5000);
        con.setReadTimeout(10000);
        con.setRequestProperty("Content-Type", "application/json; charset=UTF-8");

        String json = objectMapper.writeValueAsString(new NotificacaoDTO(usuario.getEmail(), mensagem));
        con.getOutputStream().write(json.getBytes(StandardCharsets.UTF_8));
    }

    private void validarDestino(URI destino) {
        if (!"https".equalsIgnoreCase(destino.getScheme())) {
            throw new SecurityException("Destino deve usar HTTPS.");
        }

        if (!destino.getHost().endsWith(".exemplo.gov.br")) {
            throw new SecurityException("Destino fora do domínio permitido.");
        }
    }
}
```

## Como revisar

```bash
grep -R "System.getProperty" -n src/
grep -R "getenv" -n src/
grep -R "\.url" -n src/main/resources/
grep -R "endpoint" -n src/
grep -R "callback" -n src/
```

## Correção esperada

- Tipar destinos por enum/configuração validada.
- Separar configuração por ambiente com validação de startup.
- Não permitir destino controlado por usuário.
- Validar tenant, canal e endpoint.
- Registrar destino usado em auditoria, sem expor segredo.

---

# CWE-1327 - Binding to an Unrestricted IP Address

## Explicação prática

Ocorre quando uma aplicação ou serviço escuta em todas as interfaces de rede, por exemplo `0.0.0.0`, sem necessidade.

Isso pode expor serviços administrativos, debug, métricas ou APIs internas para redes não previstas.

## Código vulnerável

```java
public class ServidorAdminLocal {

    public void iniciar() throws IOException {
        HttpServer server = HttpServer.create(new InetSocketAddress("0.0.0.0", 9090), 0);
        server.createContext("/admin/reload", exchange -> {
            recarregarConfiguracao();
            exchange.sendResponseHeaders(200, 0);
            exchange.close();
        });
        server.start();
    }
}
```

### Problema

O serviço administrativo escuta em todas as interfaces. Se a máquina estiver acessível na rede, qualquer host pode tentar acessar a porta.

## Solução segura

```java
public class ServidorAdminLocalSeguro {

    public void iniciar() throws IOException {
        HttpServer server = HttpServer.create(new InetSocketAddress("127.0.0.1", 9090), 0);
        server.createContext("/admin/reload", exchange -> {
            if (!"POST".equalsIgnoreCase(exchange.getRequestMethod())) {
                exchange.sendResponseHeaders(405, -1);
                return;
            }

            String token = exchange.getRequestHeaders().getFirst("X-Admin-Token");
            if (!tokenValido(token)) {
                exchange.sendResponseHeaders(403, -1);
                return;
            }

            recarregarConfiguracao();
            exchange.sendResponseHeaders(204, -1);
        });
        server.start();
    }
}
```

## Também revisar configuração

Em aplicações com Spring Boot, WildFly, Tomcat, containers ou scripts:

```properties
# vulnerável se não houver necessidade real
server.address=0.0.0.0
management.server.address=0.0.0.0
```

Preferir:

```properties
server.address=127.0.0.1
management.server.address=127.0.0.1
```

Ou restringir por rede, firewall, reverse proxy, autenticação e mTLS.

## Como revisar

```bash
grep -R "0.0.0.0" -n .
grep -R "InetSocketAddress" -n src/
grep -R "HttpServer.create" -n src/
grep -R "server.address" -n .
grep -R "management.server" -n .
grep -R "jboss.bind.address" -n .
```

## Correção esperada

- Serviços internos devem escutar em `127.0.0.1` ou interface restrita.
- Portas administrativas devem ter autenticação.
- Usar firewall/security group.
- Não expor debug, métricas sensíveis ou admin sem controle.
- Revisar configuração de containers e app server.

---

# Utilitários práticos para revisão

## 1. Validador básico de canal HTTPS

```java
public final class CanalSeguroValidator {

    private CanalSeguroValidator() {
    }

    public static URI validarHttps(String valor) {
        try {
            URI uri = new URI(valor).normalize();

            if (!"https".equalsIgnoreCase(uri.getScheme())) {
                throw new SecurityException("A URL deve usar HTTPS.");
            }

            if (uri.getHost() == null || uri.getHost().trim().isEmpty()) {
                throw new SecurityException("Host obrigatório.");
            }

            if (uri.getUserInfo() != null) {
                throw new SecurityException("URL com userinfo não é permitida.");
            }

            return uri;
        } catch (URISyntaxException e) {
            throw new SecurityException("URL inválida.", e);
        }
    }
}
```

## 2. Política de origem

```java
public class PoliticaOrigem {

    private final Set<String> origensPermitidas;

    public PoliticaOrigem(Set<String> origensPermitidas) {
        this.origensPermitidas = new HashSet<>(origensPermitidas);
    }

    public boolean permitida(String origin) {
        return origin != null && origensPermitidas.contains(origin);
    }
}
```

## 3. Política de destino externo

```java
public class PoliticaDestinoExterno {

    private final Set<String> hostsPermitidos;

    public PoliticaDestinoExterno(Set<String> hostsPermitidos) {
        this.hostsPermitidos = new HashSet<>();
        for (String host : hostsPermitidos) {
            this.hostsPermitidos.add(host.toLowerCase(Locale.ROOT));
        }
    }

    public void validar(URI uri) throws UnknownHostException {
        if (!"https".equalsIgnoreCase(uri.getScheme())) {
            throw new SecurityException("Somente HTTPS é permitido.");
        }

        String host = uri.getHost();
        if (host == null || !hostsPermitidos.contains(host.toLowerCase(Locale.ROOT))) {
            throw new SecurityException("Host não permitido.");
        }

        for (InetAddress address : InetAddress.getAllByName(host)) {
            if (address.isLoopbackAddress()
                    || address.isAnyLocalAddress()
                    || address.isLinkLocalAddress()
                    || address.isSiteLocalAddress()) {
                throw new SecurityException("Endereço interno não permitido.");
            }
        }
    }
}
```

---

# Mapeamento prático por tipo de problema

| Tipo de problema | CWEs mais relacionadas |
|---|---|
| URL controlada pelo usuário | CWE-918, CWE-941 |
| CORS/origem mal validada | CWE-346, CWE-940 |
| Header falsificável usado como segurança | CWE-940 |
| API HTTP com token | CWE-419 |
| Endpoint alternativo sem proteção | CWE-420, CWE-425 |
| Webhook sem assinatura | CWE-924, CWE-940 |
| Serviço admin em `0.0.0.0` | CWE-1327 |
| Comparação de token com tempo variável | CWE-385 |
| Campo livre usado como comando | CWE-515 |
| Criptografia sem autenticar entidade | CWE-322 |

---

# Comandos de busca para revisão de código

```bash
# URLs e chamadas externas
grep -R "new URL" -n src/
grep -R "URI.create" -n src/
grep -R "openConnection" -n src/
grep -R "RestTemplate" -n src/
grep -R "WebClient" -n src/
grep -R "HttpClient" -n src/

# HTTP inseguro
grep -R "http://" -n src/ resources/ .

# SSRF/callback/webhook
grep -R "callback" -n src/
grep -R "webhook" -n src/
grep -R "url" -n src/ | grep getParameter

# Origem e headers falsificáveis
grep -R "X-Forwarded-For" -n src/
grep -R "Origin" -n src/
grep -R "Referer" -n src/
grep -R "Host" -n src/

# CORS
grep -R "Access-Control-Allow-Origin" -n src/

# Serviços locais/admin
grep -R "0.0.0.0" -n .
grep -R "InetSocketAddress" -n src/
grep -R "HttpServer.create" -n src/

# Integridade de mensagem
grep -R "HmacSHA" -n src/
grep -R "X-Signature" -n src/
grep -R "MessageDigest.isEqual" -n src/
```

---

# Checklist de revisão

## Canal

- [ ] Toda comunicação sensível usa HTTPS/TLS?
- [ ] Existe bloqueio explícito para `http://`?
- [ ] Certificado e hostname são validados?
- [ ] Existe timeout de conexão e leitura?
- [ ] Redirecionamentos são controlados?

## Origem

- [ ] `Origin` é validado por allowlist?
- [ ] `X-Forwarded-For` só é usado quando o proxy é confiável?
- [ ] Webhooks possuem assinatura/mTLS?
- [ ] `Referer` não é usado como controle principal?

## Destino

- [ ] URLs externas não são controladas pelo usuário?
- [ ] Hosts externos são allowlistados?
- [ ] IPs internos, loopback e link-local são bloqueados?
- [ ] Ambientes homologação/produção têm destinos separados e validados?

## Integridade

- [ ] Mensagens críticas possuem HMAC/assinatura?
- [ ] Existe timestamp/nonce para evitar replay?
- [ ] Comparação de assinatura usa método seguro?

## Caminhos alternativos

- [ ] Endpoints Ajax, download, exportação e debug exigem autenticação/autorização?
- [ ] JSPs sensíveis estão em `WEB-INF`?
- [ ] Portas administrativas não escutam em `0.0.0.0` sem necessidade?

---

# Testes sugeridos

## Testes unitários

- Validar que URLs `http://` são rejeitadas.
- Validar que host fora da allowlist é rejeitado.
- Validar que `localhost`, `127.0.0.1`, `10.x.x.x`, `172.16.x.x`, `192.168.x.x` são rejeitados em chamadas externas.
- Validar assinatura HMAC correta e incorreta.
- Validar CORS para origem permitida e não permitida.
- Validar comparação segura de token.

## Testes de integração

- Tentar acessar endpoint direto sem autenticação.
- Tentar chamar callback com URL interna.
- Tentar webhook sem assinatura.
- Tentar webhook com payload alterado.
- Tentar endpoint administrativo por interface externa.
- Tentar redirecionamento de host permitido para IP interno.

## Testes manuais

- Alterar parâmetros `url`, `callback`, `redirect`, `endpoint`.
- Enviar headers falsos: `X-Forwarded-For`, `Origin`, `Host`.
- Testar URLs codificadas e normalizadas.
- Testar acesso direto a JSP/Action/endpoint.

---

# Resumo para prova

| CWE | Ideia principal | Exemplo Java comum | Correção |
|---|---|---|---|
| CWE-322 | Troca chave sem autenticar entidade | aceitar chave pública do request | certificado/mTLS/keystore |
| CWE-346 | Origem não validada | CORS refletindo qualquer Origin | allowlist exata |
| CWE-385 | Vazamento por tempo | comparar token com `equals` | `MessageDigest.isEqual` |
| CWE-419 | Canal principal sem proteção | API com token via HTTP | HTTPS/TLS obrigatório |
| CWE-420 | Canal alternativo sem proteção | endpoint Ajax/admin sem auth | controles iguais ao canal principal |
| CWE-425 | Acesso direto/forced browsing | JSP público sensível | `WEB-INF` + Action autorizada |
| CWE-515 | Canal encoberto por storage | campo observação usado como comando | separar dados de comandos |
| CWE-918 | SSRF | servidor acessa URL do usuário | allowlist + bloqueio IP interno |
| CWE-924 | Integridade da mensagem fraca | webhook sem assinatura | HMAC/assinatura/mTLS |
| CWE-940 | Fonte não verificada | confiar em `X-Forwarded-For` | proxy confiável + autenticação real |
| CWE-941 | Destino incorreto | endpoint configurável sem validação | destino tipado/validado |
| CWE-1327 | Bind irrestrito | admin em `0.0.0.0` | bind restrito + autenticação |

---

# Conclusão

A categoria **Communication Channel Errors** deve ser revisada sempre que o sistema se comunica com outro componente, serviço, endpoint, fila, webhook, callback ou canal administrativo.

A regra prática é:

> **validar origem, validar destino, proteger o canal, garantir integridade e impedir caminhos alternativos sem o mesmo nível de controle.**

Em sistemas Java legados, os principais pontos de atenção são chamadas com `new URL`, `openConnection`, endpoints Ajax, webhooks, CORS, download remoto, headers de proxy, JSPs públicos e portas administrativas.

---

# Referências oficiais

- CWE-417 - Communication Channel Errors: https://cwe.mitre.org/data/definitions/417.html
- CWE-322 - Key Exchange without Entity Authentication: https://cwe.mitre.org/data/definitions/322.html
- CWE-346 - Origin Validation Error: https://cwe.mitre.org/data/definitions/346.html
- CWE-385 - Covert Timing Channel: https://cwe.mitre.org/data/definitions/385.html
- CWE-419 - Unprotected Primary Channel: https://cwe.mitre.org/data/definitions/419.html
- CWE-420 - Unprotected Alternate Channel: https://cwe.mitre.org/data/definitions/420.html
- CWE-425 - Direct Request ('Forced Browsing'): https://cwe.mitre.org/data/definitions/425.html
- CWE-515 - Covert Storage Channel: https://cwe.mitre.org/data/definitions/515.html
- CWE-918 - Server-Side Request Forgery (SSRF): https://cwe.mitre.org/data/definitions/918.html
- CWE-924 - Improper Enforcement of Message Integrity During Transmission in a Communication Channel: https://cwe.mitre.org/data/definitions/924.html
- CWE-940 - Improper Verification of Source of a Communication Channel: https://cwe.mitre.org/data/definitions/940.html
- CWE-941 - Incorrectly Specified Destination in a Communication Channel: https://cwe.mitre.org/data/definitions/941.html
- CWE-1327 - Binding to an Unrestricted IP Address: https://cwe.mitre.org/data/definitions/1327.html
