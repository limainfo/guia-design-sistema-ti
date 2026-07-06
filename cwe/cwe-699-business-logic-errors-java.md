# CWE-699 - Software Development

## Category: Business Logic Errors - CWE-840

> **Objetivo do material:** documentar, de forma prática, as fraquezas da categoria **Business Logic Errors** da view **CWE-699 - Software Development**, com exemplos em **Java**, voltados para aplicações web, APIs REST, Struts/Servlet/JSP, serviços, DAOs e sistemas corporativos/legados.

---

## 1. Visão geral

A categoria **CWE-840 - Business Logic Errors** agrupa fraquezas que permitem ao atacante manipular regras de negócio aparentemente legítimas da aplicação.

Diferente de falhas mais diretas, como SQL Injection ou XSS, erros de lógica de negócio normalmente não aparecem apenas por análise sintática do código. Eles dependem do entendimento do fluxo funcional:

- quem é o dono do recurso;
- quem pode executar a ação;
- em que etapa a ação pode ocorrer;
- quantas vezes a ação pode ocorrer;
- qual limite de uso é aceitável;
- quando o recurso deve permanecer válido;
- quais regras devem ser validadas no servidor.

### Ponto importante para prova

**Business Logic Error** não significa necessariamente erro de sintaxe ou exceção. Muitas vezes o sistema “funciona”, mas permite um comportamento que viola a regra de negócio.

Exemplos comuns:

- usuário acessa registro de outro usuário mudando o `id` na URL;
- usuário solicita reembolso duas vezes;
- sistema permite cancelar item já finalizado;
- recuperação de senha permite takeover de conta;
- endpoint cria pedidos ilimitados sem limite ou throttling;
- arquivo temporário é removido antes do download terminar;
- workflow permite pular aprovação obrigatória.

---

## 2. CWEs abordadas

| CWE | Nome | Aplicação prática em Java |
|---:|---|---|
| 283 | Unverified Ownership | Não verificar se o recurso pertence ao usuário autenticado |
| 639 | Authorization Bypass Through User-Controlled Key | IDOR/BOLA por `id`, `codFuncionario`, `idPedido`, `codArquivo` etc. |
| 640 | Weak Password Recovery Mechanism for Forgotten Password | Recuperação de senha fraca ou previsível |
| 708 | Incorrect Ownership Assignment | Criar arquivo/recurso com dono/grupo incorreto |
| 770 | Allocation of Resources Without Limits or Throttling | Upload, busca, geração de PDF, relatório ou job sem limite |
| 826 | Premature Release of Resource During Expected Lifetime | Fechar/remover recurso antes do fim do uso esperado |
| 837 | Improper Enforcement of a Single, Unique Action | Permitir ação que deveria ocorrer uma única vez |
| 841 | Improper Enforcement of Behavioral Workflow | Permitir pular/inverter etapas obrigatórias do fluxo |

---

# 3. CWE-283 - Unverified Ownership

## 3.1 Conceito

A aplicação executa uma operação em um recurso sem confirmar que o recurso pertence ao usuário ou ator autenticado.

O problema é parecido com autorização, mas o foco está em **propriedade**.

Exemplos:

- baixar comprovante de outro usuário;
- cancelar solicitação que pertence a outra unidade;
- alterar endereço de envolvido de outro procedimento;
- excluir arquivo que não pertence ao processo atual;
- aprovar item criado por outra área sem verificar vínculo.

---

## 3.2 Exemplo vulnerável

```java
public ActionForward baixarComprovante(ActionMapping mapping,
        ActionForm form,
        HttpServletRequest request,
        HttpServletResponse response) throws Exception {

    Long idDeposito = Long.valueOf(request.getParameter("idDeposito"));

    DepositoJudicial deposito = depositoService.buscarPorId(idDeposito);

    // Vulnerável: não verifica se o depósito pertence à unidade/perfil do usuário logado.
    byte[] pdf = arquivoService.baixar(deposito.getCodArquivoComprovante());

    response.setContentType("application/pdf");
    response.getOutputStream().write(pdf);
    return null;
}
```

### Problema

Um usuário autenticado pode alterar o parâmetro:

```text
/deposito.do?action=baixarComprovante&idDeposito=1001
/deposito.do?action=baixarComprovante&idDeposito=1002
```

Se o sistema não validar propriedade, ele pode baixar comprovantes de outra unidade, outro processo ou outro usuário.

---

## 3.3 Solução corrigida

```java
public ActionForward baixarComprovante(ActionMapping mapping,
        ActionForm form,
        HttpServletRequest request,
        HttpServletResponse response) throws Exception {

    Usuario usuario = UsuarioUtil.getUsuarioLogado(request);
    Long idDeposito = Long.valueOf(request.getParameter("idDeposito"));

    DepositoJudicial deposito = depositoService.buscarPorId(idDeposito);

    if (deposito == null) {
        throw new ApplicationException("mensagem.erro.personalizada",
                new String[] { "Depósito não encontrado." });
    }

    if (!depositoService.usuarioPodeAcessarDeposito(usuario, deposito)) {
        auditoriaService.registrarTentativaAcessoIndevido(usuario, "DEPOSITO", idDeposito);
        throw new ApplicationException("mensagem.erro.personalizada",
                new String[] { "Usuário sem permissão para acessar este depósito." });
    }

    byte[] pdf = arquivoService.baixar(deposito.getCodArquivoComprovante());

    response.setContentType("application/pdf");
    response.getOutputStream().write(pdf);
    return null;
}
```

### Boa prática

A validação de propriedade deve ficar no **service/facade**, não apenas na tela.

```java
public boolean usuarioPodeAcessarDeposito(Usuario usuario, DepositoJudicial deposito) {
    if (usuario == null || deposito == null) {
        return false;
    }

    if (usuario.isAdministrador()) {
        return true;
    }

    return usuario.getCodUnidade().equals(deposito.getCodUnidadeResponsavel());
}
```

---

# 4. CWE-639 - Authorization Bypass Through User-Controlled Key

## 4.1 Conceito

A aplicação permite acesso a dados de outro usuário porque utiliza uma chave controlada pelo cliente sem validar autorização no servidor.

Também aparece como:

- IDOR - Insecure Direct Object Reference;
- BOLA - Broken Object Level Authorization;
- falha de autorização horizontal.

---

## 4.2 Exemplo vulnerável

```java
@Path("/pedidos")
public class PedidoResource {

    @GET
    @Path("/{idPedido}")
    public Response consultar(@PathParam("idPedido") Long idPedido) {
        Pedido pedido = pedidoService.buscarPorId(idPedido);
        return Response.ok(pedido).build();
    }
}
```

### Problema

O usuário controla `idPedido`. Se o backend não filtrar pelo usuário autenticado, ele pode acessar pedidos de terceiros.

```text
GET /api/pedidos/500
GET /api/pedidos/501
GET /api/pedidos/502
```

---

## 4.3 Solução corrigida

```java
@Path("/pedidos")
public class PedidoResource {

    @GET
    @Path("/{idPedido}")
    public Response consultar(@PathParam("idPedido") Long idPedido,
                              @Context HttpServletRequest request) {

        Usuario usuario = UsuarioUtil.getUsuarioLogado(request);

        Pedido pedido = pedidoService.buscarPedidoAutorizado(idPedido, usuario);

        if (pedido == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        return Response.ok(pedido).build();
    }
}
```

```java
public Pedido buscarPedidoAutorizado(Long idPedido, Usuario usuario) {
    if (usuario.isAdministrador()) {
        return pedidoDAO.buscarPorId(idPedido);
    }

    return pedidoDAO.buscarPorIdEUsuario(idPedido, usuario.getId());
}
```

```java
public Pedido buscarPorIdEUsuario(Long idPedido, Long idUsuario) {
    String sql = """
        SELECT *
          FROM pedido
         WHERE id_pedido = :idPedido
           AND id_usuario = :idUsuario
    """;

    return em.createNativeQuery(sql, Pedido.class)
            .setParameter("idPedido", idPedido)
            .setParameter("idUsuario", idUsuario)
            .getResultStream()
            .findFirst()
            .orElse(null);
}
```

### Regra prática

Não basta fazer:

```java
pedidoDAO.buscarPorId(idPedido);
```

Prefira buscar diretamente com escopo autorizado:

```java
pedidoDAO.buscarPorIdEUsuario(idPedido, usuario.getId());
```

Assim, mesmo que o programador esqueça uma validação depois, a consulta já nasce restrita.

---

# 5. CWE-640 - Weak Password Recovery Mechanism for Forgotten Password

## 5.1 Conceito

O mecanismo de recuperação de senha permite recuperar ou alterar a senha sem conhecer a senha anterior, mas é fraco.

Exemplos:

- token previsível;
- token sem expiração;
- pergunta secreta simples;
- link reutilizável;
- envio da senha antiga por e-mail;
- alteração de senha apenas com CPF/data de nascimento;
- token salvo em texto claro;
- resposta diferente revelando se o e-mail existe.

---

## 5.2 Exemplo vulnerável: token previsível

```java
public void solicitarRecuperacaoSenha(String email) {
    Usuario usuario = usuarioDAO.buscarPorEmail(email);

    if (usuario == null) {
        return;
    }

    // Vulnerável: token previsível baseado no ID e timestamp.
    String token = usuario.getId() + "-" + System.currentTimeMillis();

    recuperacaoDAO.salvarToken(usuario.getId(), token);

    emailService.enviar(email,
            "Recuperação de senha",
            "Acesse: https://sistema/resetar?token=" + token);
}
```

### Problemas

- token fácil de prever;
- pode ser reutilizado;
- pode não expirar;
- pode ficar salvo em texto claro;
- pode ser usado por força bruta.

---

## 5.3 Solução corrigida

```java
public void solicitarRecuperacaoSenha(String email) {
    Usuario usuario = usuarioDAO.buscarPorEmail(email);

    // Sempre responder genericamente no frontend.
    if (usuario == null) {
        auditoriaService.registrarSolicitacaoRecuperacao(email, false);
        return;
    }

    String token = gerarTokenSeguro();
    String tokenHash = hashToken(token);

    RecuperacaoSenha recuperacao = new RecuperacaoSenha();
    recuperacao.setIdUsuario(usuario.getId());
    recuperacao.setTokenHash(tokenHash);
    recuperacao.setDataCriacao(LocalDateTime.now());
    recuperacao.setDataExpiracao(LocalDateTime.now().plusMinutes(15));
    recuperacao.setUtilizado(false);

    recuperacaoDAO.salvar(recuperacao);

    emailService.enviar(usuario.getEmail(),
            "Recuperação de senha",
            "Acesse o link para redefinir sua senha: https://sistema/resetar?token=" + token);
}

private String gerarTokenSeguro() {
    byte[] bytes = new byte[32];
    new SecureRandom().nextBytes(bytes);
    return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
}

private String hashToken(String token) {
    try {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        byte[] hash = digest.digest(token.getBytes(StandardCharsets.UTF_8));
        return Base64.getEncoder().encodeToString(hash);
    } catch (NoSuchAlgorithmException e) {
        throw new IllegalStateException("Algoritmo de hash indisponível", e);
    }
}
```

---

## 5.4 Validação segura do token

```java
public void redefinirSenha(String token, String novaSenha) {
    String tokenHash = hashToken(token);

    RecuperacaoSenha recuperacao = recuperacaoDAO.buscarPorHash(tokenHash);

    if (recuperacao == null
            || recuperacao.isUtilizado()
            || recuperacao.getDataExpiracao().isBefore(LocalDateTime.now())) {
        throw new ApplicationException("mensagem.erro.personalizada",
                new String[] { "Link de recuperação inválido ou expirado." });
    }

    politicaSenhaService.validar(novaSenha);

    usuarioDAO.atualizarSenha(recuperacao.getIdUsuario(), passwordEncoder.hash(novaSenha));
    recuperacaoDAO.marcarComoUtilizado(recuperacao.getId());

    auditoriaService.registrarSenhaRedefinida(recuperacao.getIdUsuario());
}
```

### Checklist para recuperação de senha

- token aleatório com `SecureRandom`;
- token com alta entropia;
- token salvo como hash;
- expiração curta;
- uso único;
- resposta genérica ao solicitar recuperação;
- auditoria;
- rate limit por IP, usuário e e-mail;
- não enviar senha antiga;
- não usar pergunta secreta fraca.

---

# 6. CWE-708 - Incorrect Ownership Assignment

## 6.1 Conceito

O sistema cria, move, restaura ou compartilha recurso com dono, grupo ou escopo incorreto.

Em Java corporativo isso pode aparecer como:

- arquivo temporário criado em diretório público;
- arquivo anexado ao processo errado;
- comprovante vinculado ao usuário/unidade errada;
- documento importado com `codInquerito` incorreto;
- registro criado com `idUsuarioDono` vindo do formulário;
- permissão herdada indevidamente de outro objeto;
- arquivo físico salvo com permissões amplas no sistema operacional.

---

## 6.2 Exemplo vulnerável: dono vindo do request

```java
public void criarDocumento(HttpServletRequest request, byte[] conteudo) {
    Long idUsuarioDono = Long.valueOf(request.getParameter("idUsuarioDono"));
    Long idProcesso = Long.valueOf(request.getParameter("idProcesso"));

    Documento doc = new Documento();
    doc.setIdUsuarioDono(idUsuarioDono); // Vulnerável
    doc.setIdProcesso(idProcesso);
    doc.setConteudo(conteudo);

    documentoDAO.salvar(doc);
}
```

### Problema

O cliente controla o dono do recurso.

Um atacante pode criar documento em nome de outro usuário ou associar arquivo a processo indevido.

---

## 6.3 Solução corrigida

```java
public void criarDocumento(HttpServletRequest request, byte[] conteudo) {
    Usuario usuario = UsuarioUtil.getUsuarioLogado(request);
    Long idProcesso = Long.valueOf(request.getParameter("idProcesso"));

    Processo processo = processoService.buscarProcessoAutorizado(idProcesso, usuario);

    if (processo == null) {
        throw new ApplicationException("mensagem.erro.personalizada",
                new String[] { "Processo não encontrado ou sem permissão." });
    }

    Documento doc = new Documento();
    doc.setIdUsuarioDono(usuario.getId());
    doc.setCodUnidadeDona(usuario.getCodUnidade());
    doc.setIdProcesso(processo.getId());
    doc.setConteudo(conteudo);

    documentoDAO.salvar(doc);
}
```

### Regra prática

Campos de propriedade devem ser derivados do contexto autenticado ou do recurso pai validado.

Evite aceitar do cliente:

```text
idUsuarioDono
codUnidadeDona
perfilDono
grupoDono
idConta
idTenant
```

---

## 6.4 Exemplo com arquivo temporário

### Vulnerável

```java
Path arquivo = Paths.get("/tmp/relatorio.pdf");
Files.write(arquivo, pdf);
```

Problemas:

- nome previsível;
- possível sobrescrita;
- possível leitura por outro processo/usuário;
- compartilhamento indevido em ambiente multiusuário.

### Corrigido

```java
Path diretorioSeguro = Paths.get(System.getProperty("java.io.tmpdir"), "meu-sistema");
Files.createDirectories(diretorioSeguro);

Path arquivo = Files.createTempFile(diretorioSeguro, "relatorio-", ".pdf");
Files.write(arquivo, pdf, StandardOpenOption.WRITE);

// Em Linux/Unix, quando aplicável:
try {
    Set<PosixFilePermission> permissoes = PosixFilePermissions.fromString("rw-------");
    Files.setPosixFilePermissions(arquivo, permissoes);
} catch (UnsupportedOperationException ignored) {
    // Sistema de arquivos não POSIX, tratar por configuração do ambiente.
}
```

---

# 7. CWE-770 - Allocation of Resources Without Limits or Throttling

## 7.1 Conceito

A aplicação aloca recursos sem limite ou controle de frequência.

Recursos afetados:

- memória;
- CPU;
- threads;
- conexões;
- arquivos;
- sessões;
- registros em banco;
- chamadas externas;
- geração de PDF/XLS;
- consultas em tabelas grandes.

---

## 7.2 Exemplo vulnerável: relatório sem limite

```java
public List<DepositoJudicial> consultarRelatorio(ParametrosRelatorioDTO filtros) {
    // Vulnerável: consulta sem limite, sem período obrigatório e sem paginação.
    return depositoDAO.listarDepositosComFiltro(filtros);
}
```

### Problema

Um usuário pode solicitar relatório sem filtros, consumindo CPU, memória e banco.

```text
GET /relatorioDepositos?dataInicio=&dataFim=&unidade=&status=
```

---

## 7.3 Solução corrigida

```java
public ResultadoPaginado<DepositoJudicial> consultarRelatorio(ParametrosRelatorioDTO filtros,
                                                              Usuario usuario) {
    validarFiltrosObrigatorios(filtros);

    int pagina = Math.max(filtros.getPagina(), 1);
    int tamanho = Math.min(Math.max(filtros.getTamanhoPagina(), 10), 100);

    filtros.setPagina(pagina);
    filtros.setTamanhoPagina(tamanho);

    if (!rateLimitService.permitir(usuario.getId(), "RELATORIO_DEPOSITOS")) {
        throw new ApplicationException("mensagem.erro.personalizada",
                new String[] { "Muitas solicitações. Aguarde antes de tentar novamente." });
    }

    return depositoDAO.listarDepositosComFiltroPaginado(filtros, usuario);
}

private void validarFiltrosObrigatorios(ParametrosRelatorioDTO filtros) {
    if (filtros.getDataInicio() == null || filtros.getDataFim() == null) {
        throw new ApplicationException("mensagem.erro.personalizada",
                new String[] { "Informe o período do relatório." });
    }

    long dias = ChronoUnit.DAYS.between(filtros.getDataInicio(), filtros.getDataFim());

    if (dias > 90) {
        throw new ApplicationException("mensagem.erro.personalizada",
                new String[] { "O período máximo permitido é de 90 dias." });
    }
}
```

---

## 7.4 Exemplo vulnerável: upload sem limite

```java
public void upload(Part arquivo) throws IOException {
    byte[] conteudo = arquivo.getInputStream().readAllBytes();
    arquivoService.salvar(conteudo);
}
```

### Problemas

- carrega tudo em memória;
- não limita tamanho;
- não valida tipo;
- pode causar DoS.

---

## 7.5 Solução corrigida

```java
private static final long TAMANHO_MAXIMO_UPLOAD = 10L * 1024L * 1024L; // 10 MB

public void upload(Part arquivo, Usuario usuario) throws IOException {
    if (arquivo == null || arquivo.getSize() == 0) {
        throw new ApplicationException("mensagem.erro.personalizada",
                new String[] { "Arquivo não informado." });
    }

    if (arquivo.getSize() > TAMANHO_MAXIMO_UPLOAD) {
        throw new ApplicationException("mensagem.erro.personalizada",
                new String[] { "Arquivo excede o tamanho máximo permitido." });
    }

    if (!rateLimitService.permitir(usuario.getId(), "UPLOAD_DOCUMENTO")) {
        throw new ApplicationException("mensagem.erro.personalizada",
                new String[] { "Limite de uploads excedido." });
    }

    try (InputStream in = new BufferedInputStream(arquivo.getInputStream())) {
        arquivoService.salvarStreaming(in, arquivo.getSubmittedFileName(), arquivo.getSize());
    }
}
```

### Mitigações práticas

- paginação obrigatória;
- limite de período;
- tamanho máximo de upload;
- timeout em chamadas externas;
- limite de geração de PDF;
- fila para jobs pesados;
- rate limit por usuário/IP;
- cache para consultas repetidas;
- pool de conexões;
- circuit breaker para integrações externas.

---

# 8. CWE-826 - Premature Release of Resource During Expected Lifetime

## 8.1 Conceito

A aplicação libera um recurso antes do fim esperado de uso.

Em Java, isso pode ocorrer com:

- fechar `InputStream` antes do framework terminar a resposta;
- deletar arquivo temporário antes do download;
- fechar conexão manualmente antes de processamento assíncrono;
- invalidar sessão antes de gravar auditoria;
- remover token antes de confirmar transação;
- limpar objeto em cache ainda usado por outro fluxo.

---

## 8.2 Exemplo vulnerável: deletar arquivo antes do envio terminar

```java
public void baixarRelatorio(HttpServletResponse response, Long idRelatorio) throws IOException {
    Path arquivo = relatorioService.gerarPdfTemporario(idRelatorio);

    try (InputStream in = Files.newInputStream(arquivo)) {
        response.setContentType("application/pdf");
        in.transferTo(response.getOutputStream());
    } finally {
        // Vulnerável em alguns cenários: pode remover antes do container concluir flush/commit.
        Files.deleteIfExists(arquivo);
    }
}
```

### Observação

Em muitos casos simples o código acima funciona, mas em cenários com streaming, resposta assíncrona, proxy, buffering ou erro de rede, a remoção prematura pode causar falha parcial no download.

---

## 8.3 Solução corrigida: gerar em memória quando o arquivo é pequeno

```java
public void baixarRelatorio(HttpServletResponse response, Long idRelatorio) throws IOException {
    byte[] pdf = relatorioService.gerarPdf(idRelatorio);

    response.setContentType("application/pdf");
    response.setHeader("Content-Disposition", "inline; filename=relatorio.pdf");
    response.setContentLength(pdf.length);

    try (ServletOutputStream out = response.getOutputStream()) {
        out.write(pdf);
        out.flush();
    }
}
```

---

## 8.4 Solução corrigida: ciclo de vida controlado para arquivo temporário

```java
public void baixarRelatorio(HttpServletResponse response, Long idRelatorio) throws IOException {
    Path arquivo = relatorioService.gerarPdfTemporario(idRelatorio);

    response.setContentType("application/pdf");
    response.setHeader("Content-Disposition", "inline; filename=relatorio.pdf");
    response.setHeader("X-Temp-File-Id", arquivo.getFileName().toString());

    try (InputStream in = Files.newInputStream(arquivo);
         ServletOutputStream out = response.getOutputStream()) {

        byte[] buffer = new byte[8192];
        int lidos;

        while ((lidos = in.read(buffer)) != -1) {
            out.write(buffer, 0, lidos);
        }

        out.flush();
    }

    // Opção: remover por job de limpeza posterior, não no fluxo crítico do download.
    limpezaArquivoTemporarioService.agendarRemocao(arquivo, Duration.ofHours(1));
}
```

---

## 8.5 Exemplo vulnerável: fechar recurso compartilhado

```java
public class ClienteHttpCompartilhado {

    private final CloseableHttpClient client = HttpClients.createDefault();

    public String consultar(String url) throws IOException {
        try (CloseableHttpResponse response = client.execute(new HttpGet(url))) {
            return EntityUtils.toString(response.getEntity());
        } finally {
            // Vulnerável: fecha cliente compartilhado usado por outras chamadas.
            client.close();
        }
    }
}
```

### Corrigido

```java
public class ClienteHttpCompartilhado implements Closeable {

    private final CloseableHttpClient client = HttpClients.createDefault();

    public String consultar(String url) throws IOException {
        try (CloseableHttpResponse response = client.execute(new HttpGet(url))) {
            return EntityUtils.toString(response.getEntity());
        }
    }

    @Override
    public void close() throws IOException {
        client.close();
    }
}
```

O recurso compartilhado deve ser fechado no ciclo de vida do componente, não a cada chamada.

---

# 9. CWE-837 - Improper Enforcement of a Single, Unique Action

## 9.1 Conceito

A aplicação deveria permitir uma ação apenas uma vez, mas não garante essa unicidade.

Exemplos:

- votar mais de uma vez;
- usar cupom várias vezes;
- pagar a mesma guia duas vezes;
- solicitar reembolso duplicado;
- confirmar cadastro duas vezes;
- anexar comprovante duplicado;
- reenviar uma transação financeira;
- executar duas vezes um callback de pagamento.

---

## 9.2 Exemplo vulnerável: double submit

```java
public void confirmarPagamento(Long idGuia, Usuario usuario) {
    Guia guia = guiaDAO.buscarPorId(idGuia);

    if (!"PENDENTE".equals(guia.getStatus())) {
        throw new ApplicationException("mensagem.erro.personalizada",
                new String[] { "Guia não está pendente." });
    }

    pagamentoGateway.confirmar(guia);
    guiaDAO.atualizarStatus(idGuia, "PAGA");
}
```

### Problema

Duas requisições simultâneas podem passar pela validação antes da atualização do status.

```text
Thread A: consulta status PENDENTE
Thread B: consulta status PENDENTE
Thread A: confirma pagamento
Thread B: confirma pagamento novamente
```

---

## 9.3 Solução corrigida: atualização atômica

```java
@Transactional
public void confirmarPagamento(Long idGuia, Usuario usuario) {
    int atualizados = guiaDAO.marcarComoProcessandoSePendente(idGuia);

    if (atualizados == 0) {
        throw new ApplicationException("mensagem.erro.personalizada",
                new String[] { "Guia já processada ou indisponível." });
    }

    try {
        Guia guia = guiaDAO.buscarPorId(idGuia);
        pagamentoGateway.confirmar(guia);
        guiaDAO.atualizarStatus(idGuia, "PAGA");
    } catch (Exception e) {
        guiaDAO.atualizarStatus(idGuia, "ERRO_PROCESSAMENTO");
        throw e;
    }
}
```

```java
public int marcarComoProcessandoSePendente(Long idGuia) {
    String sql = """
        UPDATE guia
           SET status = 'PROCESSANDO',
               data_atualizacao = CURRENT_TIMESTAMP
         WHERE id_guia = :idGuia
           AND status = 'PENDENTE'
    """;

    return em.createNativeQuery(sql)
            .setParameter("idGuia", idGuia)
            .executeUpdate();
}
```

---

## 9.4 Solução com chave de idempotência

```java
public ResultadoPagamento pagar(PagamentoRequest request, Usuario usuario) {
    String chave = request.getIdempotencyKey();

    if (StringUtils.isBlank(chave)) {
        throw new ApplicationException("mensagem.erro.personalizada",
                new String[] { "Chave de idempotência obrigatória." });
    }

    Optional<ResultadoPagamento> resultadoExistente = idempotenciaDAO.buscarResultado(usuario.getId(), chave);

    if (resultadoExistente.isPresent()) {
        return resultadoExistente.get();
    }

    idempotenciaDAO.registrarInicio(usuario.getId(), chave);

    ResultadoPagamento resultado = pagamentoService.executar(request, usuario);

    idempotenciaDAO.registrarResultado(usuario.getId(), chave, resultado);

    return resultado;
}
```

### Banco de dados

```sql
CREATE UNIQUE INDEX uk_idempotencia_usuario_chave
    ON idempotencia_requisicao (id_usuario, chave);
```

### Boas práticas

- usar constraint única no banco;
- usar transação;
- usar lock otimista/pessimista quando necessário;
- usar chave de idempotência em APIs críticas;
- tratar callback externo como idempotente;
- nunca confiar apenas em botão desabilitado no frontend.

---

# 10. CWE-841 - Improper Enforcement of Behavioral Workflow

## 10.1 Conceito

A aplicação não garante que as etapas obrigatórias de um fluxo sejam seguidas na ordem correta.

Exemplos:

- aprovar sem revisar;
- pagar sem gerar guia;
- finalizar compra sem confirmar pagamento;
- assinar contrato sem validar documentação;
- mudar status diretamente por parâmetro;
- anexar comprovante sem processo válido;
- liberar financiamento sem etapa de vistoria;
- pular aceite de termos;
- executar Action diretamente sem passar pela tela anterior.

---

## 10.2 Exemplo vulnerável: status controlado pelo cliente

```java
public void atualizarStatus(HttpServletRequest request) {
    Long idSolicitacao = Long.valueOf(request.getParameter("idSolicitacao"));
    String novoStatus = request.getParameter("status");

    // Vulnerável: cliente escolhe qualquer status.
    solicitacaoDAO.atualizarStatus(idSolicitacao, novoStatus);
}
```

### Problema

Um usuário pode forçar transições indevidas:

```text
PENDENTE -> APROVADA
PENDENTE -> FINALIZADA
EM_ANALISE -> PAGA
```

---

## 10.3 Solução corrigida: máquina de estados

```java
public enum StatusSolicitacao {
    RASCUNHO,
    ENVIADA,
    EM_ANALISE,
    APROVADA,
    REPROVADA,
    FINALIZADA
}
```

```java
public class WorkflowSolicitacaoService {

    private static final Map<StatusSolicitacao, Set<StatusSolicitacao>> TRANSICOES_PERMITIDAS = Map.of(
            StatusSolicitacao.RASCUNHO, Set.of(StatusSolicitacao.ENVIADA),
            StatusSolicitacao.ENVIADA, Set.of(StatusSolicitacao.EM_ANALISE),
            StatusSolicitacao.EM_ANALISE, Set.of(StatusSolicitacao.APROVADA, StatusSolicitacao.REPROVADA),
            StatusSolicitacao.APROVADA, Set.of(StatusSolicitacao.FINALIZADA),
            StatusSolicitacao.REPROVADA, Set.of(),
            StatusSolicitacao.FINALIZADA, Set.of()
    );

    public void alterarStatus(Long idSolicitacao,
                              StatusSolicitacao novoStatus,
                              Usuario usuario) {

        Solicitacao solicitacao = solicitacaoDAO.buscarPorId(idSolicitacao);

        if (!usuarioPodeExecutarTransicao(usuario, solicitacao, novoStatus)) {
            throw new ApplicationException("mensagem.erro.personalizada",
                    new String[] { "Usuário sem permissão para executar esta transição." });
        }

        validarTransicao(solicitacao.getStatus(), novoStatus);
        validarPreCondicoes(solicitacao, novoStatus);

        solicitacaoDAO.atualizarStatus(idSolicitacao, novoStatus);
        auditoriaService.registrarTransicao(usuario, idSolicitacao, solicitacao.getStatus(), novoStatus);
    }

    private void validarTransicao(StatusSolicitacao atual, StatusSolicitacao novo) {
        Set<StatusSolicitacao> permitidos = TRANSICOES_PERMITIDAS.getOrDefault(atual, Set.of());

        if (!permitidos.contains(novo)) {
            throw new ApplicationException("mensagem.erro.personalizada",
                    new String[] { "Transição de status inválida: " + atual + " -> " + novo });
        }
    }

    private void validarPreCondicoes(Solicitacao solicitacao, StatusSolicitacao novoStatus) {
        if (novoStatus == StatusSolicitacao.APROVADA && !solicitacao.isDocumentacaoCompleta()) {
            throw new ApplicationException("mensagem.erro.personalizada",
                    new String[] { "Não é possível aprovar sem documentação completa." });
        }

        if (novoStatus == StatusSolicitacao.FINALIZADA && !solicitacao.isPagamentoConfirmado()) {
            throw new ApplicationException("mensagem.erro.personalizada",
                    new String[] { "Não é possível finalizar sem pagamento confirmado." });
        }
    }
}
```

---

## 10.4 Exemplo em Struts: Action direta pulando etapa

### Vulnerável

```java
public ActionForward confirmar(ActionMapping mapping,
        ActionForm form,
        HttpServletRequest request,
        HttpServletResponse response) throws Exception {

    PedidoForm pedidoForm = (PedidoForm) form;

    pedidoService.confirmarPedido(pedidoForm.getIdPedido());

    return mapping.findForward("sucesso");
}
```

### Problema

O usuário pode chamar diretamente:

```text
/pedido.do?action=confirmar&idPedido=123
```

Mesmo sem passar por validação, revisão, aceite de termos ou cálculo de valor.

---

### Corrigido

```java
public ActionForward confirmar(ActionMapping mapping,
        ActionForm form,
        HttpServletRequest request,
        HttpServletResponse response) throws Exception {

    Usuario usuario = UsuarioUtil.getUsuarioLogado(request);
    PedidoForm pedidoForm = (PedidoForm) form;

    pedidoService.confirmarPedido(pedidoForm.getIdPedido(), usuario);

    return mapping.findForward("sucesso");
}
```

```java
@Transactional
public void confirmarPedido(Long idPedido, Usuario usuario) {
    Pedido pedido = pedidoDAO.buscarPedidoAutorizado(idPedido, usuario);

    if (pedido == null) {
        throw new ApplicationException("mensagem.erro.personalizada",
                new String[] { "Pedido não encontrado ou sem permissão." });
    }

    if (!StatusPedido.REVISADO.equals(pedido.getStatus())) {
        throw new ApplicationException("mensagem.erro.personalizada",
                new String[] { "Pedido deve estar revisado antes da confirmação." });
    }

    if (!pedido.isTermoAceito()) {
        throw new ApplicationException("mensagem.erro.personalizada",
                new String[] { "Aceite dos termos é obrigatório." });
    }

    if (!pedido.isValorCalculado()) {
        throw new ApplicationException("mensagem.erro.personalizada",
                new String[] { "Valor do pedido ainda não foi calculado." });
    }

    pedidoDAO.atualizarStatus(idPedido, StatusPedido.CONFIRMADO);
}
```

---

# 11. Serviço utilitário: BusinessRuleGuard

```java
public final class BusinessRuleGuard {

    private BusinessRuleGuard() {
    }

    public static void require(boolean condition, String mensagem) {
        if (!condition) {
            throw new ApplicationException("mensagem.erro.personalizada",
                    new String[] { mensagem });
        }
    }

    public static void requireNotNull(Object value, String mensagem) {
        if (value == null) {
            throw new ApplicationException("mensagem.erro.personalizada",
                    new String[] { mensagem });
        }
    }

    public static void requireOwner(Long donoEsperado, Long donoAtual) {
        if (donoEsperado == null || !donoEsperado.equals(donoAtual)) {
            throw new ApplicationException("mensagem.erro.personalizada",
                    new String[] { "Recurso não pertence ao usuário autenticado." });
        }
    }

    public static void requireStatus(Object atual, Object esperado, String mensagem) {
        if (!Objects.equals(atual, esperado)) {
            throw new ApplicationException("mensagem.erro.personalizada",
                    new String[] { mensagem });
        }
    }
}
```

Uso:

```java
BusinessRuleGuard.requireOwner(usuario.getId(), pedido.getIdUsuario());
BusinessRuleGuard.requireStatus(pedido.getStatus(), StatusPedido.REVISADO,
        "Pedido deve estar revisado antes da confirmação.");
```

---

# 12. Padrões recomendados

## 12.1 Buscar recurso já autorizado

Prefira:

```java
Pedido pedido = pedidoDAO.buscarPorIdEUsuario(idPedido, usuario.getId());
```

Evite:

```java
Pedido pedido = pedidoDAO.buscarPorId(idPedido);
if (!pedido.getIdUsuario().equals(usuario.getId())) {
    throw new SecurityException();
}
```

A segunda abordagem é aceitável, mas mais fácil de esquecer em algum ponto.

---

## 12.2 Não aceitar campos críticos do cliente

Campos perigosos em formulário/request:

```text
idUsuario
idUsuarioDono
codUnidade
perfil
grupo
role
status
aprovado
isAdmin
valorFinal
quantidadeDisponivel
idTenant
codArquivo
```

Esses campos devem vir do servidor, sessão, banco ou regra de negócio validada.

---

## 12.3 Toda ação crítica deve validar

Para ações críticas, valide sempre:

1. usuário autenticado;
2. permissão funcional;
3. propriedade/escopo do recurso;
4. estado atual do recurso;
5. transição permitida;
6. pré-condições de negócio;
7. unicidade/idempotência;
8. limite de uso;
9. auditoria.

---

# 13. Comandos de busca no código

## 13.1 Procurar uso direto de IDs do request

```bash
grep -R "getParameter(\"id" -n src/main/java
```

```bash
grep -R "getParameter(\"cod" -n src/main/java
```

## 13.2 Procurar atualização direta de status

```bash
grep -R "setStatus" -n src/main/java
```

```bash
grep -R "atualizarStatus" -n src/main/java
```

## 13.3 Procurar endpoints críticos sem usuário logado

```bash
grep -R "public ActionForward" -n src/main/java | grep -i confirmar
```

```bash
grep -R "@Path" -n src/main/java
```

## 13.4 Procurar criação de arquivo temporário insegura

```bash
grep -R "File.createTempFile\|Files.createTempFile\|/tmp/" -n src/main/java
```

## 13.5 Procurar ausência de paginação/limite

```bash
grep -R "getResultList" -n src/main/java
```

```bash
grep -R "SELECT \*" -n src/main/java
```

## 13.6 Procurar recuperação de senha

```bash
grep -Ri "recupera\|reset\|senha\|token" src/main/java
```

---

# 14. Checklist de revisão

## CWE-283 / CWE-639

- [ ] O recurso pertence ao usuário/unidade/tenant autenticado?
- [ ] O ID recebido do cliente é validado no servidor?
- [ ] A consulta já aplica o escopo autorizado?
- [ ] Existe teste tentando acessar recurso de outro usuário?

## CWE-640

- [ ] Token de recuperação é aleatório e forte?
- [ ] Token expira?
- [ ] Token é de uso único?
- [ ] Token é salvo como hash?
- [ ] Existe rate limit?
- [ ] A resposta evita revelar se o e-mail existe?

## CWE-708

- [ ] O dono do recurso é definido pelo servidor?
- [ ] Arquivos temporários têm nome imprevisível?
- [ ] Recursos são vinculados ao processo/unidade corretos?
- [ ] Permissões de arquivo/diretório são restritas?

## CWE-770

- [ ] Existe limite de tamanho?
- [ ] Existe paginação?
- [ ] Existe timeout?
- [ ] Existe rate limit?
- [ ] Existem limites por usuário/IP?
- [ ] Relatórios grandes usam fila/job assíncrono?

## CWE-826

- [ ] O recurso permanece válido até o fim do uso?
- [ ] Arquivo temporário não é apagado cedo demais?
- [ ] Stream/conexão compartilhada não é fechada indevidamente?
- [ ] Existe estratégia clara de limpeza?

## CWE-837

- [ ] Ação única é protegida por constraint/transação?
- [ ] Existe idempotência?
- [ ] Callback externo pode ser repetido sem causar duplicidade?
- [ ] Double-click/double-submit foi testado?

## CWE-841

- [ ] Existe máquina de estados?
- [ ] Transições inválidas são bloqueadas?
- [ ] Pré-condições são validadas no service?
- [ ] O usuário não consegue chamar Action direta pulando tela?

---

# 15. Testes sugeridos

## Teste 1 - IDOR/BOLA

1. Login com usuário A.
2. Acessar recurso próprio.
3. Alterar `id` para recurso do usuário B.
4. Resultado esperado: `403` ou `404` controlado.

## Teste 2 - Propriedade de arquivo

1. Gerar arquivo para processo X.
2. Tentar baixar usando usuário sem vínculo com processo X.
3. Resultado esperado: acesso negado e evento auditado.

## Teste 3 - Recuperação de senha

1. Solicitar recuperação várias vezes.
2. Validar se tokens anteriores são invalidados ou se cada token expira.
3. Tentar reutilizar token.
4. Resultado esperado: token inválido após uso.

## Teste 4 - Requisição duplicada

1. Enviar duas confirmações simultâneas.
2. Resultado esperado: apenas uma confirmação efetiva.
3. Verificar constraint/transação/log.

## Teste 5 - Workflow

1. Criar solicitação em `RASCUNHO`.
2. Chamar diretamente endpoint de `FINALIZAR`.
3. Resultado esperado: transição negada.

## Teste 6 - Recursos sem limite

1. Solicitar relatório sem filtros.
2. Solicitar relatório com período muito amplo.
3. Fazer muitas chamadas em sequência.
4. Resultado esperado: validação de período, paginação e rate limit.

---

# 16. Resumo para prova

| CWE | Ideia principal | Frase de memorização |
|---:|---|---|
| 283 | Não verifica dono | “Esse recurso é mesmo do usuário?” |
| 639 | ID controlado pelo usuário bypassa autorização | “Trocar o ID não pode trocar o dono.” |
| 640 | Recuperação de senha fraca | “Token de reset é uma credencial temporária.” |
| 708 | Dono atribuído errado | “O servidor define a propriedade, não o cliente.” |
| 770 | Recurso sem limite | “Toda operação cara precisa de limite.” |
| 826 | Recurso liberado cedo demais | “Não feche/remova antes do último consumidor.” |
| 837 | Ação única repetida | “Uma vez significa uma vez, inclusive sob concorrência.” |
| 841 | Workflow mal aplicado | “Não basta ter telas; o service precisa impor a ordem.” |

---

# 17. Referências oficiais

- CWE-699 - Software Development: https://cwe.mitre.org/data/definitions/699.html
- CWE-840 - Business Logic Errors: https://cwe.mitre.org/data/definitions/840.html
- CWE-283 - Unverified Ownership: https://cwe.mitre.org/data/definitions/283.html
- CWE-639 - Authorization Bypass Through User-Controlled Key: https://cwe.mitre.org/data/definitions/639.html
- CWE-640 - Weak Password Recovery Mechanism for Forgotten Password: https://cwe.mitre.org/data/definitions/640.html
- CWE-708 - Incorrect Ownership Assignment: https://cwe.mitre.org/data/definitions/708.html
- CWE-770 - Allocation of Resources Without Limits or Throttling: https://cwe.mitre.org/data/definitions/770.html
- CWE-826 - Premature Release of Resource During Expected Lifetime: https://cwe.mitre.org/data/definitions/826.html
- CWE-837 - Improper Enforcement of a Single, Unique Action: https://cwe.mitre.org/data/definitions/837.html
- CWE-841 - Improper Enforcement of Behavioral Workflow: https://cwe.mitre.org/data/definitions/841.html

---

# 18. Observação final

Erros de lógica de negócio são perigosos porque frequentemente usam funcionalidades válidas da aplicação. A defesa principal não é apenas sanitização ou validação de formato, mas a aplicação consistente de regras de negócio no servidor:

- propriedade;
- autorização;
- estado;
- ordem do fluxo;
- unicidade;
- limites;
- auditoria.

Em revisão de código Java, sempre procure pontos em que o sistema aceita do cliente algo que deveria ser decidido pelo servidor.
