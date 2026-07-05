# CWE-699 — Software Development
## Categoria: CWE-438 — Behavioral Problems

> **Objetivo:** material prático para revisão e uso em GitHub, com foco em Java, aplicações web legadas, Struts/Servlet/JSP, APIs REST, serviços corporativos e código executado em application server.
>
> **Fonte principal:** MITRE CWE — `https://cwe.mitre.org/data/definitions/438.html`
>
> A **CWE-438 — Behavioral Problems** é uma **Category** dentro da view **CWE-699 — Software Development**. Por ser uma categoria, ela não deve ser usada diretamente para mapear vulnerabilidades reais. Para análise, correção e evidência técnica, use as CWEs Base/Class listadas abaixo.

---

## 1. Visão geral

A categoria **Behavioral Problems** reúne falhas em que o sistema **executa o comportamento errado**, **executa etapas na ordem errada**, **interpreta dados de forma diferente do esperado** ou **permite que o fluxo de negócio seja manipulado**.

Em Java web, essas fraquezas aparecem com frequência em:

- `Action`/`Servlet` que redireciona, mas continua executando;
- validação feita antes de normalizar/canonicalizar entrada;
- autorização feita com URL, path ou identificador ainda não normalizado;
- fluxo de telas em que o usuário consegue pular etapas;
- `switch` sem `break`, sem `default` seguro ou com queda acidental;
- operadores incorretos, precedência ambígua e ausência de parênteses;
- código que depende de comportamento de ambiente, versão do Java, servidor ou proxy;
- loops que não terminam;
- ações críticas executadas mais de uma vez por duplo clique, replay ou refresh;
- proxy, gateway ou balanceador interpretando HTTP de forma diferente do backend.

**Ideia central para revisão:** quando a segurança depende de uma sequência correta de etapas, a aplicação deve impor essa sequência no backend. Não basta confiar na ordem das telas, no JavaScript, no botão escondido, no redirect ou no comportamento implícito do servidor.

---

## 2. Mapa rápido da categoria

| CWE | Nome | Aplicabilidade em Java | Foco prático |
|---:|---|---|---|
| 115 | Misinterpretation of Input | Alta | Entrada interpretada com tipo, encoding, formato, locale ou semântica incorreta. |
| 179 | Incorrect Behavior Order: Early Validation | Alta | Validação ocorre antes da normalização, decodificação ou canonicalização. |
| 408 | Incorrect Behavior Order: Early Amplification | Alta | O sistema expande, carrega, descompacta ou processa dados antes de validar limites. |
| 437 | Incomplete Model of Endpoint Features | Alta | O modelo de endpoints não cobre métodos, aliases, rotas, headers ou ações reais. |
| 439 | Behavioral Change in New Version or Environment | Alta | Mudança de Java, servidor, biblioteca ou ambiente altera o comportamento esperado. |
| 440 | Expected Behavior Violation | Alta | O código viola o contrato esperado de uma função, serviço ou fluxo. |
| 444 | Inconsistent Interpretation of HTTP Requests | Média/Alta | Proxy, gateway e backend interpretam requisições HTTP de forma diferente. |
| 480 | Use of Incorrect Operator | Alta | Uso de operador errado, como `&` no lugar de `&&`, `==` em `String`, ou operador lógico incorreto. |
| 483 | Incorrect Block Delimitation | Alta | Falta de chaves ou delimitação incorreta altera quais comandos pertencem ao bloco. |
| 484 | Omitted Break Statement in Switch | Alta | `switch` executa casos seguintes por queda acidental. |
| 551 | Authorization Before Parsing and Canonicalization | Alta | Autorização ocorre antes de resolver caminho, alias, encoding ou forma canônica. |
| 698 | Execution After Redirect | Alta | Código continua executando após `sendRedirect`, `forward` ou retorno de erro. |
| 733 | Compiler Optimization Removal or Modification of Security-critical Code | Média | Código crítico de segurança pode ser removido/modificado por otimização ou por não ter efeito observável. |
| 783 | Operator Precedence Logic Error | Alta | Expressão lógica funciona diferente do esperado por precedência de operadores. |
| 835 | Loop with Unreachable Exit Condition | Alta | Loop nunca atinge condição de saída. Pode causar DoS. |
| 837 | Improper Enforcement of a Single, Unique Action | Alta | Ação crítica pode ser executada mais de uma vez. |
| 841 | Improper Enforcement of Behavioral Workflow | Alta | Usuário consegue pular, repetir ou inverter etapas do fluxo de negócio. |
| 1025 | Comparison Using Wrong Factors | Alta | Comparação usa atributo errado para tomar decisão de segurança ou negócio. |
| 1037 | Processor Optimization Removal or Modification of Security-critical Code | Média | CPU/JIT/concorrência altera visibilidade ou ordem de execução esperada. |

---

## 3. Princípios seguros para Behavioral Problems

1. **Normalize antes de validar e autorizar.** Entrada codificada, path, URL, nome de arquivo e identificador devem ser convertidos para uma forma canônica antes da decisão.
2. **O backend deve impor o fluxo.** A ordem correta das telas não é controle de segurança.
3. **Depois de redirect/erro, pare a execução.** Em Java web, `sendRedirect()` não encerra o método automaticamente.
4. **Ação crítica deve ser idempotente ou protegida por token único.** Duplo clique, refresh e replay são cenários reais.
5. **Não dependa de default do ambiente.** Charset, timezone, locale, TLS, proxy, encoding e comportamento de servidor devem ser explícitos.
6. **Use enum/estado canônico para workflow.** Evite controlar fluxo por string solta, parâmetro hidden ou flag de tela.
7. **Prefira código explícito.** Chaves obrigatórias, `break` explícito, parênteses em regras complexas e `default` seguro.
8. **Trate comportamento inesperado como falha segura.** Se o sistema não entende o estado, método, rota, operador, parâmetro ou versão, deve negar ou interromper.

---

## 4. Base de apoio para os exemplos

Os exemplos usam classes simples. Adapte para Struts, Servlet, Spring MVC, Jakarta EE ou Java legado conforme o projeto.

```java
public final class Usuario {
    private final Long id;
    private final String login;
    private final Set<String> permissoes;

    public Usuario(Long id, String login, Set<String> permissoes) {
        this.id = id;
        this.login = login;
        this.permissoes = permissoes == null ? Collections.emptySet() : permissoes;
    }

    public Long getId() {
        return id;
    }

    public String getLogin() {
        return login;
    }

    public boolean possuiPermissao(String permissao) {
        return permissoes.contains(permissao);
    }
}

public final class AcessoNegadoException extends RuntimeException {
    public AcessoNegadoException(String mensagem) {
        super(mensagem);
    }
}

public final class RequisicaoInvalidaException extends RuntimeException {
    public RequisicaoInvalidaException(String mensagem) {
        super(mensagem);
    }
}

public final class AuthorizationGuard {
    public void exigirPermissao(Usuario usuario, String permissao) {
        if (usuario == null || !usuario.possuiPermissao(permissao)) {
            throw new AcessoNegadoException("Usuário sem permissão: " + permissao);
        }
    }
}
```

---

# 5. CWEs Base/Class com exemplos Java

---

## 5.1 CWE-115 — Misinterpretation of Input

### Descrição prática

O sistema recebe uma entrada e a interpreta de forma diferente da intenção original. Isso pode ocorrer por:

- formato de data diferente;
- locale diferente;
- charset implícito;
- booleano interpretado incorretamente;
- parâmetro numérico convertido de forma permissiva;
- valores equivalentes representados de formas diferentes;
- entrada que possui significado especial para uma camada e significado diferente para outra.

### Exemplo vulnerável

```java
public boolean isAdmin(HttpServletRequest request) {
    // Vulnerável: qualquer valor diferente de "true" vira false, inclusive erros de digitação.
    // Além disso, uma decisão de segurança nunca deveria vir de parâmetro da request.
    return Boolean.parseBoolean(request.getParameter("admin"));
}

public BigDecimal converterValor(String valor) {
    // Vulnerável: depende do formato recebido. "1,50" pode falhar ou ser tratado indevidamente.
    return new BigDecimal(valor);
}
```

### Solução

```java
public boolean isAdmin(Usuario usuario) {
    return usuario != null && usuario.possuiPermissao("ADMIN");
}

public BigDecimal converterValorMonetario(String valor) {
    if (valor == null || !valor.matches("^\\d{1,9}([.,]\\d{2})?$")) {
        throw new RequisicaoInvalidaException("Valor monetário inválido.");
    }

    String normalizado = valor.replace(',', '.');
    return new BigDecimal(normalizado).setScale(2, RoundingMode.UNNECESSARY);
}
```

### Como revisar

Procure por:

```bash
grep -R "Boolean.parseBoolean(request" -n src/
grep -R "new BigDecimal(request" -n src/
grep -R "new String(.*getBytes" -n src/
grep -R "SimpleDateFormat" -n src/
```

### Regra prática

> Entrada externa deve ser interpretada com formato, charset, locale e semântica explícitos. Decisão de segurança não deve depender de interpretação ambígua.

---

## 5.2 CWE-179 — Incorrect Behavior Order: Early Validation

### Descrição prática

A aplicação valida a entrada **antes** de normalizar, decodificar ou canonicalizar. O atacante passa uma entrada que parece válida no primeiro momento, mas se torna perigosa depois da transformação.

### Exemplo vulnerável

```java
public File obterArquivoRelatorio(String nomeArquivo) throws IOException {
    // Vulnerável: valida antes de decodificar.
    if (nomeArquivo.contains("..")) {
        throw new RequisicaoInvalidaException("Caminho inválido.");
    }

    String decodificado = URLDecoder.decode(nomeArquivo, StandardCharsets.UTF_8.name());
    return new File("/var/app/relatorios", decodificado);
}
```

Entrada maliciosa:

```text
%2e%2e%2fWEB-INF%2fweb.xml
```

No primeiro `contains("..")`, a entrada não possui `..`. Depois de decodificar, vira `../WEB-INF/web.xml`.

### Solução

```java
public Path obterArquivoRelatorioSeguro(String nomeArquivo) throws IOException {
    if (nomeArquivo == null || nomeArquivo.isBlank()) {
        throw new RequisicaoInvalidaException("Nome de arquivo obrigatório.");
    }

    String decodificado = URLDecoder.decode(nomeArquivo, StandardCharsets.UTF_8.name());

    Path base = Paths.get("/var/app/relatorios").toRealPath();
    Path alvo = base.resolve(decodificado).normalize();

    if (!alvo.startsWith(base)) {
        throw new AcessoNegadoException("Arquivo fora do diretório permitido.");
    }

    if (!Files.isRegularFile(alvo)) {
        throw new RequisicaoInvalidaException("Arquivo inexistente.");
    }

    return alvo;
}
```

### Como revisar

```bash
grep -R "URLDecoder.decode" -n src/
grep -R "contains(\"..\")" -n src/
grep -R "new File(.*request" -n src/
grep -R "Paths.get(.*request" -n src/
```

### Regra prática

> A ordem segura é: receber → decodificar → normalizar/canonicalizar → validar → autorizar → executar.

---

## 5.3 CWE-408 — Incorrect Behavior Order: Early Amplification

### Descrição prática

O sistema amplia o impacto da entrada antes de validar limites. Exemplos:

- descompacta ZIP antes de limitar tamanho;
- carrega arquivo inteiro em memória antes de validar tamanho;
- consulta grande antes de validar filtro obrigatório;
- transforma payload pequeno em grande volume de objetos;
- executa parse caro antes de autenticar.

### Exemplo vulnerável

```java
public void importarZip(InputStream upload) throws IOException {
    // Vulnerável: processa/descompacta sem limite de tamanho total.
    try (ZipInputStream zip = new ZipInputStream(upload)) {
        ZipEntry entry;
        while ((entry = zip.getNextEntry()) != null) {
            byte[] conteudo = zip.readAllBytes();
            salvarArquivo(entry.getName(), conteudo);
        }
    }
}
```

Esse padrão permite ZIP bomb ou consumo excessivo de memória.

### Solução

```java
public void importarZipSeguro(InputStream upload) throws IOException {
    long limiteTotal = 20L * 1024L * 1024L; // 20 MB
    long limitePorArquivo = 5L * 1024L * 1024L;
    long totalExtraido = 0L;

    try (ZipInputStream zip = new ZipInputStream(upload)) {
        ZipEntry entry;
        byte[] buffer = new byte[8192];

        while ((entry = zip.getNextEntry()) != null) {
            validarNomeEntradaZip(entry.getName());

            long tamanhoArquivo = 0L;
            Path destino = resolverDestinoSeguro(entry.getName());

            try (OutputStream out = Files.newOutputStream(destino)) {
                int lidos;
                while ((lidos = zip.read(buffer)) != -1) {
                    tamanhoArquivo += lidos;
                    totalExtraido += lidos;

                    if (tamanhoArquivo > limitePorArquivo || totalExtraido > limiteTotal) {
                        throw new RequisicaoInvalidaException("Arquivo compactado excede o limite permitido.");
                    }

                    out.write(buffer, 0, lidos);
                }
            }
        }
    }
}

private void validarNomeEntradaZip(String nome) {
    if (nome == null || nome.contains("..") || nome.startsWith("/") || nome.startsWith("\\\\")) {
        throw new RequisicaoInvalidaException("Entrada ZIP inválida.");
    }
}
```

### Como revisar

```bash
grep -R "readAllBytes" -n src/
grep -R "ZipInputStream" -n src/
grep -R "MultipartFile.*getBytes" -n src/
grep -R "IOUtils.toByteArray" -n src/
```

### Regra prática

> Nunca amplie dados antes de validar autenticação, tamanho, quantidade, tipo, nome e destino.

---

## 5.4 CWE-437 — Incomplete Model of Endpoint Features

### Descrição prática

A aplicação cria um modelo incompleto dos endpoints e acredita estar protegendo tudo, mas esquece variações como:

- métodos HTTP diferentes (`GET`, `POST`, `PUT`, `DELETE`);
- aliases de URL;
- extensão diferente (`.do`, `.action`, `/api`);
- endpoint novo fora do filtro;
- parâmetro `action` que chama métodos diferentes;
- rota administrativa acessível por URL alternativa;
- endpoint de download, popup, callback ou integração.

### Exemplo vulnerável

```java
public class SecurityFilter implements Filter {
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        String uri = request.getRequestURI();

        // Vulnerável: só protege URLs .do.
        if (uri.endsWith(".do")) {
            validarSessao(request);
        }

        chain.doFilter(req, res);
    }
}
```

Endpoints como `/api/admin/usuarios`, `/download/arquivo`, `/relatorio/pdf` ou `/callback/projudi` podem ficar fora do modelo.

### Solução

```java
public final class EndpointPolicy {
    private static final Map<String, String> PERMISSOES = Map.of(
            "POST /usuarios/inativar", "USUARIO_INATIVAR",
            "GET /relatorios/depositos", "RELATORIO_DEPOSITOS_VISUALIZAR",
            "GET /arquivos/baixar", "ARQUIVO_BAIXAR"
    );

    public Optional<String> permissaoPara(HttpServletRequest request) {
        String metodo = request.getMethod().toUpperCase(Locale.ROOT);
        String path = normalizarPath(request.getRequestURI(), request.getContextPath());
        return Optional.ofNullable(PERMISSOES.get(metodo + " " + path));
    }

    private String normalizarPath(String uri, String contextPath) {
        String path = uri.substring(contextPath.length());
        return path.replaceAll("/+$", "");
    }
}

public class SecurityFilter implements Filter {
    private final EndpointPolicy policy = new EndpointPolicy();
    private final AuthorizationGuard guard = new AuthorizationGuard();

    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        Usuario usuario = (Usuario) request.getSession(false).getAttribute("usuario");

        Optional<String> permissao = policy.permissaoPara(request);
        if (permissao.isPresent()) {
            guard.exigirPermissao(usuario, permissao.get());
        }

        chain.doFilter(req, res);
    }
}
```

### Como revisar

```bash
grep -R "endsWith(\".do\")" -n src/
grep -R "getParameter(\"action\")" -n src/
grep -R "method=.*GET" -n src/main/webapp/WEB-INF
grep -R "@GetMapping\|@PostMapping\|@RequestMapping" -n src/
```

### Regra prática

> O modelo de segurança deve conhecer método HTTP, path normalizado, ação real executada e permissão exigida.

---

## 5.5 CWE-439 — Behavioral Change in New Version or Environment

### Descrição prática

O sistema depende de comportamento implícito de uma versão, biblioteca, servidor ou ambiente. Após atualização, migração ou mudança de configuração, a aplicação passa a se comportar de forma diferente.

Exemplos comuns em Java:

- mudança de JDK;
- mudança de Tomcat/WildFly/JBoss;
- mudança de driver JDBC;
- mudança de Jackson/Gson;
- charset padrão diferente;
- timezone diferente;
- mudança em normalização de path;
- cookies com política diferente;
- TLS/certificados com validação mais rígida;
- diferença entre ambiente local, homologação e produção.

### Exemplo vulnerável

```java
public String lerArquivoTexto(Path path) throws IOException {
    // Vulnerável: usa charset padrão do ambiente.
    return Files.readString(path);
}

public Date parseData(String data) throws ParseException {
    // Vulnerável: lenient por padrão pode aceitar datas inesperadas.
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    return sdf.parse(data);
}
```

### Solução

```java
public String lerArquivoTextoSeguro(Path path) throws IOException {
    return Files.readString(path, StandardCharsets.UTF_8);
}

public LocalDate parseDataSegura(String data) {
    DateTimeFormatter formatter = DateTimeFormatter
            .ofPattern("dd/MM/uuuu")
            .withResolverStyle(ResolverStyle.STRICT);

    return LocalDate.parse(data, formatter);
}
```

### Como revisar

```bash
grep -R "Files.readString" -n src/
grep -R "new String(.*byte" -n src/
grep -R "getBytes()" -n src/
grep -R "SimpleDateFormat" -n src/
grep -R "TimeZone.getDefault\|Locale.getDefault" -n src/
```

### Regra prática

> O que é relevante para segurança, auditoria e negócio deve ser explícito: charset, locale, timezone, formato, algoritmo, provider e comportamento de parsing.

---

## 5.6 CWE-440 — Expected Behavior Violation

### Descrição prática

Uma função, método, serviço ou endpoint promete um comportamento, mas implementa outro. Isso prejudica segurança porque outros pontos do sistema passam a confiar em uma garantia inexistente.

### Exemplo vulnerável

```java
public class CpfValidator {
    /**
     * Retorna true somente se o CPF for válido.
     */
    public boolean isValido(String cpf) {
        // Vulnerável: null ou vazio é tratado como válido para "facilitar cadastro parcial".
        if (cpf == null || cpf.isBlank()) {
            return true;
        }

        return cpf.matches("\\d{11}");
    }
}
```

O contrato diz “somente CPF válido”, mas a implementação aceita vazio. Outro serviço pode usar isso para liberar uma etapa crítica.

### Solução

```java
public class CpfValidator {
    /**
     * Retorna true quando o CPF possui 11 dígitos e passa na validação dos dígitos verificadores.
     * Retorna false para null, vazio ou formato inválido.
     */
    public boolean isValido(String cpf) {
        if (cpf == null) {
            return false;
        }

        String apenasDigitos = cpf.replaceAll("\\D", "");
        if (!apenasDigitos.matches("\\d{11}")) {
            return false;
        }

        return validarDigitosVerificadores(apenasDigitos);
    }
}
```

### Como revisar

```bash
grep -R "return true" -n src/ | grep -i "valid"
grep -R "TODO\|FIXME\|temporario\|provisório" -n src/
grep -R "isValido\|validar\|verificar" -n src/
```

### Regra prática

> Comentário, nome do método, contrato e implementação precisam dizer a mesma coisa.

---

## 5.7 CWE-444 — Inconsistent Interpretation of HTTP Requests ('HTTP Request/Response Smuggling')

### Descrição prática

Acontece quando componentes HTTP interpretam a mesma requisição de formas diferentes. Por exemplo:

- proxy lê `Content-Length`;
- backend lê `Transfer-Encoding`;
- firewall normaliza path de uma forma;
- aplicação normaliza de outra;
- servidor aceita header duplicado;
- gateway aceita método ou encoding que o backend interpreta diferentemente.

Em aplicações Java comuns, a correção geralmente envolve **configuração do proxy/servidor** e **não implementar parser HTTP caseiro**.

### Exemplo vulnerável

```java
public class ProxyCaseiroServlet extends HttpServlet {
    protected void service(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // Vulnerável: encaminha headers ambíguos sem validação.
        HttpURLConnection conn = (HttpURLConnection) new URL("http://backend-interno/processar").openConnection();
        conn.setRequestMethod(request.getMethod());

        Enumeration<String> nomes = request.getHeaderNames();
        while (nomes.hasMoreElements()) {
            String nome = nomes.nextElement();
            conn.setRequestProperty(nome, request.getHeader(nome));
        }

        request.getInputStream().transferTo(conn.getOutputStream());
    }
}
```

### Solução

```java
public final class HttpAmbiguityGuard {
    public void rejeitarHeadersAmbiguos(HttpServletRequest request) {
        boolean possuiContentLength = request.getHeader("Content-Length") != null;
        boolean possuiTransferEncoding = request.getHeader("Transfer-Encoding") != null;

        if (possuiContentLength && possuiTransferEncoding) {
            throw new RequisicaoInvalidaException("Requisição HTTP ambígua.");
        }

        Enumeration<String> transferEncodingValues = request.getHeaders("Transfer-Encoding");
        int count = 0;
        while (transferEncodingValues.hasMoreElements()) {
            count++;
            transferEncodingValues.nextElement();
        }

        if (count > 1) {
            throw new RequisicaoInvalidaException("Transfer-Encoding duplicado.");
        }
    }
}
```

Uso no filtro:

```java
public class HttpStrictFilter implements Filter {
    private final HttpAmbiguityGuard guard = new HttpAmbiguityGuard();

    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        guard.rejeitarHeadersAmbiguos(request);
        chain.doFilter(req, res);
    }
}
```

### Medidas recomendadas

- Usar servidores, proxies e gateways atualizados.
- Rejeitar requisições com `Content-Length` e `Transfer-Encoding` conflitantes.
- Não criar proxy HTTP manual em servlet.
- Padronizar normalização no gateway e no backend.
- Testar rotas atrás do mesmo proxy usado em produção.

### Como revisar

```bash
grep -R "Transfer-Encoding" -n src/
grep -R "Content-Length" -n src/
grep -R "getHeaderNames" -n src/
grep -R "HttpURLConnection" -n src/
grep -R "Proxy" -n src/
```

### Regra prática

> A aplicação, o proxy e o backend devem concordar sobre onde a requisição começa, onde termina e qual path/método está sendo processado.

---

## 5.8 CWE-480 — Use of Incorrect Operator

### Descrição prática

Uso de operador errado altera a regra. Em Java, os casos mais comuns são:

- `&` no lugar de `&&`;
- `|` no lugar de `||`;
- `==` no lugar de `.equals()` para `String`, `Long`, `Integer` e objetos;
- `!=` em objetos;
- operador lógico invertido;
- comparação com wrapper gerando comportamento inesperado.

### Exemplo vulnerável

```java
public boolean podeExcluir(Usuario usuario, String status) {
    // Vulnerável: usa &; avalia os dois lados sempre.
    return usuario != null & usuario.possuiPermissao("EXCLUIR") & status == "RASCUNHO";
}
```

Problemas:

- `&` não faz short-circuit;
- `status == "RASCUNHO"` compara referência, não conteúdo;
- pode gerar `NullPointerException`.

### Solução

```java
public boolean podeExcluir(Usuario usuario, String status) {
    return usuario != null
            && usuario.possuiPermissao("EXCLUIR")
            && "RASCUNHO".equals(status);
}
```

### Como revisar

```bash
grep -R " if (.* & .*" -n src/
grep -R " if (.* | .*" -n src/
grep -R "== \"" -n src/
grep -R "!= \"" -n src/
```

### Regra prática

> Em condição booleana, use `&&` e `||`. Para objetos e `String`, use `.equals()` ou `Objects.equals()`.

---

## 5.9 CWE-483 — Incorrect Block Delimitation

### Descrição prática

A delimitação incorreta de blocos faz com que uma instrução pareça estar dentro de um `if`, `else`, `for` ou `while`, mas não esteja.

### Exemplo vulnerável

```java
public void excluir(Long id, Usuario usuario) {
    if (usuario.possuiPermissao("EXCLUIR"))
        auditoria.registrar("Exclusão solicitada", usuario.getLogin());
        dao.excluir(id); // Vulnerável: executa sempre.
}
```

### Solução

```java
public void excluir(Long id, Usuario usuario) {
    if (usuario.possuiPermissao("EXCLUIR")) {
        auditoria.registrar("Exclusão solicitada", usuario.getLogin());
        dao.excluir(id);
        return;
    }

    throw new AcessoNegadoException("Usuário sem permissão para excluir.");
}
```

### Como revisar

```bash
grep -R "if (.*)$" -n src/
grep -R "else$" -n src/
grep -R "for (.*)$" -n src/
```

### Regra prática

> Use chaves sempre, inclusive em blocos de uma linha. Isso reduz erro de manutenção e alteração futura.

---

## 5.10 CWE-484 — Omitted Break Statement in Switch

### Descrição prática

Em `switch` tradicional, a ausência de `break` causa queda para o próximo caso. Quando isso não é intencional, o sistema executa comportamento indevido.

### Exemplo vulnerável

```java
public Set<String> permissoesPorPerfil(String perfil) {
    Set<String> permissoes = new HashSet<>();

    switch (perfil) {
        case "OPERADOR":
            permissoes.add("CONSULTAR");
        case "ADMIN":
            permissoes.add("EXCLUIR");
            permissoes.add("ALTERAR_PERMISSOES");
            break;
        default:
            permissoes.add("CONSULTAR_PUBLICO");
    }

    return permissoes;
}
```

Um `OPERADOR` recebe permissões de `ADMIN`.

### Solução Java 8+

```java
public Set<String> permissoesPorPerfil(String perfil) {
    Set<String> permissoes = new HashSet<>();

    switch (perfil) {
        case "OPERADOR":
            permissoes.add("CONSULTAR");
            break;
        case "ADMIN":
            permissoes.add("CONSULTAR");
            permissoes.add("EXCLUIR");
            permissoes.add("ALTERAR_PERMISSOES");
            break;
        default:
            throw new AcessoNegadoException("Perfil desconhecido.");
    }

    return permissoes;
}
```

### Solução Java moderno

```java
public Set<String> permissoesPorPerfil(String perfil) {
    return switch (perfil) {
        case "OPERADOR" -> Set.of("CONSULTAR");
        case "ADMIN" -> Set.of("CONSULTAR", "EXCLUIR", "ALTERAR_PERMISSOES");
        default -> throw new AcessoNegadoException("Perfil desconhecido.");
    };
}
```

### Como revisar

```bash
grep -R "switch" -n src/
grep -R "case .*:" -n src/
```

### Regra prática

> Toda queda entre casos deve ser explícita e comentada. Caso contrário, use `break` ou `switch` com `->`.

---

## 5.11 CWE-551 — Incorrect Behavior Order: Authorization Before Parsing and Canonicalization

### Descrição prática

A autorização é feita antes de resolver a forma real do recurso. O sistema autoriza uma string aparentemente permitida, mas depois o recurso real acessado é outro.

### Exemplo vulnerável

```java
public void baixarArquivo(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
        throws IOException {

    String nome = request.getParameter("arquivo");

    // Vulnerável: autoriza com base no nome bruto.
    if (nome.startsWith("publico/")) {
        enviarArquivo(response, new File("/var/app/arquivos", nome));
        return;
    }

    if (!usuario.possuiPermissao("ARQUIVO_PRIVADO")) {
        throw new AcessoNegadoException("Sem permissão.");
    }

    enviarArquivo(response, new File("/var/app/arquivos", nome));
}
```

Entrada:

```text
publico/../privado/contrato.pdf
```

### Solução

```java
public void baixarArquivoSeguro(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
        throws IOException {

    Path base = Paths.get("/var/app/arquivos").toRealPath();
    String parametro = request.getParameter("arquivo");
    String decodificado = URLDecoder.decode(parametro, StandardCharsets.UTF_8.name());

    Path alvo = base.resolve(decodificado).normalize();
    if (!alvo.startsWith(base)) {
        throw new AcessoNegadoException("Caminho inválido.");
    }

    boolean arquivoPublico = alvo.startsWith(base.resolve("publico").normalize());
    if (!arquivoPublico) {
        new AuthorizationGuard().exigirPermissao(usuario, "ARQUIVO_PRIVADO");
    }

    enviarArquivo(response, alvo.toFile());
}
```

### Como revisar

```bash
grep -R "startsWith(\"public" -n src/
grep -R "possuiPermissao" -n src/ | grep -i "arquivo\|path\|url"
grep -R "new File" -n src/ | grep "request\|param"
```

### Regra prática

> Autorize o recurso real, já decodificado, normalizado e resolvido contra a base permitida.

---

## 5.12 CWE-698 — Execution After Redirect (EAR)

### Descrição prática

Em Java web, chamar `response.sendRedirect(...)` não interrompe automaticamente o método. Se o código continuar, pode executar ação crítica após o redirect.

### Exemplo vulnerável

```java
public void excluir(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
        throws IOException {

    if (!usuario.possuiPermissao("EXCLUIR")) {
        response.sendRedirect("/erro/403.jsp");
    }

    Long id = Long.valueOf(request.getParameter("id"));
    dao.excluir(id); // Vulnerável: ainda executa.
}
```

### Solução

```java
public void excluir(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
        throws IOException {

    if (!usuario.possuiPermissao("EXCLUIR")) {
        response.sendRedirect("/erro/403.jsp");
        return;
    }

    Long id = Long.valueOf(request.getParameter("id"));
    dao.excluir(id);
}
```

### Solução em Struts Action

```java
public ActionForward excluir(ActionMapping mapping, ActionForm form,
        HttpServletRequest request, HttpServletResponse response) throws Exception {

    Usuario usuario = (Usuario) request.getSession().getAttribute("usuario");

    if (!usuario.possuiPermissao("EXCLUIR")) {
        return mapping.findForward("acessoNegado");
    }

    Long id = Long.valueOf(request.getParameter("id"));
    service.excluir(id, usuario);

    return mapping.findForward("sucesso");
}
```

### Como revisar

```bash
grep -R "sendRedirect" -n src/
grep -R "forward(request, response)" -n src/
grep -R "setStatus(HttpServletResponse.SC_FORBIDDEN" -n src/
grep -R "sendError" -n src/
```

Após encontrar, verifique se existe `return`, `throw` ou controle equivalente logo depois.

### Regra prática

> Redirect, forward e erro HTTP não encerram automaticamente a execução do método Java. Encerre explicitamente.

---

## 5.13 CWE-733 — Compiler Optimization Removal or Modification of Security-critical Code

### Descrição prática

Código crítico de segurança pode ser removido ou alterado por otimizações quando não produz efeito observável. Em Java, esse caso é menos direto do que em C/C++, mas aparece em situações como:

- tentativa de limpar segredo em `String`, que é imutável;
- confiança em `finalize()` para apagar recurso;
- código de proteção dentro de `assert`, removido quando assertions estão desabilitadas;
- lógica de segurança que o compilador/JIT pode considerar inalcançável ou sem efeito;
- limpeza de memória feita tarde demais ou sem garantia.

### Exemplo vulnerável

```java
public void autenticar(String senha) {
    // Vulnerável: String é imutável e pode permanecer em memória.
    if (senha.equals("senhaMestre")) {
        liberarAcessoAdministrativo();
    }

    senha = null; // Não apaga o conteúdo original da memória.
}
```

Outro exemplo vulnerável:

```java
public void executarOperacao(Usuario usuario) {
    // Vulnerável: assert pode estar desabilitado em produção.
    assert usuario != null && usuario.possuiPermissao("OPERACAO_CRITICA");

    executarCritico();
}
```

### Solução

```java
public void autenticar(char[] senha) {
    try {
        if (senha == null || senha.length == 0) {
            throw new AcessoNegadoException("Senha inválida.");
        }

        if (verificarSenha(senha)) {
            liberarAcessoAdministrativo();
            return;
        }

        throw new AcessoNegadoException("Senha inválida.");
    } finally {
        if (senha != null) {
            Arrays.fill(senha, '\0');
        }
    }
}

public void executarOperacao(Usuario usuario) {
    if (usuario == null || !usuario.possuiPermissao("OPERACAO_CRITICA")) {
        throw new AcessoNegadoException("Sem permissão.");
    }

    executarCritico();
}
```

### Como revisar

```bash
grep -R "assert .*possuiPermissao\|assert .*isAdmin" -n src/
grep -R "finalize()" -n src/
grep -R "String senha\|String password" -n src/
grep -R "= null;.*senha\|= null;.*password" -n src/
```

### Regra prática

> Não coloque controle de segurança em `assert`, `finalize()` ou limpeza sem efeito observável. Use validação explícita, exceção e ciclo de vida controlado.

---

## 5.14 CWE-783 — Operator Precedence Logic Error

### Descrição prática

A expressão lógica tem operadores com precedência diferente da esperada. O código compila e parece correto, mas a regra real é outra.

### Exemplo vulnerável

```java
public boolean podeVisualizar(Usuario usuario, Documento doc) {
    // Vulnerável: && tem precedência maior que ||.
    // Regra real: ADMIN sempre visualiza, mesmo inativo.
    return usuario.possuiPermissao("ADMIN") || usuario.getId().equals(doc.getDonoId()) && doc.isAtivo();
}
```

Talvez a intenção fosse: usuário pode visualizar se for admin ou dono, mas somente se o documento estiver ativo.

### Solução

```java
public boolean podeVisualizar(Usuario usuario, Documento doc) {
    boolean adminOuDono = usuario.possuiPermissao("ADMIN")
            || usuario.getId().equals(doc.getDonoId());

    return adminOuDono && doc.isAtivo();
}
```

Ou com parênteses:

```java
public boolean podeVisualizar(Usuario usuario, Documento doc) {
    return (usuario.possuiPermissao("ADMIN") || usuario.getId().equals(doc.getDonoId()))
            && doc.isAtivo();
}
```

### Como revisar

```bash
grep -R "&&.*||\|||.*&&" -n src/
grep -R "? .* :" -n src/
grep -R "possuiPermissao" -n src/ | grep "&&\|||"
```

### Regra prática

> Em regras de segurança, prefira variáveis intermediárias com nomes claros ou parênteses explícitos.

---

## 5.15 CWE-835 — Loop with Unreachable Exit Condition ('Infinite Loop')

### Descrição prática

O loop possui condição de saída inalcançável. Pode causar consumo de CPU, memória, conexões ou travamento de thread.

### Exemplo vulnerável

```java
public List<Deposito> buscarTodos() {
    List<Deposito> todos = new ArrayList<>();
    int pagina = 1;

    while (true) {
        List<Deposito> itens = dao.buscarPagina(pagina);
        todos.addAll(itens);

        if (itens.isEmpty()) {
            break;
        }

        // Vulnerável: pagina nunca é incrementada.
    }

    return todos;
}
```

### Solução

```java
public List<Deposito> buscarTodos() {
    List<Deposito> todos = new ArrayList<>();
    int pagina = 1;
    int limitePaginas = 1000;

    while (pagina <= limitePaginas) {
        List<Deposito> itens = dao.buscarPagina(pagina);
        if (itens.isEmpty()) {
            return todos;
        }

        todos.addAll(itens);
        pagina++;
    }

    throw new IllegalStateException("Limite de paginação excedido.");
}
```

### Outro exemplo: leitura de stream

```java
public void copiar(InputStream in, OutputStream out) throws IOException {
    byte[] buffer = new byte[8192];
    int lidos;

    while ((lidos = in.read(buffer)) != -1) {
        out.write(buffer, 0, lidos);
    }
}
```

### Como revisar

```bash
grep -R "while (true)" -n src/
grep -R "for (;;)" -n src/
grep -R "do {" -n src/
grep -R "while (.*)" -n src/
```

### Regra prática

> Todo loop deve ter progresso visível, condição de saída alcançável e limite defensivo quando processar entrada externa ou recurso remoto.

---

## 5.16 CWE-837 — Improper Enforcement of a Single, Unique Action

### Descrição prática

Uma ação que deveria ocorrer apenas uma vez pode ser executada múltiplas vezes. Exemplos:

- duplo clique em botão;
- refresh após POST;
- reenvio da mesma requisição;
- retry de integração;
- callback duplicado;
- geração duplicada de guia/boleto/PIX;
- confirmação de pagamento repetida;
- criação duplicada de registro.

### Exemplo vulnerável

```java
public void gerarGuia(Long idDeposito, Usuario usuario) {
    Deposito deposito = depositoDao.buscar(idDeposito);

    if (!deposito.podeGerarGuia()) {
        throw new RequisicaoInvalidaException("Depósito não permite geração de guia.");
    }

    Guia guia = projudiGateway.gerarGuia(deposito);
    guiaDao.salvar(guia);
    deposito.marcarGuiaGerada(guia.getId());
    depositoDao.atualizar(deposito);
}
```

Se duas requisições chegam ao mesmo tempo, ambas podem passar na validação e gerar duas guias.

### Solução com idempotência

```java
public Guia gerarGuiaSeguro(Long idDeposito, String idempotencyKey, Usuario usuario) {
    if (idempotencyKey == null || idempotencyKey.isBlank()) {
        throw new RequisicaoInvalidaException("Chave de idempotência obrigatória.");
    }

    Optional<Guia> existente = guiaDao.buscarPorIdempotencyKey(idempotencyKey);
    if (existente.isPresent()) {
        return existente.get();
    }

    Deposito deposito = depositoDao.buscarComLock(idDeposito);

    if (!deposito.podeGerarGuia()) {
        throw new RequisicaoInvalidaException("Depósito não permite geração de guia.");
    }

    Guia guia = projudiGateway.gerarGuia(deposito);
    guia.setIdempotencyKey(idempotencyKey);

    guiaDao.salvar(guia);
    deposito.marcarGuiaGerada(guia.getId());
    depositoDao.atualizar(deposito);

    return guia;
}
```

### Solução complementar no banco

```sql
ALTER TABLE guia
ADD CONSTRAINT uk_guia_idempotency UNIQUE (idempotency_key);
```

### Como revisar

```bash
grep -R "gerar.*Guia\|regerar.*Guia\|confirmar.*Pagamento" -n src/
grep -R "salvar(.*" -n src/ | grep -i "pagamento\|guia\|boleto\|pix"
grep -R "synchronized" -n src/
grep -R "idempot" -n src/
```

### Regra prática

> Toda operação crítica sujeita a retry deve ter idempotência, lock transacional ou restrição única no banco.

---

## 5.17 CWE-841 — Improper Enforcement of Behavioral Workflow

### Descrição prática

O sistema não impõe corretamente o fluxo de negócio. O usuário consegue:

- pular etapas;
- repetir etapa proibida;
- executar etapa fora de ordem;
- alterar estado diretamente;
- acessar URL de etapa posterior;
- confirmar operação sem validações anteriores;
- chamar endpoint interno pelo navegador.

### Exemplo vulnerável

```java
public void finalizarCompra(Long idCompra, Usuario usuario) {
    Compra compra = compraDao.buscar(idCompra);

    // Vulnerável: não valida etapa anterior.
    compra.setStatus("FINALIZADA");
    compraDao.atualizar(compra);
}
```

### Solução com máquina de estados simples

```java
public enum StatusCompra {
    RASCUNHO,
    DADOS_VALIDADOS,
    PAGAMENTO_CONFIRMADO,
    FINALIZADA,
    CANCELADA
}

public final class WorkflowCompra {
    public void finalizar(Compra compra) {
        if (compra.getStatus() != StatusCompra.PAGAMENTO_CONFIRMADO) {
            throw new RequisicaoInvalidaException(
                    "Compra só pode ser finalizada após confirmação de pagamento. Status atual: "
                            + compra.getStatus());
        }

        compra.setStatus(StatusCompra.FINALIZADA);
    }
}

public void finalizarCompra(Long idCompra, Usuario usuario) {
    Compra compra = compraDao.buscarComLock(idCompra);

    new AuthorizationGuard().exigirPermissao(usuario, "COMPRA_FINALIZAR");
    new WorkflowCompra().finalizar(compra);

    compraDao.atualizar(compra);
}
```

### Exemplo em sistemas com telas Struts

Vulnerável:

```java
public ActionForward concluir(ActionMapping mapping, ActionForm form,
        HttpServletRequest request, HttpServletResponse response) throws Exception {

    Long id = Long.valueOf(request.getParameter("id"));
    service.concluir(id);
    return mapping.findForward("sucesso");
}
```

Seguro:

```java
public ActionForward concluir(ActionMapping mapping, ActionForm form,
        HttpServletRequest request, HttpServletResponse response) throws Exception {

    Usuario usuario = (Usuario) request.getSession().getAttribute("usuario");
    Long id = Long.valueOf(request.getParameter("id"));

    service.concluirEtapa(id, usuario, EtapaEsperada.PAGAMENTO_CONFIRMADO);
    return mapping.findForward("sucesso");
}
```

### Como revisar

```bash
grep -R "setStatus" -n src/
grep -R "FINALIZAD\|CONCLUID\|APROVAD\|CANCELAD" -n src/
grep -R "concluir\|finalizar\|aprovar\|confirmar" -n src/
```

### Regra prática

> O estado atual deve ser validado no backend antes de cada transição relevante.

---

## 5.18 CWE-1025 — Comparison Using Wrong Factors

### Descrição prática

A decisão é feita comparando atributos errados. Isso é comum em autorização, deduplicação, workflow e validação de propriedade.

### Exemplo vulnerável

```java
public boolean podeAlterar(Processo processo, Usuario usuario) {
    // Vulnerável: compara nome textual da unidade.
    return processo.getNomeUnidade().equals(usuario.getNomeUnidade());
}
```

Problemas:

- nome pode mudar;
- pode haver homônimos;
- acentos e caixa podem divergir;
- usuário pode pertencer a mais de uma unidade;
- regra de autorização deveria usar identificador canônico.

### Solução

```java
public boolean podeAlterar(Processo processo, Usuario usuario) {
    return usuario.getUnidadesAutorizadas().contains(processo.getCodUnidadeResponsavel());
}
```

Outro exemplo vulnerável:

```java
public boolean mesmoUsuario(Usuario usuario, String loginInformado) {
    return usuario.getLogin().equalsIgnoreCase(loginInformado);
}
```

Solução:

```java
public boolean mesmoUsuario(Usuario usuario, Long idUsuarioInformado) {
    return Objects.equals(usuario.getId(), idUsuarioInformado);
}
```

### Como revisar

```bash
grep -R "equalsIgnoreCase" -n src/
grep -R "getNome.*equals" -n src/
grep -R "getDescricao.*equals" -n src/
grep -R "getLogin.*equals" -n src/
```

### Regra prática

> Para segurança e workflow, compare identificadores canônicos, não nomes, descrições, labels ou dados controláveis pelo usuário.

---

## 5.19 CWE-1037 — Processor Optimization Removal or Modification of Security-critical Code

### Descrição prática

A otimização do processador, do runtime ou do JIT pode alterar a ordem, visibilidade ou execução esperada de código crítico. Em Java, a equivalência prática mais comum aparece em concorrência e visibilidade de memória.

### Exemplo vulnerável

```java
public class ServicoComFlag {
    private boolean ativo = true;

    public void parar() {
        ativo = false;
    }

    public void processarFila() {
        while (ativo) {
            processarProximoItem();
        }
    }
}
```

Sem `volatile`, sincronização ou `AtomicBoolean`, outra thread pode alterar `ativo`, mas a thread do loop pode não observar a mudança no momento esperado.

### Solução

```java
public class ServicoComFlag {
    private final AtomicBoolean ativo = new AtomicBoolean(true);

    public void parar() {
        ativo.set(false);
    }

    public void processarFila() {
        while (ativo.get()) {
            processarProximoItem();
        }
    }
}
```

Ou:

```java
public class ServicoComFlag {
    private volatile boolean ativo = true;

    public void parar() {
        ativo = false;
    }

    public void processarFila() {
        while (ativo) {
            processarProximoItem();
        }
    }
}
```

### Como revisar

```bash
grep -R "private boolean .*ativo\|private boolean .*running\|private boolean .*executando" -n src/
grep -R "while (.*ativo\|while (.*running\|while (.*executando" -n src/
grep -R "Thread" -n src/
grep -R "volatile\|AtomicBoolean" -n src/
```

### Regra prática

> Em código concorrente, não confie em visibilidade implícita. Use `volatile`, `Atomic*`, locks ou abstrações gerenciadas pelo container.

---

# 6. Padrões seguros reutilizáveis

## 6.1 Ordem segura de processamento de entrada

```java
public final class EntradaSegura {
    public Path resolverArquivoSeguro(String parametro, Path base) throws IOException {
        if (parametro == null || parametro.isBlank()) {
            throw new RequisicaoInvalidaException("Parâmetro obrigatório.");
        }

        String decodificado = URLDecoder.decode(parametro, StandardCharsets.UTF_8.name());
        Path baseReal = base.toRealPath();
        Path alvo = baseReal.resolve(decodificado).normalize();

        if (!alvo.startsWith(baseReal)) {
            throw new AcessoNegadoException("Caminho fora da base permitida.");
        }

        return alvo;
    }
}
```

Ordem:

1. validar presença mínima;
2. decodificar;
3. normalizar;
4. resolver contra base confiável;
5. validar pertencimento;
6. autorizar;
7. executar.

---

## 6.2 Redirect seguro em Servlet

```java
public final class WebResponseUtil {
    private WebResponseUtil() {
    }

    public static boolean redirecionarAcessoNegado(HttpServletResponse response) throws IOException {
        response.sendRedirect("/erro/403.jsp");
        return true;
    }
}
```

Uso:

```java
if (!usuario.possuiPermissao("ADMIN")) {
    WebResponseUtil.redirecionarAcessoNegado(response);
    return;
}
```

---

## 6.3 Proteção contra duplo envio

```java
public final class IdempotencyService {
    private final IdempotencyDao dao;

    public IdempotencyService(IdempotencyDao dao) {
        this.dao = dao;
    }

    public void registrarOuFalhar(String chave, String operacao) {
        if (chave == null || chave.isBlank()) {
            throw new RequisicaoInvalidaException("Chave de idempotência obrigatória.");
        }

        boolean inseriu = dao.tentarInserir(chave, operacao);
        if (!inseriu) {
            throw new RequisicaoInvalidaException("Operação já processada.");
        }
    }
}
```

Banco:

```sql
CREATE TABLE idempotency_key (
    chave VARCHAR(100) NOT NULL,
    operacao VARCHAR(100) NOT NULL,
    criado_em TIMESTAMP NOT NULL,
    CONSTRAINT pk_idempotency_key PRIMARY KEY (chave, operacao)
);
```

---

## 6.4 Workflow explícito

```java
public enum TransicaoProcesso {
    RASCUNHO_PARA_VALIDADO,
    VALIDADO_PARA_APROVADO,
    APROVADO_PARA_PUBLICADO,
    QUALQUER_PARA_CANCELADO
}

public final class WorkflowProcesso {
    public void aplicar(Processo processo, TransicaoProcesso transicao) {
        switch (transicao) {
            case RASCUNHO_PARA_VALIDADO:
                exigirStatus(processo, StatusProcesso.RASCUNHO);
                processo.setStatus(StatusProcesso.VALIDADO);
                break;
            case VALIDADO_PARA_APROVADO:
                exigirStatus(processo, StatusProcesso.VALIDADO);
                processo.setStatus(StatusProcesso.APROVADO);
                break;
            case APROVADO_PARA_PUBLICADO:
                exigirStatus(processo, StatusProcesso.APROVADO);
                processo.setStatus(StatusProcesso.PUBLICADO);
                break;
            case QUALQUER_PARA_CANCELADO:
                processo.setStatus(StatusProcesso.CANCELADO);
                break;
            default:
                throw new RequisicaoInvalidaException("Transição não suportada.");
        }
    }

    private void exigirStatus(Processo processo, StatusProcesso esperado) {
        if (processo.getStatus() != esperado) {
            throw new RequisicaoInvalidaException(
                    "Status inválido. Esperado: " + esperado + ", atual: " + processo.getStatus());
        }
    }
}
```

---

# 7. Checklist prático de revisão

## Entrada, parsing e canonicalização

- [ ] A entrada é decodificada antes da validação final?
- [ ] Path, URL e nome de arquivo são normalizados antes da autorização?
- [ ] Existe validação de charset, locale, timezone e formato?
- [ ] O sistema evita interpretar parâmetro externo como decisão de segurança?

## Fluxo web

- [ ] Todo `sendRedirect()` é seguido de `return` ou `throw`?
- [ ] Todo `sendError()` interrompe o fluxo?
- [ ] `forward()` não permite execução posterior perigosa?
- [ ] A regra crítica está no backend, não apenas na tela?

## Workflow

- [ ] Toda transição de estado valida o estado atual?
- [ ] É possível chamar a etapa final por URL direta?
- [ ] O backend impede pular etapas?
- [ ] Existe lock ou controle transacional para ações concorrentes?

## Operadores e blocos

- [ ] Todo `if`, `else`, `for`, `while` usa chaves?
- [ ] Todo `switch` possui `break`, `return`, `throw` ou `->`?
- [ ] Expressões com `&&` e `||` possuem parênteses ou variáveis intermediárias?
- [ ] Comparações usam `.equals()`/`Objects.equals()` em vez de `==` para objetos?

## Ambiente e versão

- [ ] O código não depende de charset padrão?
- [ ] Datas usam `java.time` e parsing estrito?
- [ ] Configurações de servidor/proxy estão documentadas?
- [ ] Testes cobrem atualização de Java, servidor e bibliotecas críticas?

## Ações únicas

- [ ] Operações de pagamento, guia, aprovação, cancelamento e assinatura têm idempotência?
- [ ] Há restrição única no banco quando necessário?
- [ ] Retry de integração não duplica registros?
- [ ] Duplo clique ou refresh não repete a ação crítica?

---

# 8. Comandos de busca úteis

```bash
# Redirect/forward sem parada explícita
grep -R "sendRedirect\|sendError\|forward(request, response)" -n src/

# Operadores perigosos
grep -R "== \"\|!= \"" -n src/
grep -R "&&.*||\|||.*&&" -n src/
grep -R " if (.* & .*\| if (.* | .*" -n src/

# Switch tradicional
grep -R "switch" -n src/
grep -R "case .*:" -n src/

# Path/arquivo/request
grep -R "new File(.*request\|Paths.get(.*request\|URLDecoder.decode" -n src/

# Loops suspeitos
grep -R "while (true)\|for (;;)" -n src/

# Workflow/status
grep -R "setStatus\|status =\|FINALIZAD\|CONCLUID\|APROVAD\|CANCELAD" -n src/

# Ações críticas
grep -R "gerar\|regerar\|confirmar\|aprovar\|cancelar\|excluir" -n src/
```

---

# 9. Testes sugeridos

## Teste para CWE-698 — Execution After Redirect

```java
@Test
void deveInterromperExecucaoQuandoUsuarioSemPermissao() throws Exception {
    Usuario usuario = new Usuario(1L, "operador", Set.of("CONSULTAR"));

    assertThrows(AcessoNegadoException.class, () -> service.excluir(10L, usuario));

    verify(dao, never()).excluir(anyLong());
}
```

## Teste para CWE-837 — ação única

```java
@Test
void deveReusarResultadoQuandoMesmaChaveIdempotenciaForEnviada() {
    Guia primeira = service.gerarGuiaSeguro(10L, "abc-123", usuario);
    Guia segunda = service.gerarGuiaSeguro(10L, "abc-123", usuario);

    assertEquals(primeira.getId(), segunda.getId());
    verify(projudiGateway, times(1)).gerarGuia(any());
}
```

## Teste para CWE-841 — workflow

```java
@Test
void naoDeveFinalizarCompraSemPagamentoConfirmado() {
    Compra compra = new Compra();
    compra.setStatus(StatusCompra.DADOS_VALIDADOS);

    assertThrows(RequisicaoInvalidaException.class,
            () -> new WorkflowCompra().finalizar(compra));
}
```

## Teste para CWE-551 — canonicalização antes da autorização

```java
@Test
void naoDevePermitirPathTraversalComDiretorioPublico() throws Exception {
    assertThrows(AcessoNegadoException.class,
            () -> service.baixar("publico/../privado/contrato.pdf", usuarioSemPermissao));
}
```

---

# 10. Resumo para prova

- **CWE-438** é categoria de problemas comportamentais dentro da view **CWE-699 — Software Development**.
- A categoria não deve ser usada diretamente para mapear vulnerabilidades reais; o mapeamento deve usar as CWEs Base/Class.
- O foco é comportamento incorreto: ordem errada, interpretação errada, fluxo errado, operador errado, loop sem saída, execução após redirect e workflow mal aplicado.
- **CWE-179** e **CWE-551** reforçam a ordem segura: normalizar/canonicalizar antes de validar e autorizar.
- **CWE-698** é muito importante em Java web: `sendRedirect()` não encerra o método.
- **CWE-837** exige proteção contra repetição de ação crítica por idempotência, lock ou restrição única.
- **CWE-841** exige que o backend imponha o workflow, não a tela.
- **CWE-444** envolve interpretação inconsistente de HTTP entre proxy, gateway, firewall e backend.
- **CWE-480**, **CWE-483**, **CWE-484** e **CWE-783** são erros de código simples, mas com grande impacto em segurança.
- **CWE-439**, **CWE-733** e **CWE-1037** lembram que ambiente, versão, otimização e concorrência podem alterar comportamento esperado.

---

# 11. Referências oficiais

- CWE-438 — Behavioral Problems: `https://cwe.mitre.org/data/definitions/438.html`
- CWE-115 — Misinterpretation of Input: `https://cwe.mitre.org/data/definitions/115.html`
- CWE-179 — Incorrect Behavior Order: Early Validation: `https://cwe.mitre.org/data/definitions/179.html`
- CWE-408 — Incorrect Behavior Order: Early Amplification: `https://cwe.mitre.org/data/definitions/408.html`
- CWE-437 — Incomplete Model of Endpoint Features: `https://cwe.mitre.org/data/definitions/437.html`
- CWE-439 — Behavioral Change in New Version or Environment: `https://cwe.mitre.org/data/definitions/439.html`
- CWE-440 — Expected Behavior Violation: `https://cwe.mitre.org/data/definitions/440.html`
- CWE-444 — Inconsistent Interpretation of HTTP Requests: `https://cwe.mitre.org/data/definitions/444.html`
- CWE-480 — Use of Incorrect Operator: `https://cwe.mitre.org/data/definitions/480.html`
- CWE-483 — Incorrect Block Delimitation: `https://cwe.mitre.org/data/definitions/483.html`
- CWE-484 — Omitted Break Statement in Switch: `https://cwe.mitre.org/data/definitions/484.html`
- CWE-551 — Authorization Before Parsing and Canonicalization: `https://cwe.mitre.org/data/definitions/551.html`
- CWE-698 — Execution After Redirect: `https://cwe.mitre.org/data/definitions/698.html`
- CWE-733 — Compiler Optimization Removal or Modification of Security-critical Code: `https://cwe.mitre.org/data/definitions/733.html`
- CWE-783 — Operator Precedence Logic Error: `https://cwe.mitre.org/data/definitions/783.html`
- CWE-835 — Loop with Unreachable Exit Condition: `https://cwe.mitre.org/data/definitions/835.html`
- CWE-837 — Improper Enforcement of a Single, Unique Action: `https://cwe.mitre.org/data/definitions/837.html`
- CWE-841 — Improper Enforcement of Behavioral Workflow: `https://cwe.mitre.org/data/definitions/841.html`
- CWE-1025 — Comparison Using Wrong Factors: `https://cwe.mitre.org/data/definitions/1025.html`
- CWE-1037 — Processor Optimization Removal or Modification of Security-critical Code: `https://cwe.mitre.org/data/definitions/1037.html`

