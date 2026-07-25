# CWE-699 — Software Development

## Category: Data Neutralization Issues — CWE-137

> **Objetivo:** documentação prática sobre falhas de neutralização de dados, com exemplos vulneráveis e corrigidos em **Java 8**, aplicáveis a sistemas web, APIs REST, Struts/Servlet/JSP, JDBC/Hibernate, LDAP, XML, logs, CSV, arquivos, comandos do sistema e Expression Language.

---

## 1. Visão geral

A categoria **CWE-137 — Data Neutralization Issues** agrupa fraquezas em que dados externos entram em um contexto que possui sintaxe própria, mas a aplicação não neutraliza corretamente caracteres, delimitadores, sequências ou elementos especiais.

Em termos práticos, o sistema recebe um valor como dado comum, mas o envia para algum interpretador que pode tratar parte desse valor como instrução.

Exemplos de contextos sensíveis:

- shell do sistema operacional;
- SQL/HQL/JPQL;
- HTML, atributo HTML e JavaScript;
- LDAP;
- XPath/XML;
- CSV aberto em planilha;
- logs;
- cabeçalhos HTTP;
- Expression Language;
- nomes de arquivo e recursos;
- formatos delimitados por `,`, `;`, `|`, `:` ou quebra de linha.

A regra geral é: **não existe escape universal**. Cada contexto exige uma forma própria de validação, parametrização ou codificação.

---

## 2. Natureza da categoria

A **CWE-137** é uma **Category**. Ela serve para organizar fraquezas relacionadas à neutralização de dados, mas não deve ser usada diretamente para mapear uma vulnerabilidade real quando houver uma CWE Base mais específica.

Exemplos de mapeamento mais específico:

| Situação | CWE mais adequada |
|---|---:|
| Comando do SO montado com entrada externa | 78 |
| Conteúdo do usuário refletido em HTML sem escape | 79 |
| SQL concatenado com parâmetro | 89 |
| Filtro LDAP concatenado | 90 |
| XPath montado por concatenação | 91 |
| Quebra de linha injetada em header/log | 93 ou 117 |
| Campo CSV começa com fórmula | 1236 |

---

## 3. CWEs abordadas

| CWE | Nome | Exemplo prático |
|---:|---|---|
| 76 | Improper Neutralization of Equivalent Special Elements | Bloqueia `/`, mas aceita `\`, Unicode, URL encoded ou forma equivalente |
| 78 | OS Command Injection | Comando do SO montado com entrada externa |
| 79 | Cross-site Scripting | Saída HTML/JS sem escape contextual |
| 88 | Argument Injection | Argumento malicioso altera comportamento do comando |
| 89 | SQL Injection | SQL concatenado com entrada externa |
| 90 | LDAP Injection | Filtro LDAP concatenado |
| 91 | XML/XPath Injection | XML ou XPath montado com entrada externa |
| 93 | CRLF Injection | `\r\n` injeta cabeçalhos, logs ou linhas |
| 94 | Code Injection | Código gerado ou avaliado com entrada externa |
| 117 | Log Injection | Quebra de linha ou controle em logs |
| 140 | Improper Neutralization of Delimiters | Separadores como `,`, `|`, `;`, `:` tratados incorretamente |
| 170 | Improper Null Termination | Byte nulo ou terminador tratado de forma incompatível |
| 463 | Deletion of Data Structure Sentinel | Sentinela removido e estrutura perde limite |
| 464 | Addition of Data Structure Sentinel | Sentinela adicionado e estrutura termina cedo |
| 641 | Improper Restriction of Names for Files and Other Resources | Nome de arquivo/recurso permite caminhos perigosos |
| 694 | Use of Multiple Resources with Duplicate Identifier | Identificador duplicado causa ambiguidade |
| 791 | Incomplete Filtering of Special Elements | Filtro remove alguns caracteres, mas deixa equivalentes |
| 838 | Inappropriate Encoding for Output Context | Escape errado para HTML, atributo, JS, URL, SQL etc. |
| 917 | Expression Language Injection | EL avalia expressão controlada pelo usuário |
| 1236 | CSV Formula Injection | Campo CSV começa com `=`, `+`, `-`, `@` e vira fórmula |

---

## 4. Princípios práticos

### 4.1 Preferir separação estrutural

Sempre que possível, use APIs que separam instrução e dado:

- `PreparedStatement` para SQL;
- parâmetros nomeados em HQL/JPQL;
- `ProcessBuilder` com lista de argumentos;
- serialização JSON em vez de concatenar JavaScript;
- escape contextual no ponto de saída;
- parser/builder de XML em vez de concatenação;
- allowlist para nomes de arquivo, colunas e operações;
- diretório base + `normalize()`/`toRealPath()` para arquivos.

### 4.2 Blacklist é frágil

Exemplo ruim:

```java
input = input.replace("'", "");
input = input.replace(";", "");
input = input.replace("<script>", "");
```

Problemas:

- ignora variações por encoding;
- ignora formas Unicode equivalentes;
- ignora contexto;
- corrompe dado legítimo;
- cria falsa sensação de segurança.

### 4.3 Encode no contexto de saída

O mesmo valor exige tratamentos diferentes:

| Contexto | Defesa típica |
|---|---|
| SQL | parâmetro SQL |
| HTML body | HTML escape |
| HTML attribute | escape de atributo |
| JavaScript | serialização JSON |
| URL parameter | URL encoding do componente |
| Shell | evitar shell; argumentos separados |
| LDAP | escape LDAP |
| XPath | não concatenar; usar API/variáveis |
| Log | neutralizar CR/LF e controles |
| CSV | quote CSV + neutralização de fórmula |

---

# 5. CWE-76 — Improper Neutralization of Equivalent Special Elements

## Conceito

A aplicação neutraliza uma forma de elemento especial, mas ignora formas equivalentes.

Exemplos:

- bloqueia `../`, mas aceita `%2e%2e%2f`;
- bloqueia `/`, mas aceita `\`;
- bloqueia `<script>`, mas aceita variações de case/encoding;
- remove aspas simples, mas aceita caracteres Unicode equivalentes;
- valida antes de decodificar.

## Vulnerável

```java
public String limparPath(String nome) {
    return nome.replace("../", "");
}
```

Entradas problemáticas:

```text
..\segredo.txt
%2e%2e%2fsegredo.txt
....//segredo.txt
..%252fsegredo.txt
```

## Solução

Resolver o caminho dentro de uma base real e usar allowlist para nome simples.

```java
public Path resolverArquivoSeguro(Path diretorioBase, String nomeArquivo)
        throws IOException {

    if (nomeArquivo == null || nomeArquivo.trim().isEmpty()) {
        throw new IllegalArgumentException("Nome obrigatório");
    }

    String normalizado = Normalizer.normalize(nomeArquivo, Normalizer.Form.NFC);

    if (!normalizado.matches("[A-Za-z0-9._-]{1,100}")) {
        throw new IllegalArgumentException("Nome inválido");
    }

    Path baseReal = diretorioBase.toRealPath();
    Path destino = baseReal.resolve(normalizado).normalize();

    if (!destino.startsWith(baseReal)) {
        throw new SecurityException("Arquivo fora do diretório permitido");
    }

    return destino;
}
```

## Revisão

Perguntas úteis:

- a validação acontece antes ou depois da decodificação/canonicalização?
- existem formas equivalentes para o mesmo caractere?
- Windows e Linux interpretam separadores de forma diferente?
- o valor validado é exatamente o valor usado?

---

# 6. CWE-78 — OS Command Injection

## Conceito

A aplicação constrói comando do sistema operacional com entrada externa.

## Vulnerável

```java
public void compactar(String nomeArquivo) throws IOException {
    String comando = "tar -czf backup.tar.gz " + nomeArquivo;
    Runtime.getRuntime().exec(comando);
}
```

Entrada maliciosa:

```text
dados.txt; rm -rf /tmp/app
```

## Solução preferencial: usar API Java

```java
public void copiarArquivo(Path origem, Path destino) throws IOException {
    Files.copy(origem, destino, StandardCopyOption.REPLACE_EXISTING);
}
```

## Solução quando comando externo é inevitável

```java
public final class SafeCommandRunner {

    private static final Set<String> FORMATOS = new HashSet<String>(
        Arrays.asList("pdf", "txt", "csv")
    );

    public void converter(Path input, Path output, String formato)
            throws IOException, InterruptedException {

        if (!FORMATOS.contains(formato)) {
            throw new IllegalArgumentException("Formato não permitido");
        }

        Path inputReal = input.toRealPath();
        Path outputParent = output.getParent().toRealPath();

        ProcessBuilder builder = new ProcessBuilder(
            "/usr/local/bin/conversor",
            "--input", inputReal.toString(),
            "--output", output.toString(),
            "--format", formato
        );

        builder.directory(outputParent.toFile());
        builder.redirectErrorStream(true);

        Process process = builder.start();
        int exit = process.waitFor();

        if (exit != 0) {
            throw new IOException("Falha ao executar conversor");
        }
    }
}
```

## Regras

- evitar `sh -c` e `cmd.exe /c`;
- usar caminho absoluto do executável;
- aplicar allowlist de operação;
- validar arquivos dentro de diretório base;
- limitar tempo de execução;
- executar com usuário de baixo privilégio;
- não passar senha por argumento de processo.

---

# 7. CWE-79 — Cross-site Scripting

## Conceito

A aplicação inclui entrada externa em página web sem neutralizar corretamente para o contexto HTML/JavaScript.

## Vulnerável em JSP

```jsp
<p>Bem-vindo, <%= request.getParameter("nome") %></p>
```

Entrada:

```html
<script>alert(document.cookie)</script>
```

## Solução com JSTL

```jsp
<p>Bem-vindo, <c:out value="${param.nome}" /></p>
```

## Vulnerável em atributo

```jsp
<input value="${param.nome}">
```

## Solução

```jsp
<input value="<c:out value='${param.nome}' />">
```

## Vulnerável em JavaScript

```jsp
<script>
var nome = '${param.nome}';
</script>
```

## Solução

Gerar JSON no servidor:

```java
String dadosJsonSeguro = objectMapper.writeValueAsString(dto);
```

E inserir como objeto JSON, não como concatenação de string.

## Regras

- escapar no ponto de saída;
- usar escape contextual;
- não montar HTML/JS por concatenação;
- sanitizar HTML rico com biblioteca própria quando HTML for requisito;
- usar CSP como defesa adicional, não única.

---

# 8. CWE-88 — Argument Injection

## Conceito

Mesmo sem injetar novo comando, o atacante altera argumentos ou opções de um comando.

## Vulnerável

```java
public void listar(String diretorio) throws IOException {
    new ProcessBuilder("ls", diretorio).start();
}
```

Entrada:

```text
--recursive
```

O valor vira opção do comando.

## Solução

Usar `--` quando suportado e validar o argumento.

```java
public void listarArquivo(Path base, String nome) throws IOException {
    Path arquivo = resolverArquivoSeguro(base, nome);

    new ProcessBuilder(
        "/bin/ls",
        "--",
        arquivo.toString()
    ).start();
}
```

## Diferença para CWE-78

| Situação | CWE |
|---|---:|
| Entrada executa novo comando | 78 |
| Entrada altera argumento/opção | 88 |
| `ProcessBuilder` evita shell, mas aceita opção perigosa | 88 |

---

# 9. CWE-89 — SQL Injection

## Conceito

Entrada externa altera a estrutura de um comando SQL.

## Vulnerável

```java
public Usuario buscarPorLogin(String login) throws SQLException {
    String sql =
        "SELECT id, login, perfil "
      + "FROM usuario "
      + "WHERE login = '" + login + "'";

    try (Connection connection = dataSource.getConnection();
         Statement statement = connection.createStatement();
         ResultSet rs = statement.executeQuery(sql)) {

        if (!rs.next()) {
            return null;
        }

        return mapUsuario(rs);
    }
}
```

Entrada:

```text
admin' OR '1'='1
```

## Solução com PreparedStatement

```java
public Usuario buscarPorLogin(String login) throws SQLException {
    String sql =
        "SELECT id, login, perfil "
      + "FROM usuario "
      + "WHERE login = ?";

    try (Connection connection = dataSource.getConnection();
         PreparedStatement ps = connection.prepareStatement(sql)) {

        ps.setString(1, login);

        try (ResultSet rs = ps.executeQuery()) {
            if (!rs.next()) {
                return null;
            }

            return mapUsuario(rs);
        }
    }
}
```

## ORDER BY não é parâmetro SQL

Vulnerável:

```java
String sql = "SELECT * FROM funcionario ORDER BY "
    + request.getParameter("ordenarPor");
```

Solução com allowlist:

```java
private static final Map<String, String> ORDER_COLUMNS = new HashMap<String, String>();

static {
    ORDER_COLUMNS.put("nome", "p.nome");
    ORDER_COLUMNS.put("matricula", "f.matricula");
    ORDER_COLUMNS.put("unidade", "u.nome");
}

public String resolverOrdenacao(String campo) {
    String coluna = ORDER_COLUMNS.get(campo);
    return coluna == null ? "p.nome" : coluna;
}
```

## HQL/JPQL

Vulnerável:

```java
String hql = "from Usuario u where u.login = '" + login + "'";
```

Seguro:

```java
Query query = session.createQuery(
    "from Usuario u where u.login = :login"
);
query.setParameter("login", login);
```

---

# 10. CWE-90 — LDAP Injection

## Conceito

Entrada externa altera filtro LDAP.

## Vulnerável

```java
public NamingEnumeration<SearchResult> buscarUsuario(DirContext context, String uid)
        throws NamingException {

    String filter = "(uid=" + uid + ")";

    return context.search(
        "ou=users,dc=empresa,dc=com",
        filter,
        new SearchControls()
    );
}
```

Entrada:

```text
*)(|(uid=*))
```

## Solução com escape LDAP

```java
public String escapeLdapFilter(String value) {
    if (value == null) {
        return "";
    }

    StringBuilder builder = new StringBuilder();

    for (int i = 0; i < value.length(); i++) {
        char c = value.charAt(i);

        switch (c) {
            case '\\': builder.append("\\5c"); break;
            case '*':  builder.append("\\2a"); break;
            case '(':  builder.append("\\28"); break;
            case ')':  builder.append("\\29"); break;
            case '\u0000': builder.append("\\00"); break;
            default: builder.append(c);
        }
    }

    return builder.toString();
}
```

Uso:

```java
String filter = "(uid=" + escapeLdapFilter(uid) + ")";
```

---

# 11. CWE-91 — XML Injection / Blind XPath Injection

## Conceito

A aplicação monta XML ou XPath com entrada externa.

## XPath vulnerável

```java
String expression =
    "/usuarios/usuario[login='" + login
    + "' and senha='" + senha + "']";

Node node = (Node) xpath.evaluate(
    expression,
    document,
    XPathConstants.NODE
);
```

Entrada:

```text
' or '1'='1
```

## Solução

Não usar XPath concatenado para autenticação. Buscar nós e comparar valores como dados.

```java
NodeList usuarios = (NodeList) xpath.evaluate(
    "/usuarios/usuario",
    document,
    XPathConstants.NODESET
);

for (int i = 0; i < usuarios.getLength(); i++) {
    Element usuario = (Element) usuarios.item(i);
    String loginXml = textOf(usuario, "login");

    if (login.equals(loginXml)) {
        return usuario;
    }
}

return null;
```

## XML vulnerável

```java
String xml = "<usuario><nome>" + nome + "</nome></usuario>";
```

Entrada:

```xml
</nome><admin>true</admin><nome>
```

## Solução com DOM

```java
Document document = DocumentBuilderFactory
    .newInstance()
    .newDocumentBuilder()
    .newDocument();

Element usuario = document.createElement("usuario");
Element nomeElement = document.createElement("nome");

nomeElement.appendChild(document.createTextNode(nome));
usuario.appendChild(nomeElement);
document.appendChild(usuario);
```

---

# 12. CWE-93 — CRLF Injection

## Conceito

Entrada com `\r` ou `\n` é usada em contexto no qual quebra de linha tem significado especial.

## Vulnerável

```java
String fileName = request.getParameter("fileName");

response.setHeader(
    "Content-Disposition",
    "attachment; filename=" + fileName
);
```

Entrada:

```text
relatorio.pdf\r\nX-Injected-Header: true
```

## Solução

```java
public String safeHeaderFileName(String value) {
    if (value == null) {
        return "arquivo.bin";
    }

    String normalized = Normalizer.normalize(value, Normalizer.Form.NFC);

    if (!normalized.matches("[A-Za-z0-9._-]{1,100}")) {
        return "arquivo.bin";
    }

    return normalized;
}
```

Uso:

```java
response.setHeader(
    "Content-Disposition",
    "attachment; filename=\"" + safeHeaderFileName(fileName) + "\""
);
```

---

# 13. CWE-94 — Code Injection

## Conceito

Entrada externa participa da geração ou execução de código.

## Vulnerável com ScriptEngine

```java
public Object calcular(String expressao) throws ScriptException {
    ScriptEngine engine = new ScriptEngineManager().getEngineByName("JavaScript");
    return engine.eval(expressao);
}
```

Entrada:

```javascript
java.lang.Runtime.getRuntime().exec("calc")
```

## Solução

Usar operações explicitamente permitidas.

```java
public BigDecimal calcular(BigDecimal a, BigDecimal b, String operacao) {
    if ("SOMA".equals(operacao)) {
        return a.add(b);
    }

    if ("SUBTRACAO".equals(operacao)) {
        return a.subtract(b);
    }

    if ("MULTIPLICACAO".equals(operacao)) {
        return a.multiply(b);
    }

    throw new IllegalArgumentException("Operação não permitida");
}
```

## Regras

- não usar `eval` com entrada externa;
- não compilar código fornecido pelo usuário;
- não executar método vindo do request via reflection;
- usar allowlist;
- isolar processo se execução dinâmica for requisito.

---

# 14. CWE-117 — Improper Output Neutralization for Logs

## Conceito

Dados externos são escritos em logs sem neutralização.

## Vulnerável

```java
log.info("Falha de login para usuario=" + usuario);
```

Entrada:

```text
evaldo\nINFO Login bem-sucedido para admin
```

## Solução

```java
public final class LogSanitizer {

    private LogSanitizer() {
    }

    public static String clean(String value) {
        if (value == null) {
            return "";
        }

        StringBuilder builder = new StringBuilder();

        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);

            if (c == '\r') {
                builder.append("\\r");
            } else if (c == '\n') {
                builder.append("\\n");
            } else if (Character.isISOControl(c)) {
                builder.append('?');
            } else {
                builder.append(c);
            }
        }

        return builder.toString();
    }
}
```

Uso:

```java
log.warn(
    "Falha de login. usuario={} ip={}",
    LogSanitizer.clean(usuario),
    LogSanitizer.clean(ip)
);
```

---

# 15. CWE-140 — Improper Neutralization of Delimiters

## Conceito

A aplicação usa delimitadores em formato textual sem escapá-los corretamente.

## Vulnerável

```java
public String exportarLinha(String nome, String perfil) {
    return nome + "|" + perfil;
}
```

Entrada:

```text
João|ADMIN
```

## Solução

```java
public String exportarCampoPipe(String value) {
    if (value == null) {
        return "";
    }

    return value
        .replace("\\", "\\\\")
        .replace("|", "\\|")
        .replace("\r", "\\r")
        .replace("\n", "\\n");
}
```

Uso:

```java
return exportarCampoPipe(nome) + "|" + exportarCampoPipe(perfil);
```

Para CSV, prefira biblioteca CSV madura.

---

# 16. CWE-170 — Improper Null Termination

## Conceito

Java não usa string terminada por NUL como C, mas o problema aparece em integrações nativas, bibliotecas antigas, APIs de sistema ou formatos que interpretam `\0` como terminador.

## Vulnerável

```java
public void salvarNomeArquivo(String nome) {
    arquivoNativo.salvar(nome);
}
```

Entrada:

```text
relatorio.pdf\0.exe
```

Uma camada pode enxergar `relatorio.pdf`; outra, `relatorio.pdf\0.exe`.

## Solução

```java
public String validarSemNulo(String value) {
    if (value == null) {
        throw new IllegalArgumentException("Valor obrigatório");
    }

    if (value.indexOf('\0') >= 0) {
        throw new IllegalArgumentException("Caractere nulo não permitido");
    }

    return value;
}
```

---

# 17. CWE-463 — Deletion of Data Structure Sentinel

## Conceito

Um sentinela é um valor especial que marca limite, fim ou separação de estrutura. A falha ocorre quando ele é removido indevidamente.

## Vulnerável

```java
public String limpar(String value) {
    return value.replace("FIM", "");
}
```

Se `FIM` marca o fim do registro, a estrutura perde o limite.

## Solução

Usar parser e validar o formato.

```java
public Registro parseRegistro(String value) {
    String[] parts = value.split("\\|", -1);

    if (parts.length != 3) {
        throw new IllegalArgumentException("Registro inválido");
    }

    if (!"FIM".equals(parts[2])) {
        throw new IllegalArgumentException("Sentinela ausente");
    }

    return new Registro(parts[0], parts[1]);
}
```

---

# 18. CWE-464 — Addition of Data Structure Sentinel

## Conceito

A entrada adiciona um sentinela inesperado, encerrando a estrutura cedo ou alterando sua interpretação.

## Vulnerável

```java
public String criarRegistro(String usuario, String perfil) {
    return usuario + "|" + perfil + "|FIM";
}
```

Entrada:

```text
usuario = joao|ADMIN|FIM|ignorado
```

## Solução

Rejeitar delimitadores e sentinelas em campos simples.

```java
public void validarCampoSemSentinela(String value) {
    if (value == null || value.contains("|") || value.contains("FIM")) {
        throw new IllegalArgumentException("Campo inválido");
    }
}
```

Melhor ainda: usar formato estruturado produzido por biblioteca e assinado quando houver decisão de segurança.

---

# 19. CWE-641 — Improper Restriction of Names for Files and Other Resources

## Conceito

A aplicação aceita nomes perigosos para arquivos, diretórios, tópicos, filas, chaves, buckets ou outros recursos.

## Vulnerável

```java
public Path arquivoDoUsuario(String nome) {
    return Paths.get("/dados/upload/" + nome);
}
```

Entrada:

```text
../../etc/passwd
```

## Solução

Preferir nome gerado pelo servidor.

```java
public String gerarNomeSeguro(String extensao) {
    if (!Arrays.asList("pdf", "png", "jpg").contains(extensao)) {
        throw new IllegalArgumentException("Extensão não permitida");
    }

    return UUID.randomUUID().toString() + "." + extensao;
}
```

Preservar nome original apenas como metadado de exibição.

```java
public String normalizarNomeExibicao(String nome) {
    if (nome == null) {
        return "arquivo";
    }

    String normalizado = Normalizer.normalize(nome, Normalizer.Form.NFC);

    return normalizado
        .replaceAll("[\\r\\n\\t]", "_")
        .replaceAll("[^A-Za-z0-9._ -]", "_")
        .trim();
}
```

---

# 20. CWE-694 — Use of Multiple Resources with Duplicate Identifier

## Conceito

Recursos diferentes usam identificador duplicado ou equivalente, gerando ambiguidade.

Exemplos:

- `Admin` e `admin`;
- dois arquivos equivalentes após normalização Unicode;
- plugins com mesmo nome;
- dois recursos com mesmo ID em tenants diferentes;
- chaves duplicadas em JSON.

## Vulnerável

```java
public void salvarArquivo(String nome, byte[] conteudo) throws IOException {
    Path path = uploadDir.resolve(nome.toLowerCase(Locale.ROOT));
    Files.write(path, conteudo);
}
```

`Relatorio.pdf` e `relatorio.pdf` colidem.

## Solução

Separar identificador interno e nome externo.

```java
public Arquivo salvarArquivo(String nomeOriginal, byte[] conteudo)
        throws IOException {

    String id = UUID.randomUUID().toString();
    String nomeSeguro = normalizarNomeExibicao(nomeOriginal);
    Path path = uploadDir.resolve(id + ".bin");

    Files.write(path, conteudo);

    return new Arquivo(id, nomeSeguro, path.toString());
}
```

Também usar constraints únicas no banco para identificadores normalizados quando a regra exigir unicidade.

---

# 21. CWE-791 — Incomplete Filtering of Special Elements

## Conceito

A aplicação tenta filtrar caracteres especiais, mas o filtro é incompleto.

## Vulnerável

```java
public String limparSql(String input) {
    return input.replace("'", "");
}
```

Isso não cobre comentários, encoding, contexto numérico, operadores, funções, concatenação e diferenças entre bancos.

## Solução

Trocar filtro por API segura.

SQL:

```java
String sql = "SELECT * FROM usuario WHERE login = ?";
PreparedStatement ps = connection.prepareStatement(sql);
ps.setString(1, login);
```

HTML:

```jsp
<c:out value="${valor}" />
```

Comando:

```java
new ProcessBuilder("/usr/bin/programa", "--", argumentoValidado);
```

## Regra

Se a defesa principal é “remover caracteres perigosos”, há forte indício de CWE-791.

---

# 22. CWE-838 — Inappropriate Encoding for Output Context

## Conceito

A aplicação usa um escape adequado para um contexto, mas o valor é inserido em outro.

## Vulnerável

```java
String htmlEscapado = escapeHtml(nome);
String script = "var nome = '" + htmlEscapado + "';";
```

Escape HTML não protege corretamente contexto JavaScript.

## Solução

Escolher encoding conforme o contexto.

| Contexto | Defesa |
|---|---|
| HTML body | HTML escape |
| HTML attribute | attribute escape |
| JavaScript | serialização JSON |
| URL parameter | `URLEncoder.encode` do componente |
| SQL | parâmetro SQL |
| Shell | argumentos separados |
| Log | neutralização de CR/LF |
| CSV | quote CSV + neutralização de fórmula |

Exemplo para JavaScript:

```java
String json = objectMapper.writeValueAsString(dto);
```

---

# 23. CWE-917 — Expression Language Injection

## Conceito

A aplicação avalia Expression Language com entrada externa.

Pode ocorrer com:

- JSP EL;
- Spring Expression Language;
- OGNL;
- MVEL;
- motores de template;
- regras dinâmicas;
- filtros configuráveis.

## Vulnerável com SpEL

```java
public Object avaliar(String expressao) {
    ExpressionParser parser = new SpelExpressionParser();
    return parser.parseExpression(expressao).getValue();
}
```

Entrada:

```text
T(java.lang.Runtime).getRuntime().exec('calc')
```

## Solução

Usar operações explicitamente permitidas.

```java
public boolean avaliarFiltro(Filtro filtro, Documento documento) {
    if ("STATUS_IGUAL".equals(filtro.getTipo())) {
        return documento.getStatus().equals(filtro.getValor());
    }

    if ("ANO_MAIOR_QUE".equals(filtro.getTipo())) {
        int ano = Integer.parseInt(filtro.getValor());
        return documento.getAno() > ano;
    }

    throw new IllegalArgumentException("Filtro não permitido");
}
```

Quando EL for requisito:

- usar contexto restrito;
- desabilitar acesso a tipos/classes/métodos perigosos;
- aplicar allowlist de propriedades;
- limitar tamanho e complexidade;
- assinar regras;
- restringir quem pode alterar regras.

---

# 24. CWE-1236 — Improper Neutralization of Formula Elements in a CSV File

## Conceito

Campos CSV controlados pelo usuário podem virar fórmula ao serem abertos em planilhas.

Prefixos perigosos comuns:

```text
=
+
-
@
```

Também considerar espaços, tabulações e quebras de linha antes desses caracteres.

## Vulnerável

```java
public String linhaCsv(String nome, String observacao) {
    return nome + "," + observacao + "\n";
}
```

Entrada:

```text
=HYPERLINK("http://evil.example","clique")
```

## Solução

```java
public final class CsvSafe {

    private CsvSafe() {
    }

    public static String cell(String value) {
        if (value == null) {
            return "\"\"";
        }

        String normalized = value
            .replace("\r", " ")
            .replace("\n", " ");

        String leftTrimmed = ltrim(normalized);

        if (startsWithFormulaPrefix(leftTrimmed)) {
            normalized = "'" + normalized;
        }

        String escaped = normalized.replace("\"", "\"\"");

        return "\"" + escaped + "\"";
    }

    private static boolean startsWithFormulaPrefix(String value) {
        if (value.isEmpty()) {
            return false;
        }

        char first = value.charAt(0);
        return first == '=' || first == '+' || first == '-' || first == '@';
    }

    private static String ltrim(String value) {
        int index = 0;

        while (index < value.length()
                && Character.isWhitespace(value.charAt(index))) {
            index++;
        }

        return value.substring(index);
    }
}
```

Uso:

```java
String linha = CsvSafe.cell(nome) + "," + CsvSafe.cell(observacao) + "\n";
```

---

# 25. Componentes reutilizáveis

## 25.1 Allowlist genérica para token simples

```java
public final class AllowList {

    private AllowList() {
    }

    public static String requireToken(String value, String fieldName) {
        if (value == null || !value.matches("[A-Za-z0-9._-]{1,100}")) {
            throw new IllegalArgumentException(fieldName + " inválido");
        }

        return value;
    }
}
```

## 25.2 Escape HTML mínimo didático

Em produção, prefira biblioteca madura.

```java
public final class HtmlEscaper {

    private HtmlEscaper() {
    }

    public static String escapeHtml(String value) {
        if (value == null) {
            return "";
        }

        StringBuilder out = new StringBuilder();

        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);

            switch (c) {
                case '&': out.append("&amp;"); break;
                case '<': out.append("&lt;"); break;
                case '>': out.append("&gt;"); break;
                case '"': out.append("&quot;"); break;
                case '\'': out.append("&#x27;"); break;
                default: out.append(c);
            }
        }

        return out.toString();
    }
}
```

## 25.3 Nome seguro para download

```java
public final class DownloadName {

    private DownloadName() {
    }

    public static String safe(String value) {
        if (value == null) {
            return "arquivo";
        }

        String normalized = Normalizer.normalize(value, Normalizer.Form.NFC);

        normalized = normalized.replaceAll("[\\r\\n\\t\\x00]", "_");
        normalized = normalized.replaceAll("[^A-Za-z0-9._ -]", "_");
        normalized = normalized.trim();

        if (normalized.isEmpty() || normalized.length() > 100) {
            return "arquivo";
        }

        return normalized;
    }
}
```

---

# 26. Diferenças importantes

## 26.1 CWE-78 versus CWE-88

| Situação | CWE |
|---|---:|
| Entrada injeta novo comando no shell | 78 |
| Entrada altera argumento/opção | 88 |
| `Runtime.exec("cmd " + input)` | 78 |
| `ProcessBuilder("ls", input)` com `--recursive` | 88 |

## 26.2 CWE-79 versus CWE-838

| Situação | CWE |
|---|---:|
| Entrada vira script/HTML executável | 79 |
| Escape errado para o contexto | 838 |
| Escape HTML dentro de JavaScript | 838, podendo causar 79 |

## 26.3 CWE-89 versus CWE-791

| Situação | CWE |
|---|---:|
| SQL concatenado permite alterar consulta | 89 |
| Filtro remove `'`, mas é incompleto | 791 |
| PreparedStatement usado corretamente | Mitiga 89 |

## 26.4 CWE-93 versus CWE-117

| Situação | CWE |
|---|---:|
| CRLF injeta cabeçalho HTTP | 93 |
| CRLF injeta linha falsa em log | 117 |

## 26.5 CWE-463 versus CWE-464

| Situação | CWE |
|---|---:|
| Marcador de fim é removido | 463 |
| Marcador de fim é inserido pelo atacante | 464 |

---

# 27. Checklist de revisão

## SQL/HQL

- Há concatenação de SQL?
- `LIKE` trata `%` e `_` quando necessário?
- `ORDER BY` usa allowlist?
- Nome de tabela/coluna vem do usuário?
- O DAO usa parâmetros vinculados?

## HTML/XSS

- JSP usa scriptlet com entrada externa?
- Há `${param...}` em atributo ou script?
- A saída é escapada conforme contexto?
- Conteúdo armazenado é escapado ao exibir?
- JavaScript é montado por concatenação?

## Comandos

- Existe `Runtime.exec`?
- Existe `ProcessBuilder` com argumento externo?
- Existe `sh -c` ou `cmd.exe /c`?
- Há allowlist de operação?
- Há timeout e menor privilégio?

## Logs, headers e CRLF

- Dados externos entram em log?
- CR/LF é neutralizado?
- Header usa nome de arquivo externo?
- Há limite de tamanho?
- Segredos são mascarados?

## Arquivos

- Nome final é gerado pelo servidor?
- Diretório base é verificado?
- Extensão é allowlist?
- Nome original é apenas metadado?
- Há risco de colisão por normalização?

## CSV

- Células são delimitadas corretamente?
- Fórmulas são neutralizadas?
- Aspas são escapadas?
- Quebras de linha são tratadas?

## EL/código dinâmico

- Usuário controla expressão?
- Há `eval`, `ScriptEngine`, SpEL, OGNL ou MVEL?
- Existe allowlist de operações?
- O contexto está restrito?

---

# 28. Comandos de busca no código

## SQL Injection

```bash
grep -RniE 'createStatement|executeQuery\(|executeUpdate\(|createSQLQuery|createQuery' src/
```

```bash
grep -RniE 'SELECT|UPDATE|DELETE|INSERT|WHERE|ORDER BY' src/
```

## OS Command Injection / Argument Injection

```bash
grep -RniE 'Runtime\.getRuntime\(\)\.exec|ProcessBuilder|cmd\.exe|sh -c' src/
```

## XSS/JSP

```bash
grep -RniE '<%=|out\.print|innerHTML|document\.write|\$\{param\.' src/main/webapp/ web/ src/
```

## LDAP/XML/XPath

```bash
grep -RniE 'DirContext|context\.search|XPath|xpath\.evaluate|createElement|DocumentBuilderFactory' src/
```

## Logs, headers e redirects

```bash
grep -RniE '(log|logger)\.(trace|debug|info|warn|error)|setHeader|addHeader|sendRedirect' src/
```

## Code/EL Injection

```bash
grep -RniE 'ScriptEngine|eval\(|SpelExpressionParser|ExpressionParser|MVEL|OGNL|Class\.forName|Method\.invoke' src/
```

## CSV

```bash
grep -RniE 'text/csv|\.csv|StringBuilder.*append|PrintWriter' src/
```

## Arquivos

```bash
grep -RniE 'new File|Paths\.get|resolve\(|getOriginalFilename|getSubmittedFileName' src/
```

---

# 29. Testes sugeridos

## SQL

1. `admin' OR '1'='1`.
2. Valor com aspas simples.
3. Valor com `%` e `_` em `LIKE`.
4. Campo de ordenação inválido.
5. Campo de ordenação com `desc; drop table`.
6. Parâmetro numérico com texto.
7. Erro SQL não deve expor stack trace ao usuário.

## XSS

1. `<script>alert(1)</script>`.
2. `"><img src=x onerror=alert(1)>`.
3. Valor dentro de atributo HTML.
4. Valor dentro de JavaScript.
5. Conteúdo armazenado e exibido depois.
6. Unicode e encoding.
7. HTML permitido com tags não permitidas.

## Comandos

1. `; id`.
2. `&& whoami`.
3. `--help`.
4. `--config=/tmp/malicioso`.
5. Path com espaço.
6. Path com `../`.
7. Path com newline.
8. Processo excedendo timeout.

## Logs/CRLF

1. Valor com `\nINFO falso`.
2. Valor com `\r\nHeader: x`.
3. Nome de arquivo com newline.
4. Campo muito longo.
5. Valor com caracteres de controle.
6. Confirmar que segredos são mascarados.

## CSV

1. `=1+1`.
2. `+SUM(A1:A2)`.
3. `-10+20`.
4. `@cmd`.
5. Espaço antes de `=`.
6. Aspas.
7. Vírgula.
8. Quebra de linha.
9. Fórmula na segunda coluna.
10. Importação no Excel/LibreOffice.

## Arquivos

1. `../segredo.txt`.
2. `..\segredo.txt`.
3. `%2e%2e%2f`.
4. `arquivo.pdf.exe`.
5. `relatorio.PDF`.
6. `arquivo\0.pdf`.
7. nome gigante.
8. nomes equivalentes por case.
9. nomes equivalentes por Unicode.
10. colisão de nomes normalizados.

---

# 30. Exemplos de testes unitários

## SQL deve usar parâmetro

```java
@Test
public void loginComAspasNaoDeveAlterarConsulta() throws Exception {
    Usuario usuario = usuarioDAO.buscarPorLogin("admin' OR '1'='1");
    assertNull(usuario);
}
```

## Nome de download não deve conter CRLF

```java
@Test
public void nomeDeDownloadDeveRemoverCrlf() {
    String nome = DownloadName.safe("relatorio.pdf\r\nX-Test: true");

    assertFalse(nome.contains("\r"));
    assertFalse(nome.contains("\n"));
}
```

## CSV deve neutralizar fórmula

```java
@Test
public void csvDeveNeutralizarFormula() {
    String cell = CsvSafe.cell("=HYPERLINK(\"http://evil\")");
    assertTrue(cell.startsWith("\"'="));
}
```

## Escape HTML

```java
@Test
public void mensagemDeErroDeveEscaparHtml() {
    String html = HtmlEscaper.escapeHtml("<script>alert(1)</script>");

    assertEquals(
        "&lt;script&gt;alert(1)&lt;/script&gt;",
        html
    );
}
```

---

# 31. Quadro de decisão rápida

| Evidência | CWE provável |
|---|---:|
| Bloqueia `../`, mas aceita `%2e%2e%2f` | 76 ou 791 |
| `Runtime.exec("cmd " + input)` | 78 |
| Valor do usuário aparece em JSP sem escape | 79 |
| `ProcessBuilder("ls", input)` aceita `--option` | 88 |
| SQL concatenado com parâmetro | 89 |
| Filtro LDAP concatenado | 90 |
| XPath com login/senha concatenados | 91 |
| Header HTTP contém valor com CRLF | 93 |
| `ScriptEngine.eval(input)` | 94 |
| Log permite quebra de linha | 117 |
| Exportação delimitada por `|` sem escape | 140 |
| Entrada contém `\0` e cruza API nativa | 170 |
| Parser remove sentinela `FIM` | 463 |
| Entrada injeta sentinela `FIM` | 464 |
| Nome de arquivo vem do usuário e vira path | 641 |
| Recursos colidem por nome normalizado | 694 |
| Blacklist remove só alguns caracteres | 791 |
| Escape HTML usado em JavaScript | 838 |
| SpEL/OGNL/MVEL recebe expressão externa | 917 |
| CSV permite célula iniciada por `=` | 1236 |

---

# 32. Resumo para prova

## CWE-137

Categoria de falhas de neutralização. Não deve ser usada diretamente para mapeamento quando houver CWE Base mais específica.

## CWE-76

Falha ao neutralizar elementos especiais equivalentes.

## CWE-78

Entrada externa altera comando do sistema operacional.

## CWE-79

Entrada externa vira conteúdo executável em página web.

## CWE-88

Entrada externa altera argumentos ou opções de comando.

## CWE-89

Entrada externa altera comando SQL.

## CWE-90

Entrada externa altera filtro LDAP.

## CWE-91

Entrada externa altera XML ou XPath.

## CWE-93

CRLF injeta cabeçalhos, linhas ou estruturas textuais.

## CWE-94

Entrada externa controla geração ou execução de código.

## CWE-117

Entrada externa forja ou corrompe logs.

## CWE-140

Delimitadores não são neutralizados corretamente.

## CWE-170

Terminador nulo é tratado de forma incompatível.

## CWE-463

Sentinela de estrutura é removido.

## CWE-464

Sentinela de estrutura é adicionado indevidamente.

## CWE-641

Nome de arquivo ou recurso não é restringido adequadamente.

## CWE-694

Recursos diferentes usam identificador duplicado.

## CWE-791

Filtragem de caracteres especiais é incompleta.

## CWE-838

Encoding usado não corresponde ao contexto de saída.

## CWE-917

Entrada externa é avaliada por Expression Language.

## CWE-1236

Célula CSV permite fórmula maliciosa.

---

# 33. Referências

## MITRE CWE

- [CWE-137 — Data Neutralization Issues](https://cwe.mitre.org/data/definitions/137.html)
- [CWE-76 — Improper Neutralization of Equivalent Special Elements](https://cwe.mitre.org/data/definitions/76.html)
- [CWE-78 — OS Command Injection](https://cwe.mitre.org/data/definitions/78.html)
- [CWE-79 — Cross-site Scripting](https://cwe.mitre.org/data/definitions/79.html)
- [CWE-88 — Argument Injection](https://cwe.mitre.org/data/definitions/88.html)
- [CWE-89 — SQL Injection](https://cwe.mitre.org/data/definitions/89.html)
- [CWE-90 — LDAP Injection](https://cwe.mitre.org/data/definitions/90.html)
- [CWE-91 — XML Injection / XPath Injection](https://cwe.mitre.org/data/definitions/91.html)
- [CWE-93 — CRLF Injection](https://cwe.mitre.org/data/definitions/93.html)
- [CWE-94 — Code Injection](https://cwe.mitre.org/data/definitions/94.html)
- [CWE-117 — Log Injection](https://cwe.mitre.org/data/definitions/117.html)
- [CWE-140 — Improper Neutralization of Delimiters](https://cwe.mitre.org/data/definitions/140.html)
- [CWE-170 — Improper Null Termination](https://cwe.mitre.org/data/definitions/170.html)
- [CWE-463 — Deletion of Data Structure Sentinel](https://cwe.mitre.org/data/definitions/463.html)
- [CWE-464 — Addition of Data Structure Sentinel](https://cwe.mitre.org/data/definitions/464.html)
- [CWE-641 — Improper Restriction of Names for Files and Other Resources](https://cwe.mitre.org/data/definitions/641.html)
- [CWE-694 — Use of Multiple Resources with Duplicate Identifier](https://cwe.mitre.org/data/definitions/694.html)
- [CWE-791 — Incomplete Filtering of Special Elements](https://cwe.mitre.org/data/definitions/791.html)
- [CWE-838 — Inappropriate Encoding for Output Context](https://cwe.mitre.org/data/definitions/838.html)
- [CWE-917 — Expression Language Injection](https://cwe.mitre.org/data/definitions/917.html)
- [CWE-1236 — CSV Formula Injection](https://cwe.mitre.org/data/definitions/1236.html)

## OWASP e Java

- [OWASP SQL Injection Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html)
- [OWASP Cross Site Scripting Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html)
- [OWASP OS Command Injection Defense Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/OS_Command_Injection_Defense_Cheat_Sheet.html)
- [OWASP LDAP Injection Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/LDAP_Injection_Prevention_Cheat_Sheet.html)
- [OWASP Logging Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html)
- [OWASP CSV Injection](https://owasp.org/www-community/attacks/CSV_Injection)
- [Java SE 8 — PreparedStatement](https://docs.oracle.com/javase/8/docs/api/java/sql/PreparedStatement.html)
- [Java SE 8 — ProcessBuilder](https://docs.oracle.com/javase/8/docs/api/java/lang/ProcessBuilder.html)
- [Java SE 8 — Pattern](https://docs.oracle.com/javase/8/docs/api/java/util/regex/Pattern.html)

---

# 34. Conclusão

Falhas de neutralização surgem quando dados externos entram em um contexto com sintaxe própria e o sistema não garante que esses dados serão tratados apenas como dados.

A defesa correta raramente é “remover caracteres perigosos”. O padrão seguro é:

- usar API parametrizada;
- aplicar encoding contextual;
- usar allowlist;
- canonicalizar antes de validar;
- evitar interpretadores genéricos;
- validar nomes e caminhos;
- neutralizar logs e CSV;
- separar instrução de dado;
- testar com caracteres especiais reais;
- manter bibliotecas maduras para cada contexto.

A regra central é:

> Nunca envie dado externo para um interpretador sem antes garantir, pelo mecanismo apropriado ao contexto, que esse dado não poderá alterar a estrutura, a instrução ou o significado da operação.
