# CWE-699 — Software Development

## Category: File Handling Issues — CWE-1219

> **Objetivo:** apresentar uma documentação prática sobre falhas de manipulação de arquivos, com exemplos vulneráveis e corrigidos em **Java 8**, aplicáveis a sistemas web, Struts/Servlet/JSP, APIs REST, uploads, downloads, geração de PDF, arquivos temporários, execução de comandos e ambientes Linux/Windows.

---

## 1. Visão geral

A categoria **CWE-1219 — File Handling Issues** agrupa fraquezas relacionadas ao tratamento de arquivos, diretórios e recursos semelhantes dentro de um sistema de software.

Em aplicações Java web, essas falhas aparecem com frequência em pontos como:

- download de anexos;
- upload de documentos;
- geração de PDF/CSV/XLS;
- criação de arquivos temporários;
- leitura de configurações;
- extração de ZIP;
- execução de conversores externos;
- anexação de arquivos a procedimentos;
- integração com diretórios de persistência;
- uso de nomes de arquivo vindos do usuário;
- busca de executáveis ou bibliotecas por caminho relativo.

A categoria é útil para estudo e organização, mas não deve ser usada diretamente para mapear vulnerabilidades reais. O mapeamento deve ser feito na CWE Base mais específica, como CWE-22 para path traversal ou CWE-59 para link following.

---

## 2. CWEs abordadas

| CWE | Nome | Exemplo prático |
|---:|---|---|
| 22 | Improper Limitation of a Pathname to a Restricted Directory | Path traversal com `../` ou caminho absoluto |
| 41 | Improper Resolution of Path Equivalence | Caminhos equivalentes tratados como diferentes |
| 59 | Improper Link Resolution Before File Access | Symlink/hard link leva operação para outro arquivo |
| 66 | Improper Handling of File Names that Identify Virtual Resources | Nome especial identifica recurso virtual, não arquivo comum |
| 378 | Creation of Temporary File With Insecure Permissions | Arquivo temporário legível por usuários indevidos |
| 379 | Creation of Temporary File in Directory with Insecure Permissions | Arquivo temporário criado em diretório inseguro |
| 426 | Untrusted Search Path | Sistema busca executável/biblioteca em local não confiável |
| 427 | Uncontrolled Search Path Element | Elemento do search path é controlável ou inseguro |
| 428 | Unquoted Search Path or Element | Caminho com espaço sem aspas permite execução inesperada |

---

# 3. Princípios práticos

## 3.1 Nome de arquivo não é autorização

Um nome como:

```text
relatorio.pdf
```

não prova que o usuário pode acessar o arquivo. O sistema precisa validar:

- identidade do usuário;
- vínculo com o recurso;
- tenant/unidade/procedimento;
- nível de sigilo;
- status do documento;
- autorização da operação;
- caminho físico resolvido no servidor.

## 3.2 Não confiar em path vindo do cliente

Entradas perigosas:

```text
../../../../etc/passwd
..\..\windows\win.ini
/var/log/app.log
C:\Windows\win.ini
%2e%2e%2f%2e%2e%2fetc/passwd
arquivo.pdf/../segredo.txt
```

A defesa correta não é apenas remover `../`. O ideal é:

1. usar identificador lógico no request;
2. buscar metadados no banco;
3. validar autorização;
4. resolver o arquivo dentro de diretório base controlado;
5. comparar o caminho real com a base real;
6. abrir o arquivo de forma segura.

## 3.3 Preferir identificador interno

Vulnerável:

```text
GET /download?arquivo=relatorios/2026/folha.pdf
```

Preferível:

```text
GET /download?idArquivo=58721
```

O servidor consulta:

```text
idArquivo → dono → procedimento → caminho físico → permissão
```

## 3.4 Separar nome de exibição e nome físico

O nome original do arquivo deve ser tratado como metadado, não como caminho.

| Campo | Uso |
|---|---|
| `idArquivo` | Identificador interno |
| `nomeOriginal` | Exibição e download |
| `nomeFisico` | Nome gerado pelo servidor |
| `diretorioBase` | Diretório controlado pela aplicação |
| `hash` | Verificação de integridade, quando necessário |
| `contentType` | Tipo validado/armazenado |

Exemplo de nome físico seguro:

```text
c8a4bd20-9b3d-4ad7-b69a-e7452a15fb94.bin
```

## 3.5 Validar caminho depois de resolver

A regra importante é:

```text
validar o caminho real que será usado, não apenas a string recebida.
```

Em Java:

- `normalize()` remove partes redundantes, mas não necessariamente resolve symlinks;
- `toRealPath()` resolve o caminho real no sistema de arquivos;
- `getCanonicalPath()` resolve forma canônica em `java.io.File`;
- `startsWith()` deve ser usado entre objetos `Path`, não apenas string textual;
- symlinks exigem cuidado adicional.

---

# 4. CWE-22 — Path Traversal

## 4.1 Conceito

A aplicação usa entrada externa para construir um caminho que deveria ficar dentro de um diretório restrito, mas não neutraliza elementos especiais que permitem sair desse diretório.

Exemplos:

```text
../
..\
/caminho/absoluto
C:\caminho\absoluto
%2e%2e%2f
```

## 4.2 Exemplo vulnerável: download por nome

```java
public void baixarArquivo(
        HttpServletRequest request,
        HttpServletResponse response)
        throws IOException {

    String nome = request.getParameter("arquivo");

    File arquivo = new File(
        "/opt/app/anexos/" + nome
    );

    try (InputStream in = new FileInputStream(arquivo);
         OutputStream out = response.getOutputStream()) {

        byte[] buffer = new byte[8192];
        int lidos;

        while ((lidos = in.read(buffer)) != -1) {
            out.write(buffer, 0, lidos);
        }
    }
}
```

Ataque:

```text
/download?arquivo=../../../../etc/passwd
```

## 4.3 Solução: caminho real sob diretório base

```java
public final class SafeFileResolver {

    private final Path baseDirectory;

    public SafeFileResolver(Path baseDirectory)
            throws IOException {

        this.baseDirectory =
            baseDirectory.toRealPath();
    }

    public Path resolveExistingFile(String relativeName)
            throws IOException {

        if (relativeName == null
                || relativeName.trim().isEmpty()) {
            throw new IllegalArgumentException(
                "Nome de arquivo obrigatório"
            );
        }

        if (relativeName.indexOf('\0') >= 0) {
            throw new IllegalArgumentException(
                "Nome de arquivo contém caractere nulo"
            );
        }

        Path candidate = baseDirectory
            .resolve(relativeName)
            .normalize();

        Path realCandidate = candidate.toRealPath();

        if (!realCandidate.startsWith(baseDirectory)) {
            throw new SecurityException(
                "Arquivo fora do diretório permitido"
            );
        }

        if (!Files.isRegularFile(realCandidate)) {
            throw new SecurityException(
                "Recurso não é arquivo regular"
            );
        }

        return realCandidate;
    }
}
```

## 4.4 Solução preferencial: download por ID autorizado

```java
public void baixarArquivo(
        AuthenticatedPrincipal principal,
        Long idArquivo,
        HttpServletResponse response)
        throws IOException {

    Arquivo arquivo = arquivoDAO
        .obterArquivoAutorizado(
            principal.getUserId(),
            idArquivo
        )
        .orElseThrow(
            AuthorizationException::new
        );

    Path path = fileResolver.resolveExistingFile(
        arquivo.getNomeFisico()
    );

    response.setContentType(
        arquivo.getContentTypeSeguro()
    );

    response.setHeader(
        "Content-Disposition",
        "attachment; filename=\""
            + DownloadName.safe(
                arquivo.getNomeOriginal()
            )
            + "\""
    );

    try (InputStream in = Files.newInputStream(path);
         OutputStream out = response.getOutputStream()) {

        copy(in, out);
    }
}
```

## 4.5 Regras

- não receber caminho completo do cliente;
- usar ID lógico e autorização no DAO;
- resolver caminho sob diretório base;
- comparar caminho real com base real;
- rejeitar path absoluto;
- rejeitar caractere nulo;
- não salvar uploads dentro do webroot;
- aplicar menor privilégio no usuário do processo;
- registrar tentativas rejeitadas sem expor caminho sensível.

---

# 5. CWE-41 — Improper Resolution of Path Equivalence

## 5.1 Conceito

O sistema trata caminhos equivalentes como se fossem diferentes, permitindo contornar validações.

Exemplos:

```text
/opt/app/anexos/../segredo.txt
/opt/app//anexos/arquivo.pdf
/OPT/APP/ANEXOS/arquivo.pdf
arquivo.pdf
./arquivo.pdf
arquivo%2epdf
arquivo.pdf::$DATA
```

O risco depende do sistema de arquivos, sistema operacional, servidor web e camada de aplicação.

## 5.2 Exemplo vulnerável

```java
public boolean permitido(String path) {
    return path.startsWith("/opt/app/anexos/");
}
```

Entrada:

```text
/opt/app/anexos/../segredo.txt
```

A string começa com a base, mas o caminho efetivo sai do diretório.

## 5.3 Solução

```java
public boolean estaDentroDaBase(
        Path base,
        Path candidato)
        throws IOException {

    Path baseReal = base.toRealPath();
    Path candidatoReal = candidato.toRealPath();

    return candidatoReal.startsWith(baseReal);
}
```

## 5.4 Case sensitivity

Em Windows, o sistema de arquivos normalmente é case-insensitive. Em Linux, normalmente é case-sensitive.

Evite regras que dependam de diferença de case para segurança.

```java
String nomeNormalizado =
    Normalizer.normalize(
        nomeOriginal,
        Normalizer.Form.NFC
    );
```

Para identificadores lógicos, aplique normalização e constraint única no banco.

## 5.5 Duplicidade por equivalência

Vulnerável:

```java
String chave = nomeArquivo.toLowerCase(Locale.ROOT);
cache.put(chave, arquivo);
```

Problema: pode haver colisão ou sobrescrita de recursos distintos.

Solução: usar ID interno único e tratar o nome como metadado.

---

# 6. CWE-59 — Link Following

## 6.1 Conceito

A aplicação acessa um arquivo sem tratar corretamente links simbólicos ou outros links do sistema de arquivos. Um atacante pode fazer o caminho esperado apontar para outro arquivo.

Exemplo:

```text
/opt/app/upload/relatorio.pdf -> /etc/passwd
```

## 6.2 Exemplo vulnerável

```java
public void gravar(Path arquivo, byte[] conteudo)
        throws IOException {

    Files.write(
        arquivo,
        conteudo,
        StandardOpenOption.CREATE,
        StandardOpenOption.TRUNCATE_EXISTING
    );
}
```

Se `arquivo` for symlink, a escrita pode afetar outro destino.

## 6.3 Solução para leitura

```java
public InputStream abrirArquivoRegularSemSeguirLink(
        Path arquivo)
        throws IOException {

    if (Files.isSymbolicLink(arquivo)) {
        throw new SecurityException(
            "Link simbólico não permitido"
        );
    }

    if (!Files.isRegularFile(
            arquivo,
            LinkOption.NOFOLLOW_LINKS)) {
        throw new SecurityException(
            "Não é arquivo regular"
        );
    }

    return Files.newInputStream(
        arquivo,
        StandardOpenOption.READ
    );
}
```

## 6.4 Solução para criação: criar novo arquivo de forma exclusiva

```java
public void criarArquivoNovo(
        Path arquivo,
        byte[] conteudo)
        throws IOException {

    try (OutputStream out = Files.newOutputStream(
            arquivo,
            StandardOpenOption.CREATE_NEW,
            StandardOpenOption.WRITE)) {

        out.write(conteudo);
    }
}
```

`CREATE_NEW` evita sobrescrever arquivo já existente, reduzindo risco de troca prévia por symlink.

## 6.5 TOCTOU

Cuidado com sequência:

```text
verificar → atacante troca arquivo → usar
```

Exemplo vulnerável:

```java
if (!Files.isSymbolicLink(path)) {
    Files.write(path, conteudo);
}
```

Entre a verificação e a escrita, o arquivo pode ser substituído.

Mitigações:

- criar com `CREATE_NEW`;
- usar diretório não gravável por usuários não confiáveis;
- usar permissões restritas;
- evitar operar em diretórios compartilhados;
- usar `SecureDirectoryStream` quando disponível e aplicável;
- reduzir janela entre check e use;
- bloquear por desenho: usuário não controla diretório físico.

## 6.6 Exemplo com `SecureDirectoryStream`

```java
public void apagarDentroDaBase(
        Path base,
        String nome)
        throws IOException {

    try (DirectoryStream<Path> stream =
             Files.newDirectoryStream(base)) {

        if (!(stream instanceof SecureDirectoryStream)) {
            throw new UnsupportedOperationException(
                "Sistema de arquivos não oferece SecureDirectoryStream"
            );
        }

        SecureDirectoryStream<Path> secure =
            (SecureDirectoryStream<Path>) stream;

        Path relativo = Paths.get(nome);

        if (relativo.isAbsolute()
                || relativo.getNameCount() != 1) {
            throw new SecurityException(
                "Nome inválido"
            );
        }

        secure.deleteFile(relativo);
    }
}
```

Na prática, a disponibilidade depende do provedor de sistema de arquivos.

---

# 7. CWE-66 — File Names that Identify Virtual Resources

## 7.1 Conceito

Alguns nomes parecem arquivos comuns, mas identificam recursos virtuais, streams alternativos, dispositivos ou aliases especiais.

Exemplos históricos e dependentes de plataforma:

```text
CON
PRN
AUX
NUL
COM1
LPT1
arquivo.txt::$DATA
/proc/self/environ
/dev/null
/dev/random
```

## 7.2 Exemplo vulnerável

```java
public void salvarUpload(
        String nomeOriginal,
        byte[] conteudo)
        throws IOException {

    Path destino = uploadDir.resolve(nomeOriginal);
    Files.write(destino, conteudo);
}
```

Em determinados ambientes, um nome especial pode não se comportar como arquivo normal.

## 7.3 Solução: nome físico gerado pelo servidor

```java
public ArquivoUpload salvarUpload(
        String nomeOriginal,
        byte[] conteudo,
        String extensao)
        throws IOException {

    String extensaoSegura =
        validarExtensao(extensao);

    String nomeFisico =
        UUID.randomUUID().toString()
        + "."
        + extensaoSegura;

    Path destino = uploadDir.resolve(nomeFisico);

    try (OutputStream out = Files.newOutputStream(
            destino,
            StandardOpenOption.CREATE_NEW,
            StandardOpenOption.WRITE)) {
        out.write(conteudo);
    }

    return new ArquivoUpload(
        nomeFisico,
        DownloadName.safe(nomeOriginal)
    );
}
```

## 7.4 Bloqueio de nomes especiais

Se o nome do usuário precisar ser usado como nome físico, aplique allowlist e bloqueie nomes reservados.

```java
public boolean nomeReservadoWindows(String nome) {
    String base = nome;

    int ponto = nome.indexOf('.');
    if (ponto >= 0) {
        base = nome.substring(0, ponto);
    }

    String upper = base.toUpperCase(Locale.ROOT);

    return Arrays.asList(
        "CON", "PRN", "AUX", "NUL",
        "COM1", "COM2", "COM3", "COM4",
        "COM5", "COM6", "COM7", "COM8", "COM9",
        "LPT1", "LPT2", "LPT3", "LPT4",
        "LPT5", "LPT6", "LPT7", "LPT8", "LPT9"
    ).contains(upper);
}
```

Mesmo assim, nome gerado pelo servidor é mais seguro.

---

# 8. CWE-378 — Temporary File With Insecure Permissions

## 8.1 Conceito

A aplicação cria arquivo temporário com permissões excessivas. Outros usuários/processos podem ler, alterar ou substituir o conteúdo.

## 8.2 Exemplo vulnerável

```java
File temp = File.createTempFile(
    "relatorio-",
    ".pdf"
);

try (FileOutputStream out =
         new FileOutputStream(temp)) {
    out.write(pdfBytes);
}
```

O problema não é necessariamente `createTempFile`, mas a ausência de controle explícito de permissões e diretório em ambientes sensíveis.

## 8.3 Solução com NIO e permissões POSIX

```java
public Path criarTemporarioPrivado(
        Path diretorioPrivado,
        byte[] conteudo)
        throws IOException {

    Set<PosixFilePermission> permissions =
        EnumSet.of(
            PosixFilePermission.OWNER_READ,
            PosixFilePermission.OWNER_WRITE
        );

    FileAttribute<Set<PosixFilePermission>> attrs =
        PosixFilePermissions.asFileAttribute(
            permissions
        );

    Path temp = Files.createTempFile(
        diretorioPrivado,
        "relatorio-",
        ".pdf",
        attrs
    );

    Files.write(
        temp,
        conteudo,
        StandardOpenOption.TRUNCATE_EXISTING
    );

    return temp;
}
```

## 8.4 Compatibilidade com Windows

POSIX permissions podem não estar disponíveis. Trate explicitamente:

```java
public Path criarTemporarioSeguro(
        Path diretorioPrivado,
        byte[] conteudo)
        throws IOException {

    try {
        return criarTemporarioPrivado(
            diretorioPrivado,
            conteudo
        );
    } catch (UnsupportedOperationException e) {
        Path temp = Files.createTempFile(
            diretorioPrivado,
            "relatorio-",
            ".pdf"
        );

        Files.write(
            temp,
            conteudo,
            StandardOpenOption.TRUNCATE_EXISTING
        );

        return temp;
    }
}
```

No Windows, controle permissões pelo diretório, ACLs e usuário do processo.

## 8.5 Regras

- não criar temporário em diretório público;
- restringir permissões de leitura/escrita;
- apagar após uso;
- não registrar caminho se contiver dados sensíveis;
- não usar nome previsível;
- usar `CREATE_NEW` quando criar manualmente;
- evitar temporários para segredos quando puder usar stream.

---

# 9. CWE-379 — Temporary File in Directory With Insecure Permissions

## 9.1 Conceito

Mesmo que o arquivo seja criado de forma razoável, o diretório temporário pode permitir interferência por usuários não confiáveis.

Exemplos:

```text
/tmp/app
C:\Temp\app
pasta compartilhada
pasta dentro do webroot
volume de container gravável por múltiplos serviços
```

## 9.2 Exemplo vulnerável

```java
Path temp = Files.createTempFile(
    Paths.get("/tmp"),
    "guia-",
    ".pdf"
);
```

Se outro usuário puder listar, criar links ou manipular arquivos no diretório, o risco aumenta.

## 9.3 Solução: diretório privado por aplicação

```java
public Path prepararDiretorioTemporarioPrivado(
        Path base)
        throws IOException {

    Path dir = base.resolve("tmp-app");

    if (!Files.exists(dir)) {
        Set<PosixFilePermission> permissions =
            EnumSet.of(
                PosixFilePermission.OWNER_READ,
                PosixFilePermission.OWNER_WRITE,
                PosixFilePermission.OWNER_EXECUTE
            );

        Files.createDirectories(
            dir,
            PosixFilePermissions.asFileAttribute(
                permissions
            )
        );
    }

    if (!Files.isDirectory(dir)) {
        throw new IOException(
            "Diretório temporário inválido"
        );
    }

    return dir.toRealPath();
}
```

## 9.4 Para application server

Em ambiente WildFly/Tomcat:

- configurar diretório temporário fora do webroot;
- não usar diretório compartilhado entre aplicações sem necessidade;
- garantir dono e permissões corretas;
- não permitir upload direto para temp público;
- limpar temporários antigos com rotina controlada;
- não permitir que outro usuário do SO escreva no diretório.

## 9.5 Rotina de limpeza

```java
public void limparTemporariosAntigos(
        Path tempDir,
        Duration idadeMaxima)
        throws IOException {

    Path base = tempDir.toRealPath();
    Instant limite = Instant.now().minus(idadeMaxima);

    try (DirectoryStream<Path> stream =
             Files.newDirectoryStream(base)) {

        for (Path path : stream) {
            Path real = path.toRealPath();

            if (!real.startsWith(base)) {
                continue;
            }

            if (!Files.isRegularFile(real)) {
                continue;
            }

            FileTime modified =
                Files.getLastModifiedTime(real);

            if (modified.toInstant().isBefore(limite)) {
                Files.deleteIfExists(real);
            }
        }
    }
}
```

---

# 10. CWE-426 — Untrusted Search Path

## 10.1 Conceito

A aplicação executa ou carrega recurso usando busca por caminho, e um diretório não confiável pode ser consultado antes do local correto.

Exemplos:

- executar `convert` sem caminho absoluto;
- depender de `PATH` configurável;
- carregar DLL/SO por nome;
- usar diretório atual no search path;
- iniciar processo a partir de pasta gravável;
- empacotar script que chama outro utilitário sem caminho absoluto.

## 10.2 Exemplo vulnerável

```java
public void converter(Path entrada)
        throws IOException {

    new ProcessBuilder(
        "convert",
        entrada.toString(),
        "saida.pdf"
    ).start();
}
```

Se o `PATH` contiver diretório controlável antes do diretório legítimo, outro executável chamado `convert` pode ser executado.

## 10.3 Solução: caminho absoluto e ambiente controlado

```java
public void converter(Path entrada, Path saida)
        throws IOException, InterruptedException {

    Path executavel = Paths.get(
        "/usr/local/bin/convert"
    ).toRealPath();

    ProcessBuilder builder =
        new ProcessBuilder(
            executavel.toString(),
            entrada.toRealPath().toString(),
            saida.toString()
        );

    Map<String, String> env = builder.environment();
    env.clear();
    env.put("PATH", "/usr/local/bin:/usr/bin:/bin");
    env.put("LANG", "C");

    builder.directory(
        saida.getParent().toFile()
    );

    Process process = builder.start();

    int exit = process.waitFor();

    if (exit != 0) {
        throw new IOException(
            "Conversão falhou"
        );
    }
}
```

## 10.4 Regras

- usar caminho absoluto para executáveis;
- limpar ou controlar variáveis de ambiente;
- não depender de diretório atual;
- não executar a partir de diretório de upload;
- não permitir que usuário controle `PATH`, `LD_LIBRARY_PATH`, `java.library.path`;
- validar permissões do executável;
- usar usuário de baixo privilégio.

---

# 11. CWE-427 — Uncontrolled Search Path Element

## 11.1 Conceito

O search path contém elemento controlável, gravável ou mal definido.

Diferença prática:

- **CWE-426:** a aplicação usa caminho de busca não confiável;
- **CWE-427:** um elemento específico do caminho é controlado de forma indevida.

## 11.2 Exemplo vulnerável

```java
String toolsDir = request.getParameter("toolsDir");

ProcessBuilder builder = new ProcessBuilder(
    "assinador",
    arquivo.toString()
);

builder.environment().put(
    "PATH",
    toolsDir + ":/usr/bin:/bin"
);

builder.start();
```

O atacante controla um elemento do `PATH`.

## 11.3 Solução

```java
private static final String SAFE_PATH =
    "/opt/app/bin:/usr/bin:/bin";

public Process criarProcessoAssinador(Path arquivo)
        throws IOException {

    Path assinador = Paths.get(
        "/opt/app/bin/assinador"
    ).toRealPath();

    ProcessBuilder builder = new ProcessBuilder(
        assinador.toString(),
        arquivo.toRealPath().toString()
    );

    Map<String, String> env = builder.environment();
    env.clear();
    env.put("PATH", SAFE_PATH);
    env.put("LANG", "C");

    return builder.start();
}
```

## 11.4 Carregamento de bibliotecas nativas

Vulnerável:

```java
System.loadLibrary("cryptoapp");
```

Se o caminho de bibliotecas nativas for controlável, uma biblioteca maliciosa pode ser carregada.

Mais seguro:

```java
System.load(
    "/opt/app/native/libcryptoapp.so"
);
```

Ainda assim, proteger permissões do arquivo e diretório.

## 11.5 Java classpath

Risco semelhante ocorre com classpath controlável:

```bash
java -cp /tmp/plugins/app.jar:/opt/app/app.jar br.gov.App
```

Se `/tmp/plugins` for gravável por usuários não confiáveis, classes maliciosas podem ter precedência.

---

# 12. CWE-428 — Unquoted Search Path or Element

## 12.1 Conceito

Um caminho com espaços é usado sem aspas ou delimitação adequada, permitindo que o sistema interprete parte do caminho como outro executável ou argumento.

Esse problema é clássico em Windows, mas o princípio vale para qualquer contexto em que caminho é convertido para linha de comando textual.

## 12.2 Exemplo vulnerável

```java
String comando =
    "C:\\Program Files\\App Seguro\\assinador.exe "
    + arquivo;

Runtime.getRuntime().exec(comando);
```

O caminho contém espaço. A interpretação pode tentar executar:

```text
C:\Program.exe
```

ou tratar partes do caminho como argumentos.

## 12.3 Solução: não montar linha de comando textual

```java
ProcessBuilder builder = new ProcessBuilder(
    "C:\\Program Files\\App Seguro\\assinador.exe",
    arquivo.toString()
);

builder.start();
```

O `ProcessBuilder` recebe os argumentos separados. Não é necessário inserir aspas manualmente nesse caso.

## 12.4 Quando precisar gerar script

Se for inevitável gerar script ou comando textual:

- usar quoting correto para o shell específico;
- evitar entrada externa;
- preferir arquivo de configuração temporário seguro;
- usar caminho curto/sem espaços quando controlado;
- testar no ambiente real;
- não concatenar sem delimitação.

## 12.5 Regras

- evitar `Runtime.exec(String)`;
- usar `ProcessBuilder(List<String>)`;
- não passar pelo shell;
- usar caminho absoluto;
- separar executável e argumentos;
- não confiar no diretório atual;
- controlar search path.

---

# 13. Componentes reutilizáveis

## 13.1 `DownloadName`

```java
public final class DownloadName {

    private DownloadName() {
    }

    public static String safe(String value) {
        if (value == null) {
            return "arquivo";
        }

        String normalized = Normalizer.normalize(
            value,
            Normalizer.Form.NFC
        );

        normalized = normalized
            .replaceAll("[\\r\\n\\t\\x00]", "_")
            .replaceAll("[^A-Za-z0-9._ -]", "_")
            .trim();

        if (normalized.isEmpty()
                || normalized.length() > 100) {
            return "arquivo";
        }

        return normalized;
    }
}
```

## 13.2 `FileStorageService`

```java
public final class FileStorageService {

    private final Path baseDirectory;

    public FileStorageService(Path baseDirectory)
            throws IOException {
        this.baseDirectory = baseDirectory.toRealPath();
    }

    public StoredFile store(
            String originalName,
            InputStream input,
            String extension)
            throws IOException {

        String safeExtension = validateExtension(extension);

        String physicalName =
            UUID.randomUUID().toString()
            + "."
            + safeExtension;

        Path target = baseDirectory
            .resolve(physicalName)
            .normalize();

        if (!target.startsWith(baseDirectory)) {
            throw new SecurityException(
                "Destino inválido"
            );
        }

        try (OutputStream out = Files.newOutputStream(
                target,
                StandardOpenOption.CREATE_NEW,
                StandardOpenOption.WRITE)) {

            copyWithLimit(input, out, 50L * 1024L * 1024L);
        }

        return new StoredFile(
            physicalName,
            DownloadName.safe(originalName)
        );
    }

    public Path resolveStored(String physicalName)
            throws IOException {

        if (!physicalName.matches(
                "[A-Fa-f0-9-]{36}\\.[A-Za-z0-9]{1,10}")) {
            throw new SecurityException(
                "Nome físico inválido"
            );
        }

        Path path = baseDirectory
            .resolve(physicalName)
            .normalize();

        Path real = path.toRealPath();

        if (!real.startsWith(baseDirectory)) {
            throw new SecurityException(
                "Arquivo fora da base"
            );
        }

        if (!Files.isRegularFile(
                real,
                LinkOption.NOFOLLOW_LINKS)) {
            throw new SecurityException(
                "Arquivo inválido"
            );
        }

        return real;
    }

    private String validateExtension(String extension) {
        if (extension == null) {
            throw new IllegalArgumentException(
                "Extensão obrigatória"
            );
        }

        String normalized = extension
            .trim()
            .toLowerCase(Locale.ROOT);

        if (!Arrays.asList("pdf", "png", "jpg", "csv")
                .contains(normalized)) {
            throw new IllegalArgumentException(
                "Extensão não permitida"
            );
        }

        return normalized;
    }

    private void copyWithLimit(
            InputStream in,
            OutputStream out,
            long maxBytes)
            throws IOException {

        byte[] buffer = new byte[8192];
        long total = 0;
        int read;

        while ((read = in.read(buffer)) != -1) {
            total += read;

            if (total > maxBytes) {
                throw new IOException(
                    "Arquivo excede limite"
                );
            }

            out.write(buffer, 0, read);
        }
    }
}
```

## 13.3 `StoredFile`

```java
public final class StoredFile {

    private final String physicalName;
    private final String displayName;

    public StoredFile(
            String physicalName,
            String displayName) {
        this.physicalName = physicalName;
        this.displayName = displayName;
    }

    public String getPhysicalName() {
        return physicalName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
```

---

# 14. Diferenças importantes

## 14.1 CWE-22 versus CWE-41

| Situação | CWE |
|---|---:|
| Entrada permite sair do diretório restrito | 22 |
| Caminhos equivalentes contornam validação | 41 |
| `../` passa por `startsWith` textual | 22 e 41 |

## 14.2 CWE-22 versus CWE-59

| Situação | CWE |
|---|---:|
| String do caminho sai da base | 22 |
| Caminho aparentemente dentro da base aponta via symlink para fora | 59 |
| Upload substitui arquivo por symlink | 59 |

## 14.3 CWE-378 versus CWE-379

| Situação | CWE |
|---|---:|
| Arquivo temporário tem permissão excessiva | 378 |
| Diretório temporário é inseguro | 379 |
| Arquivo em `/tmp` público com permissão aberta | ambas podem aparecer |

## 14.4 CWE-426 versus CWE-427 versus CWE-428

| Situação | CWE |
|---|---:|
| Busca usa caminho não confiável | 426 |
| Elemento específico do path é controlado/inseguro | 427 |
| Caminho com espaço não é delimitado/aspado | 428 |

---

# 15. Checklist de revisão

## 15.1 Upload

- O nome físico é gerado pelo servidor?
- O nome original é apenas metadado?
- O arquivo é salvo fora do webroot?
- Há limite de tamanho?
- A extensão é allowlist?
- O tipo real é validado quando necessário?
- `CREATE_NEW` é usado para evitar sobrescrita?
- O diretório não é gravável por usuários não confiáveis?
- Symlinks são tratados?
- Há varredura/validação conforme política?

## 15.2 Download

- O download usa ID, não caminho livre?
- A autorização é validada no DAO/serviço?
- O caminho real fica sob a base?
- Arquivo é regular?
- Nome no header é neutralizado?
- Content-Type é seguro?
- Arquivo sigiloso exige autenticação?
- Tentativas rejeitadas são auditadas?

## 15.3 Arquivos temporários

- O diretório temporário é privado?
- O arquivo tem permissão restrita?
- O nome é imprevisível?
- O arquivo é apagado após uso?
- Não há dados sensíveis persistidos desnecessariamente?
- Rotina de limpeza valida base real?
- Não há compartilhamento indevido entre aplicações?

## 15.4 Search path

- Executáveis usam caminho absoluto?
- `PATH` é controlado?
- `LD_LIBRARY_PATH`/`java.library.path` não são controláveis?
- Diretório atual não participa da busca?
- Comandos não são montados como string?
- Caminhos com espaço são passados como argumentos separados?
- Scripts usam paths absolutos para comandos internos?

## 15.5 Plataforma

- Windows device names são bloqueados quando aplicável?
- ADS como `::$DATA` é rejeitado?
- Case sensitivity foi considerada?
- Separadores `/` e `\` são tratados?
- Unicode normalization foi considerada?
- NUL byte é rejeitado?

---

# 16. Comandos de busca no código

## 16.1 Operações de arquivo

```bash
grep -RniE \
  'new File|Paths\.get|Files\.|FileInputStream|FileOutputStream|RandomAccessFile' \
  src/
```

## 16.2 Parâmetros usados em path

```bash
grep -RniE \
  'getParameter\("(arquivo|file|path|nome|diretorio|dir)' \
  src/
```

## 16.3 Temporários

```bash
grep -RniE \
  'createTempFile|java\.io\.tmpdir|/tmp|C:\\Temp|deleteOnExit' \
  src/ config/
```

## 16.4 Symlinks e links

```bash
grep -RniE \
  'isSymbolicLink|NOFOLLOW_LINKS|toRealPath|toFile\(\)\.getCanonicalPath' \
  src/
```

## 16.5 Execução de comandos/search path

```bash
grep -RniE \
  'Runtime\.getRuntime\(\)\.exec|ProcessBuilder|System\.loadLibrary|System\.load\(' \
  src/
```

## 16.6 Headers de download

```bash
grep -RniE \
  'Content-Disposition|filename=|setHeader\(' \
  src/
```

---

# 17. Testes sugeridos

## 17.1 Path traversal

1. `../../../../etc/passwd`.
2. `..\..\windows\win.ini`.
3. `/etc/passwd`.
4. `C:\Windows\win.ini`.
5. `%2e%2e%2f`.
6. `....//arquivo`.
7. `arquivo.pdf/../segredo.txt`.
8. nome vazio.
9. nome com byte nulo.
10. nome extremamente longo.

## 17.2 Path equivalence

1. `./arquivo.pdf`.
2. `dir/../arquivo.pdf`.
3. múltiplas barras.
4. case diferente.
5. Unicode normalizado e não normalizado.
6. extensão em maiúsculas.
7. nome com espaço no fim.
8. nome com ponto no fim em Windows.

## 17.3 Link following

1. Arquivo normal.
2. Symlink dentro da base apontando para fora.
3. Symlink trocado entre validação e uso.
4. Hard link quando aplicável.
5. Diretório no lugar de arquivo.
6. Arquivo removido durante operação.
7. Link cíclico.

## 17.4 Temporários

1. Diretório temp privado.
2. Diretório temp público.
3. Permissões do arquivo.
4. Arquivo pré-existente com mesmo nome.
5. Symlink no diretório temp.
6. Limpeza de arquivo antigo.
7. Arquivo ainda em uso.
8. Falha de escrita.

## 17.5 Search path

1. `PATH` com diretório malicioso antes.
2. Executável ausente.
3. Executável substituído.
4. Caminho com espaço.
5. Diretório atual gravável.
6. `LD_LIBRARY_PATH` controlável.
7. `java.library.path` controlável.
8. Script chamando comando sem caminho absoluto.

---

# 18. Exemplos de testes unitários

## 18.1 Path traversal deve ser rejeitado

```java
@Test(expected = SecurityException.class)
public void deveRejeitarPathTraversal()
        throws Exception {

    SafeFileResolver resolver =
        new SafeFileResolver(
            Paths.get("/opt/app/anexos")
        );

    resolver.resolveExistingFile(
        "../../../../etc/passwd"
    );
}
```

## 18.2 Nome de download deve remover CRLF

```java
@Test
public void nomeDownloadNaoDeveConterCrlf() {
    String nome = DownloadName.safe(
        "relatorio.pdf\r\nX-Test: true"
    );

    assertFalse(nome.contains("\r"));
    assertFalse(nome.contains("\n"));
}
```

## 18.3 Nome físico deve ser UUID

```java
@Test
public void nomeFisicoNaoDeveUsarNomeOriginal()
        throws Exception {

    StoredFile file = storage.store(
        "../../segredo.pdf",
        new ByteArrayInputStream(new byte[] { 1, 2, 3 }),
        "pdf"
    );

    assertTrue(
        file.getPhysicalName().matches(
            "[A-Fa-f0-9-]{36}\\.pdf"
        )
    );
}
```

## 18.4 ProcessBuilder deve receber executável absoluto

```java
@Test
public void comandoDeveUsarCaminhoAbsoluto() {
    Path executavel = Paths.get(
        "/usr/local/bin/convert"
    );

    assertTrue(executavel.isAbsolute());
}
```

---

# 19. Quadro de decisão rápida

| Evidência | CWE provável |
|---|---:|
| `new File(base + parametro)` | 22 |
| `startsWith("/base")` textual antes de normalizar | 41 |
| Symlink dentro da pasta aponta para fora | 59 |
| Nome `CON`, `NUL`, `::$DATA`, `/proc` é aceito | 66 |
| Temporário legível por outros usuários | 378 |
| Temporário criado em `/tmp` compartilhado sem proteção | 379 |
| `ProcessBuilder("convert", ...)` depende de `PATH` | 426 |
| Usuário controla elemento do `PATH` | 427 |
| `Runtime.exec("C:\\Program Files\\...")` como string | 428 |

---

# 20. Resumo para prova

## CWE-1219

Categoria de problemas de manipulação de arquivos. Não deve ser usada diretamente para mapeamento quando houver CWE Base mais específica.

## CWE-22

Path traversal: entrada externa permite acessar arquivo fora do diretório restrito.

## CWE-41

Path equivalence: caminhos equivalentes são resolvidos de forma incorreta ou inconsistente.

## CWE-59

Link following: symlink ou link leva a operação para recurso diferente do esperado.

## CWE-66

Nome de arquivo identifica recurso virtual, dispositivo, stream alternativo ou alias especial.

## CWE-378

Arquivo temporário criado com permissões inseguras.

## CWE-379

Arquivo temporário criado em diretório com permissões inseguras.

## CWE-426

Busca por executável/biblioteca usa caminho não confiável.

## CWE-427

Elemento do search path é controlável ou inseguro.

## CWE-428

Search path ou elemento com espaço é usado sem aspas/delimitação adequada.

---

# 21. Referências

## MITRE CWE

- [CWE-1219 — File Handling Issues](https://cwe.mitre.org/data/definitions/1219.html)
- [CWE-22 — Improper Limitation of a Pathname to a Restricted Directory](https://cwe.mitre.org/data/definitions/22.html)
- [CWE-41 — Improper Resolution of Path Equivalence](https://cwe.mitre.org/data/definitions/41.html)
- [CWE-59 — Improper Link Resolution Before File Access](https://cwe.mitre.org/data/definitions/59.html)
- [CWE-66 — Improper Handling of File Names that Identify Virtual Resources](https://cwe.mitre.org/data/definitions/66.html)
- [CWE-378 — Creation of Temporary File With Insecure Permissions](https://cwe.mitre.org/data/definitions/378.html)
- [CWE-379 — Creation of Temporary File in Directory with Insecure Permissions](https://cwe.mitre.org/data/definitions/379.html)
- [CWE-426 — Untrusted Search Path](https://cwe.mitre.org/data/definitions/426.html)
- [CWE-427 — Uncontrolled Search Path Element](https://cwe.mitre.org/data/definitions/427.html)
- [CWE-428 — Unquoted Search Path or Element](https://cwe.mitre.org/data/definitions/428.html)

## Java e OWASP

- [Java SE 8 — Path](https://docs.oracle.com/javase/8/docs/api/java/nio/file/Path.html)
- [Java SE 8 — Files](https://docs.oracle.com/javase/8/docs/api/java/nio/file/Files.html)
- [Java SE 8 — LinkOption](https://docs.oracle.com/javase/8/docs/api/java/nio/file/LinkOption.html)
- [Java SE 8 — SecureDirectoryStream](https://docs.oracle.com/javase/8/docs/api/java/nio/file/SecureDirectoryStream.html)
- [Java SE 8 — ProcessBuilder](https://docs.oracle.com/javase/8/docs/api/java/lang/ProcessBuilder.html)
- [OWASP File Upload Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html)
- [OWASP Path Traversal](https://owasp.org/www-community/attacks/Path_Traversal)

---

# 22. Conclusão

Falhas de manipulação de arquivos normalmente surgem quando a aplicação confunde **nome externo**, **caminho físico**, **recurso lógico** e **autorização**.

Os controles principais são:

- usar ID lógico em vez de path externo;
- gerar nome físico no servidor;
- armazenar nome original apenas como metadado;
- resolver caminho real sob diretório base;
- tratar symlinks e links;
- criar temporários em diretório privado;
- restringir permissões;
- usar caminho absoluto para executáveis;
- controlar search path;
- evitar comandos textuais;
- aplicar menor privilégio no sistema operacional.

A regra central é:

> Toda operação de arquivo deve partir de um recurso autorizado pelo servidor, resolvido dentro de uma base controlada e acessado com permissões mínimas, sem depender de caminhos, nomes ou search paths controlados pelo usuário.
