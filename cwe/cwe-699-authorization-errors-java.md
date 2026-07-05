# CWE-699 — Software Development

## Categoria: CWE-1212 — Authorization Errors

> **Objetivo:** material prático para revisão e uso em GitHub, com foco em sistemas Java web, APIs REST, Struts/Servlet/JSP e backends corporativos.

> **Fonte principal:** MITRE CWE — `https://cwe.mitre.org/data/definitions/1212.html`  
> A CWE-1212 é uma **Category** dentro da view **CWE-699 - Software Development**. Por ser categoria, não deve ser usada diretamente para mapear vulnerabilidades reais. Para análise prática, correção e mapeamento, use as CWEs Base/Class listadas nesta documentação.

---

## 1. Visão geral

A categoria **Authorization Errors** reúne fraquezas relacionadas à autorização, ou seja, à capacidade do sistema garantir que um usuário, processo ou integração autenticada possui permissão para acessar um recurso ou executar uma ação.

Em aplicações Java, esses problemas aparecem com frequência em:

- Actions Struts acessadas diretamente sem passar pelo fluxo da tela;
- endpoints REST que validam apenas se o usuário está logado, mas não validam permissão;
- downloads de arquivos por `idArquivo`, `idDeposito`, `codDocumento`, `codInquerito` ou outro identificador manipulável;
- filtros que autorizam a URL antes de normalizar o caminho;
- arquivos sensíveis salvos dentro do diretório público da aplicação;
- autorização baseada em `hidden field`, parâmetro de request ou cookie manipulável;
- perfis muito amplos, como `ADMIN`, `OPERADOR` ou `GESTOR`, sem granularidade por ação;
- vazamento de metadados: nomes de arquivos, contagens, datas, títulos, unidade, status ou existência de registros sigilosos.

**Diferença importante:**

- **Autenticação:** quem é o usuário?
- **Autorização:** esse usuário pode executar esta ação sobre este recurso específico?

Um usuário autenticado pode não estar autorizado a baixar determinado arquivo, ver determinado procedimento, cancelar uma guia, consultar uma unidade ou alterar determinado registro.

---

## 2. Mapa rápido da categoria

| CWE | Nome | Ideia central | Exemplo típico em Java |
|---:|---|---|---|
| 425 | Direct Request / Forced Browsing | recurso restrito pode ser acessado diretamente pela URL | chamar `/admin/relatorio.do` sem passar pelo menu |
| 551 | Authorization Before Parsing and Canonicalization | autoriza antes de normalizar URL/caminho | libera `/public/../admin/acao.do` |
| 552 | Files or Directories Accessible to External Parties | arquivo sensível fica acessível publicamente | PDF em `/uploads/comprovantes/` dentro do web root |
| 639 | Authorization Bypass Through User-Controlled Key | usuário troca o ID e acessa dado de outro usuário | `baixarArquivo?id=123` sem checar dono/escopo |
| 653 | Improper Isolation or Compartmentalization | módulos/recursos de privilégios diferentes não são isolados | rotina administrativa junto com operação comum |
| 939 | Improper Authorization in Handler for Custom URL Scheme | handler de scheme customizado executa ação sem validar origem/permissão | Android `meuapp://delete?id=10` |
| 842 | Placement of User into Incorrect Group | usuário é colocado em grupo/perfil incorreto | request informa `perfil=ADMIN` |
| 1220 | Insufficient Granularity of Access Control | permissão é ampla demais | `ADMIN` pode consultar, alterar, excluir e exportar tudo |
| 1230 | Exposure of Sensitive Information Through Metadata | dado é protegido, mas metadados vazam informação | busca mostra título, data e existência de documento sigiloso |

---

## 3. Princípios seguros para autorização em Java

1. **Autorize no servidor, sempre.** Menu escondido, botão oculto, JavaScript, `disabled`, `readonly` e `hidden field` não são controles de segurança.
2. **Valide permissão por ação e por recurso.** Não basta verificar `usuario != null` ou `isLogado()`.
3. **Nunca confie no identificador vindo da tela.** `id`, `codArquivo`, `codFuncionario`, `codInquerito`, `idDeposito` e similares devem ser cruzados com o escopo permitido ao usuário.
4. **Normalize antes de autorizar.** Caminhos, URLs e nomes de arquivo devem ser decodificados, normalizados e validados antes de qualquer decisão de acesso.
5. **Arquivos sensíveis fora do web root.** Baixe por controller/Action com autorização, não por URL pública direta.
6. **Perfis devem virar permissões granulares.** `ADMIN` sozinho costuma ser amplo demais.
7. **Metadados também são dados.** Nome do arquivo, contagem, status, data, unidade e título podem revelar informação sensível.
8. **Falha de autorização deve ser registrada.** Logue tentativa negada com usuário, ação, recurso e correlation id, sem expor dados sensíveis.

---

## 4. Base de apoio para os exemplos

Os exemplos abaixo usam classes simples para representar padrões que podem ser adaptados para Struts, Servlet, Spring MVC ou REST.

### 4.1 Usuário autenticado

```java
public final class UsuarioAutenticado {
    private final Long id;
    private final String login;
    private final Long codUnidade;
    private final Set<String> permissoes;

    public UsuarioAutenticado(Long id, String login, Long codUnidade, Set<String> permissoes) {
        this.id = id;
        this.login = login;
        this.codUnidade = codUnidade;
        this.permissoes = permissoes == null ? Collections.emptySet() : permissoes;
    }

    public Long getId() {
        return id;
    }

    public String getLogin() {
        return login;
    }

    public Long getCodUnidade() {
        return codUnidade;
    }

    public boolean possuiPermissao(String permissao) {
        return permissoes.contains(permissao);
    }
}
```

### 4.2 Exceção de autorização

```java
public class AcessoNegadoException extends RuntimeException {
    public AcessoNegadoException(String mensagem) {
        super(mensagem);
    }
}
```

### 4.3 Guard centralizado de autorização

```java
public final class AuthorizationGuard {

    private AuthorizationGuard() {
    }

    public static UsuarioAutenticado exigirUsuario(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            throw new AcessoNegadoException("Usuário não autenticado.");
        }

        Object usuario = session.getAttribute("USUARIO_AUTENTICADO");
        if (!(usuario instanceof UsuarioAutenticado)) {
            throw new AcessoNegadoException("Usuário não autenticado.");
        }

        return (UsuarioAutenticado) usuario;
    }

    public static UsuarioAutenticado exigirPermissao(HttpServletRequest request, String permissao) {
        UsuarioAutenticado usuario = exigirUsuario(request);
        if (!usuario.possuiPermissao(permissao)) {
            throw new AcessoNegadoException("Permissão negada: " + permissao);
        }
        return usuario;
    }

    public static void exigirMesmoUsuarioOuPermissao(UsuarioAutenticado usuario,
                                                     Long idDonoRecurso,
                                                     String permissaoAdministrativa) {
        boolean dono = usuario.getId().equals(idDonoRecurso);
        boolean admin = usuario.possuiPermissao(permissaoAdministrativa);

        if (!dono && !admin) {
            throw new AcessoNegadoException("Usuário sem autorização para o recurso.");
        }
    }

    public static void exigirMesmaUnidadeOuPermissao(UsuarioAutenticado usuario,
                                                     Long codUnidadeRecurso,
                                                     String permissaoGlobal) {
        boolean mesmaUnidade = usuario.getCodUnidade().equals(codUnidadeRecurso);
        boolean acessoGlobal = usuario.possuiPermissao(permissaoGlobal);

        if (!mesmaUnidade && !acessoGlobal) {
            throw new AcessoNegadoException("Usuário sem autorização para a unidade do recurso.");
        }
    }
}
```

### 4.4 Log de negação de acesso

```java
public final class SecurityAuditLogger {

    private static final Logger LOGGER = LoggerFactory.getLogger(SecurityAuditLogger.class);

    private SecurityAuditLogger() {
    }

    public static void acessoNegado(String login, String acao, String recurso, String motivo) {
        LOGGER.warn("evento=ACESSO_NEGADO login={} acao={} recurso={} motivo={}",
                sanitizar(login), sanitizar(acao), sanitizar(recurso), sanitizar(motivo));
    }

    private static String sanitizar(String valor) {
        if (valor == null) {
            return "";
        }
        return valor.replace('\n', '_').replace('\r', '_').replace('\t', '_');
    }
}
```

---

## 5. CWE-425 — Direct Request ('Forced Browsing')

### 5.1 Conceito

A aplicação web não aplica autorização adequada em todas as URLs, scripts ou arquivos restritos. O usuário consegue chamar diretamente uma rota que normalmente só apareceria depois de navegar por uma tela, menu ou fluxo esperado.

### 5.2 Como aparece em Java web

- O menu esconde a opção, mas a Action continua acessível.
- Uma JSP fica em diretório público e pode ser chamada diretamente.
- Uma URL administrativa usa apenas validação visual no frontend.
- Um endpoint de exportação ou download não chama o guard de autorização.

### 5.3 Exemplo vulnerável

```java
public class RelatorioAdminAction extends Action {

    public ActionForward gerar(ActionMapping mapping,
                               ActionForm form,
                               HttpServletRequest request,
                               HttpServletResponse response) throws Exception {

        // Vulnerável: assume que só administradores verão o link no menu.
        RelatorioService service = new RelatorioService();
        byte[] pdf = service.gerarRelatorioCompleto();

        response.setContentType("application/pdf");
        response.getOutputStream().write(pdf);
        return null;
    }
}
```

Problema: qualquer usuário autenticado, ou até não autenticado dependendo do filtro, pode tentar acessar diretamente:

```text
/relatorioAdmin.do?action=gerar
```

### 5.4 Solução segura

```java
public class RelatorioAdminAction extends Action {

    public ActionForward gerar(ActionMapping mapping,
                               ActionForm form,
                               HttpServletRequest request,
                               HttpServletResponse response) throws Exception {

        UsuarioAutenticado usuario = AuthorizationGuard.exigirPermissao(
                request,
                "RELATORIO_ADMIN_GERAR"
        );

        RelatorioService service = new RelatorioService();
        byte[] pdf = service.gerarRelatorioCompleto(usuario);

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=relatorio-admin.pdf");
        response.getOutputStream().write(pdf);
        return null;
    }
}
```

### 5.5 Pontos de revisão

Procure por Actions ou endpoints que fazem algo crítico sem chamada explícita a autorização:

```bash
grep -R "class .*Action" -n src/main/java
grep -R "getOutputStream().write" -n src/main/java
grep -R "sendRedirect" -n src/main/java
grep -R "action=.*gerar\|action=.*baixar\|action=.*excluir\|action=.*cancelar" -n src/main/webapp
```

---

## 6. CWE-551 — Incorrect Behavior Order: Authorization Before Parsing and Canonicalization

### 6.1 Conceito

A aplicação toma a decisão de autorização antes de interpretar, decodificar e normalizar completamente a URL, caminho ou identificador. Isso permite bypass por variações como `../`, `%2e%2e`, `%2f`, dupla codificação ou caminhos equivalentes.

### 6.2 Exemplo vulnerável

```java
public class DownloadServlet extends HttpServlet {

    private static final String DIRETORIO_BASE = "/var/app/documentos";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String arquivo = request.getParameter("arquivo");

        // Vulnerável: autoriza com base na string original.
        if (arquivo.startsWith("publico/")) {
            File file = new File(DIRETORIO_BASE, arquivo);
            Files.copy(file.toPath(), response.getOutputStream());
            return;
        }

        response.sendError(HttpServletResponse.SC_FORBIDDEN);
    }
}
```

Entrada maliciosa possível:

```text
/download?arquivo=publico/../sigiloso/investigacao.pdf
```

A string começa com `publico/`, mas o caminho real aponta para outro diretório.

### 6.3 Solução segura

```java
public class DownloadServlet extends HttpServlet {

    private static final Path BASE_PUBLICA = Paths.get("/var/app/documentos/publico").toAbsolutePath().normalize();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        AuthorizationGuard.exigirPermissao(request, "DOCUMENTO_PUBLICO_BAIXAR");

        String nomeArquivo = request.getParameter("arquivo");
        if (nomeArquivo == null || nomeArquivo.isBlank()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        Path destino = BASE_PUBLICA.resolve(nomeArquivo).normalize();

        // Autoriza depois da normalização.
        if (!destino.startsWith(BASE_PUBLICA)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        if (!Files.isRegularFile(destino)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        response.setContentType("application/octet-stream");
        Files.copy(destino, response.getOutputStream());
    }
}
```

### 6.4 Regras práticas

- Normalize antes de comparar.
- Não faça autorização com `startsWith()` em caminho bruto.
- Não decodifique duas vezes.
- Prefira resolver o recurso por ID no banco e não por caminho informado pelo usuário.
- Para arquivos, use `Path.resolve(...).normalize()` e verifique `startsWith(BASE_PERMITIDA)`.

---

## 7. CWE-552 — Files or Directories Accessible to External Parties

### 7.1 Conceito

Arquivos ou diretórios que deveriam ser privados ficam acessíveis para usuários externos. Em aplicações web, isso ocorre quando PDFs, anexos, planilhas, backups, arquivos temporários ou comprovantes são gravados dentro do diretório público do servidor.

### 7.2 Exemplo vulnerável

```java
public class ComprovanteService {

    public String salvarComprovante(byte[] pdf, Long idDeposito) throws IOException {
        // Vulnerável: arquivo salvo dentro do web root.
        Path destino = Paths.get("/opt/wildfly/standalone/deployments/app.war/uploads/comprovantes/",
                idDeposito + ".pdf");

        Files.write(destino, pdf);

        // Qualquer pessoa que descubra a URL pode tentar acessar.
        return "/uploads/comprovantes/" + idDeposito + ".pdf";
    }
}
```

Problemas:

- o servidor web pode entregar o arquivo sem passar pela Action/Servlet;
- o nome sequencial facilita enumeração;
- não há autorização por usuário, unidade, procedimento ou nível de sigilo;
- backup, temporários ou PDFs internos podem ser expostos.

### 7.3 Solução segura

```java
public class ComprovanteService {

    private static final Path DIRETORIO_PRIVADO = Paths.get("/var/app/arquivos-privados/comprovantes")
            .toAbsolutePath()
            .normalize();

    public Long salvarComprovante(byte[] pdf, Long idDeposito) throws IOException {
        Files.createDirectories(DIRETORIO_PRIVADO);

        String nomeFisico = UUID.randomUUID() + ".pdf";
        Path destino = DIRETORIO_PRIVADO.resolve(nomeFisico).normalize();

        Files.write(destino, pdf, StandardOpenOption.CREATE_NEW);

        // Gravar no banco: idArquivo, idDeposito, nomeFisico, contentType, hash, tamanho.
        return registrarArquivoNoBanco(idDeposito, nomeFisico, pdf.length);
    }

    private Long registrarArquivoNoBanco(Long idDeposito, String nomeFisico, int tamanho) {
        // Implementação ilustrativa.
        return 1000L;
    }
}
```

Download autorizado:

```java
public class BaixarComprovanteAction extends Action {

    public ActionForward baixar(ActionMapping mapping,
                                ActionForm form,
                                HttpServletRequest request,
                                HttpServletResponse response) throws Exception {

        UsuarioAutenticado usuario = AuthorizationGuard.exigirPermissao(request, "COMPROVANTE_BAIXAR");

        Long idArquivo = Long.valueOf(request.getParameter("idArquivo"));

        ArquivoPrivado arquivo = new ArquivoDAO().buscarPorId(idArquivo)
                .orElseThrow(() -> new AcessoNegadoException("Arquivo não encontrado ou sem acesso."));

        AuthorizationGuard.exigirMesmaUnidadeOuPermissao(
                usuario,
                arquivo.getCodUnidade(),
                "COMPROVANTE_BAIXAR_GLOBAL"
        );

        Path path = arquivo.getPathPrivadoNormalizado();
        response.setContentType(arquivo.getContentType());
        response.setHeader("Content-Disposition", "attachment; filename=\"comprovante.pdf\"");
        Files.copy(path, response.getOutputStream());
        return null;
    }
}
```

### 7.4 Checklist para arquivos

- PDFs/anexos ficam fora do web root?
- Existe Action/Controller para baixar o arquivo?
- O download valida autenticação, permissão e escopo do recurso?
- O nome físico é imprevisível?
- O erro não diferencia “não existe” de “existe, mas você não pode acessar” quando isso revelar informação?
- Diretórios temporários são limpos?
- Arquivos gerados não ficam em `/tmp`, `/public`, `/webapp`, `/assets`, `/uploads` sem controle?

---

## 8. CWE-639 — Authorization Bypass Through User-Controlled Key

### 8.1 Conceito

O sistema permite que um usuário acesse dados de outro usuário alterando um identificador controlado pela requisição, como `id`, `codFuncionario`, `codArquivo`, `idDeposito`, `codUnidade` ou `numeroProcesso`.

Esse problema é conhecido em muitos contextos como **IDOR** ou, em APIs, pode se aproximar de **BOLA**.

### 8.2 Exemplo vulnerável

```java
public class DepositoJudicialAction extends Action {

    public ActionForward visualizar(ActionMapping mapping,
                                    ActionForm form,
                                    HttpServletRequest request,
                                    HttpServletResponse response) throws Exception {

        AuthorizationGuard.exigirUsuario(request);

        Long idDeposito = Long.valueOf(request.getParameter("idDeposito"));

        // Vulnerável: busca direta pelo ID informado pelo usuário.
        DepositoJudicial deposito = new DepositoJudicialDAO().buscarPorId(idDeposito);

        request.setAttribute("deposito", deposito);
        return mapping.findForward("visualizar");
    }
}
```

Ataque:

```text
/depositoJudicial.do?action=visualizar&idDeposito=100
/depositoJudicial.do?action=visualizar&idDeposito=101
/depositoJudicial.do?action=visualizar&idDeposito=102
```

Se o sistema não validar escopo, o usuário pode enumerar registros.

### 8.3 Solução segura com filtro por escopo no DAO

```java
public class DepositoJudicialAction extends Action {

    public ActionForward visualizar(ActionMapping mapping,
                                    ActionForm form,
                                    HttpServletRequest request,
                                    HttpServletResponse response) throws Exception {

        UsuarioAutenticado usuario = AuthorizationGuard.exigirPermissao(request, "DEPOSITO_VISUALIZAR");
        Long idDeposito = Long.valueOf(request.getParameter("idDeposito"));

        Optional<DepositoJudicial> depositoOpt = new DepositoJudicialDAO()
                .buscarAutorizado(idDeposito, usuario.getId(), usuario.getCodUnidade(), usuario.possuiPermissao("DEPOSITO_VISUALIZAR_GLOBAL"));

        DepositoJudicial deposito = depositoOpt.orElseThrow(
                () -> new AcessoNegadoException("Registro não encontrado ou sem autorização.")
        );

        request.setAttribute("deposito", deposito);
        return mapping.findForward("visualizar");
    }
}
```

DAO ilustrativo:

```java
public class DepositoJudicialDAO {

    public Optional<DepositoJudicial> buscarAutorizado(Long idDeposito,
                                                       Long idUsuario,
                                                       Long codUnidade,
                                                       boolean acessoGlobal) {
        String sql = """
                SELECT d.*
                  FROM depositojudicial d
                 WHERE d.id_deposito = :idDeposito
                   AND (
                        :acessoGlobal = true
                        OR d.cod_unidade = :codUnidade
                        OR d.id_usuario_responsavel = :idUsuario
                   )
                """;

        // Executar query parametrizada.
        return Optional.empty();
    }
}
```

### 8.4 Solução segura com verificação após carga

Quando a regra é complexa e não cabe no SQL, carregue o recurso e valide antes de retornar qualquer dado:

```java
public DepositoJudicial buscarParaVisualizacao(Long idDeposito, UsuarioAutenticado usuario) {
    DepositoJudicial deposito = depositoDAO.buscarPorId(idDeposito)
            .orElseThrow(() -> new AcessoNegadoException("Registro não encontrado ou sem autorização."));

    boolean mesmaUnidade = usuario.getCodUnidade().equals(deposito.getCodUnidade());
    boolean responsavel = usuario.getId().equals(deposito.getIdUsuarioResponsavel());
    boolean global = usuario.possuiPermissao("DEPOSITO_VISUALIZAR_GLOBAL");

    if (!mesmaUnidade && !responsavel && !global) {
        throw new AcessoNegadoException("Registro não encontrado ou sem autorização.");
    }

    return deposito;
}
```

### 8.5 Padrões perigosos

```java
request.getParameter("idUsuario")
request.getParameter("codFuncionario")
request.getParameter("codUnidade")
request.getParameter("idArquivo")
request.getParameter("idDeposito")
form.getCodUsuario()
form.getPerfil()
form.getCodUnidade()
```

Esses valores podem ser usados como filtros de pesquisa, mas não como prova de autorização.

---

## 9. CWE-653 — Improper Isolation or Compartmentalization

### 9.1 Conceito

O produto não isola adequadamente funcionalidades, processos ou recursos que exigem diferentes níveis de privilégio. Uma falha em uma área de menor privilégio pode atingir recursos de maior privilégio.

### 9.2 Exemplo vulnerável

```java
public class UsuarioService {

    public void atualizarMeusDados(Long idUsuarioLogado, UsuarioForm form) {
        Usuario usuario = usuarioDAO.buscarPorId(idUsuarioLogado);
        usuario.setNome(form.getNome());
        usuario.setEmail(form.getEmail());

        // Vulnerável: campo administrativo no mesmo fluxo de autoatendimento.
        usuario.setPerfil(form.getPerfil());
        usuario.setAtivo(form.isAtivo());

        usuarioDAO.salvar(usuario);
    }
}
```

Problema: uma funcionalidade comum de “meus dados” compartilha campos administrativos. Se a tela não exibe `perfil`, um atacante ainda pode enviar o parâmetro manualmente.

### 9.3 Solução segura

Separe casos de uso de baixo e alto privilégio.

```java
public class AutoAtendimentoUsuarioService {

    public void atualizarMeusDados(UsuarioAutenticado usuarioLogado, MeusDadosForm form) {
        Usuario usuario = usuarioDAO.buscarPorId(usuarioLogado.getId());
        usuario.setNome(form.getNome());
        usuario.setEmail(form.getEmail());
        usuarioDAO.salvar(usuario);
    }
}
```

```java
public class AdministracaoUsuarioService {

    public void alterarPerfil(HttpServletRequest request, Long idUsuario, String novoPerfil) {
        UsuarioAutenticado admin = AuthorizationGuard.exigirPermissao(request, "USUARIO_ALTERAR_PERFIL");

        if (!politicaPerfil.permiteAtribuir(admin, novoPerfil)) {
            throw new AcessoNegadoException("Perfil não pode ser atribuído pelo usuário atual.");
        }

        Usuario usuario = usuarioDAO.buscarPorId(idUsuario);
        usuario.setPerfil(novoPerfil);
        usuarioDAO.salvar(usuario);
    }
}
```

### 9.4 Boas práticas de isolamento

- Formulários diferentes para usuário comum e administrador.
- DTOs diferentes para operação comum e operação administrativa.
- Services separados por privilégio.
- Permissões diferentes por ação.
- Filas, jobs e integrações com credenciais próprias e privilégios mínimos.
- Banco ou schema separados quando houver dados com níveis de sigilo muito diferentes.
- Nunca reaproveite um endpoint administrativo em tela comum “só escondendo os campos”.

---

## 10. CWE-939 — Improper Authorization in Handler for Custom URL Scheme

### 10.1 Conceito

O produto usa um handler para um esquema de URL customizado, mas não restringe adequadamente quais atores podem invocá-lo. É comum em aplicações móveis, desktop ou integrações locais.

Embora seja menos comum em backend Java web tradicional, pode aparecer em aplicativos Android escritos em Java ou em aplicações desktop que registram schemes como:

```text
meuapp://abrir?id=10
meuapp://aprovar?id=10
meuapp://delete?id=10
```

### 10.2 Exemplo vulnerável em Android Java

```java
public class DeepLinkActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Uri uri = getIntent().getData();
        if (uri == null) {
            finish();
            return;
        }

        String action = uri.getQueryParameter("action");
        String id = uri.getQueryParameter("id");

        // Vulnerável: qualquer app/site que chamar o scheme pode disparar ação sensível.
        if ("cancelar".equals(action)) {
            new GuiaService().cancelarGuia(Long.valueOf(id));
        }

        finish();
    }
}
```

URL maliciosa:

```text
meuapp://guia?action=cancelar&id=123
```

### 10.3 Solução segura

```java
public class DeepLinkActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Uri uri = getIntent().getData();
        if (uri == null) {
            finish();
            return;
        }

        String action = uri.getQueryParameter("action");
        String id = uri.getQueryParameter("id");
        String token = uri.getQueryParameter("token");

        if (!deepLinkTokenService.validarTokenDeUsoUnico(token, action, id)) {
            negar();
            return;
        }

        UsuarioSessao usuario = sessaoLocal.obterUsuarioLogado();
        if (usuario == null || !usuario.possuiPermissao("GUIA_CANCELAR")) {
            negar();
            return;
        }

        if ("cancelar".equals(action)) {
            confirmarComUsuario(() -> new GuiaService().cancelarGuia(Long.valueOf(id), usuario));
        }
    }

    private void negar() {
        Toast.makeText(this, "Ação não autorizada.", Toast.LENGTH_SHORT).show();
        finish();
    }

    private void confirmarComUsuario(Runnable acao) {
        new AlertDialog.Builder(this)
                .setTitle("Confirmar operação")
                .setMessage("Deseja realmente executar esta ação?")
                .setPositiveButton("Confirmar", (dialog, which) -> acao.run())
                .setNegativeButton("Cancelar", null)
                .show();
    }
}
```

### 10.4 Regras práticas

- Não execute ação destrutiva diretamente a partir do deep link.
- Exija sessão válida.
- Exija permissão no servidor ou no backend chamado pelo app.
- Use token de uso único, expiração curta e vínculo com a ação.
- Peça confirmação para ações sensíveis.
- Não coloque segredo permanente dentro da URL.

---

## 11. CWE-842 — Placement of User into Incorrect Group

### 11.1 Conceito

O produto ou administrador coloca um usuário em grupo, perfil ou papel incorreto. Se o grupo incorreto tiver mais privilégios que o esperado, o usuário pode obter acesso indevido.

### 11.2 Exemplo vulnerável

```java
public class CadastroUsuarioAction extends Action {

    public ActionForward salvar(ActionMapping mapping,
                                ActionForm form,
                                HttpServletRequest request,
                                HttpServletResponse response) {

        CadastroUsuarioForm formulario = (CadastroUsuarioForm) form;

        Usuario usuario = new Usuario();
        usuario.setNome(formulario.getNome());
        usuario.setEmail(formulario.getEmail());

        // Vulnerável: perfil vem da requisição.
        usuario.setPerfil(formulario.getPerfil());

        usuarioDAO.salvar(usuario);
        return mapping.findForward("sucesso");
    }
}
```

Ataque: o usuário altera o request e envia:

```text
perfil=ADMINISTRADOR
```

### 11.3 Solução segura

```java
public class CadastroUsuarioAction extends Action {

    public ActionForward salvar(ActionMapping mapping,
                                ActionForm form,
                                HttpServletRequest request,
                                HttpServletResponse response) {

        CadastroUsuarioForm formulario = (CadastroUsuarioForm) form;

        Usuario usuario = new Usuario();
        usuario.setNome(formulario.getNome());
        usuario.setEmail(formulario.getEmail());

        // Seguro: perfil padrão definido no servidor.
        usuario.setPerfil("USUARIO_COMUM");

        usuarioDAO.salvar(usuario);
        return mapping.findForward("sucesso");
    }
}
```

Alteração de perfil deve ser operação administrativa separada:

```java
public class PerfilUsuarioAction extends Action {

    public ActionForward alterarPerfil(ActionMapping mapping,
                                       ActionForm form,
                                       HttpServletRequest request,
                                       HttpServletResponse response) {

        UsuarioAutenticado admin = AuthorizationGuard.exigirPermissao(request, "USUARIO_ALTERAR_PERFIL");
        AlterarPerfilForm formulario = (AlterarPerfilForm) form;

        String novoPerfil = formulario.getNovoPerfil();

        if (!politicaPerfil.permiteAtribuir(admin, novoPerfil)) {
            throw new AcessoNegadoException("Perfil não permitido para atribuição.");
        }

        usuarioService.alterarPerfil(formulario.getIdUsuario(), novoPerfil, admin);
        return mapping.findForward("sucesso");
    }
}
```

### 11.4 Validações recomendadas

- Perfil padrão deve ser definido no backend.
- Usuário não deve escolher o próprio grupo privilegiado.
- Mudança de perfil deve exigir permissão específica.
- Deve haver trilha de auditoria para alteração de grupo/perfil.
- Deve haver revisão periódica de usuários com perfis críticos.
- Perfis importados de integrações devem ser mapeados por allowlist.

---

## 12. CWE-1220 — Insufficient Granularity of Access Control

### 12.1 Conceito

O controle de acesso existe, mas é amplo demais. Ele não separa adequadamente ações, recursos, unidades, níveis de sigilo ou operações de leitura/escrita.

### 12.2 Exemplo vulnerável

```java
public class GuiaDepositoAction extends Action {

    public ActionForward cancelar(ActionMapping mapping,
                                  ActionForm form,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {

        UsuarioAutenticado usuario = AuthorizationGuard.exigirPermissao(request, "ADMIN");

        Long idGuia = Long.valueOf(request.getParameter("idGuia"));
        guiaService.cancelar(idGuia, usuario);

        return mapping.findForward("sucesso");
    }
}
```

Problema: a permissão `ADMIN` é genérica. Talvez o usuário possa administrar cadastros, mas não cancelar guia. Ou possa consultar guias da própria unidade, mas não cancelar guias de outra unidade.

### 12.3 Solução segura com permissões granulares

```java
public final class Permissoes {
    public static final String GUIA_CONSULTAR = "GUIA_CONSULTAR";
    public static final String GUIA_GERAR = "GUIA_GERAR";
    public static final String GUIA_REGERAR = "GUIA_REGERAR";
    public static final String GUIA_CANCELAR = "GUIA_CANCELAR";
    public static final String GUIA_BAIXAR_COMPROVANTE = "GUIA_BAIXAR_COMPROVANTE";
    public static final String GUIA_ACESSO_GLOBAL = "GUIA_ACESSO_GLOBAL";

    private Permissoes() {
    }
}
```

```java
public class GuiaDepositoAction extends Action {

    public ActionForward cancelar(ActionMapping mapping,
                                  ActionForm form,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {

        UsuarioAutenticado usuario = AuthorizationGuard.exigirPermissao(request, Permissoes.GUIA_CANCELAR);

        Long idGuia = Long.valueOf(request.getParameter("idGuia"));
        Guia guia = guiaDAO.buscarPorId(idGuia)
                .orElseThrow(() -> new AcessoNegadoException("Guia não encontrada ou sem acesso."));

        AuthorizationGuard.exigirMesmaUnidadeOuPermissao(
                usuario,
                guia.getCodUnidade(),
                Permissoes.GUIA_ACESSO_GLOBAL
        );

        guiaService.cancelar(guia, usuario);
        return mapping.findForward("sucesso");
    }
}
```

### 12.4 Matriz de acesso sugerida

| Recurso | Ação | Permissão granular | Escopo |
|---|---|---|---|
| Guia | Consultar | `GUIA_CONSULTAR` | própria unidade |
| Guia | Gerar | `GUIA_GERAR` | própria unidade |
| Guia | Regerar | `GUIA_REGERAR` | própria unidade |
| Guia | Cancelar | `GUIA_CANCELAR` | própria unidade + regra de status |
| Guia | Baixar comprovante | `GUIA_BAIXAR_COMPROVANTE` | própria unidade ou responsável |
| Guia | Acesso global | `GUIA_ACESSO_GLOBAL` | todas as unidades |
| Usuário | Alterar perfil | `USUARIO_ALTERAR_PERFIL` | perfis permitidos |
| Relatório | Exportar XLS/PDF | `RELATORIO_EXPORTAR` | dados autorizados |

### 12.5 Sinais de baixa granularidade

- Uma permissão permite ler, alterar, excluir e exportar.
- `ADMIN` aparece em muitas regras sem distinção de ação.
- O sistema valida perfil, mas não valida unidade, dono, status ou sigilo.
- Operação de consulta e operação destrutiva usam o mesmo controle.
- O botão é escondido, mas o endpoint é o mesmo.

---

## 13. CWE-1230 — Exposure of Sensitive Information Through Metadata

### 13.1 Conceito

O sistema protege o acesso direto ao dado sensível, mas deixa metadados acessíveis. Esses metadados podem permitir inferir a existência, tipo, conteúdo, estado ou padrão de uso do dado original.

Exemplos de metadados sensíveis:

- nome de arquivo;
- título de documento;
- número de procedimento;
- data de criação ou alteração;
- usuário responsável;
- unidade;
- status;
- contagem de registros;
- tamanho de arquivo;
- tags, classificação ou nível de sigilo;
- mensagem “registro existe, mas você não tem permissão”.

### 13.2 Exemplo vulnerável

```java
public class PesquisaDocumentoAction extends Action {

    public ActionForward pesquisar(ActionMapping mapping,
                                   ActionForm form,
                                   HttpServletRequest request,
                                   HttpServletResponse response) {

        UsuarioAutenticado usuario = AuthorizationGuard.exigirUsuario(request);
        PesquisaForm pesquisa = (PesquisaForm) form;

        // Vulnerável: a busca não retorna o conteúdo, mas revela metadados de documentos sigilosos.
        List<DocumentoResumoDTO> resultados = documentoDAO.pesquisarResumo(pesquisa.getTermo());

        request.setAttribute("resultados", resultados);
        return mapping.findForward("resultado");
    }
}
```

DTO problemático:

```java
public class DocumentoResumoDTO {
    private Long id;
    private String titulo;
    private String nomeArquivo;
    private String unidade;
    private LocalDateTime dataCriacao;
    private String nivelSigilo;
}
```

Mesmo sem baixar o documento, o usuário pode descobrir que existe um arquivo chamado:

```text
operacao-sigilosa-delegacia-x.pdf
```

### 13.3 Solução segura

Aplique autorização também sobre a busca e sobre os metadados retornados.

```java
public class PesquisaDocumentoAction extends Action {

    public ActionForward pesquisar(ActionMapping mapping,
                                   ActionForm form,
                                   HttpServletRequest request,
                                   HttpServletResponse response) {

        UsuarioAutenticado usuario = AuthorizationGuard.exigirPermissao(request, "DOCUMENTO_PESQUISAR");
        PesquisaForm pesquisa = (PesquisaForm) form;

        List<DocumentoResumoDTO> resultados = documentoDAO.pesquisarResumoAutorizado(
                pesquisa.getTermo(),
                usuario.getId(),
                usuario.getCodUnidade(),
                usuario.possuiPermissao("DOCUMENTO_PESQUISAR_GLOBAL")
        );

        request.setAttribute("resultados", resultados);
        return mapping.findForward("resultado");
    }
}
```

DAO ilustrativo:

```java
public class DocumentoDAO {

    public List<DocumentoResumoDTO> pesquisarResumoAutorizado(String termo,
                                                              Long idUsuario,
                                                              Long codUnidade,
                                                              boolean global) {
        String sql = """
                SELECT d.id_documento,
                       d.titulo_publico,
                       d.data_criacao,
                       d.cod_unidade
                  FROM documento d
                 WHERE lower(d.titulo_publico) LIKE lower(:termo)
                   AND (
                        :global = true
                        OR d.cod_unidade = :codUnidade
                        OR d.id_usuario_responsavel = :idUsuario
                   )
                   AND d.excluido = false
                """;

        return Collections.emptyList();
    }
}
```

### 13.4 Estratégias de redução de exposição

- Retorne apenas metadados necessários para a tela.
- Use título público diferente do nome real do arquivo.
- Não exponha `nivelSigilo` para quem não pode acessar o conteúdo.
- Aplique os mesmos filtros de autorização da consulta completa na consulta resumida.
- Não diferencie erro “não existe” de “sem permissão” quando a existência for sensível.
- Em estatísticas, aplique agregação mínima e evite contagens muito específicas.

---

## 14. Filtro de autorização por rota

Além de validar dentro da Action/Service, é útil ter uma camada centralizada para impedir acesso direto a rotas críticas.

```java
public class AuthorizationFilter implements Filter {

    private final Map<String, String> permissoesPorRota = Map.of(
            "/relatorioAdmin.do", "RELATORIO_ADMIN_GERAR",
            "/guiaDeposito/cancelar.do", "GUIA_CANCELAR",
            "/usuario/alterarPerfil.do", "USUARIO_ALTERAR_PERFIL"
    );

    @Override
    public void doFilter(ServletRequest servletRequest,
                         ServletResponse servletResponse,
                         FilterChain chain) throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;

        String path = normalizarPath(request);
        String permissao = permissoesPorRota.get(path);

        try {
            if (permissao != null) {
                AuthorizationGuard.exigirPermissao(request, permissao);
            } else {
                AuthorizationGuard.exigirUsuario(request);
            }

            chain.doFilter(request, response);
        } catch (AcessoNegadoException e) {
            UsuarioAutenticado usuario = obterUsuarioOuNulo(request);
            SecurityAuditLogger.acessoNegado(
                    usuario == null ? "anonimo" : usuario.getLogin(),
                    request.getMethod(),
                    path,
                    e.getMessage()
            );
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
        }
    }

    private String normalizarPath(HttpServletRequest request) {
        String contextPath = request.getContextPath();
        String uri = request.getRequestURI();
        String semContexto = uri.substring(contextPath.length());
        return URI.create(semContexto).normalize().getPath();
    }

    private UsuarioAutenticado obterUsuarioOuNulo(HttpServletRequest request) {
        try {
            return AuthorizationGuard.exigirUsuario(request);
        } catch (AcessoNegadoException e) {
            return null;
        }
    }
}
```

> Observação: o filtro por rota ajuda, mas não substitui a autorização por recurso. Um usuário pode ter acesso à rota `/baixarArquivo.do`, mas não a todos os arquivos.

---

## 15. Padrão recomendado para download de arquivo privado

Este padrão ajuda a cobrir CWE-425, CWE-552, CWE-639 e CWE-1230.

```java
public class ArquivoPrivadoController {

    public void baixar(HttpServletRequest request, HttpServletResponse response) throws IOException {
        UsuarioAutenticado usuario = AuthorizationGuard.exigirPermissao(request, "ARQUIVO_BAIXAR");

        Long idArquivo = Long.valueOf(request.getParameter("idArquivo"));

        ArquivoPrivado arquivo = arquivoDAO.buscarResumoPorId(idArquivo)
                .orElseThrow(() -> new AcessoNegadoException("Arquivo não encontrado ou sem autorização."));

        if (!arquivoPodeSerBaixado(usuario, arquivo)) {
            throw new AcessoNegadoException("Arquivo não encontrado ou sem autorização.");
        }

        Path base = Paths.get("/var/app/arquivos-privados").toAbsolutePath().normalize();
        Path path = base.resolve(arquivo.getNomeFisico()).normalize();

        if (!path.startsWith(base) || !Files.isRegularFile(path)) {
            throw new AcessoNegadoException("Arquivo não encontrado ou sem autorização.");
        }

        response.setContentType(arquivo.getContentTypeSeguro());
        response.setHeader("Content-Disposition", "attachment; filename=\"" + arquivo.getNomeDownloadSeguro() + "\"");
        Files.copy(path, response.getOutputStream());
    }

    private boolean arquivoPodeSerBaixado(UsuarioAutenticado usuario, ArquivoPrivado arquivo) {
        return usuario.possuiPermissao("ARQUIVO_BAIXAR_GLOBAL")
                || usuario.getCodUnidade().equals(arquivo.getCodUnidade())
                || usuario.getId().equals(arquivo.getIdUsuarioResponsavel());
    }
}
```

---

## 16. Comandos `grep` para revisão de código

### 16.1 Busca por Actions e endpoints críticos

```bash
grep -R "action=.*baixar\|action=.*gerar\|action=.*excluir\|action=.*cancelar\|action=.*alterar" -n src/main/webapp
grep -R "public ActionForward .*baixar\|public ActionForward .*excluir\|public ActionForward .*cancelar" -n src/main/java
grep -R "@DeleteMapping\|@PostMapping\|@PutMapping" -n src/main/java
```

### 16.2 Busca por identificadores controlados pelo usuário

```bash
grep -R "getParameter(\"id\|getParameter(\"cod\|getParameter(\"idArquivo\|getParameter(\"idDeposito" -n src/main/java
grep -R "form.getId\|form.getCod\|getCodUnidade\|getCodFuncionario" -n src/main/java
```

### 16.3 Busca por arquivos públicos e diretórios de upload

```bash
grep -R "uploads\|webapp\|getRealPath\|FileOutputStream\|Files.write" -n src/main/java src/main/webapp
grep -R "Content-Disposition\|application/pdf\|octet-stream\|getOutputStream" -n src/main/java
```

### 16.4 Busca por autorização fraca ou genérica

```bash
grep -R "isAdmin\|ADMIN\|perfil\|role\|grupo" -n src/main/java
grep -R "isLogado\|getSession(false)\|USUARIO_AUTENTICADO" -n src/main/java
grep -R "possuiPermissao" -n src/main/java
```

### 16.5 Busca por metadados expostos

```bash
grep -R "ResumoDTO\|SearchDTO\|listarResumo\|pesquisarResumo\|count\|quantidade" -n src/main/java
grep -R "nomeArquivo\|titulo\|nivelSigilo\|dataCriacao\|codUnidade" -n src/main/java src/main/webapp
```

---

## 17. Checklist prático de revisão

### 17.1 Para cada Action/endpoint

- [ ] Exige autenticação?
- [ ] Exige permissão específica?
- [ ] Valida o recurso acessado, não apenas a rota?
- [ ] Valida unidade, dono, responsável, status e nível de sigilo?
- [ ] Registra tentativa negada?
- [ ] Retorna erro genérico quando a existência do recurso for sensível?

### 17.2 Para cada download/exportação

- [ ] O arquivo está fora do web root?
- [ ] O nome físico é imprevisível?
- [ ] O download passa por Action/Controller?
- [ ] O ID do arquivo é validado contra o escopo do usuário?
- [ ] O caminho é normalizado antes do acesso?
- [ ] O nome de download é sanitizado?

### 17.3 Para cada tela de administração

- [ ] O acesso não depende apenas de menu/botão escondido?
- [ ] O backend valida permissão?
- [ ] O formulário não aceita perfil/grupo/codUnidade livremente?
- [ ] Alteração de perfil/grupo tem auditoria?
- [ ] Perfis administrativos são atribuídos por allowlist?

### 17.4 Para cada consulta/listagem

- [ ] A query já aplica filtro de autorização?
- [ ] A contagem respeita o mesmo filtro?
- [ ] Metadados sensíveis são ocultados?
- [ ] O usuário não consegue inferir a existência de registros sigilosos?

---

## 18. Testes sugeridos

### 18.1 Forced browsing

1. Acesse uma tela permitida.
2. Copie a URL de uma ação restrita.
3. Faça login com usuário sem permissão.
4. Cole a URL diretamente.
5. Resultado esperado: HTTP 403, redirect seguro ou mensagem de acesso negado.

### 18.2 IDOR / chave controlada pelo usuário

1. Acesse um registro permitido e capture o ID.
2. Troque o ID por outro sequencial.
3. Troque `codUnidade`, `idArquivo`, `idDeposito` ou `codFuncionario` no request.
4. Resultado esperado: o sistema não retorna dados de outro usuário/unidade.

### 18.3 Arquivo privado

1. Tente acessar o caminho físico ou URL direta do arquivo.
2. Tente baixar o arquivo via Action com usuário sem permissão.
3. Tente enumerar IDs.
4. Resultado esperado: sem download e sem vazamento de existência sensível.

### 18.4 Canonicalização

Teste entradas como:

```text
../admin/arquivo.pdf
publico/../sigiloso/documento.pdf
%2e%2e%2fsigiloso%2fdocumento.pdf
publico/%252e%252e/sigiloso/documento.pdf
./admin/acao.do
/admin/../admin/acao.do
```

Resultado esperado: normalização antes da autorização e bloqueio de acesso indevido.

### 18.5 Metadados

1. Pesquise por termo que existe em documento sigiloso.
2. Compare resultado com usuário autorizado e não autorizado.
3. Verifique contagens, títulos, nomes de arquivo, datas e status.
4. Resultado esperado: usuário não autorizado não vê conteúdo nem metadados capazes de revelar a existência do dado.

---

## 19. Resumo para prova

- **CWE-1212** é categoria de erros de autorização dentro da CWE-699.
- **CWE-425**: esconder link não protege URL. Toda rota restrita precisa de autorização.
- **CWE-551**: normalize/decodifique antes de autorizar. Nunca autorize usando caminho bruto.
- **CWE-552**: arquivo sensível não deve ficar em diretório público.
- **CWE-639**: não confie em ID vindo da request. Valide dono, unidade, escopo e permissão.
- **CWE-653**: separe módulos, DTOs, services e permissões de baixo e alto privilégio.
- **CWE-939**: deep links/custom URL schemes não podem executar ação sensível sem sessão, permissão, token e confirmação.
- **CWE-842**: perfil/grupo não deve ser definido livremente pelo usuário.
- **CWE-1220**: permissões genéricas são perigosas; use granularidade por ação e recurso.
- **CWE-1230**: metadados também podem vazar informação sensível.

---

## 20. Modelo mental simples

Antes de liberar qualquer operação, responda:

1. O usuário está autenticado?
2. Ele possui permissão para a ação?
3. Ele possui permissão para este recurso específico?
4. O recurso pertence ao escopo dele?
5. O identificador veio da request? Se sim, foi validado contra banco/regra de negócio?
6. A resposta revela existência, metadados ou detalhes que deveriam permanecer protegidos?

Se qualquer resposta for incerta, trate como acesso negado.

---

## 21. Referências oficiais

- CWE-699 — Software Development: `https://cwe.mitre.org/data/definitions/699.html`
- CWE-1212 — Authorization Errors: `https://cwe.mitre.org/data/definitions/1212.html`
- CWE-425 — Direct Request ('Forced Browsing'): `https://cwe.mitre.org/data/definitions/425.html`
- CWE-551 — Incorrect Behavior Order: Authorization Before Parsing and Canonicalization: `https://cwe.mitre.org/data/definitions/551.html`
- CWE-552 — Files or Directories Accessible to External Parties: `https://cwe.mitre.org/data/definitions/552.html`
- CWE-639 — Authorization Bypass Through User-Controlled Key: `https://cwe.mitre.org/data/definitions/639.html`
- CWE-653 — Improper Isolation or Compartmentalization: `https://cwe.mitre.org/data/definitions/653.html`
- CWE-939 — Improper Authorization in Handler for Custom URL Scheme: `https://cwe.mitre.org/data/definitions/939.html`
- CWE-842 — Placement of User into Incorrect Group: `https://cwe.mitre.org/data/definitions/842.html`
- CWE-1220 — Insufficient Granularity of Access Control: `https://cwe.mitre.org/data/definitions/1220.html`
- CWE-1230 — Exposure of Sensitive Information Through Metadata: `https://cwe.mitre.org/data/definitions/1230.html`
