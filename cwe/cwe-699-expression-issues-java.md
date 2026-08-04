# CWE-699 — Software Development

## Category: Expression Issues — CWE-569

> **Objetivo:** apresentar uma documentação prática sobre erros de expressão lógica, com exemplos vulneráveis e corrigidos em **Java 8**, aplicáveis a sistemas web, APIs REST, Struts/Servlet/JSP, Services, Facades, DAOs, validações, autorização, filtros, jobs e regras de negócio.

---

## 1. Visão geral

A categoria **CWE-569 — Expression Issues** agrupa fraquezas causadas por expressões escritas de forma incorreta.

Essas falhas parecem simples, mas podem causar problemas graves quando a expressão controla:

- autenticação;
- autorização;
- validação de entrada;
- bloqueio de conta;
- cálculo financeiro;
- status de workflow;
- filtro de dados por usuário;
- regra de negócio;
- fluxo de aprovação;
- execução de job;
- tratamento de exceção;
- liberação de funcionalidade administrativa.

Exemplos comuns em Java:

```java
if (usuario != null || usuario.isAtivo()) { ... }
```

```java
if (!perfil.equals("ADMIN") || !perfil.equals("GESTOR")) { ... }
```

```java
if (status == APROVADO || status == DEFERIDO && usuario.isAdmin()) { ... }
```

```java
if (valor.compareTo(BigDecimal.ZERO) == -1) { ... }
```

```java
if (ativo = true) { ... } // Em Java, só compila quando a variável é boolean.
```

O problema central é que a expressão compila, parece razoável em revisão superficial, mas executa uma regra diferente da intenção.

---

## 2. Natureza da categoria

A **CWE-569** é uma **Category**, isto é, um agrupamento organizacional. Ela não deve ser usada diretamente para mapear uma vulnerabilidade real quando houver uma CWE Base mais específica.

Mapeamento prático:

| Situação encontrada | CWE mais específica |
|---|---:|
| Operador errado, como `||` no lugar de `&&` | CWE-480 |
| Expressão que nunca será verdadeira | CWE-570 |
| Expressão que sempre será verdadeira | CWE-571 |
| Falha causada por precedência entre `&&`, `||`, `!`, `+`, `?:` etc. | CWE-783 |

---

## 3. CWEs abordadas

| CWE | Nome | Aplicação prática em Java |
|---:|---|---|
| 480 | Use of Incorrect Operator | Uso de operador errado: `=`, `==`, `!=`, `&&`, `||`, `&`, `|`, `+`, `!`, `compareTo` |
| 570 | Expression is Always False | Condição impossível, regra morta, branch nunca executado |
| 571 | Expression is Always True | Condição tautológica, validação inútil, autorização sempre liberada |
| 783 | Operator Precedence Logic Error | Falta de parênteses altera a ordem de avaliação |

---

# 4. Princípios práticos

## 4.1 Expressões de segurança devem ser simples

Evite expressões longas como:

```java
if ((usuario != null && usuario.isAtivo() || usuario.isAdmin())
        && status != null && status == APROVADO
        || perfil != null && perfil.equals("GESTOR")) {
    executar();
}
```

Prefira nomes intermediários:

```java
boolean usuarioAtivo =
    usuario != null && usuario.isAtivo();

boolean usuarioAdmin =
    usuario != null && usuario.isAdmin();

boolean statusAprovado =
    Status.APROVADO.equals(status);

boolean gestor =
    Perfil.GESTOR.equals(perfil);

if ((usuarioAtivo || usuarioAdmin)
        && statusAprovado
        && gestor) {
    executar();
}
```

Ainda melhor: mover a regra para método com nome de negócio.

```java
if (politica.podeExecutar(usuario, status, perfil)) {
    executar();
}
```

## 4.2 Não misturar decisão de negócio com detalhe técnico

Ruim:

```java
if (request.getParameter("admin") != null
        && request.getParameter("admin") == "true"
        || session.getAttribute("perfil").equals("ADMIN")) {
    excluir();
}
```

Melhor:

```java
if (authorizationService.temPermissao(
        principal,
        Permissao.EXCLUIR_REGISTRO)) {
    excluir();
}
```

## 4.3 Usar parênteses mesmo quando a precedência é conhecida

Java possui regras claras de precedência, mas código de regra de negócio deve ser legível.

Preferir:

```java
if ((status == Status.APROVADO
        || status == Status.DEFERIDO)
        && usuario.isGestor()) {
    liberar();
}
```

em vez de:

```java
if (status == Status.APROVADO
        || status == Status.DEFERIDO
        && usuario.isGestor()) {
    liberar();
}
```

## 4.4 Testar os quatro quadrantes

Para expressões booleanas com duas condições, testar:

| A | B | Resultado esperado |
|---|---|---|
| false | false | ? |
| false | true | ? |
| true | false | ? |
| true | true | ? |

Muitas falhas em `&&`, `||` e `!` aparecem apenas quando se testa todas as combinações.

---

# 5. CWE-480 — Use of Incorrect Operator

## 5.1 Conceito

O produto usa acidentalmente o operador errado, alterando a lógica esperada.

Em Java, alguns erros clássicos de C/C++ não compilam, como atribuir inteiro dentro de `if`. Porém, muitos erros equivalentes ainda compilam:

- `=` em boolean;
- `==` em `String`;
- `!=` em vez de `==`;
- `||` em vez de `&&`;
- `&` em vez de `&&`;
- `|` em vez de `||`;
- `+` em vez de comparação/cálculo correto;
- `!` aplicado ao termo errado;
- `compareTo` usado com valor específico;
- `equals` usado em `BigDecimal` quando a intenção era comparar valor numérico;
- `==` em objetos/enums mal modelados.

---

## 5.2 Exemplo vulnerável: atribuição em boolean

```java
public boolean podeAcessar(Usuario usuario) {
    boolean autenticado = usuario != null;

    if (autenticado = true) {
        return true;
    }

    return false;
}
```

### Problema

Em Java, isso compila porque `autenticado` é boolean. O valor `true` é atribuído à variável, e a condição passa a ser sempre verdadeira.

## 5.3 Solução

```java
public boolean podeAcessar(Usuario usuario) {
    boolean autenticado =
        usuario != null;

    if (autenticado) {
        return true;
    }

    return false;
}
```

Ou diretamente:

```java
public boolean podeAcessar(Usuario usuario) {
    return usuario != null;
}
```

---

## 5.4 Exemplo vulnerável: `||` em vez de `&&`

```java
public void alterarSenha(
        Usuario usuario,
        String novaSenha) {

    if (usuario != null || usuario.isAtivo()) {
        senhaService.alterar(usuario, novaSenha);
    }
}
```

### Problema

Se `usuario` for `null`, a segunda parte será avaliada e causará `NullPointerException`. A intenção provavelmente era exigir usuário existente e ativo.

## 5.5 Solução

```java
public void alterarSenha(
        Usuario usuario,
        String novaSenha) {

    if (usuario != null && usuario.isAtivo()) {
        senhaService.alterar(usuario, novaSenha);
        return;
    }

    throw new AutorizacaoException(
        "Usuário inválido ou inativo"
    );
}
```

---

## 5.6 Exemplo vulnerável: `&&` e `||` com negações

Versão correta para negar quem não é ADMIN nem GESTOR:

```java
public void validarPerfil(String perfil) {
    if (!"ADMIN".equals(perfil)
            && !"GESTOR".equals(perfil)) {
        throw new AutorizacaoException(
            "Perfil não autorizado"
        );
    }
}
```

Versão vulnerável:

```java
public void validarPerfil(String perfil) {
    if (!"ADMIN".equals(perfil)
            || !"GESTOR".equals(perfil)) {
        throw new AutorizacaoException(
            "Perfil não autorizado"
        );
    }
}
```

### Problema

A expressão sempre será verdadeira, porque nenhum perfil pode ser simultaneamente `ADMIN` e `GESTOR`.

Para `ADMIN`:

```text
!"ADMIN".equals("ADMIN")  → false
!"GESTOR".equals("ADMIN") → true
false || true             → true
```

## 5.7 Solução

```java
public void validarPerfil(String perfil) {
    if (!"ADMIN".equals(perfil)
            && !"GESTOR".equals(perfil)) {
        throw new AutorizacaoException(
            "Perfil não autorizado"
        );
    }
}
```

Mais legível:

```java
public void validarPerfil(String perfil) {
    Set<String> permitidos =
        new HashSet<String>(
            Arrays.asList("ADMIN", "GESTOR")
        );

    if (!permitidos.contains(perfil)) {
        throw new AutorizacaoException(
            "Perfil não autorizado"
        );
    }
}
```

---

## 5.8 Exemplo vulnerável: `==` com `String`

```java
public boolean isAdministrador(String perfil) {
    return perfil == "ADMIN";
}
```

### Problema

`==` compara referência de objeto, não conteúdo textual.

## 5.9 Solução

```java
public boolean isAdministrador(String perfil) {
    return "ADMIN".equals(perfil);
}
```

Para domínio de perfis, preferir enum:

```java
public enum Perfil {
    ADMIN,
    GESTOR,
    USUARIO
}
```

```java
public boolean isAdministrador(Perfil perfil) {
    return Perfil.ADMIN.equals(perfil);
}
```

---

## 5.10 Exemplo vulnerável: `&` em vez de `&&`

```java
public boolean podeVisualizar(
        Usuario usuario,
        Documento documento) {

    return usuario != null
        & documento.getDonoId()
            .equals(usuario.getId());
}
```

### Problema

`&` em boolean avalia os dois lados sempre. Se `usuario` for `null`, a segunda expressão pode gerar erro.

## 5.11 Solução

```java
public boolean podeVisualizar(
        Usuario usuario,
        Documento documento) {

    return usuario != null
        && documento != null
        && documento.getDonoId()
            .equals(usuario.getId());
}
```

---

## 5.12 Exemplo vulnerável: `compareTo` usado incorretamente

```java
public boolean valorNegativo(BigDecimal valor) {
    return valor.compareTo(BigDecimal.ZERO) == -1;
}
```

### Problema

O contrato de `compareTo` garante valor negativo, zero ou positivo. Não garante exatamente `-1`.

## 5.13 Solução

```java
public boolean valorNegativo(BigDecimal valor) {
    return valor.compareTo(BigDecimal.ZERO) < 0;
}
```

---

## 5.14 Exemplo vulnerável: `BigDecimal.equals`

```java
public boolean valorEsperado(BigDecimal valor) {
    return valor.equals(new BigDecimal("10.00"));
}
```

### Problema

`BigDecimal.equals` considera escala. Assim, `10.0` e `10.00` podem ser diferentes.

## 5.15 Solução

```java
public boolean valorEsperado(BigDecimal valor) {
    return valor.compareTo(
        new BigDecimal("10.00")
    ) == 0;
}
```

---

# 6. CWE-570 — Expression is Always False

## 6.1 Conceito

A aplicação contém uma expressão que sempre será falsa.

Isso pode causar:

- regra de segurança nunca aplicada;
- validação nunca executada;
- alerta nunca emitido;
- job nunca processado;
- status nunca alcançado;
- bloqueio nunca acionado;
- teste enganoso;
- código morto.

---

## 6.2 Exemplo vulnerável: condição impossível

```java
public boolean perfilPermitido(String perfil) {
    return "ADMIN".equals(perfil)
        && "GESTOR".equals(perfil);
}
```

Nenhum valor único de `perfil` pode ser simultaneamente `ADMIN` e `GESTOR`.

## 6.3 Solução

```java
public boolean perfilPermitido(String perfil) {
    return "ADMIN".equals(perfil)
        || "GESTOR".equals(perfil);
}
```

Ou:

```java
private static final Set<String> PERFIS_PERMITIDOS =
    new HashSet<String>(
        Arrays.asList("ADMIN", "GESTOR")
    );

public boolean perfilPermitido(String perfil) {
    return PERFIS_PERMITIDOS.contains(perfil);
}
```

---

## 6.4 Exemplo vulnerável: faixa impossível

```java
public boolean idadeValida(int idade) {
    return idade < 18 && idade > 65;
}
```

Não existe idade menor que 18 e maior que 65 ao mesmo tempo.

## 6.5 Solução

Se a intenção era detectar idade fora da faixa:

```java
public boolean idadeInvalida(int idade) {
    return idade < 18 || idade > 65;
}
```

Se a intenção era validar faixa permitida:

```java
public boolean idadeValida(int idade) {
    return idade >= 18 && idade <= 65;
}
```

---

## 6.6 Exemplo vulnerável: status incompatíveis

```java
public boolean podeFinalizar(Processo processo) {
    return processo.getStatus() == Status.ABERTO
        && processo.getStatus() == Status.FINALIZADO;
}
```

## 6.7 Solução

```java
public boolean podeFinalizar(Processo processo) {
    return processo.getStatus() == Status.ABERTO
        && processo.isDocumentacaoCompleta();
}
```

Ou, quando há múltiplos status permitidos:

```java
public boolean statusPermiteEdicao(Status status) {
    return status == Status.RASCUNHO
        || status == Status.PENDENTE_AJUSTE;
}
```

---

## 6.8 Exemplo vulnerável: variável nunca alterada

```java
public void processar(List<Item> itens) {
    boolean existeErro = false;

    for (Item item : itens) {
        validar(item);
    }

    if (existeErro) {
        notificarFalha();
    }
}
```

A variável `existeErro` nunca muda para `true`.

## 6.9 Solução

```java
public void processar(List<Item> itens) {
    boolean existeErro = false;

    for (Item item : itens) {
        if (!validar(item)) {
            existeErro = true;
            registrarFalha(item);
        }
    }

    if (existeErro) {
        notificarFalha();
    }
}
```

Ou falhar imediatamente:

```java
for (Item item : itens) {
    validarOuFalhar(item);
}
```

---

# 7. CWE-571 — Expression is Always True

## 7.1 Conceito

A aplicação contém uma expressão que sempre será verdadeira.

Isso pode causar:

- autenticação sempre liberada;
- autorização sempre concedida;
- validação inútil;
- bloqueio nunca efetivo;
- exclusão sempre executada;
- fluxo de segurança contornado;
- teste falso positivo.

---

## 7.2 Exemplo vulnerável: condição tautológica

```java
public boolean perfilValido(String perfil) {
    return !"ADMIN".equals(perfil)
        || !"GESTOR".equals(perfil);
}
```

Essa expressão sempre será verdadeira.

## 7.3 Solução

Se a intenção é permitir ADMIN ou GESTOR:

```java
public boolean perfilValido(String perfil) {
    return "ADMIN".equals(perfil)
        || "GESTOR".equals(perfil);
}
```

Se a intenção é detectar perfil inválido:

```java
public boolean perfilInvalido(String perfil) {
    return !"ADMIN".equals(perfil)
        && !"GESTOR".equals(perfil);
}
```

---

## 7.4 Exemplo vulnerável: faixa sempre verdadeira

```java
public boolean idadeAceita(int idade) {
    return idade >= 18 || idade <= 65;
}
```

Para qualquer idade, pelo menos uma das condições será verdadeira.

Exemplos:

```text
10  → 10 <= 65
30  → 30 >= 18 e 30 <= 65
90  → 90 >= 18
```

## 7.5 Solução

```java
public boolean idadeAceita(int idade) {
    return idade >= 18 && idade <= 65;
}
```

---

## 7.6 Exemplo vulnerável: objeto sempre não nulo por construção

```java
public void salvar(UsuarioDTO dto) {
    Usuario usuario = new Usuario();

    if (usuario != null) {
        usuarioDAO.salvar(usuario);
    }
}
```

A condição não acrescenta segurança.

## 7.7 Solução

Validar o objeto que realmente veio de fora:

```java
public void salvar(UsuarioDTO dto) {
    if (dto == null) {
        throw new ValidacaoException(
            "Dados obrigatórios"
        );
    }

    Usuario usuario = mapper.toEntity(dto);
    usuarioDAO.salvar(usuario);
}
```

---

## 7.8 Exemplo vulnerável: default inseguro

```java
public boolean podeExcluir(Usuario usuario) {
    boolean autorizado = true;

    if (usuario == null) {
        autorizado = false;
    }

    return autorizado || usuario.isAdmin();
}
```

Quando `usuario` não é nulo, `autorizado` permanece `true`, então a expressão libera qualquer usuário.

## 7.9 Solução

```java
public boolean podeExcluir(Usuario usuario) {
    return usuario != null && usuario.isAdmin();
}
```

---

# 8. CWE-783 — Operator Precedence Logic Error

## 8.1 Conceito

A expressão usa operadores cuja precedência altera a lógica pretendida.

Em Java, `&&` tem precedência maior que `||`.

Logo:

```java
A || B && C
```

é interpretado como:

```java
A || (B && C)
```

e não como:

```java
(A || B) && C
```

---

## 8.2 Exemplo vulnerável: autorização

```java
public boolean podeAcessar(
        Usuario usuario,
        Documento documento) {

    return usuario.isAdmin()
        || usuario.isGestor()
        && documento.isDaUnidade(usuario.getUnidadeId());
}
```

### Problema

A expressão equivale a:

```java
return usuario.isAdmin()
    || (usuario.isGestor()
        && documento.isDaUnidade(usuario.getUnidadeId()));
```

Ou seja, administrador acessa qualquer documento. Isso pode ser correto ou não. Se a intenção era exigir documento da unidade para ambos, está vulnerável.

## 8.3 Solução

```java
public boolean podeAcessar(
        Usuario usuario,
        Documento documento) {

    return (usuario.isAdmin()
        || usuario.isGestor())
        && documento.isDaUnidade(
            usuario.getUnidadeId()
        );
}
```

Mais legível:

```java
boolean perfilPermitido =
    usuario.isAdmin() || usuario.isGestor();

boolean documentoDaUnidade =
    documento.isDaUnidade(
        usuario.getUnidadeId()
    );

return perfilPermitido && documentoDaUnidade;
```

---

## 8.4 Exemplo vulnerável: negação mal agrupada

```java
public boolean entradaInvalida(String valor) {
    return !(valor != null)
        && valor.trim().isEmpty();
}
```

Se `valor` for `null`, a segunda parte gera erro. Se não for `null`, a primeira é falsa.

## 8.5 Solução

```java
public boolean entradaInvalida(String valor) {
    return valor == null
        || valor.trim().isEmpty();
}
```

---

## 8.6 Exemplo vulnerável: cálculo financeiro mal expresso

```java
public BigDecimal calcularTotal(
        BigDecimal valor,
        BigDecimal multa,
        BigDecimal juros) {

    return valor.add(multa)
        .multiply(juros);
}
```

Se a intenção era:

```text
valor + multa + juros
```

o código está errado por encadeamento/precedência conceitual da expressão.

## 8.7 Solução

```java
public BigDecimal calcularTotal(
        BigDecimal valor,
        BigDecimal multa,
        BigDecimal juros) {

    return valor
        .add(multa)
        .add(juros);
}
```

Se a intenção era aplicar percentual:

```java
public BigDecimal calcularTotal(
        BigDecimal valor,
        BigDecimal percentualMulta,
        BigDecimal percentualJuros) {

    BigDecimal multa =
        valor.multiply(percentualMulta);

    BigDecimal juros =
        valor.multiply(percentualJuros);

    return valor.add(multa).add(juros);
}
```

---

# 9. Exemplos aplicados a sistemas Java web

## 9.1 Filtro de autenticação vulnerável

```java
public void doFilter(
        ServletRequest request,
        ServletResponse response,
        FilterChain chain)
        throws IOException, ServletException {

    HttpServletRequest http =
        (HttpServletRequest) request;

    HttpSession session =
        http.getSession(false);

    if (session != null
            || session.getAttribute("usuario") != null) {
        chain.doFilter(request, response);
        return;
    }

    ((HttpServletResponse) response)
        .sendError(HttpServletResponse.SC_UNAUTHORIZED);
}
```

### Problema

O operador correto deveria ser `&&`. Com `||`, quando `session` for `null`, a segunda parte causa `NullPointerException`.

## 9.2 Solução

```java
if (session != null
        && session.getAttribute("usuario") != null) {
    chain.doFilter(request, response);
    return;
}
```

---

## 9.3 Regra de permissão vulnerável

```java
public boolean podeAlterar(
        Usuario usuario,
        Registro registro) {

    return usuario.isAdmin()
        || usuario.isResponsavel()
        && registro.isAberto();
}
```

Se a intenção era exigir registro aberto para qualquer perfil:

```java
public boolean podeAlterar(
        Usuario usuario,
        Registro registro) {

    return (usuario.isAdmin()
        || usuario.isResponsavel())
        && registro.isAberto();
}
```

---

## 9.4 Validação de status vulnerável

```java
public void validarStatus(Status status) {
    if (status != Status.ABERTO
            || status != Status.PENDENTE) {
        throw new ValidacaoException(
            "Status inválido"
        );
    }
}
```

A expressão sempre lança exceção.

Solução:

```java
public void validarStatus(Status status) {
    if (status != Status.ABERTO
            && status != Status.PENDENTE) {
        throw new ValidacaoException(
            "Status inválido"
        );
    }
}
```

Mais legível:

```java
private static final Set<Status> STATUS_PERMITIDOS =
    EnumSet.of(Status.ABERTO, Status.PENDENTE);

public void validarStatus(Status status) {
    if (!STATUS_PERMITIDOS.contains(status)) {
        throw new ValidacaoException(
            "Status inválido"
        );
    }
}
```

---

# 10. Componentes reutilizáveis

## 10.1 Política de autorização com nomes claros

```java
public final class AuthorizationPolicy {

    public boolean podeVisualizarDocumento(
            Usuario usuario,
            Documento documento) {

        if (usuario == null || documento == null) {
            return false;
        }

        boolean perfilPermitido =
            usuario.isAdmin()
            || usuario.isGestor()
            || usuario.isResponsavel();

        boolean mesmoTenant =
            documento.getTenantId()
                .equals(usuario.getTenantId());

        boolean documentoDaUnidade =
            documento.getUnidadeId()
                .equals(usuario.getUnidadeId());

        return perfilPermitido
            && mesmoTenant
            && documentoDaUnidade;
    }
}
```

## 10.2 Validador de status com `EnumSet`

```java
public final class StatusPolicy {

    private static final Set<Status> EDITAVEIS =
        EnumSet.of(
            Status.RASCUNHO,
            Status.PENDENTE_AJUSTE
        );

    public boolean podeEditar(Status status) {
        return EDITAVEIS.contains(status);
    }
}
```

## 10.3 Validação de faixa

```java
public final class RangeValidator {

    private RangeValidator() {
    }

    public static void requireBetween(
            int value,
            int min,
            int max,
            String fieldName) {

        if (value < min || value > max) {
            throw new ValidacaoException(
                fieldName + " fora da faixa permitida"
            );
        }
    }
}
```

## 10.4 Comparação segura de `BigDecimal`

```java
public final class MoneyRules {

    private MoneyRules() {
    }

    public static boolean maiorQueZero(
            BigDecimal value) {

        return value != null
            && value.compareTo(BigDecimal.ZERO) > 0;
    }

    public static boolean menorOuIgual(
            BigDecimal value,
            BigDecimal limit) {

        return value != null
            && limit != null
            && value.compareTo(limit) <= 0;
    }
}
```

---

# 11. Diferenças importantes

## 11.1 CWE-480 versus CWE-783

| Situação | CWE |
|---|---:|
| Operador errado foi usado | 480 |
| Operador correto foi usado, mas precedência mudou a intenção | 783 |
| `||` no lugar de `&&` | 480 |
| `A || B && C` quando se queria `(A || B) && C` | 783 |

## 11.2 CWE-570 versus CWE-571

| Situação | CWE |
|---|---:|
| Expressão nunca executa branch | 570 |
| Expressão sempre executa branch | 571 |
| `x < 0 && x > 10` | 570 |
| `x >= 0 || x <= 10` | 571 |

## 11.3 CWE-570/571 versus Dead Code

Expressões sempre falsas ou verdadeiras podem gerar código morto. Quando a causa raiz é a expressão lógica, mapear em CWE-570 ou CWE-571. Quando o foco é bloco inalcançável por outros motivos, pode se relacionar a CWE-561.

## 11.4 CWE-480 versus comparação de strings

Usar `==` para comparar `String` em Java pode ser visto como operador incorreto em sentido prático, especialmente se impacta autenticação, autorização ou validação.

---

# 12. Checklist de revisão

## 12.1 Operadores

- Há `=` dentro de `if` com boolean?
- Há `==` comparando `String`?
- Há `!=` com objetos?
- Há `||` onde a regra exige todos os critérios?
- Há `&&` onde a regra exige qualquer critério?
- Há `&` ou `|` com boolean?
- Há `!` aplicado ao termo errado?
- Há `compareTo(...) == -1`?
- Há `BigDecimal.equals` em regra monetária?
- Há mistura de `&&` e `||` sem parênteses?

## 12.2 Expressões sempre falsas

- A condição exige dois status mutuamente exclusivos?
- A condição exige duas roles exclusivas?
- A faixa numérica é impossível?
- A variável nunca é alterada?
- O branch nunca aparece em cobertura de testes?
- O código depende de valor constante?

## 12.3 Expressões sempre verdadeiras

- A validação usa `||` com negações?
- A faixa usa `>= min || <= max`?
- Existe default `autorizado = true`?
- A condição testa objeto recém-criado contra `null`?
- O teste de permissão sempre passa?
- O bloqueio depende de condição tautológica?

## 12.4 Precedência

- Existem `&&` e `||` na mesma linha?
- Existe ternário aninhado?
- Existe concatenação com ternário?
- Existe negação sobre expressão composta?
- Existem cálculos financeiros sem variáveis intermediárias?
- O significado é óbvio sem conhecer a tabela de precedência?

## 12.5 Segurança

- A expressão decide permissão?
- Decide autenticação?
- Decide liberação de ação administrativa?
- Decide filtro por tenant/unidade?
- Decide bloqueio de conta?
- Decide processamento financeiro?
- Decide status de workflow?
- Há testes para todos os perfis/status?

---

# 13. Comandos de busca no código

Os comandos abaixo servem para triagem e geram falsos positivos.

## 13.1 Mistura de `&&` e `||`

```bash
grep -RniE '&&.*\|\||\|\|.*&&' src/
```

## 13.2 Comparação de String com `==`

```bash
grep -RniE '==[[:space:]]*"|!="[^"]*"' src/
```

## 13.3 Operadores booleanos não curto-circuitados

```bash
grep -RniE '[^&]&[^&]|[^|]\|[^|]' src/
```

Revisar manualmente para separar casos de bitwise legítimos.

## 13.4 Comparação de `compareTo`

```bash
grep -RniE 'compareTo\(.*\)[[:space:]]*==[[:space:]]*-?1' src/
```

## 13.5 `BigDecimal.equals`

```bash
grep -RniE 'BigDecimal|\.equals\(new BigDecimal|\.equals\(.*BigDecimal' src/
```

## 13.6 Status/perfil com múltiplas negações

```bash
grep -RniE '!=.*\|\||!.*equals.*\|\||!=.*&&|!.*equals.*&&' src/
```

## 13.7 Atribuição booleana em condição

```bash
grep -RniE 'if[[:space:]]*\([^)]*=[^=]' src/
```

Revisar com cuidado porque pode capturar `>=`, `<=` ou expressões legítimas.

---

# 14. Testes sugeridos

## 14.1 Permissões

Para cada regra de permissão, testar:

1. usuário nulo;
2. usuário comum;
3. usuário gestor;
4. usuário admin;
5. recurso do mesmo tenant;
6. recurso de outro tenant;
7. recurso da mesma unidade;
8. recurso de outra unidade;
9. status aberto;
10. status fechado.

## 14.2 Status

1. status nulo;
2. status permitido 1;
3. status permitido 2;
4. status não permitido;
5. status finalizado;
6. status cancelado;
7. transição válida;
8. transição inválida.

## 14.3 Faixas

1. valor abaixo do mínimo;
2. valor igual ao mínimo;
3. valor no meio;
4. valor igual ao máximo;
5. valor acima do máximo;
6. valor negativo;
7. zero;
8. nulo, quando aplicável.

## 14.4 Strings e enums

1. `ADMIN`;
2. `admin`;
3. `GESTOR`;
4. `USUARIO`;
5. string nova com mesmo conteúdo;
6. string nula;
7. string vazia;
8. enum desconhecido.

## 14.5 BigDecimal

1. `10.0`;
2. `10.00`;
3. `0`;
4. `-1`;
5. valor acima do limite;
6. valor exatamente no limite;
7. valor com escala diferente;
8. nulo.

---

# 15. Exemplos de testes unitários

## 15.1 Perfil permitido

```java
@Test
public void devePermitirAdminOuGestor() {
    PerfilPolicy policy =
        new PerfilPolicy();

    assertTrue(policy.perfilPermitido("ADMIN"));
    assertTrue(policy.perfilPermitido("GESTOR"));
    assertFalse(policy.perfilPermitido("USUARIO"));
    assertFalse(policy.perfilPermitido(null));
}
```

## 15.2 Idade dentro da faixa

```java
@Test
public void idadeDeveEstarEntre18e65() {
    assertFalse(idadeAceita(17));
    assertTrue(idadeAceita(18));
    assertTrue(idadeAceita(40));
    assertTrue(idadeAceita(65));
    assertFalse(idadeAceita(66));
}
```

## 15.3 Precedência em autorização

```java
@Test
public void adminTambemDeveRespeitarUnidadeQuandoRegraExigir() {
    Usuario admin =
        usuarioAdminDaUnidade(10L);

    Documento documento =
        documentoDaUnidade(20L);

    assertFalse(
        policy.podeAcessar(admin, documento)
    );
}
```

## 15.4 BigDecimal

```java
@Test
public void valoresComEscalaDiferenteDevemSerNumericamenteIguais() {
    BigDecimal a =
        new BigDecimal("10.0");

    BigDecimal b =
        new BigDecimal("10.00");

    assertTrue(a.compareTo(b) == 0);
    assertFalse(a.equals(b));
}
```

---

# 16. Quadro de decisão rápida

| Evidência | CWE provável |
|---|---:|
| `if (autorizado = true)` | 480 e possivelmente 571 |
| `perfil == "ADMIN"` | 480 |
| `usuario != null || usuario.isAtivo()` | 480 |
| `perfil != ADMIN && perfil != GESTOR` usado para permitir | 480 ou 570 |
| `perfil != ADMIN || perfil != GESTOR` usado para negar | 571 |
| `idade < 18 && idade > 65` | 570 |
| `idade >= 18 || idade <= 65` | 571 |
| `status == ABERTO && status == FINALIZADO` | 570 |
| `admin || gestor && mesmaUnidade` sem parênteses | 783 |
| `compareTo(...) == -1` | 480 |
| `BigDecimal.equals` em valor monetário | 480 |
| `&` em vez de `&&` com null check | 480 |

---

# 17. Resumo para prova

## CWE-569

Categoria de problemas de expressão. Agrupa erros lógicos em operadores, condições sempre falsas, condições sempre verdadeiras e precedência.

## CWE-480

Uso de operador incorreto.

Exemplos:

- `||` no lugar de `&&`;
- `==` em `String`;
- `&` no lugar de `&&`;
- `compareTo(...) == -1`;
- atribuição booleana dentro de `if`.

## CWE-570

Expressão sempre falsa.

Exemplos:

- `idade < 18 && idade > 65`;
- `status == ABERTO && status == FINALIZADO`;
- `perfil == ADMIN && perfil == GESTOR`.

## CWE-571

Expressão sempre verdadeira.

Exemplos:

- `idade >= 18 || idade <= 65`;
- `perfil != ADMIN || perfil != GESTOR`;
- `if (autorizado = true)`.

## CWE-783

Erro de precedência de operadores.

Exemplo:

```java
admin || gestor && mesmaUnidade
```

é interpretado como:

```java
admin || (gestor && mesmaUnidade)
```

e não como:

```java
(admin || gestor) && mesmaUnidade
```

---

# 18. Recomendações práticas

1. Usar parênteses em expressões com `&&` e `||`.
2. Evitar expressões longas em `if`.
3. Nomear subcondições booleanas.
4. Mover regras críticas para métodos de política.
5. Usar `EnumSet` para status/perfis permitidos.
6. Usar `"CONST".equals(valor)` para strings.
7. Usar `compareTo < 0`, `== 0`, `> 0`, não `== -1`.
8. Usar `BigDecimal.compareTo` para valor monetário.
9. Testar combinações verdade/falso.
10. Tratar warnings de IDE, Sonar e compilador como sinais importantes.

---

# 19. Referências

## MITRE CWE

- [CWE-569 — Expression Issues](https://cwe.mitre.org/data/definitions/569.html)
- [CWE-480 — Use of Incorrect Operator](https://cwe.mitre.org/data/definitions/480.html)
- [CWE-570 — Expression is Always False](https://cwe.mitre.org/data/definitions/570.html)
- [CWE-571 — Expression is Always True](https://cwe.mitre.org/data/definitions/571.html)
- [CWE-783 — Operator Precedence Logic Error](https://cwe.mitre.org/data/definitions/783.html)

## Java

- [Java SE 8 — Operators](https://docs.oracle.com/javase/tutorial/java/nutsandbolts/operators.html)
- [Java SE 8 — Expressions, Statements, and Blocks](https://docs.oracle.com/javase/tutorial/java/nutsandbolts/expressions.html)
- [Java SE 8 — BigDecimal](https://docs.oracle.com/javase/8/docs/api/java/math/BigDecimal.html)
- [Java SE 8 — EnumSet](https://docs.oracle.com/javase/8/docs/api/java/util/EnumSet.html)

---

# 20. Conclusão

Erros de expressão são perigosos porque normalmente não parecem vulnerabilidades clássicas. Eles se apresentam como pequenos deslizes de lógica, mas podem desativar validações, liberar permissões, impedir bloqueios ou executar fluxos indevidos.

Os controles mais importantes são:

- clareza;
- parênteses explícitos;
- métodos com nome de regra;
- testes de combinações;
- revisão de operadores;
- uso de tipos adequados;
- análise estática;
- cobertura dos cenários negativos.

A regra central é:

> Expressões que controlam segurança ou regra de negócio devem ser simples, testadas em todas as combinações relevantes e escritas de modo que a intenção seja mais evidente que a precedência dos operadores.
