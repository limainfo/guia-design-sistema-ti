# Resumo técnico — Engenharia de Software no desenvolvimento de softwares de games

## 1. Visão geral

O material parte da ideia de que **jogo** é um sistema composto por regras, jogadores, resultados mensuráveis e um conflito artificial delimitado por um mundo ficcional. Quando esse jogo passa a ser executado em hardware e controlado por software, tem-se o **jogo digital**. 

A tese central do capítulo é que o desenvolvimento de jogos não pode ser tratado como simples programação de entretenimento. Ele exige Engenharia de Software porque envolve:

* múltiplos artefatos interdependentes;
* forte carga de design e narrativa;
* integração entre software, arte, áudio e infraestrutura;
* ciclos repetidos de desenvolvimento e testes;
* coordenação intensiva entre equipes multidisciplinares.

---

## 2. O que diferencia software de jogos de software convencional

Os jogos digitais possuem características que os afastam do software corporativo tradicional. O texto destaca que eles são:

* interativos;
* adaptativos;
* orientados a desafio, competição e recompensa;
* capazes de gerar motivação contínua;
* frequentemente sociais, principalmente em jogos on-line. 

### Diferença técnica central

Enquanto software convencional costuma priorizar automação de processos, consistência operacional e suporte a regras de negócio explícitas, jogos precisam lidar simultaneamente com:

* mecânicas de interação;
* experiência do jogador;
* equilíbrio de desafio;
* progressão;
* narrativa;
* imersão;
* apresentação visual e sonora.

Em termos de engenharia, isso aumenta bastante a complexidade do projeto.

---

## 3. Padrões de design de jogos

O material menciona que, assim como a Engenharia de Software usa padrões para resolver problemas recorrentes, o **design de jogos** também adota padrões específicos. São citadas 11 categorias de padrões de desenho de jogos, relacionadas a elementos como: 

* elementos de jogo;
* gestão de recursos;
* informação, comunicação e apresentação;
* ações e eventos;
* estruturas narrativas;
* previsão e imersão;
* interação social;
* objetivos;
* estruturas e objetivo;
* sessões de jogo;
* maestria, equilíbrio e curvas de aprendizagem.

### Interpretação técnica

Essas categorias mostram que jogo não é apenas um software com interface bonita. Ele precisa ser modelado como um sistema que combina:

* lógica computacional;
* dinâmica comportamental;
* percepção do usuário;
* progressão;
* estímulos cognitivos e emocionais.

---

## 4. Processo de Engenharia de Software em jogos

A **Figura 1**, apresentada no material, é uma das partes mais importantes. Ela compara o ciclo tradicional de Engenharia de Software com o ciclo adaptado ao desenvolvimento de jogos. No software convencional, o fluxo aparece como:

* análise;
* projeto;
* desenvolvimento;
* testes;
* manutenção. 

Já no desenvolvimento de jogos, a figura mostra que essas etapas são atravessadas por um documento central: o **Documento de Desenho do Jogo** (*Game Design Document*). Esse documento gera desdobramentos sucessivos em desenvolvimento e testes, rompendo a linearidade simples do modelo convencional. 

### Conclusão técnica

No desenvolvimento de jogos, o processo é menos linear e mais iterativo, porque o refinamento de um elemento do jogo costuma impactar vários outros.

---

## 5. O Documento de Desenho do Jogo como artefato central

O material atribui papel central ao **Game Design Document (GDD)**. Ele é apresentado como artefato transversal entre análise e projeto, servindo como guia para o restante do ciclo. Segundo a figura e as páginas seguintes, esse documento pode conter seções como: 

* página de títulos;
* tabela de conteúdos;
* histórico de versões;
* visão geral do jogo;
* gameplay e mecânicas;
* história e personagens;
* níveis;
* interface gráfica do usuário;
* inteligência artificial;
* tecnologias;
* game art;
* software de terceiros;
* gerenciamento;
* apêndices e anexos.

### Função técnica do GDD

O GDD atua como:

* artefato de especificação;
* ponto de integração entre equipes;
* documento de rastreabilidade;
* base para planejamento técnico;
* mecanismo de alinhamento entre visão criativa e implementação.

### Insight importante

No software comum, o documento de requisitos tende a dominar a fase inicial. Em jogos, o GDD amplia esse papel e incorpora não só requisitos funcionais e técnicos, mas também:

* visão artística;
* ambientação;
* narrativa;
* mecânicas;
* integração tecnológica;
* planejamento de equipes.

Por isso, erro nesse documento tende a se propagar para todas as etapas. O próprio texto ressalta esse risco. 

---

## 6. Dupla natureza do projeto de um jogo

O material destaca que o desenvolvimento de um jogo envolve dois conjuntos documentais integrados:

* o **projeto de criação do jogo** (*game creative/production design document*);
* o **projeto de software do jogo** (*game software design description*). 

### Leitura técnica

Isso significa que o jogo possui, ao mesmo tempo:

## 6.1 Projeto criativo

Focado em:

* enredo;
* personagens;
* ambientação;
* estilo visual;
* ritmo;
* proposta de experiência.

## 6.2 Projeto de software

Focado em:

* arquitetura;
* requisitos funcionais e não funcionais;
* tecnologias;
* módulos;
* infraestrutura;
* testes;
* integração.

O sucesso do produto depende justamente da coerência entre esses dois planos.

---

## 7. Jogos single player, multiplayer local e multiplayer on-line

O texto apresenta um exemplo importante: a escolha entre

* **single player**;
* **multiplayer local**;
* **multiplayer on-line**

afeta diretamente a arquitetura do software. 

### Single player

* menor complexidade de infraestrutura;
* foco em lógica local, IA e experiência individual.

### Multiplayer local

* compartilhamento do mesmo hardware ou ambiente próximo;
* sincronização local de entrada e estado do jogo.

### Multiplayer on-line

É apontado como o mais complexo, porque exige:

* conhecimento de redes;
* servidores na nuvem ou hospedagem;
* comunicação simultânea entre jogadores;
* sincronização de partidas;
* suporte a serviços de conexão. 

### Implicação técnica

A decisão sobre o tipo de jogo altera:

* arquitetura;
* requisitos não funcionais;
* tecnologias;
* esforço de teste;
* custo de operação;
* composição da equipe.

---

## 8. Uso da UML no desenvolvimento de jogos

O material afirma que diagramas UML também são utilizados no desenvolvimento de jogos digitais. São citados especialmente:

* casos de uso;
* classes;
* sequência;
* componentes;
* atividades. 

## 8.1 Casos de uso

Na análise, ajudam a representar:

* atores;
* interações do jogador com menus e fluxos;
* integração com terceiros;
* cenários normais, alternativos e de exceção.

## 8.2 Diagrama de classes

Ajuda a estruturar:

* objetos do jogo;
* atributos;
* comportamentos;
* relacionamentos.

## 8.3 Diagrama de sequência

Útil para modelar:

* troca de mensagens;
* ordem dos eventos;
* fluxos interativos;
* sequência de ações do jogador e do sistema.

## 8.4 Diagrama de componentes

Permite visualizar:

* modularização;
* dependências entre subsistemas;
* interfaces entre artefatos e motores.

## 8.5 Diagrama de atividades

O texto dá destaque especial a esse diagrama, por permitir:

* representar fluxo de atividades;
* evidenciar paralelismo;
* explicitar decisões;
* descrever cenários de roteiro, ambientação, ação e efeitos. 

### Interpretação técnica

Em jogos, UML não serve apenas para documentação tradicional, mas para estruturar comportamentos complexos de interação e apoiar a convergência entre design e implementação.

---

## 9. Gestão de equipes e métodos de trabalho

O material mostra que o desenvolvimento de jogos demanda equipes muito mais diversas que as de software convencional. A própria figura comparativa cita papéis adicionais como:

* designers de jogos;
* especialistas em IA;
* engenheiros/projetistas de redes;
* produtores de áudio;
* diretores artísticos. 

### Consequência

Não basta gerenciar código. É necessário coordenar pessoas de áreas com linguagens e entregas muito diferentes.

## 9.1 SCRUM

O texto aponta SCRUM como método particularmente útil para gestão da área técnica, destacando:

* ciclos curtos de 1 a 4 semanas;
* reuniões diárias rápidas;
* identificação precoce de dificuldades;
* forte comunicação entre membros e stakeholders. 

## 9.2 PMBOK

Já o PMBOK é apresentado como guia de gerenciamento mais amplo, cobrindo prazo, escopo, custo, qualidade, riscos, comunicação, aquisições e demais áreas do projeto. 

### Síntese técnica

* **SCRUM**: mais aderente à coordenação tática do time de desenvolvimento.
* **PMBOK**: mais aderente à governança ampla do projeto como empreendimento.

---

## 10. Ferramentas de apoio ao desenvolvimento de jogos

O **Quadro 1**, nas páginas 44 a 46, lista ferramentas e sites de apoio ao desenvolvimento de jogos. Esse quadro é útil para revisão prática. 

## 10.1 Motores e frameworks

* **Unity** — motor de jogo para programação e criação de jogos.
* **Godot** — motor open source e gratuito.
* **Unreal** — motor de jogo, gratuito em alguns contextos não lucrativos.
* **Construct** — editor 2D baseado em HTML5.
* **Cocos2d** — framework de desenvolvimento multiplataforma. 

## 10.2 Modelagem, animação e arte 3D

* **Blender** — modelagem, texturização, composição e animação.
* **Autodesk Maya** — animação, modelagem, simulação e renderização 3D.
* **ZBrush** — modelagem digital 3D e texturização em alta resolução.
* **SketchUp**
* **3ds Max** 

## 10.3 Edição de imagens e recursos

* **Gimp** — criação de texturas.
* **Texture Haven** — texturas gratuitas.
* **3D Model Haven** — modelos 3D gratuitos.
* **YouTube Music Library** — trilhas e efeitos gratuitos. 

### Insight técnico

O material deixa claro que normalmente não existe uma única ferramenta suficiente. O desenvolvimento de jogos é multimodal e exige combinação de motores, ferramentas gráficas, bibliotecas, repositórios e fontes de assets.

---

## 11. Reuso, orientação a objetos e padrões de projeto

O capítulo reforça que, no desenvolvimento de jogos, o reuso é essencial para reduzir esforço e tempo. Ele conecta isso ao paradigma orientado a objetos, destacando os conceitos de:

* **baixo acoplamento**;
* **alta coesão**. 

### Baixo acoplamento

Redução da dependência entre componentes.

### Alta coesão

Cada componente deve refletir responsabilidades concisas e pertinentes.

### Aplicação prática em jogos

Isso é importante para:

* separar mecânicas;
* encapsular entidades;
* modularizar IA;
* isolar renderização, física, interface, áudio e rede;
* facilitar manutenção e evolução.

O texto ainda afirma que esses princípios também podem se conectar a arquiteturas orientadas a serviços ou microsserviços, especialmente quando o jogo possui serviços distribuídos. 

---

## 12. Testes em jogos: defeitos, erros e falhas

O material dedica espaço relevante aos testes e faz uma distinção conceitual importante:

* **defeito**;
* **erro**;
* **falha**. 

## 12.1 Defeito

Problema introduzido por uso incorreto de informação, método, solução ou ferramenta.

## 12.2 Erro

Estado intermediário incorreto ou resultado inesperado na execução do programa.

## 12.3 Falha

Comportamento inesperado percebido pelo usuário.

### Relação entre eles

Defeitos podem gerar erros, e erros podem gerar falhas. Mas nem todo erro necessariamente se manifesta como falha percebida.

---

## 13. Casos, procedimentos, critérios e níveis de teste

O texto apresenta os artefatos de suporte ao teste:

* **casos de teste**: condições a serem testadas;
* **procedimentos de teste**: passos para executar os testes;
* **critérios de teste**: regras de seleção e avaliação dos testes. 

Também enumera os níveis clássicos:

* teste de unidade;
* teste de integração;
* teste de sistema;
* teste de aceitação;
* teste de regressão. 

### Aplicação prática em jogos

* **unidade**: valida pequenas rotinas, como métodos e comportamentos isolados;
* **integração**: verifica relação entre módulos, por exemplo física + animação + entrada;
* **sistema**: testa o jogo como produto executável;
* **aceitação**: valida com usuários selecionados;
* **regressão**: reexecuta testes em novas versões.

---

## 14. Modelo V no paralelismo entre desenvolvimento e teste

A **Figura 2**, na página 48, apresenta um **modelo V**, que relaciona atividades de desenvolvimento a seus respectivos níveis de teste. O lado esquerdo mostra:

* especificação de requisitos;
* projeto de alto nível;
* projeto detalhado;
* codificação.

O lado direito mostra, em correspondência:

* teste de aceitação;
* teste de sistema;
* teste de integração;
* teste de unidade. 

### Significado técnico

O modelo V reforça que testes não devem ser pensados apenas no final. Eles precisam ser planejados em paralelo ao desenvolvimento.

Em jogos, isso é ainda mais importante porque:

* alterações em mecânica afetam múltiplos sistemas;
* o custo de descobrir erro tarde é alto;
* problemas podem surgir só quando arte, lógica, física e rede estão integradas.

---

## 15. Versionamento e manutenção

Na página final, o material destaca o uso de **Git**, com exemplos como **GitHub** e **GitLab**, para permitir controle de versões, rastreabilidade e retorno a versões anteriores em caso de falhas. 

### Importância técnica

Versionamento em jogos é crítico porque:

* muitos artefatos mudam simultaneamente;
* há código, assets, documentos, testes e scripts;
* o risco de regressão é alto;
* equipes grandes precisam sincronizar trabalho.

O capítulo enfatiza que repositórios, versões e registros de modificações devem ser mantidos no documento de desenho do jogo, bem como registros de testes e demais elementos atualizados. 

---

## 16. Síntese técnica final

O principal ensinamento do material é que desenvolver jogos digitais significa integrar, de forma disciplinada, elementos que vão muito além do código:

* regras;
* narrativa;
* mecânicas;
* arte;
* IA;
* interface;
* infraestrutura;
* testes;
* gerenciamento;
* manutenção.

Assim, a Engenharia de Software em jogos não elimina a criatividade, mas dá estrutura para que ela se transforme em produto viável, escalável, testável e sustentável.

---

# Versão curta para revisão rápida

## O que torna jogos diferentes

* Interatividade
* Recompensa e progressão
* Narrativa
* Imersão
* Equilíbrio
* Integração entre arte, software e infraestrutura

## Artefato central

* **Game Design Document (GDD)**

## Dois projetos integrados

* Projeto criativo do jogo
* Projeto de software do jogo

## UML aplicada a jogos

* Casos de uso
* Classes
* Sequência
* Componentes
* Atividades

## Métodos de gestão

* SCRUM
* PMBOK

## Ferramentas citadas

* Unity
* Godot
* Unreal
* Blender
* Maya
* Gimp
* Cocos2d
* Construct

## Conceitos de qualidade estrutural

* Baixo acoplamento
* Alta coesão
* Reuso
* Orientação a objetos
* Padrões de projeto

## Testes

* Unidade
* Integração
* Sistema
* Aceitação
* Regressão

## Conceitos de defeitos

* Defeito
* Erro
* Falha

## Manutenção

* Git
* GitHub / GitLab
* Controle de versões
* Registro contínuo de mudanças e testes

---

