# CWE-699 — Software Development

## Category: Documentation Issues — CWE-1225

> **Objetivo:** apresentar uma documentação prática sobre falhas de documentação técnica que afetam segurança, manutenção e evolução de sistemas, com exemplos em **Java 8**, Struts/Servlet/JSP, APIs REST, Services, Facades, DAOs, integrações e rotinas batch/agendadas.

---

## 1. Visão geral

A categoria **CWE-1225 — Documentation Issues** agrupa fraquezas relacionadas à ausência, insuficiência ou inconsistência de documentação técnica.

Diferente de uma SQL Injection ou XSS, a falha aqui nem sempre aparece como uma linha de código vulnerável isolada. O problema surge quando a equipe não consegue entender corretamente:

- como o sistema foi desenhado;
- quais regras de segurança existem;
- quais fluxos são obrigatórios;
- quais entradas e saídas são aceitas;
- quais exceções devem ser tratadas;
- como programas, jobs e integrações são executados;
- quais decisões de design precisam ser preservadas;
- quais premissas não podem ser alteradas sem revisão.

Quando a documentação é ausente, incompleta ou contraditória, a manutenção tende a introduzir novas vulnerabilidades por interpretação errada do sistema.

---

## 2. Natureza da categoria

A **CWE-1225** é uma **Category**. Ela organiza fraquezas relacionadas à documentação, mas não deve ser usada diretamente para mapear uma vulnerabilidade real quando houver CWE Base mais específica.

Exemplos:

- design de autorização não documentado e endpoint novo fica sem checagem: pode se relacionar a **CWE-306** ou **CWE-862**, além de problema documental;
- documentação diz que o token expira em 15 minutos, mas o código aceita 24 horas: **CWE-1068** como inconsistência entre implementação e design documentado;
- documentação não descreve tratamento de exceções e o código passa a expor stack trace: pode se relacionar a falha de error handling e exposição de informação.

---

## 3. CWEs abordadas

| CWE | Nome | Ideia prática |
|---:|---|---|
| 1053 | Missing Documentation for Design | Não existe documentação que represente o design do produto |
| 1068 | Inconsistency Between Implementation and Documented Design | Código e documentação dizem coisas diferentes |
| 1110 | Incomplete Design Documentation | Documentação de design existe, mas faltam partes relevantes |
| 1111 | Incomplete I/O Documentation | Entradas e saídas não são completamente documentadas |
| 1112 | Incomplete Documentation of Program Execution | Execução de programas, jobs, scripts ou serviços não é bem documentada |
| 1118 | Insufficient Documentation of Error Handling Techniques | Tratamento de erros, exceções e falhas não é documentado adequadamente |

---

# 4. Por que documentação é uma questão de segurança

## 4.1 Segurança depende de intenção explícita

Código mostra o que acontece. Documentação de design explica o que deveria acontecer e por quê.

Sem essa intenção explícita, uma manutenção pode parecer correta localmente, mas quebrar uma regra de segurança global.

Exemplo:

```java
public Arquivo obterArquivo(Long codArquivo) {
    return arquivoDAO.obterPorId(codArquivo);
}
```

Esse método pode parecer correto, mas pode estar errado se a regra de design for:

> Todo arquivo sigiloso deve ser obtido pelo par `codArquivo + usuário logado + nível de acesso + procedimento vinculado`.

O design de autorização precisa estar documentado para evitar que alguém crie uma consulta aparentemente simples, mas insegura.

## 4.2 Documentação reduz ambiguidade

Ambiguidade comum em sistemas Java legados:

- Quem valida: Action, Facade, Service ou DAO?
- O DAO pode retornar dado não autorizado?
- O campo hidden pode ser confiado?
- A integração externa pode retornar erro parcial?
- O job pode ser executado simultaneamente?
- O método pode receber `null`?
- A exceção deve fazer rollback?
- O usuário pode repetir a operação?
- O endpoint é interno ou público?
- O arquivo fica no banco, disco, storage ou sistema externo?

A documentação prática deve responder a essas perguntas.

---

# 5. CWE-1053 — Missing Documentation for Design

## 5.1 Conceito

O produto não possui documentação que represente como foi projetado.

A equipe depende apenas de:

- leitura do código;
- memória de pessoas;
- comentários soltos;
- tickets antigos;
- comportamento observado em produção;
- nomes de métodos;
- tentativa e erro.

Isso aumenta o risco de mudanças inseguras.

## 5.2 Exemplo vulnerável: regra de autorização sem design documentado

### Código existente

```java
public class ArquivoAction extends DispatchAction {

    public ActionForward baixar(
            ActionMapping mapping,
            ActionForm form,
            HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        Long codArquivo = Long.valueOf(
            request.getParameter("codArquivo")
        );

        Arquivo arquivo = arquivoFacade.obter(codArquivo);

        escreverArquivo(response, arquivo);
        return null;
    }
}
```

### Problema

Não existe documentação informando:

- se o arquivo é público ou sigiloso;
- se o usuário precisa estar autenticado;
- se o arquivo pertence a um procedimento;
- se o perfil do usuário deve ser validado;
- se há níveis de sigilo;
- se o DAO já filtra autorização;
- se download deve gerar auditoria.

Um desenvolvedor pode concluir que basta consultar por `codArquivo`.

## 5.3 Solução: documentar o design da autorização

### Exemplo de documentação de design

```markdown
## Design de autorização para download de arquivos

Todo download de arquivo deve seguir o fluxo:

1. Identificar usuário autenticado.
2. Obter `codArquivo` do request.
3. Validar que o arquivo existe.
4. Validar vínculo do arquivo com o procedimento.
5. Validar que o usuário possui acesso ao procedimento.
6. Validar nível de sigilo do arquivo.
7. Registrar auditoria de download.
8. Retornar o arquivo sem expor caminho físico.

É proibido consultar arquivo apenas por `codArquivo` em endpoint acessível ao usuário.

Método autorizado:

- `ArquivoFacade.obterArquivoAutorizado(codArquivo, usuario)`

Métodos internos que não verificam autorização só podem ser usados por rotinas administrativas já protegidas.
```

### Código corrigido

```java
public ActionForward baixar(
        ActionMapping mapping,
        ActionForm form,
        HttpServletRequest request,
        HttpServletResponse response)
        throws Exception {

    Usuario usuario = obterUsuarioLogado(request);

    Long codArquivo = Long.valueOf(
        request.getParameter("codArquivo")
    );

    Arquivo arquivo = arquivoFacade
        .obterArquivoAutorizado(
            codArquivo,
            usuario
        );

    auditoriaService.registrarDownload(
        usuario.getId(),
        codArquivo
    );

    escreverArquivo(response, arquivo);
    return null;
}
```

## 5.4 O que documentar no design

- módulos e responsabilidades;
- fronteiras entre Action, Facade, Service e DAO;
- regras de autenticação;
- regras de autorização;
- regras de auditoria;
- fluxo transacional;
- integrações externas;
- estados do domínio;
- jobs e concorrência;
- armazenamento de arquivos;
- tratamento de erros;
- decisões de segurança;
- exceções permitidas à regra geral.

## 5.5 Template prático

```markdown
# Design técnico — <nome da funcionalidade>

## Objetivo
Descrever o objetivo funcional e de segurança.

## Escopo
O que está incluído e o que não está.

## Atores
Usuários, perfis, sistemas externos e jobs.

## Fluxo principal
Passos obrigatórios da operação.

## Regras de segurança
Autenticação, autorização, auditoria, sigilo e validações.

## Dados manipulados
Entidades, tabelas, DTOs e campos relevantes.

## Integrações
Sistemas externos, protocolos, timeouts e tratamento de falhas.

## Transações
Onde inicia, confirma ou desfaz a transação.

## Erros esperados
Erros de negócio, técnicos e de integração.

## Decisões de design
Escolhas importantes e justificativas.

## Restrições
Premissas que não devem ser alteradas sem revisão.
```

---

# 6. CWE-1068 — Inconsistency Between Implementation and Documented Design

## 6.1 Conceito

A implementação se comporta de forma diferente do design documentado.

Essa é uma falha perigosa porque a equipe acredita que uma regra existe, mas o código executa outra.

## 6.2 Exemplo vulnerável: documentação exige expiração, código não valida

### Documentação

```markdown
Tokens de recuperação de senha expiram em 20 minutos e só podem ser usados uma vez.
```

### Código vulnerável

```java
public void redefinirSenha(
        String token,
        String novaSenha) {

    ResetToken resetToken = resetTokenDAO
        .obterPorToken(token);

    if (resetToken == null) {
        throw new ApplicationException(
            "Token inválido"
        );
    }

    usuarioDAO.atualizarSenha(
        resetToken.getCodUsuario(),
        passwordHasher.hash(novaSenha.toCharArray())
    );
}
```

### Problemas

O código não valida:

- expiração;
- uso único;
- revogação;
- usuário vinculado;
- tentativas simultâneas.

## 6.3 Solução

```java
@Transactional
public void redefinirSenha(
        String token,
        char[] novaSenha) {

    ResetToken resetToken = resetTokenDAO
        .obterValidoParaAtualizacao(
            tokenHasher.hash(token),
            new Date()
        );

    if (resetToken == null) {
        throw new ApplicationException(
            "Token inválido ou expirado"
        );
    }

    int consumido = resetTokenDAO
        .marcarComoUtilizadoSeAindaNaoUtilizado(
            resetToken.getId()
        );

    if (consumido != 1) {
        throw new ApplicationException(
            "Token já utilizado"
        );
    }

    usuarioDAO.atualizarSenha(
        resetToken.getCodUsuario(),
        passwordHasher.hash(novaSenha)
    );

    sessaoService.revogarSessoes(
        resetToken.getCodUsuario()
    );
}
```

## 6.4 Como detectar inconsistência

Comparar:

- documento de requisitos;
- documento de design;
- código;
- testes;
- comportamento em homologação;
- logs de produção;
- scripts de banco;
- configuração de ambiente;
- documentação operacional.

## 6.5 Checklist de revisão

- O código implementa todos os passos documentados?
- Algum passo foi removido por simplificação?
- O teste cobre a regra documentada?
- O documento foi atualizado após mudança de regra?
- A configuração de produção reflete o documento?
- O script de banco contradiz a regra de negócio?
- O tratamento de erro é o mesmo documentado?
- O endpoint novo seguiu a mesma política dos endpoints antigos?

## 6.6 Exemplo de anotação no documento final

```markdown
## Divergência corrigida

A documentação previa que o token de redefinição de senha deveria expirar em 20 minutos e permitir uso único. A implementação anterior apenas verificava a existência do token.

Correção aplicada:

- consulta passou a considerar data de expiração;
- token passou a ser consumido de forma atômica;
- sessões antigas são revogadas após redefinição;
- testes foram adicionados para token expirado, reutilizado e concorrente.
```

---

# 7. CWE-1110 — Incomplete Design Documentation

## 7.1 Conceito

A documentação de design existe, mas não descreve partes necessárias para implementação e manutenção seguras.

É diferente da CWE-1053:

- **CWE-1053:** não há documentação de design;
- **CWE-1110:** há documentação, mas ela está incompleta.

## 7.2 Exemplo vulnerável: documentação não descreve estados do workflow

### Documento incompleto

```markdown
A solicitação pode ser cadastrada, analisada e concluída.
```

### Problema

O documento não informa:

- quais estados existem;
- quais transições são permitidas;
- quem pode executar cada transição;
- se uma ação pode ser repetida;
- quais campos são obrigatórios em cada estado;
- como lidar com cancelamento;
- como tratar concorrência;
- quais transições geram auditoria.

### Código vulnerável

```java
public void alterarStatus(
        Long idSolicitacao,
        String novoStatus) {

    Solicitacao solicitacao = dao.obter(idSolicitacao);
    solicitacao.setStatus(novoStatus);
    dao.atualizar(solicitacao);
}
```

## 7.3 Solução: documentar máquina de estados

```markdown
## Máquina de estados da solicitação

| Estado atual | Ação | Novo estado | Perfil permitido | Observação |
|---|---|---|---|---|
| RASCUNHO | Enviar | ENVIADA | Solicitante | Exige anexos obrigatórios |
| ENVIADA | Distribuir | EM_ANALISE | Coordenador | Registra analista responsável |
| EM_ANALISE | Aprovar | APROVADA | Analista | Exige parecer |
| EM_ANALISE | Indeferir | INDEFERIDA | Analista | Exige justificativa |
| APROVADA | Concluir | CONCLUIDA | Sistema/Job | Ação idempotente |
| Qualquer | Cancelar | CANCELADA | Administrador | Exige motivo |

Transições fora da tabela são proibidas.
```

### Código corrigido

```java
public void alterarStatus(
        Usuario usuario,
        Long idSolicitacao,
        AcaoWorkflow acao) {

    Solicitacao solicitacao = dao
        .obterParaAtualizacao(idSolicitacao);

    Transicao transicao = workflowPolicy
        .obterTransicaoPermitida(
            solicitacao.getStatus(),
            acao,
            usuario.getPerfil()
        );

    if (transicao == null) {
        throw new ApplicationException(
            "Transição não permitida"
        );
    }

    transicao.validarCamposObrigatorios(solicitacao);

    solicitacao.setStatus(
        transicao.getNovoStatus()
    );

    dao.atualizar(solicitacao);
    auditoria.registrarTransicao(usuario, solicitacao, acao);
}
```

## 7.4 Itens que costumam ficar incompletos

- política de autorização;
- estados e transições;
- regras de idempotência;
- tratamento de concorrência;
- limites de tamanho;
- timeout de integração;
- dados sensíveis;
- regras de auditoria;
- decisões de fallback;
- rollback transacional;
- comportamento em erro parcial;
- compatibilidade com dados legados.

## 7.5 Template para completar design

```markdown
## Regras obrigatórias de design

### Autenticação
Quem precisa estar autenticado?

### Autorização
Qual perfil pode executar cada ação?

### Estados
Quais estados existem e quais transições são válidas?

### Dados sensíveis
Quais campos exigem máscara, sigilo, criptografia ou auditoria?

### Concorrência
A operação pode ser chamada duas vezes? Como impedir duplicidade?

### Integração
Qual timeout, retry, fallback e comportamento em erro?

### Transação
O que deve ser atômico?

### Auditoria
Qual evento deve ser registrado?

### Compatibilidade
Há dados antigos em formato diferente?
```

---

# 8. CWE-1111 — Incomplete I/O Documentation

## 8.1 Conceito

A documentação não descreve de forma completa as entradas e saídas do sistema, método, endpoint, job, arquivo ou integração.

Isso inclui:

- parâmetros obrigatórios;
- parâmetros opcionais;
- tipo;
- formato;
- tamanho;
- valores permitidos;
- exemplos;
- erros possíveis;
- encoding;
- timezone;
- unidade de medida;
- campos sensíveis;
- nulidade;
- ordenação;
- paginação;
- efeitos colaterais;
- contrato de resposta.

## 8.2 Exemplo vulnerável: endpoint sem contrato de entrada

### Código vulnerável

```java
@PostMapping("/ferias/finalizar")
public void finalizarFerias(
        @RequestParam Long codFuncionario,
        @RequestParam Long codFerias) {

    feriasService.finalizar(
        codFuncionario,
        codFerias
    );
}
```

### Problemas

Sem documentação de I/O, não está claro:

- se `codFuncionario` pode vir do request;
- se o funcionário deve ser inferido da sessão;
- se `codFerias` precisa pertencer ao funcionário;
- se a operação é idempotente;
- se há retorno;
- quais erros podem ocorrer;
- se deve registrar auditoria;
- se pode ser chamada por job.

## 8.3 Solução: contrato de I/O

```markdown
## POST /ferias/finalizar

### Objetivo
Finalizar uma férias já vencida, vinculada ao funcionário informado.

### Autenticação
Obrigatória.

### Autorização
Somente perfis RH_ADMIN ou rotina Quartz autorizada.

### Entrada

| Campo | Tipo | Obrigatório | Regra |
|---|---|---:|---|
| codFerias | Long | Sim | Deve existir e estar ativa |
| codFuncionario | Long | Não para usuário comum | Quando informado por rotina, deve coincidir com a férias |

### Regras

1. A férias deve pertencer ao funcionário.
2. A data final deve ser anterior à data atual.
3. Férias canceladas não devem ser finalizadas.
4. A operação deve ser idempotente.
5. Múltiplos históricos de situação funcional em aberto devem ser encerrados.

### Saída

| Status | Significado |
|---|---|
| 200 | Férias finalizada ou já finalizada |
| 400 | Dados inválidos |
| 403 | Usuário sem permissão |
| 404 | Férias não encontrada |
| 409 | Estado incompatível |
```

## 8.4 Código alinhado ao contrato

```java
public ResultadoFinalizacao finalizar(
        Usuario usuario,
        Long codFerias) {

    Ferias ferias = feriasDAO
        .obterPorId(codFerias)
        .orElseThrow(
            NotFoundException::new
        );

    autorizacaoService.validarPodeFinalizarFerias(
        usuario,
        ferias
    );

    return feriasService.finalizarSeNecessario(ferias);
}
```

## 8.5 Exemplo de documentação de DTO

```markdown
## FuncionarioFeriasDTO

| Campo | Tipo | Nulo | Descrição | Regra |
|---|---|---:|---|---|
| codFuncionario | Long | Não | Código interno do funcionário | Deve existir em `tb_funcionario` |
| nome | String | Não | Nome de exibição | Não usar como identificador |
| ano | Integer | Não | Ano de exercício | Entre 1900 e ano atual |
| diasUsufruidos | Integer | Não | Dias válidos de férias | 0 a 30 |
| saldo | Integer | Não | 30 - dias válidos | Nunca negativo |
```

## 8.6 Erros comuns em documentação de I/O

- omitir se campo aceita `null`;
- não informar timezone;
- não informar escala de dinheiro;
- não informar encoding do arquivo;
- não dizer se parâmetro pode repetir;
- não dizer limite máximo;
- não indicar se campo é controlado pelo servidor;
- não indicar se campo é sensível;
- não documentar códigos de erro;
- não documentar efeitos colaterais.

---

# 9. CWE-1112 — Incomplete Documentation of Program Execution

## 9.1 Conceito

A documentação não define completamente como programas, jobs, rotinas, scripts, comandos, processos ou serviços são executados.

Aplica-se a:

- Quartz jobs;
- scripts SQL;
- rotinas batch;
- integrações agendadas;
- geração de relatórios;
- importadores;
- serviços iniciados no app server;
- comandos externos;
- jobs de CI/CD;
- migrações de banco;
- tarefas de manutenção.

## 9.2 Exemplo vulnerável: job sem documentação operacional

### Código

```java
public class ProcessaInformesJob implements Job {

    @Override
    public void execute(JobExecutionContext context) {
        processaInformesFacade.processarPendentes();
    }
}
```

### Problemas se não houver documentação

Não está claro:

- periodicidade;
- timezone;
- se permite execução concorrente;
- qual usuário técnico é usado;
- qual datasource é utilizado;
- qual transação envolve o processamento;
- se pode ser reexecutado manualmente;
- quais registros são elegíveis;
- qual limite por execução;
- como retomar após falha;
- onde ver logs;
- qual impacto em produção;
- como desabilitar em emergência.

## 9.3 Solução: documentação de execução

```markdown
## Job: ProcessaInformesJob

### Objetivo
Processar informes pendentes e atualizar situações funcionais derivadas.

### Agendamento
Cron: `0 0 5 * * ?`
Timezone: America/Sao_Paulo
Execução esperada: diária, às 05:00.

### Concorrência
Não permite execuções simultâneas.
Em cluster, deve haver controle via Quartz persistente ou lock transacional.

### Entrada
Registros pendentes em `tb_informefuncionario` com status elegível.

### Saída
Atualização de `tb_h_situacaofuncional` e marcação do informe processado.

### Idempotência
A rotina deve poder ser reexecutada sem duplicar histórico.

### Transação
Cada funcionário deve ser processado em transação independente.

### Logs
Prefixo: `[PROCESSA-INFORMES]`
Nível INFO: início, fim e resumo.
Nível WARN: registro ignorado por inconsistência.
Nível ERROR: falha técnica com correlation ID.

### Retentativa
Falhas técnicas podem ser reprocessadas na próxima execução.
Falhas de regra devem ser marcadas para análise.

### Operação manual
Executar somente por perfil administrador técnico e registrar auditoria.
```

## 9.4 Código alinhado

```java
@DisallowConcurrentExecution
public class ProcessaInformesJob implements Job {

    @Override
    public void execute(JobExecutionContext context) {
        String correlationId = UUID.randomUUID().toString();

        log.info(
            "[PROCESSA-INFORMES] inicio correlationId={}",
            correlationId
        );

        ResultadoProcessamento resultado =
            processaInformesFacade.processarPendentes(
                correlationId
            );

        log.info(
            "[PROCESSA-INFORMES] fim correlationId={} processados={} falhas={}",
            correlationId,
            resultado.getProcessados(),
            resultado.getFalhas()
        );
    }
}
```

## 9.5 Script SQL também precisa de documentação

Exemplo de cabeçalho recomendado:

```sql
-- Script: correcao_sequences_mantis_0155929.sql
-- Objetivo: realinhar sequences após migração de PostgreSQL.
-- Ambiente: homologação/produção, schema sa_garh.
-- Pré-condição: executar relatório de sequences desalinhadas.
-- Pós-condição: nextval(sequence) > max(id) da tabela associada.
-- Transação: executar em janela controlada.
-- Rollback: não aplicável diretamente; registrar valores anteriores.
-- Validação: executar consultas de conferência ao final.
-- Responsável: <nome/equipe>
-- Data: <data>
```

## 9.6 Riscos de execução mal documentada

- job roda duas vezes;
- job roda no timezone errado;
- script é aplicado no schema errado;
- rotina de homologação roda em produção;
- batch processa dados além do escopo;
- relatório pesado roda sem limite;
- reprocessamento duplica efeitos;
- exceção interrompe lote inteiro;
- comando externo executa com privilégio excessivo.

---

# 10. CWE-1118 — Insufficient Documentation of Error Handling Techniques

## 10.1 Conceito

A documentação não descreve suficientemente como erros, exceções e falhas devem ser tratados.

Isso gera comportamentos inconsistentes como:

- engolir exceção;
- expor stack trace ao usuário;
- retornar HTTP 200 em erro;
- fazer rollback quando deveria confirmar parcial;
- confirmar transação quando deveria desfazer;
- repetir operação não idempotente;
- registrar log sem contexto;
- registrar log com dados sensíveis;
- converter erro de autorização em erro genérico;
- tratar erro técnico como regra de negócio.

## 10.2 Exemplo vulnerável: exceção engolida

```java
public void anexarComprovante(Long idDeposito) {
    try {
        byte[] pdf = gerarPdfComprovante(idDeposito);
        arquivoService.anexar(pdf);
    } catch (Exception e) {
        log.warn("Falha ao anexar comprovante");
    }
}
```

### Problemas

- perde stack trace;
- não marca pendência;
- não permite retentativa consciente;
- não informa o `idDeposito`;
- não diferencia erro técnico e erro de negócio;
- o chamador pode achar que deu certo.

## 10.3 Solução: política documentada de erro

```markdown
## Tratamento de erros — anexação de comprovante

### Erros de negócio
- Depósito inexistente: marcar como falha permanente.
- Depósito sem pagamento confirmado: ignorar com WARN.
- Comprovante já anexado: operação idempotente, retornar sucesso.

### Erros técnicos
- Falha ao gerar PDF: registrar ERROR e permitir retentativa.
- Falha no storage: registrar ERROR e permitir retentativa.
- Timeout em serviço externo: registrar WARN/ERROR conforme quantidade e permitir retentativa.

### Auditoria e logs
- Sempre registrar `idDeposito` e `correlationId`.
- Nunca registrar conteúdo do PDF ou token.
- Stack trace deve ser mantido no log técnico.

### Resultado
A rotina deve retornar status por item: PROCESSADO, IGNORADO, FALHA_TEMPORARIA ou FALHA_PERMANENTE.
```

## 10.4 Código corrigido

```java
public ResultadoItem anexarComprovante(
        Long idDeposito,
        String correlationId) {

    try {
        Deposito deposito = depositoDAO.obter(idDeposito);

        if (deposito == null) {
            return ResultadoItem.falhaPermanente(
                idDeposito,
                "Depósito inexistente"
            );
        }

        if (deposito.isComprovanteAnexado()) {
            return ResultadoItem.processado(
                idDeposito,
                "Comprovante já anexado"
            );
        }

        byte[] pdf = gerarPdfComprovante(deposito);
        arquivoService.anexar(pdf);

        depositoDAO.marcarComprovanteAnexado(idDeposito);

        return ResultadoItem.processado(
            idDeposito,
            "Comprovante anexado"
        );

    } catch (RegraNegocioException e) {
        log.warn(
            "Falha de regra ao anexar comprovante. idDeposito={} correlationId={} motivo={}",
            idDeposito,
            correlationId,
            e.getMessage()
        );

        return ResultadoItem.falhaPermanente(
            idDeposito,
            e.getMessage()
        );

    } catch (Exception e) {
        log.error(
            "Falha técnica ao anexar comprovante. idDeposito={} correlationId={}",
            idDeposito,
            correlationId,
            e
        );

        return ResultadoItem.falhaTemporaria(
            idDeposito,
            "Falha técnica"
        );
    }
}
```

## 10.5 Documentar tipos de erro

```markdown
## Taxonomia de erro

| Tipo | Exemplo | Ação |
|---|---|---|
| Validação | Campo obrigatório ausente | Retornar 400 / mensagem de usuário |
| Autenticação | Sessão expirada | Retornar 401 / redirecionar login |
| Autorização | Perfil sem permissão | Retornar 403 / registrar auditoria |
| Negócio | Estado incompatível | Retornar 409 ou mensagem de regra |
| Integração temporária | Timeout | Retentar com limite |
| Integração permanente | Código externo inválido | Marcar falha permanente |
| Infraestrutura | Banco indisponível | Rollback e alerta técnico |
| Inesperado | NullPointerException | Log técnico, resposta genérica |
```

## 10.6 Documentar rollback e retentativa

```markdown
## Política de transação e retentativa

- Erro de validação: não inicia transação.
- Erro de negócio antes da persistência: rollback.
- Erro técnico durante persistência: rollback.
- Erro ao notificar sistema externo após commit: registrar pendência para retentativa.
- Retentativa só pode ocorrer em operações idempotentes.
- Operações não idempotentes exigem chave de idempotência.
```

---

# 11. Padrões práticos de documentação segura

## 11.1 ADR — Architecture Decision Record

Use ADR para decisões relevantes de segurança ou arquitetura.

```markdown
# ADR-0007 — Download de arquivo autorizado via Facade

## Status
Aceito

## Contexto
Arquivos podem possuir níveis de sigilo e vínculo com procedimentos.
Consultar arquivo apenas por `codArquivo` permite IDOR.

## Decisão
Todo download acessível ao usuário deve usar `ArquivoFacade.obterArquivoAutorizado`.
O DAO não deve ser chamado diretamente pela Action.

## Consequências
- Endpoints novos devem reutilizar a Facade.
- Testes devem cobrir usuário sem acesso.
- Auditoria de download é obrigatória.
```

## 11.2 Comentário de regra de negócio no código

Comentários úteis explicam intenção, não repetem o código.

### Ruim

```java
// Busca arquivo
Arquivo arquivo = arquivoDAO.obter(codArquivo);
```

### Bom

```java
// Regra de segurança:
// o arquivo não pode ser obtido apenas por codArquivo,
// pois o identificador é controlável pelo usuário.
// A Facade valida vínculo com procedimento, sigilo e perfil.
Arquivo arquivo = arquivoFacade.obterArquivoAutorizado(
    codArquivo,
    usuario
);
```

## 11.3 JavaDoc para contrato de método crítico

```java
/**
 * Finaliza férias vencidas do funcionário.
 *
 * <p>Contrato de segurança:</p>
 * <ul>
 *   <li>A férias deve pertencer ao funcionário informado.</li>
 *   <li>Férias canceladas ou suspensas não devem ser finalizadas.</li>
 *   <li>A operação deve ser idempotente.</li>
 *   <li>Todos os históricos transitórios de férias em aberto devem ser encerrados.</li>
 * </ul>
 *
 * @param ferias férias a finalizar; não pode ser {@code null}
 * @return resultado da finalização
 * @throws ApplicationException quando o estado for incompatível ou houver falha técnica
 */
public ResultadoFinalizacao finalizarFeriasVencidas(Ferias ferias)
        throws ApplicationException {
    // implementação
}
```

## 11.4 Documentação de endpoint

```markdown
## Endpoint: POST /api/arquivos/{codArquivo}/download

### Segurança
- Autenticação obrigatória.
- Autorização por procedimento vinculado.
- Validação de nível de sigilo.
- Auditoria obrigatória.

### Entrada
| Campo | Origem | Regra |
|---|---|---|
| codArquivo | path | Long positivo, arquivo existente |

### Saída
- 200 com PDF/binário autorizado.
- 403 se usuário não possui acesso.
- 404 se arquivo não existe ou não deve ser revelado.

### Observação
Não retornar caminho físico do arquivo.
```

## 11.5 Documentação de DAO

```java
/**
 * Consulta arquivos autorizados para o usuário.
 *
 * <p>Importante: esta consulta aplica filtro de autorização no banco.
 * Não substituir por consulta simples por ID em endpoints públicos.</p>
 */
Optional<Arquivo> obterArquivoAutorizado(
    Long codArquivo,
    Long codUsuario
);
```

---

# 12. Exemplos de falhas documentais em Java

## 12.1 Campo de formulário sem contrato

### Vulnerável

```jsp
<input type="hidden" name="perfil" value="USUARIO">
```

```java
String perfil = request.getParameter("perfil");
usuarioService.alterarPerfil(codUsuario, perfil);
```

### Documentação ausente

Não está documentado que `perfil` é dado controlado pelo servidor e não pode vir do formulário.

### Correção documental

```markdown
O perfil do usuário jamais deve ser recebido do formulário de autoatendimento.
Alterações de perfil são operações administrativas e devem usar endpoint próprio, com autorização específica e auditoria.
```

### Código corrigido

```java
usuarioService.atualizarDadosCadastrais(
    codUsuario,
    form.getNome(),
    form.getEmail()
);
```

## 12.2 Regra de anonimização não documentada

### Risco

Ambiente de desenvolvimento usa dados anonimizados. O nome de produção pode não coincidir com o nome visto em desenvolvimento.

### Correção documental

```markdown
## Observação sobre evidências

Os dados do solicitante são de produção. As consultas e correções foram validadas em desenvolvimento com dados anonimizados. Portanto, divergências em nome da pessoa não indicam funcionário diferente quando os identificadores técnicos coincidem.

Identificadores confiáveis para análise:
- codFuncionario;
- matrícula;
- codInforme;
- chaves primárias das tabelas envolvidas.
```

## 12.3 Integração sem documentação de erro

### Vulnerável

```java
ProjudiResponse response = projudiClient.enviar(request);
processar(response.getResult());
```

### Problema

Não está documentado se resposta HTTP 400 pode conter erro de negócio esperado ou se sempre deve gerar exceção técnica.

### Correção documental

```markdown
## Tratamento de resposta do Projudi

- 2xx: processar `result`.
- 400 com wrapper válido: tratar como erro de negócio e exibir mensagens retornadas.
- 401/403: erro de autenticação/autorização da integração.
- 404 em consulta opcional: retornar Optional.empty.
- 5xx ou parse inválido: erro técnico com mensagem genérica ao usuário.
```

## 12.4 Sequence pós-migração sem documentação operacional

### Risco

Scripts de correção de sequence podem ser executados de forma insegura se não documentarem pré-condição, validação e escopo.

### Cabeçalho recomendado

```sql
-- Objetivo: corrigir sequences desalinhadas após migração PostgreSQL.
-- Escopo: sequences listadas no relatório anexo.
-- Critério: sequence deve ficar com valor maior que max(id) da tabela.
-- Não alterar tabelas fora do relatório.
-- Executar validação antes e depois.
-- Registrar valores antigos e novos.
```

---

# 13. Checklist geral de documentação segura

## 13.1 Design

- Existe documentação de arquitetura?
- Há diagrama ou descrição das fronteiras?
- Regras de segurança estão explícitas?
- Há design de autorização?
- Estados e transições estão definidos?
- Há decisões registradas em ADR?
- A documentação indica o que não deve ser feito?

## 13.2 Implementação versus documento

- O código implementa o documento?
- A documentação foi atualizada após mudança?
- Testes refletem o documento?
- Configuração de ambiente condiz com o documento?
- Scripts estão alinhados ao requisito?
- Há divergência entre comentário e código?

## 13.3 I/O

- Entradas estão completas?
- Saídas estão completas?
- Tipos e formatos estão claros?
- Nullability está clara?
- Limites estão claros?
- Timezone está claro?
- Encoding está claro?
- Códigos de erro estão documentados?
- Campos sensíveis estão identificados?

## 13.4 Execução

- Agendamento está documentado?
- Timezone está documentado?
- Concorrência está documentada?
- Retentativa está documentada?
- Operação manual está documentada?
- Usuário técnico está documentado?
- Logs e auditoria estão documentados?
- Rollback está documentado?

## 13.5 Erros

- Há taxonomia de erros?
- Exceções esperadas estão documentadas?
- Rollback/commit estão documentados?
- Retentativas estão documentadas?
- Mensagens ao usuário estão padronizadas?
- Logs técnicos preservam contexto?
- Dados sensíveis são omitidos?
- Falhas parciais têm tratamento definido?

---

# 14. Comandos de busca no código

Os comandos ajudam a encontrar áreas onde a documentação deveria existir ou ser conferida.

## 14.1 Pontos críticos sem JavaDoc/comentário

```bash
grep -RniE 'public .* (baixar|download|upload|autenticar|autorizar|processar|finalizar|excluir|alterarSenha)' src/
```

## 14.2 TODO/FIXME que indicam documentação pendente

```bash
grep -RniE 'TODO|FIXME|XXX|gambiarra|temporario|provisorio|verificar depois' src/ docs/
```

## 14.3 Exceções genéricas

```bash
grep -RniE 'catch \(Exception|throws Exception|printStackTrace|throw new RuntimeException' src/
```

## 14.4 Jobs e rotinas agendadas

```bash
grep -RniE 'implements Job|@Scheduled|CronScheduleBuilder|TimerTask|Runnable' src/
```

## 14.5 Endpoints e Actions

```bash
grep -RniE '@RequestMapping|@PostMapping|@GetMapping|DispatchAction|ActionForward' src/
```

## 14.6 Scripts SQL sem cabeçalho

```bash
find . -name '*.sql' -type f -print
```

Verificar manualmente se possuem objetivo, escopo, pré-condição, validação e rollback.

---

# 15. Testes sugeridos

## 15.1 Documentação de design

1. Selecionar uma funcionalidade crítica.
2. Ler a documentação de design.
3. Identificar regras de segurança descritas.
4. Verificar se cada regra tem teste.
5. Verificar se cada regra aparece no código.
6. Verificar se há regra implementada, mas não documentada.
7. Verificar se o documento diz quem pode executar cada ação.
8. Verificar se fluxos alternativos estão descritos.

## 15.2 Consistência implementação/documento

1. Escolher uma regra documentada.
2. Localizar a implementação.
3. Verificar se há divergência.
4. Executar teste positivo.
5. Executar teste negativo.
6. Conferir configuração de ambiente.
7. Conferir script ou migration relacionada.
8. Atualizar documento ou código conforme fonte oficial da regra.

## 15.3 I/O

1. Enviar campo obrigatório ausente.
2. Enviar campo extra.
3. Enviar campo nulo.
4. Enviar tipo incorreto.
5. Enviar tamanho máximo.
6. Enviar valor fora de faixa.
7. Conferir status HTTP ou mensagem.
8. Conferir se resposta contém dados sensíveis.

## 15.4 Execução

1. Executar job no horário previsto.
2. Executar manualmente, se permitido.
3. Simular duas execuções simultâneas.
4. Simular falha no meio do lote.
5. Simular reexecução.
6. Conferir logs.
7. Conferir auditoria.
8. Conferir se retentativa duplica efeitos.

## 15.5 Erros

1. Forçar erro de validação.
2. Forçar erro de autorização.
3. Forçar erro de integração.
4. Forçar timeout.
5. Forçar exceção inesperada.
6. Conferir rollback.
7. Conferir mensagem ao usuário.
8. Conferir log técnico.
9. Confirmar ausência de senha/token/dado sensível no log.
10. Confirmar correlation ID.

---

# 16. Exemplos de testes unitários

## 16.1 Implementação deve seguir workflow documentado

```java
@Test(expected = ApplicationException.class)
public void naoDeveAprovarSolicitacaoEmRascunho() {
    Solicitacao solicitacao = new Solicitacao();
    solicitacao.setStatus(StatusSolicitacao.RASCUNHO);

    workflowService.executar(
        usuarioAnalista,
        solicitacao,
        AcaoWorkflow.APROVAR
    );
}
```

## 16.2 Erro técnico deve retornar falha temporária

```java
@Test
public void falhaNoStorageDeveGerarFalhaTemporaria() {
    when(arquivoService.anexar(any(byte[].class)))
        .thenThrow(new StorageException("timeout"));

    ResultadoItem resultado = service.anexarComprovante(
        10L,
        "corr-123"
    );

    assertEquals(
        StatusResultado.FALHA_TEMPORARIA,
        resultado.getStatus()
    );
}
```

## 16.3 Token deve respeitar contrato documentado

```java
@Test(expected = ApplicationException.class)
public void tokenExpiradoNaoDeveRedefinirSenha() {
    ResetToken token = criarTokenExpirado();
    resetTokenDAO.salvar(token);

    senhaService.redefinirSenha(
        token.getValorOriginal(),
        "senha nova longa".toCharArray()
    );
}
```

---

# 17. Quadro de decisão rápida

| Evidência | CWE provável |
|---|---:|
| Não há documento explicando o design | 1053 |
| Documento diz uma regra e código aplica outra | 1068 |
| Documento existe, mas não cobre autorização/workflow/concorrência | 1110 |
| Endpoint não documenta campos, tipos, limites ou respostas | 1111 |
| Job/script não documenta execução, agendamento, retry ou rollback | 1112 |
| Erros e exceções são tratados sem política documentada | 1118 |

---

# 18. Resumo para prova

## CWE-1225

Categoria de problemas de documentação. Não deve ser usada diretamente quando houver CWE Base mais específica.

## CWE-1053

Ausência de documentação de design. A equipe não possui representação formal de como o produto foi projetado.

## CWE-1068

Inconsistência entre implementação e design documentado. O documento afirma uma regra, mas o código executa outra.

## CWE-1110

Documentação de design incompleta. Existe documento, mas faltam regras, fluxos, estados, segurança ou premissas relevantes.

## CWE-1111

Documentação incompleta de entrada e saída. Campos, tipos, limites, formatos, erros ou respostas não são totalmente descritos.

## CWE-1112

Documentação incompleta de execução de programa. Jobs, scripts, serviços e rotinas não explicam agendamento, concorrência, transação, retry e operação.

## CWE-1118

Documentação insuficiente de tratamento de erros. Não há orientação clara sobre exceções, rollback, retentativa, mensagens, logs e falhas parciais.

---

# 19. Modelo mínimo para documentos de requisitos técnicos

```markdown
# Solução — <ticket ou funcionalidade>

## 1. Resumo
Descrever o problema e a solução em poucas linhas.

## 2. Contexto
Informar origem do problema, ambiente e dados relevantes.

## 3. Diagnóstico
Explicar causa raiz técnica.

## 4. Regra de negócio
Descrever a regra correta de forma objetiva.

## 5. Design da solução
Informar classes, métodos, tabelas e fluxo.

## 6. Segurança
Autenticação, autorização, auditoria, dados sensíveis e validações.

## 7. Entrada e saída
Parâmetros, DTOs, status, mensagens e efeitos colaterais.

## 8. Tratamento de erros
Erros esperados, exceções, rollback, retry e logs.

## 9. Execução
Scripts, jobs, ordem de execução, pré-condições e validação.

## 10. Testes
Cenários positivos, negativos, regressão e evidências.

## 11. Riscos e observações
Limitações, premissas e pontos de atenção.
```

---

# 20. Referências

## MITRE CWE

- [CWE-1225 — Documentation Issues](https://cwe.mitre.org/data/definitions/1225.html)
- [CWE-1053 — Missing Documentation for Design](https://cwe.mitre.org/data/definitions/1053.html)
- [CWE-1068 — Inconsistency Between Implementation and Documented Design](https://cwe.mitre.org/data/definitions/1068.html)
- [CWE-1110 — Incomplete Design Documentation](https://cwe.mitre.org/data/definitions/1110.html)
- [CWE-1111 — Incomplete I/O Documentation](https://cwe.mitre.org/data/definitions/1111.html)
- [CWE-1112 — Incomplete Documentation of Program Execution](https://cwe.mitre.org/data/definitions/1112.html)
- [CWE-1118 — Insufficient Documentation of Error Handling Techniques](https://cwe.mitre.org/data/definitions/1118.html)

## Práticas complementares

- OWASP Application Security Verification Standard — ASVS
- OWASP Software Assurance Maturity Model — SAMM
- OWASP Logging Cheat Sheet
- OWASP Error Handling Cheat Sheet
- Architecture Decision Records — ADR
- JavaDoc e documentação de contratos de API

---

# 21. Conclusão

Falhas de documentação não são apenas problemas administrativos. Elas criam terreno para vulnerabilidades porque escondem intenção, premissas, fluxos obrigatórios e regras de segurança.

Uma documentação segura deve deixar claro:

- como o sistema foi desenhado;
- quais regras não podem ser violadas;
- quais entradas e saídas são aceitas;
- como jobs, scripts e integrações são executados;
- como erros e exceções devem ser tratados;
- quando o código diverge do documento;
- quais testes comprovam a regra.

A regra central é:

> Se uma regra é importante para segurança, integridade, autorização, auditoria, execução ou recuperação de erro, ela precisa estar documentada de forma objetiva e verificável por código, teste ou evidência operacional.
