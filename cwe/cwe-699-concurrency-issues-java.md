# CWE-699 - Software Development

## Category: Concurrency Issues - CWE-557

> **Objetivo do material:** documentar, de forma prática, as fraquezas da categoria **Concurrency Issues**, pertencente à view **CWE-699 - Software Development**, usando exemplos em **Java** voltados para aplicações web, APIs REST, Struts/Servlet/JSP, serviços, DAOs, agendadores, processamento assíncrono e sistemas executados em application servers.

---

## 1. Visão geral

A categoria **CWE-557 - Concurrency Issues** agrupa fraquezas relacionadas ao uso concorrente de recursos compartilhados.

Em Java, uma falha de concorrência geralmente aparece quando duas ou mais execuções acessam o mesmo estado e pelo menos uma delas o modifica sem uma estratégia correta de coordenação.

O estado compartilhado pode estar em:

- campos `static` mutáveis;
- campos de instância de `Servlet`, `Filter`, `Action`, `Service` ou singleton;
- mapas e listas usados como cache;
- arquivos e diretórios;
- registros de banco de dados;
- filas, sockets e canais alternativos;
- contexto de usuário, tenant ou privilégio;
- formatadores, parsers e bibliotecas não thread-safe;
- recursos externos chamados por múltiplas threads;
- event loops de frameworks não bloqueantes.

### Ponto importante para prova

**Concorrência não significa apenas executar várias threads manualmente.**

Uma aplicação Java web normalmente já é concorrente, porque o servidor processa várias requisições simultaneamente usando um conjunto de threads. Portanto, um campo mutável em um `Servlet`, `Filter`, `Action` reutilizada, `Service` singleton ou componente compartilhado pode causar uma condição de corrida mesmo que o código nunca chame `new Thread()`.

### Impactos possíveis

Falhas desta categoria podem provocar:

- perda ou duplicidade de atualização;
- autorização aplicada ao usuário errado;
- vazamento de dados entre requisições;
- execução duplicada de pagamento ou processamento;
- corrupção de cache ou estado em memória;
- uso de arquivo diferente daquele que foi validado;
- negação de serviço;
- inconsistência de banco de dados;
- comportamento intermitente, difícil de reproduzir;
- bypass de regra de negócio;
- deadlock, starvation ou bloqueio de event loop.

---

## 2. Natureza da categoria e mapeamento

A **CWE-557** é uma **Category**, isto é, um agrupamento organizacional de fraquezas. Ela ajuda na navegação e no estudo, mas não representa, por si só, uma causa raiz específica.

Para registrar uma vulnerabilidade real, deve-se selecionar a CWE Base mais específica, por exemplo:

- **CWE-367** para uma operação TOCTOU;
- **CWE-663** para uso concorrente de função não reentrante;
- **CWE-820** quando não existe sincronização;
- **CWE-821** quando a sincronização existe, mas está incorreta;
- **CWE-1322** quando código bloqueante é executado em um event loop não bloqueante.

---

## 3. CWEs abordadas

| CWE | Nome | Aplicação prática em Java |
|---:|---|---|
| 364 | Signal Handler Race Condition | Aplicação direta limitada; analogias com callbacks assíncronos e shutdown hooks |
| 366 | Race Condition within a Thread | Acesso simultâneo a estado compartilhado em aplicações multithread |
| 367 | Time-of-check Time-of-use Race Condition | Validar e depois usar arquivo, registro ou estado que pode mudar |
| 368 | Context Switching Race Condition | Troca não atômica de contexto de usuário, tenant ou privilégio |
| 386 | Symbolic Name not Mapping to Correct Object | Path, link, alias ou nome que passa a apontar para outro objeto |
| 421 | Race Condition During Access to Alternate Channel | Canal temporário capturado por outro ator antes do usuário legítimo |
| 663 | Use of a Non-reentrant Function in a Concurrent Context | `SimpleDateFormat`, parser ou componente com estado interno compartilhado |
| 820 | Missing Synchronization | Recurso compartilhado sem qualquer sincronização |
| 821 | Incorrect Synchronization | Lock incorreto, incompleto, local demais ou aplicado ao objeto errado |
| 1058 | Multi-Thread Context with non-Final Static or Member Element | Campo mutável em `Servlet`, singleton, bean compartilhado ou classe utilitária |
| 1322 | Blocking Code in Single-threaded, Non-blocking Context | JDBC, I/O, `sleep()` ou computação pesada em event loop |

---

## 4. Conceitos fundamentais em Java

### 4.1 Atomicidade

Uma operação é atômica quando não pode ser observada parcialmente por outra execução.

A expressão abaixo não é uma única operação atômica:

```java
contador++;
```

Ela envolve, conceitualmente:

1. ler o valor;
2. somar um;
3. gravar o novo valor.

Duas threads podem ler o mesmo valor e sobrescrever o resultado uma da outra.

### 4.2 Visibilidade

Uma thread pode não enxergar imediatamente uma alteração feita por outra thread se não houver uma relação de sincronização adequada.

`volatile` ajuda na visibilidade, mas não torna operações compostas atômicas.

```java
private volatile int saldo;

public void debitar(int valor) {
    // Ainda vulnerável: verificar e alterar é uma operação composta.
    if (saldo >= valor) {
        saldo -= valor;
    }
}
```

### 4.3 Exclusão mútua

Apenas uma thread por vez pode executar a região protegida.

Mecanismos comuns:

- `synchronized`;
- `ReentrantLock`;
- `ReadWriteLock`;
- `Semaphore`;
- classes atômicas;
- coleções concorrentes;
- lock pessimista no banco;
- controle otimista com versão;
- operação SQL condicional e atômica.

### 4.4 Thread-safe não significa atomicidade de negócio

`ConcurrentHashMap` torna operações individuais seguras, mas uma sequência de operações pode continuar vulnerável.

```java
if (!map.containsKey(chave)) {
    map.put(chave, valor);
}
```

A solução é usar uma operação composta oferecida pela própria estrutura:

```java
map.putIfAbsent(chave, valor);
```

### 4.5 Transação não resolve automaticamente toda concorrência

Uma transação de banco de dados não garante que a regra abaixo seja segura:

```java
Pedido pedido = pedidoDAO.obter(idPedido);

if (pedido.getSituacao() == PENDENTE) {
    pedido.setSituacao(PROCESSADO);
    pedidoDAO.atualizar(pedido);
}
```

Duas transações podem ler `PENDENTE` antes de qualquer uma confirmar a atualização.

Soluções possíveis:

- coluna de versão e locking otimista;
- `SELECT ... FOR UPDATE` quando apropriado;
- `UPDATE` condicional;
- chave única;
- idempotency key;
- máquina de estados com transição atômica.

---

# 5. CWE-364 - Signal Handler Race Condition

## 5.1 Conceito

Ocorre quando um tratador de sinal executado de forma assíncrona introduz uma condição de corrida ao acessar estado compartilhado ou chamar funções que não são seguras nesse contexto.

Essa CWE é mais comum em C/C++ e sistemas que trabalham diretamente com sinais do sistema operacional.

### Aplicabilidade em Java

A aplicação direta é **baixa no Java padrão**, pois a linguagem não fornece uma API pública, portável e recomendada para manipulação genérica de sinais POSIX.

Há, porém, situações análogas:

- uso de APIs internas como `sun.misc.Signal`;
- `Runtime.addShutdownHook(...)` alterando estado compartilhado;
- callbacks assíncronos de biblioteca modificando recursos usados pelo fluxo principal;
- interrupções e cancelamentos que disparam limpeza concorrente;
- múltiplos shutdown hooks executados simultaneamente.

## 5.2 Exemplo vulnerável

```java
public class GerenciadorExportacao {

    private static OutputStream arquivoAtual;

    public static void iniciar(Path destino) throws IOException {
        arquivoAtual = Files.newOutputStream(destino);

        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            try {
                // O fluxo principal pode estar escrevendo ou fechando ao mesmo tempo.
                arquivoAtual.flush();
                arquivoAtual.close();
            } catch (IOException e) {
                // erro ignorado
            }
        }));
    }

    public static void escrever(byte[] dados) throws IOException {
        arquivoAtual.write(dados);
    }
}
```

Problemas:

- o shutdown hook pode executar enquanto outra thread escreve;
- o recurso pode ser fechado duas vezes;
- o campo pode estar `null` ou apontar para outro arquivo;
- múltiplos hooks podem ser executados concorrentemente;
- a limpeza faz operações complexas durante encerramento assíncrono.

## 5.3 Solução recomendada

Usar um objeto que controla explicitamente seu ciclo de vida e tornar a limpeza idempotente.

```java
public final class Exportacao implements AutoCloseable {

    private final OutputStream output;
    private final AtomicBoolean fechado = new AtomicBoolean(false);

    public Exportacao(Path destino) throws IOException {
        this.output = Files.newOutputStream(destino);
    }

    public synchronized void escrever(byte[] dados) throws IOException {
        if (fechado.get()) {
            throw new IllegalStateException("Exportação já encerrada");
        }

        output.write(dados);
    }

    @Override
    public synchronized void close() throws IOException {
        if (fechado.compareAndSet(false, true)) {
            output.flush();
            output.close();
        }
    }
}
```

Uso:

```java
try (Exportacao exportacao = new Exportacao(destino)) {
    exportacao.escrever(conteudo);
}
```

## 5.4 Orientação prática

Quando houver callback assíncrono de encerramento:

- evite lógica de negócio extensa;
- evite compartilhar recurso mutável sem coordenação;
- torne a operação de encerramento idempotente;
- não dependa da ordem de execução entre hooks;
- prefira lifecycle controlado pelo container/framework;
- não use APIs internas de sinal em código corporativo portável.

---

# 6. CWE-366 - Race Condition within a Thread

## 6.1 Conceito

Ocorre quando execuções concorrentes usam o mesmo recurso e uma delas observa ou altera o recurso enquanto ele está em estado inválido ou intermediário.

Apesar do nome oficial mencionar “within a thread”, o problema prático envolve o uso concorrente de recursos entre fluxos de execução.

## 6.2 Exemplo vulnerável: contador compartilhado

```java
public class LoginMetricsService {

    private int falhasDeLogin;

    public void registrarFalha() {
        falhasDeLogin++;
    }

    public int getFalhasDeLogin() {
        return falhasDeLogin;
    }
}
```

Se o serviço for singleton e várias requisições executarem `registrarFalha()`, atualizações podem ser perdidas.

## 6.3 Solução com operação atômica

```java
public class LoginMetricsService {

    private final AtomicLong falhasDeLogin = new AtomicLong();

    public void registrarFalha() {
        falhasDeLogin.incrementAndGet();
    }

    public long getFalhasDeLogin() {
        return falhasDeLogin.get();
    }
}
```

## 6.4 Exemplo vulnerável: saldo

```java
public class ContaService {

    private BigDecimal saldo = new BigDecimal("100.00");

    public boolean debitar(BigDecimal valor) {
        if (saldo.compareTo(valor) >= 0) {
            saldo = saldo.subtract(valor);
            return true;
        }

        return false;
    }
}
```

Duas threads podem validar o mesmo saldo e ambas debitar.

## 6.5 Solução em memória

```java
public class ContaService {

    private final ReentrantLock lock = new ReentrantLock();
    private BigDecimal saldo = new BigDecimal("100.00");

    public boolean debitar(BigDecimal valor) {
        lock.lock();
        try {
            if (saldo.compareTo(valor) < 0) {
                return false;
            }

            saldo = saldo.subtract(valor);
            return true;
        } finally {
            lock.unlock();
        }
    }
}
```

## 6.6 Solução preferível para saldo persistido

A regra deve ser aplicada atomicamente no banco:

```sql
UPDATE conta
   SET saldo = saldo - :valor
 WHERE id_conta = :idConta
   AND saldo >= :valor;
```

```java
int alterados = contaDAO.debitarSeHouverSaldo(idConta, valor);

if (alterados == 0) {
    throw new SaldoInsuficienteException();
}
```

### Por que é melhor?

Um lock em memória protege somente:

- uma JVM;
- uma instância da aplicação;
- um processo.

Em um cluster com dois servidores, cada JVM possui seu próprio lock. A consistência do dado persistido deve ser garantida no banco ou em um mecanismo distribuído adequado.

---

# 7. CWE-367 - Time-of-check Time-of-use Race Condition

## 7.1 Conceito

TOCTOU ocorre quando o sistema:

1. verifica uma propriedade;
2. existe uma janela de tempo;
3. usa o recurso;
4. o recurso pode ter mudado entre a verificação e o uso.

## 7.2 Exemplo vulnerável com arquivo

```java
public byte[] baixar(Path arquivo) throws IOException {
    if (!Files.exists(arquivo)) {
        throw new FileNotFoundException();
    }

    if (!Files.isRegularFile(arquivo)) {
        throw new SecurityException("Arquivo inválido");
    }

    // O arquivo pode ser substituído após as verificações.
    return Files.readAllBytes(arquivo);
}
```

Entre `isRegularFile()` e `readAllBytes()`, outro processo pode:

- substituir o arquivo;
- trocar o destino de um link simbólico;
- remover e recriar o caminho;
- alterar permissões ou conteúdo.

## 7.3 Solução com `SecureDirectoryStream`

Quando o provider do sistema de arquivos oferecer suporte, `SecureDirectoryStream` permite executar operações relativas a um diretório aberto, reduzindo ataques por troca de nome/link.

```java
public byte[] lerArquivoSeguro(Path diretorio, Path nome) throws IOException {
    try (DirectoryStream<Path> stream = Files.newDirectoryStream(diretorio)) {
        if (!(stream instanceof SecureDirectoryStream<Path> secureStream)) {
            throw new IOException("Filesystem sem suporte a SecureDirectoryStream");
        }

        Set<OpenOption> opcoes = Set.of(
                StandardOpenOption.READ,
                LinkOption.NOFOLLOW_LINKS
        );

        try (SeekableByteChannel channel = secureStream.newByteChannel(nome, opcoes)) {
            ByteArrayOutputStream output = new ByteArrayOutputStream();
            ByteBuffer buffer = ByteBuffer.allocate(8192);

            while (channel.read(buffer) != -1) {
                buffer.flip();
                output.write(buffer.array(), 0, buffer.limit());
                buffer.clear();
            }

            return output.toByteArray();
        }
    }
}
```

> A disponibilidade de `SecureDirectoryStream` depende do provider do sistema de arquivos. A aplicação deve definir uma estratégia segura quando não houver suporte.

## 7.4 Exemplo vulnerável no banco

```java
public void processarPagamento(Long idPagamento) {
    Pagamento pagamento = pagamentoDAO.obter(idPagamento);

    if (pagamento.getSituacao() != SituacaoPagamento.PENDENTE) {
        throw new RegraNegocioException("Pagamento já processado");
    }

    gateway.cobrar(pagamento);

    pagamento.setSituacao(SituacaoPagamento.PAGO);
    pagamentoDAO.atualizar(pagamento);
}
```

Duas requisições podem ler `PENDENTE` e cobrar duas vezes.

## 7.5 Solução com transição atômica

```java
public void processarPagamento(Long idPagamento) {
    int alterados = pagamentoDAO.reservarParaProcessamento(
            idPagamento,
            SituacaoPagamento.PENDENTE,
            SituacaoPagamento.EM_PROCESSAMENTO
    );

    if (alterados == 0) {
        throw new RegraNegocioException(
                "Pagamento inexistente ou já reservado por outro processamento"
        );
    }

    try {
        gateway.cobrar(idPagamento);
        pagamentoDAO.marcarComoPago(idPagamento);
    } catch (RuntimeException e) {
        pagamentoDAO.marcarComoFalha(idPagamento);
        throw e;
    }
}
```

SQL conceitual:

```sql
UPDATE pagamento
   SET situacao = 'EM_PROCESSAMENTO'
 WHERE id_pagamento = :id
   AND situacao = 'PENDENTE';
```

## 7.6 Regra prática

Evite:

```text
CHECK -> intervalo -> USE
```

Prefira:

```text
CHECK + USE em uma operação atômica
```

ou:

```text
reservar estado -> executar -> concluir estado
```

---

# 8. CWE-368 - Context Switching Race Condition

## 8.1 Conceito

Ocorre quando a troca entre contextos que atravessam limites de segurança é composta por várias etapas não atômicas. Durante a troca, outra execução pode observar, modificar ou usar uma combinação incorreta de contexto e privilégio.

Em Java corporativo, os contextos mais comuns são:

- usuário autenticado;
- perfil ou papel;
- unidade organizacional;
- tenant;
- banco/schema atual;
- credencial técnica;
- nível de sigilo;
- modo administrador/impersonação.

## 8.2 Exemplo vulnerável com contexto global

```java
public class ContextoExecucao {
    public static Usuario usuarioAtual;
    public static Long unidadeAtual;
}

public class RelatorioService {

    public byte[] gerar(Usuario usuario, Long unidade) {
        ContextoExecucao.usuarioAtual = usuario;
        ContextoExecucao.unidadeAtual = unidade;

        // Outra requisição pode alterar os campos neste intervalo.
        return gerarRelatorioInterno();
    }
}
```

Uma requisição pode gerar relatório com:

- usuário da requisição A;
- unidade da requisição B.

## 8.3 Solução preferível: contexto explícito e imutável

```java
public record ContextoExecucao(
        Long idUsuario,
        Long idUnidade,
        Set<String> permissoes
) {
    public ContextoExecucao {
        permissoes = Set.copyOf(permissoes);
    }
}
```

```java
public class RelatorioService {

    public byte[] gerar(ContextoExecucao contexto, FiltroRelatorio filtro) {
        validarPermissao(contexto, filtro);
        return gerarRelatorioInterno(contexto, filtro);
    }
}
```

## 8.4 Uso de `ThreadLocal`

`ThreadLocal` pode ser necessário em alguns frameworks, mas precisa ser limpo obrigatoriamente, pois application servers reutilizam threads.

### Vulnerável

```java
public void doFilter(
        ServletRequest request,
        ServletResponse response,
        FilterChain chain) throws IOException, ServletException {

    SecurityContextHolder.set(obterContexto(request));
    chain.doFilter(request, response);

    // Não limpa se ocorrer exceção.
}
```

### Corrigido

```java
public void doFilter(
        ServletRequest request,
        ServletResponse response,
        FilterChain chain) throws IOException, ServletException {

    try {
        SecurityContextHolder.set(obterContexto(request));
        chain.doFilter(request, response);
    } finally {
        SecurityContextHolder.clear();
    }
}
```

## 8.5 Cuidado com processamento assíncrono

Um `ThreadLocal` comum não é automaticamente propagado para outra thread.

```java
executor.submit(() -> {
    // O contexto pode estar ausente ou incorreto.
    gerarDocumento();
});
```

Prefira capturar um contexto imutável e passá-lo explicitamente:

```java
ContextoExecucao contexto = contextoService.obterContextoImutavel();

executor.submit(() -> gerarDocumento(contexto));
```

---

# 9. CWE-386 - Symbolic Name not Mapping to Correct Object

## 9.1 Conceito

O sistema usa um nome simbólico que parece constante, mas que pode passar a resolver para outro objeto ao longo do tempo.

Exemplos:

- link simbólico;
- junction/mount point;
- alias de arquivo;
- nome DNS alterado ou sujeito a rebinding;
- identificador lógico reapontado;
- path relativo dependente do diretório atual;
- chave de cache reutilizada para outro objeto.

## 9.2 Exemplo vulnerável

```java
public void salvarRelatorio(Path caminho, byte[] pdf) throws IOException {
    Path real = caminho.toRealPath();

    if (!real.startsWith(DIRETORIO_RELATORIOS)) {
        throw new SecurityException("Destino inválido");
    }

    // O nome pode ser reapontado depois da validação.
    Files.write(caminho, pdf);
}
```

Canonicalizar uma vez não impede, por si só, que o mapeamento do nome seja alterado antes do uso.

## 9.3 Solução para criação de arquivo

Use criação exclusiva e não siga links simbólicos:

```java
public void criarRelatorio(Path diretorio, String nome, byte[] pdf)
        throws IOException {

    Path destino = diretorio.resolve(nome).normalize();

    if (!destino.getParent().equals(diretorio.normalize())) {
        throw new SecurityException("Nome de arquivo inválido");
    }

    try (SeekableByteChannel channel = Files.newByteChannel(
            destino,
            StandardOpenOption.CREATE_NEW,
            StandardOpenOption.WRITE,
            LinkOption.NOFOLLOW_LINKS)) {

        channel.write(ByteBuffer.wrap(pdf));
    }
}
```

### Observação

A proteção depende do tipo de operação e do filesystem. Para operações críticas:

- trabalhe com handles/canais já abertos;
- prefira `SecureDirectoryStream` quando suportado;
- use `NOFOLLOW_LINKS`;
- evite validar um nome e reabri-lo várias vezes;
- crie arquivos temporários com API segura;
- use permissões restritivas;
- não derive paths diretamente de entrada externa.

## 9.4 Exemplo conceitual com DNS

Validar o IP de uma URL e depois abrir uma nova conexão pelo hostname pode permitir que uma nova resolução retorne outro endereço.

```java
InetAddress endereco = InetAddress.getByName(host);
validarEndereco(endereco);

// Nova resolução pode produzir destino diferente.
HttpClient.newHttpClient().send(
        HttpRequest.newBuilder(URI.create("https://" + host + "/dados")).build(),
        HttpResponse.BodyHandlers.ofString()
);
```

Esse cenário é especialmente relevante em proteção contra SSRF. A implementação deve assegurar que o destino efetivamente conectado é o destino validado e considerar redirects, múltiplos endereços DNS e mudanças de resolução.

---

# 10. CWE-421 - Race Condition During Access to Alternate Channel

## 10.1 Conceito

O sistema abre um canal alternativo para um usuário autorizado, mas outro ator consegue acessar ou capturar esse canal antes do usuário legítimo.

Exemplos de canal alternativo:

- porta temporária;
- código de pareamento;
- link de confirmação;
- fila ou tópico temporário;
- arquivo temporário;
- callback local;
- canal de recuperação;
- token de polling.

## 10.2 Exemplo vulnerável: pareamento pelo primeiro solicitante

```java
public class PareamentoService {

    private final Map<String, Long> codigos = new ConcurrentHashMap<>();

    public String gerarCodigo(Long idDispositivo) {
        String codigo = String.format("%06d", new SecureRandom().nextInt(1_000_000));
        codigos.put(codigo, idDispositivo);
        return codigo;
    }

    public Long reivindicar(String codigo) {
        // O primeiro ator que usar o código obtém o dispositivo.
        return codigos.remove(codigo);
    }
}
```

Problemas:

- código curto;
- o canal não está vinculado ao usuário autorizado;
- o primeiro solicitante vence a corrida;
- não há expiração nem limite de tentativas;
- `remove()` evita segundo uso, mas não garante legitimidade do primeiro uso.

## 10.3 Solução recomendada

Vincular o canal ao ator esperado e consumir a autorização atomicamente.

```java
public record PareamentoPendente(
        Long idDispositivo,
        Long idUsuarioEsperado,
        Instant expiraEm
) {
}
```

```java
public class PareamentoService {

    private final ConcurrentMap<String, PareamentoPendente> pendentes =
            new ConcurrentHashMap<>();

    public String gerar(Long idDispositivo, Long idUsuarioEsperado) {
        String token = gerarTokenSeguro();

        pendentes.put(token, new PareamentoPendente(
                idDispositivo,
                idUsuarioEsperado,
                Instant.now().plusSeconds(120)
        ));

        return token;
    }

    public Long confirmar(String token, Long idUsuarioAutenticado) {
        AtomicReference<Long> dispositivo = new AtomicReference<>();

        pendentes.compute(token, (chave, pendente) -> {
            if (pendente == null) {
                throw new SecurityException("Token inválido ou já utilizado");
            }

            if (Instant.now().isAfter(pendente.expiraEm())) {
                throw new SecurityException("Token expirado");
            }

            if (!pendente.idUsuarioEsperado().equals(idUsuarioAutenticado)) {
                throw new SecurityException("Token não pertence ao usuário");
            }

            dispositivo.set(pendente.idDispositivo());
            return null; // consumo atômico
        });

        return dispositivo.get();
    }

    private String gerarTokenSeguro() {
        byte[] bytes = new byte[32];
        new SecureRandom().nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }
}
```

### Controles adicionais

- TLS obrigatório;
- expiração curta;
- token de alta entropia;
- limite de tentativas;
- auditoria;
- vinculação ao usuário, sessão e finalidade;
- consumo único atômico;
- confirmação fora de banda quando necessário.

---

# 11. CWE-663 - Use of a Non-reentrant Function in a Concurrent Context

## 11.1 Conceito

Uma função não reentrante mantém ou modifica estado interno que pode ser corrompido quando há chamadas concorrentes.

Em Java, exemplos clássicos incluem:

- `SimpleDateFormat` compartilhado;
- `DecimalFormat` compartilhado;
- parsers com buffers internos mutáveis;
- `MessageDigest` reutilizado por várias threads;
- `Cipher` compartilhado;
- builders mutáveis estáticos;
- bibliotecas legadas que reutilizam estado interno.

## 11.2 Exemplo vulnerável com `SimpleDateFormat`

```java
public final class DataUtil {

    private static final SimpleDateFormat FORMATO =
            new SimpleDateFormat("dd/MM/yyyy");

    private DataUtil() {
    }

    public static Date converter(String texto) throws ParseException {
        return FORMATO.parse(texto);
    }
}
```

`SimpleDateFormat` possui estado interno mutável e não deve ser compartilhado entre threads sem proteção.

## 11.3 Solução recomendada com API moderna

```java
public final class DataUtil {

    private static final DateTimeFormatter FORMATO =
            DateTimeFormatter.ofPattern("dd/MM/uuuu")
                    .withResolverStyle(ResolverStyle.STRICT);

    private DataUtil() {
    }

    public static LocalDate converter(String texto) {
        return LocalDate.parse(texto, FORMATO);
    }
}
```

`DateTimeFormatter` é imutável e thread-safe.

## 11.4 Exemplo vulnerável com `MessageDigest`

```java
public class HashService {

    private final MessageDigest digest;

    public HashService() throws NoSuchAlgorithmException {
        this.digest = MessageDigest.getInstance("SHA-256");
    }

    public byte[] calcular(byte[] dados) {
        return digest.digest(dados);
    }
}
```

Se o serviço for compartilhado, chamadas concorrentes podem interferir no estado do digest.

## 11.5 Solução

Criar uma instância por operação:

```java
public class HashService {

    public byte[] calcular(byte[] dados) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return digest.digest(dados);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 indisponível", e);
        }
    }
}
```

### Alternativas

- instância local por chamada;
- `ThreadLocal`, somente quando justificado e corretamente limpo;
- pool próprio, se o custo for comprovadamente relevante;
- sincronização ao redor do objeto, aceitando o custo de serialização;
- API imutável/thread-safe.

---

# 12. CWE-820 - Missing Synchronization

## 12.1 Conceito

O produto usa um recurso compartilhado concorrentemente, mas não tenta sincronizar o acesso.

## 12.2 Exemplo vulnerável: cache compartilhado

```java
public class PerfilCache {

    private final Map<Long, Perfil> cache = new HashMap<>();

    public Perfil obter(Long idUsuario) {
        Perfil perfil = cache.get(idUsuario);

        if (perfil == null) {
            perfil = carregarDoBanco(idUsuario);
            cache.put(idUsuario, perfil);
        }

        return perfil;
    }
}
```

Problemas:

- `HashMap` não é thread-safe;
- duas threads podem carregar e gravar simultaneamente;
- a estrutura pode entrar em estado inconsistente;
- o objeto `Perfil` também pode ser mutável.

## 12.3 Solução com `ConcurrentHashMap`

```java
public class PerfilCache {

    private final ConcurrentMap<Long, Perfil> cache =
            new ConcurrentHashMap<>();

    public Perfil obter(Long idUsuario) {
        return cache.computeIfAbsent(idUsuario, this::carregarDoBanco);
    }
}
```

### Atenção

A função passada para `computeIfAbsent` deve:

- ser curta;
- não alterar o mesmo mapa recursivamente;
- não depender de efeitos colaterais frágeis;
- tratar falhas de carregamento;
- evitar bloqueio demorado quando o mapa estiver no caminho crítico.

## 12.4 Exemplo vulnerável: check-then-act

```java
if (!idsProcessados.contains(id)) {
    processar(id);
    idsProcessados.add(id);
}
```

Mesmo com uma coleção sincronizada, a sequência pode não ser atômica.

## 12.5 Solução

```java
Set<Long> idsProcessados = ConcurrentHashMap.newKeySet();

if (idsProcessados.add(id)) {
    processar(id);
}
```

O próprio retorno de `add()` indica se o identificador foi inserido pela primeira vez.

## 12.6 Quando usar qual mecanismo

| Necessidade | Mecanismo possível |
|---|---|
| Contador | `AtomicLong`, `LongAdder` |
| Mapa compartilhado | `ConcurrentHashMap` |
| Conjunto compartilhado | `ConcurrentHashMap.newKeySet()` |
| Região crítica pequena | `synchronized` |
| Lock com timeout/interrupção | `ReentrantLock` |
| Muitas leituras e poucas escritas | `ReadWriteLock` ou estrutura imutável |
| Limitar concorrência | `Semaphore` |
| Coordenar fases | `CountDownLatch`, `CyclicBarrier`, `Phaser` |
| Estado persistido | transação, lock/versão/constraint no banco |
| Execução única distribuída | coordenação distribuída ou garantia no banco |

---

# 13. CWE-821 - Incorrect Synchronization

## 13.1 Conceito

Aqui existe uma tentativa de sincronização, mas ela é aplicada de forma incorreta.

Diferença resumida:

- **CWE-820:** não há sincronização;
- **CWE-821:** há sincronização, mas ela não protege corretamente o recurso ou a operação.

## 13.2 Exemplo vulnerável: lock criado a cada chamada

```java
public void atualizarSaldo(Long idConta, BigDecimal valor) {
    Object lock = new Object();

    synchronized (lock) {
        // Cada chamada possui um lock diferente.
        contaDAO.atualizarSaldo(idConta, valor);
    }
}
```

Esse `synchronized` não coordena chamadas diferentes.

## 13.3 Exemplo vulnerável: lock da instância protegendo estado estático

```java
public class SequenciaService {

    private static long sequencia;

    public synchronized long proximo() {
        return ++sequencia;
    }
}
```

Se houver duas instâncias de `SequenciaService`, cada instância terá seu próprio monitor, mas ambas alterarão o mesmo campo `static`.

## 13.4 Correção

```java
public class SequenciaService {

    private static final AtomicLong SEQUENCIA = new AtomicLong();

    public long proximo() {
        return SEQUENCIA.incrementAndGet();
    }
}
```

ou:

```java
public class SequenciaService {

    private static long sequencia;

    public static synchronized long proximo() {
        return ++sequencia;
    }
}
```

## 13.5 Exemplo vulnerável: proteção incompleta

```java
public class Carrinho {

    private final Object lock = new Object();
    private final List<Item> itens = new ArrayList<>();

    public void adicionar(Item item) {
        synchronized (lock) {
            itens.add(item);
        }
    }

    public BigDecimal calcularTotal() {
        // Leitura sem o mesmo lock.
        return itens.stream()
                .map(Item::getValor)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}
```

## 13.6 Correção

```java
public BigDecimal calcularTotal() {
    synchronized (lock) {
        return itens.stream()
                .map(Item::getValor)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}
```

Outra opção é retornar snapshots imutáveis e impedir exposição da coleção interna.

## 13.7 Problemas frequentes

- usar locks diferentes para o mesmo estado;
- bloquear escrita, mas não leitura;
- fazer validação fora do lock;
- liberar o lock antes de concluir a operação composta;
- sincronizar apenas na JVM quando há várias instâncias;
- manter lock durante chamada remota lenta;
- ordem diferente de aquisição de locks, causando deadlock;
- esquecer `unlock()` em caso de exceção;
- bloquear em string pública ou objeto acessível externamente.

### Uso correto de `ReentrantLock`

```java
lock.lock();
try {
    executarRegiaoCritica();
} finally {
    lock.unlock();
}
```

### Evite

```java
synchronized ("PAGAMENTO") {
    // String internada pode ser usada como lock por código não relacionado.
}
```

Prefira:

```java
private final Object pagamentoLock = new Object();
```

---

# 14. CWE-1058 - Invokable Control Element in Multi-Thread Context with non-Final Static Storable or Member Element

## 14.1 Conceito

O código contém um método executado em ambiente multithread, mas a classe possui campo `static` ou de instância mutável e inseguro.

Essa CWE é muito relevante para Java web.

Por padrão, podem ser compartilhados entre requisições:

- instância de `Servlet`;
- `Filter`;
- bean singleton do Spring;
- `@ApplicationScoped`;
- EJB stateless gerenciado pelo container;
- utilitário com campos `static`;
- Action reutilizada, conforme configuração/framework;
- listener e agendador.

## 14.2 Exemplo vulnerável em Servlet

```java
public class RelatorioServlet extends HttpServlet {

    private Long usuarioAtual;
    private String numeroProcedimento;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        usuarioAtual = obterUsuario(request);
        numeroProcedimento = request.getParameter("numero");

        gerarRelatorio(usuarioAtual, numeroProcedimento, response);
    }
}
```

Enquanto uma requisição está executando, outra pode sobrescrever os campos.

Resultado possível:

- relatório do procedimento A enviado ao usuário B;
- auditoria com identificador errado;
- autorização feita com contexto de outra requisição.

## 14.3 Correção

Variáveis específicas da requisição devem ser locais:

```java
public class RelatorioServlet extends HttpServlet {

    private final RelatorioService relatorioService;

    public RelatorioServlet(RelatorioService relatorioService) {
        this.relatorioService = Objects.requireNonNull(relatorioService);
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        Long usuarioAtual = obterUsuario(request);
        String numeroProcedimento = request.getParameter("numero");

        relatorioService.gerar(
                usuarioAtual,
                numeroProcedimento,
                response.getOutputStream()
        );
    }
}
```

O campo de dependência é `final` e o estado da requisição permanece local.

## 14.4 Exemplo vulnerável em serviço singleton

```java
@Service
public class ImportacaoService {

    private String ultimoErro;
    private int percentual;

    public void importar(Arquivo arquivo) {
        percentual = 0;
        ultimoErro = null;
        // processamento...
    }
}
```

Importações simultâneas compartilham o mesmo estado.

## 14.5 Correção

Criar um estado por execução:

```java
public record ResultadoImportacao(
        int percentual,
        List<String> erros
) {
    public ResultadoImportacao {
        erros = List.copyOf(erros);
    }
}
```

```java
@Service
public class ImportacaoService {

    public ResultadoImportacao importar(Arquivo arquivo) {
        int percentual = 0;
        List<String> erros = new ArrayList<>();

        // processamento com estado local

        return new ResultadoImportacao(percentual, erros);
    }
}
```

## 14.6 Regra prática

Em componentes compartilhados:

- dependências podem ser campos `final`;
- configuração deve ser preferencialmente imutável;
- estado por requisição deve ser variável local ou objeto próprio;
- caches devem usar estrutura thread-safe e política clara;
- não guarde usuário atual, request, response ou formulário em campo da classe.

---

# 15. CWE-1322 - Use of Blocking Code in Single-threaded, Non-blocking Context

## 15.1 Conceito

O sistema executa uma operação bloqueante em um contexto projetado para processar eventos de forma não bloqueante, normalmente com uma única thread ou pequeno conjunto de event loops.

Uma chamada bloqueante paralisa a thread responsável por muitas conexões, podendo causar:

- aumento extremo de latência;
- timeout em cascata;
- indisponibilidade;
- esgotamento de filas;
- negação de serviço com poucas requisições.

## 15.2 Exemplos de operações bloqueantes

- JDBC tradicional;
- `Files.readAllBytes()`;
- `InputStream.read()`;
- cliente HTTP síncrono;
- `Thread.sleep()`;
- `Future.get()`;
- espera por lock;
- geração pesada de PDF;
- criptografia/compressão custosa;
- consulta DNS síncrona;
- processamento de imagem.

## 15.3 Exemplo vulnerável em Spring WebFlux

```java
@GetMapping("/relatorios/{id}")
public Mono<byte[]> gerar(@PathVariable Long id) {
    return Mono.just(relatorioService.gerarPdf(id));
}
```

`Mono.just(...)` avalia o argumento imediatamente. Se `gerarPdf()` consulta banco, lê arquivos ou gera um PDF pesado, a operação bloqueia a thread que chamou o método.

## 15.4 Correção com offload controlado

```java
@GetMapping("/relatorios/{id}")
public Mono<byte[]> gerar(@PathVariable Long id) {
    return Mono.fromCallable(() -> relatorioService.gerarPdf(id))
            .subscribeOn(Schedulers.boundedElastic());
}
```

### Observação

Mover código bloqueante para `boundedElastic` reduz o impacto no event loop, mas não transforma a operação em verdadeiramente não bloqueante.

A solução arquitetural mais adequada pode exigir:

- driver de banco reativo;
- cliente HTTP assíncrono;
- streaming;
- fila de processamento;
- job assíncrono com consulta de status;
- executor dedicado e limitado;
- timeout e cancelamento.

## 15.5 Exemplo vulnerável com `CompletableFuture`

```java
public CompletableFuture<Resultado> consultar() {
    return CompletableFuture.supplyAsync(() -> {
        return consultaLenta();
    });
}
```

Sem executor explícito, a tarefa usa geralmente o `ForkJoinPool.commonPool()`, que pode também servir outras partes da aplicação.

## 15.6 Correção

```java
public class ConsultaAssincronaService {

    private final ExecutorService executor = new ThreadPoolExecutor(
            4,
            8,
            60,
            TimeUnit.SECONDS,
            new ArrayBlockingQueue<>(100),
            new ThreadPoolExecutor.AbortPolicy()
    );

    public CompletableFuture<Resultado> consultar() {
        return CompletableFuture.supplyAsync(this::consultaLenta, executor)
                .orTimeout(10, TimeUnit.SECONDS);
    }
}
```

Em application server, prefira executores gerenciados pelo container quando aplicável, em vez de criar threads diretamente.

## 15.7 Proteções importantes

- limite de threads;
- fila limitada;
- política explícita de rejeição;
- timeout;
- cancelamento;
- bulkhead;
- circuit breaker;
- métricas de fila e latência;
- não realizar operação pesada no event loop;
- não chamar `.block()` em fluxo reativo.

---

# 16. Diferenças entre CWEs próximas

## 16.1 CWE-366, CWE-820 e CWE-821

| CWE | Pergunta principal |
|---:|---|
| 366 | O comportamento incorreto resulta de uma corrida durante uso concorrente? |
| 820 | O recurso compartilhado não possui nenhuma sincronização? |
| 821 | Existe sincronização, mas ela está errada ou incompleta? |

Exemplo:

```java
contador++;
```

- pode produzir uma **race condition**: CWE-366;
- se não existe qualquer proteção: CWE-820;
- se existe `synchronized` em objeto diferente a cada chamada: CWE-821.

O mapeamento deve priorizar a causa raiz mais específica observada.

## 16.2 CWE-367 e CWE-386

- **CWE-367:** existe uma janela entre verificar e usar;
- **CWE-386:** um nome simbólico pode resolver para objeto diferente.

Um ataque com link simbólico pode combinar as duas fraquezas:

1. aplicação valida o path;
2. atacante troca o link;
3. path passa a apontar para outro arquivo;
4. aplicação usa o novo destino.

## 16.3 CWE-663 e CWE-1058

- **CWE-663:** uma função/componente não reentrante é chamado concorrentemente;
- **CWE-1058:** a classe executada em ambiente multithread possui estado mutável compartilhado inseguro.

Um `SimpleDateFormat static` compartilhado pode se encaixar nos dois conceitos, mas CWE-663 descreve melhor a natureza da função não reentrante.

## 16.4 CWE-1322 e concorrência tradicional

CWE-1322 não exige corrupção de dados. O problema principal é bloquear uma thread que deveria permanecer disponível para o event loop, causando impacto de disponibilidade e escalabilidade.

---

# 17. Padrões Java recomendados

## 17.1 Estado imutável

```java
public record UsuarioContexto(
        Long id,
        String login,
        Set<String> perfis
) {
    public UsuarioContexto {
        perfis = Set.copyOf(perfis);
    }
}
```

Objetos imutáveis podem ser compartilhados com menor risco.

## 17.2 Atualização atômica

```java
private final AtomicReference<Configuracao> configuracao =
        new AtomicReference<>(Configuracao.padrao());

public void atualizar(UnaryOperator<Configuracao> alteracao) {
    configuracao.updateAndGet(alteracao);
}
```

## 17.3 Snapshot imutável

```java
public class PermissaoCache {

    private volatile Map<Long, Set<String>> snapshot = Map.of();

    public Set<String> obter(Long idUsuario) {
        return snapshot.getOrDefault(idUsuario, Set.of());
    }

    public void recarregar(Map<Long, Set<String>> novosDados) {
        Map<Long, Set<String>> copia = novosDados.entrySet().stream()
                .collect(Collectors.toUnmodifiableMap(
                        Map.Entry::getKey,
                        entrada -> Set.copyOf(entrada.getValue())
                ));

        snapshot = copia;
    }
}
```

O novo mapa é construído separadamente e publicado de uma única vez.

## 17.4 Lock por chave

Em alguns cenários, serializar todas as operações em um único lock reduz demais a concorrência.

```java
public class LockPorConta {

    private final ConcurrentMap<Long, ReentrantLock> locks =
            new ConcurrentHashMap<>();

    public void executar(Long idConta, Runnable acao) {
        ReentrantLock lock = locks.computeIfAbsent(
                idConta,
                chave -> new ReentrantLock()
        );

        lock.lock();
        try {
            acao.run();
        } finally {
            lock.unlock();
        }
    }
}
```

### Cuidado

Esse exemplo requer política para remoção segura de locks e continua limitado a uma JVM. Para dado persistido em cluster, prefira garantia no banco ou coordenação distribuída apropriada.

## 17.5 Controle otimista com versão

```java
@Entity
public class Pedido {

    @Id
    private Long id;

    @Version
    private Long versao;

    @Enumerated(EnumType.STRING)
    private SituacaoPedido situacao;
}
```

Quando duas transações alteram a mesma versão, uma deve falhar e ser tratada de maneira explícita.

## 17.6 Constraint como última linha de defesa

Para garantir unicidade:

```sql
ALTER TABLE processamento
ADD CONSTRAINT uk_processamento_chave UNIQUE (chave_idempotencia);
```

Mesmo que duas requisições passem por validações simultâneas, apenas uma gravação será aceita.

---

# 18. Antipadrões frequentes

## 18.1 `volatile` usado como solução universal

```java
private volatile int contador;

public void incrementar() {
    contador++;
}
```

`volatile` garante visibilidade, mas `contador++` continua não atômico.

## 18.2 `Collections.synchronizedList()` com iteração sem lock

```java
List<String> lista = Collections.synchronizedList(new ArrayList<>());

for (String item : lista) {
    processar(item);
}
```

A iteração precisa ser protegida externamente ou realizada sobre snapshot.

```java
List<String> snapshot;

synchronized (lista) {
    snapshot = List.copyOf(lista);
}

for (String item : snapshot) {
    processar(item);
}
```

## 18.3 Double-checked locking sem publicação segura

Evite implementar singleton manualmente quando o problema pode ser resolvido por inicialização estática segura.

```java
public final class ConfiguracaoGlobal {

    private ConfiguracaoGlobal() {
    }

    private static class Holder {
        private static final ConfiguracaoGlobal INSTANCE =
                new ConfiguracaoGlobal();
    }

    public static ConfiguracaoGlobal getInstance() {
        return Holder.INSTANCE;
    }
}
```

## 18.4 Lock abrangendo chamada remota

```java
synchronized (lock) {
    gateway.externo().enviar(dados);
}
```

A chamada pode demorar, travar ou chamar de volta o sistema. Avalie separar:

1. reserva atômica do estado;
2. chamada externa fora do lock;
3. conclusão atômica.

## 18.5 Criar threads diretamente em application server

```java
new Thread(this::processar).start();
```

Em ambiente gerenciado, isso pode ignorar:

- lifecycle do container;
- contexto de segurança;
- classloader;
- transação;
- limites de recursos;
- monitoramento.

Prefira recursos gerenciados, scheduler do framework ou fila.

## 18.6 Guardar request em campo

```java
public class MinhaAction {
    private HttpServletRequest requestAtual;
}
```

Estado de requisição não deve ser compartilhado em componente reutilizado.

---

# 19. Exemplo integrado: processamento idempotente e concorrente

## 19.1 Requisito

Uma solicitação deve ser processada uma única vez, mesmo que:

- o usuário clique duas vezes;
- o frontend repita a chamada;
- o proxy faça retry;
- duas instâncias da aplicação recebam a mesma chave.

## 19.2 Implementação vulnerável

```java
public void executar(String chave) {
    if (processamentoDAO.existe(chave)) {
        return;
    }

    executarRegra();
    processamentoDAO.salvar(chave);
}
```

Há TOCTOU: duas execuções podem observar que a chave não existe.

## 19.3 Solução

```java
public Resultado executar(String chave) {
    boolean reservado = processamentoDAO.reservar(chave);

    if (!reservado) {
        return processamentoDAO.obterResultado(chave);
    }

    try {
        Resultado resultado = executarRegra();
        processamentoDAO.concluir(chave, resultado);
        return resultado;
    } catch (RuntimeException e) {
        processamentoDAO.registrarFalha(chave, e.getMessage());
        throw e;
    }
}
```

A reserva deve usar uma operação atômica/constraint:

```sql
INSERT INTO processamento (
    chave_idempotencia,
    situacao,
    data_inicio
) VALUES (
    :chave,
    'EM_PROCESSAMENTO',
    CURRENT_TIMESTAMP
)
ON CONFLICT (chave_idempotencia) DO NOTHING;
```

> A sintaxe exata depende do banco utilizado.

---

# 20. Testes de concorrência

## 20.1 Teste com início coordenado

```java
@Test
void deveProcessarSomenteUmaVez() throws Exception {
    int quantidade = 20;
    ExecutorService executor = Executors.newFixedThreadPool(quantidade);
    CountDownLatch prontos = new CountDownLatch(quantidade);
    CountDownLatch iniciar = new CountDownLatch(1);

    List<Future<Boolean>> resultados = new ArrayList<>();

    for (int i = 0; i < quantidade; i++) {
        resultados.add(executor.submit(() -> {
            prontos.countDown();
            iniciar.await();
            return service.tentarProcessar("CHAVE-123");
        }));
    }

    assertTrue(prontos.await(5, TimeUnit.SECONDS));
    iniciar.countDown();

    long sucessos = 0;
    for (Future<Boolean> resultado : resultados) {
        if (resultado.get(10, TimeUnit.SECONDS)) {
            sucessos++;
        }
    }

    assertEquals(1, sucessos);
    executor.shutdownNow();
}
```

## 20.2 O que testar

- duas requisições alterando o mesmo registro;
- várias requisições com usuários diferentes no mesmo Servlet/Action;
- processamento repetido com a mesma chave;
- atualização simultânea de cache;
- expiração e consumo simultâneo de token;
- leitura enquanto configuração é recarregada;
- timeout durante lock;
- falha após reserva e antes de conclusão;
- execução em duas instâncias da aplicação;
- comportamento sob carga elevada.

## 20.3 Teste não prova ausência de corrida

Condições de corrida dependem de escalonamento e tempo. Um teste passar várias vezes não prova que o código é seguro.

A avaliação deve combinar:

- raciocínio sobre atomicidade e visibilidade;
- análise estática;
- teste de carga;
- teste repetido;
- revisão de transações e constraints;
- observabilidade em produção.

---

# 21. Revisão de código

## 21.1 Comandos de busca inicial

```bash
grep -RIn "static.*HashMap\|static.*ArrayList" src/
grep -RIn "SimpleDateFormat\|DecimalFormat" src/
grep -RIn "new Thread\|Executors\.new" src/
grep -RIn "Thread\.sleep\|\.get()\|\.join()\|\.block()" src/
grep -RIn "synchronized\|ReentrantLock\|ReadWriteLock" src/
grep -RIn "ThreadLocal" src/
grep -RIn "Files\.exists\|Files\.isRegularFile\|toRealPath" src/
grep -RIn "containsKey.*put\|contains.*add" src/
grep -RIn "volatile" src/
grep -RIn "@Version\|FOR UPDATE" src/
```

Essas buscas não confirmam vulnerabilidade. Elas apenas ajudam a localizar pontos que precisam de revisão.

## 21.2 Perguntas para revisão

1. O componente é compartilhado entre requisições?
2. Há campo mutável de instância ou `static`?
3. Qual recurso é compartilhado?
4. Quem pode ler e escrever esse recurso?
5. A operação é simples ou composta?
6. Todas as leituras e escritas usam o mesmo mecanismo?
7. O lock funciona em cluster ou apenas nesta JVM?
8. O banco garante a regra por versão, constraint ou update condicional?
9. A operação pode ser repetida?
10. O código bloqueia event loop ou pool crítico?
11. Existe timeout?
12. O estado de usuário/tenant é limpo em `finally`?
13. O nome validado pode apontar para outro objeto depois?
14. Há biblioteca não thread-safe compartilhada?
15. A solução pode causar deadlock ou starvation?

---

# 22. Checklist prático

## Estado compartilhado

- [ ] Campos de requisição são variáveis locais.
- [ ] Dependências compartilhadas são imutáveis ou `final`.
- [ ] Não há `static` mutável sem justificativa e proteção.
- [ ] Objetos retornados por cache não podem ser alterados livremente.
- [ ] Coleções compartilhadas são adequadas ao padrão de acesso.

## Operações atômicas

- [ ] Sequências check-then-act foram eliminadas ou tornadas atômicas.
- [ ] Transições de estado usam `UPDATE` condicional, versão ou lock adequado.
- [ ] Unicidade importante é garantida também no banco.
- [ ] Operações repetíveis possuem chave de idempotência.
- [ ] Tokens de uso único são consumidos atomicamente.

## Sincronização

- [ ] O mesmo recurso usa o mesmo lock.
- [ ] Leitura e escrita estão cobertas quando necessário.
- [ ] `unlock()` está em `finally`.
- [ ] Não se usa string pública como monitor.
- [ ] O lock não envolve chamada remota demorada sem necessidade.
- [ ] A ordem de aquisição de múltiplos locks é consistente.

## Contexto

- [ ] Contexto de usuário/tenant não é armazenado em variável global.
- [ ] `ThreadLocal` é limpo em `finally`.
- [ ] Processamento assíncrono recebe contexto explicitamente.
- [ ] Impersonação e troca de privilégio são atômicas e auditadas.

## Arquivos e nomes simbólicos

- [ ] A aplicação não depende somente de `exists()` antes do uso.
- [ ] Links simbólicos são tratados explicitamente.
- [ ] Operações críticas usam handles/canais já abertos quando possível.
- [ ] Criação usa `CREATE_NEW` quando não pode sobrescrever.
- [ ] Paths externos são normalizados e limitados a diretório autorizado.

## Código não bloqueante

- [ ] Não há JDBC ou I/O síncrono no event loop.
- [ ] Não há `.block()`, `sleep()` ou espera sem timeout em fluxo reativo.
- [ ] Operações bloqueantes são encaminhadas a executor limitado.
- [ ] Filas possuem tamanho máximo.
- [ ] Há timeout, cancelamento e métricas.

---

# 23. Resumo para prova

| CWE | Ideia central | Exemplo Java | Correção típica |
|---:|---|---|---|
| 364 | Handler/callback assíncrono causa corrida | shutdown hook fechando recurso em uso | operação mínima, idempotente e coordenada |
| 366 | Execuções concorrentes usam estado inválido | `contador++`, débito simultâneo | atomicidade, lock ou garantia no banco |
| 367 | Recurso muda entre checagem e uso | `exists()` seguido de leitura | operação atômica, handle aberto, update condicional |
| 368 | Troca de contexto não atômica | usuário/tenant em campo global | contexto imutável e explícito |
| 386 | Nome passa a apontar para outro objeto | symlink/DNS/alias alterado | canal/handle validado, `NOFOLLOW_LINKS` |
| 421 | Outro ator captura canal alternativo | código de pareamento pelo primeiro solicitante | vínculo de identidade e consumo atômico |
| 663 | Função não reentrante é compartilhada | `SimpleDateFormat static` | API thread-safe ou instância local |
| 820 | Não existe sincronização | `HashMap` compartilhado | coleção concorrente, atomicidade ou lock |
| 821 | Sincronização está errada | lock local por chamada | lock estável e abrangência correta |
| 1058 | Campo mutável em componente multithread | campos de request em Servlet | variáveis locais e dependências `final` |
| 1322 | Código bloqueante trava event loop | JDBC/PDF em WebFlux | API assíncrona ou executor dedicado limitado |

---

# 24. Questões de revisão

1. Por que `volatile int contador` não torna `contador++` seguro?
2. Qual é a diferença entre CWE-820 e CWE-821?
3. Por que um lock Java pode ser insuficiente em aplicação com duas instâncias?
4. O que caracteriza uma falha TOCTOU?
5. Por que `Files.exists()` seguido de `Files.readAllBytes()` pode ser inseguro?
6. Por que `SimpleDateFormat static` é problemático em aplicação web?
7. Qual é o risco de armazenar `HttpServletRequest` em campo de Servlet?
8. Como uma constraint de banco ajuda na concorrência?
9. Qual é a função de uma chave de idempotência?
10. Por que `Mono.just(servico.metodoBloqueante())` não resolve o bloqueio?
11. Por que um `ThreadLocal` precisa ser limpo?
12. Quando `ConcurrentHashMap` não é suficiente para garantir regra de negócio?
13. Como distinguir atomicidade técnica de atomicidade da regra de negócio?
14. Por que a chamada externa não deve ficar sob lock sem avaliação?
15. Como testar uma operação que deve ocorrer uma única vez?

---

# 25. Respostas resumidas

1. Porque incremento é uma sequência de leitura, cálculo e escrita; `volatile` não torna a sequência atômica.
2. CWE-820 significa ausência de sincronização; CWE-821 significa sincronização existente, porém incorreta.
3. Cada JVM possui seus próprios objetos e locks; outra instância não participa do mesmo monitor.
4. Há uma verificação e depois um uso, com janela na qual o recurso pode mudar.
5. O arquivo ou link pode ser substituído entre as duas chamadas.
6. A classe possui estado interno mutável e não é thread-safe.
7. Requisições simultâneas podem sobrescrever o campo e misturar usuários/dados.
8. A constraint resolve a disputa no ponto comum a todas as instâncias: o banco.
9. Identificar uma operação lógica para que repetições retornem o mesmo resultado ou sejam rejeitadas.
10. O método é executado antes de o `Mono` ser construído.
11. Threads de pool são reutilizadas e podem carregar contexto para outra requisição.
12. Quando a regra envolve várias operações, outros sistemas, banco ou múltiplas instâncias.
13. Uma estrutura pode ser thread-safe, mas a sequência completa da regra ainda pode ser interrompida.
14. Pode bloquear outras execuções por tempo indeterminado e aumentar risco de deadlock/indisponibilidade.
15. Disparar várias execuções coordenadas e validar uma única reserva/efeito persistido.

---

# 26. Referências oficiais

- CWE-557 — Concurrency Issues: <https://cwe.mitre.org/data/definitions/557.html>
- CWE-364 — Signal Handler Race Condition: <https://cwe.mitre.org/data/definitions/364.html>
- CWE-366 — Race Condition within a Thread: <https://cwe.mitre.org/data/definitions/366.html>
- CWE-367 — Time-of-check Time-of-use Race Condition: <https://cwe.mitre.org/data/definitions/367.html>
- CWE-368 — Context Switching Race Condition: <https://cwe.mitre.org/data/definitions/368.html>
- CWE-386 — Symbolic Name not Mapping to Correct Object: <https://cwe.mitre.org/data/definitions/386.html>
- CWE-421 — Race Condition During Access to Alternate Channel: <https://cwe.mitre.org/data/definitions/421.html>
- CWE-663 — Use of a Non-reentrant Function in a Concurrent Context: <https://cwe.mitre.org/data/definitions/663.html>
- CWE-820 — Missing Synchronization: <https://cwe.mitre.org/data/definitions/820.html>
- CWE-821 — Incorrect Synchronization: <https://cwe.mitre.org/data/definitions/821.html>
- CWE-1058 — Invokable Control Element in Multi-Thread Context with non-Final Static Storable or Member Element: <https://cwe.mitre.org/data/definitions/1058.html>
- CWE-1322 — Use of Blocking Code in Single-threaded, Non-blocking Context: <https://cwe.mitre.org/data/definitions/1322.html>

---

## Conclusão

Falhas de concorrência surgem quando a aplicação faz suposições incorretas sobre exclusividade, ordem, atomicidade, visibilidade ou identidade do recurso utilizado.

Em Java corporativo, as medidas mais importantes são:

1. evitar estado mutável em componentes compartilhados;
2. manter contexto de requisição em variáveis locais ou objetos imutáveis;
3. usar operações atômicas, coleções concorrentes e locks com abrangência correta;
4. garantir regras persistentes também no banco de dados;
5. tratar explicitamente idempotência e transições de estado;
6. evitar check-then-act;
7. não compartilhar objetos não thread-safe;
8. não bloquear event loops;
9. testar concorrência de forma coordenada;
10. projetar a solução considerando múltiplas instâncias da aplicação.
