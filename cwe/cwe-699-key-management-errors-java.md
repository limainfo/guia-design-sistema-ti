# CWE-699 — Software Development

## Category: Key Management Errors — CWE-320

> **Objetivo:** apresentar uma documentação prática sobre erros de gerenciamento de chaves criptográficas, com exemplos vulneráveis e corrigidos em **Java 8**, aplicáveis a sistemas web, APIs REST, integrações, application servers, aplicações legadas e serviços distribuídos.

---

## 1. Visão geral

A categoria **CWE-320 — Key Management Errors** reúne fraquezas relacionadas ao gerenciamento de chaves criptográficas.

Na versão atual da CWE, a entrada é uma **Category**, possui mapeamento de vulnerabilidade **proibido** e está marcada como obsoleta devido à sobreposição com outras categorias. Ela continua útil para organização e estudo, mas uma vulnerabilidade real deve ser mapeada para a CWE Base mais específica.

### CWEs desta categoria

| CWE | Nome |
|---:|---|
| 322 | Key Exchange without Entity Authentication |
| 323 | Reusing a Nonce, Key Pair in Encryption |
| 324 | Use of a Key Past its Expiration Date |
| 798 | Use of Hard-coded Credentials |

---

## 2. O que é gerenciamento de chaves

Gerenciamento de chaves é o conjunto de controles aplicados durante todo o ciclo de vida do material criptográfico.

Esse ciclo normalmente envolve:

1. geração;
2. registro;
3. distribuição;
4. ativação;
5. armazenamento;
6. autorização de uso;
7. utilização;
8. rotação;
9. expiração;
10. revogação;
11. arquivamento;
12. destruição.

Uma chave criptográfica pode ser usada para:

- cifrar dados;
- decifrar dados;
- assinar mensagens;
- verificar assinaturas;
- autenticar sistemas;
- derivar outras chaves;
- proteger tokens;
- proteger sessões;
- assinar JWT;
- assinar webhooks;
- estabelecer um segredo compartilhado;
- proteger backups;
- proteger arquivos ou documentos.

---

## 3. Por que o gerenciamento de chaves é crítico

Mesmo um algoritmo criptográfico forte pode ser inutilizado por gerenciamento incorreto.

Exemplos:

- AES-GCM com IV repetido;
- chave AES gravada no código;
- Diffie-Hellman sem autenticação do outro participante;
- certificado ou chave já revogada ainda aceita;
- mesma chave usada em desenvolvimento e produção;
- chave de assinatura usada por tempo indefinido;
- chave privada distribuída para componentes que não precisam dela;
- chave removida sem preservar a capacidade legítima de decifrar dados históricos;
- chave antiga usada para produzir novos dados;
- ausência de identificação da chave usada em cada registro criptografado.

### Impactos possíveis

- quebra de confidencialidade;
- alteração de mensagens;
- falsificação de identidade;
- ataque man-in-the-middle;
- repetição de operações;
- decifração de dados históricos;
- geração de tokens falsos;
- comprometimento simultâneo de vários ambientes;
- impossibilidade de rotação;
- perda definitiva de dados;
- indisponibilidade;
- dificuldade de investigação;
- comprometimento em larga escala.

---

## 4. Conceitos fundamentais

### 4.1 Chave não é senha

Uma senha é normalmente escolhida por uma pessoa e possui baixa entropia relativa.

Uma chave criptográfica deve ser:

- gerada por mecanismo criptograficamente seguro;
- adequada ao algoritmo;
- possuir tamanho correto;
- não ser escolhida manualmente;
- não ser derivada diretamente de texto previsível;
- permanecer acessível apenas a componentes autorizados.

Exemplo incorreto:

```java
byte[] keyBytes =
    "minha-chave-secreta".getBytes(StandardCharsets.UTF_8);

SecretKey key = new SecretKeySpec(keyBytes, "AES");
```

Além de previsível, o tamanho pode ser inválido ou inadequado.

### 4.2 Nonce e IV

**Nonce** significa, em essência, “número usado uma vez”.

Dependendo do protocolo ou modo criptográfico, o nonce pode servir para:

- impedir replay;
- garantir unicidade;
- participar da derivação de chave;
- separar sessões;
- produzir um resultado criptográfico diferente;
- impedir reutilização de fluxo criptográfico.

**IV — Initialization Vector** é um parâmetro usado para inicializar determinado modo de operação.

Em AES-GCM, o IV não precisa ser secreto, mas a combinação:

```text
chave + IV
```

não pode ser reutilizada.

### 4.3 Salt não é nonce

| Elemento | Finalidade típica |
|---|---|
| Salt | Tornar hashes ou derivações independentes |
| Nonce | Garantir unicidade ou impedir replay |
| IV | Inicializar modo de cifra |
| Chave | Controlar operação criptográfica |
| Token | Representar autorização, sessão ou desafio |

Os termos podem se sobrepor em determinados protocolos, mas não devem ser tratados como equivalentes automaticamente.

### 4.4 Chave de dados e chave mestra

Uma arquitetura comum utiliza:

- **DEK — Data Encryption Key:** cifra o conteúdo;
- **KEK — Key Encryption Key:** protege a DEK;
- **KMS/HSM:** protege ou executa operações com a KEK.

Essa estratégia é conhecida como **envelope encryption**.

### 4.5 Identificador de chave

Todo conteúdo criptografado ou assinado deve permitir identificar qual chave foi usada.

Exemplo de envelope:

```text
versão | keyId | algoritmo | IV | ciphertext | authenticationTag
```

O `keyId`:

- não precisa ser secreto;
- não deve conter a chave;
- permite localizar a versão correta;
- facilita rotação;
- evita tentativa cega com várias chaves;
- melhora auditoria.

---

# 5. CWE-322 — Key Exchange without Entity Authentication

## 5.1 Conceito

A aplicação realiza troca ou acordo de chaves sem confirmar a identidade da outra entidade.

O exemplo clássico é Diffie-Hellman executado sem autenticação.

O algoritmo pode produzir um segredo compartilhado entre dois participantes, mas, por si só, não garante que o participante remoto seja realmente quem afirma ser.

Um atacante no caminho pode:

1. interceptar a chave pública de A;
2. substituir pela própria chave;
3. interceptar a chave pública de B;
4. substituir novamente;
5. estabelecer um segredo com A;
6. estabelecer outro segredo com B;
7. ler ou modificar a comunicação.

Esse cenário caracteriza ataque **man-in-the-middle**.

---

## 5.2 Exemplo vulnerável: acordo de chave com entrada não autenticada

```java
public SecretKey estabelecerSegredo(
        PrivateKey minhaChavePrivada,
        byte[] chavePublicaRecebida) throws GeneralSecurityException {

    KeyFactory factory = KeyFactory.getInstance("EC");

    PublicKey chavePublicaRemota = factory.generatePublic(
        new X509EncodedKeySpec(chavePublicaRecebida)
    );

    KeyAgreement agreement = KeyAgreement.getInstance("ECDH");
    agreement.init(minhaChavePrivada);
    agreement.doPhase(chavePublicaRemota, true);

    byte[] segredo = agreement.generateSecret();

    return new SecretKeySpec(
        Arrays.copyOf(segredo, 16),
        "AES"
    );
}
```

### Problema

O código comprova apenas que recebeu uma chave pública válida do ponto de vista estrutural.

Ele não comprova:

- quem enviou a chave;
- se a chave pertence ao servidor esperado;
- se houve substituição durante o transporte;
- se o certificado é confiável;
- se a chave está vinculada à sessão atual;
- se houve downgrade;
- se a mensagem foi repetida.

---

## 5.3 Solução preferencial: usar TLS corretamente validado

Na maioria das aplicações Java, a troca de chaves não deve ser implementada manualmente.

Deve-se utilizar TLS por meio de bibliotecas e configurações maduras.

Exemplo usando truststore específico:

```java
public SSLSocketFactory criarSocketFactory(
        Path trustStorePath,
        char[] trustStorePassword)
        throws GeneralSecurityException, IOException {

    KeyStore trustStore = KeyStore.getInstance("JKS");

    try (InputStream input =
            Files.newInputStream(trustStorePath)) {

        trustStore.load(input, trustStorePassword);
    }

    TrustManagerFactory trustManagerFactory =
        TrustManagerFactory.getInstance(
            TrustManagerFactory.getDefaultAlgorithm()
        );

    trustManagerFactory.init(trustStore);

    SSLContext sslContext =
        SSLContext.getInstance("TLS");

    sslContext.init(
        null,
        trustManagerFactory.getTrustManagers(),
        new SecureRandom()
    );

    return sslContext.getSocketFactory();
}
```

Uso:

```java
URL url = new URL("https://integracao.exemplo/api/dados");

HttpsURLConnection connection =
    (HttpsURLConnection) url.openConnection();

connection.setSSLSocketFactory(
    criarSocketFactory(
        Paths.get("/opt/app/truststore.jks"),
        trustStorePassword
    )
);

// Não substituir o HostnameVerifier por implementação permissiva.
connection.connect();
```

### O que o TLS deve validar

- cadeia do certificado;
- autoridade certificadora confiável;
- hostname;
- período de validade;
- uso da chave;
- algoritmo e parâmetros aceitos;
- revogação, quando exigida pela arquitetura;
- identidade cliente, quando houver mTLS.

---

## 5.4 Exemplo vulnerável: aceitar qualquer certificado

```java
TrustManager[] trustAll = new TrustManager[] {
    new X509TrustManager() {

        @Override
        public void checkClientTrusted(
                X509Certificate[] chain,
                String authType) {
            // Não valida.
        }

        @Override
        public void checkServerTrusted(
                X509Certificate[] chain,
                String authType) {
            // Não valida.
        }

        @Override
        public X509Certificate[] getAcceptedIssuers() {
            return new X509Certificate[0];
        }
    }
};
```

Esse padrão elimina a autenticação da entidade remota.

Também é vulnerável:

```java
connection.setHostnameVerifier(
    (hostname, session) -> true
);
```

Embora lambdas sejam suportadas no Java 8, o problema aqui é lógico: qualquer hostname é aceito.

---

## 5.5 Quando existe protocolo próprio

Caso o sistema realmente precise executar acordo de chave no nível da aplicação, a chave efêmera deve ser autenticada.

Uma abordagem possível:

1. cada entidade possui identidade criptográfica previamente confiável;
2. a chave efêmera é assinada;
3. a assinatura cobre o contexto completo;
4. o certificado ou a chave de verificação é validado;
5. o segredo é derivado com uma KDF apropriada;
6. o transcript da sessão participa da derivação.

### Estrutura da mensagem

```java
public final class PeerKeyMessage {

    private final String peerId;
    private final byte[] ephemeralPublicKey;
    private final byte[] sessionNonce;
    private final byte[] signature;
    private final X509Certificate certificate;

    // Construtor e getters.
}
```

### Validação simplificada

```java
public PublicKey validarChaveEfemera(
        PeerKeyMessage message,
        Set<TrustAnchor> trustAnchors,
        Instant now)
        throws GeneralSecurityException {

    X509Certificate certificate =
        message.getCertificate();

    certificate.checkValidity(Date.from(now));

    validarCadeiaCertificado(
        certificate,
        trustAnchors,
        now
    );

    byte[] transcript = concatenar(
        message.getPeerId().getBytes(StandardCharsets.UTF_8),
        message.getEphemeralPublicKey(),
        message.getSessionNonce()
    );

    Signature verifier =
        Signature.getInstance("SHA256withRSA");

    verifier.initVerify(certificate.getPublicKey());
    verifier.update(transcript);

    if (!verifier.verify(message.getSignature())) {
        throw new SignatureException(
            "Chave efêmera sem assinatura válida"
        );
    }

    KeyFactory factory = KeyFactory.getInstance("EC");

    return factory.generatePublic(
        new X509EncodedKeySpec(
            message.getEphemeralPublicKey()
        )
    );
}
```

> Esse exemplo é didático. Protocolos criptográficos próprios são difíceis de projetar e revisar. Prefira TLS, bibliotecas maduras e padrões previamente analisados.

---

## 5.6 Sinais de alerta

- `TrustManager` que não lança exceção;
- `HostnameVerifier` que sempre retorna `true`;
- `StrictHostKeyChecking=no`;
- chave pública recebida e usada diretamente;
- Diffie-Hellman sem certificado ou assinatura;
- certificado autofirmado aceito sem pinning ou truststore controlado;
- chave de peer obtida por HTTP;
- algoritmo de troca escolhido pelo cliente sem política;
- ausência de proteção contra downgrade;
- ausência de binding entre chave, identidade e sessão.

---

## 5.7 Mitigações

- usar TLS com validação completa;
- usar mTLS quando ambos os lados precisam ser autenticados;
- utilizar truststore controlado;
- não desabilitar verificação de hostname;
- autenticar chaves efêmeras;
- vincular chave à identidade e ao contexto;
- usar bibliotecas criptográficas maduras;
- impedir downgrade;
- rejeitar certificados inválidos, expirados ou revogados;
- registrar falhas de autenticação do peer sem registrar chaves privadas ou segredos.

---

# 6. CWE-323 — Reusing a Nonce, Key Pair in Encryption

## 6.1 Conceito

A aplicação reutiliza um nonce, IV ou par de chaves em contexto que exige unicidade ou uso efêmero.

A consequência depende do protocolo.

Pode ocorrer:

- perda de confidencialidade;
- falsificação de ciphertext;
- replay;
- recuperação de informação;
- correlação entre mensagens;
- repetição de fluxo criptográfico;
- comprometimento de autenticação;
- quebra das garantias de forward secrecy.

---

## 6.2 Exemplo vulnerável: IV fixo em AES-GCM

```java
public final class VulnerableCryptoService {

    private static final byte[] FIXED_IV =
        new byte[12];

    public byte[] encrypt(
            SecretKey key,
            byte[] plaintext)
            throws GeneralSecurityException {

        Cipher cipher =
            Cipher.getInstance("AES/GCM/NoPadding");

        GCMParameterSpec parameters =
            new GCMParameterSpec(128, FIXED_IV);

        cipher.init(
            Cipher.ENCRYPT_MODE,
            key,
            parameters
        );

        return cipher.doFinal(plaintext);
    }
}
```

### Problema

Todas as mensagens usam a mesma combinação:

```text
mesma chave + mesmo IV
```

Em GCM, essa reutilização destrói garantias importantes de segurança e pode permitir análise ou falsificação de mensagens.

---

## 6.3 Solução: IV único para cada operação

```java
public final class AesGcmService {

    private static final int IV_BYTES = 12;
    private static final int TAG_BITS = 128;

    private final SecureRandom secureRandom =
        new SecureRandom();

    public EncryptedValue encrypt(
            String keyId,
            SecretKey key,
            byte[] plaintext,
            byte[] aad)
            throws GeneralSecurityException {

        byte[] iv = new byte[IV_BYTES];
        secureRandom.nextBytes(iv);

        Cipher cipher =
            Cipher.getInstance("AES/GCM/NoPadding");

        GCMParameterSpec parameters =
            new GCMParameterSpec(TAG_BITS, iv);

        cipher.init(
            Cipher.ENCRYPT_MODE,
            key,
            parameters
        );

        if (aad != null && aad.length > 0) {
            cipher.updateAAD(aad);
        }

        byte[] ciphertext =
            cipher.doFinal(plaintext);

        return new EncryptedValue(
            1,
            keyId,
            iv,
            ciphertext
        );
    }

    public byte[] decrypt(
            EncryptedValue encryptedValue,
            SecretKey key,
            byte[] aad)
            throws GeneralSecurityException {

        Cipher cipher =
            Cipher.getInstance("AES/GCM/NoPadding");

        GCMParameterSpec parameters =
            new GCMParameterSpec(
                TAG_BITS,
                encryptedValue.getIv()
            );

        cipher.init(
            Cipher.DECRYPT_MODE,
            key,
            parameters
        );

        if (aad != null && aad.length > 0) {
            cipher.updateAAD(aad);
        }

        return cipher.doFinal(
            encryptedValue.getCiphertext()
        );
    }
}
```

Objeto armazenável:

```java
public final class EncryptedValue {

    private final int version;
    private final String keyId;
    private final byte[] iv;
    private final byte[] ciphertext;

    public EncryptedValue(
            int version,
            String keyId,
            byte[] iv,
            byte[] ciphertext) {

        this.version = version;
        this.keyId = keyId;
        this.iv = Arrays.copyOf(iv, iv.length);
        this.ciphertext =
            Arrays.copyOf(ciphertext, ciphertext.length);
    }

    public int getVersion() {
        return version;
    }

    public String getKeyId() {
        return keyId;
    }

    public byte[] getIv() {
        return Arrays.copyOf(iv, iv.length);
    }

    public byte[] getCiphertext() {
        return Arrays.copyOf(
            ciphertext,
            ciphertext.length
        );
    }
}
```

O IV pode ser armazenado junto ao ciphertext. Ele não precisa ser secreto.

---

## 6.4 Erros comuns na geração de IV

### Timestamp isolado

```java
ByteBuffer buffer = ByteBuffer.allocate(12);
buffer.putLong(System.currentTimeMillis());
buffer.putInt(0);

byte[] iv = buffer.array();
```

Chamadas no mesmo milissegundo podem repetir o valor.

### Contador apenas em memória

```java
private long counter = 0;

public byte[] nextIv() {
    return ByteBuffer.allocate(12)
        .putLong(counter++)
        .putInt(0)
        .array();
}
```

Após reinício, o contador volta a zero.

### Contador por instância em cluster

Cada nó pode gerar o mesmo valor.

### `Random` em vez de `SecureRandom`

```java
new Random().nextBytes(iv);
```

`Random` não é apropriado para material criptográfico.

### IV derivado de dado previsível

```java
byte[] iv = pedidoId.toString()
    .getBytes(StandardCharsets.UTF_8);
```

A previsibilidade e a repetição podem violar o requisito do modo.

---

## 6.5 Unicidade em sistemas distribuídos

Em sistemas com várias instâncias, a aplicação deve considerar:

- volume de operações;
- número de nós;
- reinicializações;
- clonagem de VM/container;
- snapshots;
- restauração de estado;
- concorrência;
- rotação de chave;
- probabilidade de colisão;
- limite operacional do modo.

Alternativas:

- delegar a operação para KMS/HSM;
- usar envelope encryption;
- usar IV aleatório com estratégia e limites avaliados;
- usar contador persistente e particionado;
- reservar prefixo exclusivo por nó;
- rotacionar a chave antes de atingir limites;
- monitorar quantidade de usos por chave.

---

## 6.6 Reutilização de nonce em protocolo de desafio

### Exemplo vulnerável

```java
public final class ChallengeService {

    private static final String NONCE = "fixed-nonce";

    public String generateChallenge() {
        return NONCE;
    }
}
```

Um atacante pode capturar uma resposta válida e repeti-la.

### Solução

```java
public final class ChallengeService {

    private static final int NONCE_BYTES = 32;

    private final SecureRandom random =
        new SecureRandom();

    private final ChallengeRepository repository;

    public Challenge create(
            String subject,
            Duration validity) {

        byte[] value = new byte[NONCE_BYTES];
        random.nextBytes(value);

        String nonce = Base64.getUrlEncoder()
            .withoutPadding()
            .encodeToString(value);

        Challenge challenge = new Challenge(
            subject,
            hashNonce(nonce),
            Instant.now().plus(validity),
            false
        );

        repository.save(challenge);

        return challenge.withPlainNonce(nonce);
    }
}
```

No consumo:

```java
@Transactional
public void consume(
        String subject,
        String nonce) {

    byte[] hash = hashNonce(nonce);

    int updated =
        repository.consumeIfValidAndUnused(
            subject,
            hash,
            Instant.now()
        );

    if (updated != 1) {
        throw new SecurityException(
            "Nonce inválido, expirado ou reutilizado"
        );
    }
}
```

---

## 6.7 Reutilização de par de chaves efêmero

### Exemplo vulnerável

```java
public final class SessionKeyAgreement {

    private static final KeyPair SHARED_EPHEMERAL_KEY_PAIR =
        generateKeyPair();

    public KeyPair getSessionKeyPair() {
        return SHARED_EPHEMERAL_KEY_PAIR;
    }
}
```

A mesma chave supostamente efêmera é usada em todas as sessões.

### Solução

```java
public KeyPair generateSessionKeyPair()
        throws GeneralSecurityException {

    KeyPairGenerator generator =
        KeyPairGenerator.getInstance("EC");

    generator.initialize(
        new ECGenParameterSpec("secp256r1"),
        new SecureRandom()
    );

    return generator.generateKeyPair();
}
```

Ainda é necessário autenticar a chave pública, conforme a CWE-322.

---

## 6.8 AAD em AES-GCM

AAD — Additional Authenticated Data — permite autenticar metadados sem cifrá-los.

Exemplo:

```java
byte[] aad = (
    "tenant=" + tenantId
    + "|type=DOCUMENT"
    + "|version=1"
).getBytes(StandardCharsets.UTF_8);
```

Na decifragem, o mesmo AAD deve ser fornecido.

Isso pode impedir:

- mover ciphertext entre tenants;
- trocar o tipo lógico do registro;
- alterar versão;
- associar o conteúdo a outro contexto.

O AAD não substitui autorização, mas fortalece o vínculo criptográfico entre conteúdo e contexto.

---

## 6.9 Mitigações

- nunca reutilizar a mesma combinação chave/nonce quando o modo proíbe;
- usar `SecureRandom`;
- persistir IV junto ao ciphertext;
- identificar a chave por `keyId`;
- não usar timestamp isolado;
- não reiniciar contador sem trocar a chave;
- não compartilhar contador local entre clusters sem coordenação;
- usar tokens de desafio aleatórios, temporários e de uso único;
- gerar chaves efêmeras conforme o protocolo;
- monitorar volume de uso por chave;
- rotacionar antes dos limites operacionais;
- utilizar KMS/HSM em ambientes de maior criticidade.

---

# 7. CWE-324 — Use of a Key Past its Expiration Date

## 7.1 Conceito

A aplicação usa ou aceita uma chave após o término do período autorizado.

A chave pode estar:

- expirada;
- revogada;
- comprometida;
- substituída;
- desativada;
- fora da janela de validade;
- autorizada para outra finalidade;
- associada a ambiente diferente.

---

## 7.2 Exemplo vulnerável

```java
public SecretKey getKey(String keyId) {
    KeyRecord record = keyRepository.findById(keyId)
        .orElseThrow(
            () -> new SecurityException("Chave inexistente")
        );

    return record.toSecretKey();
}
```

O código ignora:

- `notBefore`;
- `expiresAt`;
- status;
- revogação;
- finalidade;
- ambiente;
- versão;
- contexto de uso.

---

## 7.3 Modelo de metadados

```java
public final class KeyMetadata {

    private final String keyId;
    private final KeyStatus status;
    private final Instant notBefore;
    private final Instant expiresAt;
    private final Set<KeyPurpose> purposes;
    private final String environment;
    private final long maxOperations;

    // Construtor e getters.
}
```

```java
public enum KeyStatus {
    PENDING,
    ACTIVE,
    RETIRED,
    REVOKED,
    DESTROYED
}
```

```java
public enum KeyPurpose {
    ENCRYPT,
    DECRYPT,
    SIGN,
    VERIFY,
    WRAP,
    UNWRAP,
    DERIVE
}
```

---

## 7.4 Validação segura

```java
public KeyHandle getKeyForUse(
        String keyId,
        KeyPurpose purpose,
        String environment,
        Instant now) {

    KeyHandle key = keyRepository.findById(keyId)
        .orElseThrow(
            () -> new SecurityException("Chave inválida")
        );

    KeyMetadata metadata = key.getMetadata();

    if (metadata.getStatus() == KeyStatus.REVOKED
            || metadata.getStatus() == KeyStatus.DESTROYED) {
        throw new SecurityException(
            "Chave revogada ou destruída"
        );
    }

    if (now.isBefore(metadata.getNotBefore())) {
        throw new SecurityException(
            "Chave ainda não ativa"
        );
    }

    if (!now.isBefore(metadata.getExpiresAt())) {
        throw new SecurityException(
            "Chave fora da validade"
        );
    }

    if (!metadata.getPurposes().contains(purpose)) {
        throw new SecurityException(
            "Finalidade de uso não autorizada"
        );
    }

    if (!environment.equals(metadata.getEnvironment())) {
        throw new SecurityException(
            "Chave pertence a outro ambiente"
        );
    }

    return key;
}
```

---

## 7.5 Expiração não significa necessariamente destruição imediata

É importante diferenciar:

- produzir novos dados;
- validar dados já produzidos;
- decifrar dados históricos;
- reter material por obrigação legal;
- arquivar;
- destruir.

Exemplo de política:

| Status | Cifrar novos dados | Decifrar dados antigos | Assinar | Verificar assinatura antiga |
|---|---:|---:|---:|---:|
| ACTIVE | Sim | Sim | Sim | Sim |
| RETIRED | Não | Sim | Não | Sim |
| REVOKED | Não | Política de incidente | Não | Normalmente não |
| DESTROYED | Não | Não | Não | Não |

Uma chave retirada pode continuar disponível exclusivamente para:

- decifrar dados antigos;
- verificar assinaturas históricas;
- migração controlada;
- cumprimento de retenção.

Ela não deve continuar sendo usada para novos dados.

---

## 7.6 Emissão e validação de tokens assinados

### Exemplo vulnerável

```java
public PrivateKey getSigningKey() {
    return keyRepository.get("jwt-key-2021")
        .getPrivateKey();
}
```

A chave é sempre usada, independentemente do estado.

### Solução

```java
public PrivateKey getCurrentSigningKey(
        Instant now) {

    return keyRepository
        .findCurrentActive(
            KeyPurpose.SIGN,
            "PRODUCTION",
            now
        )
        .orElseThrow(
            () -> new SecurityException(
                "Nenhuma chave ativa para assinatura"
            )
        )
        .getPrivateKey();
}
```

Durante validação:

```java
public PublicKey getVerificationKey(
        String keyId,
        Instant tokenIssuedAt,
        Instant now) {

    KeyHandle key = keyRepository.findById(keyId)
        .orElseThrow(
            () -> new SecurityException(
                "Identificador de chave inválido"
            )
        );

    validarUsoDeVerificacao(
        key,
        tokenIssuedAt,
        now
    );

    return key.getPublicKey();
}
```

### Regras

- o token deve conter `kid`;
- `kid` não deve ser usado para construir caminho de arquivo;
- a chave deve existir na lista autorizada;
- algoritmo recebido no token não deve substituir a política do servidor;
- chave revogada deve ser rejeitada conforme política;
- validade do token não pode ultrapassar indevidamente o período previsto para a chave.

---

## 7.7 Rotação sem indisponibilidade

Estratégia comum:

1. criar chave nova como `PENDING`;
2. distribuir ou tornar disponível;
3. ativar a nova chave;
4. passar a emitir apenas com ela;
5. manter chave anterior para leitura/verificação;
6. migrar ou aguardar expiração dos dados;
7. retirar a chave anterior;
8. arquivar ou destruir conforme política.

### Exemplo de seleção

```java
public KeyHandle getEncryptionKey(Instant now) {
    return keyRepository.findNewestActive(
        KeyPurpose.ENCRYPT,
        "PRODUCTION",
        now
    ).orElseThrow(
        () -> new IllegalStateException(
            "Nenhuma chave ativa para criptografia"
        )
    );
}
```

Para decifrar:

```java
public KeyHandle getDecryptionKey(
        String keyId,
        Instant now) {

    KeyHandle key = keyRepository.findById(keyId)
        .orElseThrow(
            () -> new SecurityException(
                "Chave de decifragem inexistente"
            )
        );

    validarChaveParaDecifragemHistorica(
        key,
        now
    );

    return key;
}
```

---

## 7.8 Recriptografia progressiva

Ao ler conteúdo cifrado com uma chave antiga:

1. decifrar com a chave indicada pelo `keyId`;
2. verificar se existe chave ativa mais recente;
3. cifrar novamente;
4. atualizar o registro de modo transacional;
5. preservar auditoria;
6. não registrar plaintext.

```java
@Transactional
public byte[] readAndUpgrade(
        EncryptedValue value,
        byte[] aad)
        throws GeneralSecurityException {

    KeyHandle oldKey =
        keyService.getDecryptionKey(
            value.getKeyId(),
            Instant.now()
        );

    byte[] plaintext = aesGcmService.decrypt(
        value,
        oldKey.getSecretKey(),
        aad
    );

    KeyHandle currentKey =
        keyService.getEncryptionKey(
            Instant.now()
        );

    if (!currentKey.getKeyId()
            .equals(value.getKeyId())) {

        EncryptedValue upgraded =
            aesGcmService.encrypt(
                currentKey.getKeyId(),
                currentKey.getSecretKey(),
                plaintext,
                aad
            );

        encryptedRepository.replace(
            value,
            upgraded
        );
    }

    return plaintext;
}
```

O chamador deve limpar o array quando não precisar mais dele.

---

## 7.9 Mitigações

- manter metadados de validade;
- distinguir ativação, retirada, revogação e destruição;
- validar finalidade;
- validar ambiente;
- usar `keyId`;
- impedir emissão com chave retirada;
- definir janela de transição;
- manter inventário;
- monitorar uso após retirada;
- realizar rotação testada;
- definir resposta a comprometimento;
- sincronizar relógios;
- não usar fallback silencioso para chave antiga;
- não apagar chave antes de avaliar dados históricos.

---

# 8. CWE-798 — Use of Hard-coded Credentials

## 8.1 Conceito

Uma credencial é incorporada diretamente ao código-fonte, bytecode, pacote, script ou artefato.

No contexto de gerenciamento de chaves, inclui:

- chave AES literal;
- chave privada embutida;
- senha de keystore no código;
- segredo de assinatura;
- token fixo;
- API key;
- senha de banco;
- chave HMAC;
- credencial de bootstrap.

A CWE-798 é Base e possui variantes mais específicas, incluindo:

- CWE-259 — Use of Hard-coded Password;
- CWE-321 — Use of Hard-coded Cryptographic Key.

---

## 8.2 Exemplo vulnerável: chave AES no código

```java
public final class VulnerableCryptoConfig {

    private static final byte[] KEY_BYTES =
        "0123456789abcdef"
            .getBytes(StandardCharsets.UTF_8);

    public static SecretKey getKey() {
        return new SecretKeySpec(
            KEY_BYTES,
            "AES"
        );
    }
}
```

### Problemas

- qualquer pessoa com acesso ao código obtém a chave;
- a chave aparece no bytecode;
- todos os ambientes podem usar o mesmo valor;
- a rotação exige nova compilação e implantação;
- uma cópia do JAR contém o segredo;
- backups e artefatos preservam a chave;
- todos os dados protegidos pela chave ficam expostos após o vazamento.

---

## 8.3 Outro exemplo vulnerável

```java
KeyStore keyStore = KeyStore.getInstance("PKCS12");

try (InputStream input =
        Files.newInputStream(
            Paths.get("/opt/app/keys.p12")
        )) {

    keyStore.load(
        input,
        "changeit".toCharArray()
    );
}
```

Mover a chave para um keystore não resolve o problema quando a senha do keystore continua hard-coded.

---

## 8.4 Solução com provedor de chaves

```java
public interface KeyProvider {

    KeyHandle getKey(
        String keyId,
        KeyPurpose purpose
    );
}
```

Implementação conceitual:

```java
public final class KmsKeyProvider
        implements KeyProvider {

    private final KmsClient kmsClient;
    private final KeyPolicyService policyService;

    public KmsKeyProvider(
            KmsClient kmsClient,
            KeyPolicyService policyService) {

        this.kmsClient = kmsClient;
        this.policyService = policyService;
    }

    @Override
    public KeyHandle getKey(
            String keyId,
            KeyPurpose purpose) {

        policyService.validateAccess(
            keyId,
            purpose
        );

        return kmsClient.getKeyHandle(
            keyId,
            purpose
        );
    }
}
```

Idealmente, a aplicação recebe um **handle** e solicita a operação ao KMS/HSM, sem exportar a chave mestra.

---

## 8.5 Solução com secret manager

Para ambientes que ainda precisam carregar uma chave simétrica:

```java
public final class SecretManagerKeyProvider
        implements KeyProvider {

    private final SecretProvider secretProvider;
    private final KeyMetadataRepository metadataRepository;

    @Override
    public KeyHandle getKey(
            String keyId,
            KeyPurpose purpose) {

        KeyMetadata metadata =
            metadataRepository.findById(keyId)
                .orElseThrow(
                    () -> new SecurityException(
                        "Chave inválida"
                    )
                );

        validar(metadata, purpose);

        byte[] encodedKey =
            secretProvider.getBinarySecret(
                metadata.getSecretReference()
            );

        try {
            SecretKey secretKey =
                new SecretKeySpec(
                    encodedKey,
                    metadata.getAlgorithm()
                );

            return new KeyHandle(
                metadata,
                secretKey
            );
        } finally {
            Arrays.fill(
                encodedKey,
                (byte) 0
            );
        }
    }
}
```

O código contém apenas uma referência:

```properties
crypto.current-key-id=customer-data-key-2026-02
```

A referência não é a chave.

---

## 8.6 Variável de ambiente

Variável de ambiente pode ser melhor que segredo no Git, mas não é automaticamente segura.

Riscos:

- painel de implantação;
- dump de processo;
- logs do pipeline;
- manifesto;
- inspeção por administrador;
- herança por subprocesso;
- exposição acidental em diagnóstico.

Exemplo:

```java
String base64Key =
    System.getenv("APP_ENCRYPTION_KEY");
```

Esse uso pode ser aceitável em determinado ambiente, desde que:

- o valor seja injetado por mecanismo protegido;
- não apareça em logs;
- haja controle de acesso;
- exista rotação;
- o processo não exponha o ambiente;
- a origem seja auditável;
- não seja compartilhado entre ambientes.

Para alto impacto, prefira KMS/HSM ou secret manager.

---

## 8.7 Chave em arquivo de configuração

```properties
crypto.key=ABEiM0RVZneImaq7zN3u/w==
```

Base64 não protege o valor.

Uma chave codificada em Base64 continua sendo uma chave hard-coded ou armazenada de forma exposta.

---

## 8.8 Testes não podem vazar para produção

Exemplo de risco:

```java
public SecretKey loadKey() {
    try {
        return keyProvider.getProductionKey();
    } catch (Exception e) {
        return new SecretKeySpec(
            "test-key-123456".getBytes(
                StandardCharsets.UTF_8
            ),
            "AES"
        );
    }
}
```

O fallback introduz uma chave padrão conhecida.

Solução:

```java
public SecretKey loadKey() {
    return keyProvider.getProductionKey();
}
```

A aplicação deve falhar de forma segura se a chave obrigatória não estiver disponível.

---

## 8.9 Segredo no histórico Git

Ao encontrar uma chave no Git:

1. considerar a chave comprometida;
2. revogar ou rotacionar;
3. investigar uso;
4. remover do código;
5. limpar histórico, quando necessário;
6. revisar forks, clones e artefatos;
7. verificar logs de pipeline;
8. implantar detecção de segredos.

Apagar a linha em novo commit não torna a chave segura novamente.

---

## 8.10 Mitigações

- usar KMS, HSM ou secret manager;
- separar ambientes;
- atribuir identidade de workload;
- usar privilégio mínimo;
- versionar chaves;
- rotacionar sem recompilação;
- auditar acesso;
- impedir exportação da chave mestra;
- remover fallback padrão;
- detectar segredo no CI/CD;
- não registrar chave;
- não incluir chave em erro;
- restringir heap dumps;
- controlar backups;
- revogar imediatamente após vazamento.

---

# 9. Arquitetura prática de serviço criptográfico

## 9.1 Interfaces

```java
public interface CryptoKeyService {

    KeyHandle currentKeyFor(
        KeyPurpose purpose,
        Instant now
    );

    KeyHandle keyByIdFor(
        String keyId,
        KeyPurpose purpose,
        Instant now
    );
}
```

```java
public interface DataCryptoService {

    EncryptedValue encrypt(
        byte[] plaintext,
        byte[] aad
    ) throws GeneralSecurityException;

    byte[] decrypt(
        EncryptedValue encryptedValue,
        byte[] aad
    ) throws GeneralSecurityException;
}
```

---

## 9.2 Implementação

```java
public final class DefaultDataCryptoService
        implements DataCryptoService {

    private final CryptoKeyService keyService;
    private final AesGcmService aesGcmService;
    private final Clock clock;

    public DefaultDataCryptoService(
            CryptoKeyService keyService,
            AesGcmService aesGcmService,
            Clock clock) {

        this.keyService = keyService;
        this.aesGcmService = aesGcmService;
        this.clock = clock;
    }

    @Override
    public EncryptedValue encrypt(
            byte[] plaintext,
            byte[] aad)
            throws GeneralSecurityException {

        KeyHandle key =
            keyService.currentKeyFor(
                KeyPurpose.ENCRYPT,
                clock.instant()
            );

        return aesGcmService.encrypt(
            key.getKeyId(),
            key.getSecretKey(),
            plaintext,
            aad
        );
    }

    @Override
    public byte[] decrypt(
            EncryptedValue encryptedValue,
            byte[] aad)
            throws GeneralSecurityException {

        KeyHandle key =
            keyService.keyByIdFor(
                encryptedValue.getKeyId(),
                KeyPurpose.DECRYPT,
                clock.instant()
            );

        return aesGcmService.decrypt(
            encryptedValue,
            key.getSecretKey(),
            aad
        );
    }
}
```

### Benefícios

- código de negócio não acessa segredo diretamente;
- política centralizada;
- rotação transparente;
- chave identificada;
- testes com `Clock`;
- validação de finalidade;
- auditoria;
- separação entre criptografia e recuperação da chave.

---

# 10. Envelope encryption

## 10.1 Fluxo de cifragem

1. solicitar uma DEK;
2. cifrar o conteúdo com a DEK;
3. proteger a DEK com KEK/KMS;
4. armazenar:
   - ciphertext;
   - IV;
   - DEK protegida;
   - `keyId` da KEK;
   - versão;
   - algoritmo;
   - metadados autenticados.

## 10.2 Estrutura

```java
public final class EnvelopeEncryptedValue {

    private final int version;
    private final String wrappingKeyId;
    private final byte[] encryptedDataKey;
    private final byte[] iv;
    private final byte[] ciphertext;

    // Construtor e getters defensivos.
}
```

## 10.3 Vantagens

- chave mestra não cifra diretamente todos os dados;
- rotação da KEK pode exigir apenas rewrap da DEK;
- menor exposição;
- separação por registro, tenant ou domínio;
- melhor controle de volume;
- integração com KMS;
- possibilidade de destruir acesso seletivamente.

---

# 11. Inventário de chaves

Um inventário deve registrar, no mínimo:

| Campo | Finalidade |
|---|---|
| `keyId` | Identificador único |
| Algoritmo | AES, RSA, EC etc. |
| Tamanho/parâmetros | Tamanho e curva |
| Finalidade | Encrypt, sign, wrap etc. |
| Proprietário | Área ou serviço responsável |
| Ambiente | Dev, homologação, produção |
| Origem | KMS, HSM, keystore |
| Criada em | Data de criação |
| Ativa em | Início de uso |
| Expira em | Fim do período autorizado |
| Status | Pending, active, retired, revoked |
| Rotacionada por | Chave sucessora |
| Último uso | Monitoramento |
| Volume de uso | Limites e rotação |
| Classificação | Sensibilidade |
| Plano de recuperação | Continuidade |
| Plano de destruição | Encerramento |

---

# 12. Auditoria segura

## 12.1 Registrar

- `keyId`;
- operação;
- identidade do serviço;
- resultado;
- data/hora;
- ambiente;
- correlation ID;
- motivo de rejeição em código padronizado;
- rotação;
- revogação;
- mudança de política;
- tentativa de usar chave expirada;
- tentativa de usar finalidade incorreta.

## 12.2 Não registrar

- chave privada;
- chave simétrica;
- segredo compartilhado;
- DEK em texto puro;
- conteúdo decifrado;
- senha de keystore;
- token de acesso;
- material derivado;
- dump completo de objeto criptográfico.

Exemplo:

```java
auditLogger.info(
    "crypto_operation operation={} keyId={} "
        + "purpose={} result={} correlationId={}",
    "ENCRYPT",
    keyId,
    "CUSTOMER_DATA",
    "SUCCESS",
    correlationId
);
```

---

# 13. Distinções importantes

## 13.1 CWE-322 versus CWE-295

| Situação | CWE provável |
|---|---:|
| Acordo de chave sem autenticar o peer | 322 |
| Certificado é validado incorretamente | 295 |
| `TrustManager` aceita tudo | 295 e pode causar 322 |
| Hostname não é verificado | 295 e pode causar 322 |

A causa raiz mais específica deve orientar o mapeamento.

## 13.2 CWE-323 versus CWE-294

| Situação | CWE provável |
|---|---:|
| Mesmo nonce usado em AES-GCM | 323 |
| Resposta autenticada pode ser repetida | 294 |
| Nonce fixo permite replay | 323 e possível 294 |
| Token de idempotência reutilizável | Pode ser 837, não necessariamente 323 |

## 13.3 CWE-324 versus CWE-298

| Situação | CWE provável |
|---|---:|
| Chave criptográfica expirada ainda usada | 324 |
| Certificado expirado é aceito | 298 |
| Chave associada a certificado vencido continua válida | Avaliar causa raiz |

## 13.4 CWE-798 versus CWE-321

- **CWE-798:** credencial hard-coded em sentido amplo;
- **CWE-321:** variante específica para chave criptográfica hard-coded.

Quando o objeto é claramente uma chave criptográfica, CWE-321 pode ser o mapeamento mais específico.

---

# 14. Checklist de revisão

## 14.1 Geração

- A chave é gerada por mecanismo criptograficamente seguro?
- O tamanho é adequado?
- O algoritmo é aprovado pela arquitetura?
- A chave é única por ambiente?
- Chaves efêmeras são realmente efêmeras?
- Nonces e IVs respeitam os requisitos do modo?

## 14.2 Armazenamento

- A chave está fora do código?
- Existe KMS, HSM ou secret manager?
- A chave mestra é exportável?
- A senha do keystore está hard-coded?
- Backups protegem o material?
- Heap dumps são controlados?
- O acesso é mínimo?

## 14.3 Distribuição

- O canal autentica a entidade remota?
- Há TLS validado?
- Existe mTLS quando necessário?
- Chaves são enviadas por e-mail ou ticket?
- A identidade do workload é verificada?
- Existe trilha de auditoria?

## 14.4 Uso

- A finalidade é validada?
- O ambiente é validado?
- O status é validado?
- A validade é verificada?
- Há limite de operações?
- O `keyId` é persistido?
- O algoritmo é definido pela política do servidor?

## 14.5 Rotação

- Existe procedimento testado?
- A emissão muda para a chave nova?
- A chave anterior fica restrita à leitura?
- Existe período de transição?
- Há recriptografia progressiva?
- É possível revogar imediatamente?
- A rotação exige recompilar?

## 14.6 Nonces e IVs

- Existe IV fixo?
- O contador reinicia?
- Vários nós compartilham a mesma sequência?
- O valor vem de `Random`?
- O valor depende apenas de timestamp?
- Há armazenamento do IV junto ao ciphertext?
- Existe monitoramento de colisão ou volume?

## 14.7 Revogação e destruição

- A revogação é propagada?
- O cache respeita mudanças?
- A aplicação possui fallback para chave antiga?
- Dados históricos foram avaliados?
- A destruição é auditada?
- Existe plano para comprometimento?

---

# 15. Comandos de busca no código

Os comandos auxiliam a triagem e podem gerar falsos positivos.

## 15.1 Chaves literais

```bash
grep -RniE \
  '(SecretKeySpec|PrivateKey|PublicKey|AES|HmacSHA|clientSecret|encryptionKey).*"' \
  src/
```

## 15.2 Base64 em configuração

```bash
grep -RniE \
  '(crypto|encryption|signing|hmac|secret|key)[._-]?[A-Za-z]*[[:space:]]*=' \
  config/ src/main/resources/
```

## 15.3 IV fixo

```bash
grep -RniE \
  'new byte\[(12|16)\]|IvParameterSpec|GCMParameterSpec' \
  src/
```

Revisar se o array é gerado novamente com `SecureRandom`.

## 15.4 Geradores inadequados

```bash
grep -RniE \
  'new Random\(|Math\.random\(' \
  src/
```

## 15.5 TLS inseguro

```bash
grep -RniE \
  'TrustAll|X509TrustManager|HostnameVerifier|StrictHostKeyChecking|return true' \
  src/ config/ scripts/
```

## 15.6 Chaves e senhas de keystore

```bash
grep -RniE \
  '(keystore|truststore|keyStore|trustStore).*(password|senha)|changeit' \
  .
```

## 15.7 Fallback inseguro

```bash
grep -RniE \
  'orElse\(".*(key|secret|admin|changeit)|catch.*\{' \
  src/
```

## 15.8 Log de material sensível

```bash
grep -RniE \
  '(log|logger)\.(trace|debug|info|warn|error).*'\
'(secret|privateKey|encryptionKey|dataKey|plaintext|token)' \
  src/
```

---

# 16. Testes sugeridos

## 16.1 CWE-322

1. Conectar com certificado válido.
2. Testar certificado de CA não confiável.
3. Testar hostname incorreto.
4. Testar certificado expirado.
5. Testar chave pública substituída.
6. Testar assinatura inválida da chave efêmera.
7. Confirmar que `TrustManager` permissivo não existe.
8. Confirmar rejeição de downgrade.
9. Testar mTLS sem certificado cliente.
10. Testar certificado cliente não autorizado.

## 16.2 CWE-323

1. Cifrar o mesmo plaintext duas vezes.
2. Confirmar IVs diferentes.
3. Confirmar ciphertexts diferentes.
4. Confirmar decifragem correta.
5. Alterar IV e confirmar falha.
6. Alterar ciphertext e confirmar falha.
7. Alterar AAD e confirmar falha.
8. Executar chamadas concorrentes.
9. Reiniciar aplicação e repetir.
10. Executar em dois nós.
11. Confirmar que nonce de desafio não pode ser reutilizado.
12. Confirmar expiração do nonce.

## 16.3 CWE-324

1. Usar chave ativa.
2. Tentar chave ainda não ativa.
3. Tentar chave expirada.
4. Tentar chave revogada.
5. Tentar finalidade incorreta.
6. Tentar chave de outro ambiente.
7. Confirmar que chave retirada não cifra novos dados.
8. Confirmar que chave retirada pode decifrar dado histórico, quando permitido.
9. Confirmar que rotação não causa indisponibilidade.
10. Confirmar auditoria de uso rejeitado.

## 16.4 CWE-798

1. Executar scanner de segredos.
2. Inspecionar JAR com `strings`.
3. Inspecionar bytecode com `javap`.
4. Buscar chaves em `.properties`.
5. Buscar senha de keystore.
6. Revisar Dockerfile e manifestos.
7. Revisar logs do pipeline.
8. Remover acesso ao secret manager e confirmar falha segura.
9. Rotacionar chave sem recompilar.
10. Confirmar separação entre ambientes.

---

# 17. Exemplos de testes unitários

## 17.1 AES-GCM deve usar IV diferente

```java
@Test
public void shouldGenerateDifferentIvForEachEncryption()
        throws Exception {

    SecretKey key = generateTestKey();

    AesGcmService service =
        new AesGcmService();

    byte[] plaintext =
        "conteudo".getBytes(StandardCharsets.UTF_8);

    EncryptedValue first = service.encrypt(
        "test-key",
        key,
        plaintext,
        null
    );

    EncryptedValue second = service.encrypt(
        "test-key",
        key,
        plaintext,
        null
    );

    assertFalse(
        Arrays.equals(
            first.getIv(),
            second.getIv()
        )
    );
}
```

## 17.2 Chave expirada deve ser rejeitada

```java
@Test(expected = SecurityException.class)
public void shouldRejectExpiredKey() {
    Instant now =
        Instant.parse("2026-07-14T12:00:00Z");

    KeyMetadata metadata = createMetadata(
        KeyStatus.ACTIVE,
        now.minus(Duration.ofDays(10)),
        now.minus(Duration.ofSeconds(1)),
        KeyPurpose.ENCRYPT,
        "PRODUCTION"
    );

    keyRepository.save(
        new KeyHandle(metadata, testSecretKey())
    );

    keyService.getKeyForUse(
        metadata.getKeyId(),
        KeyPurpose.ENCRYPT,
        "PRODUCTION",
        now
    );
}
```

## 17.3 Chave retirada não pode cifrar

```java
@Test(expected = SecurityException.class)
public void retiredKeyMustNotEncryptNewData() {
    KeyHandle retired =
        createRetiredKey(
            KeyPurpose.DECRYPT
        );

    keyService.validate(
        retired,
        KeyPurpose.ENCRYPT,
        Instant.now()
    );
}
```

## 17.4 AAD alterado deve falhar

```java
@Test(expected = AEADBadTagException.class)
public void changedAadMustFail()
        throws Exception {

    SecretKey key = generateTestKey();

    EncryptedValue encrypted =
        aesGcmService.encrypt(
            "key-1",
            key,
            "dados".getBytes(
                StandardCharsets.UTF_8
            ),
            "tenant=10".getBytes(
                StandardCharsets.UTF_8
            )
        );

    aesGcmService.decrypt(
        encrypted,
        key,
        "tenant=20".getBytes(
            StandardCharsets.UTF_8
        )
    );
}
```

---

# 18. Perguntas para revisão

1. Por que Diffie-Hellman isoladamente não autentica os participantes?
2. Qual a relação entre CWE-322 e ataque man-in-the-middle?
3. Por que um `TrustManager` permissivo elimina a proteção esperada?
4. Qual a diferença entre chave, nonce, IV e salt?
5. Por que o IV do AES-GCM pode ser público, mas não pode ser repetido com a mesma chave?
6. Por que timestamp isolado não é uma solução segura para IV?
7. Qual o risco de contador em memória após reinicialização?
8. Como um cluster pode repetir nonces?
9. Por que uma chave expirada pode continuar necessária para decifragem histórica?
10. Qual a diferença entre `RETIRED` e `REVOKED`?
11. Por que o `keyId` precisa acompanhar o ciphertext?
12. Por que um keystore com senha hard-coded continua vulnerável?
13. Por que Base64 não protege uma chave?
14. Qual a diferença entre CWE-798 e CWE-321?
15. Como envelope encryption facilita rotação?
16. O que deve ser auditado sem revelar a chave?
17. Por que não se deve usar a chave antiga como fallback?
18. Como recriptografia progressiva funciona?
19. Quando usar KMS ou HSM?
20. Por que criar protocolo criptográfico próprio é arriscado?

---

# 19. Resumo para prova

## CWE-320

Categoria de erros no gerenciamento de chaves. É uma categoria organizacional, marcada como obsoleta por sobreposição, e não deve ser usada diretamente para mapear vulnerabilidades.

## CWE-322

Acordo ou troca de chave sem autenticar a entidade remota.

Exemplo:

- Diffie-Hellman sem certificado, assinatura ou canal autenticado.

Risco principal:

- man-in-the-middle.

## CWE-323

Reutilização de nonce, IV ou par de chaves em contexto que exige valor único ou efêmero.

Exemplo:

- AES-GCM com IV fixo.

Riscos:

- quebra de confidencialidade;
- falsificação;
- replay;
- perda de garantias criptográficas.

## CWE-324

Uso de chave após expiração, revogação ou retirada.

A aplicação deve validar:

- status;
- período;
- finalidade;
- ambiente;
- política de rotação.

## CWE-798

Credencial hard-coded no código ou artefato.

Exemplos:

- chave AES literal;
- senha de keystore;
- token;
- chave HMAC;
- senha de banco.

Solução:

- KMS;
- HSM;
- secret manager;
- injeção segura;
- rotação;
- auditoria.

---

# 20. Quadro de decisão rápida

| Evidência | CWE mais provável |
|---|---:|
| ECDH usa chave pública recebida sem autenticação | 322 |
| TLS aceita qualquer certificado | 295 e possível 322 |
| AES-GCM usa IV fixo | 323 |
| Nonce de desafio é sempre igual | 323 |
| Par ECDH efêmero é estático | 323 |
| Chave vencida continua cifrando | 324 |
| Chave revogada ainda valida token | 324 |
| Certificado expirado é aceito | 298 |
| Chave AES literal no Java | 321 ou 798 |
| Senha de keystore está no código | 798 |
| Chave está em Base64 no `.properties` | 798 |
| Aplicação usa `changeit` como fallback | 798 e possível 1392 |

---

# 21. Referências

## MITRE CWE

- [CWE-320 — Key Management Errors](https://cwe.mitre.org/data/definitions/320.html)
- [CWE-322 — Key Exchange without Entity Authentication](https://cwe.mitre.org/data/definitions/322.html)
- [CWE-323 — Reusing a Nonce, Key Pair in Encryption](https://cwe.mitre.org/data/definitions/323.html)
- [CWE-324 — Use of a Key Past its Expiration Date](https://cwe.mitre.org/data/definitions/324.html)
- [CWE-798 — Use of Hard-coded Credentials](https://cwe.mitre.org/data/definitions/798.html)
- [CWE-321 — Use of Hard-coded Cryptographic Key](https://cwe.mitre.org/data/definitions/321.html)
- [CWE-295 — Improper Certificate Validation](https://cwe.mitre.org/data/definitions/295.html)
- [CWE-298 — Improper Validation of Certificate Expiration](https://cwe.mitre.org/data/definitions/298.html)

## Java

- [Java SE 8 — Cipher](https://docs.oracle.com/javase/8/docs/api/javax/crypto/Cipher.html)
- [Java SE 8 — GCMParameterSpec](https://docs.oracle.com/javase/8/docs/api/javax/crypto/spec/GCMParameterSpec.html)
- [Java SE 8 — SSLContext](https://docs.oracle.com/javase/8/docs/api/javax/net/ssl/SSLContext.html)
- [Java SE 8 — TrustManagerFactory](https://docs.oracle.com/javase/8/docs/api/javax/net/ssl/TrustManagerFactory.html)

## NIST

- [NIST Key Management Guidelines](https://csrc.nist.gov/projects/key-management/key-management-guidelines)
- [NIST SP 800-57 Part 1 Revision 5](https://csrc.nist.gov/pubs/sp/800/57/pt1/r5/final)
- [NIST SP 800-38D — GCM and GMAC](https://csrc.nist.gov/pubs/sp/800/38/d/final)

---

# 22. Conclusão

A segurança criptográfica depende tanto do gerenciamento das chaves quanto do algoritmo escolhido.

Os controles essenciais são:

- autenticar as entidades durante a troca de chaves;
- garantir unicidade de nonce e IV;
- controlar validade, finalidade e estado;
- utilizar identificadores e versões;
- rotacionar sem fallback inseguro;
- manter chaves fora do código;
- usar KMS, HSM ou secret manager;
- separar ambientes;
- restringir e auditar o acesso;
- definir tratamento para dados históricos;
- testar revogação e rotação.

A regra central é:

> Uma chave deve ser gerada, autenticada, utilizada, rotacionada, revogada e destruída de acordo com uma política explícita, sem ser incorporada ao código e sem reutilizar parâmetros criptográficos que deveriam ser únicos.
