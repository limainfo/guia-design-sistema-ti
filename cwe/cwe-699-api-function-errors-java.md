# CWE-699 — Software Development
## Category 1228 — API / Function Errors

> Material prático para revisão de prova e uso em repositório GitHub, com exemplos em Java.

## 1. Contexto

A CWE-699 — Software Development é uma *view* da CWE/MITRE organizada em torno de conceitos comuns do ciclo de desenvolvimento de software, incluindo arquitetura e implementação. A própria CWE informa que a 699 não deve ser usada diretamente para mapear vulnerabilidades reais, pois ela é uma visão de navegação, não uma fraqueza específica.

Dentro da CWE-699, a categoria CWE-1228 — API / Function Errors reúne fraquezas relacionadas ao uso incorreto de funções internas, bibliotecas ou APIs externas.

Estrutura estudada:

```text
699 - Software Development
└── 1228 - API / Function Errors
    ├── 242 - Use of Inherently Dangerous Function
    ├── 474 - Use of Function with Inconsistent Implementations
    ├── 475 - Undefined Behavior for Input to API
    ├── 477 - Use of Obsolete Function
    ├── 676 - Use of Potentially Dangerous Function
    ├── 695 - Use of Low-Level Functionality
    └── 749 - Exposed Dangerous Method or Function
```

## 2. Tabela rápida

| CWE | Nome | Ideia central | Exemplo típico em Java |
|---:|---|---|---|
| 242 | Use of Inherently Dangerous Function | Uso de API que não pode ser considerada segura para determinado contexto | `ObjectInputStream.readObject()` sobre entrada externa |
| 474 | Use of Function with Inconsistent Implementations | Uso de API cujo comportamento muda conforme ambiente, SO, versão ou charset | `getBytes()` / `new String(bytes)` sem charset explícito |
| 475 | Undefined Behavior for Input to API | API chamada com parâmetro de controle incompleto, ambíguo ou fora do contrato seguro | `Cipher.getInstance("AES")` sem modo/padding explícitos |
| 477 | Use of Obsolete Function | API obsoleta/depreciada continua em uso | `URLEncoder.encode(String)` ou `Thread.stop()` |
| 676 | Use of Potentially Dangerous Function | API pode ser segura, mas vira vulnerabilidade se usada incorretamente | `Runtime.exec()` / `ProcessBuilder` com entrada do usuário |
| 695 | Use of Low-Level Functionality | Código usa recurso baixo nível proibido pelo framework/especificação | `DriverManager`, `Socket`, `Thread` diretamente em aplicação JEE |
| 749 | Exposed Dangerous Method or Function | Método crítico exposto sem restrição adequada | Endpoint público para remover arquivo, limpar base, executar rotina administrativa |

---

# CWE-242 — Use of Inherently Dangerous Function

## Descrição prática

Ocorre quando o sistema chama uma função/API que, para aquele contexto, não pode ser garantida como segura. A CWE descreve esse caso como o uso de uma função que nunca pode ser garantida como segura. Em Java web, um exemplo comum é aceitar dados serializados de origem externa e chamar `ObjectInputStream.readObject()`.

A documentação moderna do Java alerta que desserializar dados não confiáveis é inerentemente perigoso e deve ser evitado. Quando a desserialização é inevitável, é necessário validar cuidadosamente e aplicar filtros restritivos de classes, tamanho de arrays e profundidade do grafo de objetos.

## Exemplo vulnerável

```java
public Object lerObjeto(HttpServletRequest request) throws IOException, ClassNotFoundException {
    try (ObjectInputStream ois = new ObjectInputStream(request.getInputStream())) {
        return ois.readObject();
    }
}
```

### Problema

O método aceita bytes externos e deixa a JVM reconstruir objetos arbitrários disponíveis no classpath. Em aplicações com muitas dependências, isso pode abrir caminho para execução indireta de código, abuso de métodos existentes, negação de serviço ou corrupção de estado.

## Solução preferencial

Substituir serialização Java nativa por DTOs explícitos em JSON, XML ou outro formato controlado.

```java
public DadosEntradaDTO lerEntradaSegura(HttpServletRequest request) throws IOException {
    ObjectMapper mapper = new ObjectMapper();

    DadosEntradaDTO dto = mapper.readValue(request.getInputStream(), DadosEntradaDTO.class);

    validarEntrada(dto);
    return dto;
}

private void validarEntrada(DadosEntradaDTO dto) {
    if (dto == null) {
        throw new IllegalArgumentException("Entrada obrigatória.");
    }

    if (dto.getCodigo() == null || !dto.getCodigo().matches("\\d{1,10}")) {
        throw new IllegalArgumentException("Código inválido.");
    }
}
```

## Solução quando não for possível remover imediatamente

Criar uma regra de transição:

```java
// Exemplo conceitual. Use apenas se a versão do JDK suportar ObjectInputFilter.
ObjectInputStream ois = new ObjectInputStream(inputStream);

ObjectInputFilter filtro = ObjectInputFilter.Config.createFilter(
        "com.exemplo.dto.*;java.base/*;maxdepth=5;maxarray=1000;maxbytes=1048576;!*"
);

ois.setObjectInputFilter(filtro);
Object obj = ois.readObject();
```

## Regra de revisão

Procure por:

```text
ObjectInputStream
readObject(
Serializable
```

Pergunta de revisão: “Esse dado vem de arquivo, rede, sessão, fila, cache ou integração externa?” Se sim, tratar como não confiável.

---

# CWE-474 — Use of Function with Inconsistent Implementations

## Descrição prática

Ocorre quando o código depende de uma função cujo comportamento pode variar entre sistemas operacionais, versões, configurações ou implementações. A CWE destaca que essas diferenças podem alterar a interpretação de parâmetros, códigos de retorno, disponibilidade da função ou resultado final.

Em Java, um caso comum é usar charset padrão da plataforma sem perceber. Em servidores diferentes, `String.getBytes()` e `new String(byte[])` podem produzir resultados diferentes se o charset padrão variar.

## Exemplo vulnerável

```java
public String gerarHash(String texto) throws NoSuchAlgorithmException {
    MessageDigest digest = MessageDigest.getInstance("SHA-256");

    // Vulnerável: usa charset padrão da plataforma.
    byte[] hash = digest.digest(texto.getBytes());

    return Base64.getEncoder().encodeToString(hash);
}
```

### Problema

O mesmo texto pode gerar bytes diferentes dependendo do charset padrão do ambiente. Isso pode quebrar assinatura digital, hash, token, integração com API externa ou validação de senha legada.

## Solução

Especificar charset explicitamente.

```java
public String gerarHash(String texto) throws NoSuchAlgorithmException {
    MessageDigest digest = MessageDigest.getInstance("SHA-256");

    byte[] hash = digest.digest(texto.getBytes(StandardCharsets.UTF_8));

    return Base64.getEncoder().encodeToString(hash);
}
```

## Outro exemplo vulnerável

```java
public String lerTexto(byte[] conteudo) {
    // Vulnerável: depende do charset padrão do servidor.
    return new String(conteudo);
}
```

## Correção

```java
public String lerTexto(byte[] conteudo) {
    return new String(conteudo, StandardCharsets.UTF_8);
}
```

## Regra de revisão

Procure por:

```text
.getBytes()
new String(byte[])
InputStreamReader(inputStream)
OutputStreamWriter(outputStream)
URLEncoder.encode(valor)
URLDecoder.decode(valor)
```

Pergunta de revisão: “O comportamento muda se rodar em Windows, Linux, container, servidor antigo ou JVM diferente?”

---

# CWE-475 — Undefined Behavior for Input to API

## Descrição prática

Ocorre quando uma API só tem comportamento seguro ou definido se um parâmetro de controle for informado de forma específica. A CWE descreve o caso como comportamento indefinido quando o parâmetro de controle não está no valor esperado.

Em Java, um exemplo clássico é `Cipher.getInstance("AES")`. A documentação do Java permite passar apenas o algoritmo, mas nesse caso modo e padding usam valores padrão do provider. Isso deixa o comportamento dependente da implementação e pode resultar em escolha insegura.

## Exemplo vulnerável

```java
public byte[] criptografar(byte[] dados, SecretKey chave) throws GeneralSecurityException {
    // Vulnerável: transformação incompleta.
    Cipher cipher = Cipher.getInstance("AES");
    cipher.init(Cipher.ENCRYPT_MODE, chave);
    return cipher.doFinal(dados);
}
```

### Problema

A transformação `AES` não explicita modo de operação nem padding. O provider pode aplicar defaults. Além disso, modos inadequados como ECB não protegem corretamente padrões do conteúdo.

## Solução

Definir transformação completa e parâmetros esperados.

```java
public ResultadoCriptografia criptografar(byte[] dados, SecretKey chave) throws GeneralSecurityException {
    byte[] iv = new byte[12];
    SecureRandom secureRandom = new SecureRandom();
    secureRandom.nextBytes(iv);

    Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
    GCMParameterSpec spec = new GCMParameterSpec(128, iv);

    cipher.init(Cipher.ENCRYPT_MODE, chave, spec);
    byte[] cifrado = cipher.doFinal(dados);

    return new ResultadoCriptografia(iv, cifrado);
}
```

## Exemplo com parâmetro vindo da requisição

```java
public Cipher criarCipher(HttpServletRequest request) throws GeneralSecurityException {
    String algoritmo = request.getParameter("algoritmo");

    // Vulnerável: usuário controla o parâmetro de controle da API criptográfica.
    return Cipher.getInstance(algoritmo);
}
```

## Correção com allowlist

```java
public Cipher criarCipherSeguro(String algoritmoSolicitado) throws GeneralSecurityException {
    if (!"AES_GCM".equals(algoritmoSolicitado)) {
        throw new IllegalArgumentException("Algoritmo não permitido.");
    }

    return Cipher.getInstance("AES/GCM/NoPadding");
}
```

## Regra de revisão

Procure por:

```text
Cipher.getInstance("AES")
Cipher.getInstance(variavel)
MessageDigest.getInstance(variavel)
Signature.getInstance(variavel)
SSLContext.getInstance(variavel)
```

Pergunta de revisão: “Esse parâmetro define algoritmo, modo, provider, formato, protocolo ou comportamento interno da API?”

---

# CWE-477 — Use of Obsolete Function

## Descrição prática

Ocorre quando o código usa função depreciada, obsoleta ou substituída. A CWE observa que isso sugere falta de revisão ativa do código. Nem toda API depreciada é vulnerável por si só, mas ela normalmente indica comportamento antigo, frágil, incompatível ou menos seguro.

## Exemplo vulnerável 1 — `URLEncoder.encode(String)`

```java
public String montarParametro(String nome) {
    // Deprecated: usa charset padrão da plataforma.
    return URLEncoder.encode(nome);
}
```

### Problema

A versão sem charset explícito foi depreciada porque o resultado pode variar conforme o encoding padrão da plataforma.

## Solução

```java
public String montarParametro(String nome) throws UnsupportedEncodingException {
    return URLEncoder.encode(nome, StandardCharsets.UTF_8.name());
}
```

Em Java 10+, também existe sobrecarga com `Charset`, mas em Java 8 normalmente se usa `StandardCharsets.UTF_8.name()`.

## Exemplo vulnerável 2 — `Thread.stop()`

```java
public void encerrarProcessamento(Thread thread) {
    // Deprecated e inseguro.
    thread.stop();
}
```

### Problema

`Thread.stop()` pode liberar monitores enquanto objetos estão em estado inconsistente, danificando o estado compartilhado da aplicação.

## Solução

Usar interrupção cooperativa.

```java
public class Processador implements Runnable {

    @Override
    public void run() {
        while (!Thread.currentThread().isInterrupted()) {
            executarUmaEtapa();
        }
    }

    private void executarUmaEtapa() {
        // processamento controlado
    }
}
```

Ou usar `ExecutorService`:

```java
ExecutorService executor = Executors.newSingleThreadExecutor();
Future<?> future = executor.submit(new Processador());

// Solicita cancelamento por interrupção.
future.cancel(true);
executor.shutdownNow();
```

## Regra de revisão

Procure por:

```text
@Deprecated
Thread.stop(
URLEncoder.encode(
URLDecoder.decode(
Date.getYear(
Date.getMonth(
```

Pergunta de revisão: “A documentação da API indica substituto? Existe motivo técnico para manter o método obsoleto?”

---

# CWE-676 — Use of Potentially Dangerous Function

## Descrição prática

Ocorre quando uma função pode ser usada com segurança em alguns contextos, mas se torna perigosa quando recebe entrada externa, é chamada sem validação ou ignora restrições de ambiente.

A diferença para a CWE-242 é importante: na CWE-242, a função deve ser considerada proibida. Na CWE-676, a função pode ser aceita com restrições fortes.

## Exemplo vulnerável — comando do sistema operacional

```java
public void gerarBackup(HttpServletRequest request) throws IOException {
    String nomeArquivo = request.getParameter("arquivo");

    // Vulnerável: entrada do usuário entra no comando.
    Runtime.getRuntime().exec("zip backup.zip " + nomeArquivo);
}
```

### Problema

O usuário consegue influenciar o comando executado. Dependendo do sistema operacional, shell, argumentos e permissões do processo, isso pode levar a execução indevida, leitura de arquivos ou falha operacional.

## Solução preferencial

Evitar comando externo e usar biblioteca Java.

```java
public void gerarBackup(Path arquivoOrigem, Path arquivoZip) throws IOException {
    Path diretorioPermitido = Paths.get("/var/app/documentos").toRealPath();
    Path arquivoNormalizado = arquivoOrigem.toRealPath();

    if (!arquivoNormalizado.startsWith(diretorioPermitido)) {
        throw new SecurityException("Arquivo fora do diretório permitido.");
    }

    try (ZipOutputStream zip = new ZipOutputStream(Files.newOutputStream(arquivoZip))) {
        ZipEntry entry = new ZipEntry(arquivoNormalizado.getFileName().toString());
        zip.putNextEntry(entry);
        Files.copy(arquivoNormalizado, zip);
        zip.closeEntry();
    }
}
```

## Solução quando comando externo for inevitável

```java
public void executarAntivirus(Path arquivo) throws IOException, InterruptedException {
    Path basePermitida = Paths.get("/var/app/uploads").toRealPath();
    Path arquivoValidado = arquivo.toRealPath();

    if (!arquivoValidado.startsWith(basePermitida)) {
        throw new SecurityException("Arquivo fora da área permitida.");
    }

    ProcessBuilder pb = new ProcessBuilder(
            "/usr/bin/clamscan",
            "--no-summary",
            arquivoValidado.toString()
    );

    pb.redirectErrorStream(true);

    Process processo = pb.start();
    boolean finalizou = processo.waitFor(30, TimeUnit.SECONDS);

    if (!finalizou) {
        processo.destroyForcibly();
        throw new IOException("Tempo limite excedido ao executar antivírus.");
    }

    int exitCode = processo.exitValue();
    if (exitCode != 0 && exitCode != 1) {
        throw new IOException("Falha ao executar antivírus. Código: " + exitCode);
    }
}
```

## Regra de revisão

Procure por:

```text
Runtime.getRuntime().exec
new ProcessBuilder
Class.forName
Method.invoke
ScriptEngine.eval
Statement.execute("..." + variavel)
```

Pergunta de revisão: “Essa função é perigosa porque cruza uma fronteira: sistema operacional, banco, reflexão, script, arquivo, rede ou processo externo?”

---

# CWE-695 — Use of Low-Level Functionality

## Descrição prática

Ocorre quando o código usa uma funcionalidade de baixo nível que o framework ou especificação proíbe ou desencoraja. A CWE cita que isso pode desabilitar proteções embutidas, introduzir inconsistências exploráveis ou expor funcionalidades a ataque.

Em aplicações Java EE/Jakarta EE, exemplos comuns são abrir conexão JDBC diretamente, criar sockets diretamente, criar threads manualmente ou usar I/O direto em componentes que deveriam ser gerenciados pelo container.

## Exemplo vulnerável — conexão JDBC direta na Action/Servlet

```java
public List<Usuario> listarUsuarios() throws SQLException {
    Connection conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost:5432/app",
            "app",
            "senha"
    );

    PreparedStatement ps = conn.prepareStatement("select id, nome from usuario");
    ResultSet rs = ps.executeQuery();

    List<Usuario> usuarios = new ArrayList<>();
    while (rs.next()) {
        usuarios.add(new Usuario(rs.getLong("id"), rs.getString("nome")));
    }

    return usuarios;
}
```

### Problemas

- Credencial pode ficar hardcoded.
- Pool de conexões do servidor é ignorado.
- Transação gerenciada pelo container pode ser ignorada.
- Configurações de timeout, auditoria e segurança ficam duplicadas ou ausentes.
- Fechamento incorreto causa vazamento de conexão.

## Solução

Usar `DataSource` gerenciado pelo servidor.

```java
public class UsuarioDAO {

    private final DataSource dataSource;

    public UsuarioDAO(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public List<Usuario> listarUsuarios() throws SQLException {
        String sql = "select id, nome from usuario";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            List<Usuario> usuarios = new ArrayList<>();
            while (rs.next()) {
                usuarios.add(new Usuario(rs.getLong("id"), rs.getString("nome")));
            }
            return usuarios;
        }
    }
}
```

## Exemplo vulnerável — thread manual em aplicação web

```java
public void iniciarImportacao() {
    new Thread(() -> {
        executarImportacaoPesada();
    }).start();
}
```

## Solução conceitual

Usar mecanismo gerenciado: fila, scheduler do servidor, executor configurado pela aplicação, job controlado ou serviço assíncrono com ciclo de vida conhecido.

```java
public class ImportacaoService {

    private final ExecutorService executor;

    public ImportacaoService(ExecutorService executor) {
        this.executor = executor;
    }

    public Future<?> iniciarImportacao() {
        return executor.submit(this::executarImportacaoPesada);
    }

    private void executarImportacaoPesada() {
        // rotina controlada, com log, timeout e tratamento de erro
    }
}
```

## Regra de revisão

Procure por:

```text
DriverManager.getConnection
new Socket
new ServerSocket
new Thread
System.loadLibrary
native
sun.misc.Unsafe
FileInputStream / FileOutputStream em componente gerenciado
```

Pergunta de revisão: “O framework/container já oferece uma forma segura e gerenciada de fazer isso?”

---

# CWE-749 — Exposed Dangerous Method or Function

## Descrição prática

Ocorre quando uma API, endpoint, Action, método público ou função administrativa perigosa fica acessível a atores que não deveriam executá-la. A CWE cita como mitigação reduzir superfície de ataque, listar explicitamente o que precisa ser exposto e restringir o que deve ficar disponível apenas a usuários privilegiados.

## Exemplo vulnerável — método administrativo exposto

```java
public class ManutencaoAction extends Action {

    public ActionForward removerArquivo(ActionMapping mapping,
                                        ActionForm form,
                                        HttpServletRequest request,
                                        HttpServletResponse response) throws Exception {

        String caminho = request.getParameter("caminho");

        // Vulnerável: função perigosa exposta via requisição.
        Files.delete(Paths.get(caminho));

        response.getWriter().write("Arquivo removido.");
        return null;
    }
}
```

### Problemas

- Qualquer usuário com acesso à rota pode tentar remover arquivos.
- O caminho é controlado pela requisição.
- Não há validação de autorização.
- Não há restrição de diretório.
- Não há trilha de auditoria.
- Não há confirmação de intenção ou proteção contra CSRF.

## Solução

```java
public class ManutencaoAction extends Action {

    public ActionForward removerArquivoTemporario(ActionMapping mapping,
                                                  ActionForm form,
                                                  HttpServletRequest request,
                                                  HttpServletResponse response) throws Exception {

        Usuario usuario = obterUsuarioAutenticado(request);
        validarPermissaoAdministrador(usuario);
        validarTokenCsrf(request);

        String nomeArquivo = request.getParameter("nomeArquivo");

        if (nomeArquivo == null || !nomeArquivo.matches("[a-zA-Z0-9._-]{1,100}")) {
            throw new IllegalArgumentException("Nome de arquivo inválido.");
        }

        Path base = Paths.get("/var/app/tmp").toRealPath();
        Path alvo = base.resolve(nomeArquivo).normalize().toRealPath();

        if (!alvo.startsWith(base)) {
            throw new SecurityException("Arquivo fora do diretório permitido.");
        }

        Files.deleteIfExists(alvo);
        registrarAuditoria(usuario, "REMOVEU_ARQUIVO_TEMPORARIO", alvo.getFileName().toString());

        response.getWriter().write("Arquivo temporário removido.");
        return null;
    }

    private void validarPermissaoAdministrador(Usuario usuario) {
        if (usuario == null || !usuario.isAdministrador()) {
            throw new SecurityException("Acesso negado.");
        }
    }
}
```

## Exemplo vulnerável — método público no service

```java
public class BancoService {

    public void removerBase(String nomeBase) throws SQLException {
        Statement stmt = conn.createStatement();
        stmt.execute("DROP DATABASE " + nomeBase);
    }
}
```

## Correção conceitual

```java
public class BancoService {

    private void removerBaseInterna(String nomeBase) throws SQLException {
        if (!nomeBase.matches("[a-zA-Z0-9_]{1,30}")) {
            throw new IllegalArgumentException("Nome de base inválido.");
        }

        Statement stmt = conn.createStatement();
        stmt.execute("DROP DATABASE " + nomeBase);
    }

    public void executarManutencaoControlada(Usuario usuario, String nomeBase) throws SQLException {
        if (!usuario.isAdministrador()) {
            throw new SecurityException("Acesso negado.");
        }

        removerBaseInterna(nomeBase);
    }
}
```

## Regra de revisão

Procure por métodos públicos com nomes como:

```text
remover
excluir
deletar
limpar
resetar
reprocessar
executar
migrar
cancelar
alterarStatus
baixarArquivo
uploadArquivo
```

Pergunta de revisão: “Esse método deveria estar disponível para qualquer usuário, qualquer tela, qualquer Action ou qualquer integração?”

---

# Checklist geral de revisão

## 1. APIs proibidas ou perigosas

- Existe lista de APIs proibidas no projeto?
- O build/Sonar/Checkstyle/grep detecta uso dessas APIs?
- Existe alternativa segura documentada?

## 2. Entrada externa

- A API recebe valor de request, arquivo, banco, fila, sessão, cookie, header ou integração?
- Existe allowlist?
- Existe limite de tamanho?
- Existe validação de formato?

## 3. Ambiente

- O código depende de charset padrão?
- Depende de separador de arquivo?
- Depende de provider criptográfico?
- Depende de comportamento específico do Windows/Linux?

## 4. APIs depreciadas

- Há uso de `@Deprecated`?
- A documentação informa substituto?
- O uso é legado justificado ou apenas falta de revisão?

## 5. Superfície exposta

- Método perigoso está público?
- Endpoint administrativo exige autenticação e autorização?
- Existe CSRF quando há alteração de estado?
- Existe auditoria?
- A função deveria ser privada, interna ou acessível somente por job controlado?

---

# Comandos úteis para busca no código

```bash
grep -R "ObjectInputStream\|readObject" src/
grep -R "Runtime.getRuntime().exec\|ProcessBuilder" src/
grep -R "getBytes()\|new String(.*byte" src/
grep -R "Cipher.getInstance(\"AES\"\|Cipher.getInstance(.*request" src/
grep -R "Thread.stop\|URLEncoder.encode" src/
grep -R "DriverManager.getConnection\|new Thread\|new Socket" src/
grep -R "public .*remover\|public .*excluir\|public .*limpar\|public .*executar" src/
```

# Resumo para prova

- **CWE-242**: função deve ser evitada/proibida; exemplo: desserialização Java de entrada externa.
- **CWE-474**: função muda de comportamento conforme ambiente; exemplo: charset padrão.
- **CWE-475**: parâmetro de controle incompleto ou ambíguo; exemplo: `Cipher.getInstance("AES")`.
- **CWE-477**: função obsoleta/depreciada; exemplo: `URLEncoder.encode(String)` e `Thread.stop()`.
- **CWE-676**: função perigosa se usada incorretamente; exemplo: `Runtime.exec()` com entrada externa.
- **CWE-695**: uso de baixo nível contra o modelo do framework; exemplo: `DriverManager`, `Thread`, `Socket` diretamente.
- **CWE-749**: método perigoso exposto; exemplo: endpoint administrativo sem autorização forte.

# Fontes consultadas

- MITRE CWE-699 — https://cwe.mitre.org/data/definitions/699.html
- MITRE CWE-242 — https://cwe.mitre.org/data/definitions/242.html
- MITRE CWE-474 — https://cwe.mitre.org/data/definitions/474.html
- MITRE CWE-475 — https://cwe.mitre.org/data/definitions/475.html
- MITRE CWE-477 — https://cwe.mitre.org/data/definitions/477.html
- MITRE CWE-676 — https://cwe.mitre.org/data/definitions/676.html
- MITRE CWE-695 — https://cwe.mitre.org/data/definitions/695.html
- MITRE CWE-749 — https://cwe.mitre.org/data/definitions/749.html
- Oracle Java ObjectInputFilter — https://docs.oracle.com/en/java/javase/24/docs/api/java.base/java/io/ObjectInputFilter.html
- Oracle Java SE 8 String — https://docs.oracle.com/javase/8/docs/api/java/lang/String.html
- Oracle Java SE 8 StandardCharsets — https://docs.oracle.com/javase/8/docs/api/java/nio/charset/StandardCharsets.html
- Oracle Java SE 8 Cipher — https://docs.oracle.com/javase/8/docs/api/javax/crypto/Cipher.html
- Oracle Java SE 8 URLEncoder — https://docs.oracle.com/javase/8/docs/api/java/net/URLEncoder.html
- Oracle Thread Primitive Deprecation — https://docs.oracle.com/javase/8/docs/technotes/guides/concurrency/threadPrimitiveDeprecation.html
- Oracle Java SE 8 ProcessBuilder — https://docs.oracle.com/javase/8/docs/api/java/lang/ProcessBuilder.html
