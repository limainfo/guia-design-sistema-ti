# 1️⃣ DIAGRAMA DE CASOS DE USO

(Baseado no Capítulo 9 – Casos de Uso)

## 📌 Conceito Geral

O diagrama de casos de uso representa **uma visão externa do sistema**, mostrando:

* Atores (quem interage com o sistema)
* Casos de uso (funcionalidades do ponto de vista do usuário)
* Relacionamentos entre eles

⚠️ A UML não define o conteúdo textual do caso de uso, apenas fornece o formato do diagrama.

---

## 📌 Elementos Fundamentais

### 👤 Atores

Representam papéis externos ao sistema (usuários ou sistemas externos).

Exemplo da figura (pág. 107):

* Gerente Comercial
* Gerente
* Vendedor
* Sistema de Contabilidade

---

### 🔵 Casos de Uso

Representam funcionalidades oferecidas pelo sistema.

Exemplos da figura:

* Estabelecer Limites
* Atualiza Contas
* Analisar Riscos
* Fechar Preço
* Registrar Negócio
* Avaliar Negócio

---

### 🔗 Relacionamentos

#### Associação

Liga ator ao caso de uso.

#### «include»

Um caso de uso inclui obrigatoriamente outro.

Exemplo (pág. 107):

* Fechar Preço inclui Avaliar Negócio

---

## 📌 Estrutura Textual do Caso de Uso

O valor real está na descrição textual, que pode conter:

* 🎯 Gatilho (evento inicial)
* 🔒 Pré-condição (condição que deve ser verdadeira antes)
* ✅ Garantia (o que o sistema assegura ao final)
* 📖 Fluxo principal
* 🔁 Fluxos alternativos / extensões

O autor recomenda:
✔ Foco no texto
✔ Não exagerar nos detalhes
✔ Manter casos de uso curtos

---

## 📌 Níveis de Casos de Uso (Cockburn)

* 🐟 Nível do mar → interação principal ator-sistema (mais comum)
* 🐠 Nível de peixe → detalhamento interno
* 🐦 Nível de pássaro → visão de negócio (macro)

A maioria dos casos deve estar no **nível do mar**.

---

## 📌 Casos de Uso x Funcionalidades

* Casos de uso → narrativa da interação
* Funcionalidades (histórias) → recorte técnico para implementação

Ambos descrevem requisitos, mas com objetivos diferentes.

---

## 📌 Quando Utilizar

* Início do projeto
* Levantamento de requisitos funcionais
* Entendimento do sistema sob perspectiva do usuário

Evitar:

* Documentos longos demais
* Complexidade excessiva

---

# 2️⃣ DIAGRAMA DE CLASSES

(Baseado no Capítulo 3 – Diagramas de Classes: Elementos Básicos)

---

## 📌 Conceito Geral

O diagrama de classes é o **principal diagrama estrutural da UML**.

Ele representa:

* Classes
* Atributos
* Operações
* Relacionamentos
* Generalizações
* Restrições
* Dependências

É a espinha dorsal da modelagem estrutural.

---

## 📌 Estrutura da Classe

Uma classe possui três compartimentos:

1. Nome
2. Atributos
3. Operações

Exemplo da figura (pág. 53):
Classe Pedido:

* datadeRecebimento
* éPré-pago
* número
* preço
* operações como fechar(), pagar()

---

## 📌 Atributos

Formato:

```
visibilidade nome : tipo = valor-padrão
```

Exemplo:

```
- nome : String
```

Multiplicidade pode aparecer no atributo:

```
itensDeLinha : LinhaDePedido[*]
```

---

## 📌 Multiplicidade

Indica quantas instâncias podem participar:

* 1 → exatamente um
* 0..1 → opcional
* * → muitos
* 1..* → pelo menos um

É fundamental para compreender cardinalidade entre objetos.

---

## 📌 Associações

Representam relacionamentos estruturais entre classes.

Exemplo (pág. 54):
Pedido — Linha de Pedido
Linha de Pedido — Produto

Podem ter:

* Nome
* Papéis
* Multiplicidade
* Navegabilidade

---

## 📌 Associações Bidirecionais

Exemplo (pág. 58):
Pessoa ↔ Carro

Ambos conhecem um ao outro.

Importante:

* Exigem sincronização no código
* Devem ser usadas com cuidado

---

## 📌 Operações

Representam comportamentos.

Formato:

```
visibilidade nome(parâmetros) : tipoRetorno
```

Exemplo:

```
+ calcularTotal() : Dinheiro
```

Distinção importante:

* Consulta (query) → não altera estado
* Comando (modifier) → altera estado

---

## 📌 Generalização (Herança)

Representa relação "é um".

Exemplo (pág. 60-61):

Cliente

* Cliente Pessoa Física
* Cliente Pessoa Jurídica

Relaciona-se ao Princípio da Substituição de Liskov:
Uma subclasse deve poder substituir a superclasse sem quebrar o sistema.

---

## 📌 Dependência

Relação mais fraca que associação.

Indica que:
Se uma classe mudar, pode impactar outra.

Exemplo (pág. 62):
Janela de Benefícios depende de Funcionário.

---

## 📌 Restrições

Podem ser descritas:

* Em linguagem natural
* Em OCL
* Como observações

Exemplo:

```
{idade >= 18}
```

---

## 📌 Projeto por Contrato

Define:

* Pré-condições
* Pós-condições
* Invariantes

Aumenta confiabilidade e clareza das responsabilidades.

---

## 📌 Quando Utilizar Diagramas de Classes

* Modelagem estrutural
* Exploração do domínio
* Base para implementação

Cuidados:

* Não modelar tudo
* Manter simplicidade
* Evitar excesso de detalhes

---

# 📚 Síntese Comparativa

| Aspecto         | Casos de Uso          | Classes                    |
| --------------- | --------------------- | -------------------------- |
| Foco            | Comportamento externo | Estrutura interna          |
| Perspectiva     | Usuário               | Desenvolvedor              |
| Momento ideal   | Início do projeto     | Modelagem e design         |
| Principal valor | Narrativa textual     | Estrutura e relacionamento |
