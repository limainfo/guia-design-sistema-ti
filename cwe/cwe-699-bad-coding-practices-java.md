# CWE-699 — Software Development
## Categoria: CWE-1006 — Bad Coding Practices
> **Objetivo:** material prático para revisão e uso em GitHub, com foco em Java, aplicações web legadas, Struts/Servlet/JSP, APIs REST, serviços corporativos e código executado em application server.
> **Fonte principal:** MITRE CWE — `https://cwe.mitre.org/data/definitions/1006.html`  
> A CWE-1006 é uma **Category** dentro da view **CWE-699 - Software Development**. Por ser categoria, não deve ser usada diretamente para mapear vulnerabilidades reais. Para análise prática, correção e mapeamento, use as CWEs Base/Class/Variant listadas nesta documentação.
---
## 1. Visão geral
A categoria **Bad Coding Practices** reúne práticas de codificação que, isoladamente, podem parecer apenas problemas de qualidade, mas aumentam muito a chance de surgirem vulnerabilidades exploráveis. Em sistemas Java corporativos, essas fraquezas aparecem em métodos longos, Actions com muita responsabilidade, uso excessivo de estado global, dependências legadas, SQL/IO em loops, código de debug, comentários imprecisos, constantes espalhadas e decisões de segurança baseadas em dados manipuláveis.
**Ideia central para revisão:** esta categoria não é apenas sobre estilo. Ela aponta sinais de que o sistema pode estar difícil de manter, difícil de auditar e mais propenso a falhas reais de autenticação, autorização, exposição de dados, DoS, inconsistência de regra e bypass de validação.
---
## 2. Mapa rápido da categoria
| CWE | Nome | Aplicabilidade em Java | Foco prático |
|---:|---|---|---|
| 358 | Improperly Implemented Security Check for Standard | Alta | Um padrão ou algoritmo exige checagens obrigatórias, mas a implementação aplica apenas parte delas. |
| 360 | Trust of System Event Data | Média | O sistema confia em dados de evento, ambiente ou infraestrutura como se fossem prova de identidade/autorização. |
| 478 | Missing Default Case in Multiple Condition Expression | Alta | Um `switch`/condicional múltiplo não possui caminho padrão seguro. |
| 487 | Reliance on Package-level Scope | Média | O código depende de visibilidade package-private para proteger dados ou funções sensíveis. |
| 489 | Active Debug Code | Alta | Código de debug permanece ativo em produção. |
| 547 | Use of Hard-coded, Security-relevant Constants | Alta | Segredos, chaves ou constantes de segurança são fixados no código. |
| 561 | Dead Code | Alta | Código que nunca é executado permanece no sistema. |
| 562 | Return of Stack Variable Address | Baixa em Java | Em C/C++, retorna-se endereço de variável local. Em Java isso não ocorre da mesma forma, mas há analogia com retorno de referência mutável interna. |
| 563 | Assignment to Variable without Use | Alta | Uma variável recebe valor, mas esse valor nunca influencia a execução. |
| 581 | Object Model Violation: Just One of Equals and Hashcode Defined | Alta | A classe sobrescreve `equals` sem `hashCode`, ou vice-versa. |
| 586 | Explicit Call to Finalize() | Média | O código chama `finalize()` diretamente ou depende dele para liberar recurso. |
| 605 | Multiple Binds to the Same Port | Média | Mais de um componente tenta escutar a mesma porta. |
| 628 | Function Call with Incorrectly Specified Arguments | Alta | Uma função é chamada com argumentos em ordem, tipo ou semântica incorreta. |
| 654 | Reliance on a Single Factor in a Security Decision | Alta | Uma decisão de segurança depende de um único fator frágil. |
| 656 | Reliance on Security Through Obscurity | Alta | O sistema considera seguro algo que apenas é difícil de adivinhar. |
| 694 | Use of Multiple Resources with Duplicate Identifier | Média | Dois recursos diferentes usam o mesmo identificador ou o sistema não garante unicidade. |
| 807 | Reliance on Untrusted Inputs in a Security Decision | Alta | O sistema toma decisão de segurança com base em dado controlado pelo usuário. |
| 1041 | Use of Redundant Code | Alta | A mesma lógica é copiada em vários pontos. |
| 1043 | Data Element Aggregating an Excessively Large Number of Non-Primitive Elements | Média | Um objeto agrega quantidade excessiva de objetos complexos. |
| 1044 | Architecture with Number of Horizontal Layers Outside of Expected Range | Alta | A arquitetura tem camadas de menos ou de mais para a complexidade do sistema. |
| 1045 | Parent Class with a Virtual Destructor and a Child Class without a Virtual Destructor | Baixa em Java | Fraqueza típica de C++. Em Java, a analogia prática é uma hierarquia sem contrato claro de encerramento de recursos. |
| 1046 | Creation of Immutable Text Using String Concatenation | Alta | Criação repetida de `String` imutável por concatenação, especialmente em loop. |
| 1048 | Invokable Control Element with Large Number of Outward Calls | Alta | Um método chama muitos serviços, DAOs ou integrações externas. |
| 1049 | Excessive Data Query Operations in a Large Data Table | Alta | O código executa consultas excessivas sobre tabela grande. |
| 1050 | Excessive Platform Resource Consumption within a Loop | Alta | O loop cria ou consome recursos caros repetidamente. |
| 1063 | Creation of Class Instance within a Static Code Block | Média | Um bloco estático cria instância com dependência externa ou recurso pesado. |
| 1065 | Runtime Resource Management Control Element in a Component Built to Run on Application Servers | Alta | Componente de app server gerencia manualmente recursos que deveriam ser gerenciados pelo container. |
| 1066 | Missing Serialization Control Element | Alta | Classe serializável não controla versão, campos sensíveis ou validação ao desserializar. |
| 1067 | Excessive Execution of Sequential Searches of Data Resource | Alta | O código faz buscas sequenciais repetidas em listas ou recursos de dados. |
| 1070 | Serializable Data Element Containing non-Serializable Item Elements | Alta | Classe serializável contém campos que não são serializáveis. |
| 1071 | Empty Code Block | Alta | Bloco vazio, especialmente `catch`, `if` ou `else`, oculta erro ou fluxo incompleto. |
| 1072 | Data Resource Access without Use of Connection Pooling | Alta | Acesso ao banco sem pool de conexões. |
| 1073 | Non-SQL Invokable Control Element with Excessive Number of Data Resource Accesses | Alta | Um método que não é DAO executa muitos acessos a dados. |
| 1079 | Parent Class without Virtual Destructor Method | Baixa em Java | Fraqueza típica de C++. Em Java, a analogia é uma classe base que não define contrato de liberação/fechamento para subclasses com recursos. |
| 1082 | Class Instance Self Destruction Control Element | Baixa/Média | Objeto controla a própria destruição de forma inesperada. Em Java, aparece como objeto encerrando JVM, thread ou estado global. |
| 1084 | Invokable Control Element with Excessive File or Data Access Operations | Alta | Um método executa operações excessivas de arquivo ou dados. |
| 1085 | Invokable Control Element with Excessive Volume of Commented-out Code | Alta | Método contém grande volume de código comentado. |
| 1087 | Class with Virtual Method without a Virtual Destructor | Baixa em Java | Fraqueza típica de C++. Em Java, a analogia é classe extensível com métodos sobrescrevíveis sem lifecycle seguro. |
| 1089 | Large Data Table with Excessive Number of Indices | Média | Tabela grande tem índices em excesso. |
| 1092 | Use of Same Invokable Control Element in Multiple Architectural Layers | Alta | O mesmo método/função é usado em camadas diferentes com responsabilidades diferentes. |
| 1094 | Excessive Index Range Scan for a Data Resource | Alta | Consulta força varredura ampla de índice ou tabela. |
| 1097 | Persistent Storable Data Element without Associated Comparison Control Element | Média | Elemento persistente não possui forma consistente de comparação. |
| 1098 | Data Element containing Pointer Item without Proper Copy Control Element | Baixa em Java | Fraqueza típica de C/C++. Em Java, a analogia é manter referências mutáveis sem cópia defensiva. |
| 1099 | Inconsistent Naming Conventions for Identifiers | Alta | Identificadores usam nomes inconsistentes. |
| 1101 | Reliance on Runtime Component in Generated Code | Média | Código gerado depende de runtime específico não controlado ou pouco documentado. |
| 1102 | Reliance on Machine-Dependent Data Representation | Alta | O código depende de representação da máquina/plataforma. |
| 1103 | Use of Platform-Dependent Third Party Components | Alta | Componente de terceiro depende de plataforma específica. |
| 1104 | Use of Unmaintained Third Party Components | Alta | O sistema depende de componente sem manutenção. |
| 1106 | Insufficient Use of Symbolic Constants | Alta | Valores mágicos são usados diretamente no código. |
| 1107 | Insufficient Isolation of Symbolic Constant Definitions | Alta | Constantes de domínio ficam espalhadas por JSP, Action, DAO, SQL e JavaScript. |
| 1108 | Excessive Reliance on Global Variables | Alta | O sistema usa estado global mutável em excesso. |
| 1109 | Use of Same Variable for Multiple Purposes | Alta | A mesma variável representa coisas diferentes ao longo do método. |
| 1113 | Inappropriate Comment Style | Média | Comentários têm estilo inadequado, poluem ou confundem o código. |
| 1114 | Inappropriate Whitespace Style | Média | Formatação ruim torna o código difícil de revisar. |
| 1115 | Source Code Element without Standard Prologue | Média | Arquivos ou elementos importantes não trazem prólogo/cabeçalho padrão quando exigido pelo projeto. |
| 1116 | Inaccurate Source Code Comments | Alta | Comentário não corresponde ao comportamento real do código. |
| 1117 | Callable with Insufficient Behavioral Summary | Alta | Método público não informa contrato, pré-condições, efeitos colaterais ou exceções relevantes. |
| 1126 | Declaration of Variable with Unnecessarily Wide Scope | Alta | Variável é declarada em escopo mais amplo do que o necessário. |
| 1127 | Compilation with Insufficient Warnings or Errors | Alta | Build compila com poucos avisos ou ignora alertas relevantes. |
| 1235 | Incorrect Use of Autoboxing and Unboxing for Performance Critical Operations | Alta | Uso de wrappers (`Long`, `Integer`, `Boolean`) onde primitivos seriam mais adequados em caminho crítico. |

---
## 3. Princípios seguros para esta categoria
1. **Falha segura:** quando houver valor inesperado, erro de integração, enum desconhecido ou parâmetro inválido, negar e registrar.
2. **Separação de responsabilidades:** Action/Controller não deve concentrar regra de negócio, autorização, SQL, IO, integração externa e geração de PDF.
3. **Servidor decide segurança:** dados de request, hidden field, cookie, header e evento externo nunca devem decidir permissão sozinhos.
4. **Código legível é requisito de segurança:** nomes ruins, variáveis reutilizadas, comentários incorretos e código morto dificultam detectar vulnerabilidades.
5. **Recursos gerenciados:** em application server, usar `DataSource`, pools, executores gerenciados e lifecycle do container.
6. **Dependências mantidas:** bibliotecas sem manutenção e runtimes gerados sem controle viram dívida de segurança.
7. **Performance também protege disponibilidade:** loops com consulta, concatenação de string, boxing em massa e buscas sequenciais podem virar DoS.
8. **Constantes e regras em um lugar só:** códigos mágicos espalhados geram comportamento divergente entre backend, JSP e SQL.

---
## 4. Base de apoio para os exemplos
Os exemplos usam classes simples. Adapte para Struts, Servlet, Spring MVC, Jakarta EE ou Java legado conforme o projeto.
```java
public final class AcessoNegadoException extends RuntimeException {
    public AcessoNegadoException(String mensagem) {
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

public final class Usuario {
    private final String login;
    private final Set<String> permissoes;

    public Usuario(String login, Set<String> permissoes) {
        this.login = login;
        this.permissoes = permissoes == null ? Collections.emptySet() : permissoes;
    }

    public boolean possuiPermissao(String permissao) {
        return permissoes.contains(permissao);
    }

    public String getLogin() {
        return login;
    }
}
```

---
## 5. Checagens de segurança e confiança

### CWE-358 — Improperly Implemented Security Check for Standard

**Aplicabilidade em Java:** Alta  
**Problema:** Um padrão ou algoritmo exige checagens obrigatórias, mas a implementação aplica apenas parte delas.  
**Risco:** Tokens, certificados, assinaturas ou protocolos podem ser aceitos mesmo violando requisitos do padrão.

**Exemplo vulnerável**

```java
public Usuario validarToken(String token) {
    Claims claims = JwtParser.parser().parseClaimsJwt(token).getBody();
    // Falha: não verifica assinatura, issuer, audience, expiração nem algoritmo aceito.
    return usuarioService.buscarPorLogin(claims.getSubject());
}
```

**Solução / prática segura**

```java
public Usuario validarToken(String token) {
    Claims claims = JwtParser.parser()
        .requireIssuer(ISSUER_ESPERADO)
        .requireAudience(AUDIENCE_ESPERADA)
        .verifyWith(chavePublicaConfiavel)
        .build()
        .parseSignedClaims(token)
        .getPayload();

    if (claims.getExpiration().before(new Date())) {
        throw new AcessoNegadoException("Token expirado.");
    }
    return usuarioService.buscarPorLogin(claims.getSubject());
}
```

**Como revisar:** Em revisões, procurar validação parcial de JWT, OAuth, certificado, assinatura digital, CRL/OCSP, assinatura HMAC e protocolos com requisitos normativos.

### CWE-360 — Trust of System Event Data

**Aplicabilidade em Java:** Média  
**Problema:** O sistema confia em dados de evento, ambiente ou infraestrutura como se fossem prova de identidade/autorização.  
**Risco:** Cabeçalhos, eventos, filas ou propriedades de sistema podem ser falsificados ou manipulados.

**Exemplo vulnerável**

```java
public boolean isRequisicaoInterna(HttpServletRequest request) {
    String origem = request.getHeader("X-Forwarded-For");
    return origem != null && origem.startsWith("10.");
}
```

**Solução / prática segura**

```java
public boolean isRequisicaoInterna(HttpServletRequest request) {
    String sistema = request.getHeader("X-Sistema-Origem");
    String assinatura = request.getHeader("X-Assinatura");
    String corpo = lerCorpoNormalizado(request);

    return sistemaPermitido(sistema)
        && hmacService.assinaturaValida(sistema, corpo, assinatura)
        && redeConfiavelDoProxy(request);
}
```

**Como revisar:** Não usar IP, host, header, user-agent, nome da máquina ou evento de sistema como única evidência de confiança.

### CWE-478 — Missing Default Case in Multiple Condition Expression

**Aplicabilidade em Java:** Alta  
**Problema:** Um `switch`/condicional múltiplo não possui caminho padrão seguro.  
**Risco:** Novos valores de enum, parâmetros inesperados ou valores manipulados podem cair em comportamento permissivo ou inconsistente.

**Exemplo vulnerável**

```java
public boolean podeExecutar(String acao, Usuario usuario) {
    boolean permitido = true; // Falha: default permissivo.

    switch (acao) {
        case "CONSULTAR": permitido = usuario.podeConsultar(); break;
        case "ALTERAR": permitido = usuario.podeAlterar(); break;
        case "EXCLUIR": permitido = usuario.podeExcluir(); break;
    }
    return permitido;
}
```

**Solução / prática segura**

```java
public boolean podeExecutar(String acao, Usuario usuario) {
    switch (acao) {
        case "CONSULTAR": return usuario.podeConsultar();
        case "ALTERAR": return usuario.podeAlterar();
        case "EXCLUIR": return usuario.podeExcluir();
        default:
            auditoria.registrarNegacao(usuario, acao, "Ação desconhecida");
            return false;
    }
}
```

**Como revisar:** Em segurança, o `default` deve ser negar, registrar e encerrar o fluxo.

### CWE-489 — Active Debug Code

**Aplicabilidade em Java:** Alta  
**Problema:** Código de debug permanece ativo em produção.  
**Risco:** Pode expor stack trace, liberar autenticação, alterar fluxo, habilitar endpoints internos ou vazar segredo.

**Exemplo vulnerável**

```java
public ActionForward login(ActionMapping mapping, ActionForm form,
        HttpServletRequest request, HttpServletResponse response) {

    if ("true".equals(request.getParameter("debugLogin"))) {
        request.getSession().setAttribute("usuario", usuarioService.buscarAdmin());
        return mapping.findForward("home");
    }
    return autenticarNormalmente(mapping, form, request, response);
}
```

**Solução / prática segura**

```java
public ActionForward login(ActionMapping mapping, ActionForm form,
        HttpServletRequest request, HttpServletResponse response) {

    // Código de debug não deve existir no binário de produção.
    return autenticarNormalmente(mapping, form, request, response);
}
```

**Como revisar:** Remover `debug`, `bypass`, `mock`, `teste`, `TODO liberar`, endpoints temporários e stack traces detalhados antes do deploy.

### CWE-547 — Use of Hard-coded, Security-relevant Constants

**Aplicabilidade em Java:** Alta  
**Problema:** Segredos, chaves ou constantes de segurança são fixados no código.  
**Risco:** Vazamento no Git, dificuldade de rotação, reutilização entre ambientes e comprometimento amplo.

**Exemplo vulnerável**

```java
public final class JwtConfig {
    public static final String SECRET = "minha-chave-super-secreta-123";
}
```

**Solução / prática segura**

```java
public final class JwtConfig {
    private final SecretKey chave;

    public JwtConfig(SecretProvider secretProvider) {
        this.chave = secretProvider.obterChave("jwt.signing.key");
    }

    public SecretKey getChave() {
        return chave;
    }
}
```

**Como revisar:** Segredos devem vir de vault, variável de ambiente protegida, keystore ou mecanismo corporativo de segredo.

### CWE-654 — Reliance on a Single Factor in a Security Decision

**Aplicabilidade em Java:** Alta  
**Problema:** Uma decisão de segurança depende de um único fator frágil.  
**Risco:** Se esse fator for falsificado ou comprometido, a decisão inteira cai.

**Exemplo vulnerável**

```java
public boolean podeAcessarAdmin(HttpServletRequest request) {
    return request.getRemoteAddr().startsWith("10.");
}
```

**Solução / prática segura**

```java
public boolean podeAcessarAdmin(HttpServletRequest request, Usuario usuario) {
    return redeInternaValidada(request)
        && usuario != null
        && usuario.possuiPermissao("ADMIN_ACESSAR")
        && mfaService.sessaoPossuiMfaRecente(usuario);
}
```

**Como revisar:** Não basear segurança apenas em IP, header, obscuridade de URL, cookie não assinado, nome de máquina ou perfil amplo.

### CWE-656 — Reliance on Security Through Obscurity

**Aplicabilidade em Java:** Alta  
**Problema:** O sistema considera seguro algo que apenas é difícil de adivinhar.  
**Risco:** URLs, nomes de métodos, parâmetros ou caminhos ocultos podem ser descobertos por log, histórico, proxy, spidering ou tentativa.

**Exemplo vulnerável**

```java
// A URL é considerada segura porque não aparece no menu.
// /sistema/admin/excluirTudoXYZ123.do?action=executar
public ActionForward executar(...) {
    service.excluirRegistrosAntigos();
    return ok(mapping);
}
```

**Solução / prática segura**

```java
public ActionForward executar(ActionMapping mapping, ActionForm form,
        HttpServletRequest request, HttpServletResponse response) {

    Usuario usuario = usuarioAtual(request);
    authorizationGuard.exigirPermissao(usuario, "ROTINA_ADMIN_EXCLUIR_REGISTROS");
    service.excluirRegistrosAntigos(usuario);
    return ok(mapping);
}
```

**Como revisar:** URL difícil, nome obscuro, endpoint não documentado e botão escondido não substituem autenticação, autorização e auditoria.

### CWE-807 — Reliance on Untrusted Inputs in a Security Decision

**Aplicabilidade em Java:** Alta  
**Problema:** O sistema toma decisão de segurança com base em dado controlado pelo usuário.  
**Risco:** O usuário altera parâmetro, hidden field, cookie ou header para ganhar acesso.

**Exemplo vulnerável**

```java
public boolean podeAlterar(HttpServletRequest request) {
    return "ADMIN".equals(request.getParameter("perfil"));
}
```

**Solução / prática segura**

```java
public boolean podeAlterar(HttpServletRequest request) {
    Usuario usuario = usuarioAtual(request);
    return usuario != null && usuario.possuiPermissao("REGISTRO_ALTERAR");
}
```

**Como revisar:** Tudo que vem de request, cookie, localStorage, hidden field, query string, header ou JSON deve ser tratado como não confiável.

## 6. Encapsulamento e manutenibilidade

### CWE-487 — Reliance on Package-level Scope

**Aplicabilidade em Java:** Média  
**Problema:** O código depende de visibilidade package-private para proteger dados ou funções sensíveis.  
**Risco:** Qualquer classe no mesmo pacote pode alterar estado interno ou chamar função que deveria ser controlada.

**Exemplo vulnerável**

```java
class SessaoSeguranca {
    Usuario usuarioAtual; // package-private
    boolean modoAdministrador; // qualquer classe do pacote altera
}
```

**Solução / prática segura**

```java
public final class SessaoSeguranca {
    private final Usuario usuarioAtual;
    private final boolean modoAdministrador;

    public SessaoSeguranca(Usuario usuarioAtual, boolean modoAdministrador) {
        this.usuarioAtual = Objects.requireNonNull(usuarioAtual);
        this.modoAdministrador = modoAdministrador;
    }

    public boolean isModoAdministrador() {
        return modoAdministrador;
    }
}
```

**Como revisar:** Dados de sessão, permissão, credencial, token, status de autorização e configurações devem ser `private`, preferencialmente imutáveis.

### CWE-561 — Dead Code

**Aplicabilidade em Java:** Alta  
**Problema:** Código que nunca é executado permanece no sistema.  
**Risco:** Validações aparentes podem estar inacessíveis, gerando falsa sensação de segurança.

**Exemplo vulnerável**

```java
public void salvar(Deposito deposito) {
    if (deposito == null) {
        throw new IllegalArgumentException("Depósito obrigatório");
    }
    dao.salvar(deposito);
    return;

    // Falha: nunca executa.
    validarPermissaoAlteracao(deposito);
}
```

**Solução / prática segura**

```java
public void salvar(Deposito deposito, Usuario usuario) {
    if (deposito == null) {
        throw new IllegalArgumentException("Depósito obrigatório");
    }
    validarPermissaoAlteracao(deposito, usuario);
    dao.salvar(deposito);
}
```

**Como revisar:** Dead code em validação, autorização, auditoria e tratamento de erro deve ser removido ou reposicionado.

### CWE-563 — Assignment to Variable without Use

**Aplicabilidade em Java:** Alta  
**Problema:** Uma variável recebe valor, mas esse valor nunca influencia a execução.  
**Risco:** Validação, autorização ou sanitização pode parecer aplicada, mas não ser usada.

**Exemplo vulnerável**

```java
public void alterar(HttpServletRequest request) {
    boolean autorizado = authorizationService.podeAlterar(usuario(), request.getParameter("id"));
    // Falha: variável calculada, mas ignorada.
    dao.alterar(montarEntidade(request));
}
```

**Solução / prática segura**

```java
public void alterar(HttpServletRequest request) {
    boolean autorizado = authorizationService.podeAlterar(usuario(), request.getParameter("id"));
    if (!autorizado) {
        throw new AcessoNegadoException("Usuário sem permissão para alterar o registro.");
    }
    dao.alterar(montarEntidade(request));
}
```

**Como revisar:** Ferramentas SAST/Sonar costumam detectar atribuição sem uso; trate como relevante quando envolver segurança.

### CWE-581 — Object Model Violation: Just One of Equals and Hashcode Defined

**Aplicabilidade em Java:** Alta  
**Problema:** A classe sobrescreve `equals` sem `hashCode`, ou vice-versa.  
**Risco:** Coleções, caches e verificações de permissão podem falhar de forma inconsistente.

**Exemplo vulnerável**

```java
public class Permissao {
    private String codigo;

    @Override
    public boolean equals(Object obj) {
        return obj instanceof Permissao
            && Objects.equals(codigo, ((Permissao) obj).codigo);
    }
}
```

**Solução / prática segura**

```java
public class Permissao {
    private String codigo;

    @Override
    public boolean equals(Object obj) {
        return obj instanceof Permissao
            && Objects.equals(codigo, ((Permissao) obj).codigo);
    }

    @Override
    public int hashCode() {
        return Objects.hash(codigo);
    }
}
```

**Como revisar:** Atenção a entidades usadas em `HashSet`, `HashMap`, caches de autorização e listas de permissões.

### CWE-586 — Explicit Call to Finalize()

**Aplicabilidade em Java:** Média  
**Problema:** O código chama `finalize()` diretamente ou depende dele para liberar recurso.  
**Risco:** Liberação de recurso fica imprevisível e pode causar vazamento, indisponibilidade ou comportamento inconsistente.

**Exemplo vulnerável**

```java
ArquivoTemporario tmp = new ArquivoTemporario(path);
tmp.finalize(); // Falha: nunca chame finalize diretamente.
```

**Solução / prática segura**

```java
try (ArquivoTemporario tmp = new ArquivoTemporario(path)) {
    tmp.processar();
} // close() executado de forma determinística.
```

**Como revisar:** Usar `AutoCloseable`, `try-with-resources` e lifecycle do container. Evitar `finalize`, que é legado.

### CWE-628 — Function Call with Incorrectly Specified Arguments

**Aplicabilidade em Java:** Alta  
**Problema:** Uma função é chamada com argumentos em ordem, tipo ou semântica incorreta.  
**Risco:** Validação ou consulta de segurança pode usar o campo errado e liberar acesso indevido.

**Exemplo vulnerável**

```java
public boolean podeBaixar(Long codUsuario, Long codArquivo) {
    // Assinatura: verificarAcesso(codArquivo, codUsuario)
    return arquivoDao.verificarAcesso(codUsuario, codArquivo); // ordem invertida
}
```

**Solução / prática segura**

```java
public boolean podeBaixar(Long codUsuario, Long codArquivo) {
    return arquivoDao.verificarAcesso(
        new VerificacaoAcessoArquivo(codArquivo, codUsuario)
    );
}
```

**Como revisar:** Prefira objetos de parâmetro, tipos específicos e nomes claros quando houver vários `Long`, `String` ou `Integer` seguidos.

### CWE-1041 — Use of Redundant Code

**Aplicabilidade em Java:** Alta  
**Problema:** A mesma lógica é copiada em vários pontos.  
**Risco:** Uma cópia é corrigida, outra permanece vulnerável.

**Exemplo vulnerável**

```java
// Action A
if (usuario.isAdmin()) { salvar(); }

// Action B, regra copiada e esquecida
if (usuario.isAdmin() || "S".equals(request.getParameter("liberar"))) { salvar(); }
```

**Solução / prática segura**

```java
authorizationGuard.exigirPermissao(usuario, "REGISTRO_SALVAR");
registroService.salvar(dto, usuario);
```

**Como revisar:** Centralizar validação, autorização, sanitização, conversão de charset e montagem de SQL.

### CWE-1071 — Empty Code Block

**Aplicabilidade em Java:** Alta  
**Problema:** Bloco vazio, especialmente `catch`, `if` ou `else`, oculta erro ou fluxo incompleto.  
**Risco:** Falhas de segurança são ignoradas e o sistema continua em estado inseguro.

**Exemplo vulnerável**

```java
try {
    authorizationGuard.exigirPermissao(usuario, "ARQUIVO_BAIXAR");
} catch (AcessoNegadoException e) {
    // vazio: fluxo continua
}
baixarArquivo();
```

**Solução / prática segura**

```java
try {
    authorizationGuard.exigirPermissao(usuario, "ARQUIVO_BAIXAR");
} catch (AcessoNegadoException e) {
    auditoria.registrarNegacao(usuario, "ARQUIVO_BAIXAR");
    throw e;
}
baixarArquivo();
```

**Como revisar:** `catch` vazio em autenticação, autorização, IO, transação e criptografia deve ser tratado como crítico.

### CWE-1085 — Invokable Control Element with Excessive Volume of Commented-out Code

**Aplicabilidade em Java:** Alta  
**Problema:** Método contém grande volume de código comentado.  
**Risco:** Dificulta revisão, esconde lógica antiga vulnerável e aumenta chance de reativação acidental.

**Exemplo vulnerável**

```java
public void salvar() {
    // if (debug) liberarTudo();
    // usuario.setAdmin(true);
    // dao.salvarSemValidar(obj);
    validar();
    dao.salvar(obj);
}
```

**Solução / prática segura**

```java
public void salvar() {
    validar();
    dao.salvar(obj);
}
// Histórico fica no Git, não comentado no código-fonte.
```

**Como revisar:** Remover código comentado, principalmente se envolver autenticação, autorização, SQL, debug, senhas ou endpoints antigos.

### CWE-1097 — Persistent Storable Data Element without Associated Comparison Control Element

**Aplicabilidade em Java:** Média  
**Problema:** Elemento persistente não possui forma consistente de comparação.  
**Risco:** Duplicidade, ordenação incorreta, inconsistência em coleções e cache.

**Exemplo vulnerável**

```java
public class PeriodoAquisitivo {
    private LocalDate inicio;
    private LocalDate fim;
    // Sem equals/hashCode/compareTo; duplicados passam despercebidos.
}
```

**Solução / prática segura**

```java
public class PeriodoAquisitivo implements Comparable<PeriodoAquisitivo> {
    private LocalDate inicio;
    private LocalDate fim;

    @Override
    public int compareTo(PeriodoAquisitivo outro) {
        return Comparator.comparing(PeriodoAquisitivo::getInicio)
            .thenComparing(PeriodoAquisitivo::getFim)
            .compare(this, outro);
    }
}
```

**Como revisar:** Entidades de valor persistidas devem ter comparação por chave natural ou regra de negócio documentada.

### CWE-1099 — Inconsistent Naming Conventions for Identifiers

**Aplicabilidade em Java:** Alta  
**Problema:** Identificadores usam nomes inconsistentes.  
**Risco:** Confusão entre `idUsuario`, `codFuncionario`, `login`, `rg`, `cpf`, `codArquivo` pode gerar bugs de autorização e consulta.

**Exemplo vulnerável**

```java
Long id = Long.valueOf(request.getParameter("codFuncionario"));
arquivoService.baixar(id); // id de funcionário usado como se fosse id de arquivo.
```

**Solução / prática segura**

```java
Long codFuncionario = Long.valueOf(request.getParameter("codFuncionario"));
Funcionario funcionario = funcionarioService.buscar(codFuncionario);
Long codArquivo = funcionario.getCodArquivoFicha();
arquivoService.baixar(codArquivo, usuarioAtual(request));
```

**Como revisar:** Nomes devem carregar semântica: `codFuncionario`, `codArquivo`, `idDeposito`, `anoProcedimento`, `numProcedimento`.

### CWE-1106 — Insufficient Use of Symbolic Constants

**Aplicabilidade em Java:** Alta  
**Problema:** Valores mágicos são usados diretamente no código.  
**Risco:** Erros de interpretação e regras divergentes entre telas, serviços e DAOs.

**Exemplo vulnerável**

```java
if (tipoProcesso == 5 || tipoProcesso == 10) {
    exigirEndereco = true;
}
```

**Solução / prática segura**

```java
if (TipoProcesso.TESTEMUNHA.equals(tipoProcesso)
        || TipoProcesso.COMPROMISSADO.equals(tipoProcesso)) {
    exigirEndereco = true;
}
```

**Como revisar:** Substituir números mágicos por enum, constantes de domínio ou tabela de domínio com nomes claros.

### CWE-1107 — Insufficient Isolation of Symbolic Constant Definitions

**Aplicabilidade em Java:** Alta  
**Problema:** Constantes de domínio ficam espalhadas por JSP, Action, DAO, SQL e JavaScript.  
**Risco:** Uma regra é alterada em um ponto e esquecida em outro.

**Exemplo vulnerável**

```java
// JSP
if (codTipo == 10) { ... }
// Action
if (form.getCodTipo() == 10) { ... }
// SQL
where cod_tipo = 10
```

**Solução / prática segura**

```java
public enum TipoEnvolvido {
    TESTEMUNHA(5), COMPROMISSADO(10);

    private final int codigo;
    TipoEnvolvido(int codigo) { this.codigo = codigo; }
    public int getCodigo() { return codigo; }
}
```

**Como revisar:** Isolar constantes em enum/domínio e exportar para frontend de forma controlada quando necessário.

### CWE-1108 — Excessive Reliance on Global Variables

**Aplicabilidade em Java:** Alta  
**Problema:** O sistema usa estado global mutável em excesso.  
**Risco:** Vazamento entre usuários, condição de corrida e comportamento imprevisível em app server.

**Exemplo vulnerável**

```java
public class ContextoGlobal {
    public static Usuario usuarioAtual;
    public static Connection connection;
}
```

**Solução / prática segura**

```java
public Usuario usuarioAtual(HttpServletRequest request) {
    return (Usuario) request.getSession().getAttribute("usuario");
}

// Dependências compartilhadas devem ser thread-safe ou gerenciadas pelo container.
```

**Como revisar:** Evitar `static` mutável para usuário, conexão, request, transação, token, configuração dinâmica e cache sem controle.

### CWE-1109 — Use of Same Variable for Multiple Purposes

**Aplicabilidade em Java:** Alta  
**Problema:** A mesma variável representa coisas diferentes ao longo do método.  
**Risco:** Facilita erro de autorização, consulta e auditoria.

**Exemplo vulnerável**

```java
Long id = Long.valueOf(request.getParameter("id"));
Usuario usuario = usuarioDao.buscar(id);
id = Long.valueOf(request.getParameter("idArquivo"));
arquivoService.baixar(id, usuario);
```

**Solução / prática segura**

```java
Long idUsuario = Long.valueOf(request.getParameter("idUsuario"));
Usuario usuario = usuarioDao.buscar(idUsuario);

Long idArquivo = Long.valueOf(request.getParameter("idArquivo"));
arquivoService.baixar(idArquivo, usuario);
```

**Como revisar:** Nomear variáveis por domínio e manter escopo curto.

### CWE-1113 — Inappropriate Comment Style

**Aplicabilidade em Java:** Média  
**Problema:** Comentários têm estilo inadequado, poluem ou confundem o código.  
**Risco:** Revisores ignoram comentários importantes ou deixam passar exceções de segurança.

**Exemplo vulnerável**

```java
// gambiarra temporária, não mexer
// TODO: liberar admin se der problema
if (falhaIntegracao) return true;
```

**Solução / prática segura**

```java
// Quando a integração de autorização estiver indisponível, negar por segurança.
if (falhaIntegracao) {
    auditoria.registrarErroAutorizacao(usuario, acao);
    return false;
}
```

**Como revisar:** Comentários devem explicar decisão relevante, limitação, risco ou referência de requisito, não esconder gambiarra.

### CWE-1114 — Inappropriate Whitespace Style

**Aplicabilidade em Java:** Média  
**Problema:** Formatação ruim torna o código difícil de revisar.  
**Risco:** Condições de segurança podem ser lidas incorretamente.

**Exemplo vulnerável**

```java
if(usuario!=null&&usuario.isAtivo()||debug)
permitir=true;
```

**Solução / prática segura**

```java
boolean usuarioValido = usuario != null && usuario.isAtivo();
if (usuarioValido && !debugHabilitadoEmProducao()) {
    permitir = true;
}
```

**Como revisar:** Aplicar formatter padrão, Checkstyle/Spotless e revisão de expressões booleanas complexas.

### CWE-1115 — Source Code Element without Standard Prologue

**Aplicabilidade em Java:** Média  
**Problema:** Arquivos ou elementos importantes não trazem prólogo/cabeçalho padrão quando exigido pelo projeto.  
**Risco:** Dificulta rastrear responsabilidade, licença, requisito, módulo e histórico de segurança.

**Exemplo vulnerável**

```java
public class IntegracaoPixService {
    // Sem identificação do módulo, contrato, requisito, dono ou observação de segurança.
}
```

**Solução / prática segura**

```java
/**
 * Serviço de integração PIX judicial.
 * Requisito: Mantis 015xxxx.
 * Segurança: não registrar payload com dados sensíveis; validar assinatura da resposta.
 */
public class IntegracaoPixService {
}
```

**Como revisar:** Use prólogo apenas quando agrega rastreabilidade real; evite cabeçalhos automáticos inúteis.

### CWE-1116 — Inaccurate Source Code Comments

**Aplicabilidade em Java:** Alta  
**Problema:** Comentário não corresponde ao comportamento real do código.  
**Risco:** Revisor acredita que existe validação/autorização que o código não executa.

**Exemplo vulnerável**

```java
// Valida se o usuário pode baixar o arquivo.
public void baixar(Long idArquivo) {
    arquivoDao.buscar(idArquivo); // não valida autorização
}
```

**Solução / prática segura**

```java
// Valida autorização por arquivo antes do download.
public void baixar(Long idArquivo, Usuario usuario) {
    authorizationGuard.exigirAcessoArquivo(usuario, idArquivo);
    arquivoDao.buscar(idArquivo);
}
```

**Como revisar:** Quando o comentário diz “valida”, “garante”, “somente”, “seguro”, “criptografado”, conferir se o código realmente faz isso.

### CWE-1117 — Callable with Insufficient Behavioral Summary

**Aplicabilidade em Java:** Alta  
**Problema:** Método público não informa contrato, pré-condições, efeitos colaterais ou exceções relevantes.  
**Risco:** Chamadores usam a função de forma insegura.

**Exemplo vulnerável**

```java
public Arquivo baixar(Long id) {
    return dao.buscarArquivo(id);
}
```

**Solução / prática segura**

```java
/**
 * Baixa arquivo privado após validar se o usuário possui acesso ao recurso.
 * @throws AcessoNegadoException quando o usuário não possui permissão.
 */
public Arquivo baixar(Long idArquivo, Usuario usuario) {
    authorizationGuard.exigirAcessoArquivo(usuario, idArquivo);
    return dao.buscarArquivo(idArquivo);
}
```

**Como revisar:** Métodos públicos de Service/Facade devem deixar claro se autenticam, autorizam, auditam, transacionam e validam entrada.

### CWE-1126 — Declaration of Variable with Unnecessarily Wide Scope

**Aplicabilidade em Java:** Alta  
**Problema:** Variável é declarada em escopo mais amplo do que o necessário.  
**Risco:** Valor antigo pode ser reutilizado por engano, especialmente em métodos longos.

**Exemplo vulnerável**

```java
String motivoNegacao = null;

if (!usuario.isAtivo()) {
    motivoNegacao = "Usuário inativo";
}
// Muitas linhas depois...
auditoria.registrar(motivoNegacao);
```

**Solução / prática segura**

```java
if (!usuario.isAtivo()) {
    String motivoNegacao = "Usuário inativo";
    auditoria.registrar(motivoNegacao);
    throw new AcessoNegadoException(motivoNegacao);
}
```

**Como revisar:** Escopo curto reduz bugs em Actions grandes, métodos de relatório e integrações.

### CWE-1127 — Compilation with Insufficient Warnings or Errors

**Aplicabilidade em Java:** Alta  
**Problema:** Build compila com poucos avisos ou ignora alertas relevantes.  
**Risco:** Problemas de null, depreciação, unchecked cast e APIs inseguras seguem para produção.

**Exemplo vulnerável**

```xml
<compilerArgument>-nowarn</compilerArgument>
```

**Solução / prática segura**

```xml
<compilerArgs>
  <arg>-Xlint:all</arg>
  <arg>-Werror</arg>
</compilerArgs>

<!-- Ajustar gradualmente em legado se -Werror for inviável inicialmente. -->
```

**Como revisar:** Habilitar warnings, Sonar/SAST, Dependency Check e tratar supressões como exceção documentada.

## 7. Arquitetura, recursos e performance

### CWE-605 — Multiple Binds to the Same Port

**Aplicabilidade em Java:** Média  
**Problema:** Mais de um componente tenta escutar a mesma porta.  
**Risco:** Falhas de inicialização, indisponibilidade, comportamento diferente entre ambientes e competição por recurso.

**Exemplo vulnerável**

```java
public void iniciarServicos() throws IOException {
    new ServerSocket(8080); // serviço A
    new ServerSocket(8080); // serviço B: falha ou conflito
}
```

**Solução / prática segura**

```java
public void iniciarServicos(Config config) {
    // Em app server, evitar abrir portas manualmente.
    // Usar conector configurado no servidor, JNDI, filas ou endpoints gerenciados.
    endpointRegistry.publicar("/api/depositos", depositoResource);
}
```

**Como revisar:** Em WildFly/Tomcat/Spring Boot, portas devem ser configuradas uma vez por ambiente e não espalhadas em código.

### CWE-694 — Use of Multiple Resources with Duplicate Identifier

**Aplicabilidade em Java:** Média  
**Problema:** Dois recursos diferentes usam o mesmo identificador ou o sistema não garante unicidade.  
**Risco:** Pode haver acesso ao recurso errado, sobrescrita, confusão de auditoria ou autorização inconsistente.

**Exemplo vulnerável**

```java
// Falha: usa nome de arquivo informado pelo usuário como identificador único.
Path destino = uploads.resolve(request.getParameter("nomeArquivo"));
Files.copy(arquivoUpload, destino, StandardCopyOption.REPLACE_EXISTING);
```

**Solução / prática segura**

```java
String idSeguro = UUID.randomUUID().toString();
String nomeOriginal = sanitizarNomeArquivo(request.getParameter("nomeArquivo"));
Path destino = repositorioPrivado.resolve(idSeguro + ".bin");
Files.copy(arquivoUpload, destino);
arquivoDao.registrar(idSeguro, nomeOriginal, usuario.getId());
```

**Como revisar:** Identificadores de arquivo, usuário, sessão, documento, unidade e integração devem ter unicidade validada no banco ou repositório.

### CWE-1043 — Data Element Aggregating an Excessively Large Number of Non-Primitive Elements

**Aplicabilidade em Java:** Média  
**Problema:** Um objeto agrega quantidade excessiva de objetos complexos.  
**Risco:** Pode causar consumo de memória, sessão pesada, serialização lenta e indisponibilidade.

**Exemplo vulnerável**

```java
public class RelatorioSessao implements Serializable {
    private List<DepositoDTO> todosDepositos; // centenas de milhares na sessão
    private List<ArquivoDTO> arquivos;
    private Map<Long, List<EventoDTO>> eventosPorDeposito;
}
```

**Solução / prática segura**

```java
public class RelatorioSessao implements Serializable {
    private String idConsulta;
    private FiltroRelatorio filtro;
    private int paginaAtual;
    // Dados grandes são buscados por página no serviço/DAO.
}
```

**Como revisar:** Não guardar listas grandes, entidades Hibernate, arquivos ou grafos complexos em sessão HTTP.

### CWE-1044 — Architecture with Number of Horizontal Layers Outside of Expected Range

**Aplicabilidade em Java:** Alta  
**Problema:** A arquitetura tem camadas de menos ou de mais para a complexidade do sistema.  
**Risco:** Com poucas camadas, UI acessa banco direto; com camadas demais, regras ficam duplicadas e difíceis de auditar.

**Exemplo vulnerável**

```java
// JSP/Action montando SQL diretamente.
String sql = "delete from deposito where id=" + request.getParameter("id");
connection.createStatement().execute(sql);
```

**Solução / prática segura**

```java
// Fluxo esperado em aplicação corporativa.
Action -> Form/DTO -> Service/Facade -> DAO/Repository -> Banco

// A Action coordena request/response; o Service valida regra/autorização; o DAO acessa dados.
```

**Como revisar:** Evitar JSP/Action com SQL, regra de negócio, chamada externa, autorização e formatação de PDF tudo no mesmo método.

### CWE-1046 — Creation of Immutable Text Using String Concatenation

**Aplicabilidade em Java:** Alta  
**Problema:** Criação repetida de `String` imutável por concatenação, especialmente em loop.  
**Risco:** Consumo excessivo de CPU/memória e indisponibilidade em cargas altas.

**Exemplo vulnerável**

```java
String html = "";
for (Deposito d : depositos) {
    html += "<tr><td>" + escape(d.getNome()) + "</td></tr>";
}
```

**Solução / prática segura**

```java
StringBuilder html = new StringBuilder();
for (Deposito d : depositos) {
    html.append("<tr><td>")
        .append(escape(d.getNome()))
        .append("</td></tr>");
}
```

**Como revisar:** Para SQL, não usar concatenação: preferir `PreparedStatement`. Para texto grande, usar `StringBuilder`, template ou streaming.

### CWE-1048 — Invokable Control Element with Large Number of Outward Calls

**Aplicabilidade em Java:** Alta  
**Problema:** Um método chama muitos serviços, DAOs ou integrações externas.  
**Risco:** Fica difícil controlar transação, erro, timeout, autorização e auditoria.

**Exemplo vulnerável**

```java
public void finalizarCompra(Long id) {
    clienteDao.buscar(id);
    estoqueService.reservar(id);
    pagamentoGateway.cobrar(id);
    notaFiscalService.emitir(id);
    emailService.enviar(id);
    auditoriaService.registrar(id);
    crmService.atualizar(id);
}
```

**Solução / prática segura**

```java
public void finalizarCompra(Long id, Usuario usuario) {
    authorizationGuard.exigirPermissao(usuario, "COMPRA_FINALIZAR");
    FinalizacaoCompraContext ctx = compraFinalizacaoService.preparar(id);
    orquestradorFinalizacao.executar(ctx);
}
```

**Como revisar:** Dividir método orquestrador, aplicar transações claras, timeouts e tratamento por integração.

### CWE-1049 — Excessive Data Query Operations in a Large Data Table

**Aplicabilidade em Java:** Alta  
**Problema:** O código executa consultas excessivas sobre tabela grande.  
**Risco:** Lentidão, lock, timeout e DoS por carga legítima ou maliciosa.

**Exemplo vulnerável**

```java
for (Long id : idsDepositos) {
    Deposito d = depositoDao.buscarPorId(id); // N consultas
    processar(d);
}
```

**Solução / prática segura**

```java
List<Deposito> depositos = depositoDao.buscarPorIds(idsDepositos); // uma consulta com IN/batch
for (Deposito d : depositos) {
    processar(d);
}
```

**Como revisar:** Procurar N+1 queries, loops com DAO, relatórios sem paginação e filtros pouco seletivos.

### CWE-1050 — Excessive Platform Resource Consumption within a Loop

**Aplicabilidade em Java:** Alta  
**Problema:** O loop cria ou consome recursos caros repetidamente.  
**Risco:** Exaustão de CPU, memória, threads, conexões, descritores de arquivo ou chamadas externas.

**Exemplo vulnerável**

```java
for (String json : entradas) {
    ObjectMapper mapper = new ObjectMapper(); // criado a cada iteração
    Evento evento = mapper.readValue(json, Evento.class);
    service.processar(evento);
}
```

**Solução / prática segura**

```java
private static final ObjectMapper MAPPER = new ObjectMapper();

for (String json : entradas) {
    Evento evento = MAPPER.readValue(json, Evento.class);
    service.processar(evento);
}
```

**Como revisar:** Evitar criar `ObjectMapper`, `Pattern`, conexões, clientes HTTP, threads, arquivos e criptografia em loop sem necessidade.

### CWE-1063 — Creation of Class Instance within a Static Code Block

**Aplicabilidade em Java:** Média  
**Problema:** Um bloco estático cria instância com dependência externa ou recurso pesado.  
**Risco:** Falha de inicialização derruba a classe/aplicação; difícil configurar e testar.

**Exemplo vulnerável**

```java
public class ProjudiClientHolder {
    static final ProjudiClient CLIENT;

    static {
        CLIENT = new ProjudiClient(System.getenv("PROJUDI_URL"));
        CLIENT.autenticar();
    }
}
```

**Solução / prática segura**

```java
public class ProjudiClientFactory {
    public ProjudiClient criar() {
        ProjudiClient client = new ProjudiClient(config.getProjudiUrl());
        client.configurarTimeout(config.getTimeout());
        return client;
    }
}
```

**Como revisar:** Evitar conexão, autenticação, leitura de arquivo e chamada remota em inicializador estático.

### CWE-1065 — Runtime Resource Management Control Element in a Component Built to Run on Application Servers

**Aplicabilidade em Java:** Alta  
**Problema:** Componente de app server gerencia manualmente recursos que deveriam ser gerenciados pelo container.  
**Risco:** Conflito com pool, transação, lifecycle, segurança e escalabilidade do servidor.

**Exemplo vulnerável**

```java
public void iniciarJob() {
    new Thread(() -> processarComprovantes()).start();
    Connection conn = DriverManager.getConnection(url, user, pass);
}
```

**Solução / prática segura**

```java
@Resource
private ManagedExecutorService executor;

@Resource(lookup = "java:/jdbc/AppDS")
private DataSource dataSource;

public void iniciarJob() {
    executor.submit(this::processarComprovantes);
}
```

**Como revisar:** Em WildFly/Jakarta EE, preferir `DataSource`, executor gerenciado, EJB timer, JMS e recursos JNDI.

### CWE-1066 — Missing Serialization Control Element

**Aplicabilidade em Java:** Alta  
**Problema:** Classe serializável não controla versão, campos sensíveis ou validação ao desserializar.  
**Risco:** Falha de compatibilidade, exposição de dado sensível ou estado inválido após desserialização.

**Exemplo vulnerável**

```java
public class UsuarioSessao implements Serializable {
    private String login;
    private String tokenAcesso;
    private List<String> permissoes;
}
```

**Solução / prática segura**

```java
public class UsuarioSessao implements Serializable {
    private static final long serialVersionUID = 1L;

    private String login;
    private transient String tokenAcesso;
    private List<String> permissoes;

    private void readObject(ObjectInputStream in) throws IOException, ClassNotFoundException {
        in.defaultReadObject();
        if (login == null || permissoes == null) {
            throw new InvalidObjectException("Sessão inválida");
        }
    }
}
```

**Como revisar:** Revisar `Serializable` em sessão HTTP, cache, fila, RMI e DTOs persistidos.

### CWE-1067 — Excessive Execution of Sequential Searches of Data Resource

**Aplicabilidade em Java:** Alta  
**Problema:** O código faz buscas sequenciais repetidas em listas ou recursos de dados.  
**Risco:** Complexidade O(n²), lentidão e indisponibilidade com volume alto.

**Exemplo vulnerável**

```java
for (Deposito d : depositos) {
    Unidade unidade = unidades.stream()
        .filter(u -> u.getId().equals(d.getCodUnidade()))
        .findFirst()
        .orElse(null);
    d.setUnidade(unidade);
}
```

**Solução / prática segura**

```java
Map<Long, Unidade> unidadesPorId = unidades.stream()
    .collect(Collectors.toMap(Unidade::getId, Function.identity()));

for (Deposito d : depositos) {
    d.setUnidade(unidadesPorId.get(d.getCodUnidade()));
}
```

**Como revisar:** Trocar buscas repetidas por `Map`, join no banco, cache controlado ou índices adequados.

### CWE-1070 — Serializable Data Element Containing non-Serializable Item Elements

**Aplicabilidade em Java:** Alta  
**Problema:** Classe serializável contém campos que não são serializáveis.  
**Risco:** Erro em replicação de sessão, cluster, cache, fila ou passivação de container.

**Exemplo vulnerável**

```java
public class RelatorioSessao implements Serializable {
    private Connection connection;     // não serializável
    private InputStream arquivoAberto; // não serializável
}
```

**Solução / prática segura**

```java
public class RelatorioSessao implements Serializable {
    private static final long serialVersionUID = 1L;
    private String idRelatorio;
    private transient InputStream arquivoAberto;

    public InputStream abrirArquivo(Repositorio repositorio) {
        return repositorio.abrir(idRelatorio);
    }
}
```

**Como revisar:** Não guardar conexão, stream, entity manager, request, response, logger ou service dentro de objeto serializável.

### CWE-1072 — Data Resource Access without Use of Connection Pooling

**Aplicabilidade em Java:** Alta  
**Problema:** Acesso ao banco sem pool de conexões.  
**Risco:** Exaustão de conexões, lentidão, falhas sob carga e credenciais espalhadas.

**Exemplo vulnerável**

```java
public Connection abrirConexao() throws SQLException {
    return DriverManager.getConnection(url, usuario, senha);
}
```

**Solução / prática segura**

```java
@Resource(lookup = "java:/jdbc/AppDS")
private DataSource dataSource;

public Connection abrirConexao() throws SQLException {
    return dataSource.getConnection();
}
```

**Como revisar:** Em Java web corporativo, banco deve ser acessado por `DataSource`/pool configurado no servidor ou framework.

### CWE-1073 — Non-SQL Invokable Control Element with Excessive Number of Data Resource Accesses

**Aplicabilidade em Java:** Alta  
**Problema:** Um método que não é DAO executa muitos acessos a dados.  
**Risco:** Action/Controller vira ponto de acoplamento, difícil de transacionar, testar e proteger.

**Exemplo vulnerável**

```java
public ActionForward gerarRelatorio(...) {
    unidadeDao.buscar(...);
    depositoDao.listar(...);
    arquivoDao.listar(...);
    usuarioDao.buscar(...);
    auditoriaDao.salvar(...);
    // Action concentrando acessos a dados.
}
```

**Solução / prática segura**

```java
public ActionForward gerarRelatorio(...) {
    RelatorioDTO relatorio = relatorioDepositoService.gerar(filtro, usuarioAtual(request));
    request.setAttribute("relatorio", relatorio);
    return mapping.findForward("relatorio");
}
```

**Como revisar:** Controllers/Actions devem delegar a Service/Facade. DAO deve ser chamado em camada própria.

### CWE-1084 — Invokable Control Element with Excessive File or Data Access Operations

**Aplicabilidade em Java:** Alta  
**Problema:** Um método executa operações excessivas de arquivo ou dados.  
**Risco:** Causa lentidão, lock, exaustão de IO e dificulta auditoria/rollback.

**Exemplo vulnerável**

```java
public void anexarComprovantes(List<Long> ids) {
    for (Long id : ids) {
        Deposito d = depositoDao.buscar(id);
        byte[] pdf = Files.readAllBytes(Paths.get(d.getCaminhoPdf()));
        arquivoDao.salvar(id, pdf);
    }
}
```

**Solução / prática segura**

```java
public void anexarComprovantes(List<Long> ids) {
    List<Deposito> depositos = depositoDao.buscarPendentesPorIds(ids);
    for (Deposito d : depositos) {
        try (InputStream in = repositorioArquivos.abrir(d.getCaminhoPdf())) {
            arquivoService.anexarStream(d.getId(), in);
        }
    }
}
```

**Como revisar:** Usar paginação, streaming, batch, limite de tamanho e transação clara para operações de arquivo/dados.

### CWE-1089 — Large Data Table with Excessive Number of Indices

**Aplicabilidade em Java:** Média  
**Problema:** Tabela grande tem índices em excesso.  
**Risco:** INSERT/UPDATE/DELETE ficam lentos, geram lock e prejudicam disponibilidade.

**Exemplo vulnerável**

```sql
-- Exemplo ruim: índices criados para qualquer filtro ocasional.
CREATE INDEX idx_dep_nome ON depositojudicial(nome);
CREATE INDEX idx_dep_status ON depositojudicial(status);
CREATE INDEX idx_dep_data ON depositojudicial(data_geracao);
CREATE INDEX idx_dep_valor ON depositojudicial(valor);
CREATE INDEX idx_dep_obs ON depositojudicial(observacao);
```

**Solução / prática segura**

```sql
-- Exemplo melhor: índices baseados em consultas reais e seletivas.
CREATE INDEX idx_dep_unidade_status_data
ON depositojudicial(cod_unidade, status, data_geracao);

-- Remover índices não usados após análise de plano e estatísticas.
```

**Como revisar:** Usar `EXPLAIN`, estatísticas de uso e revisão de consultas reais antes de adicionar índices.

### CWE-1092 — Use of Same Invokable Control Element in Multiple Architectural Layers

**Aplicabilidade em Java:** Alta  
**Problema:** O mesmo método/função é usado em camadas diferentes com responsabilidades diferentes.  
**Risco:** Um utilitário pensado para UI passa a ser usado como regra de negócio, ou vice-versa, causando bypass.

**Exemplo vulnerável**

```java
// Usado na JSP para formatar e também no Service para validar regra.
public static boolean campoObrigatorio(String valor) {
    return valor != null && !valor.trim().isEmpty();
}
```

**Solução / prática segura**

```java
// Camada de domínio
validadorDeposito.validarObrigatorios(dto);

// Camada de apresentação
formatadorTela.marcarCampoObrigatorio("valor");
```

**Como revisar:** Separar validação de UI, validação de domínio, autorização, persistência e formatação.

### CWE-1094 — Excessive Index Range Scan for a Data Resource

**Aplicabilidade em Java:** Alta  
**Problema:** Consulta força varredura ampla de índice ou tabela.  
**Risco:** Relatórios e buscas podem degradar banco e causar indisponibilidade.

**Exemplo vulnerável**

```sql
SELECT *
FROM depositojudicial
WHERE nome_envolvido LIKE '%silva%'
ORDER BY data_geracao DESC;
```

**Solução / prática segura**

```sql
SELECT id, nome_envolvido, data_geracao, status
FROM depositojudicial
WHERE data_geracao >= ?
  AND data_geracao < ?
  AND nome_envolvido_normalizado LIKE ?
ORDER BY data_geracao DESC
LIMIT 100;
```

**Como revisar:** Evitar `%termo%` sem mecanismo adequado, filtros sem período, `SELECT *` e relatórios sem paginação.

### CWE-1101 — Reliance on Runtime Component in Generated Code

**Aplicabilidade em Java:** Média  
**Problema:** Código gerado depende de runtime específico não controlado ou pouco documentado.  
**Risco:** Falha em ambiente diferente, runtime desatualizado ou incompatibilidade de segurança.

**Exemplo vulnerável**

```java
// Código gerado por ferramenta antiga exige runtime específico no classpath.
GeradoProtocoloClient client = new GeradoProtocoloClient(); // depende de lib não versionada no servidor
```

**Solução / prática segura**

```java
// Dependência versionada e controlada no build.
<dependency>
  <groupId>br.gov.exemplo</groupId>
  <artifactId>protocolo-client-runtime</artifactId>
  <version>${protocolo.runtime.version}</version>
</dependency>
```

**Como revisar:** Código gerado deve ter runtime versionado, testado, atualizado e documentado no build.

### CWE-1235 — Incorrect Use of Autoboxing and Unboxing for Performance Critical Operations

**Aplicabilidade em Java:** Alta  
**Problema:** Uso de wrappers (`Long`, `Integer`, `Boolean`) onde primitivos seriam mais adequados em caminho crítico.  
**Risco:** Sob grande volume, autoboxing/unboxing aumenta CPU/memória e pode afetar disponibilidade.

**Exemplo vulnerável**

```java
Long total = 0L;
for (long i = 0; i < quantidade; i++) {
    total += i; // autoboxing/unboxing repetido
}
```

**Solução / prática segura**

```java
long total = 0L;
for (long i = 0; i < quantidade; i++) {
    total += i;
}
```

**Como revisar:** Em loops grandes, contadores, somatórios e processamento de relatórios, preferir primitivos; wrappers são úteis para nulidade/coleções.

## 8. Itens C/C++ e analogias Java

### CWE-562 — Return of Stack Variable Address

**Aplicabilidade em Java:** Baixa em Java  
**Problema:** Em C/C++, retorna-se endereço de variável local. Em Java isso não ocorre da mesma forma, mas há analogia com retorno de referência mutável interna.  
**Risco:** O chamador consegue alterar estado interno que deveria ser protegido.

**Exemplo vulnerável**

```java
public class PerfilUsuario {
    private final List<String> permissoes = new ArrayList<>();

    public List<String> getPermissoes() {
        return permissoes; // Falha: expõe referência interna mutável.
    }
}
```

**Solução / prática segura**

```java
public class PerfilUsuario {
    private final List<String> permissoes = new ArrayList<>();

    public List<String> getPermissoes() {
        return Collections.unmodifiableList(new ArrayList<>(permissoes));
    }
}
```

**Como revisar:** Para Java, revisar getters que expõem `List`, `Map`, arrays, `Date`, DTOs internos e objetos mutáveis de segurança.

### CWE-1045 — Parent Class with a Virtual Destructor and a Child Class without a Virtual Destructor

**Aplicabilidade em Java:** Baixa em Java  
**Problema:** Fraqueza típica de C++. Em Java, a analogia prática é uma hierarquia sem contrato claro de encerramento de recursos.  
**Risco:** Subclasses podem abrir recursos e não liberá-los corretamente.

**Exemplo vulnerável**

```java
abstract class Exportador {
    public void exportar() { /* ... */ }
}

class ExportadorArquivo extends Exportador {
    private FileOutputStream out; // sem contrato de fechamento
}
```

**Solução / prática segura**

```java
abstract class Exportador implements AutoCloseable {
    public abstract void exportar() throws IOException;
}

class ExportadorArquivo extends Exportador {
    private final FileOutputStream out;

    @Override
    public void close() throws IOException {
        out.close();
    }
}
```

**Como revisar:** Em Java, prefira `AutoCloseable`, composição e injeção de dependências gerenciadas pelo container.

### CWE-1079 — Parent Class without Virtual Destructor Method

**Aplicabilidade em Java:** Baixa em Java  
**Problema:** Fraqueza típica de C++. Em Java, a analogia é uma classe base que não define contrato de liberação/fechamento para subclasses com recursos.  
**Risco:** Subclasses podem vazar recursos sem que o chamador saiba como encerrar corretamente.

**Exemplo vulnerável**

```java
abstract class LeitorArquivo {
    public abstract String lerLinha() throws IOException;
}

class LeitorArquivoLocal extends LeitorArquivo {
    private final BufferedReader reader; // sem close no contrato
}
```

**Solução / prática segura**

```java
abstract class LeitorArquivo implements AutoCloseable {
    public abstract String lerLinha() throws IOException;
}

try (LeitorArquivo leitor = leitorFactory.criar(path)) {
    leitor.lerLinha();
}
```

**Como revisar:** Em Java, recursos devem ter contrato explícito: `AutoCloseable`, `close`, lifecycle do container ou escopo gerenciado.

### CWE-1082 — Class Instance Self Destruction Control Element

**Aplicabilidade em Java:** Baixa/Média  
**Problema:** Objeto controla a própria destruição de forma inesperada. Em Java, aparece como objeto encerrando JVM, thread ou estado global.  
**Risco:** Um fluxo de negócio pode derrubar aplicação, encerrar job compartilhado ou invalidar recurso usado por outros.

**Exemplo vulnerável**

```java
public class ImportadorArquivo {
    public void processar() {
        if (erroCritico()) {
            System.exit(1); // Falha: objeto encerra a JVM/app server.
        }
    }
}
```

**Solução / prática segura**

```java
public class ImportadorArquivo {
    public ResultadoImportacao processar() {
        if (erroCritico()) {
            return ResultadoImportacao.falha("Erro crítico no arquivo");
        }
        return ResultadoImportacao.sucesso();
    }
}
```

**Como revisar:** Nunca usar `System.exit`, `Runtime.halt`, `Thread.stop` ou encerramento global dentro de componente de aplicação.

### CWE-1087 — Class with Virtual Method without a Virtual Destructor

**Aplicabilidade em Java:** Baixa em Java  
**Problema:** Fraqueza típica de C++. Em Java, a analogia é classe extensível com métodos sobrescrevíveis sem lifecycle seguro.  
**Risco:** Subclasses alteram comportamento de segurança sem contrato forte.

**Exemplo vulnerável**

```java
public class ValidadorAcesso {
    public boolean validar(Usuario usuario) {
        return usuario != null;
    }
}

class ValidadorAcessoDev extends ValidadorAcesso {
    @Override public boolean validar(Usuario usuario) { return true; }
}
```

**Solução / prática segura**

```java
public final class ValidadorAcesso {
    public boolean validar(Usuario usuario, String permissao) {
        return usuario != null && usuario.possuiPermissao(permissao);
    }
}
```

**Como revisar:** Classes de segurança devem ser `final` quando possível, ou ter contratos claros e testes contra sobrescrita perigosa.

### CWE-1098 — Data Element containing Pointer Item without Proper Copy Control Element

**Aplicabilidade em Java:** Baixa em Java  
**Problema:** Fraqueza típica de C/C++. Em Java, a analogia é manter referências mutáveis sem cópia defensiva.  
**Risco:** Alteração externa muda estado interno após validação.

**Exemplo vulnerável**

```java
public class FiltroRelatorio {
    private Date dataInicio;

    public void setDataInicio(Date dataInicio) {
        this.dataInicio = dataInicio; // referência mutável externa
    }
}
```

**Solução / prática segura**

```java
public class FiltroRelatorio {
    private Date dataInicio;

    public void setDataInicio(Date dataInicio) {
        this.dataInicio = dataInicio == null ? null : new Date(dataInicio.getTime());
    }

    public Date getDataInicio() {
        return dataInicio == null ? null : new Date(dataInicio.getTime());
    }
}
```

**Como revisar:** Preferir `LocalDate`, objetos imutáveis e cópias defensivas em DTOs sensíveis.

### CWE-1102 — Reliance on Machine-Dependent Data Representation

**Aplicabilidade em Java:** Alta  
**Problema:** O código depende de representação da máquina/plataforma.  
**Risco:** Dados mudam entre Windows/Linux, encoding, locale, timezone ou ordem de bytes.

**Exemplo vulnerável**

```java
byte[] bytes = texto.getBytes(); // charset padrão da máquina
String data = new SimpleDateFormat("dd/MM/yyyy").format(new Date()); // timezone padrão
```

**Solução / prática segura**

```java
byte[] bytes = texto.getBytes(StandardCharsets.UTF_8);
String data = OffsetDateTime.now(ZoneOffset.UTC)
    .format(DateTimeFormatter.ISO_OFFSET_DATE_TIME);
```

**Como revisar:** Fixar charset, timezone, locale, separador, endianess e formato de data em integração.

### CWE-1103 — Use of Platform-Dependent Third Party Components

**Aplicabilidade em Java:** Alta  
**Problema:** Componente de terceiro depende de plataforma específica.  
**Risco:** Funciona em desenvolvimento, falha em produção ou exige configuração insegura.

**Exemplo vulnerável**

```java
Path ferramenta = Paths.get("C:\tools\assinador\assinador.exe");
new ProcessBuilder(ferramenta.toString(), arquivo).start();
```

**Solução / prática segura**

```java
Assinador assinador = assinadorFactory.criarImplementacaoPortavel();
assinador.assinar(arquivo, certificado);

// Quando dependência nativa for inevitável, validar SO, arquitetura, versão e fallback.
```

**Como revisar:** Evitar bibliotecas amarradas a Windows/Linux sem contrato explícito, testes e alternativa.

### CWE-1104 — Use of Unmaintained Third Party Components

**Aplicabilidade em Java:** Alta  
**Problema:** O sistema depende de componente sem manutenção.  
**Risco:** Falhas conhecidas não são corrigidas, atualização fica difícil e a segurança degrada.

**Exemplo vulnerável**

```xml
<dependency>
  <groupId>commons-fileupload</groupId>
  <artifactId>commons-fileupload</artifactId>
  <version>1.2.1</version>
</dependency>
```

**Solução / prática segura**

```xml
<dependency>
  <groupId>org.apache.commons</groupId>
  <artifactId>commons-fileupload2-jakarta-servlet6</artifactId>
  <version>${commons-fileupload.version}</version>
</dependency>

<!-- Manter inventário, CVE/SCA, política de atualização e testes de regressão. -->
```

**Como revisar:** Usar OWASP Dependency-Check, Snyk, Dependabot/Renovate, SBOM e política de atualização.

---
## 9. Comandos úteis de revisão

### 9.1 Procurar debug, bypass e permissões frágeis

```bash
grep -RInE "debug|bypass|mock|teste|liberarTudo|isAdmin|perfil=|request.getParameter\(.*perfil" src/
```

### 9.2 Procurar estado global e recursos manuais

```bash
grep -RInE "static .*Usuario|static .*Connection|DriverManager|getConnection|new Thread|System.exit|Runtime.getRuntime" src/
```

### 9.3 Procurar catch vazio, código morto e comentários suspeitos

```bash
grep -RInE "catch \(.*\) \{[[:space:]]*\}|TODO|FIXME|gambiarra|tempor[aá]rio|return;" src/
```

### 9.4 Procurar concatenação e loops com acesso a dados

```bash
grep -RInE "for \(.*:.*\)|while \(.*\)|\+=|createStatement|executeQuery|buscarPorId|listarPor" src/
```

### 9.5 Procurar serialização problemática

```bash
grep -RInE "implements Serializable|serialVersionUID|transient|readObject|writeObject" src/
```

---
## 10. Checklist prático

- [ ] A CWE-1006 foi tratada como categoria, não como vulnerabilidade final mapeável.
- [ ] Toda decisão de segurança tem default deny.
- [ ] Não há código de debug ativo em produção.
- [ ] Segredos, chaves e constantes sensíveis não estão hard-coded.
- [ ] Parâmetros de request, cookies, headers e hidden fields não decidem autorização.
- [ ] Actions/Controllers delegam regra de negócio para Service/Facade.
- [ ] DAOs não são chamados em loops sem batch, paginação ou cache adequado.
- [ ] Conexões de banco usam pool/DataSource, não DriverManager direto.
- [ ] Não há `catch` vazio em segurança, IO, transação ou integração.
- [ ] Classes Serializable possuem `serialVersionUID`, campos sensíveis `transient` e validação quando necessário.
- [ ] Não há estado global mutável para usuário, conexão, token, permissão ou request.
- [ ] Constantes de domínio estão centralizadas e nomeadas.
- [ ] Comentários importantes refletem o código real.
- [ ] Dependências de terceiro têm manutenção, versão controlada e análise de vulnerabilidade.
- [ ] Operações de texto, busca e cálculo em massa evitam concatenação, boxing e O(n²).

---
## 11. Testes sugeridos

### Testes unitários

- `switch`/enum com valor desconhecido deve negar acesso.
- validação de token/certificado deve rejeitar assinatura inválida, issuer inválido, audience inválida e token expirado.
- métodos com autorização devem lançar `AcessoNegadoException` quando o usuário não possuir permissão.
- classes `equals`/`hashCode` devem funcionar corretamente em `HashSet` e `HashMap`.
- objetos serializáveis devem rejeitar estado inválido no `readObject`, quando aplicável.
- getters de listas/mapas/datas internas não devem permitir alteração externa do estado.

### Testes de integração

- simular request com `perfil=ADMIN`, `debug=true` e headers falsificados; o servidor deve ignorar esses dados para autorização.
- executar consultas de relatório com volume alto e verificar paginação, tempo e plano de execução.
- validar que o sistema sobe sem criar conexões, clientes HTTP ou chamadas remotas em inicializadores estáticos.
- executar aplicação em ambiente Linux e Windows quando houver integração com arquivos, charset, paths e processos externos.

### Testes de build e qualidade

- habilitar warnings do compilador e revisar supressões.
- executar Sonar/SAST para dead code, unused assignment, catch vazio, complexidade e duplicação.
- executar análise SCA de dependências e gerar inventário/SBOM quando possível.

---
## 12. Resumo para prova

- **CWE-1006** é uma categoria de más práticas de codificação dentro da view **CWE-699 - Software Development**.
- A categoria sinaliza que o produto pode estar difícil de manter, revisar e proteger.
- Muitas CWEs desta categoria não são vulnerabilidades diretas, mas aumentam a chance de falhas exploráveis.
- Em Java, os riscos mais recorrentes são: debug ativo, segredo hard-coded, decisão de segurança com input não confiável, ausência de default deny, código morto, catch vazio, constantes mágicas, estado global, `DriverManager`, loops com DAO, serialização sem controle e dependências sem manutenção.
- Alguns itens são típicos de C/C++, como ponteiros e destrutores virtuais. Para Java, a revisão deve considerar analogias: referências mutáveis expostas, ausência de contrato de fechamento, uso de `System.exit`, lifecycle inadequado e falta de cópia defensiva.
- O objetivo prático é melhorar legibilidade, isolamento, manutenção, performance e previsibilidade — todos com impacto direto na segurança.

---
## 13. Referências oficiais

- CWE-1006 — Bad Coding Practices: https://cwe.mitre.org/data/definitions/1006.html
- CWE-358 — Improperly Implemented Security Check for Standard: https://cwe.mitre.org/data/definitions/358.html
- CWE-360 — Trust of System Event Data: https://cwe.mitre.org/data/definitions/360.html
- CWE-478 — Missing Default Case in Multiple Condition Expression: https://cwe.mitre.org/data/definitions/478.html
- CWE-487 — Reliance on Package-level Scope: https://cwe.mitre.org/data/definitions/487.html
- CWE-489 — Active Debug Code: https://cwe.mitre.org/data/definitions/489.html
- CWE-547 — Use of Hard-coded, Security-relevant Constants: https://cwe.mitre.org/data/definitions/547.html
- CWE-561 — Dead Code: https://cwe.mitre.org/data/definitions/561.html
- CWE-562 — Return of Stack Variable Address: https://cwe.mitre.org/data/definitions/562.html
- CWE-563 — Assignment to Variable without Use: https://cwe.mitre.org/data/definitions/563.html
- CWE-581 — Object Model Violation: Just One of Equals and Hashcode Defined: https://cwe.mitre.org/data/definitions/581.html
- CWE-586 — Explicit Call to Finalize(): https://cwe.mitre.org/data/definitions/586.html
- CWE-605 — Multiple Binds to the Same Port: https://cwe.mitre.org/data/definitions/605.html
- CWE-628 — Function Call with Incorrectly Specified Arguments: https://cwe.mitre.org/data/definitions/628.html
- CWE-654 — Reliance on a Single Factor in a Security Decision: https://cwe.mitre.org/data/definitions/654.html
- CWE-656 — Reliance on Security Through Obscurity: https://cwe.mitre.org/data/definitions/656.html
- CWE-694 — Use of Multiple Resources with Duplicate Identifier: https://cwe.mitre.org/data/definitions/694.html
- CWE-807 — Reliance on Untrusted Inputs in a Security Decision: https://cwe.mitre.org/data/definitions/807.html
- CWE-1041 — Use of Redundant Code: https://cwe.mitre.org/data/definitions/1041.html
- CWE-1043 — Data Element Aggregating an Excessively Large Number of Non-Primitive Elements: https://cwe.mitre.org/data/definitions/1043.html
- CWE-1044 — Architecture with Number of Horizontal Layers Outside of Expected Range: https://cwe.mitre.org/data/definitions/1044.html
- CWE-1045 — Parent Class with a Virtual Destructor and a Child Class without a Virtual Destructor: https://cwe.mitre.org/data/definitions/1045.html
- CWE-1046 — Creation of Immutable Text Using String Concatenation: https://cwe.mitre.org/data/definitions/1046.html
- CWE-1048 — Invokable Control Element with Large Number of Outward Calls: https://cwe.mitre.org/data/definitions/1048.html
- CWE-1049 — Excessive Data Query Operations in a Large Data Table: https://cwe.mitre.org/data/definitions/1049.html
- CWE-1050 — Excessive Platform Resource Consumption within a Loop: https://cwe.mitre.org/data/definitions/1050.html
- CWE-1063 — Creation of Class Instance within a Static Code Block: https://cwe.mitre.org/data/definitions/1063.html
- CWE-1065 — Runtime Resource Management Control Element in a Component Built to Run on Application Servers: https://cwe.mitre.org/data/definitions/1065.html
- CWE-1066 — Missing Serialization Control Element: https://cwe.mitre.org/data/definitions/1066.html
- CWE-1067 — Excessive Execution of Sequential Searches of Data Resource: https://cwe.mitre.org/data/definitions/1067.html
- CWE-1070 — Serializable Data Element Containing non-Serializable Item Elements: https://cwe.mitre.org/data/definitions/1070.html
- CWE-1071 — Empty Code Block: https://cwe.mitre.org/data/definitions/1071.html
- CWE-1072 — Data Resource Access without Use of Connection Pooling: https://cwe.mitre.org/data/definitions/1072.html
- CWE-1073 — Non-SQL Invokable Control Element with Excessive Number of Data Resource Accesses: https://cwe.mitre.org/data/definitions/1073.html
- CWE-1079 — Parent Class without Virtual Destructor Method: https://cwe.mitre.org/data/definitions/1079.html
- CWE-1082 — Class Instance Self Destruction Control Element: https://cwe.mitre.org/data/definitions/1082.html
- CWE-1084 — Invokable Control Element with Excessive File or Data Access Operations: https://cwe.mitre.org/data/definitions/1084.html
- CWE-1085 — Invokable Control Element with Excessive Volume of Commented-out Code: https://cwe.mitre.org/data/definitions/1085.html
- CWE-1087 — Class with Virtual Method without a Virtual Destructor: https://cwe.mitre.org/data/definitions/1087.html
- CWE-1089 — Large Data Table with Excessive Number of Indices: https://cwe.mitre.org/data/definitions/1089.html
- CWE-1092 — Use of Same Invokable Control Element in Multiple Architectural Layers: https://cwe.mitre.org/data/definitions/1092.html
- CWE-1094 — Excessive Index Range Scan for a Data Resource: https://cwe.mitre.org/data/definitions/1094.html
- CWE-1097 — Persistent Storable Data Element without Associated Comparison Control Element: https://cwe.mitre.org/data/definitions/1097.html
- CWE-1098 — Data Element containing Pointer Item without Proper Copy Control Element: https://cwe.mitre.org/data/definitions/1098.html
- CWE-1099 — Inconsistent Naming Conventions for Identifiers: https://cwe.mitre.org/data/definitions/1099.html
- CWE-1101 — Reliance on Runtime Component in Generated Code: https://cwe.mitre.org/data/definitions/1101.html
- CWE-1102 — Reliance on Machine-Dependent Data Representation: https://cwe.mitre.org/data/definitions/1102.html
- CWE-1103 — Use of Platform-Dependent Third Party Components: https://cwe.mitre.org/data/definitions/1103.html
- CWE-1104 — Use of Unmaintained Third Party Components: https://cwe.mitre.org/data/definitions/1104.html
- CWE-1106 — Insufficient Use of Symbolic Constants: https://cwe.mitre.org/data/definitions/1106.html
- CWE-1107 — Insufficient Isolation of Symbolic Constant Definitions: https://cwe.mitre.org/data/definitions/1107.html
- CWE-1108 — Excessive Reliance on Global Variables: https://cwe.mitre.org/data/definitions/1108.html
- CWE-1109 — Use of Same Variable for Multiple Purposes: https://cwe.mitre.org/data/definitions/1109.html
- CWE-1113 — Inappropriate Comment Style: https://cwe.mitre.org/data/definitions/1113.html
- CWE-1114 — Inappropriate Whitespace Style: https://cwe.mitre.org/data/definitions/1114.html
- CWE-1115 — Source Code Element without Standard Prologue: https://cwe.mitre.org/data/definitions/1115.html
- CWE-1116 — Inaccurate Source Code Comments: https://cwe.mitre.org/data/definitions/1116.html
- CWE-1117 — Callable with Insufficient Behavioral Summary: https://cwe.mitre.org/data/definitions/1117.html
- CWE-1126 — Declaration of Variable with Unnecessarily Wide Scope: https://cwe.mitre.org/data/definitions/1126.html
- CWE-1127 — Compilation with Insufficient Warnings or Errors: https://cwe.mitre.org/data/definitions/1127.html
- CWE-1235 — Incorrect Use of Autoboxing and Unboxing for Performance Critical Operations: https://cwe.mitre.org/data/definitions/1235.html
