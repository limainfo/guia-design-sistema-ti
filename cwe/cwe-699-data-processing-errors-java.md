# CWE-699 — Software Development

## Category: Data Processing Errors — CWE-19

> **Objetivo:** apresentar uma documentação prática sobre erros de processamento de dados, com exemplos vulneráveis e corrigidos em **Java 8**, aplicáveis a sistemas web, APIs REST, Struts/Servlet/JSP, integrações, XML, regex, arquivos compactados, parâmetros HTTP e validação de entrada.

---

## 1. Visão geral

A categoria **CWE-19 — Data Processing Errors** agrupa fraquezas que surgem quando o software manipula, transforma, interpreta, valida, persiste ou encaminha dados de forma incorreta.

Essa categoria aparece com frequência em código que:

- recebe parâmetros HTTP;
- interpreta JSON, XML, CSV ou arquivos;
- normaliza nomes, e-mails, URLs e identificadores;
- processa upload;
- valida campos com regex;
- descompacta arquivos;
- redireciona usuários;
- combina dados de fontes diferentes;
- converte tipos;
- interpreta estruturas com delimitadores;
- confia em parâmetros “imutáveis” vindos do navegador;
- executa regras diferentes antes e depois da normalização.

## 2. Natureza da categoria

A **CWE-19** é uma **Category**. Ela organiza fraquezas relacionadas ao processamento de dados, mas não deve ser usada diretamente para mapear uma vulnerabilidade real. O mapeamento deve apontar para a CWE Base mais específica, como CWE-601 para open redirect, CWE-611 para XXE ou CWE-409 para bomba de descompressão.

## 3. CWEs abordadas

| CWE | Nome | Exemplo prático |
|---:|---|---|
| 130 | Improper Handling of Length Parameter Inconsistency | Tamanho informado diverge do tamanho real |
| 166 | Improper Handling of Missing Special Element | Delimitador obrigatório ausente |
| 167 | Improper Handling of Additional Special Element | Delimitador extra inesperado |
| 168 | Improper Handling of Inconsistent Special Elements | Delimitadores inconsistentes |
| 178 | Improper Handling of Case Sensitivity | Diferença entre maiúsculas/minúsculas altera regra |
| 182 | Collapse of Data into Unsafe Value | Normalização transforma valor seguro em perigoso |
| 186 | Overly Restrictive Regular Expression | Regex rejeita entradas válidas e induz contorno |
| 229 | Improper Handling of Values | Valor fora do domínio esperado |
| 233 | Improper Handling of Parameters | Parâmetro ausente, duplicado, extra ou conflitante |
| 237 | Improper Handling of Structural Elements | Estrutura de dados mal interpretada |
| 241 | Improper Handling of Unexpected Data Type | Tipo inesperado aceito ou convertido indevidamente |
| 409 | Improper Handling of Highly Compressed Data | ZIP bomb ou data amplification |
| 472 | External Control of Assumed-Immutable Web Parameter | Campo hidden ou select tratado como imutável |
| 601 | Open Redirect | Redirecionamento para domínio externo |
| 611 | XXE | XML com entidade externa |
| 624 | Executable Regular Expression Error | Regex executável/montada dinamicamente |
| 625 | Permissive Regular Expression | Regex permissiva demais |
| 776 | XML Entity Expansion | Billion Laughs / expansão recursiva de entidades |
| 1024 | Comparison of Incompatible Types | Comparação entre tipos incompatíveis |

---

# 4. Princípios práticos

## 4.1 Validar dado no ponto correto

A ordem segura costuma ser:

```text
receber bytes/parâmetros
→ impor tamanho máximo
→ normalizar/canonicalizar quando necessário
→ validar formato
→ validar tipo
→ validar domínio permitido
→ validar relação com usuário/tenant/contexto
→ autorizar
→ processar
```

Erro comum:

```text
validar antes de normalizar
```

Isso permite que um valor pareça seguro durante a validação e perigoso após transformação.

## 4.2 Não confiar na interface

Qualquer valor vindo do navegador pode ser alterado:

- campo hidden;
- select;
- checkbox;
- radio;
- parâmetro de query string;
- cookie;
- header;
- rota;
- JSON;
- multipart;
- nome de arquivo.

## 4.3 Regex não substitui parser

Regex é útil para formatos simples. Para estruturas como URL, XML, JSON, CSV, path e e-mail, prefira parser específico e validação semântica.

## 4.4 Normalização precisa ser explícita

Exemplos de normalização:

- `trim`;
- remoção de espaços invisíveis;
- normalização Unicode;
- lowercase com `Locale.ROOT`;
- canonicalização de path;
- normalização de URL;
- decodificação de percent-encoding;
- tratamento de acentos;
- padronização de CPF/CNPJ/telefone.

A regra importante é: validar o mesmo valor que será usado.

---

# 5. CWE-130 — Improper Handling of Length Parameter Inconsistency

## 5.1 Conceito

O sistema recebe um tamanho declarado e um conteúdo real, mas não verifica se são consistentes.

## 5.2 Exemplo vulnerável

```java
public void processarArquivo(
        InputStream input,
        int tamanhoDeclarado)
        throws IOException {

    byte[] buffer = new byte[tamanhoDeclarado];

    int lidos = input.read(buffer);

    arquivoService.salvar(buffer);
}
```

Problemas:

- `read` pode ler menos bytes;
- `tamanhoDeclarado` pode ser enorme;
- o tamanho real pode divergir;
- a aplicação pode salvar lixo, truncar ou consumir memória excessiva.

## 5.3 Solução

```java
public byte[] lerComTamanhoMaximo(
        InputStream input,
        int tamanhoDeclarado,
        int maximoPermitido)
        throws IOException {

    if (tamanhoDeclarado < 0
            || tamanhoDeclarado > maximoPermitido) {
        throw new IllegalArgumentException(
            "Tamanho inválido"
        );
    }

    ByteArrayOutputStream output =
        new ByteArrayOutputStream();

    byte[] buffer = new byte[8192];
    int total = 0;
    int lidos;

    while ((lidos = input.read(buffer)) != -1) {
        total += lidos;

        if (total > maximoPermitido) {
            throw new IOException(
                "Arquivo excede tamanho máximo"
            );
        }

        output.write(buffer, 0, lidos);
    }

    if (total != tamanhoDeclarado) {
        throw new IOException(
            "Tamanho declarado difere do tamanho real"
        );
    }

    return output.toByteArray();
}
```

## 5.4 Revisão

Procurar por:

```bash
grep -RniE 'Content-Length|length|tamanho|read\(.*byte\[\]' src/
```

---

# 6. CWE-166 — Improper Handling of Missing Special Element

## 6.1 Conceito

Um elemento especial esperado está ausente, mas o código continua processando como se ele existisse.

Exemplos:

- token sem separador;
- linha CSV sem todas as colunas;
- header sem prefixo;
- `Authorization` sem `Bearer `;
- nome de arquivo sem extensão obrigatória;
- parâmetro composto sem delimitador.

## 6.2 Exemplo vulnerável

```java
public String extrairToken(String authorization) {
    return authorization.substring("Bearer ".length());
}
```

Se o header não começar com `Bearer `, o resultado será incorreto.

## 6.3 Solução

```java
public String extrairBearerToken(String authorization) {
    if (authorization == null) {
        throw new AuthenticationException(
            "Authorization ausente"
        );
    }

    String prefix = "Bearer ";

    if (!authorization.startsWith(prefix)) {
        throw new AuthenticationException(
            "Tipo de autorização inválido"
        );
    }

    String token = authorization.substring(prefix.length());

    if (token.trim().isEmpty()) {
        throw new AuthenticationException(
            "Token vazio"
        );
    }

    return token;
}
```

---

# 7. CWE-167 — Improper Handling of Additional Special Element

## 7.1 Conceito

O sistema aceita elementos especiais adicionais inesperados.

Exemplos:

- `usuario|perfil|extra`;
- `nome=valor=outro`;
- path com separador adicional;
- token com pontos extras;
- campo CSV contendo separadores não tratados.

## 7.2 Exemplo vulnerável

```java
public Credencial parse(String value) {
    String[] parts = value.split(":");

    return new Credencial(
        parts[0],
        parts[1]
    );
}
```

Entrada:

```text
usuario:senha:ADMIN
```

O código ignora ou interpreta incorretamente a parte extra.

## 7.3 Solução

```java
public Credencial parse(String value) {
    if (value == null) {
        throw new IllegalArgumentException(
            "Credencial ausente"
        );
    }

    String[] parts = value.split(":", -1);

    if (parts.length != 2) {
        throw new IllegalArgumentException(
            "Formato de credencial inválido"
        );
    }

    if (parts[0].trim().isEmpty()
            || parts[1].isEmpty()) {
        throw new IllegalArgumentException(
            "Credencial incompleta"
        );
    }

    return new Credencial(
        parts[0],
        parts[1]
    );
}
```

---

# 8. CWE-168 — Improper Handling of Inconsistent Special Elements

## 8.1 Conceito

O sistema aceita elementos especiais inconsistentes ou conflitantes.

Exemplos:

- aspas abertas e não fechadas;
- parênteses desbalanceados;
- JSON com chaves duplicadas;
- CSV com quantidade variável de colunas;
- URL com encoding duplo;
- delimitadores misturados.

## 8.2 Exemplo vulnerável

```java
public Map<String, String> parseParametros(String texto) {
    Map<String, String> mapa = new HashMap<String, String>();

    for (String item : texto.split("&")) {
        String[] parts = item.split("=");

        mapa.put(parts[0], parts[1]);
    }

    return mapa;
}
```

Problemas:

- `a=b=c`;
- `a`;
- `a=`;
- `a=1&a=2`;
- percent-encoding;
- duplicidade.

## 8.3 Solução

Usar parser apropriado para query string. Quando não houver, validar estritamente:

```java
public Map<String, String> parseParametros(String texto) {
    Map<String, String> mapa =
        new LinkedHashMap<String, String>();

    if (texto == null || texto.length() > 4096) {
        throw new IllegalArgumentException(
            "Parâmetros inválidos"
        );
    }

    for (String item : texto.split("&", -1)) {
        String[] parts = item.split("=", -1);

        if (parts.length != 2) {
            throw new IllegalArgumentException(
                "Parâmetro malformado"
            );
        }

        String chave = urlDecode(parts[0]);
        String valor = urlDecode(parts[1]);

        if (mapa.containsKey(chave)) {
            throw new IllegalArgumentException(
                "Parâmetro duplicado: " + chave
            );
        }

        mapa.put(chave, valor);
    }

    return mapa;
}
```

---

# 9. CWE-178 — Improper Handling of Case Sensitivity

## 9.1 Conceito

A aplicação falha ao tratar diferenças de maiúsculas/minúsculas.

Exemplos:

- `ADMIN`, `Admin`, `admin`;
- extensão `.JSP`;
- hostname em URL;
- e-mail;
- login;
- nomes de roles;
- cabeçalhos HTTP.

## 9.2 Exemplo vulnerável

```java
public boolean extensaoPermitida(String nomeArquivo) {
    return nomeArquivo.endsWith(".pdf");
}
```

`documento.PDF` pode ser rejeitado indevidamente, ou o inverso pode permitir bypass em outros contextos.

## 9.3 Solução

```java
public boolean extensaoPermitida(String nomeArquivo) {
    if (nomeArquivo == null) {
        return false;
    }

    String normalizado =
        nomeArquivo.toLowerCase(Locale.ROOT);

    return normalizado.endsWith(".pdf");
}
```

Para roles:

```java
Role role = Role.valueOf(
    valor.trim().toUpperCase(Locale.ROOT)
);
```

Melhor ainda: não receber role do cliente para decisão de segurança.

---

# 10. CWE-182 — Collapse of Data into Unsafe Value

## 10.1 Conceito

Uma transformação reduz vários valores diferentes para um mesmo valor inseguro.

Exemplos:

- normalizar Unicode de forma que dois logins diferentes colidam;
- remover caracteres especiais e transformar valor proibido em permitido;
- truncar identificador;
- converter para lowercase e misturar contas;
- remover path separators;
- remover acentos para decisão de identidade.

## 10.2 Exemplo vulnerável

```java
public String normalizarLogin(String login) {
    return login
        .replace(".", "")
        .replace("-", "")
        .toLowerCase(Locale.ROOT);
}
```

Entradas diferentes podem colapsar:

```text
joao.silva
joaosilva
joao-silva
```

## 10.3 Solução

Definir uma política única de identidade:

```java
public String normalizarLoginParaBusca(String login) {
    if (login == null) {
        throw new IllegalArgumentException(
            "Login obrigatório"
        );
    }

    String normalizado =
        login.trim().toLowerCase(Locale.ROOT);

    if (!normalizado.matches("[a-z0-9._-]{3,64}")) {
        throw new IllegalArgumentException(
            "Login possui formato inválido"
        );
    }

    return normalizado;
}
```

E aplicar constraint única no banco sobre a forma normalizada.

---

# 11. CWE-186 — Overly Restrictive Regular Expression

## 11.1 Conceito

A regex é restritiva demais e rejeita valores legítimos. Isso pode gerar:

- exclusão indevida de usuários;
- falhas operacionais;
- contornos inseguros;
- criação de fluxos alternativos;
- validação duplicada divergente.

## 11.2 Exemplo vulnerável

```java
public boolean emailValido(String email) {
    return email.matches(
        "[a-z]+@[a-z]+\\.com"
    );
}
```

Rejeita e-mails válidos como:

```text
joao.silva@empresa.com.br
user+tag@example.org
```

## 11.3 Solução

Para e-mail, muitas vezes basta uma validação operacional simples e confirmação por envio:

```java
public boolean emailAceitavel(String email) {
    if (email == null) {
        return false;
    }

    String value = email.trim();

    if (value.length() < 3 || value.length() > 254) {
        return false;
    }

    return value.contains("@")
        && !value.startsWith("@")
        && !value.endsWith("@");
}
```

Depois:

- enviar link de confirmação;
- normalizar domínio;
- não usar e-mail não confirmado para ações críticas.

---

# 12. CWE-229 — Improper Handling of Values

## 12.1 Conceito

O sistema não trata valores fora do domínio esperado.

Exemplos:

- quantidade negativa;
- data final anterior à inicial;
- valor monetário com escala indevida;
- enum desconhecido;
- status inválido;
- ano fora de faixa;
- valor muito grande;
- `NaN` ou infinito em número decimal;
- CPF com máscara inesperada.

## 12.2 Exemplo vulnerável

```java
public void atualizarQuantidade(
        Long itemId,
        int quantidade) {

    estoqueDAO.atualizar(
        itemId,
        quantidade
    );
}
```

Permite quantidade negativa.

## 12.3 Solução

```java
public void atualizarQuantidade(
        Long itemId,
        int quantidade) {

    if (itemId == null || itemId <= 0) {
        throw new IllegalArgumentException(
            "Item inválido"
        );
    }

    if (quantidade < 0 || quantidade > 10_000) {
        throw new IllegalArgumentException(
            "Quantidade fora da faixa permitida"
        );
    }

    estoqueDAO.atualizar(
        itemId,
        quantidade
    );
}
```

---

# 13. CWE-233 — Improper Handling of Parameters

## 13.1 Conceito

Parâmetros são tratados de forma incorreta.

Exemplos:

- parâmetro obrigatório ausente;
- parâmetro duplicado;
- parâmetro extra altera comportamento;
- dois parâmetros conflitantes;
- `id` no path e no body divergentes;
- parâmetro opcional vira default inseguro;
- array enviado onde se espera valor único.

## 13.2 Exemplo vulnerável

```java
public void alterarUsuario(
        Long pathId,
        UsuarioDTO dto) {

    usuarioDAO.atualizar(
        dto.getId(),
        dto
    );
}
```

O path indica um usuário, mas o body pode indicar outro.

## 13.3 Solução

```java
public void alterarUsuario(
        Long pathId,
        UsuarioDTO dto) {

    if (pathId == null || dto == null) {
        throw new IllegalArgumentException(
            "Dados obrigatórios"
        );
    }

    if (dto.getId() != null
            && !pathId.equals(dto.getId())) {
        throw new IllegalArgumentException(
            "ID do path difere do ID do body"
        );
    }

    usuarioDAO.atualizar(
        pathId,
        dto
    );
}
```

## 13.4 Duplicidade HTTP

```java
String[] valores =
    request.getParameterValues("perfil");

if (valores == null || valores.length != 1) {
    throw new IllegalArgumentException(
        "Parâmetro perfil deve aparecer uma única vez"
    );
}
```

---

# 14. CWE-237 — Improper Handling of Structural Elements

## 14.1 Conceito

A aplicação interpreta mal elementos estruturais de um formato.

Exemplos:

- CSV com aspas;
- JSON com arrays/objetos inesperados;
- XML com namespace;
- path com `../`;
- URL com usuário/senha/host/porta;
- multipart com nome de arquivo malformado;
- logs com quebras de linha;
- SQL montado manualmente.

## 14.2 Exemplo vulnerável: CSV com split simples

```java
public Pessoa parseLinha(String linha) {
    String[] colunas = linha.split(",");

    return new Pessoa(
        colunas[0],
        colunas[1]
    );
}
```

Falha para:

```csv
"Silva, João",123
```

## 14.3 Solução

Usar biblioteca de CSV com suporte a aspas, escapes e quantidade de colunas.

Exemplo conceitual:

```java
public Pessoa parseLinha(CsvRecord record) {
    if (record.size() != 2) {
        throw new IllegalArgumentException(
            "Quantidade de colunas inválida"
        );
    }

    return new Pessoa(
        record.get(0),
        record.get(1)
    );
}
```

Para path:

```java
Path base = Paths.get("/dados/upload")
    .toRealPath();

Path destino = base.resolve(nomeArquivo)
    .normalize();

if (!destino.startsWith(base)) {
    throw new SecurityException(
        "Caminho fora do diretório permitido"
    );
}
```

---

# 15. CWE-241 — Improper Handling of Unexpected Data Type

## 15.1 Conceito

O sistema recebe um tipo diferente do esperado e processa mesmo assim.

Exemplos:

- JSON espera string, recebe array;
- espera número, recebe objeto;
- espera boolean, recebe `"true"`;
- espera lista pequena, recebe lista gigante;
- `Map<String,Object>` aceita qualquer coisa;
- cast tardio gera comportamento parcial.

## 15.2 Exemplo vulnerável

```java
public void processar(Map<String, Object> json) {
    String perfil = json.get("perfil").toString();

    if ("ADMIN".equals(perfil)) {
        concederAdmin();
    }
}
```

Se `perfil` for array, objeto ou valor inesperado, a conversão pode gerar comportamento imprevisível.

## 15.3 Solução com DTO tipado

```java
public final class AlteracaoPerfilRequest {

    private String perfil;

    public String getPerfil() {
        return perfil;
    }

    public void setPerfil(String perfil) {
        this.perfil = perfil;
    }
}
```

Validação:

```java
public Perfil parsePerfil(String valor) {
    if (valor == null) {
        throw new IllegalArgumentException(
            "Perfil obrigatório"
        );
    }

    try {
        return Perfil.valueOf(
            valor.trim().toUpperCase(Locale.ROOT)
        );
    } catch (IllegalArgumentException e) {
        throw new IllegalArgumentException(
            "Perfil inválido"
        );
    }
}
```

---

# 16. CWE-409 — Improper Handling of Highly Compressed Data

## 16.1 Conceito

O sistema descompacta entrada altamente comprimida sem impor limites.

Exemplo clássico:

```text
ZIP bomb
```

Um arquivo pequeno pode expandir para gigabytes.

## 16.2 Exemplo vulnerável

```java
public void extrairZip(Path zip, Path destino)
        throws IOException {

    try (ZipInputStream zin =
            new ZipInputStream(
                Files.newInputStream(zip))) {

        ZipEntry entry;

        while ((entry = zin.getNextEntry()) != null) {
            Path arquivo =
                destino.resolve(entry.getName());

            Files.copy(
                zin,
                arquivo,
                StandardCopyOption.REPLACE_EXISTING
            );
        }
    }
}
```

Problemas:

- sem limite de tamanho total;
- sem limite por arquivo;
- sem limite de quantidade;
- sem validação de path;
- risco de Zip Slip;
- risco de consumo de disco e CPU.

## 16.3 Solução

```java
public void extrairZipSeguro(
        Path zip,
        Path destino)
        throws IOException {

    final long maxTotal = 100L * 1024L * 1024L;
    final long maxArquivo = 20L * 1024L * 1024L;
    final int maxEntradas = 1000;

    Path base = destino.toRealPath();

    long total = 0;
    int entradas = 0;

    try (ZipInputStream zin =
            new ZipInputStream(
                Files.newInputStream(zip))) {

        ZipEntry entry;

        byte[] buffer = new byte[8192];

        while ((entry = zin.getNextEntry()) != null) {
            entradas++;

            if (entradas > maxEntradas) {
                throw new IOException(
                    "ZIP possui entradas demais"
                );
            }

            Path arquivo = base
                .resolve(entry.getName())
                .normalize();

            if (!arquivo.startsWith(base)) {
                throw new SecurityException(
                    "Entrada ZIP fora do destino"
                );
            }

            if (entry.isDirectory()) {
                Files.createDirectories(arquivo);
                continue;
            }

            Files.createDirectories(
                arquivo.getParent()
            );

            long totalArquivo = 0;

            try (OutputStream out =
                    Files.newOutputStream(arquivo)) {

                int lidos;

                while ((lidos = zin.read(buffer)) != -1) {
                    totalArquivo += lidos;
                    total += lidos;

                    if (totalArquivo > maxArquivo) {
                        throw new IOException(
                            "Arquivo interno excede limite"
                        );
                    }

                    if (total > maxTotal) {
                        throw new IOException(
                            "ZIP excede limite total"
                        );
                    }

                    out.write(buffer, 0, lidos);
                }
            }
        }
    }
}
```

---

# 17. CWE-472 — External Control of Assumed-Immutable Web Parameter

## 17.1 Conceito

A aplicação assume que determinado parâmetro web não pode ser alterado pelo usuário, mas ele pode.

Exemplos:

- `<input type="hidden" name="preco">`;
- `<input type="hidden" name="perfil">`;
- select com opções restritas no HTML;
- checkbox que controla autorização;
- parâmetro `isAdmin=false`;
- campo hidden com `codUnidade`;
- parâmetro de workflow.

## 17.2 Exemplo vulnerável

```jsp
<input type="hidden" name="valor" value="${produto.valor}">
<input type="hidden" name="produtoId" value="${produto.id}">
```

```java
BigDecimal valor =
    new BigDecimal(
        request.getParameter("valor")
    );

pedidoService.comprar(
    produtoId,
    valor
);
```

O usuário pode alterar o valor.

## 17.3 Solução

```java
public void comprar(
        AuthenticatedPrincipal principal,
        Long produtoId,
        int quantidade) {

    Produto produto =
        produtoDAO.findAtivo(produtoId)
            .orElseThrow(
                NotFoundException::new
            );

    BigDecimal valorOficial =
        produto.getValor();

    pedidoService.comprar(
        principal.getUserId(),
        produto.getId(),
        quantidade,
        valorOficial
    );
}
```

Se precisar preservar estado entre telas:

- usar sessão servidor;
- token assinado;
- idempotency key;
- refazer consulta no servidor;
- validar workflow;
- não confiar em hidden como autoridade.

---

# 18. CWE-601 — URL Redirection to Untrusted Site

## 18.1 Conceito

A aplicação redireciona o usuário para URL controlada pelo atacante.

## 18.2 Exemplo vulnerável

```java
public void login(
        HttpServletRequest request,
        HttpServletResponse response)
        throws IOException {

    String redirect =
        request.getParameter("redirect");

    autenticar(request);

    response.sendRedirect(redirect);
}
```

Ataque:

```text
/login?redirect=https://site-falso.example/phishing
```

## 18.3 Solução: permitir apenas caminhos internos

```java
public String validarRedirectInterno(
        String redirect) {

    if (redirect == null || redirect.isEmpty()) {
        return "/home";
    }

    if (!redirect.startsWith("/")) {
        return "/home";
    }

    if (redirect.startsWith("//")) {
        return "/home";
    }

    if (redirect.contains("\r")
            || redirect.contains("\n")) {
        return "/home";
    }

    URI uri = URI.create(redirect);

    if (uri.isAbsolute()
            || uri.getHost() != null) {
        return "/home";
    }

    return redirect;
}
```

Uso:

```java
response.sendRedirect(
    request.getContextPath()
    + validarRedirectInterno(redirect)
);
```

## 18.4 Alternativa: IDs de destino

```java
Map<String, String> destinos =
    new HashMap<String, String>();

destinos.put("home", "/home");
destinos.put("perfil", "/usuario/perfil");

String destino =
    destinos.getOrDefault(
        request.getParameter("destino"),
        "/home"
    );
```

---

# 19. CWE-611 — Improper Restriction of XML External Entity Reference

## 19.1 Conceito

O parser XML permite entidades externas que acessam recursos fora da esfera pretendida.

Riscos:

- leitura de arquivo local;
- SSRF;
- vazamento de segredo;
- varredura de rede interna;
- negação de serviço;
- inclusão de conteúdo indevido.

## 19.2 XML malicioso

```xml
<?xml version="1.0"?>
<!DOCTYPE data [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<data>&xxe;</data>
```

## 19.3 Exemplo vulnerável

```java
DocumentBuilderFactory factory =
    DocumentBuilderFactory.newInstance();

DocumentBuilder builder =
    factory.newDocumentBuilder();

Document document =
    builder.parse(inputStream);
```

## 19.4 Solução

```java
public Document parseXmlSeguro(InputStream input)
        throws Exception {

    DocumentBuilderFactory factory =
        DocumentBuilderFactory.newInstance();

    factory.setFeature(
        "http://apache.org/xml/features/disallow-doctype-decl",
        true
    );

    factory.setFeature(
        "http://xml.org/sax/features/external-general-entities",
        false
    );

    factory.setFeature(
        "http://xml.org/sax/features/external-parameter-entities",
        false
    );

    factory.setFeature(
        "http://apache.org/xml/features/nonvalidating/load-external-dtd",
        false
    );

    factory.setXIncludeAware(false);
    factory.setExpandEntityReferences(false);

    DocumentBuilder builder =
        factory.newDocumentBuilder();

    builder.setEntityResolver(
        (publicId, systemId) ->
            new InputSource(
                new StringReader("")
            )
    );

    return builder.parse(input);
}
```

## 19.5 Observações

- testar a configuração no parser real usado em produção;
- evitar XML quando não necessário;
- desabilitar DTD quando possível;
- impor limites de tamanho;
- validar schema local e controlado;
- não permitir busca de schema remoto pelo documento recebido.

---

# 20. CWE-624 — Executable Regular Expression Error

## 20.1 Conceito

O sistema usa regex construída ou executada de forma insegura, especialmente quando parte da expressão vem de entrada externa.

## 20.2 Exemplo vulnerável

```java
public List<String> buscar(
        List<String> nomes,
        String filtro) {

    Pattern pattern =
        Pattern.compile(filtro);

    return nomes.stream()
        .filter(n -> pattern.matcher(n).find())
        .collect(Collectors.toList());
}
```

O usuário controla a regex.

Problemas:

- exceções;
- ReDoS;
- busca semântica diferente da esperada;
- uso de metacaracteres;
- comportamento caro em CPU.

## 20.3 Solução: tratar entrada como texto literal

```java
public List<String> buscar(
        List<String> nomes,
        String filtro) {

    if (filtro == null || filtro.length() > 100) {
        throw new IllegalArgumentException(
            "Filtro inválido"
        );
    }

    Pattern pattern =
        Pattern.compile(
            Pattern.quote(filtro),
            Pattern.CASE_INSENSITIVE
        );

    List<String> resultado =
        new ArrayList<String>();

    for (String nome : nomes) {
        if (pattern.matcher(nome).find()) {
            resultado.add(nome);
        }
    }

    return resultado;
}
```

Quando regex avançada for requisito:

- usar timeout ou engine segura;
- limitar tamanho;
- revisar padrões perigosos;
- bloquear backtracking catastrófico;
- compilar em ambiente controlado;
- capturar `PatternSyntaxException`.

---

# 21. CWE-625 — Permissive Regular Expression

## 21.1 Conceito

A regex é permissiva demais e aceita valores inválidos.

## 21.2 Exemplo vulnerável

```java
public boolean arquivoPermitido(String nome) {
    return nome.matches(".*\\.pdf.*");
}
```

Aceita:

```text
arquivo.pdf.exe
```

## 21.3 Solução

```java
public boolean arquivoPermitido(String nome) {
    if (nome == null) {
        return false;
    }

    String normalizado =
        nome.trim().toLowerCase(Locale.ROOT);

    return normalizado.matches(
        "^[a-z0-9._-]{1,100}\\.pdf$"
    );
}
```

Ainda assim:

- validar MIME real quando aplicável;
- armazenar com nome gerado pelo servidor;
- não executar arquivo enviado;
- verificar tamanho;
- remover path;
- restringir diretório.

---

# 22. CWE-776 — Improper Restriction of Recursive Entity References in DTDs

## 22.1 Conceito

O parser permite entidades recursivas ou expansões massivas em DTD.

Exemplo clássico:

```xml
<!DOCTYPE lolz [
 <!ENTITY lol "lol">
 <!ENTITY lol1 "&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;&lol;">
 <!ENTITY lol2 "&lol1;&lol1;&lol1;&lol1;&lol1;&lol1;&lol1;&lol1;&lol1;&lol1;">
]>
<root>&lol2;</root>
```

Isso pode consumir CPU e memória.

## 22.2 Exemplo vulnerável

O mesmo parser XML vulnerável da CWE-611 também pode permitir expansão de entidades:

```java
DocumentBuilderFactory factory =
    DocumentBuilderFactory.newInstance();

DocumentBuilder builder =
    factory.newDocumentBuilder();

builder.parse(input);
```

## 22.3 Solução

Desabilitar DTD e entidades:

```java
factory.setFeature(
    "http://apache.org/xml/features/disallow-doctype-decl",
    true
);

factory.setExpandEntityReferences(false);
```

Adicionar limites operacionais:

```java
System.setProperty(
    "jdk.xml.entityExpansionLimit",
    "0"
);
```

Em produção, prefira configurar limites no runtime/application server e validar que o parser respeita as propriedades usadas.

---

# 23. CWE-1024 — Comparison of Incompatible Types

## 23.1 Conceito

O sistema compara objetos ou valores de tipos incompatíveis.

Exemplos:

- `Long` com `String`;
- `BigDecimal` com `double`;
- data como texto;
- enum com código numérico sem conversão;
- CPF formatado com CPF sem máscara;
- `Integer` com `Long` dentro de `Map`;
- IDs de domínios diferentes.

## 23.2 Exemplo vulnerável

```java
Long perfilId = usuario.getPerfilId();
String perfilAdmin = "1";

if (perfilId.equals(perfilAdmin)) {
    concederAdmin();
}
```

A comparação sempre falha, ou o código pode receber correções improvisadas inseguras.

## 23.3 Exemplo com `BigDecimal`

```java
BigDecimal valor =
    new BigDecimal("10.0");

if (valor.equals(
        new BigDecimal("10.00"))) {
    aplicarRegra();
}
```

`equals` considera escala; `compareTo` compara valor numérico.

## 23.4 Solução

```java
if (valor.compareTo(
        new BigDecimal("10.00")) == 0) {
    aplicarRegra();
}
```

Para perfil:

```java
Perfil perfil =
    Perfil.fromCodigo(
        usuario.getPerfilId()
    );

if (Perfil.ADMIN.equals(perfil)) {
    concederAdmin();
}
```

---

# 24. Componentes reutilizáveis

## 24.1 Validador de parâmetro único

```java
public final class RequestParamValidator {

    private RequestParamValidator() {
    }

    public static String requiredSingle(
            HttpServletRequest request,
            String name) {

        String[] values =
            request.getParameterValues(name);

        if (values == null || values.length != 1) {
            throw new IllegalArgumentException(
                "Parâmetro inválido: " + name
            );
        }

        String value = values[0];

        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(
                "Parâmetro obrigatório: " + name
            );
        }

        return value;
    }
}
```

## 24.2 Parser de inteiro com faixa

```java
public static int parseIntRange(
        String value,
        int min,
        int max,
        String fieldName) {

    try {
        int parsed = Integer.parseInt(value);

        if (parsed < min || parsed > max) {
            throw new IllegalArgumentException(
                fieldName + " fora da faixa"
            );
        }

        return parsed;
    } catch (NumberFormatException e) {
        throw new IllegalArgumentException(
            fieldName + " inválido"
        );
    }
}
```

## 24.3 Normalização segura de enum

```java
public static <E extends Enum<E>> E parseEnum(
        Class<E> type,
        String value,
        String fieldName) {

    if (value == null) {
        throw new IllegalArgumentException(
            fieldName + " obrigatório"
        );
    }

    try {
        return Enum.valueOf(
            type,
            value.trim().toUpperCase(Locale.ROOT)
        );
    } catch (IllegalArgumentException e) {
        throw new IllegalArgumentException(
            fieldName + " inválido"
        );
    }
}
```

---

# 25. Diferenças importantes

## 25.1 CWE-186 versus CWE-625

| Situação | CWE |
|---|---:|
| Regex rejeita valores legítimos | 186 |
| Regex aceita valores perigosos | 625 |
| Regex controlada pelo usuário | 624 |
| Regex causa consumo excessivo | 1333, quando foco é complexidade |

## 25.2 CWE-611 versus CWE-776

| Situação | CWE |
|---|---:|
| XML acessa entidade externa | 611 |
| XML expande entidades recursivas/massivas | 776 |
| As duas ocorrem no mesmo parser | mapear a causa mais específica ou ambas, conforme análise |

## 25.3 CWE-472 versus CWE-233

| Situação | CWE |
|---|---:|
| Hidden/select tratado como imutável | 472 |
| Parâmetro ausente, duplicado ou conflitante | 233 |

## 25.4 CWE-130 versus CWE-409

| Situação | CWE |
|---|---:|
| Tamanho declarado difere do real | 130 |
| Conteúdo compactado expande demais | 409 |

---

# 26. Checklist de revisão

## 26.1 Parâmetros

- Parâmetros obrigatórios são validados?
- Parâmetros duplicados são rejeitados?
- IDs no path e body são consistentes?
- Campos hidden são revalidados no servidor?
- Defaults são seguros?
- Valores extras são rejeitados?
- Há limite de tamanho?

## 26.2 Estrutura

- CSV é parseado com biblioteca adequada?
- JSON rejeita campos desconhecidos quando necessário?
- XML desabilita DTD e entidades externas?
- Paths são canonicalizados?
- URLs são parseadas por `URI`/`URL`, não por regex simples?
- Formatos compostos validam delimitadores?

## 26.3 Valores

- Valores negativos são tratados?
- Datas possuem ordem válida?
- Números possuem faixa e escala?
- Enums rejeitam valores desconhecidos?
- Tipos inesperados são rejeitados?
- Comparações usam tipos compatíveis?

## 26.4 Regex

- Regex é ancorada com `^` e `$` quando necessário?
- Entrada do usuário é escapada com `Pattern.quote`?
- Há limite de tamanho antes de aplicar regex?
- Regex é permissiva demais?
- Regex é restritiva demais?
- Há risco de backtracking catastrófico?

## 26.5 Compressão e upload

- Há limite total de expansão?
- Há limite por arquivo?
- Há limite de entradas?
- Há validação contra Zip Slip?
- Arquivos são gravados fora do webroot?
- Nome final é gerado pelo servidor?
- MIME/tipo real é validado quando necessário?

## 26.6 Redirecionamento

- URLs externas são proibidas por padrão?
- Redirect usa allowlist?
- Caminhos iniciados com `//` são rejeitados?
- CRLF é rejeitado?
- Há mapeamento por ID em vez de URL livre?

---

# 27. Comandos de busca no código

## 27.1 Parâmetros HTTP

```bash
grep -RniE 'getParameter|getParameterValues|getHeader|getCookies' src/
```

## 27.2 Redirect

```bash
grep -RniE 'sendRedirect|redirect:|ActionRedirect' src/
```

## 27.3 XML

```bash
grep -RniE 'DocumentBuilderFactory|SAXParserFactory|XMLInputFactory|TransformerFactory' src/
```

## 27.4 ZIP e compactação

```bash
grep -RniE 'ZipInputStream|ZipFile|GZIPInputStream|InflaterInputStream' src/
```

## 27.5 Regex

```bash
grep -RniE 'Pattern\.compile|\.matches\(|\.replaceAll\(|\.split\(' src/
```

## 27.6 Comparações suspeitas

```bash
grep -RniE '\.equals\(|compareTo\(|BigDecimal|Enum\.valueOf' src/
```

## 27.7 Campos hidden

```bash
grep -RniE '<input[^>]+type="hidden"' src/main/webapp/ web/
```

---

# 28. Testes sugeridos

## 28.1 Parâmetros

1. Enviar parâmetro obrigatório ausente.
2. Enviar parâmetro duplicado.
3. Enviar `id` diferente no path e body.
4. Alterar campo hidden.
5. Enviar valor negativo.
6. Enviar valor acima do limite.
7. Enviar enum inválido.
8. Enviar tipo JSON inesperado.
9. Enviar string muito longa.
10. Enviar campos extras.

## 28.2 Regex

1. Valor válido comum.
2. Valor válido com acento.
3. Valor válido com hífen/ponto.
4. Valor com metacaracteres.
5. Valor muito longo.
6. Valor que explora backtracking.
7. Valor com extensão dupla.
8. Valor com case diferente.
9. Valor com espaços invisíveis.
10. Valor vazio.

## 28.3 XML

1. XML normal.
2. XML com DOCTYPE.
3. XML com entidade externa `file://`.
4. XML com entidade HTTP.
5. XML com entidade recursiva.
6. XML grande.
7. XML com namespace.
8. XML malformado.
9. XML com schema remoto.
10. XML com encoding inesperado.

## 28.4 ZIP

1. ZIP normal.
2. ZIP com muitos arquivos.
3. ZIP com arquivo muito grande.
4. ZIP com expansão total grande.
5. ZIP com `../`.
6. ZIP com path absoluto.
7. ZIP vazio.
8. ZIP corrompido.
9. ZIP aninhado.
10. ZIP com nomes duplicados.

## 28.5 Redirect

1. `/home`.
2. `home`.
3. `https://externo`.
4. `//externo`.
5. `/%2F%2Fexterno`.
6. caminho com CRLF.
7. caminho vazio.
8. destino por ID válido.
9. destino por ID inválido.
10. redirect após login/logout.

---

# 29. Exemplos de testes unitários

## 29.1 Redirect externo deve ser rejeitado

```java
@Test
public void deveRejeitarRedirectExterno() {
    RedirectValidator validator =
        new RedirectValidator();

    assertEquals(
        "/home",
        validator.validarRedirectInterno(
            "https://evil.example"
        )
    );

    assertEquals(
        "/home",
        validator.validarRedirectInterno(
            "//evil.example"
        )
    );
}
```

## 29.2 Campo hidden alterado não deve definir preço

```java
@Test
public void valorDoProdutoDeveVirDoServidor() {
    Produto produto =
        new Produto(10L, new BigDecimal("100.00"));

    when(produtoDAO.findAtivo(10L))
        .thenReturn(Optional.of(produto));

    compraService.comprar(
        principal,
        10L,
        1
    );

    verify(pedidoService).comprar(
        principal.getUserId(),
        10L,
        1,
        new BigDecimal("100.00")
    );
}
```

## 29.3 Parâmetro duplicado deve ser rejeitado

```java
@Test(expected = IllegalArgumentException.class)
public void parametroDuplicadoDeveSerRejeitado() {
    HttpServletRequest request =
        mock(HttpServletRequest.class);

    when(request.getParameterValues("perfil"))
        .thenReturn(
            new String[] { "USER", "ADMIN" }
        );

    RequestParamValidator.requiredSingle(
        request,
        "perfil"
    );
}
```

---

# 30. Quadro de decisão rápida

| Evidência | CWE provável |
|---|---:|
| `Content-Length` difere dos bytes processados | 130 |
| Header `Authorization` sem `Bearer` é aceito | 166 |
| Token com partes extras é aceito | 167 |
| Delimitadores duplicados/inconsistentes são aceitos | 168 |
| `ADMIN` e `admin` são tratados de modo divergente | 178 |
| Normalização faz dois usuários virarem o mesmo login | 182 |
| Regex rejeita e-mails válidos | 186 |
| Quantidade negativa é aceita | 229 |
| Parâmetro duplicado altera comportamento | 233 |
| CSV é parseado com `split(",")` | 237 |
| JSON aceita tipo inesperado | 241 |
| ZIP pequeno expande para volume enorme | 409 |
| Campo hidden define preço/perfil | 472 |
| `sendRedirect` usa parâmetro livre | 601 |
| XML permite entidade externa | 611 |
| Usuário controla regex | 624 |
| Regex aceita `arquivo.pdf.exe` | 625 |
| XML permite expansão recursiva de entidades | 776 |
| `Long` é comparado com `String` | 1024 |

---

# 31. Resumo para prova

## CWE-19

Categoria de erros no processamento de dados. Não deve ser usada diretamente para mapeamento quando houver CWE mais específica.

## CWE-130

Inconsistência entre tamanho declarado e tamanho real.

## CWE-166

Elemento especial esperado está ausente.

## CWE-167

Elemento especial adicional é aceito indevidamente.

## CWE-168

Elementos especiais aparecem de forma inconsistente.

## CWE-178

Case sensitivity tratado de forma incorreta.

## CWE-182

Normalização ou colapso transforma valores diferentes em um valor inseguro.

## CWE-186

Regex restritiva demais rejeita entradas legítimas.

## CWE-229

Valores fora do domínio esperado são aceitos.

## CWE-233

Parâmetros ausentes, duplicados, extras ou conflitantes são tratados incorretamente.

## CWE-237

Elementos estruturais do formato são interpretados incorretamente.

## CWE-241

Tipo inesperado é aceito ou convertido indevidamente.

## CWE-409

Entrada altamente compactada causa amplificação de dados.

## CWE-472

Parâmetro web controlável é tratado como imutável.

## CWE-601

Redirecionamento para site não confiável.

## CWE-611

XML permite referência a entidade externa.

## CWE-624

Regex executável ou dinâmica é usada de forma insegura.

## CWE-625

Regex permissiva demais aceita valores perigosos.

## CWE-776

DTD permite expansão recursiva ou massiva de entidades.

## CWE-1024

Comparação entre tipos incompatíveis.

---

# 32. Referências

## MITRE CWE

- [CWE-19 — Data Processing Errors](https://cwe.mitre.org/data/definitions/19.html)
- [CWE-130 — Improper Handling of Length Parameter Inconsistency](https://cwe.mitre.org/data/definitions/130.html)
- [CWE-166 — Improper Handling of Missing Special Element](https://cwe.mitre.org/data/definitions/166.html)
- [CWE-167 — Improper Handling of Additional Special Element](https://cwe.mitre.org/data/definitions/167.html)
- [CWE-168 — Improper Handling of Inconsistent Special Elements](https://cwe.mitre.org/data/definitions/168.html)
- [CWE-178 — Improper Handling of Case Sensitivity](https://cwe.mitre.org/data/definitions/178.html)
- [CWE-182 — Collapse of Data into Unsafe Value](https://cwe.mitre.org/data/definitions/182.html)
- [CWE-186 — Overly Restrictive Regular Expression](https://cwe.mitre.org/data/definitions/186.html)
- [CWE-229 — Improper Handling of Values](https://cwe.mitre.org/data/definitions/229.html)
- [CWE-233 — Improper Handling of Parameters](https://cwe.mitre.org/data/definitions/233.html)
- [CWE-237 — Improper Handling of Structural Elements](https://cwe.mitre.org/data/definitions/237.html)
- [CWE-241 — Improper Handling of Unexpected Data Type](https://cwe.mitre.org/data/definitions/241.html)
- [CWE-409 — Improper Handling of Highly Compressed Data](https://cwe.mitre.org/data/definitions/409.html)
- [CWE-472 — External Control of Assumed-Immutable Web Parameter](https://cwe.mitre.org/data/definitions/472.html)
- [CWE-601 — URL Redirection to Untrusted Site](https://cwe.mitre.org/data/definitions/601.html)
- [CWE-611 — Improper Restriction of XML External Entity Reference](https://cwe.mitre.org/data/definitions/611.html)
- [CWE-624 — Executable Regular Expression Error](https://cwe.mitre.org/data/definitions/624.html)
- [CWE-625 — Permissive Regular Expression](https://cwe.mitre.org/data/definitions/625.html)
- [CWE-776 — Improper Restriction of Recursive Entity References in DTDs](https://cwe.mitre.org/data/definitions/776.html)
- [CWE-1024 — Comparison of Incompatible Types](https://cwe.mitre.org/data/definitions/1024.html)

## Java e OWASP

- [OWASP XML External Entity Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/XML_External_Entity_Prevention_Cheat_Sheet.html)
- [OWASP Unvalidated Redirects and Forwards Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Unvalidated_Redirects_and_Forwards_Cheat_Sheet.html)
- [OWASP File Upload Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html)
- [Java SE 8 — DocumentBuilderFactory](https://docs.oracle.com/javase/8/docs/api/javax/xml/parsers/DocumentBuilderFactory.html)
- [Java SE 8 — Pattern](https://docs.oracle.com/javase/8/docs/api/java/util/regex/Pattern.html)
- [Java SE 8 — ZipInputStream](https://docs.oracle.com/javase/8/docs/api/java/util/zip/ZipInputStream.html)

---

# 33. Conclusão

Erros de processamento de dados acontecem quando o sistema interpreta uma entrada de forma diferente do que a regra de negócio, a segurança ou o formato realmente exigem.

Os controles mais importantes são:

- limitar tamanho antes de processar;
- rejeitar parâmetros duplicados ou conflitantes;
- normalizar antes de validar, quando aplicável;
- validar formato, tipo, faixa e domínio;
- não confiar em campos hidden;
- usar parsers adequados;
- tratar XML de forma restrita;
- impor limites em arquivos compactados;
- evitar regex dinâmica;
- restringir redirects;
- comparar tipos compatíveis;
- validar no servidor tudo que veio do cliente.

A regra central é:

> Todo dado externo deve ser tratado como ambíguo até que tamanho, estrutura, tipo, valor, origem e contexto tenham sido validados de forma explícita.
