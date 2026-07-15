# Atualizações e correções técnicas em relação ao material

Este documento preserva o que pode ser cobrado na prova e registra diferenças relevantes entre os slides de 2025 e as práticas/documentações atuais em 2026.

| Tema no material | Ajuste adotado na documentação |
|---|---|
| Porta Docker descrita como “interna:externa” | A sintaxe correta de `-p` é `HOST:CONTAINER` |
| `docker-compose` | Compose V2 usa `docker compose` |
| `version: "3.8"` em Compose | A chave superior `version` está obsoleta |
| Docker Toolbox | Ferramenta legada e obsoleta |
| Script `get.docker.com` | Útil em laboratório; repositório oficial é preferível para produção |
| Usuário no grupo `docker` | O grupo concede privilégios equivalentes a root |
| Docker Community x Enterprise | A nomenclatura é histórica; ofertas e assinaturas atuais mudaram |
| AWS “AKS” | O serviço Kubernetes da AWS é EKS; AKS pertence ao Azure |
| `docker swarm nodes --help` | O comando correto é `docker node --help` |
| Kubernetes usa Docker como runtime | Kubernetes usa CRI; Docker Engine exige `cri-dockerd`; containerd e CRI-O são comuns |
| Falha de Node “migra” Pods | Controllers criam Pods substitutos; não ocorre migração viva padrão |
| ISO como snapshot de VM | ISO é imagem de disco/mídia; snapshot é recurso do hypervisor |
| Docker Content Trust | DCT/Notary v1 está sendo retirado em 2026; considerar Cosign ou Notation |
| Ingress como direção principal | Ingress continua estável, mas está congelado; Gateway API recebe novos recursos |
| Istio apenas com Envoy sidecar | Istio também oferece ambient mode com `ztunnel` e waypoint opcional |
| “Aplicação monolítica deve evitar Docker” | Monólitos podem ser containerizados; a decisão depende de estado, acoplamento e requisitos |
| `EXPOSE` publica porta | `EXPOSE` documenta; publicação exige `-p` ou configuração equivalente |

## Fontes oficiais consultadas

- Docker Compose V2 e histórico: <https://docs.docker.com/compose/intro/history/>
- Chave `version` obsoleta: <https://docs.docker.com/reference/compose-file/version-and-name/>
- Pós-instalação e grupo Docker: <https://docs.docker.com/engine/install/linux-postinstall/>
- Produtos retirados e DCT: <https://docs.docker.com/retired/>
- Container runtimes Kubernetes: <https://kubernetes.io/docs/setup/production-environment/container-runtimes/>
- CRI: <https://kubernetes.io/docs/concepts/containers/cri/>
- Ingress: <https://kubernetes.io/docs/concepts/services-networking/ingress/>
- Gateway API: <https://kubernetes.io/docs/concepts/services-networking/gateway/>
- Modos de dataplane Istio: <https://istio.io/latest/docs/overview/dataplane-modes/>
