# Kubernetes no laboratório

## Objetos da aplicação

Cada componente possui:

- um Deployment com duas réplicas;
- um Service;
- probes de readiness e liveness;
- requests e limits;
- rolling update sem indisponibilidade planejada;
- distribuição por hostname com `topologySpreadConstraints`.

## Service e balanceamento

O Service seleciona os pods por labels. O frontend Nginx encaminha `/api/` para:

```text
http://microplatform-backend:8080
```

Esse nome é resolvido pelo DNS interno do Kubernetes.

## Readiness versus liveness

- readiness: informa quando o pod pode receber tráfego;
- liveness: informa quando o container deve ser reiniciado.

Durante um rolling update, o Service só encaminha requisições aos pods que já
passaram pela readiness probe.

## StatefulSet do PostgreSQL

O PostgreSQL utiliza StatefulSet porque necessita identidade e armazenamento
persistente. O PVC usa a StorageClass `standard` instalada pelo Kind.

## Experimentos

```bash
kubectl -n dev scale deployment microplatform-backend --replicas=5
kubectl -n dev get pods -o wide
kubectl -n dev delete pod -l app.kubernetes.io/name=microbackend
kubectl -n dev rollout history deployment/microplatform-backend
```

Após testar a escala manual, um novo `helm upgrade` restaura o número definido
nos values do chart, demonstrando a reconciliação declarativa.
