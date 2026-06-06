# Questões de Revisão - Design Patterns/CDC

## Questões objetivas

### 1. O que melhor define um Design Pattern?

A. Um trecho de código pronto para copiar.
B. Uma solução conceitual reutilizável para problema recorrente de design.
C. Uma biblioteca externa usada em orientação a objetos.
D. Uma regra obrigatória de compilação.

**Resposta:** B.

---

### 2. Qual pattern é mais adequado para substituir muitos `if/else` de cálculo de frete?

A. Singleton.
B. Strategy.
C. Builder.
D. Prototype.

**Resposta:** B.

---

### 3. Qual pattern garante uma única instância de uma classe?

A. Adapter.
B. Observer.
C. Singleton.
D. Composite.

**Resposta:** C.

---

### 4. Qual é o principal risco do Singleton mal utilizado?

A. Criar muitos objetos pequenos.
B. Virar variável global disfarçada e dificultar testes.
C. Impedir uso de interface gráfica.
D. Substituir todos os repositórios.

**Resposta:** B.

---

### 5. Qual pattern é indicado quando uma API externa possui interface incompatível com o domínio?

A. Adapter.
B. Builder.
C. Memento.
D. Iterator.

**Resposta:** A.

---

### 6. Qual pattern cria uma interface simples para um subsistema complexo?

A. Composite.
B. Facade.
C. Prototype.
D. Flyweight.

**Resposta:** B.

---

### 7. Qual pattern permite tratar objetos individuais e grupos da mesma forma?

A. Composite.
B. Proxy.
C. Strategy.
D. Command.

**Resposta:** A.

---

### 8. Qual pattern permite que um objeto avise vários outros quando seu estado muda?

A. Observer.
B. Factory Method.
C. Builder.
D. Bridge.

**Resposta:** A.

---

### 9. Qual pattern encapsula uma ação como objeto, podendo facilitar filas, logs e desfazer?

A. Command.
B. State.
C. Decorator.
D. Iterator.

**Resposta:** A.

---

### 10. O que é um God Object?

A. Classe abstrata usada como contrato.
B. Classe que concentra responsabilidades demais e conhece muitas partes do sistema.
C. Classe que implementa Factory.
D. Objeto imutável usado em DDD.

**Resposta:** B.

---

### 11. No CDC, o que vem primeiro?

A. Banco de dados.
B. Código.
C. Contrato.
D. Deploy.

**Resposta:** C.

---

### 12. Qual alternativa representa uma pré-condição?

A. Retornar status 201 após criar pedido.
B. O saldo nunca pode ser negativo.
C. O valor de pagamento deve ser maior que zero antes de pagar.
D. Registrar log após a operação.

**Resposta:** C.

---

### 13. Qual alternativa representa uma invariante?

A. O cliente envia um JSON.
B. O sistema retorna um recibo.
C. O saldo de estoque nunca pode ficar negativo.
D. O usuário clica em salvar.

**Resposta:** C.

---

### 14. Qual é a diferença principal entre TDD e CDC?

A. TDD começa pelo contrato e CDC pelo banco.
B. TDD foca comportamento interno; CDC foca fronteira entre componentes.
C. TDD só funciona em frontend; CDC só funciona em backend.
D. Não há diferença.

**Resposta:** B.

---

### 15. Sobre API-first e CDC, é correto afirmar:

A. Todo CDC é API-first.
B. Todo API-first pode ser visto como CDC, mas CDC é mais amplo.
C. CDC só existe com Swagger.
D. API-first impede testes de contrato.

**Resposta:** B.

---

## Questões discursivas

### 1. Explique por que Design Patterns não devem ser usados “por estética”.

**Resposta esperada:** Patterns devem resolver dores reais de design. Quando usados sem necessidade, aumentam a complexidade, criam arquivos e abstrações desnecessárias e dificultam leitura e manutenção.

### 2. Diferencie Adapter e Facade.

**Resposta esperada:** Adapter converte uma interface incompatível para uma interface esperada pelo cliente. Facade simplifica o acesso a um subsistema complexo por meio de uma interface mais simples.

### 3. Explique como o CDC ajuda frontend e backend a trabalharem em paralelo.

**Resposta esperada:** O contrato define request, response, status, campos obrigatórios e erros antes da implementação. Assim, o frontend pode usar mocks/stubs e o backend implementa conforme o contrato, reduzindo dependência direta e retrabalho.

### 4. No laboratório de almoxarifado, por que a Factory melhora o design?

**Resposta esperada:** Porque centraliza a criação de `Material`, valida código, nome e saldo inicial, evita `new` espalhado e impede que uma entidade nasça inválida.

### 5. Por que Repository melhora testabilidade?

**Resposta esperada:** Porque o domínio depende de uma interface de persistência, permitindo trocar banco real por mock ou implementação em memória durante testes.
