# CWE-699 - Software Development

## Category: Complexity Issues - CWE-1226

> **Objetivo do material:** documentar, de forma prática, as fraquezas da categoria **Complexity Issues** da view **CWE-699 - Software Development**, com exemplos em **Java**, voltados para aplicações web, APIs REST, Struts/Servlet/JSP, serviços, DAOs, sistemas corporativos e código legado.

---

## 1. Visão geral

A categoria **CWE-1226 - Complexity Issues** agrupa problemas em que a complexidade do código, da arquitetura, das consultas, das expressões regulares ou da superfície exposta dificulta manutenção, revisão, teste e segurança.

Nem toda complexidade é uma vulnerabilidade imediata. O risco aparece quando a complexidade:

- dificulta encontrar validações, autorização e regras de negócio;
- aumenta a chance de corrigir um bug e introduzir outro;
- cria fluxos com muitos caminhos difíceis de testar;
- permite negação de serviço por consumo excessivo de CPU, banco, memória ou threads;
- aumenta a superfície exposta a usuários externos;
- torna o comportamento dependente de ordem, ambiente, herança ou configuração implícita.

### Ponto importante para prova

**Complexidade excessiva é uma fraqueza indireta de segurança.** Muitas CWEs desta categoria não representam uma exploração direta como SQL Injection ou XSS, mas tornam o sistema mais difícil de auditar, corrigir e proteger.

Exemplos comuns em Java corporativo:

- `Action` com centenas ou milhares de linhas;
- `Facade` com regras, autorização, consulta, integração e montagem de PDF no mesmo método;
- método com 15 parâmetros booleanos/string;
- DAO chamado dentro de `for`, gerando N+1 queries;
- regex vulnerável a ReDoS;
- herança profunda entre `Action`, `BaseAction`, `RelatorioAction`, `DepositoAction`;
- endpoint público maior do que o necessário;
- objeto de sessão com listas grandes e objetos não primitivos demais.

---

## 2. CWEs abordadas

| CWE | Nome | Aplicação prática em Java |
|---:|---|---|
| 1043 | Data Element Aggregating an Excessively Large Number of Non-Primitive Elements | DTO/VO/bean/sessão com listas e objetos demais |
| 1047 | Modules with Circular Dependencies | `service` depende de `facade`, que depende do mesmo `service` |
| 1055 | Multiple Inheritance from Concrete Classes | Não se aplica diretamente a Java, mas há analogias com herança/default methods/composição incorreta |
| 1056 | Invokable Control Element with Variadic Parameters | Uso de `Object...`, `String...`, `Map` genérico para regras críticas |
| 1060 | Excessive Number of Inefficient Server-Side Data Accesses | N+1 queries, consultas em loop, múltiplos acessos desnecessários |
| 1064 | Signature Containing Excessive Number of Parameters | Método com parâmetros demais, especialmente flags e filtros soltos |
| 1074 | Class with Excessively Deep Inheritance | Cadeias longas de `extends` dificultando entendimento de regras |
| 1075 | Unconditional Control Flow Transfer outside of Switch Block | `break`/`continue` rotulado, retornos escondidos, fluxo difícil de seguir |
| 1080 | Source Code File with Excessive Number of Lines of Code | Arquivo Java enorme, geralmente `Action`, `Facade` ou `DAO` |
| 1086 | Class with Excessive Number of Child Classes | Classe base abstrata com filhos demais e contrato instável |
| 1095 | Loop Condition Value Update within the Loop | Atualização manual da variável de controle em vários pontos do loop |
| 1119 | Excessive Use of Unconditional Branching | Uso excessivo de `return`, `continue`, `break`, `throw` como controle confuso |
| 1121 | Excessive McCabe Cyclomatic Complexity | Muitos caminhos de execução por `if`, `else`, `case`, `catch` etc. |
| 1122 | Excessive Halstead Complexity | Uso excessivo de operadores, operandos, expressões complexas e código difícil de ler |
| 1123 | Excessive Use of Self-Modifying Code | Em Java, analogias com reflexão, bytecode, scripts dinâmicos e proxies alterando comportamento |
| 1124 | Excessively Deep Nesting | `if` dentro de `if` dentro de `for` dentro de `try` etc. |
| 1125 | Excessive Attack Surface | Endpoints, métodos públicos, Actions e integrações expostos sem necessidade |
| 1333 | Inefficient Regular Expression Complexity | Regex com backtracking catastrófico/ReDoS |

---

# 3. CWE-1043 - Data Element Aggregating an Excessively Large Number of Non-Primitive Elements

## 3.1 Conceito

Ocorre quando um elemento de dados agrega um número excessivo de objetos não primitivos, como listas, mapas, DTOs, entidades e coleções aninhadas.

Em Java, isso aparece como:

- DTO que carrega a tela inteira;
- objeto salvo em sessão com muitas listas;
- entidade JPA/Hibernate com muitos relacionamentos carregados de uma vez;
- objeto de relatório com tudo em memória antes de gerar PDF/XLS;
- formulário Struts com listas de domínio, itens, anexos, usuários, logs e filtros juntos.

## 3.2 Exemplo vulnerável

```java
public class ProcessoTelaDTO implements Serializable {
    private ProcessoDTO processo;
    private List<EnvolvidoDTO> envolvidos;
    private List<DocumentoDTO> documentos;
    private List<HistoricoDTO> historicos;
    private List<MovimentoDTO> movimentos;
    private List<ArquivoDTO> arquivos;
    private List<AuditoriaDTO> auditorias;
    private List<PermissaoDTO> permissoes;
    private Map<String, Object> parametros;
    private Map<String, List<Object>> cacheTela;
}
```

Problemas:

- objeto difícil de serializar em sessão;
- consumo alto de memória;
- maior risco de expor dados sensíveis por acidente;
- difícil saber quais campos são realmente necessários;
- alteração em uma tela pode quebrar outra.

## 3.3 Solução recomendada

Separar DTOs por caso de uso e carregar apenas o necessário.

```java
public class ProcessoResumoDTO implements Serializable {
    private Long idProcesso;
    private String numeroAno;
    private String unidade;
    private String situacao;
}

public class ProcessoDocumentosDTO implements Serializable {
    private Long idProcesso;
    private List<DocumentoResumoDTO> documentos;
}

public class DocumentoResumoDTO implements Serializable {
    private Long idDocumento;
    private String nome;
    private String tipo;
    private boolean sigiloso;
}
```

## 3.4 Revisão prática

Perguntas úteis:

- Esse objeto precisa mesmo carregar todas as listas?
- O objeto está sendo salvo em sessão?
- Algum campo sensível vai para JSON, JSP, log ou serialização?
- Há paginação para listas grandes?
- O DTO é de tela, de domínio, de integração ou de persistência?

---

# 4. CWE-1047 - Modules with Circular Dependencies

## 4.1 Conceito

Ocorre quando módulos dependem uns dos outros de forma circular.

Exemplo de ciclo:

```text
DepositoJudicialAction
    -> DepositoJudicialFacade
        -> ArquivoAnexoService
            -> DepositoJudicialFacade
```

ou:

```text
UsuarioService -> PermissaoService -> AuditoriaService -> UsuarioService
```

O problema aumenta acoplamento, dificulta teste unitário e pode esconder regras de autorização.

## 4.2 Exemplo vulnerável

```java
public class PedidoService {
    private final PagamentoService pagamentoService;

    public void fecharPedido(Long idPedido) {
        pagamentoService.cobrar(idPedido);
    }
}

public class PagamentoService {
    private final PedidoService pedidoService;

    public void cobrar(Long idPedido) {
        Pedido pedido = pedidoService.obterPedido(idPedido);
        // cobrança
    }
}
```

## 4.3 Solução recomendada

Extrair a operação comum para um componente mais estável ou criar um orquestrador.

```java
public class PedidoRepository {
    public Pedido obterPedido(Long idPedido) {
        // consulta centralizada
        return new Pedido();
    }
}

public class PedidoPagamentoWorkflow {
    private final PedidoRepository pedidoRepository;
    private final PagamentoService pagamentoService;

    public void fecharPedido(Long idPedido) {
        Pedido pedido = pedidoRepository.obterPedido(idPedido);
        pagamentoService.cobrar(pedido);
    }
}

public class PagamentoService {
    public void cobrar(Pedido pedido) {
        // cobrança sem depender de PedidoService
    }
}
```

## 4.4 Revisão prática

Procure ciclos como:

```text
Action -> Facade -> Service -> Facade
Service A -> Service B -> Service A
DAO -> Service
DTO -> Service
```

Regra prática:

- `Action` chama `Facade`/`Service`;
- `Service` aplica regra;
- `DAO/Repository` acessa dados;
- `DTO` não deve depender de serviço;
- classes de infraestrutura não devem depender de regra de negócio específica.

---

# 5. CWE-1055 - Multiple Inheritance from Concrete Classes

## 5.1 Conceito

Essa CWE é mais comum em linguagens que permitem herança múltipla de classes concretas, como C++.

Em **Java**, uma classe não pode estender múltiplas classes concretas. Ainda assim, há analogias importantes:

- interfaces com muitos `default methods`;
- hierarquias que simulam herança múltipla por composição mal definida;
- classes base genéricas demais;
- uso de mixins/frameworks/reflection que tornam o comportamento ambíguo.

## 5.2 Exemplo problemático em Java

```java
interface Autorizavel {
    default boolean podeExecutar(Usuario usuario) {
        return usuario != null && usuario.isAtivo();
    }
}

interface Auditavel {
    default boolean podeExecutar(Usuario usuario) {
        return true;
    }
}

public class GerarRelatorioService implements Autorizavel, Auditavel {
    @Override
    public boolean podeExecutar(Usuario usuario) {
        // Resolve conflito, mas pode escolher regra errada.
        return Auditavel.super.podeExecutar(usuario);
    }
}
```

Problema: o método final escolhe a regra mais permissiva por engano.

## 5.3 Solução recomendada

Usar composição explícita.

```java
public class AuthorizationPolicy {
    public boolean podeExecutar(Usuario usuario, String acao) {
        return usuario != null
                && usuario.isAtivo()
                && usuario.possuiPermissao(acao);
    }
}

public class AuditService {
    public void registrar(String acao, Usuario usuario) {
        // auditoria
    }
}

public class GerarRelatorioService {
    private final AuthorizationPolicy authorizationPolicy;
    private final AuditService auditService;

    public GerarRelatorioService(AuthorizationPolicy authorizationPolicy,
                                 AuditService auditService) {
        this.authorizationPolicy = authorizationPolicy;
        this.auditService = auditService;
    }

    public void gerar(Usuario usuario) {
        if (!authorizationPolicy.podeExecutar(usuario, "RELATORIO_GERAR")) {
            throw new SecurityException("Usuário sem permissão.");
        }
        auditService.registrar("RELATORIO_GERAR", usuario);
        // geração do relatório
    }
}
```

---

# 6. CWE-1056 - Invokable Control Element with Variadic Parameters

## 6.1 Conceito

Ocorre quando uma função/método usa parâmetros variáveis, dificultando validação, entendimento e segurança.

Em Java, aparece como:

```java
public void executar(String acao, Object... args)
```

ou:

```java
public void registrarEvento(String tipo, String... campos)
```

## 6.2 Exemplo vulnerável

```java
public void executarAcao(String acao, Object... args) {
    if ("ALTERAR_SENHA".equals(acao)) {
        Long idUsuario = (Long) args[0];
        String novaSenha = (String) args[1];
        alterarSenha(idUsuario, novaSenha);
    }
}
```

Problemas:

- ordem dos argumentos é implícita;
- tipos são validados tarde;
- fácil trocar parâmetro sensível;
- difícil auditar autorização por ação.

## 6.3 Solução recomendada

Criar comandos ou DTOs específicos.

```java
public class AlterarSenhaCommand {
    private final Long idUsuario;
    private final String senhaAtual;
    private final String novaSenha;

    public AlterarSenhaCommand(Long idUsuario, String senhaAtual, String novaSenha) {
        this.idUsuario = idUsuario;
        this.senhaAtual = senhaAtual;
        this.novaSenha = novaSenha;
    }

    public Long getIdUsuario() {
        return idUsuario;
    }

    public String getSenhaAtual() {
        return senhaAtual;
    }

    public String getNovaSenha() {
        return novaSenha;
    }
}

public void alterarSenha(Usuario usuarioLogado, AlterarSenhaCommand command) {
    if (!usuarioLogado.getId().equals(command.getIdUsuario())) {
        throw new SecurityException("Usuário não autorizado.");
    }
    validarSenhaAtual(command.getIdUsuario(), command.getSenhaAtual());
    salvarNovaSenha(command.getIdUsuario(), command.getNovaSenha());
}
```

---

# 7. CWE-1060 - Excessive Number of Inefficient Server-Side Data Accesses

## 7.1 Conceito

Ocorre quando a aplicação executa consultas demais no servidor, especialmente em loops, sem usar agregação, `JOIN`, paginação, batch ou consultas otimizadas.

É comum em:

- relatórios;
- telas com listas grandes;
- geração de PDF/XLS;
- integrações REST que consultam banco para cada item;
- `DAO` chamado dentro de `for`.

## 7.2 Exemplo vulnerável

```java
public List<DepositoDTO> listarDepositosComComprovante(List<Long> ids) {
    List<DepositoDTO> resultado = new ArrayList<>();

    for (Long id : ids) {
        DepositoDTO deposito = depositoDAO.obterPorId(id);
        deposito.setComprovantes(comprovanteDAO.listarPorDeposito(id));
        deposito.setHistorico(historicoDAO.listarPorDeposito(id));
        resultado.add(deposito);
    }

    return resultado;
}
```

Se houver 500 depósitos, o método pode gerar mais de 1.000 consultas.

## 7.3 Solução recomendada

Buscar dados em lote e montar em memória.

```java
public List<DepositoDTO> listarDepositosComComprovante(List<Long> ids) {
    List<DepositoDTO> depositos = depositoDAO.listarPorIds(ids);

    Map<Long, List<ComprovanteDTO>> comprovantesPorDeposito =
            comprovanteDAO.listarPorDepositos(ids).stream()
                    .collect(Collectors.groupingBy(ComprovanteDTO::getIdDeposito));

    Map<Long, List<HistoricoDTO>> historicosPorDeposito =
            historicoDAO.listarPorDepositos(ids).stream()
                    .collect(Collectors.groupingBy(HistoricoDTO::getIdDeposito));

    for (DepositoDTO deposito : depositos) {
        Long idDeposito = deposito.getIdDeposito();
        deposito.setComprovantes(comprovantesPorDeposito.getOrDefault(idDeposito, Collections.emptyList()));
        deposito.setHistorico(historicosPorDeposito.getOrDefault(idDeposito, Collections.emptyList()));
    }

    return depositos;
}
```

## 7.4 Revisão prática

Procure padrões como:

```java
for (...) {
    dao.obter(...);
}

while (...) {
    repository.find...(...);
}

lista.stream().map(item -> dao.consultar(item.getId()))
```

Checklist:

- existe paginação?
- existe limite máximo?
- o DAO pode receber lista de IDs?
- é possível usar `JOIN`, `IN`, `EXISTS`, `GROUP BY` ou agregação?
- o relatório precisa carregar todos os registros em memória?

---

# 8. CWE-1064 - Signature Containing an Excessive Number of Parameters

## 8.1 Conceito

Ocorre quando um método possui parâmetros demais. Isso dificulta entendimento, teste e segurança.

Exemplo comum em sistemas legados:

```java
public List<RelatorioDTO> gerar(Long codUnidade,
                                String nome,
                                String cpf,
                                String numero,
                                Integer ano,
                                Date dataInicio,
                                Date dataFim,
                                Integer status,
                                Integer tipo,
                                Boolean todasUnidades,
                                Boolean detalhado,
                                Usuario usuario) {
    // ...
}
```

Problemas:

- parâmetros podem ser invertidos;
- flags booleanas geram muitos comportamentos ocultos;
- regras de autorização ficam espalhadas;
- difícil criar testes cobrindo combinações.

## 8.2 Solução recomendada

Criar objeto de parâmetro/criteria.

```java
public class RelatorioDepositosFiltro {
    private Long codUnidade;
    private String nome;
    private String cpf;
    private String numero;
    private Integer ano;
    private LocalDate dataInicio;
    private LocalDate dataFim;
    private Integer status;
    private Integer tipo;
    private boolean todasUnidades;
    private boolean detalhado;

    public void validar() {
        if (ano != null && numero == null) {
            throw new IllegalArgumentException("Número deve ser informado quando ano estiver preenchido.");
        }
        if (dataInicio != null && dataFim != null && dataInicio.isAfter(dataFim)) {
            throw new IllegalArgumentException("Data inicial não pode ser posterior à data final.");
        }
    }
}

public List<RelatorioDTO> gerar(RelatorioDepositosFiltro filtro, Usuario usuario) {
    filtro.validar();
    validarPermissao(usuario, filtro);
    return relatorioDAO.listar(filtro);
}
```

---

# 9. CWE-1074 - Class with Excessively Deep Inheritance

## 9.1 Conceito

Ocorre quando uma classe herda comportamento por uma cadeia longa de superclasses.

Exemplo:

```java
public class DepositoJudicialAction
        extends RelatorioFinanceiroAction
        extends BaseRelatorioAction
        extends BaseSegurancaAction
        extends DispatchAction {
}
```

Em Java real, a sintaxe acima não é válida em uma linha, mas representa a cadeia:

```text
DepositoJudicialAction
  -> RelatorioFinanceiroAction
    -> BaseRelatorioAction
      -> BaseSegurancaAction
        -> DispatchAction
```

## 9.2 Exemplo problemático

```java
public class BaseSegurancaAction extends DispatchAction {
    protected Usuario obterUsuario(HttpServletRequest request) {
        return (Usuario) request.getSession().getAttribute("usuario");
    }
}

public class BaseRelatorioAction extends BaseSegurancaAction {
    protected void validarRelatorio(HttpServletRequest request) {
        // validação genérica
    }
}

public class RelatorioFinanceiroAction extends BaseRelatorioAction {
    protected void validarRelatorio(HttpServletRequest request) {
        // sobrescreve parte da regra
    }
}

public class DepositoJudicialAction extends RelatorioFinanceiroAction {
    public ActionForward gerar(ActionMapping mapping, ActionForm form,
                               HttpServletRequest request,
                               HttpServletResponse response) {
        validarRelatorio(request); // Qual regra está sendo chamada?
        return null;
    }
}
```

Problema: fica difícil saber qual regra de validação/autorização será aplicada.

## 9.3 Solução recomendada

Preferir composição com serviços explícitos.

```java
public class DepositoJudicialAction extends DispatchAction {
    private final UsuarioContext usuarioContext = new UsuarioContext();
    private final RelatorioSecurityService relatorioSecurityService = new RelatorioSecurityService();
    private final DepositoJudicialFacade depositoJudicialFacade = new DepositoJudicialFacade();

    public ActionForward gerar(ActionMapping mapping, ActionForm form,
                               HttpServletRequest request,
                               HttpServletResponse response) throws Exception {

        Usuario usuario = usuarioContext.obterUsuario(request);
        RelatorioDepositosFiltro filtro = montarFiltro(form);

        relatorioSecurityService.validarGeracao(usuario, filtro);
        depositoJudicialFacade.gerarRelatorio(filtro, usuario);

        return mapping.findForward("sucesso");
    }
}
```

---

# 10. CWE-1075 - Unconditional Control Flow Transfer outside of Switch Block

## 10.1 Conceito

Ocorre quando o código usa transferência incondicional de fluxo fora de um `switch`, dificultando entendimento e validação.

Em Java, exemplos:

- `break` rotulado;
- `continue` rotulado;
- muitos `return` em posições inesperadas;
- `throw` usado como fluxo normal;
- laços interrompidos de forma não óbvia.

## 10.2 Exemplo problemático

```java
public boolean possuiDocumentoValido(List<PessoaDTO> pessoas) {
    externo:
    for (PessoaDTO pessoa : pessoas) {
        for (DocumentoDTO documento : pessoa.getDocumentos()) {
            if (documento.isBloqueado()) {
                break externo;
            }
            if (documento.isValido()) {
                return true;
            }
        }
    }
    return false;
}
```

Problema: o `break externo` encerra tudo e pode gerar falso negativo.

## 10.3 Solução recomendada

Separar intenção em métodos menores.

```java
public boolean possuiDocumentoValido(List<PessoaDTO> pessoas) {
    for (PessoaDTO pessoa : pessoas) {
        if (possuiDocumentoValido(pessoa)) {
            return true;
        }
    }
    return false;
}

private boolean possuiDocumentoValido(PessoaDTO pessoa) {
    for (DocumentoDTO documento : pessoa.getDocumentos()) {
        if (documento.isBloqueado()) {
            continue;
        }
        if (documento.isValido()) {
            return true;
        }
    }
    return false;
}
```

---

# 11. CWE-1080 - Source Code File with Excessive Number of Lines of Code

## 11.1 Conceito

Ocorre quando um arquivo fonte tem linhas demais, dificultando revisão, entendimento e manutenção.

Em Java web legado, isso costuma ocorrer em:

- `Action` com muitas ações da tela;
- `Facade` que faz regra, SQL, PDF, integração e auditoria;
- `DAO` com SQLs enormes e repetidos;
- JSP com HTML, JavaScript, scriptlet e regra de negócio juntos.

## 11.2 Exemplo problemático

```text
DepositoJudicialAction.java
  - iniciar()
  - pesquisar()
  - gerarRelatorio()
  - exportarXls()
  - exportarPdf()
  - gerarGuia()
  - regerarGuia()
  - baixarComprovante()
  - anexarComprovante()
  - consultarProjudi()
  - escreverErroNoNavegador()
  - montarHtml()
  - validarFiltros()
  - montarSql()
  - tratarExcecoes()
```

Problema: responsabilidades demais no mesmo arquivo.

## 11.3 Solução recomendada

Separar por responsabilidade.

```text
DepositoJudicialAction.java
DepositoJudicialRelatorioAction.java
DepositoJudicialGuiaAction.java
DepositoJudicialDownloadAction.java
DepositoJudicialFacade.java
DepositoJudicialRelatorioService.java
DepositoJudicialGuiaService.java
DepositoJudicialPdfService.java
DepositoJudicialDAO.java
```

Regra prática: a `Action` deve coordenar entrada/saída web, não concentrar regra de negócio nem montagem complexa de PDF/SQL.

---

# 12. CWE-1086 - Class with Excessive Number of Child Classes

## 12.1 Conceito

Ocorre quando uma classe possui filhos demais. Isso torna o contrato da classe base instável e difícil de alterar.

## 12.2 Exemplo problemático

```java
public abstract class RelatorioBase {
    public abstract byte[] gerar(Map<String, Object> parametros);
}

public class RelatorioDepositos extends RelatorioBase { /* ... */ }
public class RelatorioUsuarios extends RelatorioBase { /* ... */ }
public class RelatorioAuditoria extends RelatorioBase { /* ... */ }
public class RelatorioFinanceiro extends RelatorioBase { /* ... */ }
public class RelatorioArquivos extends RelatorioBase { /* ... */ }
// dezenas de outros filhos
```

Problemas:

- qualquer mudança na classe base pode quebrar muitos relatórios;
- filhos podem ignorar validações da classe base;
- contratos genéricos demais (`Map<String,Object>`) dificultam segurança.

## 12.3 Solução recomendada

Usar interface pequena e registrar handlers por tipo.

```java
public interface RelatorioHandler<F> {
    boolean suporta(TipoRelatorio tipo);
    byte[] gerar(F filtro, Usuario usuario);
}

public class RelatorioDepositosHandler implements RelatorioHandler<RelatorioDepositosFiltro> {
    @Override
    public boolean suporta(TipoRelatorio tipo) {
        return TipoRelatorio.DEPOSITOS.equals(tipo);
    }

    @Override
    public byte[] gerar(RelatorioDepositosFiltro filtro, Usuario usuario) {
        validarPermissao(usuario, filtro);
        return gerarPdf(filtro);
    }
}
```

---

# 13. CWE-1095 - Loop Condition Value Update within the Loop

## 13.1 Conceito

Ocorre quando a variável que controla o loop é modificada dentro do próprio loop, especialmente em múltiplos pontos.

## 13.2 Exemplo vulnerável

```java
int i = 0;
while (i < registros.size()) {
    RegistroDTO registro = registros.get(i);

    if (registro.isIgnorar()) {
        i++;
        continue;
    }

    if (registro.isAgrupador()) {
        i = i + registro.getQuantidadeFilhos();
    }

    processar(registro);
    i++;
}
```

Problemas:

- pode pular registros;
- pode processar registro duplicado;
- pode gerar loop infinito;
- difícil testar todos os cenários.

## 13.3 Solução recomendada

Separar pré-processamento e iteração simples.

```java
List<RegistroDTO> registrosProcessaveis = registros.stream()
        .filter(registro -> !registro.isIgnorar())
        .collect(Collectors.toList());

for (RegistroDTO registro : registrosProcessaveis) {
    processar(registro);
}
```

Se for necessário controle de índice, centralize a regra.

```java
for (int i = 0; i < registros.size(); i++) {
    RegistroDTO registro = registros.get(i);
    processar(registro);
}
```

---

# 14. CWE-1119 - Excessive Use of Unconditional Branching

## 14.1 Conceito

Ocorre quando o código usa desvios incondicionais demais, tornando o fluxo difícil de seguir.

Em Java, isso aparece como uso excessivo de:

- `return` espalhado;
- `continue`;
- `break`;
- `throw` para fluxo esperado;
- blocos de exceção usados como regra de negócio.

## 14.2 Exemplo problemático

```java
public Resultado validar(Formulario form, Usuario usuario) {
    if (form == null) return Resultado.erro("Formulário inválido");
    if (usuario == null) return Resultado.erro("Usuário inválido");
    if (!usuario.isAtivo()) return Resultado.erro("Usuário inativo");
    if (form.getNumero() == null) return Resultado.erro("Número obrigatório");
    if (form.getAno() == null) return Resultado.erro("Ano obrigatório");
    if (!usuario.podeConsultar(form.getUnidade())) return Resultado.erro("Sem permissão");
    if (form.getDataInicio() != null && form.getDataFim() != null && form.getDataInicio().after(form.getDataFim())) return Resultado.erro("Período inválido");

    return Resultado.ok();
}
```

O uso de guard clauses não é ruim por si só, mas quando se torna uma lista extensa e desorganizada, a regra fica difícil de auditar.

## 14.3 Solução recomendada

Agrupar validações por responsabilidade.

```java
public Resultado validar(Formulario form, Usuario usuario) {
    List<String> erros = new ArrayList<>();

    validarUsuario(usuario, erros);
    validarCamposObrigatorios(form, erros);
    validarPeriodo(form, erros);
    validarPermissao(form, usuario, erros);

    return erros.isEmpty() ? Resultado.ok() : Resultado.erro(erros);
}

private void validarUsuario(Usuario usuario, List<String> erros) {
    if (usuario == null || !usuario.isAtivo()) {
        erros.add("Usuário inválido ou inativo.");
    }
}

private void validarCamposObrigatorios(Formulario form, List<String> erros) {
    if (form == null) {
        erros.add("Formulário inválido.");
        return;
    }
    if (form.getNumero() == null) {
        erros.add("Número obrigatório.");
    }
    if (form.getAno() == null) {
        erros.add("Ano obrigatório.");
    }
}
```

---

# 15. CWE-1121 - Excessive McCabe Cyclomatic Complexity

## 15.1 Conceito

Complexidade ciclomática mede a quantidade de caminhos independentes em um trecho de código. Quanto maior o número de `if`, `else`, `case`, `catch`, operadores lógicos e desvios, mais caminhos precisam ser testados.

## 15.2 Exemplo vulnerável

```java
public BigDecimal calcularValor(Deposito deposito, Usuario usuario) {
    BigDecimal valor = deposito.getValor();

    if (deposito.isPix()) {
        if (deposito.isExpirado()) {
            if (usuario.isAdministrador()) {
                valor = valor.add(taxaRegeracao());
            } else {
                throw new SecurityException("Sem permissão");
            }
        } else if (deposito.isPago()) {
            valor = valor.subtract(descontoPagamento());
        } else {
            valor = valor.add(taxaPix());
        }
    } else if (deposito.isBoleto()) {
        if (deposito.isPago()) {
            valor = valor.subtract(descontoPagamento());
        } else if (deposito.isExpirado()) {
            valor = valor.add(multaBoleto());
        } else {
            valor = valor.add(taxaBoleto());
        }
    } else {
        throw new IllegalArgumentException("Tipo de depósito inválido");
    }

    if (deposito.getDataPagamento() != null && deposito.getDataPagamento().after(new Date())) {
        throw new IllegalStateException("Data de pagamento futura");
    }

    return valor;
}
```

Problemas:

- muitos caminhos;
- difícil testar todas as combinações;
- regras de autorização misturadas com cálculo;
- risco de inconsistência entre PIX e boleto.

## 15.3 Solução recomendada

Separar regras por estratégia.

```java
public interface CalculadoraDeposito {
    boolean suporta(TipoDeposito tipo);
    BigDecimal calcular(Deposito deposito, Usuario usuario);
}

public class CalculadoraPix implements CalculadoraDeposito {
    @Override
    public boolean suporta(TipoDeposito tipo) {
        return TipoDeposito.PIX.equals(tipo);
    }

    @Override
    public BigDecimal calcular(Deposito deposito, Usuario usuario) {
        validarDataPagamento(deposito);
        validarRegeracaoExpirada(deposito, usuario);

        if (deposito.isPago()) {
            return deposito.getValor().subtract(descontoPagamento());
        }
        if (deposito.isExpirado()) {
            return deposito.getValor().add(taxaRegeracao());
        }
        return deposito.getValor().add(taxaPix());
    }

    private void validarRegeracaoExpirada(Deposito deposito, Usuario usuario) {
        if (deposito.isExpirado() && !usuario.isAdministrador()) {
            throw new SecurityException("Sem permissão");
        }
    }
}
```

---

# 16. CWE-1122 - Excessive Halstead Complexity

## 16.1 Conceito

A complexidade Halstead considera quantidade e variedade de operadores e operandos. Na prática, ela cresce quando uma expressão ou método usa muitos símbolos, condições e variáveis diferentes.

## 16.2 Exemplo problemático

```java
if ((usuario != null && usuario.isAtivo() && usuario.getPerfil() != null
        && (usuario.getPerfil().isAdmin() || usuario.getPerfil().isGestor())
        && deposito != null && deposito.getUnidade() != null
        && deposito.getUnidade().equals(usuario.getUnidade())
        && deposito.getValor() != null && deposito.getValor().compareTo(BigDecimal.ZERO) > 0
        && (deposito.isPendente() || (deposito.isExpirado() && usuario.isAdmin()))
        && request.getParameter("confirmar") != null
        && "S".equals(request.getParameter("confirmar")))) {
    gerarGuia(deposito);
}
```

## 16.3 Solução recomendada

Nomear regras intermediárias.

```java
boolean usuarioValido = usuario != null && usuario.isAtivo();
boolean perfilAutorizado = usuarioValido
        && usuario.getPerfil() != null
        && (usuario.getPerfil().isAdmin() || usuario.getPerfil().isGestor());
boolean mesmaUnidade = deposito != null
        && deposito.getUnidade() != null
        && deposito.getUnidade().equals(usuario.getUnidade());
boolean valorValido = deposito != null
        && deposito.getValor() != null
        && deposito.getValor().compareTo(BigDecimal.ZERO) > 0;
boolean situacaoPermiteGeracao = deposito != null
        && (deposito.isPendente() || (deposito.isExpirado() && usuario.isAdmin()));
boolean confirmacaoInformada = "S".equals(request.getParameter("confirmar"));

if (usuarioValido
        && perfilAutorizado
        && mesmaUnidade
        && valorValido
        && situacaoPermiteGeracao
        && confirmacaoInformada) {
    gerarGuia(deposito);
}
```

Melhor ainda: mover para uma policy.

```java
if (guiaPolicy.podeGerar(usuario, deposito, request.getParameter("confirmar"))) {
    gerarGuia(deposito);
}
```

---

# 17. CWE-1123 - Excessive Use of Self-Modifying Code

## 17.1 Conceito

Self-modifying code é mais comum em linguagens de baixo nível, mas em Java há equivalentes práticos:

- geração dinâmica de bytecode;
- scripts Groovy/JavaScript executados em produção;
- reflexão alterando campos privados;
- proxies dinâmicos mudando comportamento;
- carregamento de classe/plugin sem controle;
- regras de negócio armazenadas como texto no banco.

## 17.2 Exemplo vulnerável

```java
public boolean validarRegra(String regra, Map<String, Object> contexto) throws Exception {
    ScriptEngine engine = new ScriptEngineManager().getEngineByName("JavaScript");
    engine.put("ctx", contexto);
    return Boolean.TRUE.equals(engine.eval(regra));
}
```

Se `regra` vier do banco ou de usuário sem controle, a aplicação passa a executar comportamento dinâmico difícil de auditar.

## 17.3 Solução recomendada

Modelar regras com tipos explícitos.

```java
public interface RegraValidacao {
    boolean validar(ContextoValidacao contexto);
}

public class RegraValorMinimo implements RegraValidacao {
    private final BigDecimal valorMinimo;

    public RegraValorMinimo(BigDecimal valorMinimo) {
        this.valorMinimo = valorMinimo;
    }

    @Override
    public boolean validar(ContextoValidacao contexto) {
        return contexto.getValor().compareTo(valorMinimo) >= 0;
    }
}
```

Se regras dinâmicas forem inevitáveis:

- usar allowlist de operações;
- versionar regras;
- registrar auditoria;
- limitar permissões;
- testar regras antes de ativar;
- impedir acesso a APIs de sistema, rede, arquivos e reflection.

---

# 18. CWE-1124 - Excessively Deep Nesting

## 18.1 Conceito

Ocorre quando há muitos blocos aninhados, dificultando leitura e teste.

## 18.2 Exemplo vulnerável

```java
public void processar(Formulario form, Usuario usuario) {
    if (form != null) {
        if (usuario != null) {
            if (usuario.isAtivo()) {
                if (form.getId() != null) {
                    if (usuario.podeAlterar(form.getUnidade())) {
                        if (form.isConfirmado()) {
                            salvar(form);
                        }
                    }
                }
            }
        }
    }
}
```

## 18.3 Solução recomendada

Usar validações de saída e métodos com nomes claros.

```java
public void processar(Formulario form, Usuario usuario) {
    validarFormulario(form);
    validarUsuario(usuario);
    validarPermissao(usuario, form);
    validarConfirmacao(form);

    salvar(form);
}

private void validarFormulario(Formulario form) {
    if (form == null || form.getId() == null) {
        throw new IllegalArgumentException("Formulário inválido.");
    }
}

private void validarUsuario(Usuario usuario) {
    if (usuario == null || !usuario.isAtivo()) {
        throw new SecurityException("Usuário inválido.");
    }
}

private void validarPermissao(Usuario usuario, Formulario form) {
    if (!usuario.podeAlterar(form.getUnidade())) {
        throw new SecurityException("Usuário sem permissão.");
    }
}

private void validarConfirmacao(Formulario form) {
    if (!form.isConfirmado()) {
        throw new IllegalStateException("Operação não confirmada.");
    }
}
```

---

# 19. CWE-1125 - Excessive Attack Surface

## 19.1 Conceito

Ocorre quando o produto expõe pontos de entrada, permissões, funções, endpoints, métodos públicos ou integrações além do necessário.

Em Java web:

- Actions públicas sem necessidade;
- endpoints administrativos ativos em produção;
- métodos `public` que deveriam ser `private`/`protected`;
- URLs antigas ainda funcionando;
- filtros aplicados apenas a parte das rotas;
- documentação Swagger aberta com endpoints internos;
- Actuator/JMX/console expostos.

## 19.2 Exemplo vulnerável

```java
public class AdminAction extends DispatchAction {

    public ActionForward limparCache(ActionMapping mapping, ActionForm form,
                                     HttpServletRequest request,
                                     HttpServletResponse response) {
        cacheService.limparTudo();
        return mapping.findForward("ok");
    }

    public ActionForward executarJob(ActionMapping mapping, ActionForm form,
                                     HttpServletRequest request,
                                     HttpServletResponse response) {
        jobService.executar(request.getParameter("job"));
        return mapping.findForward("ok");
    }
}
```

Problema: métodos administrativos podem ficar acessíveis por URL.

## 19.3 Solução recomendada

Reduzir a superfície e aplicar autorização explícita.

```java
public class AdminAction extends DispatchAction {

    public ActionForward limparCache(ActionMapping mapping, ActionForm form,
                                     HttpServletRequest request,
                                     HttpServletResponse response) {
        Usuario usuario = obterUsuario(request);
        authorizationGuard.exigirPermissao(usuario, "ADMIN_CACHE_LIMPAR");

        cacheService.limparCacheAplicacao();
        auditoriaService.registrar(usuario, "ADMIN_CACHE_LIMPAR");

        return mapping.findForward("ok");
    }
}
```

Boas práticas:

- remover endpoints não usados;
- restringir por perfil e rede quando aplicável;
- exigir autenticação forte para função crítica;
- separar endpoints internos de externos;
- desabilitar consoles/debug em produção;
- validar se todo método Action público está realmente mapeado e protegido.

---

# 20. CWE-1333 - Inefficient Regular Expression Complexity

## 20.1 Conceito

Ocorre quando uma expressão regular possui complexidade de pior caso ineficiente, possivelmente exponencial. Isso pode causar **ReDoS** (*Regular Expression Denial of Service*), consumindo CPU com entradas especialmente criadas.

## 20.2 Exemplo vulnerável

```java
private static final Pattern PADRAO = Pattern.compile("^(a+)+$");

public boolean validar(String entrada) {
    return PADRAO.matcher(entrada).matches();
}
```

Entrada problemática:

```text
aaaaaaaaaaaaaaaaaaaaaaaaaaaaa!
```

O regex tenta muitas combinações antes de falhar.

## 20.3 Exemplo mais realista

```java
private static final Pattern EMAIL_FRACO = Pattern.compile("^(.+)+@(.+)+\\.(.+)+$");

public boolean emailValido(String email) {
    return EMAIL_FRACO.matcher(email).matches();
}
```

Problemas:

- grupos repetidos aninhados;
- `.+` amplo demais;
- ausência de limite de tamanho;
- regex tenta muitas alternativas.

## 20.4 Solução recomendada

Definir limite de tamanho e regex mais restritiva.

```java
private static final int TAMANHO_MAX_EMAIL = 254;

private static final Pattern EMAIL_SEGURO = Pattern.compile(
        "^[A-Za-z0-9._%+-]{1,64}@[A-Za-z0-9.-]{1,253}\\.[A-Za-z]{2,20}$"
);

public boolean emailValido(String email) {
    if (email == null || email.length() > TAMANHO_MAX_EMAIL) {
        return false;
    }
    return EMAIL_SEGURO.matcher(email).matches();
}
```

## 20.5 Alternativas de mitigação

- limitar tamanho da entrada antes do regex;
- evitar quantificadores aninhados como `(a+)+`, `(.*)+`, `(.+)+`;
- preferir classes de caracteres específicas;
- usar quantificadores possessivos quando adequado: `++`, `*+`, `?+`;
- pré-compilar `Pattern` estático;
- considerar biblioteca com mecanismo sem backtracking catastrófico, quando disponível;
- criar testes com entradas maliciosas grandes.

Exemplo com quantificador possessivo:

```java
private static final Pattern SOMENTE_A = Pattern.compile("^a++$");
```

---

# 21. Utilitário prático: revisão de complexidade em Java

```java
public final class ComplexityReviewRules {

    private ComplexityReviewRules() {
    }

    public static void validarTamanhoEntrada(String valor, int limite, String campo) {
        if (valor != null && valor.length() > limite) {
            throw new IllegalArgumentException(campo + " excede o tamanho máximo permitido.");
        }
    }

    public static <T> List<T> limitarLista(List<T> lista, int limite, String campo) {
        if (lista == null) {
            return Collections.emptyList();
        }
        if (lista.size() > limite) {
            throw new IllegalArgumentException(campo + " excede o limite permitido.");
        }
        return lista;
    }

    public static void exigirPagina(Integer pagina, Integer tamanhoPagina) {
        if (pagina == null || pagina < 1) {
            throw new IllegalArgumentException("Página inválida.");
        }
        if (tamanhoPagina == null || tamanhoPagina < 1 || tamanhoPagina > 100) {
            throw new IllegalArgumentException("Tamanho da página inválido.");
        }
    }
}
```

Uso:

```java
public List<DepositoDTO> pesquisar(FiltroDepositos filtro, Usuario usuario) {
    ComplexityReviewRules.exigirPagina(filtro.getPagina(), filtro.getTamanhoPagina());
    ComplexityReviewRules.validarTamanhoEntrada(filtro.getNome(), 120, "Nome");
    authorizationGuard.validarConsultaDepositos(usuario, filtro);
    return depositoDAO.pesquisar(filtro);
}
```

---

# 22. Comandos de apoio para revisão

## 22.1 Métodos com varargs

```bash
grep -R "\.\.\." -n src/main/java
```

## 22.2 Possíveis consultas dentro de loops

```bash
grep -R "for .*{" -n src/main/java
grep -R "while .*{" -n src/main/java
grep -R "DAO\.\|dao\.\|Repository\.\|repository\." -n src/main/java
```

Depois verifique manualmente se há acesso a dados dentro de `for`, `while` ou `stream().map(...)`.

## 22.3 Classes muito grandes

```bash
find src/main/java -name "*.java" -exec wc -l {} + | sort -nr | head -30
```

## 22.4 JSPs muito grandes

```bash
find src/main/webapp -name "*.jsp" -exec wc -l {} + | sort -nr | head -30
```

## 22.5 Uso de regex potencialmente arriscado

```bash
grep -R "Pattern.compile" -n src/main/java
grep -R "matches()" -n src/main/java
grep -R "replaceAll" -n src/main/java
grep -R "split(" -n src/main/java
```

Procure especialmente padrões com:

```text
(.*)+
(.+)+
(a+)+
([a-zA-Z]+)*
```

## 22.6 Métodos com parâmetros demais

```bash
grep -R "public .*([^)]*,[^)]*,[^)]*,[^)]*,[^)]*," -n src/main/java
```

## 22.7 Uso excessivo de herança

```bash
grep -R "extends " -n src/main/java
```

Depois verifique a profundidade das classes base.

## 22.8 Métodos públicos em Actions

```bash
grep -R "public ActionForward" -n src/main/java
```

Revise se todos exigem autenticação/autorização e se realmente precisam estar expostos.

---

# 23. Checklist prático

Use este checklist em revisão de código:

## Complexidade estrutural

- [ ] A classe possui responsabilidade única?
- [ ] O arquivo Java/JSP não está grande demais?
- [ ] Há herança profunda?
- [ ] Há classe base com filhos demais?
- [ ] Há dependência circular entre módulos?
- [ ] Há parâmetros demais em métodos públicos?
- [ ] Há uso de `Object...`, `Map<String,Object>` ou parâmetros genéricos em regra crítica?

## Complexidade de fluxo

- [ ] O método possui muitos `if/else/case/catch`?
- [ ] Há blocos muito aninhados?
- [ ] Há `break`/`continue` rotulado?
- [ ] A variável de controle do loop é alterada dentro do loop?
- [ ] Existem múltiplos retornos que dificultam auditoria?
- [ ] Cada regra de segurança tem nome claro?

## Complexidade de dados e recursos

- [ ] Há consulta ao banco dentro de loop?
- [ ] Há paginação e limite máximo?
- [ ] Há lista grande mantida em sessão?
- [ ] Há objeto agregando muitas listas/entidades?
- [ ] O relatório carrega todos os dados em memória?

## Superfície de ataque

- [ ] Existe endpoint administrativo exposto?
- [ ] Todo método público em `Action`/controller exige autorização?
- [ ] Rotas antigas foram removidas ou bloqueadas?
- [ ] Swagger/Actuator/JMX/console estão protegidos?
- [ ] Métodos que deveriam ser internos estão públicos?

## Regex

- [ ] Regex recebe entrada de usuário?
- [ ] Existe limite de tamanho antes do regex?
- [ ] O padrão possui quantificadores aninhados?
- [ ] Existe teste com entrada maliciosa grande?
- [ ] É possível substituir regex por parser/validação simples?

---

# 24. Testes sugeridos

## 24.1 Teste para N+1 query

```java
@Test
public void deveConsultarDepositosEmLote() {
    List<Long> ids = Arrays.asList(1L, 2L, 3L, 4L, 5L);

    service.listarDepositosComComprovante(ids);

    verify(depositoDAO, times(1)).listarPorIds(ids);
    verify(comprovanteDAO, times(1)).listarPorDepositos(ids);
    verify(historicoDAO, times(1)).listarPorDepositos(ids);
}
```

## 24.2 Teste para limite de entrada antes de regex

```java
@Test
public void deveRecusarEmailMuitoGrandeAntesDoRegex() {
    String email = "a".repeat(10_000) + "@teste.com";

    boolean valido = validador.emailValido(email);

    assertFalse(valido);
}
```

## 24.3 Teste para método com criteria

```java
@Test
public void deveRejeitarAnoSemNumero() {
    RelatorioDepositosFiltro filtro = new RelatorioDepositosFiltro();
    filtro.setAno(2026);

    assertThrows(IllegalArgumentException.class, filtro::validar);
}
```

## 24.4 Teste para superfície de ataque

```java
@Test
public void deveExigirPermissaoParaLimparCache() {
    Usuario usuario = new Usuario();
    usuario.setPerfil("USUARIO_COMUM");

    assertThrows(SecurityException.class, () -> {
        adminService.limparCache(usuario);
    });
}
```

---

# 25. Resumo para prova

| CWE | Ideia central | Como lembrar |
|---:|---|---|
| 1043 | Objeto agrega coisas demais | DTO/sessão gigante |
| 1047 | Dependência circular | A chama B que chama A |
| 1055 | Herança múltipla concreta | Em Java, analogia com contrato ambíguo |
| 1056 | Parâmetros variáveis | `Object...` em regra crítica |
| 1060 | Consultas ineficientes demais | N+1 query |
| 1064 | Parâmetros demais | Método difícil de chamar/testar |
| 1074 | Herança profunda | Regra escondida na superclasse |
| 1075 | Desvio incondicional fora de switch | `break externo`, fluxo confuso |
| 1080 | Arquivo grande demais | Action/Facade/DAO monstro |
| 1086 | Classe base com filhos demais | contrato frágil |
| 1095 | Controle do loop alterado no corpo | risco de pular/infinito |
| 1119 | Desvios demais | fluxo difícil de auditar |
| 1121 | Complexidade ciclomática alta | muitos caminhos |
| 1122 | Complexidade Halstead alta | expressão/método difícil de ler |
| 1123 | Código automodificável | regra dinâmica/reflection/script |
| 1124 | Aninhamento profundo | `if` dentro de `if` dentro de `if` |
| 1125 | Superfície de ataque grande | endpoint/método exposto demais |
| 1333 | Regex ineficiente | ReDoS/backtracking catastrófico |

---

# 26. Referências oficiais

- CWE-699 - Software Development: https://cwe.mitre.org/data/definitions/699.html
- CWE-1226 - Complexity Issues: https://cwe.mitre.org/data/definitions/1226.html
- CWE-1043 - Data Element Aggregating an Excessively Large Number of Non-Primitive Elements: https://cwe.mitre.org/data/definitions/1043.html
- CWE-1047 - Modules with Circular Dependencies: https://cwe.mitre.org/data/definitions/1047.html
- CWE-1055 - Multiple Inheritance from Concrete Classes: https://cwe.mitre.org/data/definitions/1055.html
- CWE-1056 - Invokable Control Element with Variadic Parameters: https://cwe.mitre.org/data/definitions/1056.html
- CWE-1060 - Excessive Number of Inefficient Server-Side Data Accesses: https://cwe.mitre.org/data/definitions/1060.html
- CWE-1064 - Invokable Control Element with Signature Containing an Excessive Number of Parameters: https://cwe.mitre.org/data/definitions/1064.html
- CWE-1074 - Class with Excessively Deep Inheritance: https://cwe.mitre.org/data/definitions/1074.html
- CWE-1075 - Unconditional Control Flow Transfer outside of Switch Block: https://cwe.mitre.org/data/definitions/1075.html
- CWE-1080 - Source Code File with Excessive Number of Lines of Code: https://cwe.mitre.org/data/definitions/1080.html
- CWE-1086 - Class with Excessive Number of Child Classes: https://cwe.mitre.org/data/definitions/1086.html
- CWE-1095 - Loop Condition Value Update within the Loop: https://cwe.mitre.org/data/definitions/1095.html
- CWE-1119 - Excessive Use of Unconditional Branching: https://cwe.mitre.org/data/definitions/1119.html
- CWE-1121 - Excessive McCabe Cyclomatic Complexity: https://cwe.mitre.org/data/definitions/1121.html
- CWE-1122 - Excessive Halstead Complexity: https://cwe.mitre.org/data/definitions/1122.html
- CWE-1123 - Excessive Use of Self-Modifying Code: https://cwe.mitre.org/data/definitions/1123.html
- CWE-1124 - Excessively Deep Nesting: https://cwe.mitre.org/data/definitions/1124.html
- CWE-1125 - Excessive Attack Surface: https://cwe.mitre.org/data/definitions/1125.html
- CWE-1333 - Inefficient Regular Expression Complexity: https://cwe.mitre.org/data/definitions/1333.html
