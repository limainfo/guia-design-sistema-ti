# Resumo geral para a prova

## 1. Virtualização e containers

### Hypervisors

- **Tipo 1:** executa diretamente no hardware; comum em servidores e datacenters.
- **Tipo 2:** executa sobre um sistema operacional hospedeiro; comum em desktops e laboratórios.

### VM versus container

| VM | Container |
|---|---|
| Virtualiza hardware | Isola processos no mesmo kernel |
| Inclui SO convidado | Compartilha kernel do host |
| Mais pesada | Mais leve |
| Inicialização mais lenta | Inicialização rápida |
| Pode usar kernel diferente | Depende de kernel compatível |

### Linux

- **Namespaces:** isolam PID, rede, mounts, usuários, hostname e IPC.
- **cgroups:** limitam e contabilizam CPU, memória, I/O e processos.
- **Kernel:** gerencia recursos do sistema.

## 2. Docker

### Conceitos

- **Imagem:** pacote imutável de arquivos, dependências e metadados.
- **Container:** instância executável de uma imagem.
- **Registry:** serviço que armazena imagens.
- **Repository:** coleção de imagens relacionadas.
- **Tag:** nome lógico de versão; `latest` não garante versão mais recente.

### Fluxo do `docker run`

1. Docker procura a imagem localmente.
2. Se não existir, realiza pull do registry padrão.
3. Cria o container.
4. Configura filesystem, rede, volumes e limites.
5. Inicia o processo principal.

### Portas

```bash
docker run -p 8080:80 nginx
```

Ordem correta: `HOST:CONTAINER`.

### Dockerfile

- `FROM`: imagem base;
- `WORKDIR`: diretório de trabalho;
- `COPY`: copia arquivos;
- `RUN`: executa durante build;
- `USER`: usuário de execução;
- `EXPOSE`: documenta porta;
- `CMD`: comando padrão;
- `ENTRYPOINT`: executável principal.

### Cache

Copie arquivos de dependências antes do código para preservar cache.

### Multi-stage

Separa compilação da imagem final, reduzindo tamanho e superfície de ataque.

## 3. Volumes e redes

### Volumes

- persistem após remoção do container;
- podem ser compartilhados;
- são gerenciados pelo Docker;
- não confundir com a camada gravável do container.

### Montagens

- volume nomeado: persistência gerenciada;
- bind mount: caminho do host;
- `tmpfs`: memória, sem persistência.

### Redes

- `bridge`: padrão em um host;
- `host`: compartilha rede do host;
- `none`: sem rede;
- `overlay`: comunicação entre nós do Swarm;
- `macvlan` e `ipvlan`: integração avançada à rede.

### DNS interno

Em rede definida pelo usuário, containers resolvem nomes de outros containers/serviços.

## 4. Troubleshooting Docker

| Comando | Função |
|---|---|
| `docker ps -a` | Estado de todos os containers |
| `docker logs -f` | Acompanhar logs |
| `docker inspect` | Metadados detalhados |
| `docker stats` | CPU, memória, rede e I/O |
| `docker exec -it ... sh` | Executar shell/comando |
| `docker network inspect` | Inspecionar rede |
| `docker volume inspect` | Inspecionar volume |

### Exit codes

- `0`: sucesso;
- `1`: erro genérico;
- `126`: sem permissão;
- `127`: comando não encontrado;
- `137`: SIGKILL/OOM frequente;
- `143`: SIGTERM.

### Restart policies

- `no`;
- `on-failure`;
- `always`;
- `unless-stopped`.

## 5. Docker Compose

### Conceito

Define e executa aplicações multicontainer em YAML.

### Comando atual

```bash
docker compose up -d
```

Não preferir `docker-compose`, que pertence ao Compose V1.

### Atualização de schema

A chave superior `version` está obsoleta.

### Elementos

- `services`;
- `networks`;
- `volumes`;
- `secrets`;
- `ports`;
- `environment`;
- `depends_on`;
- `healthcheck`.

### Condições de dependência

- `service_started`;
- `service_healthy`;
- `service_completed_successfully`.

`depends_on` não substitui retry e tolerância a falhas da aplicação.

## 6. Segurança de containers

- use imagens confiáveis;
- analise vulnerabilidades;
- atualize e reconstrua imagens;
- execute como usuário não root;
- remova capabilities;
- use `no-new-privileges`;
- defina filesystem read-only quando possível;
- limite CPU, memória e PIDs;
- não monte o socket Docker sem necessidade;
- não grave segredos na imagem;
- segmente redes;
- restrinja volumes;
- use Seccomp, AppArmor ou SELinux;
- gere SBOM e aplique assinatura moderna.

### Docker Scout

```bash
docker scout quickview imagem
docker scout cves imagem
```

### Atualização DCT

Docker Content Trust/Notary v1 está sendo retirado em 2026. Para novos projetos, avaliar Cosign ou Notation.

## 7. Orquestração

### Motivações

- gerenciamento centralizado;
- descoberta de serviço;
- balanceamento;
- escala;
- auto-recuperação;
- rollout e rollback;
- armazenamento;
- monitoramento.

### Estado desejado

Controllers comparam estado atual e desejado e executam ações corretivas.

## 8. Docker Swarm

### Componentes

- **Manager:** gerencia estado e agenda tasks.
- **Worker:** executa tasks.
- **Service:** definição da aplicação.
- **Task:** unidade de execução de uma réplica.
- **Overlay:** rede entre nós.
- **Routing mesh:** distribuição de tráfego publicado.

### Comandos

```bash
docker swarm init
docker node ls
docker service create
docker service ls
docker service ps
docker service scale web=5
docker service update --replicas 5 web
docker stack deploy -c stack.yaml stack
docker swarm leave --force
```

## 9. Kubernetes

### Control Plane

- `kube-apiserver`: entrada da API;
- `etcd`: estado do cluster;
- `kube-scheduler`: escolhe Node para Pod;
- `kube-controller-manager`: executa controllers;
- `cloud-controller-manager`: integração com nuvem.

### Worker

- `kubelet`: garante execução dos Pods;
- container runtime: executa containers via CRI;
- `kube-proxy` ou dataplane equivalente: regras de Services;
- CNI: rede de Pods.

### Atualização runtime

Kubernetes usa CRI. Docker Engine exige `cri-dockerd`; containerd e CRI-O são comuns.

### Falha de Node

- heartbeats param;
- Node fica NotReady;
- novos Pods não são agendados;
- controllers criam substitutos em outros Nodes, conforme políticas.

## 10. Pods e workloads

### Pod

- menor unidade implantável;
- um ou mais containers;
- compartilha IP, portas e volumes;
- geralmente efêmero.

### Estados de container

- Waiting;
- Running;
- Terminated.

### Sidecar

Container auxiliar que estende a aplicação principal.

### Probes

- **startup:** inicialização concluída;
- **readiness:** pode receber tráfego;
- **liveness:** precisa ser reiniciado?

### Workloads

| Objeto | Uso |
|---|---|
| Deployment | Aplicações stateless e atualização |
| ReplicaSet | Quantidade de réplicas |
| StatefulSet | Identidade e volumes estáveis |
| DaemonSet | Um Pod por Node |
| Job | Tarefa até conclusão |
| CronJob | Tarefa agendada |

### Estratégias de Deployment

- `RollingUpdate`: atualização gradual;
- `Recreate`: remove antigos antes de criar novos; gera downtime.

## 11. Services e rede Kubernetes

### Service

Ponto de acesso estável para Pods selecionados por labels.

### Tipos

- ClusterIP: interno e padrão;
- NodePort: porta em cada Node;
- LoadBalancer: balanceador externo;
- ExternalName: alias DNS;
- Headless: `clusterIP: None`, descoberta direta.

### EndpointSlice

Mantém endpoints prontos do Service.

### Ingress

Regras HTTP/HTTPS e requer Ingress Controller.

### Atualização

Ingress está congelado. Gateway API é recomendada para novos recursos.

### Tráfego

- norte-sul: externo para interno;
- leste-oeste: comunicação entre serviços.

## 12. Service Mesh e Istio

### Service mesh

Gerencia comunicação, segurança, observabilidade, resiliência e tráfego entre serviços.

### Istio

- control plane configura o dataplane;
- sidecar mode usa Envoy em cada Pod;
- ambient mode usa `ztunnel` por Node e waypoint opcional.

## 13. Diferenças que mais confundem

| Conceitos | Diferença principal |
|---|---|
| Imagem x container | Pacote x execução |
| Container x VM | Kernel compartilhado x SO convidado |
| Volume x bind mount | Gerenciado pelo Docker x caminho do host |
| `docker run` x `docker start` | Cria e inicia x inicia existente |
| Compose x Swarm | Projeto local x cluster reconciliado |
| Pod x Deployment | Unidade executável x controlador de Pods |
| Readiness x liveness | Tráfego x reinício |
| ClusterIP x NodePort | Interno x porta em Nodes |
| Ingress x Service | Roteamento HTTP externo x acesso estável a Pods |
| Ingress x Gateway API | API congelada x modelo extensível moderno |
| Sidecar x DaemonSet | Auxiliar por Pod x agente por Node |
