# Glossário

## A

**Admission Controller** — Componente que pode validar ou modificar requisições à API Kubernetes antes da persistência.

**Ambient mode** — Modo de dataplane do Istio que evita sidecar por Pod, usando `ztunnel` por Node e waypoint opcional.

**API Server** — Componente central do Kubernetes que expõe a API do cluster.

**AppArmor** — Mecanismo de controle de acesso baseado em perfis, usado para restringir processos.

## B

**Bare metal** — Execução direta sobre hardware físico, sem camada de virtualização para a carga em questão.

**Bind mount** — Montagem que vincula um caminho do host a um caminho do container.

**Bridge** — Driver de rede Docker padrão para comunicação entre containers no mesmo host.

**Build context** — Conjunto de arquivos enviado ao processo de build da imagem.

**BuildKit** — Backend moderno de construção de imagens Docker.

## C

**Capability** — Unidade granular de privilégio do kernel Linux, como `NET_BIND_SERVICE`.

**cgroups** — Recurso Linux para medir, limitar e priorizar recursos de grupos de processos.

**Cluster** — Conjunto de máquinas que trabalham como uma plataforma coordenada.

**ClusterIP** — Tipo padrão de Service Kubernetes, acessível internamente.

**CNI** — Container Network Interface; padrão de plugins para rede de containers e Pods.

**Compose** — Ferramenta para definir e executar aplicações Docker multicontainer.

**ConfigMap** — Objeto Kubernetes para dados de configuração não sensíveis.

**Container** — Processo ou conjunto de processos isolados, executado a partir de uma imagem.

**Container runtime** — Software que executa containers, como containerd ou CRI-O.

**Control Plane** — Componentes que gerenciam estado e decisões globais do cluster Kubernetes.

**Controller** — Loop que observa estado atual e desejado e executa ações de reconciliação.

**CRI** — Container Runtime Interface; protocolo entre kubelet e runtime.

**CronJob** — Workload Kubernetes que agenda Jobs segundo expressão cron.

## D

**Daemon** — Processo executado em segundo plano.

**DaemonSet** — Workload Kubernetes que mantém um Pod em cada Node elegível.

**Dataplane** — Componentes que processam o tráfego ou executam o trabalho real.

**Deployment** — Workload Kubernetes para aplicações stateless e atualizações declarativas.

**Digest** — Identificador imutável baseado no conteúdo de uma imagem OCI.

**Docker daemon** — Processo `dockerd`, responsável pela API e coordenação do Docker Engine.

**Dockerfile** — Arquivo declarativo usado para construir uma imagem.

## E

**EndpointSlice** — Objeto Kubernetes que representa endpoints de rede associados a Services.

**ENTRYPOINT** — Instrução Dockerfile que define o executável principal.

**etcd** — Banco chave-valor distribuído que armazena o estado da API Kubernetes.

**ExternalName** — Tipo de Service que cria um alias DNS para um nome externo.

## G

**Gateway API** — Família de APIs Kubernetes para provisionamento e roteamento de rede extensível.

## H

**Headless Service** — Service sem ClusterIP, usado para descoberta direta de endpoints.

**Health check** — Verificação do estado funcional de uma aplicação ou serviço.

**Heartbeat** — Sinal periódico que indica que um componente continua ativo.

**Horizontal Pod Autoscaler** — Controlador que ajusta réplicas com base em métricas.

**Hypervisor** — Camada que cria e administra máquinas virtuais.

## I

**Imagem** — Pacote imutável com filesystem, dependências e metadados para criar containers.

**Ingress** — API Kubernetes para regras de entrada HTTP/HTTPS; exige controlador.

**Ingress Controller** — Implementação que observa objetos Ingress e configura dataplane.

**Init container** — Container que executa e termina antes dos containers principais do Pod.

**Istio** — Service mesh que oferece segurança, tráfego e observabilidade.

## J

**Job** — Workload Kubernetes para executar uma tarefa até conclusão.

## K

**Kernel** — Núcleo do sistema operacional que gerencia recursos e hardware.

**kube-apiserver** — Servidor da API Kubernetes.

**kube-controller-manager** — Processo que executa controllers principais.

**kube-proxy** — Componente que implementa regras de rede para Services, salvo alternativas.

**kube-scheduler** — Componente que atribui Pods a Nodes.

**kubectl** — Cliente de linha de comando da API Kubernetes.

**kubelet** — Agente do Node que garante execução dos Pods atribuídos.

## L

**Label** — Par chave-valor usado para organizar e selecionar objetos Kubernetes.

**Liveness probe** — Verificação que indica se um container deve ser reiniciado.

**LoadBalancer** — Tipo de Service que solicita balanceador externo.

## M

**Macvlan** — Driver Docker que atribui endereço MAC ao container.

**Manager Node** — Nó Swarm que mantém estado, agenda tasks e gerencia o cluster.

**Manifest** — Arquivo declarativo, normalmente YAML, que define objetos Kubernetes.

**Multi-stage build** — Dockerfile com múltiplos estágios para separar build e runtime.

## N

**Namespace Linux** — Mecanismo de isolamento de recursos, como PID, rede e mounts.

**Namespace Kubernetes** — Escopo lógico para organização de objetos no cluster.

**NetworkPolicy** — Objeto Kubernetes que declara tráfego permitido entre Pods e redes.

**Node** — Máquina worker ou control plane participante de um cluster.

**NodePort** — Tipo de Service que abre uma porta em cada Node.

## O

**OCI** — Open Container Initiative; padrões para imagens, runtimes e distribuição.

**Overlay network** — Rede virtual distribuída entre nós do Docker Swarm.

## P

**PersistentVolume** — Recurso Kubernetes que representa armazenamento persistente.

**PersistentVolumeClaim** — Solicitação de armazenamento feita por um workload.

**Pod** — Menor unidade implantável Kubernetes, composta por um ou mais containers.

**Port publishing** — Exposição de porta do container por meio do host.

**Readiness probe** — Verificação que determina se o Pod pode receber tráfego.

**Reconciliation** — Processo de aproximar estado atual do estado desejado.

**Registry** — Serviço de armazenamento e distribuição de imagens.

**ReplicaSet** — Workload que mantém uma quantidade desejada de Pods.

**Repository** — Coleção de imagens relacionadas dentro de um registry.

**Request** — Recurso reservado/considerado pelo scheduler para um container Kubernetes.

**Rootless** — Execução do daemon ou container sem privilégios root no host.

**Routing mesh** — Recurso Swarm que distribui tráfego publicado para tasks do serviço.

## S

**SBOM** — Software Bill of Materials; inventário de componentes de software.

**Scheduler** — Componente que escolhe onde workloads serão executados.

**Seccomp** — Filtro de chamadas de sistema Linux.

**Secret** — Dado sensível disponibilizado a workloads; exige proteção adicional em repouso e acesso.

**SELinux** — Sistema de controle de acesso obrigatório baseado em políticas e rótulos.

**Service** — Objeto Kubernetes que fornece acesso estável a Pods.

**Service Mesh** — Camada para gerenciar comunicação entre serviços.

**ServiceAccount** — Identidade usada por processos em Pods para acessar a API Kubernetes.

**Sidecar** — Container auxiliar executado junto do container principal no Pod.

**Startup probe** — Verificação que determina se a inicialização da aplicação foi concluída.

**StatefulSet** — Workload para Pods com identidade e armazenamento estáveis.

**Swarm** — Modo de orquestração integrado ao Docker Engine.

## T

**Tag** — Referência lógica e mutável para uma versão de imagem.

**Task** — Unidade de trabalho de um Service no Swarm.

**Taint** — Marca em Node que restringe agendamento, exceto para Pods com toleration.

**tmpfs** — Montagem temporária em memória.

## V

**Volume** — Armazenamento externo ao ciclo de vida da camada gravável do container.

## W

**Waypoint proxy** — Proxy opcional do Istio ambient para processamento L7.

**Worker Node** — Nó que executa workloads do cluster.

**Workload** — Objeto que administra Pods, como Deployment, StatefulSet ou Job.

## Z

**ztunnel** — Proxy por Node usado pelo Istio ambient para conectividade segura L4.
