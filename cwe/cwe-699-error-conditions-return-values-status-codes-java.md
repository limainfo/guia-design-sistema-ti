# CWE-699 — Software Development

## Category: Error Conditions, Return Values, Status Codes — CWE-389

> **Objetivo:** apresentar uma documentação prática sobre erros de tratamento de exceções, valores de retorno e códigos de status, com exemplos vulneráveis e corrigidos em **Java 8**, aplicáveis a sistemas web, APIs REST, Struts/Servlet/JSP, Services, Facades, DAOs, integrações, jobs e rotinas batch.

---

## 1. Visão geral

A categoria **CWE-389 — Error Conditions, Return Values, Status Codes** agrupa fraquezas que ocorrem quando uma função, método, endpoint ou componente:

- retorna código de status incorreto;
- ignora valor de retorno;
- verifica retorno de forma errada;
- detecta erro, mas não toma ação;
- não propaga erro;
- não registra falha relevante;
- deixa exceção escapar sem tratamento adequado;
- expõe informação sensível em mensagens de erro;
- usa tratamento de erro inconsistente;
- usa `return` dentro de `finally`;
- depende de `assert` para validação de segurança;
- não possui página de erro customizada.

Em aplicações Java, esses problemas aparecem com frequência em:

- `try/catch` vazios;
- `catch (Exception e)` genérico;
- `throws Exception`;
- `return null`;
- uso incorreto de `Optional`;
- endpoints retornando HTTP 200 em erro;
- APIs REST retornando stack trace;
- `finally` com `return`;
- erro detectado apenas em log;
- `assert` usado para validar entrada;
- ausência de mapeamento centralizado de exceções;
- JSP/container exibindo erro técnico ao usuário.

---

## 2. Natureza da categoria

A **CWE-389** é uma **Category**. Ela organiza fraquezas relacionadas a condições de erro, retornos e códigos de status, mas não deve ser usada diretamente para mapear uma vulnerabilidade real quando houver uma CWE Base mais específica.

Exemplos de mapeamento:

| Situação encontrada | CWE mais específica |
|---|---:|
| Stack trace aparece para o usuário | 209 |
| Exceção escapa e derruba fluxo crítico | 248 |
| Retorno de `delete()` ou `renameTo()` é ignorado | 252 |
| `executeUpdate()` é comparado errado | 253 |
| Código detecta erro, mas segue execução | 390 |
| API retorna `200 OK` para falha de autenticação | 393 |
| `catch (NullPointerException)` usado como teste de nulo | 395 |
| `catch (Exception)` genérico sem política | 396 |
| Método declara `throws Exception` | 397 |
| `return` dentro de `finally` esconde exceção | 584 |
| `assert usuario != null` em produção | 617 |
| Falta página de erro customizada | 756 |

---

## 3. CWEs abordadas

| CWE | Nome | Exemplo prático em Java |
|---:|---|---|
| 209 | Generation of Error Message Containing Sensitive Information | Stack trace, SQL, caminho local ou token na resposta |
| 248 | Uncaught Exception | Exceção não tratada em endpoint/job |
| 252 | Unchecked Return Value | Retorno boolean/int ignorado |
| 253 | Incorrect Check of Function Return Value | Retorno verificado com condição errada |
| 390 | Detection of Error Condition Without Action | Erro detectado, mas sem ação efetiva |
| 391 | Unchecked Error Condition | Condição de erro possível não verificada |
| 392 | Missing Report of Error Condition | Erro não é reportado, logado ou propagado |
| 393 | Return of Wrong Status Code | HTTP 200 para erro, 500 para validação, 404 indevido |
| 394 | Unexpected Status Code or Return Value | Integração retorna status inesperado e sistema não trata |
| 395 | Use of NullPointerException Catch to Detect NULL Pointer Dereference | `catch (NullPointerException)` como controle de fluxo |
| 396 | Declaration of Catch for Generic Exception | `catch (Exception)` genérico |
| 397 | Declaration of Throws for Generic Exception | `throws Exception` genérico |
| 544 | Missing Standardized Error Handling Mechanism | Falta mecanismo padronizado de erro |
| 584 | Return Inside Finally Block | `return` em `finally` oculta exceções |
| 617 | Reachable Assertion | `assert` alcançável para validar segurança |
| 756 | Missing Custom Error Page | Erro técnico do container exposto ao usuário |

---

# 4. Princípios práticos

## 4.1 Erro deve ter destino claro

Ao detectar uma falha, o código precisa escolher uma ação:

- rejeitar a entrada;
- lançar exceção de domínio;
- retornar erro padronizado;
- registrar auditoria;
- compensar transação;
- fazer rollback;
- acionar retry;
- encerrar fluxo;
- responder com status apropriado;
- degradar funcionalidade de forma segura.

Detectar erro e continuar normalmente costuma ser pior que falhar.

## 4.2 Mensagem interna é diferente de mensagem externa

Mensagem externa deve ser segura:

```json
{
  "code": "ERRO_INTERNO",
  "message": "Não foi possível concluir a operação.",
  "correlationId": "9f3c..."
}
```

Mensagem interna pode conter detalhes técnicos, desde que o log seja protegido:

```text
Falha ao consultar pagamento. id=123 correlationId=9f3c...
```

Mesmo no log, não registrar:

- senha;
- token;
- cookie;
- chave;
- CPF completo quando desnecessário;
- payload sensível;
- SQL com dados sensíveis;
- stack trace em log público.

## 4.3 Status HTTP faz parte do contrato

Status incorreto causa problemas de segurança e operação.

Exemplos:

- `200 OK` em falha de autenticação pode fazer cliente assumir sucesso;
- `500 Internal Server Error` em validação permite ruído e dificulta monitoramento;
- `404` usado para erro de autorização pode ser adequado em alguns contextos, mas precisa ser política explícita;
- `302` indevido em API pode mascarar autenticação expirada;
- `204 No Content` em operação que falhou pode causar perda de dados.

## 4.4 `null`, boolean e código numérico devem ser tratados com cuidado

Retornos como `null`, `false`, `-1`, `0`, `1` e códigos de status exigem contrato claro.

Sempre perguntar:

- o que significa `null`?
- o que significa `0`?
- erro é exceção ou valor?
- quem é obrigado a verificar?
- o método documenta isso?
- existe teste para retorno inesperado?

---

# 5. CWE-209 — Generation of Error Message Containing Sensitive Information

## 5.1 Conceito

A aplicação gera mensagem de erro contendo informações sensíveis.

Exemplos:

- stack trace;
- SQL;
- caminho local;
- nome de tabela;
- usuário do banco;
- token;
- senha;
- header Authorization;
- detalhes de infraestrutura;
- versão do servidor;
- dados pessoais;
- regra interna de autorização.

## 5.2 Exemplo vulnerável em servlet/action

```java
public ActionForward consultar(
        ActionMapping mapping,
        ActionForm form,
        HttpServletRequest request,
        HttpServletResponse response)
        throws Exception {

    try {
        service.consultar(form);
        return mapping.findForward("sucesso");
    } catch (Exception e) {
        response.getWriter().write(
            "Erro ao consultar: " + e.toString()
        );

        e.printStackTrace(response.getWriter());
        return null;
    }
}
```

Problemas:

- expõe classe, método e stack trace;
- pode expor SQL, paths e dados internos;
- mistura resposta HTTP com fluxo Struts;
- dificulta tratamento padronizado.

## 5.3 Solução

```java
public ActionForward consultar(
        ActionMapping mapping,
        ActionForm form,
        HttpServletRequest request,
        HttpServletResponse response)
        throws ApplicationException {

    try {
        service.consultar(form);
        return mapping.findForward("sucesso");
    } catch (ValidacaoException e) {
        throw new ApplicationException(
            "mensagem.aviso.geral",
            new String[] { e.getMensagemUsuario() },
            ApplicationException.ICON_AVISO
        );
    } catch (Exception e) {
        String correlationId =
            CorrelationId.getOrCreate(request);

        log.error(
            "Falha ao consultar. correlationId={}",
            correlationId,
            e
        );

        throw new ApplicationException(
            "mensagem.erro.personalizada",
            new String[] {
                "Não foi possível concluir a consulta. "
              + "Informe o código " + correlationId
              + " ao suporte."
            },
            ApplicationException.ICON_ERRO
        );
    }
}
```

## 5.4 Exemplo REST

```java
public ErrorResponse erroSeguro(
        String code,
        String message,
        String correlationId) {

    return new ErrorResponse(
        code,
        message,
        correlationId
    );
}
```

Resposta:

```json
{
  "code": "ERRO_INTERNO",
  "message": "Não foi possível concluir a operação.",
  "correlationId": "d7ec9b"
}
```

## 5.5 Revisão

Procurar:

```bash
grep -RniE 'printStackTrace|getMessage\(\)|toString\(\)|Exception' src/
```

Perguntas:

- a mensagem chega ao usuário?
- contém stack trace?
- contém SQL?
- contém caminho local?
- contém segredo?
- contém dado pessoal desnecessário?
- existe correlation ID?

---

# 6. CWE-248 — Uncaught Exception

## 6.1 Conceito

Uma exceção relevante não é capturada nem tratada no nível correto, causando:

- encerramento inesperado;
- resposta técnica ao usuário;
- job abortado sem estado consistente;
- transação parcial;
- recurso não liberado;
- falha silenciosa em thread;
- comportamento não determinístico.

## 6.2 Exemplo vulnerável em job

```java
public void execute() {
    List<Long> ids =
        depositoDAO.buscarPendentes();

    for (Long id : ids) {
        anexarComprovante(id);
    }
}
```

Se um item falhar, todo o job pode parar.

## 6.3 Solução

```java
public void execute() {
    List<Long> ids =
        depositoDAO.buscarPendentes();

    for (Long id : ids) {
        try {
            anexarComprovante(id);
        } catch (ApplicationException e) {
            log.warn(
                "Falha de negócio ao anexar comprovante. id={}",
                id,
                e
            );

            depositoDAO.marcarFalha(
                id,
                e.getMessage()
            );
        } catch (Exception e) {
            log.error(
                "Falha inesperada ao anexar comprovante. id={}",
                id,
                e
            );

            depositoDAO.marcarFalha(
                id,
                "Erro inesperado"
            );
        }
    }
}
```

## 6.4 Observação

Capturar exceção não significa esconder erro. Significa decidir:

- se o item atual falha e o job continua;
- se tudo deve abortar;
- se haverá retry;
- se haverá alerta;
- se haverá marcação de estado.

---

# 7. CWE-252 — Unchecked Return Value

## 7.1 Conceito

O código chama função que retorna sucesso/falha, mas ignora o retorno.

## 7.2 Exemplo vulnerável

```java
public void removerArquivo(File arquivo) {
    arquivo.delete();
}
```

`delete()` retorna `false` se não conseguiu remover.

## 7.3 Solução

```java
public void removerArquivo(Path arquivo)
        throws IOException {

    boolean removido =
        Files.deleteIfExists(arquivo);

    if (!removido) {
        log.info(
            "Arquivo não existia para remoção. arquivo={}",
            arquivo
        );
    }
}
```

Quando a remoção é obrigatória:

```java
public void removerArquivoObrigatorio(Path arquivo)
        throws IOException {

    Files.delete(arquivo);
}
```

`Files.delete` lança exceção em falha, tornando o erro explícito.

## 7.4 Outro exemplo

```java
preparedStatement.execute();
```

Se o retorno ou efeitos esperados não são verificados, o código pode assumir que a operação funcionou.

## 7.5 Revisão

Procurar:

```bash
grep -RniE '\.delete\(\)|\.renameTo\(|executeUpdate\(|mkdir\(|mkdirs\(' src/
```

---

# 8. CWE-253 — Incorrect Check of Function Return Value

## 8.1 Conceito

O retorno é verificado, mas de forma errada.

## 8.2 Exemplo vulnerável

```java
int linhas =
    preparedStatement.executeUpdate();

if (linhas < 0) {
    throw new SQLException(
        "Nenhum registro atualizado"
    );
}
```

Para `executeUpdate`, zero linhas pode indicar que nada foi alterado.

## 8.3 Solução

```java
int linhas =
    preparedStatement.executeUpdate();

if (linhas != 1) {
    throw new OptimisticLockException(
        "Registro não atualizado ou concorrência detectada"
    );
}
```

## 8.4 Exemplo com `indexOf`

```java
if (texto.indexOf("ADMIN") > 0) {
    liberar();
}
```

Se `ADMIN` estiver no índice `0`, a condição falha.

Solução:

```java
if (texto.indexOf("ADMIN") >= 0) {
    liberar();
}
```

## 8.5 Perguntas

- qual é o contrato do método?
- `0` significa sucesso ou falha?
- `-1` significa não encontrado?
- exceção substitui retorno?
- retorno parcial é possível?
- a verificação cobre todos os casos?

---

# 9. CWE-390 — Detection of Error Condition Without Action

## 9.1 Conceito

O código identifica uma condição de erro, mas não toma ação suficiente.

## 9.2 Exemplo vulnerável

```java
if (usuario == null) {
    log.warn("Usuário não encontrado");
}

return usuario.getNome();
```

O erro foi detectado, mas o fluxo continuou.

## 9.3 Solução

```java
if (usuario == null) {
    log.warn(
        "Usuário não encontrado. id={}",
        usuarioId
    );

    throw new NotFoundException(
        "Usuário não encontrado"
    );
}

return usuario.getNome();
```

## 9.4 Exemplo em validação

```java
if (!arquivoValido) {
    mensagens.add("Arquivo inválido");
}

processarArquivo(arquivo);
```

Solução:

```java
if (!arquivoValido) {
    throw new ValidacaoException(
        "Arquivo inválido"
    );
}
```

---

# 10. CWE-391 — Unchecked Error Condition

## 10.1 Conceito

A aplicação executa operação que pode falhar, mas não verifica a condição de erro.

É parecida com CWE-252, mas mais ampla: a condição de erro pode vir de retorno, estado, flag, exceção suprimida ou resposta externa.

## 10.2 Exemplo vulnerável

```java
HttpURLConnection connection =
    (HttpURLConnection) url.openConnection();

InputStream input =
    connection.getInputStream();

processar(input);
```

O código não verifica status HTTP.

## 10.3 Solução

```java
HttpURLConnection connection =
    (HttpURLConnection) url.openConnection();

connection.setConnectTimeout(5000);
connection.setReadTimeout(10000);

int status =
    connection.getResponseCode();

if (status < 200 || status >= 300) {
    throw new IntegracaoException(
        "Integração retornou status inválido: "
        + status
    );
}

try (InputStream input =
         connection.getInputStream()) {

    processar(input);
}
```

## 10.4 Exemplo com upload

```java
if (arquivo.getSize() > LIMITE) {
    // sem ação
}

salvar(arquivo);
```

---

# 11. CWE-392 — Missing Report of Error Condition

## 11.1 Conceito

O erro ocorre ou é detectado, mas não é reportado adequadamente.

Isso dificulta:

- suporte;
- auditoria;
- monitoramento;
- rastreabilidade;
- investigação;
- retry;
- compensação;
- alerta operacional.

## 11.2 Exemplo vulnerável

```java
try {
    integrarPagamento(pagamento);
} catch (IOException e) {
    // ignora
}
```

## 11.3 Solução

```java
try {
    integrarPagamento(pagamento);
} catch (IOException e) {
    log.error(
        "Falha ao integrar pagamento. pagamentoId={}",
        pagamento.getId(),
        e
    );

    pagamentoDAO.marcarFalhaIntegracao(
        pagamento.getId(),
        "FALHA_COMUNICACAO"
    );

    alertaService.notificarSeNecessario(
        "Falha de integração de pagamento"
    );
}
```

## 11.4 Reportar não é expor ao usuário

Reportar pode significar:

- log técnico;
- métrica;
- evento de auditoria;
- registro de falha no banco;
- retorno padronizado;
- alerta;
- dead letter queue.

---

# 12. CWE-393 — Return of Wrong Status Code

## 12.1 Conceito

A aplicação retorna código de status incorreto.

## 12.2 Exemplo vulnerável

```java
@PostMapping("/login")
public ResponseEntity<LoginResponse> login(
        @RequestBody LoginRequest request) {

    if (!authService.autenticar(request)) {
        return ResponseEntity.ok(
            new LoginResponse(false)
        );
    }

    return ResponseEntity.ok(
        new LoginResponse(true)
    );
}
```

A falha de autenticação retorna `200 OK`.

## 12.3 Solução

```java
@PostMapping("/login")
public ResponseEntity<?> login(
        @RequestBody LoginRequest request) {

    if (!authService.autenticar(request)) {
        return ResponseEntity
            .status(HttpStatus.UNAUTHORIZED)
            .body(
                ErrorResponse.of(
                    "AUTH_INVALIDA",
                    "Credenciais inválidas"
                )
            );
    }

    return ResponseEntity.ok(
        loginService.gerarResposta(request)
    );
}
```

## 12.4 Mapeamento prático HTTP

| Situação | Status comum |
|---|---:|
| Sucesso com corpo | 200 |
| Criado | 201 |
| Sucesso sem corpo | 204 |
| Entrada inválida | 400 |
| Não autenticado | 401 |
| Autenticado sem permissão | 403 |
| Recurso inexistente | 404 |
| Conflito de estado | 409 |
| Validação semântica | 422, se adotado pela API |
| Erro inesperado | 500 |
| Serviço externo indisponível | 502/503/504, conforme caso |

## 12.5 Observação

O uso de `404` para esconder a existência de recurso pode ser correto, mas deve ser política explícita de segurança, não improviso.

---

# 13. CWE-394 — Unexpected Status Code or Return Value

## 13.1 Conceito

A aplicação não trata retorno inesperado de função, biblioteca ou serviço externo.

## 13.2 Exemplo vulnerável

```java
int status =
    response.getStatus();

if (status == 200) {
    processarSucesso(response);
} else {
    processarErro(response);
}
```

Agrupar todos os demais status como erro genérico pode ser insuficiente.

## 13.3 Solução

```java
switch (status) {
    case 200:
        processarSucesso(response);
        break;

    case 400:
        tratarErroNegocio(response);
        break;

    case 401:
    case 403:
        renovarCredencialOuBloquear(response);
        break;

    case 404:
        tratarNaoEncontrado(response);
        break;

    case 409:
        tratarConflito(response);
        break;

    case 429:
        reagendarComBackoff(response);
        break;

    case 500:
    case 502:
    case 503:
    case 504:
        reagendarRetry(response);
        break;

    default:
        throw new IntegracaoException(
            "Status inesperado da integração: "
            + status
        );
}
```

## 13.4 Exemplo com enum

```java
StatusPagamento status =
    StatusPagamento.fromCodigo(codigo);

if (status == null) {
    throw new IntegracaoException(
        "Status de pagamento desconhecido: "
        + codigo
    );
}
```

---

# 14. CWE-395 — Use of NullPointerException Catch to Detect NULL Pointer Dereference

## 14.1 Conceito

O código usa `catch (NullPointerException)` para detectar valor nulo.

## 14.2 Exemplo vulnerável

```java
try {
    return funcionario
        .getPessoa()
        .getNome()
        .toUpperCase(Locale.ROOT);
} catch (NullPointerException e) {
    return "";
}
```

Problemas:

- esconde origem real do nulo;
- pode mascarar bug;
- captura NPE não relacionado;
- prejudica manutenção;
- dificulta testes.

## 14.3 Solução

```java
public String obterNomeFuncionario(
        Funcionario funcionario) {

    if (funcionario == null
            || funcionario.getPessoa() == null
            || funcionario.getPessoa().getNome() == null) {
        return "";
    }

    return funcionario
        .getPessoa()
        .getNome()
        .toUpperCase(Locale.ROOT);
}
```

Ou com validação obrigatória:

```java
if (funcionario == null) {
    throw new IllegalArgumentException(
        "Funcionário obrigatório"
    );
}
```

## 14.4 Regra

`NullPointerException` indica defeito ou violação de contrato. Não deve ser mecanismo normal de controle de fluxo.

---

# 15. CWE-396 — Declaration of Catch for Generic Exception

## 15.1 Conceito

O código captura `Exception` de forma genérica.

Nem todo `catch (Exception)` é automaticamente vulnerável, mas o risco aumenta quando ele:

- trata erros diferentes da mesma forma;
- engole exceções;
- converte tudo em sucesso;
- perde informação de causa;
- esconde erro de programação;
- dificulta rollback;
- gera mensagem incorreta ao usuário;
- mistura erro de negócio, validação, infraestrutura e bug.

## 15.2 Exemplo vulnerável

```java
try {
    usuarioService.alterarSenha(dto);
} catch (Exception e) {
    return "sucesso";
}
```

## 15.3 Solução

```java
try {
    usuarioService.alterarSenha(dto);
    return "sucesso";
} catch (ValidacaoException e) {
    request.setAttribute(
        "mensagem",
        e.getMensagemUsuario()
    );

    return "erroValidacao";
} catch (AutorizacaoException e) {
    response.setStatus(
        HttpServletResponse.SC_FORBIDDEN
    );

    return "semPermissao";
} catch (ApplicationException e) {
    throw e;
} catch (RuntimeException e) {
    log.error(
        "Falha inesperada ao alterar senha",
        e
    );

    throw e;
}
```

## 15.4 Quando `catch (Exception)` pode existir

Em fronteiras bem definidas:

- filtro global;
- handler central de REST;
- job scheduler;
- consumidor de fila;
- thread principal;
- última barreira antes de responder ao usuário.

Mesmo assim, deve:

- registrar;
- gerar erro padronizado;
- preservar causa;
- não retornar sucesso;
- não expor detalhes sensíveis;
- aplicar rollback/estado de falha.

---

# 16. CWE-397 — Declaration of Throws for Generic Exception

## 16.1 Conceito

Método declara `throws Exception`, escondendo quais falhas realmente podem ocorrer.

## 16.2 Exemplo vulnerável

```java
public void importarArquivo(File file)
        throws Exception {

    validar(file);
    processar(file);
    salvar(file);
}
```

Problemas:

- chamador não sabe o que tratar;
- todos capturam `Exception`;
- contrato fica impreciso;
- erros de negócio e infraestrutura se misturam.

## 16.3 Solução

```java
public void importarArquivo(Path file)
        throws ValidacaoException,
               ImportacaoException,
               IOException {

    validar(file);
    processar(file);
    salvar(file);
}
```

Ou encapsular em exceção de aplicação com causa preservada:

```java
try {
    processar(file);
} catch (IOException e) {
    throw new ImportacaoException(
        "Falha ao ler arquivo de importação",
        e
    );
}
```

## 16.4 Regra prática

Em camadas de negócio, prefira exceções com significado:

- `ValidacaoException`;
- `AutorizacaoException`;
- `IntegracaoException`;
- `ConcorrenciaException`;
- `RecursoNaoEncontradoException`;
- `ApplicationException`.

---

# 17. CWE-544 — Missing Standardized Error Handling Mechanism

## 17.1 Conceito

A aplicação não possui mecanismo padronizado de tratamento de erro.

Consequências:

- cada Action/Controller responde diferente;
- mensagens técnicas vazam em alguns fluxos;
- logs são inconsistentes;
- status HTTP variam sem critério;
- exceções são engolidas em alguns pontos;
- usuários recebem mensagens diferentes para o mesmo erro;
- integrações não conseguem interpretar falhas;
- suporte não encontra correlation ID;
- auditoria fica incompleta.

## 17.2 Exemplo vulnerável

```java
if (erroA) {
    response.sendError(500, e.getMessage());
}

if (erroB) {
    request.setAttribute("erro", e.toString());
    return mapping.findForward("erro");
}

if (erroC) {
    return null;
}
```

## 17.3 Solução: modelo padrão de erro

```java
public final class ErrorResponse {

    private final String code;
    private final String message;
    private final String correlationId;

    public ErrorResponse(
            String code,
            String message,
            String correlationId) {

        this.code = code;
        this.message = message;
        this.correlationId = correlationId;
    }

    public String getCode() {
        return code;
    }

    public String getMessage() {
        return message;
    }

    public String getCorrelationId() {
        return correlationId;
    }
}
```

## 17.4 Handler central REST

```java
@ControllerAdvice
public class ApiExceptionHandler {

    @ExceptionHandler(ValidacaoException.class)
    public ResponseEntity<ErrorResponse> validacao(
            ValidacaoException e,
            HttpServletRequest request) {

        return ResponseEntity
            .badRequest()
            .body(
                erro(
                    "VALIDACAO",
                    e.getMensagemUsuario(),
                    request
                )
            );
    }

    @ExceptionHandler(AutorizacaoException.class)
    public ResponseEntity<ErrorResponse> autorizacao(
            AutorizacaoException e,
            HttpServletRequest request) {

        return ResponseEntity
            .status(HttpStatus.FORBIDDEN)
            .body(
                erro(
                    "ACESSO_NEGADO",
                    "Acesso negado.",
                    request
                )
            );
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> inesperado(
            Exception e,
            HttpServletRequest request) {

        String correlationId =
            CorrelationId.getOrCreate(request);

        log.error(
            "Erro inesperado. correlationId={}",
            correlationId,
            e
        );

        return ResponseEntity
            .status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(
                new ErrorResponse(
                    "ERRO_INTERNO",
                    "Não foi possível concluir a operação.",
                    correlationId
                )
            );
    }

    private ErrorResponse erro(
            String code,
            String message,
            HttpServletRequest request) {

        return new ErrorResponse(
            code,
            message,
            CorrelationId.getOrCreate(request)
        );
    }
}
```

## 17.5 Padrão para aplicação Struts/JSP

```java
public final class ActionErrorHandler {

    private ActionErrorHandler() {
    }

    public static ActionForward tratar(
            Exception e,
            ActionMapping mapping,
            HttpServletRequest request,
            Logger log) {

        String correlationId =
            CorrelationId.getOrCreate(request);

        if (e instanceof ValidacaoException) {
            request.setAttribute(
                "mensagemErro",
                ((ValidacaoException) e)
                    .getMensagemUsuario()
            );

            return mapping.findForward(
                "erroValidacao"
            );
        }

        log.error(
            "Erro inesperado em Action. correlationId={}",
            correlationId,
            e
        );

        request.setAttribute(
            "mensagemErro",
            "Não foi possível concluir a operação. "
          + "Código: " + correlationId
        );

        return mapping.findForward("erro");
    }
}
```

## 17.6 Padrão mínimo

- exceções de domínio;
- exceções de integração;
- exceções de autorização;
- handler central;
- status HTTP consistente;
- mensagem externa segura;
- log interno com correlation ID;
- auditoria para eventos sensíveis;
- documentação do contrato de erro;
- testes de erro.

---

# 18. CWE-584 — Return Inside Finally Block

## 18.1 Conceito

Um `return` dentro de `finally` pode descartar exceção lançada no bloco `try` ou `catch`.

## 18.2 Exemplo vulnerável

```java
public boolean salvar(Usuario usuario) {
    try {
        usuarioDAO.salvar(usuario);
        return true;
    } finally {
        return false;
    }
}
```

O método sempre retorna `false`.

Outro exemplo mais perigoso:

```java
public String executar() {
    try {
        service.processar();
        return "sucesso";
    } finally {
        return "fim";
    }
}
```

Se `service.processar()` lançar exceção, ela será descartada.

## 18.3 Solução

```java
public boolean salvar(Usuario usuario) {
    usuarioDAO.salvar(usuario);
    return true;
}
```

Para limpeza de recurso:

```java
public void processar(Path arquivo)
        throws IOException {

    try (InputStream input =
             Files.newInputStream(arquivo)) {

        importar(input);
    }
}
```

Quando `finally` for necessário:

```java
try {
    service.processar();
} finally {
    limparContexto();
}
```

Sem `return`, `throw` ou alteração indevida do resultado.

## 18.4 Revisão

```bash
grep -RniE 'finally[[:space:]]*\{|return .*finally|finally' src/
```

Revisar manualmente blocos `finally`.

---

# 19. CWE-617 — Reachable Assertion

## 19.1 Conceito

A aplicação usa `assert` para validar condição que pode ser alcançada por entrada externa ou fluxo normal.

Em Java, `assert` pode estar desabilitado em produção. Logo, não é mecanismo de segurança.

## 19.2 Exemplo vulnerável

```java
public void transferir(
        Conta origem,
        Conta destino,
        BigDecimal valor) {

    assert valor.compareTo(BigDecimal.ZERO) > 0;

    origem.debitar(valor);
    destino.creditar(valor);
}
```

Se assertions estiverem desabilitadas, valor negativo pode passar.

## 19.3 Solução

```java
public void transferir(
        Conta origem,
        Conta destino,
        BigDecimal valor) {

    if (valor == null
            || valor.compareTo(BigDecimal.ZERO) <= 0) {
        throw new ValidacaoException(
            "Valor de transferência inválido"
        );
    }

    origem.debitar(valor);
    destino.creditar(valor);
}
```

## 19.4 Quando usar `assert`

`assert` pode ser usado para invariantes internas durante desenvolvimento, mas não para:

- autenticação;
- autorização;
- validação de entrada;
- validação de regra de negócio;
- limites de segurança;
- contratos de API externa;
- decisões financeiras.

---

# 20. CWE-756 — Missing Custom Error Page

## 20.1 Conceito

A aplicação não define página de erro customizada e deixa o container/framework exibir erro técnico.

## 20.2 Exemplo vulnerável

Sem configuração no `web.xml`, um erro 500 pode exibir:

- stack trace;
- nome de classe;
- versão do servidor;
- caminho interno;
- JSP compilado;
- detalhes do framework.

## 20.3 Solução em `web.xml`

```xml
<error-page>
    <error-code>400</error-code>
    <location>/WEB-INF/jsp/erro/400.jsp</location>
</error-page>

<error-page>
    <error-code>403</error-code>
    <location>/WEB-INF/jsp/erro/403.jsp</location>
</error-page>

<error-page>
    <error-code>404</error-code>
    <location>/WEB-INF/jsp/erro/404.jsp</location>
</error-page>

<error-page>
    <error-code>500</error-code>
    <location>/WEB-INF/jsp/erro/500.jsp</location>
</error-page>

<error-page>
    <exception-type>java.lang.Throwable</exception-type>
    <location>/WEB-INF/jsp/erro/500.jsp</location>
</error-page>
```

## 20.4 Página JSP segura

```jsp
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Erro</title>
</head>
<body>
    <h1>Não foi possível concluir a operação</h1>
    <p>
        Tente novamente. Se o problema persistir,
        informe o código de atendimento:
        <c:out value="${correlationId}" />
    </p>
</body>
</html>
```

## 20.5 Regras

- não exibir stack trace;
- não exibir exception message bruta;
- incluir correlation ID;
- retornar status correto;
- manter página simples;
- registrar erro no servidor;
- testar em produção/homologação com modo debug desligado.

---

# 21. Componentes reutilizáveis

## 21.1 Correlation ID

```java
public final class CorrelationId {

    private static final String ATTRIBUTE =
        "correlationId";

    private CorrelationId() {
    }

    public static String getOrCreate(
            HttpServletRequest request) {

        Object existing =
            request.getAttribute(ATTRIBUTE);

        if (existing instanceof String) {
            return (String) existing;
        }

        String id =
            UUID.randomUUID().toString();

        request.setAttribute(ATTRIBUTE, id);

        return id;
    }
}
```

## 21.2 Filtro de correlation ID

```java
public class CorrelationIdFilter
        implements Filter {

    @Override
    public void doFilter(
            ServletRequest servletRequest,
            ServletResponse servletResponse,
            FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request =
            (HttpServletRequest) servletRequest;

        String correlationId =
            request.getHeader("X-Correlation-Id");

        if (correlationId == null
                || !correlationId.matches(
                    "[A-Za-z0-9._-]{1,100}")) {
            correlationId =
                UUID.randomUUID().toString();
        }

        request.setAttribute(
            "correlationId",
            correlationId
        );

        chain.doFilter(
            servletRequest,
            servletResponse
        );
    }
}
```

## 21.3 Exceções de aplicação

```java
public class NegocioException
        extends RuntimeException {

    private final String codigo;
    private final String mensagemUsuario;

    public NegocioException(
            String codigo,
            String mensagemUsuario) {

        super(codigo);
        this.codigo = codigo;
        this.mensagemUsuario = mensagemUsuario;
    }

    public String getCodigo() {
        return codigo;
    }

    public String getMensagemUsuario() {
        return mensagemUsuario;
    }
}
```

```java
public class IntegracaoException
        extends RuntimeException {

    public IntegracaoException(
            String message,
            Throwable cause) {

        super(message, cause);
    }
}
```

## 21.4 Resultado explícito

```java
public final class ResultadoOperacao {

    private final boolean sucesso;
    private final String codigoErro;
    private final String mensagem;

    private ResultadoOperacao(
            boolean sucesso,
            String codigoErro,
            String mensagem) {

        this.sucesso = sucesso;
        this.codigoErro = codigoErro;
        this.mensagem = mensagem;
    }

    public static ResultadoOperacao sucesso() {
        return new ResultadoOperacao(
            true,
            null,
            null
        );
    }

    public static ResultadoOperacao erro(
            String codigoErro,
            String mensagem) {

        return new ResultadoOperacao(
            false,
            codigoErro,
            mensagem
        );
    }

    public boolean isSucesso() {
        return sucesso;
    }

    public boolean isErro() {
        return !sucesso;
    }

    public String getCodigoErro() {
        return codigoErro;
    }

    public String getMensagem() {
        return mensagem;
    }
}
```

Ao usar esse padrão, o chamador deve ser obrigado a verificar `isErro()` antes de seguir.

---

# 22. Diferenças importantes entre CWEs

## 22.1 CWE-252 versus CWE-253

| Situação | CWE |
|---|---:|
| Retorno é ignorado | 252 |
| Retorno é verificado com lógica errada | 253 |
| `delete()` chamado sem verificar resultado | 252 |
| `executeUpdate() < 0` para detectar ausência de update | 253 |

## 22.2 CWE-390 versus CWE-392

| Situação | CWE |
|---|---:|
| Erro é detectado, mas nada efetivo é feito | 390 |
| Erro não é reportado/logado/propagado | 392 |
| Pode ocorrer simultaneamente | Sim |

## 22.3 CWE-396 versus CWE-397

| Situação | CWE |
|---|---:|
| Método captura `Exception` | 396 |
| Método declara `throws Exception` | 397 |
| Ambos induzem tratamento genérico | Sim |

## 22.4 CWE-393 versus CWE-394

| Situação | CWE |
|---|---:|
| A aplicação retorna status errado | 393 |
| A aplicação recebe status inesperado e trata mal | 394 |

## 22.5 CWE-209 versus CWE-756

| Situação | CWE |
|---|---:|
| Mensagem de erro contém informação sensível | 209 |
| Falta página de erro customizada | 756 |
| Página padrão exibe stack trace | Pode envolver ambas |

---

# 23. Checklist de revisão

## 23.1 Mensagens de erro

- Stack trace chega ao usuário?
- `e.getMessage()` é exibido diretamente?
- SQL aparece na resposta?
- Caminho local aparece na resposta?
- Token, senha ou cookie aparecem em erro?
- Existe correlation ID?
- Mensagem externa é padronizada?

## 23.2 Exceções

- Há `catch` vazio?
- Há `catch (Exception)` fora de fronteira global?
- Há `throws Exception` em método de negócio?
- Há `NullPointerException` usado como controle de fluxo?
- Há exceção capturada e sucesso retornado?
- A causa original é preservada?
- Erros esperados possuem exceções específicas?

## 23.3 Retornos

- `delete`, `renameTo`, `mkdir`, `executeUpdate` são verificados?
- `null` é retorno esperado ou erro?
- `Optional` seria mais claro?
- O retorno `0` é tratado?
- Há comparação errada com `-1`, `0` ou `> 0`?
- Retorno de integração é validado?

## 23.4 HTTP/API

- Login inválido retorna 401?
- Falta de permissão retorna 403 ou política equivalente?
- Validação retorna 400/422 conforme contrato?
- Erro interno retorna 500 seguro?
- Recurso inexistente retorna 404?
- Status de integração inesperado é tratado?
- APIs não retornam HTML de erro do container?

## 23.5 Fluxo e limpeza

- Existe `return` em `finally`?
- Existe `throw` em `finally` que esconde erro anterior?
- `try-with-resources` é usado?
- Limpeza de recurso não altera resultado principal?
- Há rollback em falhas transacionais?

## 23.6 Configuração

- Existem páginas de erro customizadas?
- Modo debug está desligado?
- Handler global está registrado?
- Logs possuem correlation ID?
- Jobs registram falha por item?
- Existe alerta para falhas críticas?

---

# 24. Comandos de busca no código

## 24.1 Stack trace e mensagens técnicas

```bash
grep -RniE \
  'printStackTrace|getMessage\(\)|toString\(\)|sendError\(.*Exception|Exception.*response|getWriter\(\)\.write' \
  src/ web/
```

## 24.2 Catch genérico e catch vazio

```bash
grep -RniE \
  'catch[[:space:]]*\([[:space:]]*Exception|catch[[:space:]]*\([[:space:]]*Throwable' \
  src/
```

```bash
grep -RniE \
  'catch[^{]*\{[[:space:]]*\}' \
  src/
```

## 24.3 Throws genérico

```bash
grep -RniE \
  'throws[[:space:]]+Exception|throws[[:space:]]+Throwable' \
  src/
```

## 24.4 Retornos ignorados

```bash
grep -RniE \
  '\.delete\(\);|\.renameTo\(.*\);|\.mkdir\(\);|\.mkdirs\(\);|executeUpdate\(.*\);' \
  src/
```

## 24.5 Finally

```bash
grep -RniE \
  'finally|return .*finally' \
  src/
```

Revisar manualmente se há `return`, `throw` ou alteração de resultado dentro de `finally`.

## 24.6 Assert

```bash
grep -RniE \
  'assert[[:space:]]+' \
  src/
```

## 24.7 Status HTTP

```bash
grep -RniE \
  'ResponseEntity\.ok|SC_OK|setStatus\(200|sendRedirect|sendError|HttpStatus' \
  src/
```

## 24.8 Páginas de erro

```bash
grep -RniE \
  '<error-page>|exception-type|error-code' \
  src/main/webapp/WEB-INF web/WEB-INF
```

---

# 25. Testes sugeridos

## 25.1 Mensagem de erro

1. Forçar erro interno.
2. Confirmar que a resposta não contém stack trace.
3. Confirmar que não contém SQL.
4. Confirmar que não contém caminho local.
5. Confirmar que possui correlation ID.
6. Confirmar que o log interno contém causa técnica.
7. Confirmar que segredos são mascarados.

## 25.2 Status HTTP

1. Login inválido.
2. Usuário sem permissão.
3. Recurso inexistente.
4. Entrada inválida.
5. Conflito de concorrência.
6. Erro inesperado.
7. Serviço externo indisponível.
8. Token expirado.
9. Sessão ausente.
10. Validação de negócio.

## 25.3 Retornos

1. `executeUpdate()` retorna `0`.
2. `deleteIfExists()` retorna `false`.
3. Integração retorna `202`.
4. Integração retorna `204`.
5. Integração retorna `400`.
6. Integração retorna `401`.
7. Integração retorna `429`.
8. Integração retorna status desconhecido.
9. Método retorna `null`.
10. Método retorna lista vazia.

## 25.4 Exceções

1. Exceção de validação.
2. Exceção de autorização.
3. Exceção de integração.
4. Runtime inesperada.
5. Erro em um item de job.
6. Erro no primeiro item.
7. Erro no último item.
8. Falha de rollback.
9. Erro durante fechamento de recurso.
10. Exceção em handler.

## 25.5 Página de erro

1. Acessar URL inexistente.
2. Forçar 403.
3. Forçar 500.
4. Forçar exception não tratada.
5. Confirmar status correto.
6. Confirmar página amigável.
7. Confirmar ausência de stack trace.
8. Confirmar correlation ID.
9. Confirmar log no servidor.
10. Testar em modo debug desligado.

---

# 26. Exemplos de testes unitários

## 26.1 `executeUpdate()` deve afetar uma linha

```java
@Test(expected = OptimisticLockException.class)
public void updateSemLinhasDeveGerarErro() {
    when(preparedStatement.executeUpdate())
        .thenReturn(0);

    usuarioDAO.atualizarNome(
        10L,
        "Novo nome"
    );
}
```

## 26.2 Handler não deve expor stack trace

```java
@Test
public void erroInternoNaoDeveExporStackTrace() {
    Exception e =
        new SQLException(
            "select * from usuario where senha='x'"
        );

    ErrorResponse response =
        handler.toErrorResponse(e, request);

    assertEquals(
        "ERRO_INTERNO",
        response.getCode()
    );

    assertFalse(
        response.getMessage().contains("select")
    );

    assertNotNull(
        response.getCorrelationId()
    );
}
```

## 26.3 `finally` não deve sobrescrever exceção

```java
@Test(expected = RuntimeException.class)
public void finallyNaoDeveOcultarExcecao() {
    service.metodoQueLancaExcecao();
}
```

## 26.4 Login inválido deve retornar 401

```java
@Test
public void loginInvalidoDeveRetornar401() {
    ResponseEntity<?> response =
        controller.login(
            new LoginRequest("user", "senhaErrada")
        );

    assertEquals(
        HttpStatus.UNAUTHORIZED,
        response.getStatusCode()
    );
}
```

---

# 27. Quadro de decisão rápida

| Evidência | CWE provável |
|---|---:|
| Resposta exibe stack trace | 209 |
| Exceção não tratada derruba endpoint/job | 248 |
| `file.delete();` sem verificar retorno | 252 |
| `executeUpdate() < 0` para detectar falha | 253 |
| `if (erro) log;` e segue execução | 390 |
| Status HTTP não verificado antes de processar resposta | 391 |
| `catch` vazio | 392 |
| API retorna 200 para erro | 393 |
| Status externo desconhecido cai como sucesso | 394 |
| `catch (NullPointerException)` para detectar nulo | 395 |
| `catch (Exception)` genérico | 396 |
| `throws Exception` em método de negócio | 397 |
| Cada tela trata erro de um jeito | 544 |
| `return` dentro de `finally` | 584 |
| `assert` valida regra de segurança | 617 |
| Container mostra página técnica de erro | 756 |

---

# 28. Resumo para prova

## CWE-389

Categoria sobre condições de erro, valores de retorno e códigos de status. Não deve ser usada diretamente quando houver CWE Base mais específica.

## CWE-209

Mensagem de erro contém informação sensível.

## CWE-248

Exceção não capturada adequadamente.

## CWE-252

Valor de retorno não é verificado.

## CWE-253

Valor de retorno é verificado de forma incorreta.

## CWE-390

Erro é detectado, mas nenhuma ação efetiva é tomada.

## CWE-391

Condição de erro não é verificada.

## CWE-392

Erro não é reportado, logado ou propagado.

## CWE-393

Código de status errado é retornado.

## CWE-394

Status ou valor inesperado é tratado incorretamente.

## CWE-395

`NullPointerException` é capturada para detectar nulo.

## CWE-396

Captura genérica de `Exception`.

## CWE-397

Declaração genérica de `throws Exception`.

## CWE-544

Ausência de mecanismo padronizado de tratamento de erros.

## CWE-584

`return` dentro de `finally` oculta retorno ou exceção anterior.

## CWE-617

`assert` alcançável usado para validar condição relevante.

## CWE-756

Ausência de página de erro customizada.

---

# 29. Referências

## MITRE CWE

- [CWE-389 — Error Conditions, Return Values, Status Codes](https://cwe.mitre.org/data/definitions/389.html)
- [CWE-209 — Generation of Error Message Containing Sensitive Information](https://cwe.mitre.org/data/definitions/209.html)
- [CWE-248 — Uncaught Exception](https://cwe.mitre.org/data/definitions/248.html)
- [CWE-252 — Unchecked Return Value](https://cwe.mitre.org/data/definitions/252.html)
- [CWE-253 — Incorrect Check of Function Return Value](https://cwe.mitre.org/data/definitions/253.html)
- [CWE-390 — Detection of Error Condition Without Action](https://cwe.mitre.org/data/definitions/390.html)
- [CWE-391 — Unchecked Error Condition](https://cwe.mitre.org/data/definitions/391.html)
- [CWE-392 — Missing Report of Error Condition](https://cwe.mitre.org/data/definitions/392.html)
- [CWE-393 — Return of Wrong Status Code](https://cwe.mitre.org/data/definitions/393.html)
- [CWE-394 — Unexpected Status Code or Return Value](https://cwe.mitre.org/data/definitions/394.html)
- [CWE-395 — Use of NullPointerException Catch to Detect NULL Pointer Dereference](https://cwe.mitre.org/data/definitions/395.html)
- [CWE-396 — Declaration of Catch for Generic Exception](https://cwe.mitre.org/data/definitions/396.html)
- [CWE-397 — Declaration of Throws for Generic Exception](https://cwe.mitre.org/data/definitions/397.html)
- [CWE-544 — Missing Standardized Error Handling Mechanism](https://cwe.mitre.org/data/definitions/544.html)
- [CWE-584 — Return Inside Finally Block](https://cwe.mitre.org/data/definitions/584.html)
- [CWE-617 — Reachable Assertion](https://cwe.mitre.org/data/definitions/617.html)
- [CWE-756 — Missing Custom Error Page](https://cwe.mitre.org/data/definitions/756.html)

## Java e OWASP

- [Java SE 8 — Exceptions](https://docs.oracle.com/javase/tutorial/essential/exceptions/)
- [Java SE 8 — try-with-resources](https://docs.oracle.com/javase/tutorial/essential/exceptions/tryResourceClose.html)
- [Java SE 8 — Assertions](https://docs.oracle.com/javase/8/docs/technotes/guides/language/assert.html)
- [OWASP Error Handling Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Error_Handling_Cheat_Sheet.html)
- [OWASP Logging Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html)
- [OWASP REST Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/REST_Security_Cheat_Sheet.html)

---

# 30. Conclusão

Erros de tratamento de falha são perigosos porque podem transformar um problema comum em falha de segurança.

Os controles essenciais são:

- não expor detalhes técnicos ao usuário;
- não ignorar retorno de funções críticas;
- verificar corretamente códigos de status;
- lançar exceções com significado;
- evitar `catch` e `throws` genéricos;
- padronizar respostas de erro;
- registrar falhas com correlation ID;
- não usar `assert` como validação de segurança;
- não retornar dentro de `finally`;
- configurar páginas de erro customizadas;
- testar fluxos de erro, não apenas fluxos de sucesso.

A regra central é:

> Toda condição de erro deve ser tratada de forma explícita, padronizada e segura, preservando informação suficiente para diagnóstico interno sem expor detalhes sensíveis ao usuário ou permitir que o fluxo continue como se tivesse sido bem-sucedido.
