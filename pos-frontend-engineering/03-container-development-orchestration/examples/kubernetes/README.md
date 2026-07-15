# Exemplos Kubernetes

Aplique o namespace e a aplicação web:

```bash
kubectl apply -f namespace.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get all -n estudo-containers
```

Teste com port-forward:

```bash
kubectl port-forward -n estudo-containers service/web 8080:80
```

Acesse `http://localhost:8080`.

Acompanhe o rollout:

```bash
kubectl rollout status -n estudo-containers deployment/web
kubectl get pods -n estudo-containers -w
```

Remova o laboratório:

```bash
kubectl delete namespace estudo-containers
```

> Alguns manifests, como o StatefulSet, dependem de uma StorageClass padrão. NetworkPolicy depende de suporte do plugin CNI.
