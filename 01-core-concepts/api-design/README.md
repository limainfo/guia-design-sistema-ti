# API Design
Aprenda sobre API design para entrevistas de desenho de sistemas
---

No contexto de entrevistas de system design, você vai querer definir como os clientes interagem com o seu sistema como parte da etapa de API no framework Delivery.

O design de API segue padrões previsíveis. Você escolhe um protocolo, define seus recursos e especifica como os clientes enviam dados e recebem respostas. Este artigo não vai torná-lo um mestre em design de APIs, mas deve cobrir o básico necessário para impressionar nesse período de 5 minutos da sua entrevista de system design.

Antes de irmos fundo aqui, quero deixar uma coisa muito clara: a maioria dos entrevistadores não se importa tanto assim que o seu design de API seja perfeito. Eles querem ver que você consegue desenhar uma API razoável e seguir em frente para as partes mais complexas do sistema.

Dito isso, se você estiver entrevistando para vagas de frontend ou produto, o design de API importa mais, já que você vai trabalhar diariamente com APIs. Além disso, para vagas de nível júnior, há menos expectativa sobre sua capacidade de projetar sistemas distribuídos, então pode sobrar mais tempo na entrevista para discutir APIs.

---

## API Types

Em uma entrevista, você normalmente vai escolher entre três protocolos principais de API:

* **REST (Representational State Transfer)** – REST usa métodos HTTP padrão (GET, POST, PUT, DELETE) para manipular recursos identificados por URLs. Para operações CRUD padrão em aplicações web e mobile, REST se mapeia naturalmente para as operações de banco de dados e para a semântica do HTTP, tornando-se o protocolo padrão para a maioria dos web services. **Essa deve ser sua escolha padrão.**

* **GraphQL** – Diferente dos endpoints fixos do REST, GraphQL usa um único endpoint com uma linguagem de consulta que permite ao cliente especificar exatamente quais dados precisa. Pense em um aplicativo mobile que precisa apenas de informações básicas de usuário versus um dashboard web que exibe análises completas – com REST, você precisaria criar múltiplos endpoints ou forçar o cliente a buscar mais dados do que precisa, mas com GraphQL cada cliente pede exatamente o que precisa em uma única query. Se o entrevistador mencionar “busca flexível de dados” ou falar sobre evitar *over-fetching* e *under-fetching*, isso é um sinal para você considerar GraphQL.

* **RPC (Remote Procedure Call)** – Protocolos RPC como gRPC usam serialização binária e HTTP/2 para comunicação eficiente entre serviços. Enquanto REST trata tudo como recursos, RPC permite pensar em termos de ações e procedimentos – quando seu serviço de usuário precisa validar permissões rapidamente com o serviço de autenticação, uma chamada RPC como `checkPermission(userId, resource)` é mais natural do que tentar modelar isso como um recurso REST. Se o entrevistador mencionar especificamente microservices ou APIs internas, considere RPC para essas conexões de alta performance. Use RPC quando performance for crítica (veja *Networking Essentials* para detalhes mais profundos de protocolo).

**Padronize em REST a menos que tenha um motivo específico para não fazê-lo.** É bem compreendido, tem ótimas ferramentas e atende a 90% dos casos de uso. Se estiver em dúvida, basta dizer “vou usar REST APIs” e seguir em frente.

Para recursos em tempo real como notificações, chat ou atualizações ao vivo, você vai precisar de protocolos diferentes, como **WebSockets** ou **Server-Sent Events**. Eles não são APIs tradicionais – são conexões persistentes. Mas são importantes de conhecer, e você pode aprender tudo sobre isso no nosso *Real-time Updates Pattern*.

---

## API Types Flowchart

Vamos passar por cada um desses protocolos um por um e destacar o que importa na sua entrevista.

---

## REST

Como REST é sua escolha padrão, vamos gastar mais tempo aqui entendendo como desenhar APIs REST que funcionam bem em entrevistas de system design.

### Resource Modeling

A base de um bom design de API REST é identificar corretamente os seus recursos. Se você seguiu o framework Delivery, recursos são apenas suas entidades centrais.

Pegue a Ticketmaster como exemplo. Suas entidades centrais podem ser **events**, **venues**, **tickets** e **bookings**. Elas se mapeiam naturalmente para recursos REST:

```http
GET /events                    # Obter todos os eventos
GET /events/{id}               # Obter um evento específico
GET /venues/{id}               # Obter um local (venue) específico
GET /events/{id}/tickets       # Obter ingressos disponíveis para um evento
POST /events/{id}/bookings     # Criar uma nova reserva para um evento
GET /bookings/{id}             # Obter uma reserva específica
```

O importante é que recursos REST devem representar **coisas** no seu sistema, não ações. Em vez de pensar sobre o que os usuários podem fazer (como “book” ou “purchase”), pense sobre o que **existe** no seu sistema (events, venues, tickets, bookings).

Os recursos devem sempre ser substantivos no plural, ou seja, `bookings`, `events`, `tickets` etc. A maioria dos entrevistadores não liga para isso, mas alguns ligam, e é tão fácil acertar que vale a pena fazer do jeito certo.

Ao lidar com relacionamentos entre recursos, você tem duas abordagens principais. Você pode **aninhá-los** quando há uma relação clara de pai-filho, como `/events/{id}/tickets` para todos os ingressos pertencentes a um evento específico. Alternativamente, pode manter os recursos “planos” e usar **query parameters** para filtragem, como `/tickets?event_id=123`.

A diferença chave é se o relacionamento é **obrigatório** ou **opcional**. Use parâmetros de caminho (ou recursos aninhados) quando o valor for obrigatório – como `/events/{id}/tickets`, onde você sempre precisa especificar de qual evento quer os ingressos. Use query parameters quando o filtro for opcional – como `/tickets?event_id=123&section=VIP`, onde você pode querer todos os ingressos, ou só os do evento, ou ainda os do evento e de uma seção específica.

Em entrevistas, essa distinção ajuda você a fazer a escolha certa rapidamente. Se o relacionamento for sempre obrigatório para a consulta fazer sentido, use path parameter. Se for um filtro opcional entre muitos possíveis filtros, use query parameter. O entrevistador se importa mais se você consegue identificar os recursos corretos do que com a estrutura perfeita da URL, mas mostrar esse entendimento transmite boa intuição de design de API.

---

### HTTP Methods

Depois de identificar os recursos, você precisa decidir como os clientes interagem com eles. O HTTP fornece um conjunto de métodos (verbos) que se mapeiam naturalmente para operações comuns, e entender quando usar cada um é crucial em entrevistas.

* **GET** é para recuperar dados sem mudar nada. Use GET em `/events/{id}` para buscar detalhes de um evento ou em `/events` para listar todos os eventos.

* **POST** cria novos recursos. Quando um usuário reserva ingressos, você faz POST em `/events/{id}/bookings` com os detalhes da reserva no corpo da requisição. O servidor atribui um ID e retorna a reserva recém-criada. POST **não é seguro nem idempotente**. Ou seja, chamar várias vezes cria várias reservas.

* **PUT** substitui um recurso inteiro pelo que você envia. Se você está atualizando completamente o perfil de um usuário, faça PUT em `/users/{id}` com o objeto de usuário completo. Diferente de POST, PUT é **idempotente**, então enviar os mesmos dados várias vezes resulta no mesmo estado final.

* **PATCH** atualiza parte de um recurso. Quando o usuário altera apenas o endereço de e-mail, faça PATCH em `/users/{id}` com somente o campo `email`.

* **DELETE** remove um recurso. `DELETE /bookings/{id}` cancela uma reserva. É idempotente – deletar um recurso já deletado deve retornar o mesmo resultado.

O ponto chave aqui é **idempotência**. Operações que podem ser repetidas sem mudar o resultado (GET, PUT, PATCH, DELETE) são idempotentes. Isso importa quando a rede falha e o cliente precisa reenviar requisições – você não quer reservas duplicadas por causa de um retry.

---

### Passing Data to APIs

Endpoints de API precisam de entrada para dizer ao servidor o que fazer. Isso pode ser quais recursos buscar, quais dados atualizar no banco ou como filtrar resultados. Entender **onde** colocar cada tipo de entrada é crucial para desenhar APIs limpas e intuitivas.

Você tem três opções principais para passar dados para uma API REST, e cada uma serve a um propósito diferente:

1. **Path parameters** identificam qual recurso específico você está manipulando. Quando quer obter detalhes de um evento, você coloca o ID do evento no caminho: `/events/123`. O ID faz parte da própria estrutura da URL, deixando claro que você está pedindo um evento específico, não uma coleção. Use path parameters quando o valor for obrigatório para identificar o recurso – sem ele, a requisição não faz sentido.

2. **Query parameters** filtram, ordenam ou modificam como você recupera recursos. Quando quer buscar eventos em uma cidade ou intervalo de datas específicos, use query parameters: `/events?city=NYC&date=2024-01-01`. Eles são opcionais – você pode pedir todos os eventos sem filtros, ou aplicar vários filtros juntos. Query parameters funcionam bem também para paginação: `/events?page=2&limit=20`. Observe que a primeira opção é separada por `?` e os parâmetros subsequentes por `&`.

3. **Request body** contém os dados que você está enviando para criar ou atualizar recursos. Quando um usuário reserva ingressos, você faz POST em `/events/{id}/bookings` com os detalhes da reserva no corpo. Coisas como quantos ingressos, preferências de assento e assim por diante. O request body é onde você coloca estruturas de dados complexas e qualquer coisa que seja muito grande ou sensível para ir numa URL.

Cada tipo de entrada cumpre um papel diferente no contrato da API. **Path parameters** são estruturais, determinam qual endpoint você está acessando. **Query parameters** são modificadores, mudam como o endpoint se comporta. O **request body** é o payload, os dados com os quais você realmente está trabalhando.

Um exemplo prático: se você está construindo um sistema de reservas e o usuário quer reservar ingressos VIP para um evento específico, você poderia estruturar assim:

```http
POST /events/123/bookings?notify=true
{
  "tickets": [
    { "section": "VIP", "quantity": 2 },
    { "section": "General", "quantity": 1 }
  ],
  "payment_method": "credit_card"
}
```

* O ID do evento (`123`) está no **path** porque você precisa especificar de qual evento está fazendo a reserva.
* A preferência de notificação é um **query parameter** porque é um comportamento opcional.
* Os detalhes da reserva vão no **request body**, porque são os dados centrais que você está criando.

---

### Returning Data

Uma resposta de API é composta de duas partes:

1. **Status code**, que indica se a requisição foi bem-sucedida ou não.
2. **Response body**, que contém os dados retornados para o cliente (normalmente em JSON).

Para status codes, fique nos mais comuns:

* `200` para sucesso
* `201` para recursos criados
* `400` para requisição inválida (*bad request*)
* `401` para quando é necessário autenticar
* `404` para não encontrado
* `500` para erro de servidor

Não complique isso em entrevistas – os entrevistadores se preocupam mais se você entende a diferença entre erros de cliente (4xx) e de servidor (5xx) do que se você memorizou todos os códigos. Mesmo usar `4xx`/`5xx` para esconder o código exato geralmente é totalmente aceitável.

---

## GraphQL

GraphQL surgiu no Facebook em 2012 para resolver um problema específico: o app mobile precisava de dados diferentes do app web, mas eles estavam presos a endpoints REST que retornavam estruturas de dados fixas. O time mobile vivia pedindo novos endpoints ou mudanças nos existentes e isso estava atrasando o desenvolvimento dos dois lados.

Com REST, você normalmente tem duas escolhas desagradáveis quando clientes diferentes precisam de dados diferentes:

* Criar múltiplos endpoints para diferentes casos de uso, levando à proliferação de endpoints e dores de manutenção.
* Fazer com que os endpoints retornem tudo o que qualquer cliente possa precisar, causando *over-fetching*, em que clientes mobile baixam megabytes de dados que não usam.

GraphQL consolida endpoints de recursos em um **único endpoint** que aceita *queries* descrevendo exatamente quais dados você quer. O cliente especifica o formato da resposta, e o servidor retorna os dados exatamente nesse formato.

### How GraphQL Works

Aqui vai um exemplo simples usando o nosso cenário da Ticketmaster. Em vez de endpoints REST separados para events, venues e tickets, você teria um único endpoint GraphQL capaz de lidar com queries assim:

```graphql
query {
  event(id: "123") {
    name
    date
    venue {
      name
      address
    }
    tickets {
      section
      price
      available
    }
  }
}
```

O servidor retorna exatamente o que você pediu, nem mais, nem menos. Se o app mobile precisa apenas de `name` e `date`, pode solicitar apenas esses campos. Se o dashboard web precisa de detalhes completos do evento com informações do venue e disponibilidade de ingressos, pode pedir tudo isso numa única query.

### When to Use GraphQL in Interviews

GraphQL é a escolha certa quando você tem clientes **diversos com necessidades de dados diferentes**. Se o entrevistador mencionar cenários como “o app mobile precisa de dados diferentes do app web” ou perguntar sobre “evitar over-fetching e under-fetching”, provavelmente está esperando que você cite GraphQL.

Também é uma boa escolha quando times de frontend precisam iterar rapidamente sem mudanças no backend. Com REST, adicionar um novo campo em uma tela mobile geralmente exige alterações no backend e novos deploys de API. Com GraphQL, o frontend pode pedir campos adicionais desde que eles existam no schema.

Por outro lado, GraphQL adiciona complexidade. Você precisa implementar parsing de queries, validação de schema e, muitas vezes, estratégias sofisticadas de cache. Para a maioria das entrevistas de system design, REST é mais simples e direto, a menos que o problema peça explicitamente a flexibilidade do GraphQL.

---

### GraphQL Schema Design

Se você escolher GraphQL, precisa pensar o design de forma diferente. Em vez de endpoints de recursos do REST, você projeta um **schema** que define seus tipos de dados e seus relacionamentos.

No exemplo Ticketmaster, você começaria modelando suas entidades centrais como tipos GraphQL:

```graphql
type Event {
  id: ID!
  name: String!
  date: DateTime!
  venue: Venue!
  tickets: [Ticket!]!
}

type Venue {
  id: ID!
  name: String!
  address: String!
}

type Query {
  event(id: ID!): Event
  events(limit: Int, after: String): [Event!]!
}
```

A diferença principal em relação ao REST é que você define os relacionamentos diretamente no schema. Um `Event` tem um `Venue`, e os clientes podem atravessar esse relacionamento em uma única query.

Mas essa flexibilidade cria o **problema N+1**, o principal “gotcha” do GraphQL. Quando um cliente consulta eventos com seus venues, você pode acabar executando uma query para os eventos e depois N queries separadas para cada venue. Com 100 eventos, isso dá 101 queries de banco em vez de 2. A solução é usar padrões de *batching* / *dataloader*, que agrupam consultas relacionadas, mas isso adiciona complexidade que você normalmente não tem com REST.

GraphQL também trata autorização de forma diferente. Em vez de proteger endpoints inteiros como no REST, você protege **campos individuais**. Um usuário pode ver o `name` e `date` de um evento, mas não os dados de `venue`. Você controla isso no nível de campo nos resolvers do schema.

Em entrevistas, mencione GraphQL quando você enxergar problemas claros de over-fetching ou under-fetching, mas não o escolha como padrão. A maioria dos entrevistadores gosta de ver que você conhece GraphQL, mas normalmente prefere que você resolva os desafios arquiteturais principais com ferramentas mais simples primeiro.

---

## RPC

RPC (Remote Procedure Call) é um protocolo que permite a um cliente chamar um procedimento em um servidor e esperar por uma resposta **sem** que o cliente precise entender os detalhes de rede por trás disso. É mais rápido que HTTP para comunicação entre serviços, especialmente quando você precisa de alta performance e baixa latência.

### How RPC Works

Ao contrário da abordagem orientada a recursos do REST, RPC é orientado a **ações**. Você está essencialmente chamando funções através da rede como se fossem funções locais no seu código. Veja como as mesmas operações da Ticketmaster podem parecer com RPC:

```text
// Em vez de GET /events/123
getEvent(eventId: "123")

// Em vez de POST /events/123/bookings
createBooking(eventId: "123", userId: "456", tickets: [...])

// Em vez de GET /events/123/tickets
getAvailableTickets(eventId: "123", section: "VIP")
```

O protocolo RPC mais popular hoje é o **gRPC**, que usa **Protocol Buffers** para serialização e **HTTP/2** para transporte. Essa combinação é muito mais rápida que o JSON-sobre-HTTP do REST, especialmente para comunicação serviço-a-serviço. Outro framework RPC notável é o **Apache Thrift**, originalmente desenvolvido no Facebook e hoje open source, que suporta múltiplas linguagens de programação e formatos de serialização.

---

### Protocol Buffers and Type Safety

gRPC usa Protocol Buffers (*protobuf*) para definir contratos de serviço. Você escreve um arquivo `.proto` que descreve os métodos do serviço e suas estruturas de dados:

```proto
service TicketService {
  rpc GetEvent(GetEventRequest) returns (Event);
  rpc CreateBooking(CreateBookingRequest) returns (Booking);
  rpc GetAvailableTickets(GetTicketsRequest) returns (TicketList);
}

message GetEventRequest {
  string event_id = 1;
}

message Event {
  string id = 1;
  string name = 2;
  int64 date = 3;
  Venue venue = 4;
}
```

A partir dessa única definição, o gRPC gera código de cliente e servidor em múltiplas linguagens. Isso significa que o seu serviço backend em Go e o seu serviço de pagamentos em Java podem se comunicar com segurança de tipos em tempo de compilação, detectando incompatibilidades antes do deploy.

---

### When to Use RPC in Interviews

RPC brilha em arquiteturas de **microservices**, onde os serviços precisam se comunicar com frequência e de forma eficiente. Se o entrevistador mencionar comunicação interna entre serviços, requisitos de alta performance ou ambientes *polyglot* (serviços em linguagens diferentes), RPC provavelmente é uma boa escolha.

Considere RPC quando:

* **Performance é crítica**: serialização binária e HTTP/2 tornam RPC significativamente mais rápido que REST com JSON
* **Segurança de tipos é importante**: código de cliente gerado evita muitos erros em tempo de execução
* **Comunicação serviço-a-serviço**: APIs internas entre serviços próprios não precisam da semântica de recursos do REST
* **Streaming é necessário**: gRPC suporta streaming bidirecional para recursos em tempo real

No nosso exemplo Ticketmaster, você pode usar **REST** para APIs públicas consumidas por apps mobile e web, mas usar **gRPC** para comunicação interna entre os serviços de reservas, pagamentos e inventário.

A menos que seja explicitamente solicitado, você normalmente não detalha suas APIs internas durante a etapa de API da entrevista. Em vez disso, foca apenas nas APIs voltadas ao usuário. No máximo, você menciona que os serviços internos se comunicam via RPC durante o desenho de alto nível.

---

## Common API Patterns

Independentemente de você escolher REST, GraphQL ou RPC, há padrões que se aplicam a todos os tipos de API. Vale a pena conhecê-los, pois aparecem na maioria dos sistemas reais.

### Pagination

Quando você lida com grandes volumes de dados, não pode retornar tudo de uma vez. Imagine uma API que retorna **todos** os eventos já criados – isso pode significar milhões de registros, ou vários gigabytes de dados.

Em vez disso, você precisa de paginação para quebrar resultados grandes em blocos gerenciáveis. Há duas abordagens principais: **offset-based** e **cursor-based**.

#### Offset-based Pagination

Paginação baseada em offset é a abordagem mais simples e usada pela maioria dos sites. Você especifica quantos registros pular e quantos retornar:

```text
/events?offset=20&limit=10   // retorna os registros 21–30
```

É intuitivo e fácil de implementar, mas tem problemas com grandes conjuntos de dados. Se alguém adiciona um novo evento enquanto você está paginando pelos resultados, pode acabar vendo duplicatas ou perdendo registros à medida que os dados “se movem”.

#### Cursor-based Pagination

Paginação baseada em cursor resolve isso usando um **ponteiro para um registro específico** em vez de contar desde o começo. Na prática:

* Primeira requisição:

  ```http
  /events?limit=10
  ```

* A resposta inclui os eventos mais um cursor apontando para o último registro:

  ```json
  {
    "events": [...],
    "next_cursor": "cmd9atj3p000007ky19w1dpy2"
  }
  ```

* Próxima requisição:

  ```http
  /events?cursor=cmd9atj3p000007ky19w1dpy2&limit=10
  ```

O cursor normalmente é uma referência codificada para um registro específico (como um ID ou timestamp). Isso é mais estável porque não é afetado por novos registros sendo adicionados, mas é mais difícil implementar recursos como “pular para a página 5”. No exemplo, `cmd9atj3p000007ky19w1dpy2` é o ID do último evento da primeira página.

Para entrevistas, paginação baseada em offset geralmente é suficiente, a menos que você esteja lidando com dados em tempo real ou o entrevistador pergunte especificamente sobre cenários de alto volume. A maioria quer apenas ver que você **lembrou de incluir paginação**, não qual abordagem específica escolheu.

---

### Versioning Strategies

APIs evoluem com o tempo e você precisa de uma estratégia para lidar com mudanças sem quebrar clientes existentes. Isso é especialmente importante em APIs públicas, onde você não controla quando os clientes atualizam seus códigos.

A abordagem mais comum é **versionar na URL**, incluindo o número da versão no caminho: `/v1/events` ou `/v2/events`. Isso é explícito e fácil de entender. Os clientes sabem exatamente qual versão estão usando só de olhar a URL. Também é simples de implementar, já que você pode rotear versões diferentes para caminhos de código diferentes.

**Versionamento por header** coloca a versão em um cabeçalho HTTP, por exemplo: `Accept-Version: v2` ou `API-Version: 2`. Isso mantém as URLs mais limpas e segue melhor os padrões HTTP, mas é menos óbvio para desenvolvedores e mais difícil de testar em navegadores.

Em entrevistas, **versionamento na URL** costuma ser a escolha mais segura por ser mais amplamente entendido e fácil de explicar rapidamente. A menos que o entrevistador pergunte especificamente sobre versionamento por header, fique com a abordagem via URL.

Você vai notar que em nossos *breakdowns* nem incluímos versionamento no design de API. Isso acontece mais porque não é algo importante para a maioria dos entrevistadores do que por não ser importante na prática (é importante).

---

## Security Considerations

Segurança muitas vezes é tratada como pós-pensamento em entrevistas, mas demonstrar consciência de segurança pode destacar você. Você não precisa projetar um sistema à prova de balas, mas mostrar que entende princípios básicos de segurança em APIs indica que pensa em sistemas prontos para produção.

### Authentication and Authorization

A primeira pergunta que sua API precisa responder é:

> “Quem está fazendo esta requisição, e essa pessoa pode fazer o que está pedindo?”

* **Authentication** verifica a identidade – prova que o usuário é quem diz ser.
* **Authorization** verifica permissões – checa se o usuário autenticado pode realizar a ação que está pedindo.

No nosso exemplo Ticketmaster, autenticação pode verificar que a requisição vem do usuário `john@example.com`, enquanto autorização verifica se o John pode cancelar a reserva específica que ele está tentando cancelar (ele só deveria poder cancelar as reservas dele, não as de todo mundo).

---

### API Keys vs JWT Tokens

Ao desenhar autenticação para sua API, você normalmente escolhe entre duas abordagens dependendo de **quem** vai usar sua API e **como** ela será acessada.

Na maioria (mas não todas) das entrevistas, autenticação e autorização não são o foco. Meu conselho é mencionar quais endpoints exigem usuário autenticado e dizer que você usaria um JWT ou armazenaria a sessão do usuário em um banco para autenticar.

#### API Keys

API keys são strings longas e aleatórias que funcionam como senhas para aplicações, não para humanos. Quando um cliente faz uma requisição, ele inclui sua API key no header `Authorization`, e o servidor procura essa chave para identificar qual aplicação está fazendo a chamada.

Como funciona: você gera uma API key única para cada cliente (algo como `sk_live_abc123def456...`), armazena isso no seu banco junto com permissões e limites de uso, e depois verifica cada requisição recebida olhando essa chave. Elas são perfeitas para comunicação **server-to-server**, onde você controla os dois lados. Quando seu serviço de reservas precisa chamar seu serviço de pagamentos, uma API key é simples e eficiente. Também faz sentido quando você expõe seus endpoints para desenvolvedores terceiros que precisam de acesso programático ao seu sistema.

Se você estiver construindo um produto voltado ao usuário final, com APIs expostas ao usuário, API keys quase nunca são a escolha certa. Usuários não deveriam gerenciar strings criptográficas enormes, e API keys normalmente não expiram nem carregam contexto de usuário da forma que sessões de usuário precisam.

```http
GET /events
Authorization: Bearer sk_live_abc123...
```

#### JWT (JSON Web Tokens)

Tokens JWT, por outro lado, codificam informações do usuário diretamente dentro do token, em vez de armazenar o estado da sessão no servidor. Quando um usuário faz login com sucesso, o servidor cria um JWT contendo seu ID, permissões e tempo de expiração, depois assina o token inteiro com uma chave secreta.

Quando esse JWT volta em requisições futuras, você pode verificar se é autêntico checando a assinatura e ler as informações do usuário diretamente do token, sem *lookups* no banco. O token carrega todo o contexto de que você precisa para autorizar a requisição.

JWTs funcionam muito bem em sistemas distribuídos porque qualquer serviço que conheça a chave de assinatura pode validar os tokens de forma independente. Se o app mobile envia um JWT para o seu API Gateway, o gateway pode verificar a identidade do usuário e encaminhar a requisição para o serviço de reservas com confiança.

Exemplo de payload JWT:

```json
{
  "user_id": "123",
  "email": "john@example.com",
  "role": "customer",
  "exp": 1640995200
}
```

Use **API keys** para comunicação interna entre serviços e para acesso de desenvolvedores externos. Use **JWT tokens** para sessões de usuários em aplicações web e mobile. Tokens JWT podem ser *stateless* (sem consulta ao banco) e carregar contexto de usuário, o que os torna ideais para aplicações voltadas ao usuário final.

---

### Role-Based Access Control (RBAC)

Sistemas reais têm tipos diferentes de usuários com permissões diferentes. No nosso sistema Ticketmaster, clientes podem reservar ingressos e visualizar suas reservas, gerentes de local (*venue managers*) podem criar eventos e ver relatórios de vendas, e administradores do sistema podem acessar tudo.

RBAC atribui **roles** a usuários e **permissões** a roles:

**Roles:**

* `customer`: pode reservar ingressos, ver suas próprias reservas
* `venue_manager`: pode criar eventos, ver vendas dos seus venues
* `admin`: pode acessar tudo

**Mapeamento de usuários:**

* Usuário: `john@example.com` → Role: `customer`
* Usuário: `manager@venue.com` → Role: `venue_manager`

No design da API, você verificaria tanto autenticação quanto autorização:

```http
GET /bookings/{id}
1. O usuário está autenticado? (JWT válido)
2. O usuário está autorizado? (é dono dessa reserva OU é admin)
```

Na entrevista, na maioria dos casos você só vai mencionar quais endpoints podem ser acessados por quais roles – e muitas vezes nem essa distinção é relevante para o problema central.

---

### Rate Limiting and Throttling

Rate limiting evita abuso ao restringir quantas requisições um cliente pode fazer em um determinado período de tempo. Isso protege seu sistema tanto de ataques maliciosos quanto de uso excessivo acidental.

Estratégias comuns incluem:

* Limites por usuário: 1000 requisições por hora por usuário autenticado
* Limites por IP: 100 requisições por hora para requisições não autenticadas
* Limites específicos por endpoint: 10 tentativas de reserva por minuto para evitar cambistas de ingressos (*ticket scalping*)

Você normalmente implementa rate limiting no nível do **API Gateway** ou usando *middleware* na sua aplicação. Quando os limites são excedidos, retorne um status `429 Too Many Requests`.

Em entrevistas, mencionar rate limiting mostra que você entende preocupações de produção, mas não gaste tempo desenhando algoritmos específicos, a menos que perguntem. Um simples “vamos implementar rate limiting para evitar abuso” geralmente é suficiente.

---

## Conclusion

O design de APIs em entrevistas de system design é sobre demonstrar **bom julgamento de engenharia**, não criar especificações perfeitas. Foque em:

* Escolher o protocolo certo para o seu caso (geralmente REST)
* Modelar claramente seus recursos
* Mostrar que entende o básico de autenticação e segurança

Na entrevista, é tudo questão de equilíbrio. Gaste tempo suficiente para mostrar que você sabe desenhar uma API razoável, mas não se prenda demais aos detalhes quando houver desafios arquiteturais maiores para resolver. O entrevistador quer ver que você consegue construir sistemas que funcionam, não que decorou cada código HTTP.

Na prática, candidatos erram mais por gastar **tempo demais** no design de API do que por investir pouco. Faça o melhor para não gastar mais que 5 minutos esboçando suas APIs na entrevista.
