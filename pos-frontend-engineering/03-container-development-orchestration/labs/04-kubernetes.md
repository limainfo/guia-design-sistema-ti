# Laboratório 4 — Kubernetes

## Objetivo

Aplicar manifests, observar Pods e Deployments, testar um Service, escalar, atualizar, executar rollback e diagnosticar eventos.

## Pré-requisitos

Um cluster local, por exemplo:

- Docker Desktop Kubernetes;
- kind;
- minikube;
- k3s;
- cluster remoto de laboratório.

Confirme:

```bash
kubectl cluster-info
kubectl get nodes
kubectl config current-context
```

## Parte 1 — Aplicar namespace

```bash
cd examples/kubernetes
kubectl apply -f namespace.yaml
kubectl get namespace estudo-containers
```

Defina o namespace no contexto atual, opcionalmente:

```bash
kubectl config set-context --current --namespace=estudo-containers
```

## Parte 2 — Deployment e Service

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

Verifique:

```bash
kubectl get deployments
kubectl get replicasets
kubectl get pods -o wide
kubectl get service
```

## Parte 3 — Acompanhar rollout

```bash
kubectl rollout status deployment/web
kubectl rollout history deployment/web
```

## Parte 4 — Testar o Service

```bash
kubectl port-forward service/web 8080:80
```

Em outro terminal:

```bash
curl http://localhost:8080
```

## Parte 5 — Service e endpoints

```bash
kubectl get endpointslices \
  -l kubernetes.io/service-name=web

kubectl get pods -l app=web --show-labels
```

Discuta como labels ligam Service e Pods.

## Parte 6 — Escalar

```bash
kubectl scale deployment/web --replicas=5
kubectl get pods -l app=web -w
```

Depois reduza:

```bash
kubectl scale deployment/web --replicas=2
```

## Parte 7 — Simular falha de Pod

Escolha um Pod:

```bash
kubectl get pods -l app=web
kubectl delete pod <NOME_DO_POD>
```

Observe:

```bash
kubectl get pods -l app=web -w
```

O ReplicaSet cria um substituto para restaurar o número desejado.

## Parte 8 — Atualizar imagem

Consulte a imagem atual:

```bash
kubectl get deployment web \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

Atualize para uma tag diferente válida em seu ambiente:

```bash
kubectl set image deployment/web nginx=nginx:1.28-alpine
kubectl rollout status deployment/web
kubectl rollout history deployment/web
```

## Parte 9 — Rollback

```bash
kubectl rollout undo deployment/web
kubectl rollout status deployment/web
```

## Parte 10 — Logs e exec

```bash
POD=$(kubectl get pod -l app=web -o jsonpath='{.items[0].metadata.name}')
kubectl logs "$POD"
kubectl exec -it "$POD" -- sh
```

Saia com `exit`.

## Parte 11 — Job

```bash
kubectl apply -f job.yaml
kubectl get jobs
kubectl get pods -l job-name=processamento
kubectl logs job/processamento
```

## Parte 12 — DaemonSet

```bash
kubectl apply -f daemonset.yaml
kubectl get daemonset
kubectl get pods -l app=agente-node -o wide
```

Deve existir uma réplica por Node elegível.

## Parte 13 — StatefulSet

```bash
kubectl apply -f headless-service.yaml
kubectl apply -f statefulset.yaml
kubectl get statefulset
kubectl get pods -l app=exemplo-stateful
kubectl get pvc
```

Os Pods devem ter nomes ordenados, como `exemplo-stateful-0` e `exemplo-stateful-1`.

> O manifesto depende de uma StorageClass padrão. Se os PVCs permanecerem Pending, verifique `kubectl get storageclass`.

## Parte 14 — Diagnóstico

```bash
kubectl describe deployment web
kubectl describe pod "$POD"
kubectl get events --sort-by=.lastTimestamp
```

Experimente consultar recursos:

```bash
kubectl top pods
```

Esse comando depende de Metrics Server.

## Parte 15 — Limpeza

```bash
kubectl delete namespace estudo-containers
```

Se você alterou o namespace padrão do contexto:

```bash
kubectl config set-context --current --namespace=default
```

## Perguntas finais

1. O que criou o novo Pod após a exclusão manual?
2. Qual é a relação entre Deployment e ReplicaSet?
3. Como readiness afeta EndpointSlices?
4. Qual é a diferença entre Job e Deployment?
5. Por que StatefulSet usa Service headless?
6. O que acontece com um DaemonSet quando um novo Node entra no cluster?
