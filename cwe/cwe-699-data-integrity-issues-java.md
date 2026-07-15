# CWE-699 — Software Development

## Category: Data Integrity Issues — CWE-1214

> **Objetivo:** apresentar uma documentação prática sobre falhas de integridade de dados, com exemplos vulneráveis e corrigidos em **Java 8**, aplicáveis a sistemas web, APIs REST, Struts/Servlet/JSP, integrações, arquivos, plugins, cookies, mensagens assinadas e canais de comunicação.

---

## 1. Visão geral

A categoria **CWE-1214 — Data Integrity Issues** agrupa fraquezas relacionadas à capacidade do software de assegurar que dados, mensagens, arquivos, configurações, componentes e recursos não foram modificados de forma indevida.

A integridade pode ser comprometida:

- antes, durante ou depois da transmissão;
- ao combinar dados confiáveis e não confiáveis;
- ao selecionar uma fonte menos confiável;
- durante parsing, desserialização ou canonicalização;
- ao carregar código, plugins ou dependências;
- ao usar cookies em decisões de segurança;
- ao validar assinatura, hash, MAC ou checksum;
- ao confiar em criptografia sem autenticação.

### Impactos possíveis

- alteração de parâmetros de negócio;
- elevação de privilégio;
- execução de código não autorizado;
- instalação de atualização maliciosa;
- fraude em mensagens de integração;
- adulteração de cookies;
- injeção de campos não assinados;
- aceitação de documentos ou tokens falsificados;
- corrupção de dados e perda de rastreabilidade.

---

## 2. Natureza da categoria e mapeamento

A **CWE-1214** é uma **Category**, usada para organizar fraquezas relacionadas. Ela não deve ser usada diretamente para mapear vulnerabilidades reais; deve-se selecionar a CWE Base ou Class que melhor represente a causa raiz.

Exemplos:

- retorno de `Signature.verify()` ignorado: **CWE-347**;
- cookie `role=ADMIN` usado na autorização: **CWE-565**;
- JAR baixado e executado sem verificação: **CWE-494**;
- AES/CBC sem MAC: **CWE-649**;
- webhook sem HMAC ou assinatura: **CWE-924**;
- parâmetro do request usado no lugar do principal autenticado: **CWE-348**.

---

## 3. CWEs abordadas

| CWE | Nome | Exemplo prático em Java |
|---:|---|---|
| 322 | Key Exchange without Entity Authentication | ECDH/TLS sem autenticação correta do peer |
| 346 | Origin Validation Error | Callback, WebSocket ou evento aceito sem validar origem |
| 347 | Improper Verification of Cryptographic Signature | Assinatura ignorada, chave errada ou bytes diferentes |
| 348 | Use of Less Trusted Source | Header/parâmetro usado no lugar de fonte autenticada |
| 349 | Acceptance of Extraneous Untrusted Data With Trusted Data | Campo não assinado sobrescreve campo assinado |
| 351 | Insufficient Type Distinction | IDs e objetos de tipos distintos tratados como equivalentes |
| 353 | Missing Support for Integrity Check | Protocolo ou arquivo sem checksum, MAC ou assinatura |
| 354 | Improper Validation of Integrity Check Value | Comparação parcial, ignorada ou realizada após o uso |
| 494 | Download of Code Without Integrity Check | Plugin ou atualização executada sem verificação |
| 565 | Reliance on Cookies without Validation and Integrity Checking | Papel, preço ou ID confiado diretamente do cookie |
| 649 | Reliance on Obfuscation or Encryption without Integrity Checking | Dado cifrado ou ofuscado, mas adulterável |
| 829 | Inclusion of Functionality from Untrusted Control Sphere | Biblioteca, plugin ou script de fonte externa não controlada |
| 924 | Improper Enforcement of Message Integrity During Transmission | Mensagem de integração sem proteção contra alteração |

---

# 4. Conceitos fundamentais

## 4.1 Integridade, autenticidade e confidencialidade

### Confidencialidade

Impede a leitura do conteúdo por terceiros. Não garante automaticamente que o ciphertext não foi alterado.

### Integridade

Permite detectar alteração. Mecanismos típicos:

- HMAC;
- assinatura digital;
- modo AEAD, como AES-GCM;
- checksum, quando o risco é apenas corrupção acidental.

### Autenticidade

Permite vincular dados a uma origem autorizada. Pode ser obtida por assinatura digital, HMAC, TLS autenticado ou mTLS.

| Necessidade | Mecanismo típico |
|---|---|
| Detectar corrupção acidental | CRC ou checksum |
| Detectar adulteração maliciosa | HMAC, assinatura ou AEAD |
| Ocultar conteúdo | Criptografia |
| Ocultar e detectar adulteração | AEAD, como AES-GCM |
| Comprovar origem | Assinatura, HMAC ou canal autenticado |

Um hash SHA-256 enviado junto do arquivo pelo mesmo canal não protege contra um atacante que consiga substituir tanto o arquivo quanto o hash.

## 4.2 Hash, MAC e assinatura

### Hash

```java
MessageDigest digest =
    MessageDigest.getInstance("SHA-256");

byte[] hash = digest.digest(data);
```

Não usa segredo. Qualquer pessoa pode recalcular.

### HMAC

```java
Mac mac = Mac.getInstance("HmacSHA256");
mac.init(secretKey);

byte[] tag = mac.doFinal(data);
```

Usa segredo compartilhado e oferece integridade/autenticidade entre participantes que conhecem a chave.

### Assinatura digital

```java
Signature signature =
    Signature.getInstance("SHA256withRSA");

signature.initVerify(publicKey);
signature.update(data);

boolean valid =
    signature.verify(signatureBytes);
```

Exige confiança correta na chave pública, no algoritmo e nos bytes assinados.

## 4.3 AEAD

AEAD significa **Authenticated Encryption with Associated Data**. AES-GCM oferece confidencialidade e integridade, além de autenticar dados associados não cifrados, como `tenantId`, tipo e versão.

## 4.4 Verificar antes de interpretar e usar

Fluxo incorreto:

```text
receber → desserializar → executar regra → verificar integridade
```

Fluxo recomendado:

```text
receber bytes → limitar tamanho → verificar integridade/autenticidade
→ verificar replay/validade → interpretar → validar semântica
→ autorizar → executar
```

A verificação criptográfica não substitui validação de entrada, autorização, controle de workflow ou proteção contra replay.

## 4.5 Assinar os bytes realmente processados

É perigoso validar uma representação e processar outra. Exemplos:

- assinar apenas parte do JSON;
- permitir propriedades duplicadas;
- normalizar depois da verificação;
- validar o JSON original e processar parâmetros adicionais;
- reserializar o conteúdo antes de calcular HMAC quando o protocolo assina bytes brutos.

---

# 5. CWE-322 — Key Exchange without Entity Authentication

## 5.1 Conceito

A aplicação estabelece ou negocia uma chave sem autenticar adequadamente a entidade remota. Diffie-Hellman ou ECDH produzem um segredo compartilhado, mas não comprovam sozinhos quem está do outro lado.

## 5.2 Exemplo vulnerável

```java
public SecretKey createSharedKey(
        PrivateKey localPrivateKey,
        byte[] remotePublicKeyBytes)
        throws GeneralSecurityException {

    KeyFactory keyFactory =
        KeyFactory.getInstance("EC");

    PublicKey remotePublicKey =
        keyFactory.generatePublic(
            new X509EncodedKeySpec(
                remotePublicKeyBytes
            )
        );

    KeyAgreement agreement =
        KeyAgreement.getInstance("ECDH");

    agreement.init(localPrivateKey);
    agreement.doPhase(remotePublicKey, true);

    byte[] sharedSecret =
        agreement.generateSecret();

    return new SecretKeySpec(
        Arrays.copyOf(sharedSecret, 16),
        "AES"
    );
}
```

A chave recebida não está vinculada a uma identidade confiável.

## 5.3 Solução

Na maioria dos sistemas Java:

- usar TLS;
- validar cadeia e hostname;
- usar truststore controlado;
- usar mTLS quando necessário;
- não aceitar `TrustManager` ou `HostnameVerifier` permissivo.

```java
URL url =
    new URL("https://integracao.exemplo/api");

HttpsURLConnection connection =
    (HttpsURLConnection) url.openConnection();

connection.setSSLSocketFactory(
    trustedSslContext.getSocketFactory()
);

connection.connect();
```

Quando houver protocolo próprio, autenticar a chave efêmera por assinatura/certificado, incluir nonce e contexto e impedir replay/downgrade.

---

# 6. CWE-346 — Origin Validation Error

## 6.1 Conceito

O sistema não verifica adequadamente se a origem dos dados ou da comunicação é válida.

Origem pode significar:

- aplicação que enviou evento;
- servidor que enviou callback;
- domínio web;
- origem de WebSocket;
- certificado cliente;
- produtor de fila;
- tenant que criou o dado.

## 6.2 Exemplo vulnerável

```java
public boolean isTrustedOrigin(
        HttpServletRequest request) {

    String origin =
        request.getHeader("Origin");

    return origin != null
        && origin.endsWith("empresa.com");
}
```

`maliciousempresa.com` também termina com `empresa.com`.

## 6.3 Solução com comparação exata

```java
public boolean isAllowedOrigin(
        HttpServletRequest request,
        Set<String> allowedOrigins) {

    String origin = request.getHeader("Origin");

    if (origin == null) {
        return false;
    }

    try {
        URI uri = new URI(origin);

        if (!"https".equalsIgnoreCase(
                uri.getScheme())) {
            return false;
        }

        String normalized =
            "https://"
            + uri.getHost().toLowerCase(Locale.ROOT)
            + (uri.getPort() == -1 || uri.getPort() == 443
                ? ""
                : ":" + uri.getPort());

        return allowedOrigins.contains(normalized);
    } catch (URISyntaxException e) {
        return false;
    }
}
```

`Origin` não substitui autenticação e autorização.

## 6.4 Callback seguro

```java
public void processCallback(
        byte[] rawBody,
        String signatureHeader,
        String timestampHeader) {

    webhookVerifier.verify(
        rawBody,
        signatureHeader,
        timestampHeader
    );

    PagamentoCallback callback =
        parse(rawBody);

    pagamentoService.confirmar(
        callback.getPagamentoId(),
        callback.getStatus()
    );
}
```

---

# 7. CWE-347 — Improper Verification of Cryptographic Signature

## 7.1 Conceito

A assinatura existe, mas é verificada incorretamente.

Erros comuns:

- ignorar o retorno de `verify()`;
- continuar após exceção;
- aceitar chave fornecida pelo atacante;
- permitir algoritmo indicado pelo payload sem política;
- assinar apenas parte do conteúdo;
- verificar depois do uso;
- processar bytes diferentes dos verificados.

## 7.2 Exemplo vulnerável

```java
public void process(
        byte[] data,
        byte[] signatureBytes,
        PublicKey publicKey)
        throws GeneralSecurityException {

    Signature verifier =
        Signature.getInstance("SHA256withRSA");

    verifier.initVerify(publicKey);
    verifier.update(data);

    verifier.verify(signatureBytes);

    execute(data);
}
```

O retorno booleano foi ignorado.

## 7.3 Solução

```java
public void process(
        byte[] data,
        byte[] signatureBytes,
        PublicKey publicKey)
        throws GeneralSecurityException {

    if (signatureBytes == null
            || signatureBytes.length == 0) {
        throw new SignatureException(
            "Assinatura obrigatória"
        );
    }

    Signature verifier =
        Signature.getInstance("SHA256withRSA");

    verifier.initVerify(publicKey);
    verifier.update(data);

    if (!verifier.verify(signatureBytes)) {
        throw new SignatureException(
            "Assinatura inválida"
        );
    }

    execute(data);
}
```

## 7.4 Chave confiável

```java
public boolean verify(
        String keyId,
        byte[] data,
        byte[] signature)
        throws GeneralSecurityException {

    PublicKey trustedKey =
        trustedKeyRepository
            .findActiveVerificationKey(keyId)
            .orElseThrow(
                () -> new SecurityException(
                    "Chave não autorizada"
                )
            );

    Signature verifier =
        Signature.getInstance("SHA256withRSA");

    verifier.initVerify(trustedKey);
    verifier.update(data);

    return verifier.verify(signature);
}
```

O `keyId` precisa ser validado; não deve virar caminho de arquivo nem permitir seleção de chave arbitrária.

---

# 8. CWE-348 — Use of Less Trusted Source

## 8.1 Conceito

Existem duas fontes para o mesmo dado, mas a aplicação usa a menos confiável ou a menos verificável.

Exemplos:

- ID do usuário no request em vez do principal autenticado;
- papel no cookie em vez do banco;
- preço do browser em vez do catálogo;
- `X-Forwarded-For` não normalizado;
- nome de arquivo do cliente em vez de ID interno.

## 8.2 Exemplo vulnerável

```java
public Documento obterDocumento(
        HttpServletRequest request) {

    Long usuarioId = Long.valueOf(
        request.getParameter("usuarioId")
    );

    Long documentoId = Long.valueOf(
        request.getParameter("documentoId")
    );

    return documentoDAO.findByUserAndId(
        usuarioId,
        documentoId
    );
}
```

## 8.3 Solução

```java
public Documento obterDocumento(
        AuthenticatedPrincipal principal,
        HttpServletRequest request) {

    Long documentoId = Long.valueOf(
        request.getParameter("documentoId")
    );

    return documentoDAO
        .findAuthorizedDocument(
            principal.getUserId(),
            documentoId
        )
        .orElseThrow(
            AuthorizationException::new
        );
}
```

Para IP de cliente, confiar apenas em proxies conhecidos que removem e recriam os headers. IP não deve ser fator único de autorização.

---

# 9. CWE-349 — Acceptance of Extraneous Untrusted Data With Trusted Data

## 9.1 Conceito

O sistema processa dados confiáveis, mas aceita dados adicionais não confiáveis no mesmo contexto e os trata como confiáveis.

## 9.2 Exemplo vulnerável

O payload assinado contém valor `500.00`, mas um parâmetro externo o sobrescreve:

```java
public void confirmar(
        SignedPedido signedPedido,
        HttpServletRequest request) {

    Pedido pedido =
        signatureService.verifyAndParse(
            signedPedido
        );

    BigDecimal valor =
        new BigDecimal(
            request.getParameter("valor")
        );

    pedido.setValor(valor);

    pagamentoService.confirmar(pedido);
}
```

## 9.3 Solução

```java
public void confirmar(
        SignedPedido signedPedido) {

    Pedido pedido =
        signatureService.verifyAndParse(
            signedPedido
        );

    pedidoValidator.validate(pedido);
    pagamentoService.confirmar(pedido);
}
```

Dados adicionais devem ser tratados como não confiáveis e nunca sobrescrever campos protegidos.

## 9.4 Rejeitar propriedades desconhecidas

```java
ObjectMapper mapper = new ObjectMapper();

mapper.configure(
    DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES,
    true
);

Pagamento pagamento =
    mapper.readValue(json, Pagamento.class);
```

Também é necessário tratar propriedades duplicadas, limites de tamanho/profundidade e diferenças entre parsers.

---

# 10. CWE-351 — Insufficient Type Distinction

## 10.1 Conceito

A aplicação não distingue adequadamente elementos de tipos diferentes.

Em Java isso pode aparecer por:

- uso excessivo de `String` e `Long`;
- `Map<String, Object>`;
- parâmetros `Object`;
- eventos genéricos;
- casts tardios;
- IDs de domínios diferentes com o mesmo tipo primitivo.

## 10.2 Exemplo vulnerável

```java
public void concederAcesso(
        Long usuarioId,
        Long recursoId) {

    permissaoDAO.insert(
        usuarioId,
        recursoId
    );
}
```

Não está claro se `recursoId` é documento, arquivo, processo ou unidade.

## 10.3 Solução com tipos explícitos

```java
public final class UserId {

    private final long value;

    public UserId(long value) {
        if (value <= 0) {
            throw new IllegalArgumentException(
                "UserId inválido"
            );
        }

        this.value = value;
    }

    public long getValue() {
        return value;
    }
}
```

```java
public final class DocumentId {

    private final long value;

    public DocumentId(long value) {
        if (value <= 0) {
            throw new IllegalArgumentException(
                "DocumentId inválido"
            );
        }

        this.value = value;
    }

    public long getValue() {
        return value;
    }
}
```

```java
public void grantDocumentAccess(
        UserId userId,
        DocumentId documentId) {

    permissionDAO.insertDocumentPermission(
        userId.getValue(),
        documentId.getValue()
    );
}
```

---

# 11. CWE-353 — Missing Support for Integrity Check

## 11.1 Conceito

O protocolo, formato ou fluxo não oferece mecanismo para verificar integridade.

Exemplos:

- datagrama UDP sem MAC;
- arquivo de configuração distribuído sem assinatura;
- exportação importada sem hash;
- pacote de atualização sem manifesto;
- backup sem verificação;
- mensagem de fila em ambiente não confiável sem autenticação.

## 11.2 Exemplo vulnerável

```java
public void send(
        DatagramSocket socket,
        InetAddress address,
        int port,
        byte[] payload)
        throws IOException {

    DatagramPacket packet =
        new DatagramPacket(
            payload,
            payload.length,
            address,
            port
        );

    socket.send(packet);
}
```

Se o contexto exige proteção contra adulteração, o protocolo não oferece nenhuma.

## 11.3 Solução com HMAC

```java
public final class AuthenticatedMessage {

    private final byte[] payload;
    private final byte[] mac;

    public AuthenticatedMessage(
            byte[] payload,
            byte[] mac) {

        this.payload =
            Arrays.copyOf(payload, payload.length);

        this.mac =
            Arrays.copyOf(mac, mac.length);
    }

    public byte[] getPayload() {
        return Arrays.copyOf(
            payload,
            payload.length
        );
    }

    public byte[] getMac() {
        return Arrays.copyOf(
            mac,
            mac.length
        );
    }
}
```

```java
public AuthenticatedMessage protect(
        byte[] payload,
        SecretKey hmacKey)
        throws GeneralSecurityException {

    Mac mac = Mac.getInstance("HmacSHA256");
    mac.init(hmacKey);

    byte[] tag = mac.doFinal(payload);

    return new AuthenticatedMessage(
        payload,
        tag
    );
}
```

### Checksum simples ou HMAC?

Checksum simples é adequado para corrupção acidental. Em canal com atacante, usar HMAC, assinatura, AEAD ou protocolo autenticado.

---

# 12. CWE-354 — Improper Validation of Integrity Check Value

## 12.1 Conceito

Existe valor de integridade, mas a aplicação:

- não o valida;
- compara parcialmente;
- valida depois do uso;
- ignora o resultado;
- aceita valor vazio;
- usa chave ou algoritmo errado;
- não inclui todos os campos;
- aceita fallback sem integridade.

## 12.2 Exemplo vulnerável: comparação parcial

```java
public boolean isValid(
        String expectedHash,
        String actualHash) {

    return expectedHash.substring(0, 8)
        .equals(actualHash.substring(0, 8));
}
```

## 12.3 Exemplo vulnerável: resultado ignorado

```java
boolean valid =
    MessageDigest.isEqual(
        expectedMac,
        calculatedMac
    );

process(payload);
```

## 12.4 Solução

```java
public void verifyMac(
        byte[] payload,
        byte[] receivedMac,
        SecretKey key)
        throws GeneralSecurityException {

    if (receivedMac == null
            || receivedMac.length != 32) {
        throw new SecurityException(
            "MAC inválido"
        );
    }

    Mac mac = Mac.getInstance("HmacSHA256");
    mac.init(key);

    byte[] calculatedMac =
        mac.doFinal(payload);

    try {
        if (!MessageDigest.isEqual(
                receivedMac,
                calculatedMac)) {
            throw new SecurityException(
                "Falha de integridade"
            );
        }
    } finally {
        Arrays.fill(
            calculatedMac,
            (byte) 0
        );
    }
}
```

## 12.5 Ordem correta

```java
public DomainMessage verifyAndParse(
        byte[] rawMessage,
        byte[] receivedMac,
        SecretKey key)
        throws GeneralSecurityException {

    enforceSizeLimit(rawMessage);
    verifyMac(rawMessage, receivedMac, key);

    return parser.parse(rawMessage);
}
```

---

# 13. CWE-494 — Download of Code Without Integrity Check

## 13.1 Conceito

A aplicação baixa código-fonte ou executável e o executa sem verificar suficientemente origem e integridade.

Exemplos:

- JAR remoto;
- plugin;
- atualização;
- script;
- regra dinâmica;
- firmware;
- classe carregada por `URLClassLoader`.

## 13.2 Exemplo vulnerável

```java
URL pluginUrl =
    new URL(
        request.getParameter("pluginUrl")
    );

URLClassLoader loader =
    new URLClassLoader(
        new URL[] { pluginUrl }
    );

Class<?> pluginClass =
    Class.forName(
        "com.example.Plugin",
        true,
        loader
    );

Plugin plugin =
    (Plugin) pluginClass.newInstance();

plugin.execute();
```

## 13.3 Solução com catálogo e hash confiável

```java
public final class ApprovedPlugin {

    private final String id;
    private final URI uri;
    private final byte[] sha256;

    // Construtor e getters defensivos.
}
```

```java
public Path downloadAndVerify(
        ApprovedPlugin plugin,
        Path destination)
        throws IOException,
               GeneralSecurityException {

    if (!"https".equalsIgnoreCase(
            plugin.getUri().getScheme())) {
        throw new SecurityException(
            "Protocolo não permitido"
        );
    }

    download(plugin.getUri(), destination);

    byte[] actualHash =
        calculateSha256(destination);

    if (!MessageDigest.isEqual(
            plugin.getSha256(),
            actualHash)) {

        Files.deleteIfExists(destination);

        throw new SecurityException(
            "Plugin com integridade inválida"
        );
    }

    return destination;
}
```

O hash esperado deve vir de fonte confiável, separada do artefato baixado.

## 13.4 Assinatura de código

Para atualização ou plugin:

- assinar o artefato;
- validar com chave confiável;
- validar certificado, algoritmo e versão;
- impedir downgrade;
- verificar antes de carregar;
- aplicar allowlist;
- executar com menor privilégio;
- registrar versão, `keyId` e hash.

Apenas abrir um `JarFile` com verificação habilitada não representa uma política completa: as entradas precisam ser lidas/verificadas e o assinante deve ser comparado com identidade confiável.

## 13.5 Dependências de build

Revisar:

- repositórios Maven não autorizados;
- dependências sem versão fixa;
- plugins de build;
- repositórios HTTP;
- snapshots em produção;
- atualização automática não controlada;
- pacotes de mesmo nome em repositórios públicos.

---

# 14. CWE-565 — Reliance on Cookies without Validation and Integrity Checking

## 14.1 Conceito

A aplicação usa a existência ou o valor de cookies em operação crítica sem assegurar que o valor é válido para o usuário associado.

O cliente pode alterar cookies mesmo que possuam:

- `HttpOnly`;
- `Secure`;
- `SameSite`.

Esses atributos são importantes, mas não impedem o próprio cliente de enviar outro valor.

## 14.2 Exemplo vulnerável

```java
public String getRole(
        HttpServletRequest request) {

    Cookie[] cookies = request.getCookies();

    if (cookies == null) {
        return "GUEST";
    }

    for (Cookie cookie : cookies) {
        if ("role".equals(cookie.getName())) {
            return cookie.getValue();
        }
    }

    return "GUEST";
}
```

Uso vulnerável:

```java
if ("ADMIN".equals(getRole(request))) {
    deleteUser();
}
```

## 14.3 Solução preferencial: estado no servidor

O cookie deve conter apenas um identificador opaco e aleatório:

```java
public AuthenticatedSession getSession(
        HttpServletRequest request) {

    String sessionId =
        cookieReader.read(
            request,
            "SESSION_ID"
        );

    return sessionRepository
        .findActive(sessionId)
        .orElseThrow(
            AuthenticationException::new
        );
}
```

Papéis e permissões vêm do servidor:

```java
Set<String> roles =
    authorizationService.getRoles(
        session.getUserId()
    );
```

## 14.4 Cookie stateless assinado

```java
public final class SignedCookieCodec {

    private final SecretKey hmacKey;

    public SignedCookieCodec(
            SecretKey hmacKey) {
        this.hmacKey = hmacKey;
    }

    public String encode(byte[] payload)
            throws GeneralSecurityException {

        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(hmacKey);

        byte[] tag = mac.doFinal(payload);

        return base64Url(payload)
            + "."
            + base64Url(tag);
    }

    public byte[] decodeAndVerify(
            String value)
            throws GeneralSecurityException {

        String[] parts = value.split("\\.", -1);

        if (parts.length != 2) {
            throw new SecurityException(
                "Cookie inválido"
            );
        }

        byte[] payload =
            Base64.getUrlDecoder().decode(parts[0]);

        byte[] receivedTag =
            Base64.getUrlDecoder().decode(parts[1]);

        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(hmacKey);

        byte[] calculatedTag =
            mac.doFinal(payload);

        if (!MessageDigest.isEqual(
                receivedTag,
                calculatedTag)) {
            throw new SecurityException(
                "Cookie adulterado"
            );
        }

        return payload;
    }

    private String base64Url(byte[] value) {
        return Base64.getUrlEncoder()
            .withoutPadding()
            .encodeToString(value);
    }
}
```

O formato real ainda precisa de versão, `keyId`, expiração, audiência, sessão, limites de tamanho e estratégia de revogação.

---

# 15. CWE-649 — Reliance on Obfuscation or Encryption without Integrity Checking

## 15.1 Conceito

A aplicação cifra ou ofusca um valor que não deveria ser alterado pelo cliente, mas não implementa verificação de integridade.

Confidencialidade não implica integridade.

## 15.2 Exemplo vulnerável: AES-CBC sem MAC

```java
public byte[] encrypt(
        SecretKey key,
        byte[] iv,
        byte[] plaintext)
        throws GeneralSecurityException {

    Cipher cipher =
        Cipher.getInstance(
            "AES/CBC/PKCS5Padding"
        );

    cipher.init(
        Cipher.ENCRYPT_MODE,
        key,
        new IvParameterSpec(iv)
    );

    return cipher.doFinal(plaintext);
}
```

## 15.3 Solução com AES-GCM

```java
public EncryptedValue encrypt(
        String keyId,
        SecretKey key,
        byte[] plaintext,
        byte[] aad)
        throws GeneralSecurityException {

    byte[] iv = new byte[12];

    SecureRandom random = new SecureRandom();
    random.nextBytes(iv);

    Cipher cipher =
        Cipher.getInstance(
            "AES/GCM/NoPadding"
        );

    cipher.init(
        Cipher.ENCRYPT_MODE,
        key,
        new GCMParameterSpec(128, iv)
    );

    if (aad != null) {
        cipher.updateAAD(aad);
    }

    byte[] ciphertext =
        cipher.doFinal(plaintext);

    return new EncryptedValue(
        keyId,
        iv,
        ciphertext
    );
}
```

Alteração de IV, ciphertext, tag ou AAD deve causar falha na decifragem.

## 15.4 Encrypt-then-MAC

Em legado que precise manter CBC:

1. usar chaves independentes para cifra e MAC;
2. calcular HMAC sobre versão, IV, ciphertext e contexto;
3. validar MAC antes de decifrar;
4. usar comparação em tempo constante;
5. não revelar diferença entre erro de padding e erro de MAC.

## 15.5 Obfuscação não é controle

```java
String hiddenId =
    Base64.getEncoder()
        .encodeToString(
            documentId.toString()
                .getBytes(
                    StandardCharsets.UTF_8
                )
        );
```

Base64 não impede geração de outro ID.

---

# 16. CWE-829 — Inclusion of Functionality from Untrusted Control Sphere

## 16.1 Conceito

A aplicação inclui funcionalidade executável cuja origem está fora da esfera de controle esperada.

Exemplos:

- script remoto;
- plugin informado pelo usuário;
- biblioteca em diretório gravável;
- JAR em compartilhamento público;
- dependência de repositório não autorizado;
- regra dinâmica fornecida por parceiro sem assinatura;
- JavaScript de terceiro com acesso ao DOM sensível.

## 16.2 Exemplo vulnerável

```java
String pluginPath =
    request.getParameter("pluginPath");

URLClassLoader loader =
    new URLClassLoader(
        new URL[] {
            new File(pluginPath)
                .toURI()
                .toURL()
        }
    );

Class<?> type =
    Class.forName(
        "com.example.CustomPlugin",
        true,
        loader
    );

type.newInstance();
```

## 16.3 Solução

- mapear IDs para plugins aprovados;
- armazenar em diretório não gravável pelo usuário da aplicação;
- verificar assinatura/hash;
- fixar versão;
- reduzir privilégios;
- revisar API exposta ao plugin;
- isolar processo quando necessário.

```java
public Plugin loadApprovedPlugin(
        String pluginId)
        throws Exception {

    ApprovedPlugin plugin =
        pluginCatalog.find(pluginId)
            .orElseThrow(
                () -> new SecurityException(
                    "Plugin não autorizado"
                )
            );

    Path verifiedJar =
        pluginVerifier.downloadAndVerify(plugin);

    URLClassLoader loader =
        new URLClassLoader(
            new URL[] {
                verifiedJar.toUri().toURL()
            },
            Plugin.class.getClassLoader()
        );

    Class<?> type =
        Class.forName(
            plugin.getImplementationClass(),
            true,
            loader
        );

    if (!Plugin.class.isAssignableFrom(type)) {
        loader.close();

        throw new SecurityException(
            "Tipo de plugin inválido"
        );
    }

    return (Plugin) type.newInstance();
}
```

Assinatura comprova origem e integridade, mas não garante que o código do fornecedor esteja livre de vulnerabilidades ou comportamento perigoso.

## 16.4 JavaScript em JSP

Vulnerável:

```jsp
<script src="${param.widgetUrl}"></script>
```

Preferível:

```jsp
<script
    src="/static/vendor/widget-4.2.1.min.js">
</script>
```

Para recurso externo inevitável: origem e versão fixas, HTTPS, CSP, Subresource Integrity quando aplicável e menor acesso possível.

---

# 17. CWE-924 — Improper Enforcement of Message Integrity During Transmission

## 17.1 Conceito

A aplicação recebe mensagem de um endpoint, mas não assegura suficientemente que ela permaneceu inalterada durante a transmissão.

Mesmo com TLS, proteção no nível da mensagem pode ser necessária quando:

- existem intermediários;
- a mensagem passa por filas;
- ela é armazenada e validada depois;
- o TLS termina antes do consumidor;
- o payload atravessa vários domínios;
- a origem precisa ser comprovada independentemente do canal.

## 17.2 Exemplo vulnerável

```java
@PostMapping("/webhook")
public void webhook(
        @RequestBody Evento evento) {

    eventoService.processar(evento);
}
```

## 17.3 Solução com HMAC sobre bytes brutos

```java
public final class WebhookVerifier {

    private final SecretKey hmacKey;
    private final Clock clock;
    private final ReplayRepository replayRepository;

    public WebhookVerifier(
            SecretKey hmacKey,
            Clock clock,
            ReplayRepository replayRepository) {

        this.hmacKey = hmacKey;
        this.clock = clock;
        this.replayRepository = replayRepository;
    }

    public void verify(
            byte[] rawBody,
            String signatureBase64,
            String timestampText,
            String eventId)
            throws GeneralSecurityException {

        long timestamp =
            Long.parseLong(timestampText);

        Instant sentAt =
            Instant.ofEpochSecond(timestamp);

        Duration age =
            Duration.between(
                sentAt,
                clock.instant()
            ).abs();

        if (age.compareTo(
                Duration.ofMinutes(5)) > 0) {
            throw new SecurityException(
                "Mensagem fora da janela"
            );
        }

        if (replayRepository.exists(eventId)) {
            throw new SecurityException(
                "Mensagem repetida"
            );
        }

        byte[] signedData = concatenate(
            timestampText.getBytes(
                StandardCharsets.UTF_8
            ),
            new byte[] { '.' },
            eventId.getBytes(
                StandardCharsets.UTF_8
            ),
            new byte[] { '.' },
            rawBody
        );

        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(hmacKey);

        byte[] calculated =
            mac.doFinal(signedData);

        byte[] received =
            Base64.getDecoder().decode(
                signatureBase64
            );

        if (!MessageDigest.isEqual(
                received,
                calculated)) {
            throw new SecurityException(
                "Assinatura inválida"
            );
        }

        replayRepository.register(
            eventId,
            sentAt
        );
    }

    private byte[] concatenate(
            byte[]... parts) {

        int length = 0;

        for (byte[] part : parts) {
            length += part.length;
        }

        byte[] result = new byte[length];
        int offset = 0;

        for (byte[] part : parts) {
            System.arraycopy(
                part,
                0,
                result,
                offset,
                part.length
            );

            offset += part.length;
        }

        return result;
    }
}
```

## 17.4 Processamento seguro

```java
public void processWebhook(
        byte[] rawBody,
        String signature,
        String timestamp,
        String eventId)
        throws GeneralSecurityException {

    enforceMaximumSize(rawBody);

    webhookVerifier.verify(
        rawBody,
        signature,
        timestamp,
        eventId
    );

    Evento evento =
        eventParser.parse(rawBody);

    eventValidator.validate(evento);
    authorizationPolicy.validate(evento);
    eventoService.processar(evento);
}
```

O consumo de `eventId` deve ser atômico. A chave deve ser específica por parceiro, rotacionável e nunca registrada em log.

---

# 18. Componentes reutilizáveis

## 18.1 Verificador de integridade

```java
public interface IntegrityVerifier {

    void verify(
        byte[] data,
        byte[] integrityValue
    ) throws GeneralSecurityException;
}
```

```java
public final class HmacSha256Verifier
        implements IntegrityVerifier {

    private final SecretKey key;

    public HmacSha256Verifier(
            SecretKey key) {
        this.key = key;
    }

    @Override
    public void verify(
            byte[] data,
            byte[] receivedMac)
            throws GeneralSecurityException {

        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(key);

        byte[] calculatedMac =
            mac.doFinal(data);

        try {
            if (!MessageDigest.isEqual(
                    receivedMac,
                    calculatedMac)) {
                throw new SecurityException(
                    "Falha de integridade"
                );
            }
        } finally {
            Arrays.fill(
                calculatedMac,
                (byte) 0
            );
        }
    }
}
```

## 18.2 Envelope versionado

```java
public final class IntegrityEnvelope {

    private final int version;
    private final String keyId;
    private final String algorithm;
    private final long timestamp;
    private final String messageId;
    private final byte[] payload;
    private final byte[] integrityValue;

    // Construtor e getters defensivos.
}
```

Benefícios:

- evolução de algoritmo;
- rotação de chaves;
- proteção contra replay;
- auditoria;
- compatibilidade entre versões;
- seleção segura da chave.

## 18.3 Política de fonte

```java
public interface TrustedSourcePolicy {

    void validate(
        SourceIdentity source,
        MessageContext context
    );
}
```

Pode validar certificado, issuer, tenant, producer ID, proxy, audience, tópico, ambiente e finalidade.

---

# 19. Diferenças entre CWEs próximas

## 19.1 CWE-353 versus CWE-354

| Situação | CWE |
|---|---:|
| Protocolo não possui campo de integridade | 353 |
| Campo existe, mas não é validado | 354 |
| Campo é validado parcialmente | 354 |
| Mecanismo é inadequado ao atacante esperado | Avaliar 353/354 e a causa de projeto |

## 19.2 CWE-347 versus CWE-354

- **CWE-347:** problema específico de assinatura criptográfica.
- **CWE-354:** problema genérico na validação de checksum ou valor de integridade.

Quando a falha for claramente na assinatura digital, preferir CWE-347.

## 19.3 CWE-346 versus CWE-348

- **CWE-346:** a origem não foi validada adequadamente.
- **CWE-348:** havia uma fonte mais confiável, mas a aplicação escolheu a menos confiável.

## 19.4 CWE-349 versus CWE-347

- assinatura válida, mas dados adicionais não assinados mudam a execução: **CWE-349**;
- assinatura validada incorretamente: **CWE-347**.

## 19.5 CWE-494 versus CWE-829

- **CWE-494:** código é baixado/executado sem verificar origem e integridade;
- **CWE-829:** funcionalidade é incluída de esfera não confiável.

Um plugin remoto controlado pelo usuário pode conter ambas.

## 19.6 CWE-565 versus CWE-649

- cookie usado sem validação/integridade: **CWE-565**;
- valor cifrado ou ofuscado usado sem integridade: **CWE-649**.

## 19.7 CWE-924 versus CWE-523

- **CWE-924:** mensagem pode ser alterada durante transmissão;
- **CWE-523:** credencial é transportada sem proteção.

---

# 20. Checklist de revisão

## 20.1 Origem

- A origem da mensagem é autenticada?
- A chave pública é confiável?
- Certificado e hostname são validados?
- Existe mTLS quando necessário?
- Headers de proxy são normalizados?
- O produtor da fila é identificado?
- O tenant está vinculado à credencial?

## 20.2 Assinatura e MAC

- O resultado é realmente testado?
- A validação ocorre antes do parsing?
- Todos os campos críticos estão cobertos?
- O algoritmo é definido pelo servidor?
- A chave possui finalidade adequada?
- Existe `keyId`?
- Há rotação?
- A comparação é constante?
- Valores vazios são rejeitados?

## 20.3 Dados estruturados

- Campos extras são rejeitados?
- Campos duplicados são rejeitados?
- O objeto validado é o mesmo usado?
- Query, header ou cookie pode sobrescrever campo assinado?
- Existe serialização canônica?
- Há limites de tamanho e profundidade?
- Tipos de IDs são distintos?

## 20.4 Criptografia

- O modo oferece autenticação?
- AES-GCM usa IV único?
- AAD vincula o contexto?
- CBC possui Encrypt-then-MAC?
- MAC é validado antes da decifragem?
- Erros evitam padding oracle?
- Base64 está sendo confundido com proteção?

## 20.5 Cookies

- Cookies críticos são apenas identificadores opacos?
- Estado de autorização permanece no servidor?
- Cookie stateless é assinado?
- Expiração é validada?
- Existe proteção contra replay?
- `Secure`, `HttpOnly` e `SameSite` estão configurados?
- O servidor valida todos os valores?

## 20.6 Código e dependências

- Plugins vêm de catálogo aprovado?
- Artefatos são assinados ou possuem hash confiável?
- O hash esperado vem de fonte confiável?
- Versões são fixas?
- Repositórios são autorizados?
- Existe proteção contra downgrade?
- Código remoto roda com privilégio mínimo?
- Scripts externos possuem política de origem?

## 20.7 Mensagens

- HMAC/assinatura cobre os bytes brutos?
- Timestamp é validado?
- Existe identificador único?
- Replay é impedido atomicamente?
- A chave é específica por parceiro?
- O tamanho é limitado antes da validação?
- TLS continua habilitado?

---

# 21. Comandos de busca no código

Os comandos servem para triagem e podem gerar falsos positivos.

## 21.1 Assinatura

```bash
grep -RniE \
  'Signature\.getInstance|\.verify\(|initVerify' \
  src/
```

Revisar se o retorno de `verify()` é usado.

## 21.2 Hash ou MAC

```bash
grep -RniE \
  'MessageDigest|Mac\.getInstance|HmacSHA|checksum|sha256|hash' \
  src/
```

## 21.3 Cookies

```bash
grep -RniE \
  'getCookies\(|new Cookie\(|getValue\(\)' \
  src/
```

## 21.4 Criptografia sem autenticação

```bash
grep -RniE \
  'AES/(CBC|ECB)|Cipher\.getInstance\("AES"\)|IvParameterSpec' \
  src/
```

## 21.5 Código remoto

```bash
grep -RniE \
  'URLClassLoader|Class\.forName|new URL\(|ScriptEngine|GroovyShell' \
  src/
```

## 21.6 Fonte menos confiável

```bash
grep -RniE \
  'X-Forwarded-For|X-Real-IP|getParameter\("(user|usuarioId|role|perfil)' \
  src/
```

## 21.7 Webhooks e callbacks

```bash
grep -RniE \
  'webhook|callback|notification|notificacao|evento' \
  src/
```

## 21.8 Base64 como proteção

```bash
grep -RniE \
  'Base64\.getEncoder|Base64\.getDecoder' \
  src/
```

## 21.9 Dependências externas em JSP

```bash
grep -RniE \
  '<script[^>]+src="https?://|<link[^>]+href="https?://' \
  src/main/webapp/ web/
```

---

# 22. Testes sugeridos

## 22.1 Assinatura

1. Assinatura válida.
2. Payload alterado.
3. Assinatura alterada.
4. Chave desconhecida.
5. Chave expirada ou revogada.
6. Algoritmo não permitido.
7. Assinatura vazia.
8. Campo extra não assinado.
9. Propriedade duplicada.
10. Bytes com encoding diferente.

## 22.2 HMAC e mensagens

1. HMAC válido.
2. Um byte alterado.
3. Timestamp antigo.
4. Timestamp futuro excessivo.
5. `eventId` repetido.
6. Duas requisições simultâneas.
7. Chave de outro parceiro.
8. Payload acima do limite.
9. Assinatura truncada.
10. Base64 inválido.

## 22.3 Cookies

1. Alterar `role`.
2. Alterar `userId`.
3. Reutilizar cookie após logout.
4. Reutilizar em outro usuário.
5. Remover assinatura.
6. Alterar expiração.
7. Usar `keyId` desconhecido.
8. Confirmar `Secure`, `HttpOnly` e `SameSite`.
9. Testar sessão expirada.
10. Testar revogação.

## 22.4 Código e plugins

1. Artefato válido.
2. Um byte alterado.
3. Hash incorreto.
4. Assinatura inválida.
5. Versão abaixo da mínima.
6. URL não aprovada.
7. Redirecionamento para outro host.
8. Certificado inválido.
9. Plugin com classe não permitida.
10. Diretório gravável por usuário não confiável.

## 22.5 AES-GCM

1. Cifrar o mesmo plaintext duas vezes.
2. Confirmar IVs diferentes.
3. Alterar ciphertext.
4. Alterar IV.
5. Alterar AAD.
6. Usar chave errada.
7. Truncar tag.
8. Usar `keyId` desconhecido.
9. Testar rotação.
10. Testar dados históricos.

---

# 23. Exemplos de testes unitários

## 23.1 Assinatura inválida deve impedir processamento

```java
@Test(expected = SignatureException.class)
public void invalidSignatureMustBeRejected()
        throws Exception {

    byte[] payload =
        "pedido=100".getBytes(
            StandardCharsets.UTF_8
        );

    byte[] invalidSignature =
        new byte[256];

    signedMessageService.verifyAndProcess(
        payload,
        invalidSignature,
        trustedPublicKey
    );
}
```

## 23.2 Campo não assinado não pode sobrescrever valor

```java
@Test
public void requestParameterMustNotOverrideSignedAmount()
        throws Exception {

    SignedPedido signed =
        signPedido(
            100L,
            new BigDecimal("500.00")
        );

    Pedido pedido =
        pedidoService.verifyAndParse(signed);

    assertEquals(
        new BigDecimal("500.00"),
        pedido.getValor()
    );
}
```

## 23.3 AES-GCM deve detectar alteração

```java
@Test(expected = AEADBadTagException.class)
public void changedCiphertextMustFail()
        throws Exception {

    EncryptedValue encrypted =
        cryptoService.encrypt(
            "dados".getBytes(
                StandardCharsets.UTF_8
            ),
            "tenant=10".getBytes(
                StandardCharsets.UTF_8
            )
        );

    byte[] changed =
        encrypted.getCiphertext();

    changed[0] ^= 0x01;

    EncryptedValue tampered =
        new EncryptedValue(
            encrypted.getKeyId(),
            encrypted.getIv(),
            changed
        );

    cryptoService.decrypt(
        tampered,
        "tenant=10".getBytes(
            StandardCharsets.UTF_8
        )
    );
}
```

---

# 24. Perguntas para revisão

1. Qual a diferença entre integridade e confidencialidade?
2. Por que um hash público não autentica a origem?
3. Quando usar checksum, HMAC, assinatura ou AEAD?
4. Por que a assinatura deve ser validada antes do parsing?
5. O que ocorre quando o retorno de `Signature.verify()` é ignorado?
6. Por que a chave pública recebida no request não é confiável?
7. O que caracteriza uma fonte menos confiável?
8. Como dados extras podem anular uma assinatura válida?
9. Por que propriedades desconhecidas devem ser tratadas explicitamente?
10. Como tipos fortes ajudam a evitar confusão de IDs?
11. Qual a diferença entre CWE-353 e CWE-354?
12. Por que baixar hash e artefato do mesmo local pode ser insuficiente?
13. `HttpOnly` impede adulteração de cookie pelo próprio cliente?
14. Por que AES-CBC não fornece integridade sozinho?
15. Como AES-GCM detecta alteração?
16. O que é AAD?
17. Qual a diferença entre CWE-494 e CWE-829?
18. TLS elimina a necessidade de assinatura de webhook em todos os cenários?
19. Por que timestamp sem `eventId` pode não impedir replay?
20. Por que se deve assinar os bytes efetivamente processados?

---

# 25. Resumo para prova

## CWE-1214

Categoria de problemas relacionados à integridade de dados. Deve-se mapear a causa específica em uma CWE Base/Class.

## CWE-322

Troca de chave sem autenticação da entidade remota.

## CWE-346

Origem de dados ou comunicação não validada adequadamente.

## CWE-347

Assinatura criptográfica verificada de maneira incorreta.

## CWE-348

Uso de fonte menos confiável quando existe outra mais segura.

## CWE-349

Dados extras não confiáveis são aceitos junto com dados confiáveis.

## CWE-351

Tipos diferentes não são distinguidos adequadamente.

## CWE-353

Ausência de mecanismo de verificação de integridade.

## CWE-354

Valor de integridade existe, mas é validado incorretamente.

## CWE-494

Código remoto é baixado e executado sem confirmar origem e integridade.

## CWE-565

Cookie é usado em operação crítica sem validação e proteção contra adulteração.

## CWE-649

Criptografia ou ofuscação é usada sem proteção de integridade.

## CWE-829

Funcionalidade é incluída a partir de esfera de controle não confiável.

## CWE-924

Mensagem pode ser modificada durante transmissão sem detecção adequada.

---

# 26. Quadro de decisão rápida

| Evidência | CWE provável |
|---|---:|
| ECDH usa chave pública não autenticada | 322 |
| Callback aceita qualquer origem | 346 |
| `Signature.verify()` é ignorado | 347 |
| `usuarioId` do request prevalece sobre principal autenticado | 348 |
| Query parameter sobrescreve valor assinado | 349 |
| Mesmo `Long` representa recursos distintos sem distinção | 351 |
| Protocolo não possui integridade | 353 |
| HMAC existe, mas não é comparado | 354 |
| JAR remoto é carregado diretamente | 494 |
| Cookie `role=ADMIN` decide autorização | 565 |
| AES-CBC protege parâmetro sem MAC | 649 |
| Plugin vem de caminho controlado pelo usuário | 829 |
| Webhook não possui assinatura/HMAC | 924 |

---

# 27. Referências

## MITRE CWE

- [CWE-1214 — Data Integrity Issues](https://cwe.mitre.org/data/definitions/1214.html)
- [CWE-322 — Key Exchange without Entity Authentication](https://cwe.mitre.org/data/definitions/322.html)
- [CWE-346 — Origin Validation Error](https://cwe.mitre.org/data/definitions/346.html)
- [CWE-347 — Improper Verification of Cryptographic Signature](https://cwe.mitre.org/data/definitions/347.html)
- [CWE-348 — Use of Less Trusted Source](https://cwe.mitre.org/data/definitions/348.html)
- [CWE-349 — Acceptance of Extraneous Untrusted Data With Trusted Data](https://cwe.mitre.org/data/definitions/349.html)
- [CWE-351 — Insufficient Type Distinction](https://cwe.mitre.org/data/definitions/351.html)
- [CWE-353 — Missing Support for Integrity Check](https://cwe.mitre.org/data/definitions/353.html)
- [CWE-354 — Improper Validation of Integrity Check Value](https://cwe.mitre.org/data/definitions/354.html)
- [CWE-494 — Download of Code Without Integrity Check](https://cwe.mitre.org/data/definitions/494.html)
- [CWE-565 — Reliance on Cookies without Validation and Integrity Checking](https://cwe.mitre.org/data/definitions/565.html)
- [CWE-649 — Reliance on Obfuscation or Encryption of Security-Relevant Inputs without Integrity Checking](https://cwe.mitre.org/data/definitions/649.html)
- [CWE-829 — Inclusion of Functionality from Untrusted Control Sphere](https://cwe.mitre.org/data/definitions/829.html)
- [CWE-924 — Improper Enforcement of Message Integrity During Transmission in a Communication Channel](https://cwe.mitre.org/data/definitions/924.html)

## Java

- [Java SE 8 — Signature](https://docs.oracle.com/javase/8/docs/api/java/security/Signature.html)
- [Java SE 8 — MessageDigest](https://docs.oracle.com/javase/8/docs/api/java/security/MessageDigest.html)
- [Java SE 8 — Mac](https://docs.oracle.com/javase/8/docs/api/javax/crypto/Mac.html)
- [Java SE 8 — Cipher](https://docs.oracle.com/javase/8/docs/api/javax/crypto/Cipher.html)
- [Java SE 8 — GCMParameterSpec](https://docs.oracle.com/javase/8/docs/api/javax/crypto/spec/GCMParameterSpec.html)
- [Java SE 8 — URLClassLoader](https://docs.oracle.com/javase/8/docs/api/java/net/URLClassLoader.html)

## Orientações complementares

- [OWASP Cryptographic Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html)
- [OWASP Third Party JavaScript Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Third_Party_Javascript_Management_Cheat_Sheet.html)
- [NIST FIPS 198-1 — HMAC](https://csrc.nist.gov/pubs/fips/198-1/final)
- [NIST SP 800-38D — GCM and GMAC](https://csrc.nist.gov/pubs/sp/800/38/d/final)

---

# 28. Conclusão

Integridade não é garantida apenas porque:

- o dado está cifrado;
- o valor parece opaco;
- o cookie possui `HttpOnly`;
- o canal usa HTTPS;
- existe um campo chamado `checksum`;
- o artefato veio de URL conhecida;
- a mensagem contém uma assinatura;
- a aplicação usa SHA-256.

O software precisa verificar:

- qual é a origem;
- qual fonte é confiável;
- quais bytes foram protegidos;
- qual chave foi usada;
- qual algoritmo é permitido;
- se todos os campos críticos estão cobertos;
- se a validação ocorre antes do uso;
- se há replay;
- se código e dependências pertencem à esfera de controle esperada;
- se a criptografia também oferece autenticação.

A regra central é:

> Dados só devem ser tratados como íntegros depois que sua origem, seu contexto e seu valor de integridade forem validados por mecanismo adequado ao risco, antes de qualquer interpretação ou decisão de segurança.
