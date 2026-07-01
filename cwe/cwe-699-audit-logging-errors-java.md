# CWE-699 - Software Development

## Category: Audit / Logging Errors - CWE-1210

> Material prático para revisão de prova, análise de código e uso em repositório GitHub.
>
> Foco: exemplos em Java, aplicações web, Struts/JSP, REST, serviços de integração, sistemas legados e rotinas de backend.

---

## 1. Visão geral

A **CWE-699 - Software Development** é uma visão da CWE voltada para fraquezas que aparecem durante o desenvolvimento de software.

Dentro dela, a categoria **CWE-1210 - Audit / Logging Errors** agrupa problemas relacionados à auditoria e aos logs do sistema.

Segundo a CWE, essa categoria cobre fraquezas em componentes de auditoria que registram atividades de usuários, acessos, alterações e eventos relevantes para identificar comportamentos indesejados. Quando esses problemas não são tratados, a capacidade de auditoria do sistema fica degradada.

Importante: **CWE-1210 é uma categoria**, portanto não deve ser usada diretamente para classificar uma vulnerabilidade real. Para isso, deve-se usar uma das CWEs base listadas abaixo.

---

## 2. Estrutura estudada

```text
699 - Software Development
 └── Category Audit / Logging Errors - CWE-1210
     ├── CWE-117 - Improper Output Neutralization for Logs
     ├── CWE-222 - Truncation of Security-relevant Information
     ├── CWE-223 - Omission of Security-relevant Information
     ├── CWE-224 - Obscured Security-relevant Information by Alternate Name
     ├── CWE-778 - Insufficient Logging
     └── CWE-779 - Logging of Excessive Data
```

---

## 3. Ideia central da categoria

Logs e auditorias precisam responder perguntas como:

- Quem realizou a ação?
- O que foi feito?
- Quando ocorreu?
- De onde veio a requisição?
- Qual recurso foi afetado?
- A ação teve sucesso ou falhou?
- O evento foi normal, suspeito ou proibido?
- Existe identificador para correlacionar a ação com outras chamadas?

Um log inseguro pode falhar de duas formas opostas:

1. **Registrar pouco**: não permite investigar incidentes.
2. **Registrar demais**: expõe dados sensíveis ou gera volume que prejudica análise.

Além disso, mesmo quando há log, ele pode ser manipulado por entrada externa, truncado, ambíguo ou registrado com nomes alternativos que escondem o alvo real.

---

## 4. Modelo prático de log seguro em Java

Antes das CWEs específicas, vale definir um padrão mínimo reutilizável.

### 4.1. Utilitário simples para neutralizar dados antes do log

```java
public final class LogSanitizer {

    private static final int LIMITE_PADRAO = 200;

    private LogSanitizer() {
    }

    public static String safe(String valor) {
        return safe(valor, LIMITE_PADRAO);
    }

    public static String safe(String valor, int limite) {
        if (valor == null) {
            return "";
        }

        String normalizado = valor
                .replace('\r', '_')
                .replace('\n', '_')
                .replace('\t', ' ')
                .replaceAll("[\\p{Cntrl}&&[^\\r\\n\\t]]", "_");

        if (normalizado.length() > limite) {
            return normalizado.substring(0, limite) + "...[TRUNCADO_LOG]";
        }

        return normalizado;
    }

    public static String maskCpf(String cpf) {
        if (cpf == null) {
            return "";
        }

        String somenteNumeros = cpf.replaceAll("\\D", "");
        if (somenteNumeros.length() != 11) {
            return "***";
        }

        return somenteNumeros.substring(0, 3)
                + ".***.***-"
                + somenteNumeros.substring(9);
    }

    public static String maskToken(String token) {
        if (token == null || token.length() < 8) {
            return "***";
        }

        return token.substring(0, 4) + "..." + token.substring(token.length() - 4);
    }
}
```

Observação importante: `safe(...)` não é uma solução mágica. Ela reduz risco de quebra de linha, caracteres de controle e volume excessivo. Dados sensíveis ainda devem ser mascarados ou não registrados.

### 4.2. Exemplo de evento de auditoria padronizado

```java
public class AuditoriaService {

    private static final Logger log = LoggerFactory.getLogger(AuditoriaService.class);

    public void registrarAcessoNegado(String usuario,
                                      String acao,
                                      String recurso,
                                      String ip,
                                      String correlationId) {

        log.warn("AUDIT evento=ACESSO_NEGADO usuario={} acao={} recurso={} ip={} correlationId={}",
                LogSanitizer.safe(usuario),
                LogSanitizer.safe(acao),
                LogSanitizer.safe(recurso),
                LogSanitizer.safe(ip),
                LogSanitizer.safe(correlationId));
    }
}
```

Pontos positivos:

- Usa campos previsíveis.
- Evita concatenação direta com entrada externa.
- Facilita busca por `evento=ACESSO_NEGADO`.
- Permite correlacionar eventos por `correlationId`.
- Mantém dados perigosos neutralizados.

---

# CWE-117 - Improper Output Neutralization for Logs

## 1. Conceito

A aplicação monta uma mensagem de log com dados externos, mas não neutraliza caracteres especiais antes de gravar no arquivo de log.

Na prática, isso permite **log forging** ou **log injection**.

Um atacante pode enviar caracteres como `\r`, `\n`, tabulações ou sequências especiais para:

- quebrar a linha do log;
- criar uma entrada falsa;
- esconder uma ação real;
- corromper o formato do arquivo;
- prejudicar ferramentas que processam logs automaticamente.

---

## 2. Exemplo vulnerável em Java

```java
public ActionForward consultar(ActionMapping mapping,
                               ActionForm form,
                               HttpServletRequest request,
                               HttpServletResponse response) {

    String cpf = request.getParameter("cpf");

    try {
        pessoaFacade.consultarPorCpf(cpf);
    } catch (Exception e) {
        log.warn("Falha ao consultar pessoa com CPF = " + cpf);
    }

    return mapping.findForward("sucesso");
}
```

Entrada maliciosa:

```text
12345678900\r\nWARN AUDIT evento=LOGIN_ADMIN_SUCESSO usuario=admin
```

Log gerado:

```text
WARN Falha ao consultar pessoa com CPF = 12345678900
WARN AUDIT evento=LOGIN_ADMIN_SUCESSO usuario=admin
```

O atacante conseguiu inserir uma linha falsa no log.

---

## 3. Solução recomendada

```java
public ActionForward consultar(ActionMapping mapping,
                               ActionForm form,
                               HttpServletRequest request,
                               HttpServletResponse response) {

    String cpf = request.getParameter("cpf");

    try {
        pessoaFacade.consultarPorCpf(cpf);
    } catch (Exception e) {
        log.warn("Falha ao consultar pessoa. cpf={}", LogSanitizer.maskCpf(cpf), e);
    }

    return mapping.findForward("sucesso");
}
```

Melhorias:

- Não concatena entrada externa diretamente.
- Usa placeholder do logger.
- Mascara CPF.
- Neutraliza o dado antes do log.
- Mantém a exceção como último parâmetro para preservar stack trace.

Atenção: **usar placeholder não neutraliza automaticamente CR/LF**. Ele evita problemas de concatenação, mas a entrada ainda precisa ser tratada quando vem de fonte externa.

---

## 4. O que procurar no código

```bash
grep -R "log\..*request.getParameter" src/main/java
grep -R "log\..*getHeader" src/main/java
grep -R "log\..*getQueryString" src/main/java
grep -R "log\..* + .*" src/main/java
grep -R "System.out.println" src/main/java
```

---

## 5. Perguntas de revisão

- Algum dado do usuário é gravado diretamente no log?
- O log registra parâmetros HTTP, headers, URI ou body sem tratamento?
- O sistema remove ou substitui `\r` e `\n`?
- Dados sensíveis são mascarados?
- Existe padrão centralizado para log de auditoria?

---

# CWE-222 - Truncation of Security-relevant Information

## 1. Conceito

A aplicação trunca informação relevante para segurança durante exibição, gravação ou processamento.

O problema não é truncar qualquer texto. O problema é truncar algo que seria necessário para entender:

- origem do ataque;
- alvo real;
- usuário envolvido;
- recurso afetado;
- URI completa;
- identificador da transação;
- payload ou parâmetro malicioso relevante.

---

## 2. Exemplo vulnerável em Java

```java
public void registrarFalhaAutorizacao(HttpServletRequest request, String usuario) {
    String uri = request.getRequestURI();

    if (uri.length() > 80) {
        uri = uri.substring(0, 80);
    }

    log.warn("Acesso negado. usuario={} uri={}", usuario, uri);
}
```

Problema:

```text
/admin/processo/visualizar?codArquivo=123&nivelSigilo=PUBLICO&acao=...
```

Se a parte relevante estiver depois dos 80 caracteres, o log perde justamente o dado necessário para investigação.

---

## 3. Solução recomendada

```java
public void registrarFalhaAutorizacao(HttpServletRequest request,
                                      String usuario,
                                      String correlationId) {

    String uriCompleta = request.getRequestURI();
    String queryString = request.getQueryString();

    String alvoCompleto = queryString == null
            ? uriCompleta
            : uriCompleta + "?" + queryString;

    String hashAlvo = DigestUtils.sha256Hex(alvoCompleto);

    log.warn("AUDIT evento=ACESSO_NEGADO usuario={} alvoHash={} alvoResumo={} tamanhoAlvo={} correlationId={}",
            LogSanitizer.safe(usuario),
            hashAlvo,
            LogSanitizer.safe(alvoCompleto, 300),
            alvoCompleto.length(),
            LogSanitizer.safe(correlationId));
}
```

Essa abordagem registra:

- resumo controlado do alvo;
- tamanho original;
- hash do valor completo;
- correlação para buscar detalhes em outra fonte;
- indicação clara de truncamento quando ocorrer.

---

## 4. Exemplo em regra de negócio

### Vulnerável

```java
log.warn("Erro ao validar documento: {}", mensagemErro.substring(0, 100));
```

### Corrigido

```java
String detalheSeguro = LogSanitizer.safe(mensagemErro, 500);
String hashDetalhe = DigestUtils.sha256Hex(mensagemErro == null ? "" : mensagemErro);

log.warn("Erro ao validar documento. detalhe={} detalheHash={} tamanhoDetalhe={}",
        detalheSeguro,
        hashDetalhe,
        mensagemErro == null ? 0 : mensagemErro.length());
```

---

## 5. O que procurar no código

```bash
grep -R "substring(0" src/main/java
grep -R "left(" src/main/java
grep -R "StringUtils.abbreviate" src/main/java
grep -R "TRUNC" src/main/java
grep -R "getRequestURI" src/main/java
```

---

## 6. Perguntas de revisão

- O truncamento remove justamente o identificador do recurso?
- A aplicação registra que o dado foi truncado?
- Existe hash ou identificador para recuperar o valor completo?
- O log preserva `correlationId`?
- O tamanho original é registrado?

---

# CWE-223 - Omission of Security-relevant Information

## 1. Conceito

A aplicação não registra ou não exibe informação importante para identificar a origem ou natureza de um ataque.

É diferente da CWE-778:

- **CWE-778**: não há log suficiente do evento.
- **CWE-223**: até existe log, mas faltam dados importantes.

---

## 2. Exemplo vulnerável em Java

```java
public boolean autenticar(String login, String senha) {
    boolean autenticado = usuarioService.autenticar(login, senha);

    if (!autenticado) {
        log.warn("Falha de autenticação");
    }

    return autenticado;
}
```

Problema:

O log informa que houve falha, mas não diz:

- qual usuário foi usado;
- de qual IP veio a tentativa;
- qual user-agent;
- horário já existe no log, mas não há `correlationId`;
- se o usuário existe ou não;
- se a conta estava bloqueada;
- se houve múltiplas tentativas.

---

## 3. Solução recomendada

```java
public boolean autenticar(HttpServletRequest request, String login, String senha) {
    boolean autenticado = usuarioService.autenticar(login, senha);

    String ip = obterIpCliente(request);
    String userAgent = request.getHeader("User-Agent");
    String correlationId = obterCorrelationId(request);

    if (!autenticado) {
        log.warn("AUDIT evento=LOGIN_FALHA login={} ip={} userAgent={} correlationId={}",
                LogSanitizer.safe(login),
                LogSanitizer.safe(ip),
                LogSanitizer.safe(userAgent, 150),
                LogSanitizer.safe(correlationId));
    }

    return autenticado;
}
```

A senha nunca deve ser registrada.

---

## 4. Exemplo em acesso negado

### Vulnerável

```java
if (!usuarioPodeBaixarArquivo(usuario, codArquivo)) {
    log.warn("Acesso negado ao arquivo");
    throw new ApplicationException("mensagem.aviso.geral", new String[] {"Acesso negado."});
}
```

### Corrigido

```java
if (!usuarioPodeBaixarArquivo(usuario, codArquivo)) {
    log.warn("AUDIT evento=DOWNLOAD_ARQUIVO_NEGADO usuario={} codArquivo={} codInquerito={} anoInquerito={} ip={} correlationId={}",
            usuario.getLogin(),
            codArquivo,
            codInquerito,
            anoInquerito,
            LogSanitizer.safe(obterIpCliente(request)),
            LogSanitizer.safe(obterCorrelationId(request)));

    throw new ApplicationException("mensagem.aviso.geral", new String[] {"Acesso negado."});
}
```

O usuário recebe uma mensagem genérica, mas o log interno preserva dados suficientes para auditoria.

---

## 5. O que procurar no código

```bash
grep -R "Falha de autenticação" src/main/java
grep -R "Acesso negado" src/main/java
grep -R "catch *(.*Exception" src/main/java
grep -R "throw new ApplicationException" src/main/java
grep -R "return null" src/main/java
```

---

## 6. Perguntas de revisão

- O evento registra usuário ou login informado?
- O recurso afetado aparece no log?
- O IP ou origem da requisição foi registrado?
- Existe `correlationId`?
- O log diferencia sucesso, falha, bloqueio e acesso negado?
- O log registra o motivo técnico sem expor segredo ao usuário?

---

# CWE-224 - Obscured Security-relevant Information by Alternate Name

## 1. Conceito

A aplicação registra informação de segurança usando um nome alternativo em vez do nome canônico da entidade afetada.

Na prática, o log aponta para um nome fornecido pelo usuário, alias, link simbólico, apelido, descrição ou parâmetro indireto, mas não registra o identificador real do recurso afetado.

Isso dificulta descobrir o alvo verdadeiro.

---

## 2. Exemplo vulnerável em Java

```java
public void baixarArquivo(HttpServletRequest request) {
    String nomeArquivo = request.getParameter("nomeArquivo");

    File arquivo = arquivoService.resolverArquivo(nomeArquivo);

    if (!arquivoService.usuarioPodeAcessar(arquivo)) {
        log.warn("Acesso negado ao arquivo {}", nomeArquivo);
        throw new SecurityException("Acesso negado");
    }

    arquivoService.escreverNoResponse(arquivo);
}
```

Problema:

O usuário pode informar um alias, nome amigável ou caminho indireto. O log registra o que o usuário mandou, não o arquivo real resolvido.

---

## 3. Solução recomendada

```java
public void baixarArquivo(HttpServletRequest request) throws IOException {
    String nomeInformado = request.getParameter("nomeArquivo");

    File arquivo = arquivoService.resolverArquivo(nomeInformado);
    String caminhoCanonico = arquivo.getCanonicalPath();
    Long codArquivo = arquivoService.obterCodigoArquivo(arquivo);

    if (!arquivoService.usuarioPodeAcessar(arquivo)) {
        log.warn("AUDIT evento=DOWNLOAD_ARQUIVO_NEGADO nomeInformado={} codArquivo={} caminhoCanonico={} usuario={} ip={}",
                LogSanitizer.safe(nomeInformado),
                codArquivo,
                LogSanitizer.safe(caminhoCanonico, 300),
                usuarioLogado(),
                LogSanitizer.safe(obterIpCliente(request)));

        throw new SecurityException("Acesso negado");
    }

    arquivoService.escreverNoResponse(arquivo);
}
```

Melhorias:

- Registra o nome informado pelo usuário.
- Registra o identificador canônico do recurso.
- Registra o caminho canônico ou ID interno.
- Evita que alias esconda o alvo real.

---

## 4. Exemplo em entidades de negócio

### Vulnerável

```java
log.info("Usuário alterou unidade {}", formulario.getDescrUnidade());
```

### Corrigido

```java
log.info("AUDIT evento=UNIDADE_ALTERADA codUnidade={} descrUnidade={} usuario={}",
        formulario.getCodUnidade(),
        LogSanitizer.safe(formulario.getDescrUnidade()),
        usuario.getLogin());
```

Descrições podem mudar, ser duplicadas ou estar inconsistentes. O identificador canônico é o código interno.

---

## 5. O que procurar no código

```bash
grep -R "descr" src/main/java | grep "log"
grep -R "nomeArquivo" src/main/java
grep -R "getParameter" src/main/java | grep "arquivo"
grep -R "getPath" src/main/java
grep -R "getCanonicalPath" src/main/java
```

---

## 6. Perguntas de revisão

- O log registra apenas descrição, nome ou texto informado pelo usuário?
- Existe código interno do recurso no log?
- O sistema registra o nome canônico após normalização?
- O log diferencia `nomeInformado` de `nomeResolvido`?
- O recurso pode ter alias, apelido, link, descrição duplicada ou caminho relativo?

---

# CWE-778 - Insufficient Logging

## 1. Conceito

Quando ocorre um evento crítico de segurança, o sistema não registra o evento ou registra detalhes insuficientes.

Exemplos comuns:

- login com falha não registrado;
- login bem-sucedido de conta privilegiada não registrado;
- alteração de perfil/permissão sem auditoria;
- download de documento sigiloso sem log;
- tentativa de acesso negado sem log;
- falha de integração crítica sem log;
- exceção capturada e ignorada;
- operação administrativa sem registro.

---

## 2. Exemplo vulnerável em Java

```java
public void alterarPerfilUsuario(Long codUsuario, String novoPerfil) {
    Usuario usuario = usuarioDao.buscar(codUsuario);
    usuario.setPerfil(novoPerfil);
    usuarioDao.salvar(usuario);
}
```

Problema:

A alteração de perfil é crítica, mas não há auditoria.

---

## 3. Solução recomendada

```java
public void alterarPerfilUsuario(Long codUsuario, String novoPerfil, Usuario usuarioLogado) {
    Usuario usuario = usuarioDao.buscar(codUsuario);
    String perfilAnterior = usuario.getPerfil();

    usuario.setPerfil(novoPerfil);
    usuarioDao.salvar(usuario);

    log.warn("AUDIT evento=PERFIL_USUARIO_ALTERADO codUsuarioAlvo={} perfilAnterior={} perfilNovo={} usuarioResponsavel={}",
            codUsuario,
            LogSanitizer.safe(perfilAnterior),
            LogSanitizer.safe(novoPerfil),
            usuarioLogado.getLogin());
}
```

Eventos administrativos devem ser registrados de forma explícita.

---

## 4. Exemplo em integração externa

### Vulnerável

```java
try {
    projudiGateway.regerarDeposito(idCef);
} catch (Exception e) {
    throw new ApplicationException("mensagem.erro.personalizada",
            new String[] {"Erro ao consultar PROJUDI."});
}
```

### Corrigido

```java
try {
    projudiGateway.regerarDeposito(idCef);
} catch (Exception e) {
    log.error("AUDIT evento=INTEGRACAO_PROJUDI_FALHA operacao=REGERAR_DEPOSITO idCef={} usuario={} correlationId={}",
            idCef,
            usuario.getLogin(),
            LogSanitizer.safe(correlationId),
            e);

    throw new ApplicationException("mensagem.erro.personalizada",
            new String[] {"Erro ao consultar PROJUDI."});
}
```

O usuário vê mensagem simples, mas a equipe técnica tem log suficiente para diagnóstico e auditoria.

---

## 5. Eventos mínimos que costumam exigir auditoria

```text
LOGIN_SUCESSO
LOGIN_FALHA
LOGOUT
ACESSO_NEGADO
PERMISSAO_ALTERADA
PERFIL_ALTERADO
SENHA_REDEFINIDA
DOCUMENTO_SIGILOSO_VISUALIZADO
DOCUMENTO_SIGILOSO_BAIXADO
DADO_SENSIVEL_ALTERADO
OPERACAO_ADMINISTRATIVA_EXECUTADA
INTEGRACAO_EXTERNA_FALHA
ERRO_VALIDACAO_SEGURANCA
```

---

## 6. O que procurar no código

```bash
grep -R "catch *(.*Exception" src/main/java
grep -R "e.printStackTrace" src/main/java
grep -R "// TODO.*log" src/main/java
grep -R "setPerfil" src/main/java
grep -R "setSenha" src/main/java
grep -R "baixar" src/main/java
grep -R "sigilo" src/main/java
grep -R "permiss" src/main/java
```

---

## 7. Perguntas de revisão

- Toda ação administrativa gera auditoria?
- Tentativas negadas são registradas?
- Falhas de autenticação são registradas?
- Acesso a dado sigiloso é registrado?
- Erros de integração externa são registrados com operação e identificador?
- Exceções críticas são logadas antes de serem encapsuladas?

---

# CWE-779 - Logging of Excessive Data

## 1. Conceito

A aplicação registra dados em excesso, tornando os logs difíceis de processar e podendo prejudicar análise forense, recuperação ou segurança.

Além do problema de volume, logs excessivos frequentemente expõem dados sensíveis.

Exemplos de dados que normalmente não devem ser logados em claro:

- senha;
- token JWT completo;
- Authorization header;
- cookie de sessão;
- CPF completo;
- dados bancários;
- payload completo de requisição com dados pessoais;
- documentos sigilosos;
- chave de API;
- segredo de integração;
- resposta completa de serviço externo com dados sensíveis.

---

## 2. Exemplo vulnerável em Java

```java
public void autenticar(HttpServletRequest request) throws IOException {
    String body = request.getReader()
            .lines()
            .collect(Collectors.joining(System.lineSeparator()));

    log.info("Requisição de autenticação recebida: headers={} body={}",
            Collections.list(request.getHeaderNames()),
            body);

    autenticacaoService.autenticar(body);
}
```

Problemas:

- Pode registrar senha.
- Pode registrar token.
- Pode registrar cookies.
- Pode registrar dados pessoais.
- Pode gerar volume excessivo.
- Pode violar regras internas de proteção de dados.

---

## 3. Solução recomendada

```java
public void autenticar(HttpServletRequest request, LoginDTO loginDTO) {
    String correlationId = obterCorrelationId(request);

    log.info("AUDIT evento=LOGIN_REQUISICAO login={} ip={} userAgent={} correlationId={}",
            LogSanitizer.safe(loginDTO.getLogin()),
            LogSanitizer.safe(obterIpCliente(request)),
            LogSanitizer.safe(request.getHeader("User-Agent"), 150),
            LogSanitizer.safe(correlationId));

    autenticacaoService.autenticar(loginDTO);
}
```

A senha não é registrada. O body completo não é registrado. O log preserva apenas o necessário.

---

## 4. Exemplo com token JWT

### Vulnerável

```java
String authorization = request.getHeader("Authorization");
log.info("Authorization recebido: {}", authorization);
```

### Corrigido

```java
String authorization = request.getHeader("Authorization");
String tokenMascarado = authorization == null
        ? ""
        : LogSanitizer.maskToken(authorization);

log.debug("Header Authorization recebido. tokenMascarado={}", tokenMascarado);
```

Em muitos casos, nem o token mascarado precisa ser registrado. Use apenas quando houver necessidade real de diagnóstico.

---

## 5. Exemplo com objeto completo

### Vulnerável

```java
log.info("DTO recebido: {}", depositoJudicialDTO);
```

Se o `toString()` do DTO incluir CPF, endereço, chave bancária, número de documento ou dados sigilosos, esses dados irão para o log.

### Corrigido

```java
log.info("AUDIT evento=DEPOSITO_JUDICIAL_SOLICITADO idCef={} codInquerito={} anoInquerito={} tipoDeposito={} usuario={}",
        depositoJudicialDTO.getIdCef(),
        depositoJudicialDTO.getCodInquerito(),
        depositoJudicialDTO.getAnoInquerito(),
        depositoJudicialDTO.getTipoDeposito(),
        usuario.getLogin());
```

Registre campos específicos e necessários, não o objeto inteiro.

---

## 6. O que procurar no código

```bash
grep -R "Authorization" src/main/java
grep -R "password\|senha\|token\|cookie\|secret\|apikey" src/main/java
grep -R "log\..*DTO" src/main/java
grep -R "log\..*body" src/main/java
grep -R "getReader" src/main/java
grep -R "getInputStream" src/main/java
grep -R "toString()" src/main/java | grep "log"
```

---

## 7. Perguntas de revisão

- O log registra body completo?
- O log registra headers completos?
- O log registra CPF, senha, token, cookie ou documento?
- O `toString()` de DTOs contém dados sensíveis?
- O nível `debug` está habilitado em produção?
- O log é necessário ou existe apenas por conveniência?
- Há retenção e controle de acesso aos logs?

---

# 5. Comparação rápida entre as CWEs

| CWE | Problema principal | Exemplo simples | Correção principal |
|---|---|---|---|
| CWE-117 | Entrada externa manipula o formato do log | `\r\n` cria linha falsa | neutralizar CR/LF e caracteres de controle |
| CWE-222 | Informação relevante é cortada | URI truncada esconde parâmetro crítico | registrar resumo, hash, tamanho e correlação |
| CWE-223 | Log existe, mas falta detalhe importante | “Acesso negado” sem usuário/recurso/IP | registrar campos essenciais do evento |
| CWE-224 | Log usa nome alternativo | registra alias em vez do arquivo real | registrar identificador canônico e nome resolvido |
| CWE-778 | Evento crítico não é logado | alteração de perfil sem auditoria | criar trilha de auditoria para eventos críticos |
| CWE-779 | Log registra dados demais | body completo com senha/token | whitelist de campos e mascaramento |

---

# 6. Checklist prático para revisão de código

## 6.1. Segurança do conteúdo do log

- [ ] Dados externos são neutralizados antes de ir para o log.
- [ ] CR/LF são removidos ou substituídos.
- [ ] Caracteres de controle são tratados.
- [ ] Dados sensíveis são mascarados.
- [ ] Senhas nunca são registradas.
- [ ] Tokens e cookies não são registrados em claro.
- [ ] Body completo não é registrado sem justificativa.

## 6.2. Qualidade da auditoria

- [ ] Eventos críticos possuem log.
- [ ] Acesso negado é registrado.
- [ ] Alteração de permissão é registrada.
- [ ] Acesso a documento sigiloso é registrado.
- [ ] Falha de integração externa é registrada.
- [ ] Há `correlationId`.
- [ ] Há usuário responsável.
- [ ] Há recurso afetado.
- [ ] Há resultado da operação: sucesso, falha, negado ou bloqueado.

## 6.3. Identificação correta do recurso

- [ ] O log usa código interno quando existir.
- [ ] O log não depende apenas de descrição textual.
- [ ] O log registra nome informado e nome resolvido quando houver alias.
- [ ] Caminhos de arquivo são canonicalizados antes do log.
- [ ] Identificadores longos não são truncados sem hash/correlação.

---

# 7. Padrão sugerido para eventos de auditoria

```text
AUDIT evento=<EVENTO> usuario=<LOGIN> recurso=<ID> resultado=<RESULTADO> ip=<IP> correlationId=<ID>
```

Exemplos:

```text
AUDIT evento=LOGIN_FALHA usuario=evaldo ip=10.0.0.15 correlationId=abc-123
AUDIT evento=ACESSO_NEGADO usuario=evaldo recurso=Arquivo:123 resultado=NEGADO ip=10.0.0.15 correlationId=abc-123
AUDIT evento=PERFIL_ALTERADO usuarioResponsavel=admin usuarioAlvo=jsilva perfilAnterior=USER perfilNovo=ADMIN correlationId=abc-123
```

---

# 8. Exemplo completo: filtro para criar correlationId

```java
public class CorrelationIdFilter implements Filter {

    private static final String HEADER_CORRELATION_ID = "X-Correlation-Id";

    @Override
    public void doFilter(ServletRequest servletRequest,
                         ServletResponse servletResponse,
                         FilterChain chain) throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;

        String correlationId = request.getHeader(HEADER_CORRELATION_ID);

        if (correlationId == null || !correlationId.matches("[A-Za-z0-9._-]{1,80}")) {
            correlationId = UUID.randomUUID().toString();
        }

        MDC.put("correlationId", correlationId);
        response.setHeader(HEADER_CORRELATION_ID, correlationId);

        try {
            chain.doFilter(request, response);
        } finally {
            MDC.remove("correlationId");
        }
    }
}
```

Com isso, o padrão do log pode incluir `%X{correlationId}` no layout do Logback/Log4j.

---

# 9. Exemplo de configuração Logback

```xml
<configuration>
    <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>${LOG_DIR:-logs}/aplicacao.log</file>

        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>${LOG_DIR:-logs}/aplicacao.%d{yyyy-MM-dd}.log</fileNamePattern>
            <maxHistory>30</maxHistory>
        </rollingPolicy>

        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} %-5level [%thread] correlationId=%X{correlationId} %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>

    <root level="INFO">
        <appender-ref ref="FILE" />
    </root>
</configuration>
```

Pontos de atenção:

- Evite `DEBUG` em produção sem necessidade.
- Defina retenção.
- Proteja acesso aos arquivos de log.
- Separe logs técnicos de logs de auditoria quando possível.
- Evite registrar dados pessoais sem necessidade.

---

# 10. Testes práticos

## 10.1. Teste para CWE-117

Enviar parâmetro com quebra de linha:

```text
cpf=12345678900%0D%0AWARN%20AUDIT%20evento=FAKE_LOGIN
```

Resultado esperado:

- O log não deve criar uma nova linha falsa.
- O valor deve aparecer neutralizado.

## 10.2. Teste para CWE-222

Enviar URI muito longa:

```text
/baixarArquivo?codArquivo=123&parametroMuitoLongo=AAAA....&nivelSigilo=SIGILOSO
```

Resultado esperado:

- O log deve indicar truncamento, tamanho original, hash e correlationId.

## 10.3. Teste para CWE-223

Forçar acesso negado.

Resultado esperado:

- O log deve conter usuário, recurso, IP, resultado e correlationId.

## 10.4. Teste para CWE-224

Acessar recurso por alias, descrição ou nome alternativo.

Resultado esperado:

- O log deve conter o nome informado e o identificador canônico resolvido.

## 10.5. Teste para CWE-778

Executar alteração administrativa.

Resultado esperado:

- A alteração deve gerar evento de auditoria.

## 10.6. Teste para CWE-779

Enviar login com senha e token.

Resultado esperado:

- Senha não aparece no log.
- Token completo não aparece no log.
- Body completo não aparece no log.

---

# 11. Resumo para prova

- **CWE-117**: o atacante manipula o conteúdo do log. Corrigir neutralizando saída para log.
- **CWE-222**: o sistema corta informação importante. Corrigir preservando identificadores, hash, tamanho e correlação.
- **CWE-223**: o log existe, mas omite dados relevantes. Corrigir definindo campos mínimos de auditoria.
- **CWE-224**: o log usa nome alternativo e esconde o alvo real. Corrigir registrando identificador canônico.
- **CWE-778**: o sistema não registra evento crítico. Corrigir com auditoria para eventos de segurança.
- **CWE-779**: o sistema registra informação demais. Corrigir com minimização, whitelist e mascaramento.

Regra prática:

> Log seguro registra o suficiente para investigar, mas não o suficiente para vazar segredo.

---

# 12. Referências

- CWE-1210 - Audit / Logging Errors: https://cwe.mitre.org/data/definitions/1210.html
- CWE-117 - Improper Output Neutralization for Logs: https://cwe.mitre.org/data/definitions/117.html
- CWE-222 - Truncation of Security-relevant Information: https://cwe.mitre.org/data/definitions/222.html
- CWE-223 - Omission of Security-relevant Information: https://cwe.mitre.org/data/definitions/223.html
- CWE-224 - Obscured Security-relevant Information by Alternate Name: https://cwe.mitre.org/data/definitions/224.html
- CWE-778 - Insufficient Logging: https://cwe.mitre.org/data/definitions/778.html
- CWE-779 - Logging of Excessive Data: https://cwe.mitre.org/data/definitions/779.html
