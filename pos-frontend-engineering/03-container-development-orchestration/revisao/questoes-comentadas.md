# Questões comentadas

## Fundamentos

### 1. Qual é a principal diferença entre uma VM e um container?

A. Containers incluem um sistema operacional completo.  
B. VMs compartilham o kernel do host.  
C. VMs normalmente possuem SO convidado; containers compartilham o kernel do host.  
D. Não existe diferença de isolamento.

**Resposta: C.** A VM virtualiza hardware e carrega um SO convidado. O container isola processos e recursos em nível de sistema operacional.

### 2. O que caracteriza um hypervisor tipo 1?

A. Executa dentro de um container.  
B. Executa diretamente sobre o hardware.  
C. Executa somente em Windows.  
D. Não permite múltiplas VMs.

**Resposta: B.** Também é chamado bare metal e é comum em infraestrutura de produção.

### 3. Qual recurso do Linux limita CPU e memória de grupos de processos?

A. Namespace UTS.  
B. Shell.  
C. cgroups.  
D. Registry.

**Resposta: C.** Namespaces isolam a visão; cgroups controlam e contabilizam recursos.

### 4. Qual recurso separa a árvore de processos visível por um container?

A. PID namespace.  
B. Volume.  
C. Hyper-V.  
D. Tag.

**Resposta: A.** O PID namespace cria uma visão isolada dos processos.

## Docker e imagens

### 5. O que é uma imagem Docker?

A. Um container em execução.  
B. Um pacote de camadas, arquivos, dependências e metadados usado para criar containers.  
C. Um volume persistente.  
D. Uma rede bridge.

**Resposta: B.** A imagem é o modelo imutável; o container é a instância executável.

### 6. Ao executar `docker run nginx` sem a imagem local, o que ocorre?

A. O comando sempre falha.  
B. Docker cria uma VM.  
C. Docker procura a imagem no registry padrão e realiza pull.  
D. Docker compila Nginx.

**Resposta: C.** Por padrão, o registry é o Docker Hub quando nenhum outro é informado.

### 7. Em `-p 8080:80`, qual é a interpretação correta?

A. Container 8080 para host 80.  
B. Host 8080 para container 80.  
C. Duas portas internas.  
D. Rede 8080 e volume 80.

**Resposta: B.** A ordem é `HOST:CONTAINER`.

### 8. Qual comando lista também containers parados?

A. `docker ps`  
B. `docker container ls -a`  
C. `docker image ls`  
D. `docker stats`

**Resposta: B.** `docker ps -a` é um atalho equivalente.

### 9. Qual é a função do `WORKDIR`?

A. Publicar uma porta.  
B. Definir o diretório de trabalho para instruções seguintes e execução.  
C. Criar rede.  
D. Adicionar usuário ao grupo Docker.

**Resposta: B.** Afeta instruções como `RUN`, `COPY`, `CMD` e o diretório inicial do processo.

### 10. Por que copiar o arquivo de dependências antes do código?

A. Para impedir o build.  
B. Para aumentar o tamanho.  
C. Para aproveitar o cache quando apenas o código mudar.  
D. Para publicar a imagem.

**Resposta: C.** A camada de instalação das dependências pode ser reutilizada.

### 11. Qual é a principal vantagem de multi-stage build?

A. Executar múltiplos containers.  
B. Separar compilação e runtime, reduzindo a imagem final.  
C. Criar múltiplas redes.  
D. Substituir o registry.

**Resposta: B.** Compiladores e artefatos intermediários não precisam ficar na imagem final.

### 12. A tag `latest` significa necessariamente a versão mais recente?

A. Sim, sempre.  
B. Não; é apenas a tag assumida quando outra não é informada.  
C. Apenas no Kubernetes.  
D. Apenas no Docker Hub privado.

**Resposta: B.** Tags são referências mutáveis definidas pelo publicador.

## Volumes, redes e troubleshooting

### 13. Qual é a principal vantagem de um volume?

A. Alterar o kernel.  
B. Persistir dados além do ciclo de vida do container.  
C. Substituir a imagem.  
D. Criar um hypervisor.

**Resposta: B.** Volumes são externos à camada gravável do container.

### 14. Qual é a diferença principal entre volume e bind mount?

A. Volume é gerenciado pelo Docker; bind mount aponta para caminho do host.  
B. Bind mount é sempre temporário.  
C. Volume não persiste.  
D. Não existe diferença.

**Resposta: A.** Bind mounts acoplam mais diretamente a estrutura do host.

### 15. Qual é o driver de rede padrão do Docker em um host comum?

A. overlay.  
B. none.  
C. bridge.  
D. macvlan.

**Resposta: C.** Redes bridge definidas pelo usuário ainda fornecem DNS por nome.

### 16. Qual rede é usada para conectar serviços em nós diferentes do Swarm?

A. host.  
B. overlay.  
C. none.  
D. loopback.

**Resposta: B.** Overlay cria uma rede virtual distribuída.

### 17. Qual comando acompanha logs continuamente?

A. `docker logs -f container`  
B. `docker inspect -f container`  
C. `docker stats -a`  
D. `docker volume ls`

**Resposta: A.** `-f` segue novas linhas de log.

### 18. Qual comando mostra CPU e memória em tempo real?

A. `docker stats`  
B. `docker history`  
C. `docker tag`  
D. `docker login`

**Resposta: A.** Também mostra rede, I/O e PIDs.

### 19. Qual política reinicia o container, exceto quando ele foi parado explicitamente?

A. `no`  
B. `on-failure`  
C. `unless-stopped`  
D. `never`

**Resposta: C.** `always` também reinicia, mas não preserva a intenção de parada da mesma forma.

### 20. O código de saída 137 costuma indicar o quê?

A. Sucesso.  
B. Comando não encontrado.  
C. SIGKILL, frequentemente associado a OOM.  
D. Erro de DNS exclusivamente.

**Resposta: C.** É preciso confirmar com `docker inspect` e o campo `OOMKilled`.

## Docker Compose e segurança

### 21. Qual é o principal benefício do Docker Compose?

A. Substituir Dockerfile.  
B. Gerenciar múltiplos serviços com uma configuração YAML.  
C. Criar hypervisors.  
D. Eliminar a necessidade de imagens.

**Resposta: B.** Compose também administra redes e volumes do projeto.

### 22. Qual é o comando moderno do Compose V2?

A. `docker-compose up`  
B. `docker compose up`  
C. `docker stack compose`  
D. `compose docker up`

**Resposta: B.** A forma com hífen pertence ao Compose V1.

### 23. Qual é a situação da chave superior `version` no Compose atual?

A. Obrigatória.  
B. Proibida e causa falha sempre.  
C. Obsoleta e apenas informativa.  
D. Define a versão do Docker Engine.

**Resposta: C.** Compose usa a especificação atual suportada.

### 24. O que `condition: service_healthy` exige?

A. Apenas que o container tenha sido criado.  
B. Que a dependência passe em seu health check.  
C. Que o serviço termine.  
D. Que a imagem esteja no Docker Hub.

**Resposta: B.** É mais adequado quando a dependência precisa estar pronta.

### 25. Qual é a principal vantagem de executar como usuário não root?

A. Aumentar o número de portas.  
B. Reduzir impacto de comprometimento e escalada.  
C. Remover a necessidade de logs.  
D. Habilitar overlay.

**Resposta: B.** Privilégios mínimos reduzem o alcance do atacante.

### 26. Por que não montar `/var/run/docker.sock` em qualquer container?

A. O arquivo não existe.  
B. Pode conceder controle do daemon e privilégios sobre o host.  
C. Impede redes bridge.  
D. Torna a imagem maior.

**Resposta: B.** É um dos riscos mais críticos em ambientes Docker.

### 27. Qual ferramenta citada analisa vulnerabilidades de imagens?

A. Docker Scout.  
B. Docker Compose.  
C. kube-proxy.  
D. etcd.

**Resposta: A.** `docker scout cves` detalha vulnerabilidades e dependências.

### 28. Qual é a atualização sobre Docker Content Trust em 2026?

A. Tornou-se obrigatório.  
B. DCT/Notary v1 está sendo retirado; alternativas incluem Cosign e Notation.  
C. Foi incorporado ao Kubernetes scheduler.  
D. Substitui Seccomp.

**Resposta: B.** Novos projetos devem planejar assinatura OCI moderna.

## Orquestração e Swarm

### 29. O que é estado desejado?

A. O log atual do container.  
B. A declaração de como o sistema deve estar, usada pelos controllers.  
C. A imagem local.  
D. O IP do manager.

**Resposta: B.** O orquestrador reconcilia o estado atual com essa declaração.

### 30. Qual componente do Swarm gerencia o cluster?

A. Worker.  
B. Manager.  
C. Volume.  
D. Registry.

**Resposta: B.** Managers mantêm estado, agendam tasks e reconciliam services.

### 31. O que é uma Task no Swarm?

A. Um registry.  
B. Uma unidade de trabalho de um Service, normalmente um container.  
C. Um tipo de volume.  
D. Uma rede física.

**Resposta: B.** Services geram tasks conforme número de réplicas.

### 32. Qual comando lista Nodes no Swarm?

A. `docker swarm nodes`  
B. `docker node ls`  
C. `docker service nodes`  
D. `docker host ls`

**Resposta: B.** O namespace correto é `docker node`.

### 33. Qual comando escala o serviço `web` para cinco réplicas?

A. `docker service scale web=5`  
B. `docker run web 5`  
C. `docker node scale web`  
D. `docker swarm replicas 5`

**Resposta: A.** `docker service update --replicas 5 web` também é válido.

## Kubernetes

### 34. Qual componente expõe a API HTTP central do Kubernetes?

A. kubelet.  
B. kube-apiserver.  
C. kube-proxy.  
D. containerd.

**Resposta: B.** É a porta de entrada para operações no cluster.

### 35. Qual componente armazena o estado da API?

A. Docker Hub.  
B. etcd.  
C. Ingress.  
D. Envoy.

**Resposta: B.** etcd é um banco chave-valor consistente.

### 36. Qual é a função do kube-scheduler?

A. Executar containers.  
B. Escolher um Node adequado para Pods sem vínculo.  
C. Armazenar logs.  
D. Criar imagens.

**Resposta: B.** kubelet e runtime executam os containers.

### 37. O que acontece quando um Worker deixa de responder?

A. Kubernetes migra o processo vivo.  
B. O Node é marcado NotReady e controllers podem criar substitutos em outros Nodes.  
C. etcd é apagado.  
D. O cluster sempre encerra.

**Resposta: B.** A reação respeita tempos, tolerâncias, volumes e políticas.

### 38. Qual é a menor unidade implantável do Kubernetes?

A. Container isolado.  
B. Pod.  
C. Node.  
D. Namespace.

**Resposta: B.** Kubernetes agenda Pods.

### 39. O que containers no mesmo Pod compartilham?

A. Apenas imagem.  
B. IP, namespace de rede e volumes declarados.  
C. Nodes diferentes.  
D. Registries.

**Resposta: B.** Eles se comunicam por `localhost` e precisam coordenar portas.

### 40. Qual probe controla se o Pod deve receber tráfego?

A. liveness.  
B. readiness.  
C. startup exclusivamente.  
D. heartbeat do Node.

**Resposta: B.** Falha de readiness remove o endpoint do Service.

### 41. Qual probe indica que o container precisa ser reiniciado?

A. readiness.  
B. liveness.  
C. Service.  
D. EndpointSlice.

**Resposta: B.** Uma liveness mal configurada pode criar reinicializações em loop.

### 42. Qual estratégia de Deployment remove todos os Pods antigos antes dos novos?

A. RollingUpdate.  
B. Recreate.  
C. Headless.  
D. NodePort.

**Resposta: B.** Evita coexistência, mas gera downtime.

### 43. Qual workload oferece identidade estável e volume por réplica?

A. Deployment.  
B. StatefulSet.  
C. DaemonSet.  
D. CronJob.

**Resposta: B.** É comum em sistemas distribuídos e bancos.

### 44. Qual workload executa um Pod em cada Node elegível?

A. DaemonSet.  
B. ReplicaSet.  
C. Service.  
D. Ingress.

**Resposta: A.** Usado para agentes de logs, métricas e rede.

### 45. Qual workload executa uma tarefa até conclusão?

A. Job.  
B. Deployment.  
C. Service.  
D. NodePort.

**Resposta: A.** CronJob agenda Jobs periodicamente.

## Services e mesh

### 46. Qual é o tipo padrão de Service?

A. NodePort.  
B. LoadBalancer.  
C. ClusterIP.  
D. ExternalName.

**Resposta: C.** Expõe o Service internamente no cluster.

### 47. Qual Service usa `clusterIP: None`?

A. LoadBalancer.  
B. Headless Service.  
C. NodePort.  
D. ExternalName obrigatório.

**Resposta: B.** Permite descoberta direta dos endpoints.

### 48. Qual é a função de EndpointSlice?

A. Armazenar imagens.  
B. Representar endpoints de rede associados a Services.  
C. Criar Nodes.  
D. Compilar Dockerfiles.

**Resposta: B.** É atualizado conforme Pods selecionados e prontos mudam.

### 49. Qual é a situação atual da API Ingress?

A. Foi removida.  
B. Está estável, porém congelada; Gateway API é recomendada para novos recursos.  
C. Substituiu Service.  
D. Só funciona no Docker Swarm.

**Resposta: B.** Ingress continua utilizável e compatível.

### 50. O que é um Service Mesh?

A. Um tipo de volume.  
B. Uma camada de infraestrutura que gerencia comunicação entre serviços.  
C. Um hypervisor.  
D. Um registry privado.

**Resposta: B.** Pode oferecer mTLS, políticas, telemetria e controle de tráfego.

### 51. Qual é a diferença entre o Istio sidecar mode e ambient mode?

A. Não existe diferença.  
B. Sidecar usa proxy por Pod; ambient usa proxy L4 por Node e waypoint opcional para L7.  
C. Ambient exige VM por Pod.  
D. Sidecar não possui dataplane.

**Resposta: B.** Os dois modos podem coexistir na mesma mesh.
