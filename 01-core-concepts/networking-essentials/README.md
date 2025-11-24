# Core Concepts

## Networking Essentials

Aprenda as partes importantes de redes que você precisa conhecer para suas entrevistas de System Design

---

### Video Walkthrough

Assista ao autor explicar o problema passo a passo.

---

Rede (networking) é uma parte fundamental de system design: quase sempre você vai projetar sistemas compostos por dispositivos independentes que se comunicam por uma rede. Mas o campo de redes é vasto e complexo, e é fácil se perder (esse costuma ser um dos livros didáticos mais pesados na faculdade).

Neste guia, vamos cobrir as partes mais importantes de redes que você precisa saber para suas entrevistas de system design. Em mergulhos mais profundos, padrões e análises de problemas posteriores, vamos construir em cima desses fundamentos para resolver os desafios que você enfrentará ao projetar seus sistemas.

Para isso, vamos começar com os fundamentos de como redes funcionam, depois examinar protocolos-chave em diferentes camadas da pilha de rede. Para cada conceito, vamos cobrir seu propósito, como funciona e quando aplicá-lo nos seus designs. Tem muita coisa para ver, então vamos direto ao ponto!

Networking tende a ser um foco maior em entrevistas de infraestrutura e sistemas distribuídos. Para cargos de full-stack e voltados a produto, você provavelmente só vai precisar de um entendimento mais superficial dos conceitos de redes. Entender bem esses fundamentos já ajuda a tomar decisões melhores, mesmo que os detalhes minuciosos não sejam cobrados diretamente na entrevista.

Cada entrevistador é um pouco diferente, e se a pessoa acabou de sair de um plantão lidando com problemas de load balancer ou issues de CDN, você vai querer estar preparado para responder às perguntas e sondagens dela!

---

## Networking 101

No seu núcleo, redes tratam de conectar dispositivos e permitir que se comuniquem. Redes são construídas em uma arquitetura em camadas (o famoso “modelo OSI”), o que simplifica bastante o mundo para nós, desenvolvedores de aplicação, que ficamos no topo dessa pilha.

Na prática, as camadas de rede são abstrações que nos permitem raciocinar sobre a comunicação entre dispositivos em termos mais simples e relevantes para a aplicação. Assim, quando você faz uma requisição de página web, não precisa saber quais tensões elétricas representam 1 ou 0 no fio da rede (o hardware moderno é muito mais sofisticado do que isso!) — você só precisa saber como usar a próxima camada abaixo na pilha.

Pense nisso como quando você usa uma função de abertura de arquivo na sua linguagem de programação em vez de instruir manualmente o disco sobre como ler bytes de um setor físico.

---

### Networking Layers

Embora toda a pilha de rede seja fascinante, há três camadas principais que aparecem com mais frequência em entrevistas de system design. Vamos entrar em cada uma delas em detalhes, mas antes vamos falar rapidamente sobre o que essas camadas fazem e como trabalham juntas.

#### Camadas OSI

![Network Layers](/assets/core-concepts/networking-essentials/01-osi-layers.png)

##### Network Layer (Layer 3)

Nessa camada está o IP, o protocolo que cuida de roteamento e endereçamento. Ele é responsável por quebrar os dados em pacotes, encaminhar pacotes entre redes e oferecer entrega “best-effort” (melhor esforço) para qualquer endereço IP de destino na rede.

Embora existam outros protocolos nessa camada (como InfiniBand, muito usado em cargas massivas de treinamento de ML), o IP é de longe o mais comum em entrevistas de system design.

##### Transport Layer (Layer 4)

Nessa camada temos TCP, QUIC e UDP, que fornecem serviços de comunicação fim a fim. Pense neles como uma camada que adiciona recursos como confiabilidade, ordenação e controle de fluxo em cima da camada de rede.

##### Application Layer (Layer 7)

Na camada final estão os protocolos de aplicação como DNS, HTTP, WebSockets, WebRTC. Esses são protocolos comuns que se apoiam em TCP (ou UDP, no caso do WebRTC) para fornecer uma camada de abstração para diferentes tipos de dados normalmente associados a aplicações web. Vamos falar deles em detalhes.

Essas camadas trabalham juntas para viabilizar toda a nossa comunicação de rede. Para ver como elas interagem na prática, vamos passar por um exemplo concreto de como uma requisição web simples funciona.

---

### Exemplo: Uma Requisição Web Simples

Quando você digita uma URL no navegador, várias camadas de protocolos de rede entram em ação. Vamos decompor como essas camadas trabalham juntas para obter uma página web simples via HTTP sobre TCP.

Primeiro usamos DNS para converter um nome de domínio legível por humanos, como `hellointerview.com`, em um endereço IP como `32.42.52.62`. Em seguida, começa uma série de etapas cuidadosamente orquestradas: configuramos uma conexão TCP sobre IP, enviamos nossa requisição HTTP, recebemos uma resposta e finalizamos a conexão.

Em detalhes:

![Simple Web Request](/assets/core-concepts/networking-essentials/02-simple-http-request.png)


#### Simple HTTP Request

1. **DNS Resolution**:
   O cliente começa resolvendo o nome de domínio do site para um endereço IP usando o DNS (Domain Name System).

2. **TCP Handshake**:
   O cliente inicia uma conexão TCP com o servidor usando o *three-way handshake*:

   * **SYN**: o cliente envia um pacote SYN (*synchronize*) para o servidor solicitando a conexão.
   * **SYN-ACK**: o servidor responde com um pacote SYN-ACK (*synchronize-acknowledge*) para reconhecer a solicitação.
   * **ACK**: o cliente envia um pacote ACK (*acknowledge*) para estabelecer a conexão.

3. **HTTP Request**:
   Uma vez estabelecida a conexão TCP, o cliente envia uma requisição HTTP `GET` ao servidor para solicitar a página web.

4. **Server Processing**:
   O servidor processa a requisição, recupera a página solicitada e prepara uma resposta HTTP.

   > Esse costuma ser o único tipo de latência em que a maioria dos desenvolvedores pensa e sobre o qual sente que tem controle!

5. **HTTP Response**:
   O servidor envia a resposta HTTP de volta ao cliente, incluindo o conteúdo da página web solicitada.

6. **TCP Teardown**:
   Após a conclusão da transferência de dados, cliente e servidor encerram a conexão TCP usando um *four-way handshake*:

   * **FIN**: o cliente envia um pacote FIN (*finish*) ao servidor para encerrar a conexão.
   * **ACK**: o servidor reconhece o FIN com um ACK.
   * **FIN**: o servidor envia um FIN ao cliente para encerrar o lado dele da conexão.
   * **ACK**: o cliente reconhece o FIN do servidor com um ACK.

Não é tão comum hoje em Big Tech, mas já foi uma pergunta de entrevista bem popular pedir para o candidato detalhar “o que acontece quando você digita (por exemplo) `hellointerview.com` no navegador e pressiona Enter?”.

Detalhes como esses normalmente não fazem parte de entrevistas de system design, mas é útil entender o básico de redes — isso pode te poupar algumas dores de cabeça no trabalho!

---

### O que Observar Aqui

Embora os detalhes específicos dos *handshakes* e *teardowns* de TCP pareçam esotéricos para entrevistas, há algumas coisas importantes a observar que usaremos mais adiante:

1. **Como desenvolvedor de aplicação, podemos simplificar muito nosso modelo mental.**
   A aplicação pode assumir que os dados são transmitidos com certo grau de confiabilidade e ordenação: a camada TCP garante que os dados sejam entregues corretamente e em ordem, e informará a aplicação se algo não chegar.
   Também não precisamos nos preocupar em “encontrar” um servidor específico no mundo nem em gerar trens de pulsos elétricos para chegar até ele. Com DNS, fazemos o *lookup* do endereço IP; com IP, o hardware de rede entre nós, nosso ISP, *backbone* etc. cuida de rotear os dados até o destino. Ótimo!

2. **Embora conceitualmente tenhamos um único “request” e “response”, houve muito mais pacotes e requisições trocados entre servidores para isso acontecer.**
   Tudo isso introduz latência que podemos ignorar… até o momento em que não podemos mais. Quanto mais alto vamos na pilha, mais latência e processamento são necessários. Isso será relevante quando falarmos de load balancers em breve!

3. **A conexão entre cliente e servidor é um estado que ambos precisam manter.**
   A menos que usemos recursos como HTTP keep-alive ou multiplexação do HTTP/2, precisamos repetir todo o processo de configuração de conexão para cada requisição — um overhead potencialmente significativo. Isso se torna importante ao projetar sistemas que precisam de conexões persistentes, como aqueles que lidam com atualizações em tempo real (*Realtime Updates*).

---
## Parte 2 — Network Layer Protocols (Protocolos da Camada de Rede)

A primeira camada da nossa jornada são os **protocolos da camada de rede**. Essa camada é dominada pelo protocolo **IP**, responsável por **roteamento e endereçamento**.

Em um sistema, nós (ou nossos servidores) normalmente recebemos endereços IP dinamicamente por meio de um **servidor DHCP** quando a máquina inicia. Esses endereços IP são arbitrários — eles só passam a ter significado quando informamos outras pessoas (ou serviços) sobre eles.

Por exemplo:
Eu posso criar uma rede privada com meus servidores e atribuir qualquer endereço IP que eu quiser para eles. Mas, se você quiser que tráfego da **internet** consiga encontrá-los, então você precisa usar **endereços IP roteáveis**, oficialmente alocados por uma **RIR (Regional Internet Registry)**.

Esses endereços atribuídos são chamados de **IPs públicos** e servem para identificar dispositivos na internet. O mais importante sobre eles é:

* A infraestrutura global de roteamento da internet é totalmente otimizada para trafegar pacotes entre esses IPs.
* Ela *sabe onde eles estão*.

Por exemplo:
Qualquer endereço que comece com `17.` (como `17.0.0.0`) pertence à Apple. Os roteadores do backbone da internet sabem que, para enviar pacotes destinados a esses endereços, devem encaminhá-los para os roteadores da Apple.

Existe muito mais sobre roteamento na internet (BGP, ASN, políticas e anúncios de rota...) mas para nossa finalidade aqui — **system design** — podemos manter simples e subir uma camada na pilha: a **camada de transporte**.

---

## Transport Layer Protocols (Protocolos da Camada de Transporte)

A camada de transporte é onde estabelecemos a **comunicação fim a fim entre aplicações**. Ela transforma um amontoado de pacotes desordenados da camada de rede em algo mais utilizável, oferecendo garantias importantes.

Os três protocolos mais importantes desta camada são:

* **TCP**
* **UDP**
* **QUIC**

Cada um com características próprias que os tornam adequados para casos de uso diferentes.

Em praticamente todas as entrevistas de system design, a escolha real que você enfrenta é entre:

### ✔ **TCP** versus **UDP**

O **QUIC** é relativamente novo, oferecendo benefícios semelhantes ao TCP com modernizações e melhorias de desempenho — mas ainda não é onipresente. Para efeito de entrevistas, podemos tratá-lo como:

> “Um TCP melhorado, mas ainda não universalmente adotado.”

Alguns entrevistadores mais focados em desempenho podem se impressionar se você mencionar QUIC e HTTP/3, mas grande parte deles vai preferir que você dedique seu tempo a outras partes do design.

---

## UDP — Rápido, porém Não Confiável

O **User Datagram Protocol (UDP)** é o “metralhadora giratória” dos protocolos.

Ele oferece pouquíssimas funcionalidades além do IP, mas é **extremamente rápido**.
O termo certo é mesmo: *spray and pray*.

Ele fornece um serviço simples, sem conexão, **sem garantias**:

* Sem garantia de entrega
* Sem garantia de ordem
* Sem proteção contra duplicação

Quando sua aplicação recebe um datagrama UDP, ela pode ver:

* IP de origem + porta
* IP de destino + porta

E só. O resto é um *blob* binário.

### Características principais do UDP:

* **Connectionless** — não exige handshakes
* **Sem confiabilidade** — pacotes podem se perder
* **Sem ordenação** — pacotes podem chegar embaralhados
* **Baixa latência** — quase zero overhead

Sem necessidade de conexão parece ótimo, mas a falta de garantia e ordenação… nem tanto. Então, por que usar UDP?

UDP é perfeito quando **velocidade importa mais que confiabilidade**, como em:

* Streaming de vídeo ao vivo
* Jogos online
* VoIP
* Resoluções DNS

Nesses casos, a aplicação pode tolerar perda ou desordem ocasional.

### Exemplo — VoIP

Se alguns pacotes se perderem, o usuário talvez só note um pequeno *glitch* no áudio — ainda melhor do que parar tudo para retransmitir pacotes atrasados.

#### Importante: navegadores têm suporte mínimo a UDP

O único suporte real é via **WebRTC**.
Se você pensa em usar UDP em um sistema com usuários web, precisará de estratégia alternativa.

---

## TCP — Confiável, porém com Overhead

O **Transmission Control Protocol (TCP)** é o cavalo de batalha da internet.

Ele fornece:

* Confiabilidade
* Ordenação
* Checagem de erros
* Controle de fluxo
* Controle de congestionamento

E isso vem ao custo de overhead e latência.

Ele estabelece uma conexão por meio de um **three-way handshake**, mantém o estado ao longo da sessão e garante que todos os pacotes sejam entregues e na ordem correta.

Essa conexão é chamada de **stream**.

### Características principais do TCP:

* **Orientado à conexão**
* **Entrega confiável**
* **Garantia de ordenação**
* **Controle de fluxo**
* **Controle de congestionamento**

TCP é ideal quando **integridade dos dados é crítica**, ou seja: quase tudo que não cabe no modelo UDP.

---

## Quando usar cada protocolo?

### Use **UDP** quando:

* Latência mínima é crucial
* Alguma perda de dados é aceitável
* Você tem alto volume de telemetria/logs
* Você não precisa suportar navegadores (ou tem fallback)

### Use **TCP** quando:

* Você não tem motivo forte para usar UDP
* Confiabilidade importa
* A ordem importa
* Sua aplicação é web tradicional

Em entrevistas, **assuma TCP como padrão**, a menos que diga o contrário.

Se conseguir argumentar corretamente quando UDP faz mais sentido, você ganha pontos extras.

---

## Comparação TCP vs UDP

| Característica        | UDP                    | TCP                   |
| --------------------- | ---------------------- | --------------------- |
| Conexão               | Sem conexão            | Orientado à conexão   |
| Confiabilidade        | Best-effort            | Entrega garantida     |
| Ordenação             | Não garante            | Garante               |
| Controle de fluxo     | Não                    | Sim                   |
| Controle de congestão | Não                    | Sim                   |
| Tamanho do cabeçalho  | 8 bytes                | 20–60 bytes           |
| Velocidade            | Mais rápido            | Mais lento (overhead) |
| Uso ideal             | Streaming, VoIP, jogos | Quase tudo            |

---

## Application Layer Protocols (Protocolos da Camada de Aplicação)

Agora subimos para a camada onde desenvolvedores passam a maior parte do tempo: a **Application Layer**.

Esses protocolos definem **como aplicações se comunicam** e são construídos em cima dos protocolos de transporte (TCP/UDP).

Normalmente, a camada de aplicação roda em **User Space**, enquanto as camadas inferiores (L3–L4) rodam no **Kernel Space**, o que significa:

* Camadas de aplicação são fáceis de modificar
* Camadas inferiores são difíceis de alterar, mas extremamente eficientes

A seguir, vamos explorar os protocolos mais comuns:

* **HTTP/HTTPS**
* **REST**
* **GraphQL**
* **gRPC**

## Parte 3 — Application Layer Protocols (HTTP/HTTPS, REST)

Agora entramos na camada onde a maior parte dos desenvolvedores realmente vive: **a camada de aplicação**. É aqui que encontramos os protocolos que usamos todos os dias — HTTP, REST, GraphQL, gRPC — que definem como aplicações conversam umas com as outras.

Lembre-se:

* As camadas inferiores (L3 e L4) são rápidas e eficientes, mas rígidas.
* A camada de aplicação é mais flexível, roda em **User Space** e pode ser adaptada sem precisar alterar o sistema operacional.

Vamos começar com o mais importante:

---

# HTTP/HTTPS — A Base da Web

O **Hypertext Transfer Protocol (HTTP)** é o padrão absoluto de comunicação de dados na web.
Ele segue o modelo **request–response**:

1. O cliente envia uma requisição HTTP
2. O servidor responde com uma resposta HTTP

E é **stateless** (sem estado):
Cada requisição é independente e o servidor não precisa lembrar nada sobre requisições anteriores.

Isso é muito desejável em system design, já que sistemas sem estado (**stateless**) são mais fáceis de escalar horizontalmente.

---

## Exemplo simples de Request/Response

```http
GET /index.html HTTP/1.1
Host: example.com
User-Agent: Chrome
Accept: text/html
```

```http
HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 1024

<html>...</html>
```

Nesta troca vemos:

* **Métodos/Verbos**: GET, POST, PUT, DELETE
* **Status Codes**: 200, 404, 500 etc.
* **Headers**: metadados
* **Body**: conteúdo real

---

# Métodos HTTP comuns

### **GET**

Busca dados. Não deve modificar nada. Deve ser idempotente.

### **POST**

Envia dados. Usado para criar recursos. Não é idempotente.

### **PUT**

Atualiza um recurso existente. Deve ser idempotente.

### **PATCH**

Atualiza parcialmente um recurso.

### **DELETE**

Remove um recurso. Deve ser idempotente.

---

# Status Codes mais usados

### **2xx — Sucesso**

* **200 OK**
* **201 Created**

### **3xx — Redirecionamento**

* **301 Moved Permanently**
* **302 Found**

### **4xx — Erro do Cliente**

* **404 Not Found**
* **401 Unauthorized**
* **403 Forbidden**
* **429 Too Many Requests**

### **5xx — Erro do Servidor**

* **500 Internal Server Error**
* **502 Bad Gateway**

---

# Headers HTTP — Flexíveis e Poderosos

Headers funcionam como pares chave/valor, permitindo enorme flexibilidade.

Um excelente exemplo de design é **Content Negotiation**, onde o cliente informa o que aceita receber:

```http
Accept-Encoding: gzip, br
```

O servidor pode então responder com:

```http
Content-Encoding: br
```

Isso permite compactação moderna, fallback, compatibilidade etc.

---

# HTTPS — Segurança com TLS/SSL

HTTPS é simplesmente HTTP + criptografia TLS.

Ele adiciona:

* Criptografia ponta a ponta
* Integridade
* Autenticação do servidor

Se você está construindo algo público, **HTTPS é obrigatório**.

⚠️ Mas cuidado:
Mesmo com HTTPS, **o servidor nunca deve confiar no corpo da requisição** sem validação.
Exemplo clássico de erro:

> O cliente envia `userId = 123` no body
> O back-end usa esse ID para consultar o banco
> Um atacante muda o ID para 999 e acessa dados de outra pessoa

Por isso:

* Sempre valide quem é o usuário autenticado no servidor
* Nunca confie apenas nos dados enviados pelo cliente

---

# REST — Simples, Flexível e Perfeito para Entrevistas

REST é o paradigma mais comum para APIs em entrevistas de System Design.

Ele se baseia em:

* **Recursos** (resources)
* **Operações sobre recursos** (GET, POST, PUT, DELETE)
* **Representações** (normalmente JSON)

REST combina muito bem com a estrutura do HTTP e é fácil de entender, usar e escalar.

---

## Exemplo simples de RESTful API

### **Buscar usuário**

```
GET /users/{id} → User
```

### **Atualizar usuário**

```
PUT /users/{id} → User
{
  "username": "john.doe",
  "email": "john.doe@example.com"
}
```

### **Criar usuário**

```
POST /users → User
{
  "username": "stefan.mai",
  "email": "stefan@hellointerview.com"
}
```

### **Recursos aninhados**

```
GET /users/{id}/posts → [Post]
```

---

# Importante: Operações ≠ Recursos

Engenheiros costumam pensar em funções como:

* updateUser
* startGame

Mas isso não é RESTful.

REST deve refletir **recursos**:

* `PUT /users/{id}`
* `PATCH /games` com `{ "status": "started" }`

---

# Onde Usar REST

REST é excelente para:

* CRUD
* Microserviços padrão
* Web e mobile
* APIs públicas
* Sistemas que não precisam de altíssima performance

REST **não** é ideal para:

* Alto throughput extremo
* Baixa latência crítica
* Comunicação binária compacta

Mas para **entrevistas**, REST é quase sempre o **padrão default**.

---
## Parte 4 — GraphQL (Flexible Data Fetching)

O **GraphQL** é um paradigma mais recente de APIs (open-source desde 2015, criado pelo Facebook) que permite ao cliente pedir **exatamente os dados que precisa**, nada mais e nada menos.

Ele resolve problemas bem comuns em APIs REST tradicionais, especialmente quando o frontend precisa montar telas complexas com múltiplas fontes de dados.

---

# O Problema que o GraphQL Resolve

Em times tradicionais, temos:

* **Frontend** (web/mobile)
* **Backend** (API + banco de dados)

Quando o frontend precisa montar uma página complexa, surgem três problemas clássicos:

---

## 1. **Under-Fetching**

O frontend precisa fazer **várias requisições** porque cada endpoint entrega uma parte da informação.

**Exemplo:**
Para exibir uma lista de usuários com detalhes, precisa:

* `/users`
* `/users/{id}/profile`
* `/users/{id}/groups`
* `/users/{id}/status`

Resultado:
Muitos round-trips → mais latência → tela lenta.

---

## 2. **Over-Fetching**

O backend tenta “prever o futuro” e cria endpoints gigantes para evitar múltiplas requisições.

Só que:

* Traz dados demais
* As respostas ficam pesadas
* A API fica lenta
* O frontend recebe coisas que nem usa

---

## 3. Criar **novas APIs** para cada nova tela

Os times começam a criar endpoints específicos (“tela home”, “tela de dashboard”, “tela perfil”), gerando:

* Manutenção difícil
* Explosão de endpoints
* Rigidez
* Mudanças lentas

---

# GraphQL resolve tudo isso

GraphQL permite que o frontend diga:

> “Quero estes campos, nestes objetos, nestas relações.”

E o backend retorna **somente isso**, no formato exato.

---

# Exemplo de Query GraphQL

```graphql
query GetUsersWithProfilesAndGroups($limit: Int = 10, $offset: Int = 0) {
  users(limit: $limit, offset: $offset) {
    id
    username
    
    profile {
      id
      fullName
      avatar
    }
    
    groups {
      id
      name
      description
      
      category {
        id
        name
        icon
      }
    }
    
    status {
      isActive
      lastActiveAt
    }
  }
  
  _metadata {
    totalCount
    hasNextPage
  }
}
```

Essa única query substitui **dezenas de chamadas REST**.
O backend interpreta a consulta, busca os dados necessários e retorna **somente os campos solicitados**.

---

# Quando Usar GraphQL

GraphQL brilha quando:

* O frontend muda rápido
* Existem múltiplas telas diferentes
* A quantidade de dados enviados precisa ser otimizada
* O app é mobile (economia de banda → mais rápido)
* Muitos times consomem a mesma API
* O cliente precisa fazer queries complexas e profundas

Também funciona muito bem quando:

* Os dados têm relações ricas (User → Profile → Groups → Category)

---

# Desvantagens (Importante para entrevistas!)

Embora GraphQL seja poderoso, há trade-offs:

### ❌ Backend mais complexo

Resolvers podem gerar consultas ruins se não forem bem otimizados.

### ❌ Pode causar *N+1 queries*

Erro clássico: fazer 300 consultas em vez de 1 JOIN.

### ❌ Pode introduzir latência extra

Por exigir parsing e interpretação da query.

### ❌ Não é ideal para throughput altíssimo

REST ou gRPC geralmente vencem nesse caso.

---

# GraphQL em Entrevistas de System Design

Em entrevistas, o uso de GraphQL pode ser uma faca de dois gumes:

### 👍 Quando mencionar

* O entrevistador pede **flexibilidade**
* Os requisitos mudam rápido
* A aplicação é um app mobile
* O frontend é complexo e requer granularidade

### 👎 Quando NÃO mencionar

* O problema é sobre alta performance
* Há muito tráfego interno entre microserviços
* O entrevistador está perguntando sobre otimizações de queries
* A API é pública
* O problema é relativamente simples (ex: CRUD direto)

---

# Resumo: GraphQL

| Vantagem                  | Significado                           |
| ------------------------- | ------------------------------------- |
| Flexível                  | Cliente pede só o que precisa         |
| Altamente adaptável       | Ideal para apps em rápida evolução    |
| Evita under/over-fetching | Melhor experiência no frontend        |
| Perfeito para mobile      | Respostas menores e rápidas           |
| Útil em times grandes     | API única para múltiplos consumidores |

| Desvantagem                       | Significado                        |
| --------------------------------- | ---------------------------------- |
| Backend complexo                  | Resolvers, performance, N+1        |
| Pode ser mais lento               | Interpretação da query             |
| Não ideal para throughput extremo | Melhor usar REST/gRPC              |
| Curva de aprendizado maior        | Devs precisam conhecer a linguagem |

---

## “GraphQL ou REST?” — resposta ideal em entrevista

> *"REST é meu padrão; eu só usaria GraphQL se o problema claramente exigir flexibilidade no consumo dos dados ou se o entrevistador mencionar requisitos voláteis no frontend."*

Perfeito.
Essa frase mostra maturidade e senso de trade-off.

---

## Parte 5 — gRPC (Efficient Service Communication)

O **gRPC** é um framework de **RPC (Remote Procedure Call)** criado pelo Google.
Ele é:

* Extremamente rápido
* Baseado em HTTP/2
* Usa **Protocol Buffers** (protobuf) como formato de serialização
* Ideal para comunicação entre microserviços

Pense nele como:

> **“REST + JSON, mas muito mais rápido, mais leve e com tipos fortes.”**

---

# Por que usar Protocol Buffers?

Protocol Buffers são uma alternativa ao JSON:

### JSON (texto):

* Fácil de ler
* Mas pesado
* Tem esquema implícito
* Converte/parsing custa CPU
* Tamanho maior

### Protobuf (binário):

* Muito leve
* Performático
* Estrutura rígida (esquema fixo)
* Mais rápido para serializar/deserializar
* Muito menor em bytes

---

# Exemplo: JSON vs Protobuf

### JSON (40 bytes)

```json
{
  "id": "123",
  "name": "John Doe"
}
```

### Protobuf (15 bytes)

```
0A 03 31 32 33 12 08 6A 6F 68 6E 20 64 6F 65
```

(Esse conteúdo binário representa exatamente os mesmos dados.)

O Protobuf é menor, mais rápido e mais eficiente.

---

# Exemplo de mensagem Protobuf

```protobuf
message User {
  string id = 1;
  string name = 2;
}
```

As tags (`= 1`, `= 2`) determinam o identificador de cada campo no formato binário.

---

# Exemplo de um serviço gRPC

```protobuf
message GetUserRequest {
  string id = 1;
}

message GetUserResponse {
  User user = 1;
}

service UserService {
  rpc GetUser (GetUserRequest) returns (GetUserResponse);
}
```

Depois, o compilador `protoc` gera automaticamente:

* client stubs (clientes)
* server stubs (servidores)

em várias linguagens:

* Java
* Python
* Go
* C#
* Node.js
* C++

Com isso, você escreve apenas **a lógica** — o restante (serialização, transporte, parsing) é automático.

---

# Recursos importantes do gRPC

Além de ser binário e rápido, o gRPC oferece:

* **Streaming bidirecional**
* **Streaming server-side**
* **Streaming client-side**
* **Deadlines / timeouts integrados**
* **Client-side load balancing**
* **Compressão opcional**
* **Schemas fortemente tipados**
* **Alta performance**

Ele foi projetado para grandes sistemas distribuídos e microserviços em alta escala (Google, Netflix, Lyft, etc. usam muito).

---

# Quando usar gRPC

Ideal para:

* Comunicação **entre microserviços internos**
* Ambientes com throughput alto
* Serviços que trocam muita informação binária
* Cenários onde a latência é crítica
* Infraestruturas com volume muito alto

gRPC é **perfeito** quando:

* Você controla o cliente e o servidor
* Não existe necessidade de interoperar com navegadores
* Você quer forte tipagem entre times/línguas diferentes

---

# Quando NÃO usar gRPC

Evite gRPC quando:

### ❌ A API é pública

Clientes externos não têm suporte universal ao gRPC.

### ❌ Clientes incluem navegadores

Browsers **não suportam gRPC nativamente**.
Eles suportam **apenas gRPC-web** (que não é exatamente o mesmo protocolo).

### ❌ Você precisa debugar com facilidade

Mensagens binárias não são tão humanamente legíveis quanto JSON.

### ❌ A equipe não domina Protobuf

A curva de aprendizado pode atrapalhar projetos simples.

---

# “gRPC no lado interno e REST no lado externo”

Esse é um padrão extremamente comum:

```
  [Client Web/Mobile]  → REST/HTTP →  [API Gateway]  → gRPC → [Microservices]
```

Usar:

* **REST** para consumo externo
* **gRPC** para comunicação interna

combina:

* facilidade do JSON
* velocidade do gRPC
* tipagem forte
* alta performance interna

É o melhor dos dois mundos.

---

# Melhor resposta para uma entrevista

Se o entrevistador perguntar sobre protocolos de serviço a serviço:

> *"Eu usaria REST para APIs públicas e gRPC para comunicação interna entre microserviços, já que gRPC oferece menor latência, melhor throughput e forte tipagem."*

Simples, correto, elegante.

---

# Resumo

| Característica | REST          | gRPC                   |
| -------------- | ------------- | ---------------------- |
| Protocolo      | HTTP 1.1      | HTTP/2                 |
| Formato        | JSON          | Protobuf (binário)     |
| Performance    | Média         | Muito alta             |
| Streaming      | Limitado      | Completo               |
| Tipagem        | Fraca         | Forte                  |
| Navegadores    | Suporte total | Não suportado          |
| Ideal para     | APIs públicas | Microserviços internos |

---

## Parte 6 — SSE (Server-Sent Events)

Agora entramos nos protocolos usados para **atualizações em tempo real**.
O primeiro deles é o **SSE — Server-Sent Events**.

Ele é extremamente útil e, ao mesmo tempo, muito mal compreendido em entrevistas.
Vamos destrinchar sem complicação.

---

# O que é SSE?

SSE é um mecanismo baseado em **HTTP** que permite que o servidor envie **várias mensagens ao cliente ao longo do tempo**, usando **uma única conexão HTTP**.

Pense assim:

> “É um hack muito inteligente em cima do HTTP que transforma uma resposta única em um fluxo contínuo de eventos.”

SSE é:

* unidirecional (servidor → cliente)
* persistente
* baseado em texto
* muito simples de usar
* totalmente suportado em navegadores

---

# Sem SSE — como seria?

Normalmente:

* o cliente faz um request HTTP
* o servidor devolve **um único JSON**
* a conexão fecha

Exemplo:

```json
{
  "events": [
    { "id": 1, "description": "Event 1" },
    { "id": 2, "description": "Event 2" }
  ]
}
```

Isso não funciona para **real-time**, porque:

* você precisa esperar o JSON inteiro chegar
* você não recebe eventos “ao vivo”
* se o servidor ficar gerando novos eventos, teria que refazer a requisição continuamente

---

# Com SSE — fluxo contínuo de eventos

O servidor envia:

```
data: {"id": 1, "description": "Event 1"}
data: {"id": 2, "description": "Event 2"}
data: {"id": 3, "description": "Event 3"}
```

Cada linha é **um evento separado**.
O navegador recebe cada evento **instantaneamente** e processa na hora.

E tudo isso ocorre:

* usando **um único request HTTP**
* sobre **uma única conexão TCP**
* sem WebSockets
* sem polling
* sem complexidade

---

# Como funciona no navegador?

```javascript
const events = new EventSource("/stream");

events.onmessage = (event) => {
  console.log("Evento recebido:", event.data);
};
```

Simples assim.

O navegador:

* abre uma conexão HTTP
* mantém a conexão aberta
* processa cada linha “data: …”
* reabre automaticamente se cair (com cabeçalho `Last-Event-ID`)

---

# Por que usar SSE?

📌 **Perfeito para:**

* notificações
* contadores ao vivo
* eventos de log
* atualizações incrementais
* dashboards
* preços em tempo real
* atualizações de leilões
* sistemas de streaming de eventos simples

📌 **Muito mais simples que WebSockets**, quando só precisamos de push unidirecional.

📌 **Totalmente suportado em browsers**, ao contrário de gRPC.

📌 **Excelente para entrevistas** — quase sempre o entrevistador aceita SSE como solução elegante.

---

# Limitações (importantes em entrevistas)

SSE parece perfeito… mas tem limitações reais:

### ❌ Não é bidirecional

Para enviar dados do cliente → servidor, você ainda precisa de HTTP normal.

### ❌ Conexões podem ser finalizadas por load balancers

Alguns middle boxes fecham conexões “longas”.

### ❌ Alguns proxies acumulam o stream

Transformando SSE em um grande JSON único (causando latência enorme).

### ❌ Não é adequado para milhares de conexões simultâneas por servidor

WebSockets ou sistemas dedicados podem ser melhores.

### ❌ Não funciona com HTTP/2 multiplexado como WebSockets

Cada EventSource ainda requer 1 conexão.

Mas:
**a maioria das entrevistas finge que essas limitações não existem.**

---

# Reconexão automática

Uma das partes mais legais do SSE é a reconexão automática:

* O cliente reconecta sozinho
* Envia `Last-Event-ID`
* O servidor deve reenviar eventos perdidos

Isso deixa a experiência robusta sem esforço.

---

# Quando usar SSE em uma entrevista

SSE é um excelente ponto médio entre:

* **Long Polling** (simples, porém ineficiente)
* **WebSockets** (poderosos, porém complexos e caros)

Use SSE quando:

✔ só precisamos de servidor → cliente
✔ não queremos criar um protocolo customizado
✔ atualizações são frequentes mas não massivamente intensivas
✔ queremos simplicidade
✔ estamos fazendo um marketplace, leilão, chat “básico”, telemetria, contadores, etc.

Nunca use SSE quando:

❌ precisamos de comunicação bidirecional
❌ estamos criando um jogo em tempo real
❌ o problema envolve infraestrutura que não gosta de conexões persistentes
❌ o entrevistador pede explicitamente WebSockets

---

# A frase perfeita para a entrevista

> **“Se precisamos apenas de push do servidor para o cliente, usaria SSE. É leve, funciona via HTTP e todos os navegadores suportam nativamente.”**

Mostra clareza, maturidade e senso de trade-off.

---
## Parte 7 — WebSockets (Real-Time Bidirectional Communication)

Agora chegamos ao protocolo mais famoso quando falamos de **tempo real de verdade**: **WebSockets**.

Enquanto o SSE funciona muito bem para comunicação **unidirecional** (servidor → cliente), muitas aplicações precisam de:

* comunicação em tempo real
* baixa latência
* servidor → cliente
* cliente → servidor
* troca contínua de mensagens
* sem abrir novas conexões a cada envio

É aqui que WebSockets brilham.

---

# O que é WebSocket?

WebSockets fornecem uma **conexão persistente** bidirecional entre cliente e servidor.
Isso significa:

> Cliente e servidor podem enviar e receber mensagens a qualquer momento, sem precisar abrir novas conexões HTTP.

É como transformar uma conexão TCP em um “canal de chat” contínuo.

---

# Como o WebSocket funciona?

1. O cliente inicia uma conexão HTTP tradicional.
2. Envia um header especial:

   ```
   Connection: Upgrade
   Upgrade: websocket
   ```
3. O servidor aceita o *upgrade*
4. A conexão deixa de ser HTTP e vira WebSocket
5. A comunicação passa a ser **binária** e **persistente**
6. Cliente e servidor trocam mensagens livremente até alguém fechar

---

# Por que isso é útil?

Porque modelos HTTP tradicionais são:

* request → response
* fechou a conexão
* cliente precisa pedir novamente
* servidor nunca consegue iniciar comunicação sozinho

WebSockets mudam isso radicalmente.
É quase como se cliente e servidor estivessem em um chat privado, o tempo todo.

---

# Exemplos perfeitos de uso de WebSockets

✔ Chats
✔ Notificações instantâneas
✔ Jogos multiplayer
✔ Eventos de mercado financeiro
✔ Aplicações colaborativas (Google Docs, Figma…)
✔ Transmissão de métricas em tempo real
✔ Painéis interativos
✔ Videoconferências (parte do protocolo)

Sempre que precisamos de:

* alta frequência
* baixa latência
* bidirecional
* tempo real contínuo

→ WebSockets é o melhor candidato.

---

# Exemplo de uso no navegador

```javascript
const socket = new WebSocket("wss://example.com/ws");

socket.onopen = () => {
  console.log("Conectado!");
  socket.send("Olá servidor!");
};

socket.onmessage = (event) => {
  console.log("Mensagem recebida:", event.data);
};
```

O servidor recebe a mensagem e pode responder de volta **na mesma conexão**.

---

# WebSocket NÃO define formato de mensagem

Essa é uma parte importante que muitos candidatos esquecem:

WebSockets fornecem **apenas o canal**.
Você precisa definir o seu próprio mini-protocolo:

* JSON?
* Protobuf?
* Texto?
* Binário compactado?

Exemplo JSON para WebSocket API:

```json
{
  "type": "NEW_MESSAGE",
  "payload": {
    "user": "João",
    "text": "Olá!"
  }
}
```

E isso significa mais responsabilidade no design.

---

# Vantagens dos WebSockets

### 🔥 1. Conexão persistente

Não precisa criar novas conexões TCP a cada evento.

### 🔥 2. Totalmente bidirecional

Cliente → Servidor
Servidor → Cliente

Quando quiser.

### 🔥 3. Baixa latência

Mensagem vai direto pelo canal aberto.

### 🔥 4. Eficiência para muitos eventos

Excelente em cenários com centenas de eventos por segundo.

---

# Desvantagens (muito importantes para entrevistas)

### ❌ 1. Stateful

Cada conexão permanece aberta e ocupa recursos.

Isso quebra o modelo “stateless” fácil de escalar.

### ❌ 2. Requer infraestrutura compatível

Nem todos os load balancers/proxies/firewalls aceitam WebSockets.

### ❌ 3. Persistência custa memória

Milhares de conexões simultâneas exigem tuning fino de servidor.

### ❌ 4. Requere L4 load balancers (na maioria dos casos)

(load balancers L7 costumam quebrar a persistência da conexão)

### ❌ 5. Reconexão não é padrão

Ao contrário do SSE, você precisa implementar reconexão manual:

```js
socket.onclose = () => setTimeout(connectAgain, 5000);
```

### ❌ 6. Complexidade maior

Você precisa criar:

* formato das mensagens
* controle de sessões
* protocolos internos
* segurança customizada
* fallback quando WebSocket não conectar

---

# Quando usar WebSockets em entrevistas?

Use WebSockets quando:

✔ existe necessidade explícita de bidirecionalidade
✔ existe necessidade de alta frequência de mensagens
✔ SSE não dá conta
✔ o problema envolve “tempo real” forte (latência < 100 ms)
✔ estamos modelando chats, jogos, colaboração, streaming crítico

Não use WebSockets quando:

❌ você só precisa de push simples (use SSE)
❌ cliente não precisa enviar dados com frequência
❌ número de conexões simultâneas será enorme sem controle
❌ problema não exige tempo real verdadeiro

---

# A frase perfeita na entrevista

> **"Eu só usaria WebSockets se realmente precisarmos de comunicação bidirecional em tempo real. Caso contrário, SSE ou long polling são mais simples e mais baratos para manter."**

Isso mostra maturidade e boas práticas.

---

# SSE vs WebSocket — Tabela de comparação

| Característica | SSE                                | WebSocket                            |
| -------------- | ---------------------------------- | ------------------------------------ |
| Direção        | Servidor → cliente                 | Bidirecional                         |
| Protocolo      | HTTP                               | TCP (após upgrade)                   |
| Suporte        | Browsers nativos                   | Browsers (sim), proxies (nem sempre) |
| Foco           | Alta compatibilidade, simplicidade | Baixa latência, alta interação       |
| Requisição     | Fluxo de eventos                   | Canal contínuo                       |
| Estado         | Stateless-ish                      | Stateful                             |
| Reconexão      | Automática                         | Manual                               |
| Ideal para     | Notificações                       | Chat, jogos, colaboração             |

---

## Parte 8 — WebRTC (Peer-to-Peer Communication)

Chegamos ao protocolo **mais diferente** de todos: **WebRTC**.
Ele não é apenas um protocolo — é um **conjunto de protocolos, técnicas e infraestrutura** voltado para **comunicação direta entre dispositivos**.

É usado principalmente para:

* chamadas de vídeo
* chamadas de áudio
* conferências
* aplicações colaborativas P2P
* transmissão de tela
* troca de arquivos entre pares

E é o **único protocolo de camada de aplicação aqui que usa UDP como base**.

---

# ❗ Por que WebRTC é difícil?

Porque conectar dois dispositivos diretamente é algo **complexo**.
A maioria dos clientes está atrás de:

* firewalls
* roteadores domésticos
* proxies corporativos
* NATs (Network Address Translation)

Essas coisas impedem conexões de entrada.
Ou seja:

> A maioria dos dispositivos **não pode receber conexões diretamente**.

WebRTC existe justamente para “furar” essas barreiras de rede usando uma série de técnicas.

---

# Como WebRTC funciona? (Visão geral)

Para conectar dois navegadores (peer A e peer B), o WebRTC precisa de três peças:

1. **Signaling server**
   Para os peers trocarem informações de conexão (metadata e chaves).
   *WebRTC não define o protocolo de sinalização; você cria o seu (REST, WebSocket, SSE etc.).*

2. **STUN server**
   Para descobrir o IP público e a porta que o roteador/NAT está abrindo.

3. **TURN server (fallback)**
   Um “correio” que retransmite os dados quando o P2P direto não funciona.

---

# O fluxo WebRTC (as 4 etapas)

### **1. Signaling**

Os dois navegadores se conectam a um servidor central para trocar:

* SDP offers
* SDP answers
* ICE candidates

Isso é basicamente metadados para que cada peer saiba como chegar no outro.

### **2. STUN**

Cada peer pergunta ao servidor STUN:

> “Qual é o meu IP público e porta visíveis para o mundo?”

Isso é chamado de *NAT traversal*.

### **3. Troca de ICE candidates**

Os peers compartilham, via signaling, as portas IP/portas onde tentam se comunicar.

### **4. Conexão P2P direta**

Se tudo der certo:

✨ Os dois navegadores conseguem se conectar diretamente via UDP.

Se não der certo:

→ Usa TURN, que atua como relay.

---

# WebRTC com TURN (fallback)

Quando tudo falha — firewalls pesados, redes corporativas, proxies agressivos — WebRTC usa o **TURN server**, que retransmite dados entre peers.

Desvantagens:

* custa mais banda
* exige servidor robusto
* perde parte da vantagem “P2P”
* aumenta a latência

Mas é necessário para confiabilidade.

---

# Por que WebRTC é útil?

Porque ele fornece:

* transmissão de áudio em tempo real
* vídeo em tempo real
* latência muito baixa
* modos de transporte binário eficientes
* criptografia obrigatória
* integração perfeita com navegadores
* conexão direta (quando possível) para reduzir custos e latência

---

# Exemplos perfeitos para WebRTC

✔ Videoconferências (Google Meet, Zoom Web, Webex)
✔ Chamadas P2P (WhatsApp Web, Facebook Messenger)
✔ Colaboração com streaming (Figma, Miro, VNC via navegador)
✔ Transmissão de tela
✔ Transferência de arquivos P2P

Se há **mídia em tempo real**, WebRTC geralmente é a resposta.

---

# Exemplos onde NÃO usar WebRTC

❌ Chat simples
❌ Notificações em tempo real
❌ Aplicações onde o servidor precisa inspecionar dados
❌ Ambientes com tráfego massivo (escala global)

WebRTC só deve ser usado quando existe **necessidade real de P2P**, especialmente vídeo/áudio.

---

# Diferenças WebRTC vs WebSocket vs SSE

| Característica    | SSE                | WebSocket          | WebRTC                |
| ----------------- | ------------------ | ------------------ | --------------------- |
| Direção           | Servidor → cliente | Bidirecional       | P2P                   |
| Transporte        | HTTP               | TCP                | UDP                   |
| Suporte a mídia   | Não                | Não                | Sim (RTP)             |
| Uso típico        | Notificações       | Chat/jogos         | Áudio/vídeo           |
| Conexão           | Cliente ↔ Servidor | Cliente ↔ Servidor | Peer ↔ Peer           |
| Firewall-friendly | Alta               | Média              | Baixa (usa STUN/TURN) |
| Complexidade      | Baixa              | Média              | Alta                  |

---

# WebRTC em Entrevistas

⚠️ WebRTC costuma ser um **caminho perigoso** em entrevistas.

Motivo:

* É extremamente complexo
* Exige conhecimento de STUN/TURN
* Exige signaling server
* Exige fallback
* É difícil de escalar
* É muito raro o entrevistador realmente pedir isso

A menos que o problema envolva explicitamente:

✔ chamadas de vídeo
✔ compartilhamento de áudio
✔ transmissão P2P

**Evite WebRTC**.

---

# A frase perfeita para entrevista

> “Eu só usaria WebRTC caso o problema envolva comunicação multimídia em tempo real entre peers. Para qualquer outra necessidade de real-time eu preferiria WebSockets ou SSE, que são muito mais simples e fáceis de escalar.”

Essa frase demonstra maturidade técnica e entendimento de trade-offs.

---

# Recapitulando WebRTC

✔ P2P real
✔ Baixa latência
✔ Ideal para mídia em tempo real
✔ Usa STUN/TURN
✔ Difícil de implementar
✔ Pouco necessário na maioria dos designs
✔ Ótimo quando realmente precisamos de áudio/vídeo/streaming

---
## Parte 9 — Load Balancing (L4, L7, Health Checks, Algoritmos)

Agora entramos em um dos assuntos **mais cobrados em entrevistas de System Design**: **load balancing**.

Load balancers são essenciais para:

* escalar horizontalmente
* distribuir tráfego entre servidores
* garantir disponibilidade
* lidar com falhas
* manter baixa latência
* evitar sobrecarga em apenas um nó

E fazem isso tanto no nível **cliente** (client-side load balancing) quanto no nível **servidor** (dedicated load balancers).

Vamos começar pelo básico.

---

# O que é Load Balancing?

É a técnica de **dividir requisições entre múltiplos servidores**.

Se temos 1 servidor:

```
Cliente → Servidor
```

Mas se temos 5 servidores, precisamos decidir **quem recebe cada requisição**:

```
              → Servidor A
Cliente → LB → Servidor B
              → Servidor C
              → Servidor D
              → Servidor E
```

Sem um load balancer, você teria que expor todos os servidores ao cliente — o que seria caótico.

---

# Escalabilidade: Vertical vs Horizontal

### **Vertical Scaling (scale-up)**

Aumentar CPU / RAM / disco de uma máquina.

Vantagens:

* simples
* eficiente

Desvantagens:

* limitado
* caro
* ponto único de falha

### **Horizontal Scaling (scale-out)**

Adicionar mais servidores.

Vantagens:

* escalabilidade infinita
* alta disponibilidade
* redundância

Desvantagens:

* requer load balancing
* requer infraestrutura de cluster

Para entrevistas, **horizontal** é quase sempre o caminho.

---

# Tipos de Load Balancing

Existem dois modelos principais:

1. **Client-side load balancing**
2. **Dedicated load balancer (server-side)**

Vamos explorar ambos.

---

# 1. Client-Side Load Balancing

Aqui, o **cliente decide** qual servidor usar.

Geralmente:

* cliente pega uma lista de servidores
* escolhe um
* envia requisição diretamente

Isso reduz latência e remove uma camada no meio.

---

## Exemplos de client-side load balancing

### **A. Redis Cluster**

O cliente conecta a qualquer nó do cluster → recebe o mapa de nós → usa hashing para saber qual nó contém a chave → acessa diretamente o nó correto.

Se errar, o Redis responde com:

```
MOVED {new_node}
```

### **B. DNS Round Robin**

Quando você consulta:

```
example.com
```

O DNS retorna uma lista rotacionada:

```
1.1.1.1
1.1.1.2
1.1.1.3
```

Cada cliente vê uma ordem diferente → requests vão para servidores diferentes.

---

## Quando usar client-side load balancing

✔ Em microserviços internos
✔ Quando você controla o cliente
✔ Quando atualizar a lista de servidores é simples
✔ Para reduzir um hop de rede
✔ Para reduzir latência
✔ Para sistemas que suportam gRPC

## Quando NÃO usar

❌ Em clientes públicos
❌ Em dispositivos móveis
❌ Quando a lista de servidores muda frequentemente
❌ Quando você não controla o código cliente

---

# 2. Dedicated Load Balancer (server-side)

O modelo mais comum.

Existe um componente dedicado entre cliente e servidor:

```
Cliente → Load Balancer → Servidores
```

Esse load balancer pode ser:

* hardware (F5, Citrix)
* software (NGINX, HAProxy, Envoy)
* gerenciado (AWS ALB/NLB, Google Cloud LB, Azure LB)

Vantagens:

* atualizações instantâneas de servidores
* health checks
* algoritmos complexos
* controle centralizado
* segurança integrada
* roteamento sofisticado

Desvantagens:

* adiciona um hop
* pode virar SPOF (mitigado com múltiplos LBs + DNS)

---

# L4 vs L7 Load Balancing

Agora entramos no tema mais cobrado em entrevistas.

---

# Layer 4 Load Balancer (TCP/UDP)

Opera na **camada de transporte**.

Não lê HTTP.
Não entende cookies.
Não olha headers.

Ele roteia tráfego baseando-se apenas em:

* IP origem/destino
* Porta
* Protocolo (TCP/UDP)

É extremamente rápido.

### Uso típico:

* WebSockets
* gRPC (em muitos casos)
* Jogos online
* Tráfego binário
* Alta performance

---

# Layer 7 Load Balancer (HTTP/HTTPS)

Opera na **camada de aplicação**.

Entende:

* HTTP
* URL
* Headers
* Cookies
* Query params

E pode tomar decisões inteligentes:

* enviar `/api/*` para backend de API
* enviar `/static/*` para servidores de assets
* rotear usuários a partir de cookies
* gzip, rate-limit, autentication, etc.

### Uso típico:

* REST
* GraphQL
* APIs públicas
* Websites
* Routers inteligentes de URL

---

# Resumo L4 vs L7

| Característica        | L4         | L7               |
| --------------------- | ---------- | ---------------- |
| Camada                | Transporte | Aplicação        |
| Protocolo             | TCP/UDP    | HTTP             |
| Performance           | Muito alta | Alta (mas menor) |
| Persistência          | Ideal      | Não ideal        |
| WebSockets            | Excelente  | Pode quebrar     |
| Flexibilidade         | Baixa      | Altíssima        |
| Roteamento por URL    | Não        | Sim              |
| Roteamento por cookie | Não        | Sim              |
| Roteamento por header | Não        | Sim              |

---

# Health Checks (checagem de saúde)

Load balancers usam health checks para saber se o servidor está vivo.

Tipos comuns:

### **TCP health check**

Mais rápido e barato:

* Abre uma conexão TCP
* Se conectou → servidor saudável

### **HTTP health check**

Mais detalhado:

* Faz requisição HTTP (ex: `/health`)
* Espera status 200
* Pode verificar database, cache, etc.

### **gRPC health check**

* Usa método padrão `grpc.health.v1.Health/Check`

Load balancer **desativa** servidores que falham.
Alta disponibilidade garantida.

---

# Algoritmos de Load Balancing

### **1. Round Robin**

Sequencial: A → B → C → A → B → C
Simples, balanceado, ótimo para servidores idênticos.

### **2. Random**

Escolhe aleatoriamente.
Efetivo com workloads homogêneos.

### **3. Least Connections**

Envia requisições para o servidor com **menos conexões ativas**.

Perfeito para:

* WebSockets
* SSE
* Requisições longas

### **4. Least Response Time**

Escolhe o servidor mais rápido.

### **5. IP Hash**

Mesma origem → mesmo servidor
Bom para sticky sessions.

---

# Por que WebSockets exigem L4?

Porque WebSockets precisam:

* conexão persistente
* handshake
* manter a mesma conexão TCP viva
* tráfego contínuo

Um L7 LB **termina** a conexão e cria outra → isso quebra WebSockets.

Por isso:

> **Se o sistema usar WebSockets, escolha um L4 load balancer.**

Ponto importante em entrevistas.

---

# Real-World Tools

### Hardware:

* F5 BIG-IP

### Software:

* NGINX
* HAProxy
* Envoy

### Cloud:

* AWS ELB, ALB, NLB
* Google Cloud LB
* Azure LB

L4: NLB / TCP LB
L7: ALB / HTTP LB

---

# Frase perfeita para entrevistas

> “Para tráfego HTTP, usaria um load balancer L7.
> Para WebSockets, gRPC ou conexões persistentes, prefiro um L4 devido à necessidade de manter o fluxo TCP.”

Simples e demonstra entendimento profundo.

---

## Parte 10 — Regionalização, Latência e CDNs

Agora entramos em um dos temas **mais importantes** para sistemas globais:
**como reduzir latência e lidar com distribuição geográfica**.

Este tópico é extremamente relevante em entrevistas, especialmente quando:

* o sistema precisa atender usuários no mundo todo
* APIs precisam responder rápido
* existe tráfego massivo
* lidamos com disponibilidade e redundância
* clientes estão espalhados em múltiplos continentes

Vamos por partes.

---

# 🌎 O Problema: Latência Físico-Geográfica

A latência depende da **distância física**.
Mesmo viajando pela fibra ótica (que opera a ~⅔ da velocidade da luz), não há como superar isso.

Exemplo:

* **Nova York → Londres**: ~5.600 km
* Velocidade da luz na fibra: ~200.000 km/s
* Latência mínima: **~56 ms apenas de ida e volta** (RTT)

Agora imagine:

* DNS
* TLS handshake
* routing hops
* firewalls
* load balancers
* processamento de aplicação
* banco de dados em outra região

A latência real pode facilmente chegar a 150–250 ms.

E isso é perceptível ao usuário.

---

# ✔ Estratégia Geral: Aproximar os Dados do Usuário

O princípio mais importante:

> **Quanto mais perto o dado está da computação, mais rápido o sistema.**

Isso vale para:

* memória → CPU
* cache → aplicação
* banco → backend
* usuário → edge/CDN

---

# 1. Content Delivery Networks (CDNs)

CDNs são redes de servidores espalhadas pelo mundo.

Chamadas de:

* POPs (Points of Presence)
* Edge Locations

Elas armazenam conteúdo mais próximo ao usuário final.

### O que elas fazem?

✔ Cache de imagens
✔ Cache de vídeos
✔ Cache de arquivos estáticos
✔ Cache de HTML
✔ Cache de JSON (quando permitido)
✔ TLS termination
✔ Compressão, minificação
✔ Edge computing (em alguns casos)

CDNs podem ter **milhares de localizações** — muito mais que qualquer provedor de nuvem.

### Por que isso é tão eficiente?

Se o usuário está em São Paulo e o backend está na Virgínia (EUA), a latência pode ser ~150 ms.

Se a CDN possui um POP em São Paulo:

* o usuário recebe o conteúdo instantaneamente da CDN
* sem precisar ir até a Virgínia

---

# Quando mencionar CDN na entrevista?

Quase sempre quando:

* usuários globais
* muito conteúdo estático
* muita leitura (read-heavy)
* o entrevistador reclama de latência
* você quer reduzir carga nos servidores principais

CDN costuma ser uma **resposta vencedora**.

---

# 2. Regional Partitioning (Partitionamento Regional)

Agora vamos falar sobre **dados dinâmicos**, que não podem ser simplesmente cacheados.

Exemplo perfeito: Uber.

Se você está em **Miami**, você nunca vai pedir uma corrida para um motorista em **Nova York**.

Isso significa:

✔ dados são *naturalmente regionais*
✔ podemos particionar por região
✔ cada região deve ter seu próprio conjunto de servidores e banco de dados

---

## Exemplo de Arquitetura Regional

```
                  Usuário em EU
                     │
         ┌───────────┴───────────┐
         │                       │
Região EUA                  Região Ásia
(Ohio, Virgínia)           (Cingapura, Tóquio)
         │                       │
  Bancos regionais        Bancos regionais
         │                       │
  Servidores regionais    Servidores regionais
```

Cada região é **autossuficiente**.

### Vantagens

* baixa latência
* bancos menores → mais rápidos
* falhas isoladas regionalmente
* escala mais simples

---

# 3. Multi-Region + Multi-AZ

Em sistemas críticos, você precisa mencionar:

* **Zonas de disponibilidade (AZs)** dentro da mesma região
* **Regiões duplicadas** para failover

### AZs protegem contra:

✔ falha de datacenter
✔ queda de energia local
✔ incêndios físicos

### Múltiplas regiões protegem contra:

✔ desastres massivos
✔ problemas de backbone
✔ quedas regionais de provedores
✔ ataques direcionados

---

# 4. Latência de Banco de Dados entre Regiões

Um erro comum em entrevistas:

> “Meu app está em São Paulo, o banco em Virgínia, mas tudo bem…”

❌ Não está!
Cada query terá ~120–160 ms só de rede.

Se a API faz:

* 1 consulta = OK
* 5 consultas = 600 ms
* 20 consultas = impossível

A regra:

> **Banco e aplicação devem estar na mesma região.**

Se o problema envolve sistema global:

✔ use bancos separados
✔ particione por região
✔ evite replicação síncrona entre continentes

---

# 5. Reduzindo Latência sem Particionar

Quando não podemos particionar a aplicação inteira, há técnicas úteis:

### ✔ Edge Caching com TTL curto

Cachear respostas dinâmicas por alguns segundos já reduz muito a latência.

### ✔ Read Replicas regionais

O banco principal fica em uma região.
Outras regiões têm réplicas apenas para leitura.

### ✔ Edge Functions / Cloudflare Workers

Executar partes da lógica no EDGE.

---

# Conversa típica na entrevista

Se o entrevistador pergunta:

> “Nosso sistema precisa servir usuários globalmente. Como reduzir latência?”

Resposta perfeita:

> "Começaria usando uma CDN para conteúdo estático e responses cacheáveis.
> Para dados dinâmicos, particionaria por região sempre que os dados forem localizados, como em serviços do tipo Uber.
> Aplicação e banco devem estar na mesma região, e usaríamos múltiplas AZs para alta disponibilidade."

Essa resposta cobre:

* latência
* regionalização
* arquitetura
* disponibilidade
* boas práticas de nuvem

É exatamente o que o avaliador espera ouvir.

---

# Resumo da Parte 10

✔ Latência é limitada pela física
✔ CDNs são essenciais para conteúdo cacheável
✔ Particionamento regional reduz consultas multiplamente distantes
✔ Multi-AZ e multi-region garantem alta disponibilidade
✔ Banco deve estar perto da aplicação
✔ Usuários devem ser encaminhados à região mais próxima

---

## Parte 11 — Handling Failures

### (Timeouts, Retries, Exponential Backoff, Idempotência, Circuit Breakers)

Agora chegamos ao último grande bloco de conhecimentos essenciais de networking para system design:
**como lidar com falhas**.

Esse é um dos temas **mais cobrados** em entrevistas — especialmente para vagas de:

* backend
* sistemas distribuídos
* cloud
* escalabilidade
* microserviços

E também é uma forma do entrevistador detectar maturidade técnica.

A premissa é simples:

> **A rede falha. Sempre.**

Se você projetar como se tudo fosse perfeito, seu sistema vai cair.

Vamos abordar todos os padrões clássicos que entrevistadores esperam ouvir.

---

# 1. Timeouts (Obrigatório)

O pior antipadrão em sistemas distribuídos é:

> “Fiz uma requisição e vou esperar para sempre.”

**Nunca** deixe uma requisição pendurada indefinidamente.
Sempre configure:

* timeout de conexão
* timeout de leitura
* timeout de escrita

### Por quê?

✔ evita que threads, conexões e recursos fiquem travados
✔ limita o impacto de serviços lentos
✔ evita deadlocks entre serviços

### Resposta perfeita em entrevistas:

> “Toda chamada de rede deve ter um timeout definido, caso contrário o sistema trava sob degradação.”

---

# 2. Retries (com parcimônia)

Retries são essenciais porque muitas falhas são **transientes**:

* spikes de latência
* rota temporariamente congestionada
* servidor reiniciando
* pacotes perdidos

Mas retries cegos causam:

❌ thundering herd (tempestade de requisições)
❌ cascatas de falhas
❌ congestionamento ainda maior

Por isso, retries **sempre devem ser combinados com backoff**.

---

# 3. Exponential Backoff (o padrão mais citado)

O padrão recomendado:

```
1ª tentativa → aguarde 100 ms  
2ª tentativa → aguarde 200 ms  
3ª tentativa → aguarde 400 ms  
4ª tentativa → aguarde 800 ms  
...
```

E:

### ✔ adicione jitter

(randomize um pouco o atraso)

Por quê?

Se 10.000 clientes fizerem retry ao mesmo tempo, você cria:

* pico artificial
* sobrecarga
* cascata de falhas
* colapso do serviço

### Frase perfeita para entrevista:

> “Usaria retries com backoff exponencial e jitter para evitar sincronização de requisições e mitigar cascatas de falhas.”

Essa frase vale ouro.

---

# 4. Idempotência

Retries podem causar problemas catastróficos:

* múltiplas cobranças
* múltiplas compras
* duplicação de dados
* reinserção de registros
* efeitos colaterais duplicados

Por isso, APIs precisam ser **idempotentes**.

Significa:

> “A mesma requisição pode ser executada N vezes, produzindo sempre o mesmo efeito.”

### Exemplos:

✔ GET é idempotente
✔ DELETE deve ser idempotente
✔ PUT deve ser idempotente
❌ POST normalmente não é

Para tornar POST idempotente, usamos:

### **Idempotency Keys**

O cliente envia:

```
Idempotency-Key: 8f3c01a1-9c66-4e62-8018-1d76b1429327
```

O servidor:

* checa se essa operação já foi processada
* se sim → retorna o resultado anterior
* se não → processa normalmente

### Frase perfeita:

> “Quando houver risco de duplicação, eu usaria chaves de idempotência e armazenaria o resultado da operação para garantir segurança.”

---

# 5. Circuit Breakers

(A estrela das entrevistas de senior)

Esse é o padrão que mais diferencia candidatos maduros.

Quando um serviço dependente começa a falhar repetidamente:

* timeouts
* falhas
* latência alta
* erros 5xx

continuar tentando vai:

* sobrecarregar ainda mais o serviço
* travar threads
* congestionar filas
* derrubar o próprio sistema

**Circuit Breaker** funciona assim:

```
Estado FECHADO → tudo normal  
Falhas acumulam  
Estado ABERTO → para de enviar requisições e falha imediatamente  
Tempo passa  
Estado HALF-OPEN → envia uma requisição teste  
Se sucesso → volta ao normal  
Se falha → permanece aberto
```

Ele protege o sistema de:

* cascatas de falhas
* thundering herd
* dependências instáveis
* downtime prolongado

### Por que entrevistadores amam esse tópico?

✔ mostra experiência real
✔ demonstra entendimento profundo de falhas distribuídas
✔ indica mindset de resiliência
✔ separa devs júnior de devs experientes

### Frase perfeita:

> “Para evitar cascatas de falhas, implementaria um circuit breaker que abre após repetidas falhas, rejeita chamadas imediatamente e tenta recuperar após um período de cooldown.”

---

# 6. Fallbacks (opcional, mas demonstra maturidade)

Quando um serviço falha, podemos oferecer um fallback:

* servir um cache antigo
* resposta padrão
* modo degradado
* retornar valor aproximado
* exibir resultados do último sucesso

Exemplo:

Se o serviço de recomendações cair → exiba produtos populares.

---

# 7. Bulkheads (Compartimentalização)

Outro padrão avançado:

> “Isole partes do sistema para evitar que falhas se espalhem.”

Como compartimentos de um navio.

Exemplos:

* limitar conexões por serviço
* usar pools de threads separados
* usar filas separadas por tipo de tarefa

---

# 8. Rate Limiting (controle de tráfego)

Evita abusos, protege APIs e controla load.

Técnicas:

* token bucket
* leaky bucket
* fixed window
* sliding window

---

# 9. Observabilidade (Logs, métricas e tracing)

Entrevistadores valorizam:

✔ métricas (Prometheus, CloudWatch, Datadog)
✔ logs estruturados
✔ tracing distribuído (Jaeger, OpenTelemetry)
✔ dashboards
✔ alertas

---

# Resumo da Parte 11

✔ **Timeouts** evitam travamentos
✔ **Retries** são úteis, mas perigosos
✔ **Exponential backoff + jitter** é padrão ouro
✔ **Idempotência** evita duplicação catastrófica
✔ **Circuit breakers** evitam cascatas de falhas
✔ **Fallbacks** aumentam resiliência
✔ **Bulkheads** isolam falhas
✔ **Rate limiting** protege o sistema
✔ **Observabilidade** é essencial

Se você levar esses conceitos para sua entrevista, estará **muito acima da média**.

---

# Networking Essentials — Resumo Final

## 1. Camadas Importantes
- **L3 – Network Layer / IP**: roteamento e endereçamento, entrega “best-effort”.
- **L4 – Transport Layer / TCP/UDP/QUIC**:
  - TCP: confiável, ordenado, orientado à conexão.
  - UDP: rápido, sem garantias, ideal para streaming/games/VoIP.
  - QUIC: substituto moderno do TCP, usado no HTTP/3.
- **L7 – Application Layer**:
  - HTTP/HTTPS, REST, GraphQL, gRPC, SSE, WebSockets, WebRTC.

## 2. Application Protocols
- **HTTP/HTTPS**: request/response, stateless, simples e universal.
- **REST**: padrão default para entrevistas; CRUD baseado em recursos.
- **GraphQL**: ideal para flexibilidade no frontend; evita under/over-fetching.
- **gRPC**: eficiente, binário, fortemente tipado; perfeito para microserviços internos.

## 3. Real-Time Protocols
- **SSE**: server → client; leve; ótimo para notificações.
- **WebSockets**: bidirecional; baixa latência; ideal para chats e jogos.
- **WebRTC**: comunicação P2P; áudio/vídeo; usa STUN/TURN.

## 4. Load Balancing
- **Client-side**: o cliente escolhe o servidor (Redis, gRPC LB, DNS).
- **Server-side**: load balancer dedicado (AWS LB, NGINX, F5).
- **L4**: opera no TCP/UDP; ótimo para WebSockets.
- **L7**: opera no HTTP; roteamento inteligente.

Algoritmos:
- Round Robin, Random, Least Connections, IP Hash.

## 5. Regionalização e Latência
- CDNs reduzem latência para conteúdo estático.
- Particionamento regional reduz acesso entre continentes.
- App + DB devem ficar na mesma região.
- Multi-AZ e multi-region para alta disponibilidade.

## 6. Falhas e Resiliência
- **Timeouts** obrigatórios.
- **Retries + exponential backoff + jitter**.
- **Idempotência** fundamental para evitar duplicações.
- **Circuit breakers** evitam cascatas de falhas.
- **Fallbacks**, **Bulkheads**, **Rate limiting**, **Observabilidade**.

---
# Checklist Rápido de Networking para Entrevistas

## 🔹 Protocolo
- O default é **HTTP + REST sobre TCP**.
- Preciso de real-time?
  - apenas server → client → **SSE**
  - bidirecional → **WebSockets**
  - mídia (áudio/vídeo) → **WebRTC**
- Inter-service communication?
  - **gRPC** (se controle total dos clientes)
  - **REST** para APIs públicas

## 🔹 Escalabilidade
- **L7 LB** para HTTP.
- **L4 LB** para WebSockets.
- Considerar **client-side LB** para microserviços internos.
- Health checks (TCP/HTTP/gRPC).

## 🔹 Latência
- Existe público global?
  - **CDN** para estáticos.
  - **Regional partitioning** para dados locais.
  - Evitar trafegar banco entre regiões.

## 🔹 Falhas
- Implementar:
  - Timeouts
  - Retries (com backoff + jitter)
  - Idempotência
  - Circuit breakers
  - Fallbacks e rate limits

## 🔹 Segurança
- HTTPS obrigatório.
- Nunca confiar em user IDs no body sem validação.
- Autenticação → OAuth2/JWT/Mutual TLS (dependendo do cenário).

## 🔹 Observabilidade
- Logs estruturados
- Métricas (latência, erro, throughput)
- Tracing distribuído


# Mapa Mental — Networking Essentials

## L3 — IP
- Roteamento
- DHCP
- Endereços públicos/privados

## L4 — TCP/UDP/QUIC
- TCP → confiável
- UDP → rápido
- QUIC → moderno

## L7 Protocols
- HTTP/HTTPS
- REST, GraphQL, gRPC
- SSE, WebSockets, WebRTC

## Load Balancing
- Client-side (Redis, DNS, gRPC)
- Server-side
  - L4 LB
  - L7 LB
- Health checks
- Algoritmos (RR, Random, Least Conns)

## Latência Global
- CDNs
- Region partitioning
- Multi-AZ / Multi-region

## Falhas
- Timeouts
- Retries + backoff
- Idempotência
- Circuit breakers
- Fallbacks
- Bulkheads
- Rate limiting


## A. Load Balancer L7
     ┌──────────┐
     │  Cliente │
     └────┬─────┘
          │ HTTP
          ▼
   ┌──────────────┐
   │  L7 Load Bal. │
   └────┬────┬────┘
        │    │
        ▼    ▼
┌──────────┐ ┌──────────┐
│ Server A │ │ Server B │
└──────────┘ └──────────┘

## B. WebSockets via L4 LB
Cliente
   │
   ▼
┌───────────────┐
│  L4 Load Bal.  │  (conexão persistente)
└───────┬───────┘
        │
        ▼
┌──────────────┐
│ WebSocket Srv │
└──────────────┘


## C. Regional Partitioning
                     Global Users
                         │
         ┌───────────────┴───────────────┐
         │                               │
     Região EUA                     Região Europa
     (US-East)                       (EU-West)
         │                               │
  ┌──────┴──────┐                ┌───────┴──────┐
  │  App + DB   │                │   App + DB    │
  └──────────────┘                └──────────────┘


# Glossário — Networking em System Design

**IP** — Protocolo de Roteamento e Endereçamento (Layer 3).

**TCP** — Protocolo confiável, ordenado e orientado à conexão.

**UDP** — Protocolo rápido, sem garantias.

**QUIC** — Substituto moderno do TCP; usado em HTTP/3.

**REST** — Estilo arquitetural baseado em recursos e verbos HTTP.

**GraphQL** — Linguagem de consulta para APIs flexíveis.

**gRPC** — RPC binário e eficiente baseado em HTTP/2 e Protobuf.

**SSE** — Canal unidirecional servidor → cliente para tempo real.

**WebSockets** — Canal persistente e bidirecional.

**WebRTC** — Comunicação P2P com STUN/TURN; ideal para vídeo/áudio.

**Load Balancer** — Distribui tráfego entre múltiplos servidores.

**L4 LB** — Balanceamento no nível TCP/UDP.

**L7 LB** — Balanceamento no nível HTTP.

**CDN** — Rede de distribuição de conteúdo para reduzir latência.

**Region Partitioning** — Separar dados e apps por região geográfica.

**Availability Zones (AZ)** — Datacenters independentes dentro de uma região.

**Timeouts** — Limites de tempo para evitar threads travadas.

**Retry** — Repetir tentativas em falhas transitórias.

**Backoff** — Espera progressiva entre retries.

**Jitter** — Aleatorizar espera para evitar sincronização.

**Idempotência** — Operações que podem ser repetidas sem efeitos duplicados.

**Circuit Breaker** — Proteção contra cascatas de falhas.

**Fallback** — Resposta alternativa quando o serviço falha.

**Bulkhead** — Isolamento de falhas entre componentes.

**Rate Limiting** — Reduz tráfego excessivo.








