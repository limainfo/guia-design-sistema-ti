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
