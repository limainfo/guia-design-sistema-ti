# CWE-699 — Software Development

## Category: Encapsulation Issues — CWE-1227

> **Objetivo:** apresentar uma documentação prática sobre falhas de encapsulamento, com exemplos vulneráveis e corrigidos em **Java 8**, aplicáveis a aplicações em camadas, sistemas Struts/Servlet/JSP, Services, Facades, DAOs, integrações, componentes dependentes de sistema operacional e código legado.

---

## 1. Visão geral

A categoria **CWE-1227 — Encapsulation Issues** agrupa fraquezas relacionadas à violação de limites entre componentes, camadas, classes, módulos ou responsabilidades arquiteturais.

Em segurança e manutenção, encapsulamento não significa apenas usar `private`. Ele envolve preservar fronteiras como:

- Controller/Action não acessa banco diretamente;
- JSP não contém regra de negócio;
- Service/Facade centraliza regra transacional;
- DAO centraliza acesso a dados;
- componente de infraestrutura isola sistema operacional, arquivos e rede;
- classe pai não conhece classes filhas concretas;
- dados internos não são expostos por referência mutável;
- detalhes dependentes de plataforma ficam atrás de uma interface;
- código de negócio não chama APIs profundas de infraestrutura sem mediação.

Quando essas fronteiras são quebradas, o sistema fica mais difícil de revisar, testar, proteger, auditar e evoluir.

---

## 2. Natureza da categoria

A **CWE-1227** é uma **Category**, ou seja, um agrupamento organizacional. Ela não deve ser usada diretamente para mapear uma vulnerabilidade real quando houver uma CWE Base mais específica.

Exemplos:

- Action chamando JDBC diretamente: **CWE-1057** ou **CWE-1083**;
- Service acessando campo interno de outra classe sem método de domínio: **CWE-1090**;
- classe abstrata usando `instanceof` de subclasses: **CWE-1062**;
- código de negócio chamando `System.getProperty`, `File.separator` e comando nativo em vários pontos: **CWE-1100** ou **CWE-1105**.

---

## 3. CWEs abordadas

| CWE | Nome | Exemplo prático em Java |
|---:|---|---|
| 1054 | Invocation of a Control Element at an Unnecessarily Deep Horizontal Layer | Controller chama DAO interno ou API de infraestrutura profunda |
| 1057 | Data Access Operations Outside of Expected Data Manager Component | Acesso a dados feito fora do componente gerenciador esperado |
| 1062 | Parent Class with References to Child Class | Classe pai conhece subclasses concretas |
| 1083 | Data Access from Outside Expected Data Manager Component | Código acessa banco/arquivo/cache sem passar pelo gerenciador esperado |
| 1090 | Method Containing Access of a Member Element from Another Class | Método manipula estado interno de outra classe diretamente |
| 1100 | Insufficient Isolation of System-Dependent Functions | Funções dependentes do sistema espalhadas pelo código |
| 1105 | Insufficient Encapsulation of Machine-Dependent Functionality | Funcionalidade dependente da máquina/plataforma não é encapsulada |

---

# 4. Princípios práticos

## 4.1 Encapsulamento protege invariantes

Uma classe ou componente deve proteger suas próprias regras internas.

Exemplo de invariante:

```text
Pedido cancelado não pode voltar para PAGO.
```

Se outros componentes alteram diretamente o status, a regra pode ser quebrada.

## 4.2 Camadas existem para concentrar decisões

Um desenho típico em aplicações Java legadas:

```text
JSP
→ Action / Controller
→ Facade / Service
→ DAO / Repository
→ Banco de dados
```

A violação ocorre quando uma camada pula outra:

```text
JSP → DAO
Action → JDBC
Service → request.getParameter()
DAO → HttpSession
```

## 4.3 Acesso direto reduz segurança

Quando regras são espalhadas, fica difícil garantir:

- autorização;
- auditoria;
- transação;
- validação;
- tratamento de erro;
- mascaramento de dados;
- consistência;
- controle de concorrência;
- logging padronizado;
- rastreabilidade.

## 4.4 Encapsulamento não é burocracia

A finalidade é permitir que pontos críticos sejam revisados em poucos lugares.

Exemplo:

- toda consulta de documento privado passa por `DocumentoService.obterAutorizado(...)`;
- todo arquivo físico passa por `ArquivoStorageService`;
- todo acesso a parâmetro de request passa por DTO validado;
- todo comando de sistema passa por `CommandGateway`;
- toda diferença Windows/Linux passa por `PlatformService`.

---

# 5. CWE-1054 — Invocation of a Control Element at an Unnecessarily Deep Horizontal Layer

## 5.1 Conceito

O produto chama um elemento de controle localizado em uma camada horizontal desnecessariamente profunda.

Em termos práticos, um componente de alto nível acessa diretamente um componente de baixo nível, ignorando a camada intermediária que deveria aplicar regras de negócio, segurança ou consistência.

## 5.2 Exemplo vulnerável: Action chamando DAO diretamente

```java
public class BaixarDocumentoAction extends Action {

    private DocumentoDAO documentoDAO;

    public ActionForward execute(
            ActionMapping mapping,
            ActionForm form,
            HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        Long documentoId = Long.valueOf(
            request.getParameter("documentoId")
        );

        Documento documento = documentoDAO.findById(documentoId);

        response.getOutputStream()
            .write(documento.getConteudo());

        return null;
    }
}
```

### Problemas

A Action acessa uma camada profunda e pode pular:

- autorização;
- auditoria;
- validação de propriedade;
- regra de sigilo;
- transação;
- verificação de status;
- controle de download;
- mascaramento;
- tratamento de erro padronizado.

## 5.3 Solução

A Action deve delegar a decisão ao Service/Facade.

```java
public class BaixarDocumentoAction extends Action {

    private DocumentoService documentoService;

    public ActionForward execute(
            ActionMapping mapping,
            ActionForm form,
            HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        UsuarioLogado usuario = UsuarioLogado.from(request);

        Long documentoId = Long.valueOf(
            request.getParameter("documentoId")
        );

        DocumentoDownload download =
            documentoService.prepararDownload(
                usuario,
                documentoId
            );

        response.setContentType(download.getContentType());
        response.setHeader(
            "Content-Disposition",
            "attachment; filename=\""
                + download.getNomeSeguro()
                + "\""
        );

        response.getOutputStream()
            .write(download.getConteudo());

        return null;
    }
}
```

```java
public class DocumentoService {

    private DocumentoDAO documentoDAO;
    private AutorizacaoService autorizacaoService;
    private AuditoriaService auditoriaService;

    public DocumentoDownload prepararDownload(
            UsuarioLogado usuario,
            Long documentoId) {

        Documento documento = documentoDAO.findById(documentoId)
            .orElseThrow(NotFoundException::new);

        autorizacaoService.validarAcesso(
            usuario,
            documento
        );

        auditoriaService.registrarDownload(
            usuario.getId(),
            documento.getId()
        );

        return DocumentoDownload.from(documento);
    }
}
```

## 5.4 Sinais de alerta

```bash
grep -RniE 'new .*DAO|DAO\.|getConnection|createQuery|createCriteria' src/main/java/*Action* src/main/java/*Controller*
```

Perguntas:

- a Action/Controller acessa DAO diretamente?
- a camada pulada continha regra de autorização?
- há auditoria centralizada?
- a mesma regra é repetida em vários controllers?
- o método chamado pertence a uma camada mais baixa que o esperado?

---

# 6. CWE-1057 — Data Access Operations Outside of Expected Data Manager Component

## 6.1 Conceito

O produto foi projetado para realizar operações de acesso a dados por meio de um componente gerenciador específico, mas contém código que executa operações de dados fora dele.

Em Java, o componente esperado pode ser:

- DAO;
- Repository;
- EntityManager;
- serviço de arquivo;
- cache manager;
- storage service;
- gateway de integração;
- client oficial de API.

## 6.2 Exemplo vulnerável: Service usando JDBC direto

```java
public class UsuarioService {

    private DataSource dataSource;

    public void bloquearUsuario(Long usuarioId)
            throws SQLException {

        String sql =
            "UPDATE usuario SET bloqueado = true "
          + "WHERE id = ?";

        try (Connection connection =
                 dataSource.getConnection();
             PreparedStatement ps =
                 connection.prepareStatement(sql)) {

            ps.setLong(1, usuarioId);
            ps.executeUpdate();
        }
    }
}
```

### Problemas

O Service passou a conhecer detalhes de persistência:

- SQL;
- nome de tabela;
- transação;
- conexão;
- dialeto do banco;
- tratamento de erro;
- auditoria de alteração;
- cache invalidation.

## 6.3 Solução

```java
public class UsuarioService {

    private UsuarioDAO usuarioDAO;
    private AuditoriaService auditoriaService;

    public void bloquearUsuario(
            UsuarioLogado operador,
            Long usuarioId) {

        Usuario usuario = usuarioDAO.findById(usuarioId)
            .orElseThrow(NotFoundException::new);

        usuario.bloquear();

        usuarioDAO.update(usuario);

        auditoriaService.registrarBloqueio(
            operador.getId(),
            usuario.getId()
        );
    }
}
```

```java
public class UsuarioDAO {

    public void update(Usuario usuario) {
        sessionFactory.getCurrentSession()
            .update(usuario);
    }
}
```

## 6.4 Exemplo vulnerável: JSP acessando banco

```jsp
<%
Connection con = dataSource.getConnection();
Statement st = con.createStatement();
ResultSet rs = st.executeQuery("select * from usuario");
%>
```

Isso viola encapsulamento e mistura apresentação, acesso a dados, transação e segurança.

## 6.5 Solução

```text
Action busca DTO → Service aplica regra → DAO consulta → JSP apenas renderiza.
```

```java
request.setAttribute(
    "usuarios",
    usuarioService.listarUsuariosVisiveis(usuarioLogado)
);
```

```jsp
<c:forEach var="usuario" items="${usuarios}">
    <tr>
        <td><c:out value="${usuario.nome}" /></td>
    </tr>
</c:forEach>
```

---

# 7. CWE-1062 — Parent Class with References to Child Class

## 7.1 Conceito

Uma classe pai contém referência explícita a classes filhas concretas.

Isso quebra o princípio de inversão de dependência e torna a hierarquia rígida.

## 7.2 Exemplo vulnerável

```java
public abstract class Relatorio {

    public void gerar() {
        if (this instanceof RelatorioPdf) {
            gerarCabecalhoPdf();
        }

        if (this instanceof RelatorioExcel) {
            gerarCabecalhoExcel();
        }

        gerarConteudo();
    }

    protected abstract void gerarConteudo();

    private void gerarCabecalhoPdf() {
        // detalhe específico do PDF
    }

    private void gerarCabecalhoExcel() {
        // detalhe específico do Excel
    }
}
```

### Problemas

- a classe pai conhece subclasses;
- cada novo formato exige alteração no pai;
- aumenta risco de quebrar formatos existentes;
- dificulta testes;
- mistura regra comum com detalhe específico;
- incentiva `instanceof` em cascata.

## 7.3 Solução com Template Method

```java
public abstract class Relatorio {

    public final void gerar() {
        gerarCabecalho();
        gerarConteudo();
        gerarRodape();
    }

    protected abstract void gerarCabecalho();

    protected abstract void gerarConteudo();

    protected void gerarRodape() {
        // comportamento comum opcional
    }
}
```

```java
public class RelatorioPdf extends Relatorio {

    @Override
    protected void gerarCabecalho() {
        // cabeçalho PDF
    }

    @Override
    protected void gerarConteudo() {
        // conteúdo PDF
    }
}
```

```java
public class RelatorioExcel extends Relatorio {

    @Override
    protected void gerarCabecalho() {
        // cabeçalho XLS
    }

    @Override
    protected void gerarConteudo() {
        // conteúdo XLS
    }
}
```

## 7.4 Solução com Strategy

```java
public interface RelatorioRenderer {

    void renderizar(RelatorioDados dados);
}
```

```java
public class PdfRenderer implements RelatorioRenderer {

    @Override
    public void renderizar(RelatorioDados dados) {
        // renderização PDF
    }
}
```

```java
public class RelatorioService {

    private Map<FormatoRelatorio, RelatorioRenderer> renderers;

    public void gerar(
            FormatoRelatorio formato,
            RelatorioDados dados) {

        RelatorioRenderer renderer = renderers.get(formato);

        if (renderer == null) {
            throw new IllegalArgumentException(
                "Formato não suportado"
            );
        }

        renderer.renderizar(dados);
    }
}
```

## 7.5 Revisão

```bash
grep -RniE 'instanceof|\.getClass\(\)|switch.*Tipo|if.*Tipo' src/main/java
```

Nem todo `instanceof` é problema, mas é sinal para revisar se a classe pai conhece detalhes de filhos.

---

# 8. CWE-1083 — Data Access from Outside Expected Data Manager Component

## 8.1 Conceito

O produto deveria acessar determinado recurso por meio de um componente gerenciador, mas acessa diretamente esse recurso de fora.

A diferença prática para a CWE-1057 é sutil:

- **CWE-1057** enfatiza operações de acesso a dados realizadas fora do componente esperado;
- **CWE-1083** enfatiza o acesso direto ao recurso, contornando o gerenciador.

## 8.2 Exemplo vulnerável: acesso direto ao arquivo físico

```java
public class DocumentoAction extends Action {

    public ActionForward baixar(
            ActionMapping mapping,
            ActionForm form,
            HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        String path = request.getParameter("path");

        byte[] conteudo = Files.readAllBytes(
            Paths.get(path)
        );

        response.getOutputStream().write(conteudo);
        return null;
    }
}
```

### Problemas

A Action contorna o componente que deveria controlar:

- diretório base;
- path traversal;
- autorização;
- nível de sigilo;
- auditoria;
- content-type;
- nome seguro;
- existência do arquivo;
- exceções;
- criptografia em repouso.

## 8.3 Solução

```java
public class DocumentoAction extends Action {

    private ArquivoStorageService arquivoStorageService;

    public ActionForward baixar(
            ActionMapping mapping,
            ActionForm form,
            HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        UsuarioLogado usuario = UsuarioLogado.from(request);

        Long arquivoId = Long.valueOf(
            request.getParameter("arquivoId")
        );

        ArquivoDownload download =
            arquivoStorageService.obterParaDownload(
                usuario,
                arquivoId
            );

        response.setContentType(download.getContentType());
        response.getOutputStream()
            .write(download.getBytes());

        return null;
    }
}
```

```java
public class ArquivoStorageService {

    private ArquivoDAO arquivoDAO;
    private AutorizacaoArquivoService autorizacao;
    private Path diretorioBase;

    public ArquivoDownload obterParaDownload(
            UsuarioLogado usuario,
            Long arquivoId)
            throws IOException {

        Arquivo arquivo = arquivoDAO.findById(arquivoId)
            .orElseThrow(NotFoundException::new);

        autorizacao.validarLeitura(usuario, arquivo);

        Path path = resolverPathSeguro(
            arquivo.getNomeFisico()
        );

        byte[] bytes = Files.readAllBytes(path);

        return new ArquivoDownload(
            arquivo.getNomeOriginalSeguro(),
            arquivo.getContentType(),
            bytes
        );
    }

    private Path resolverPathSeguro(String nomeFisico)
            throws IOException {

        Path baseReal = diretorioBase.toRealPath();

        Path destino = baseReal.resolve(nomeFisico)
            .normalize();

        if (!destino.startsWith(baseReal)) {
            throw new SecurityException(
                "Arquivo fora do diretório permitido"
            );
        }

        return destino;
    }
}
```

## 8.4 Outros exemplos

- código acessa Redis diretamente fora do `CacheService`;
- classe de negócio lê arquivo de configuração diretamente;
- endpoint chama API externa sem passar pelo gateway;
- classe utilitária abre conexão JDBC;
- JSP lê arquivo local;
- job manipula tabela sem usar DAO transacional.

---

# 9. CWE-1090 — Method Containing Access of a Member Element from Another Class

## 9.1 Conceito

Um método acessa diretamente elemento membro de outra classe, violando encapsulamento.

Em Java, isso aparece quando:

- campos são `public`;
- getters retornam coleções mutáveis;
- objetos internos são expostos;
- outra classe altera estado sem método de domínio;
- há uso excessivo de reflection;
- DTO e entidade compartilham referência mutável.

## 9.2 Exemplo vulnerável: campo público

```java
public class Conta {
    public BigDecimal saldo;
}
```

```java
public class TransferenciaService {

    public void sacar(Conta conta, BigDecimal valor) {
        conta.saldo = conta.saldo.subtract(valor);
    }
}
```

### Problemas

A regra da conta está fora da conta:

- saldo pode ficar negativo;
- auditoria pode ser ignorada;
- limite diário pode ser ignorado;
- validação de valor pode ser esquecida;
- concorrência pode ser tratada incorretamente.

## 9.3 Solução

```java
public class Conta {

    private BigDecimal saldo;

    public Conta(BigDecimal saldoInicial) {
        if (saldoInicial == null
                || saldoInicial.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException(
                "Saldo inicial inválido"
            );
        }

        this.saldo = saldoInicial;
    }

    public void sacar(BigDecimal valor) {
        validarValorPositivo(valor);

        if (saldo.compareTo(valor) < 0) {
            throw new IllegalStateException(
                "Saldo insuficiente"
            );
        }

        saldo = saldo.subtract(valor);
    }

    public BigDecimal getSaldo() {
        return saldo;
    }

    private void validarValorPositivo(BigDecimal valor) {
        if (valor == null
                || valor.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException(
                "Valor inválido"
            );
        }
    }
}
```

```java
public class TransferenciaService {

    public void sacar(Conta conta, BigDecimal valor) {
        conta.sacar(valor);
    }
}
```

## 9.4 Exemplo vulnerável: coleção interna mutável

```java
public class Usuario {

    private List<String> perfis = new ArrayList<String>();

    public List<String> getPerfis() {
        return perfis;
    }
}
```

Outro componente pode executar:

```java
usuario.getPerfis().add("ADMIN");
```

## 9.5 Solução

```java
public class Usuario {

    private final List<String> perfis =
        new ArrayList<String>();

    public List<String> getPerfis() {
        return Collections.unmodifiableList(perfis);
    }

    public void adicionarPerfil(
            String perfil,
            UsuarioLogado operador) {

        if (!operador.podeGerenciarPerfis()) {
            throw new AuthorizationException();
        }

        if (!PerfilPolicy.isPerfilValido(perfil)) {
            throw new IllegalArgumentException(
                "Perfil inválido"
            );
        }

        perfis.add(perfil);
    }
}
```

## 9.6 Exemplo vulnerável: getter expõe array

```java
public class ArquivoAssinado {

    private byte[] assinatura;

    public byte[] getAssinatura() {
        return assinatura;
    }
}
```

O chamador pode alterar o array interno.

## 9.7 Solução

```java
public class ArquivoAssinado {

    private final byte[] assinatura;

    public ArquivoAssinado(byte[] assinatura) {
        this.assinatura = Arrays.copyOf(
            assinatura,
            assinatura.length
        );
    }

    public byte[] getAssinatura() {
        return Arrays.copyOf(
            assinatura,
            assinatura.length
        );
    }
}
```

---

# 10. CWE-1100 — Insufficient Isolation of System-Dependent Functions

## 10.1 Conceito

Funções dependentes do sistema operacional, ambiente, servidor, filesystem, encoding, timezone ou infraestrutura ficam espalhadas pelo código.

Isso dificulta:

- portabilidade;
- testes;
- segurança;
- configuração por ambiente;
- auditoria;
- contenção de impacto.

## 10.2 Exemplo vulnerável

```java
public class RelatorioService {

    public void gerar(String nome) throws IOException {
        String diretorio =
            System.getProperty("user.home")
            + "\\relatorios\\";

        File arquivo = new File(
            diretorio + nome + ".pdf"
        );

        FileOutputStream out =
            new FileOutputStream(arquivo);

        // gera PDF
        out.close();
    }
}
```

### Problemas

- separador fixo do Windows;
- diretório baseado em `user.home`;
- path montado por concatenação;
- regra de arquivo espalhada no Service;
- permissões não centralizadas;
- difícil testar em Linux/application server;
- difícil aplicar criptografia, auditoria ou limpeza.

## 10.3 Solução

Criar uma abstração de armazenamento.

```java
public interface RelatorioStorage {

    Path salvarRelatorio(
        String nomeSeguro,
        byte[] conteudo
    ) throws IOException;
}
```

```java
public class FileSystemRelatorioStorage
        implements RelatorioStorage {

    private final Path diretorioBase;

    public FileSystemRelatorioStorage(Path diretorioBase) {
        this.diretorioBase = diretorioBase;
    }

    @Override
    public Path salvarRelatorio(
            String nomeSeguro,
            byte[] conteudo)
            throws IOException {

        Path baseReal = diretorioBase.toRealPath();

        Path destino = baseReal.resolve(nomeSeguro)
            .normalize();

        if (!destino.startsWith(baseReal)) {
            throw new SecurityException(
                "Destino fora do diretório permitido"
            );
        }

        Files.write(
            destino,
            conteudo,
            StandardOpenOption.CREATE_NEW
        );

        return destino;
    }
}
```

```java
public class RelatorioService {

    private RelatorioStorage storage;

    public void gerar(String nome, byte[] pdf)
            throws IOException {

        String nomeSeguro =
            NomeArquivoPolicy.gerarNomeRelatorio(nome);

        storage.salvarRelatorio(nomeSeguro, pdf);
    }
}
```

## 10.4 Outros exemplos

- `System.getenv()` espalhado;
- `new File("/tmp")` em várias classes;
- `Runtime.exec()` fora de gateway;
- timezone default usado em regra crítica;
- charset default em leitura/gravação;
- diretório do application server acessado diretamente;
- path absoluto em regra de negócio.

## 10.5 Encapsulamento recomendado

Criar componentes como:

- `ClockProvider`;
- `FileStorageService`;
- `CommandGateway`;
- `EnvironmentConfig`;
- `TemporaryFileService`;
- `EncodingPolicy`;
- `PlatformService`;
- `ExternalProcessRunner`;
- `HostInfoProvider`.

---

# 11. CWE-1105 — Insufficient Encapsulation of Machine-Dependent Functionality

## 11.1 Conceito

Funcionalidade dependente da máquina ou plataforma não é encapsulada adequadamente.

A diferença para a CWE-1100 é que aqui o foco está mais em detalhes de hardware, sistema operacional, arquitetura, filesystem, comandos nativos, encoding, byte order ou comportamento específico do ambiente de execução.

## 11.2 Exemplo vulnerável: comando dependente de sistema

```java
public class DiscoService {

    public String obterEspacoLivre()
            throws IOException {

        Process process = Runtime.getRuntime()
            .exec("df -h");

        return lerSaida(process);
    }
}
```

Problemas:

- funciona em Linux, falha no Windows;
- output varia por locale;
- comando pode não existir;
- parsing é frágil;
- política de execução não é centralizada;
- timeout não é garantido.

## 11.3 Solução preferencial: API Java

```java
public class FileStoreDiskSpaceService
        implements DiskSpaceService {

    @Override
    public long obterEspacoLivre(Path path)
            throws IOException {

        FileStore store = Files.getFileStore(path);
        return store.getUsableSpace();
    }
}
```

Interface:

```java
public interface DiskSpaceService {

    long obterEspacoLivre(Path path)
            throws IOException;
}
```

## 11.4 Quando comando nativo for inevitável

Encapsular por plataforma.

```java
public interface NativeCommand {

    CommandResult execute()
            throws IOException, InterruptedException;
}
```

```java
public class LinuxDiskCommand implements NativeCommand {

    private final CommandRunner commandRunner;

    @Override
    public CommandResult execute()
            throws IOException, InterruptedException {

        return commandRunner.run(
            Arrays.asList("/bin/df", "-P", "/dados")
        );
    }
}
```

```java
public class CommandRunner {

    public CommandResult run(List<String> command)
            throws IOException, InterruptedException {

        ProcessBuilder builder = new ProcessBuilder(command);
        builder.redirectErrorStream(true);

        Process process = builder.start();

        boolean finished = process.waitFor(
            30,
            TimeUnit.SECONDS
        );

        if (!finished) {
            process.destroyForcibly();
            throw new IOException(
                "Comando excedeu timeout"
            );
        }

        return CommandResult.from(process);
    }
}
```

## 11.5 Exemplo: charset dependente da máquina

Vulnerável:

```java
String texto = new String(bytes);
byte[] saida = texto.getBytes();
```

Usa charset default do ambiente.

Solução:

```java
String texto = new String(
    bytes,
    StandardCharsets.UTF_8
);

byte[] saida = texto.getBytes(
    StandardCharsets.UTF_8
);
```

## 11.6 Exemplo: timezone default

Vulnerável:

```java
DateFormat format =
    new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
```

Solução:

```java
SimpleDateFormat format =
    new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");

format.setTimeZone(
    TimeZone.getTimeZone("America/Sao_Paulo")
);
```

Melhor em código moderno: usar `java.time`, mas em Java 8 isso já está disponível.

```java
ZonedDateTime agora = ZonedDateTime.now(
    ZoneId.of("America/Sao_Paulo")
);
```

---

# 12. Componentes reutilizáveis

## 12.1 Facade de domínio

```java
public class DocumentoFacade {

    private DocumentoService documentoService;

    public DocumentoDTO obterDocumento(
            UsuarioLogado usuario,
            Long documentoId) {

        return documentoService.obterAutorizado(
            usuario,
            documentoId
        );
    }
}
```

Objetivo:

- a camada web não conhece DAO;
- regra de autorização fica centralizada;
- DTO de saída é controlado;
- exceções são traduzidas no ponto correto.

## 12.2 DAO como gerenciador de dados

```java
public class DocumentoDAO {

    public Optional<Documento> findById(Long id) {
        Documento documento =
            (Documento) sessionFactory
                .getCurrentSession()
                .get(Documento.class, id);

        return Optional.ofNullable(documento);
    }

    public Optional<Documento> findAutorizado(
            Long usuarioId,
            Long documentoId) {

        Query query = sessionFactory
            .getCurrentSession()
            .createQuery(
                "select d "
              + "from Documento d "
              + "join d.permissoes p "
              + "where d.id = :documentoId "
              + "and p.usuario.id = :usuarioId"
            );

        query.setParameter("documentoId", documentoId);
        query.setParameter("usuarioId", usuarioId);

        return Optional.ofNullable(
            (Documento) query.uniqueResult()
        );
    }
}
```

## 12.3 Policy para nomes e arquivos

```java
public final class NomeArquivoPolicy {

    private NomeArquivoPolicy() {
    }

    public static String gerarNomeRelatorio(String base) {
        String normalizado = base == null
            ? "relatorio"
            : base.trim().toLowerCase(Locale.ROOT);

        normalizado = normalizado.replaceAll(
            "[^a-z0-9._-]",
            "_"
        );

        if (normalizado.isEmpty()) {
            normalizado = "relatorio";
        }

        return normalizado
            + "-"
            + UUID.randomUUID().toString()
            + ".pdf";
    }
}
```

## 12.4 Gateway de comandos

```java
public interface ExternalCommandGateway {

    CommandResult execute(
        CommandRequest request
    ) throws IOException, InterruptedException;
}
```

```java
public final class CommandRequest {

    private final String executable;
    private final List<String> arguments;
    private final Duration timeout;

    // Construtor e getters defensivos.
}
```

Esse gateway centraliza:

- allowlist de executáveis;
- diretório de trabalho;
- timeout;
- logging sem segredo;
- usuário de execução;
- limites de saída;
- tratamento de erro;
- diferenças entre ambientes.

---

# 13. Diferenças importantes entre as CWEs

## 13.1 CWE-1057 versus CWE-1083

| Situação | CWE mais provável |
|---|---:|
| Service executa SQL diretamente, apesar de existir DAO | 1057 |
| Action lê arquivo físico diretamente, apesar de existir StorageService | 1083 |
| JSP abre conexão com banco | 1057 e possível 1083 |
| Job manipula tabela fora do DAO transacional | 1057 |

## 13.2 CWE-1100 versus CWE-1105

| Situação | CWE mais provável |
|---|---:|
| Funções dependentes de sistema espalhadas pelo código | 1100 |
| Detalhe específico de máquina/plataforma não encapsulado | 1105 |
| `File.separator`, timezone e charset default em vários services | 1100 |
| Comando Linux ou parsing de output nativo no domínio | 1105 |

## 13.3 CWE-1062 versus mau uso de herança

Nem toda herança é problema. O sinal de risco é a classe pai depender explicitamente de filhos concretos.

Exemplo de alerta:

```java
if (this instanceof SubClasseEspecifica) {
    // comportamento especial
}
```

## 13.4 CWE-1090 versus getters normais

Getter não é automaticamente vulnerabilidade. O problema ocorre quando o getter expõe estado interno mutável ou permite alteração indireta sem passar pela regra da classe.

---

# 14. Checklist de revisão

## 14.1 Camadas

- Action/Controller chama DAO diretamente?
- JSP contém SQL, regra de negócio ou acesso a sessão sensível?
- Service conhece detalhes de HTTP?
- DAO conhece `HttpServletRequest`, `HttpSession` ou usuário logado da web?
- Job executa SQL fora do DAO esperado?
- Integração externa é chamada fora de gateway?

## 14.2 Dados

- Existe acesso direto a `DataSource` espalhado?
- Existem `SessionFactory` ou `EntityManager` em classes que não são DAO/Repository?
- Cache é manipulado fora do componente de cache?
- Arquivos são lidos fora do storage service?
- Acesso a dados aplica autorização no ponto central?

## 14.3 Objetos

- Campos públicos existem em entidades de domínio?
- Getters retornam `List`, `Map`, array ou objeto mutável interno?
- Outra classe altera estado sem chamar método de domínio?
- Há reflection para alterar campos privados?
- Classe pai conhece subclasses?

## 14.4 Sistema e plataforma

- `System.getProperty` está espalhado?
- `System.getenv` está espalhado?
- `Runtime.exec` ou `ProcessBuilder` aparece fora de gateway?
- Charset default é usado?
- Timezone default é usado em regra crítica?
- Caminhos absolutos aparecem em código de negócio?
- Há comandos específicos de Linux/Windows fora de adaptador?

## 14.5 Segurança

- Autorização é aplicada em um ponto central?
- Auditoria é aplicada em um ponto central?
- Regras de path seguro são centralizadas?
- Regras de download/upload são centralizadas?
- Erros são tratados por camada apropriada?
- Transação é controlada na camada correta?

---

# 15. Comandos de busca no código

## 15.1 DAO em Action/Controller

```bash
grep -RniE 'DAO\.|new .*DAO|createCriteria|createQuery|getConnection' src/main/java | grep -Ei 'Action|Controller|Servlet'
```

## 15.2 SQL fora de DAO

```bash
grep -RniE 'SELECT |UPDATE |DELETE |INSERT |PreparedStatement|createStatement' src/main/java | grep -viE 'DAO|Repository'
```

## 15.3 HTTP dentro de DAO/Service profundo

```bash
grep -RniE 'HttpServletRequest|HttpServletResponse|HttpSession' src/main/java | grep -Ei 'DAO|Repository|Entity'
```

## 15.4 Campos públicos e coleções mutáveis

```bash
grep -RniE 'public .*;' src/main/java
```

```bash
grep -RniE 'List<|Map<|Set<|\[\]' src/main/java | grep -Ei 'get[A-Z].*\('
```

## 15.5 Classe pai conhecendo filhos

```bash
grep -RniE 'instanceof|getClass\(\)|switch.*tipo|if.*tipo' src/main/java
```

## 15.6 Dependência de sistema

```bash
grep -RniE 'System\.getProperty|System\.getenv|File\.separator|user\.home|java\.io\.tmpdir|Runtime\.getRuntime|ProcessBuilder' src/main/java
```

## 15.7 Charset e timezone default

```bash
grep -RniE 'new String\([^,]+\)|\.getBytes\(\)|new SimpleDateFormat|TimeZone\.getDefault|ZoneId\.systemDefault' src/main/java
```

---

# 16. Testes sugeridos

## 16.1 Camadas

1. Confirmar que endpoints críticos passam pelo Service/Facade.
2. Confirmar que autorização ocorre mesmo quando o ID é alterado no request.
3. Confirmar que auditoria ocorre em download, alteração e exclusão.
4. Confirmar que Action não acessa DAO diretamente.
5. Confirmar que JSP apenas renderiza dados preparados.
6. Confirmar que transação está na camada esperada.

## 16.2 Acesso a dados

1. Buscar SQL fora de DAO/Repository.
2. Verificar se consultas autorizadas filtram por usuário/tenant.
3. Confirmar que acesso a arquivo passa pelo StorageService.
4. Confirmar que cache é invalidado pelo componente central.
5. Testar erro de banco e verificar tradução de exceção.

## 16.3 Objetos

1. Tentar alterar coleção retornada por getter.
2. Confirmar que array retornado é cópia defensiva.
3. Tentar colocar status inválido diretamente na entidade.
4. Testar regras de domínio pelos métodos públicos.
5. Confirmar que classe pai não precisa mudar para nova subclasse.

## 16.4 Plataforma

1. Executar testes em Linux e Windows, quando aplicável.
2. Executar com timezone diferente.
3. Executar com charset default diferente.
4. Confirmar que paths usam `Path`/`Files`.
5. Confirmar que comando nativo possui timeout.
6. Confirmar fallback seguro quando comando externo não existe.

---

# 17. Exemplos de testes unitários

## 17.1 Getter não deve permitir alteração interna

```java
@Test(expected = UnsupportedOperationException.class)
public void perfisRetornadosNaoDevemSerAlteraveis() {
    Usuario usuario = new Usuario();
    usuario.adicionarPerfil("USER", operadorAutorizado);

    usuario.getPerfis().add("ADMIN");
}
```

## 17.2 Array deve ser cópia defensiva

```java
@Test
public void assinaturaNaoDeveSerAlteradaPorReferenciaExterna() {
    byte[] assinatura = new byte[] { 1, 2, 3 };

    ArquivoAssinado arquivo =
        new ArquivoAssinado(assinatura);

    byte[] obtida = arquivo.getAssinatura();
    obtida[0] = 99;

    assertEquals(1, arquivo.getAssinatura()[0]);
}
```

## 17.3 Service deve usar DAO autorizado

```java
@Test(expected = AuthorizationException.class)
public void usuarioNaoPodeBaixarDocumentoDeOutroTenant() {
    when(documentoDAO.findById(10L))
        .thenReturn(Optional.of(documentoDeOutroTenant));

    documentoService.prepararDownload(
        usuarioTenantA,
        10L
    );
}
```

## 17.4 Charset explícito

```java
@Test
public void conversaoDeTextoDeveUsarUtf8() {
    String original = "ação";

    byte[] bytes = original.getBytes(
        StandardCharsets.UTF_8
    );

    String convertido = new String(
        bytes,
        StandardCharsets.UTF_8
    );

    assertEquals(original, convertido);
}
```

---

# 18. Quadro de decisão rápida

| Evidência | CWE provável |
|---|---:|
| Action chama DAO interno diretamente | 1054 |
| Service executa SQL direto apesar de existir DAO | 1057 |
| Classe abstrata usa `instanceof` de subclasses | 1062 |
| Endpoint lê arquivo físico sem StorageService | 1083 |
| Getter retorna `List` mutável interna | 1090 |
| `System.getenv` e paths de SO espalhados | 1100 |
| Comando Linux/Windows dentro da regra de negócio | 1105 |
| JSP abre conexão com banco | 1057 / 1083 |
| DAO recebe `HttpServletRequest` | Violação de camadas, possível 1054 |
| Campo público altera estado crítico | 1090 |

---

# 19. Resumo para prova

## CWE-1227

Categoria de problemas de encapsulamento. Não deve ser usada diretamente quando houver CWE Base mais específica.

## CWE-1054

Chamada a elemento de controle em camada horizontal desnecessariamente profunda. Exemplo: Controller chamando DAO interno diretamente.

## CWE-1057

Operação de acesso a dados feita fora do componente gerenciador esperado. Exemplo: Service executando JDBC direto apesar de existir DAO.

## CWE-1062

Classe pai referencia classes filhas concretas. Exemplo: classe abstrata com `instanceof RelatorioPdf`.

## CWE-1083

Acesso a dados ou recurso fora do componente gerenciador esperado. Exemplo: Action lendo arquivo físico sem passar por StorageService.

## CWE-1090

Método acessa elemento membro de outra classe, violando encapsulamento. Exemplo: getter retorna coleção mutável interna.

## CWE-1100

Funções dependentes do sistema não são isoladas. Exemplo: paths, variáveis de ambiente e comandos espalhados pelo código.

## CWE-1105

Funcionalidade dependente da máquina/plataforma não é encapsulada. Exemplo: comando Linux dentro da regra de negócio.

---

# 20. Referências

## MITRE CWE

- [CWE-1227 — Encapsulation Issues](https://cwe.mitre.org/data/definitions/1227.html)
- [CWE-1054 — Invocation of a Control Element at an Unnecessarily Deep Horizontal Layer](https://cwe.mitre.org/data/definitions/1054.html)
- [CWE-1057 — Data Access Operations Outside of Expected Data Manager Component](https://cwe.mitre.org/data/definitions/1057.html)
- [CWE-1062 — Parent Class with References to Child Class](https://cwe.mitre.org/data/definitions/1062.html)
- [CWE-1083 — Data Access from Outside Expected Data Manager Component](https://cwe.mitre.org/data/definitions/1083.html)
- [CWE-1090 — Method Containing Access of a Member Element from Another Class](https://cwe.mitre.org/data/definitions/1090.html)
- [CWE-1100 — Insufficient Isolation of System-Dependent Functions](https://cwe.mitre.org/data/definitions/1100.html)
- [CWE-1105 — Insufficient Encapsulation of Machine-Dependent Functionality](https://cwe.mitre.org/data/definitions/1105.html)

## Java

- [Java SE 8 — Path](https://docs.oracle.com/javase/8/docs/api/java/nio/file/Path.html)
- [Java SE 8 — Files](https://docs.oracle.com/javase/8/docs/api/java/nio/file/Files.html)
- [Java SE 8 — ProcessBuilder](https://docs.oracle.com/javase/8/docs/api/java/lang/ProcessBuilder.html)
- [Java SE 8 — StandardCharsets](https://docs.oracle.com/javase/8/docs/api/java/nio/charset/StandardCharsets.html)
- [Java SE 8 — Optional](https://docs.oracle.com/javase/8/docs/api/java/util/Optional.html)

---

# 21. Conclusão

Falhas de encapsulamento não costumam parecer vulnerabilidades imediatas como SQL Injection ou XSS. Mesmo assim, elas aumentam o risco porque espalham regras críticas, quebram fronteiras arquiteturais e dificultam revisão.

Os controles mais importantes são:

- manter camadas bem definidas;
- centralizar acesso a dados;
- centralizar acesso a arquivos;
- proteger invariantes dentro das classes;
- evitar exposição de estado mutável;
- isolar funções dependentes de sistema;
- encapsular detalhes específicos da máquina;
- usar interfaces para infraestrutura;
- impedir que classes de alto nível conheçam detalhes profundos;
- manter autorização, auditoria e transação em pontos controlados.

A regra central é:

> Cada componente deve expor apenas operações seguras e necessárias, preservando suas próprias invariantes e impedindo que outras camadas contornem regras de negócio, segurança, persistência ou infraestrutura.
