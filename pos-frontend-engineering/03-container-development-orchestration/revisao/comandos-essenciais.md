# Comandos essenciais

## Docker — informações

```bash
docker version
docker info
docker system df
```

## Docker — containers

```bash
docker run --name app -d imagem
docker run --rm -it imagem sh
docker ps
docker ps -a
docker start app
docker stop app
docker restart app
docker rm app
docker rm -f app
docker logs app
docker logs -f --tail 100 app
docker inspect app
docker exec -it app sh
docker stats app
docker port app
```

## Docker — portas e recursos

```bash
docker run -p 8080:80 nginx
docker run -p 127.0.0.1:8080:80 nginx
docker run --memory=512m --cpus=0.5 imagem
docker update --memory=1g --cpus=1 app
docker update --restart unless-stopped app
```

## Docker — imagens

```bash
docker image ls
docker pull nginx:stable-alpine
docker build -t usuario/app:1.0.0 .
docker image inspect usuario/app:1.0.0
docker tag app:1.0.0 usuario/app:1.0.0
docker push usuario/app:1.0.0
docker image rm usuario/app:1.0.0
docker history usuario/app:1.0.0
```

## Docker — volumes

```bash
docker volume create dados
docker volume ls
docker volume inspect dados
docker volume rm dados
docker volume prune

docker run --mount source=dados,target=/dados imagem
docker run --mount source=dados,target=/dados,readonly imagem
docker run --mount type=bind,source="$PWD",target=/app imagem
```

## Docker — redes

```bash
docker network ls
docker network create app-net
docker network inspect app-net
docker network connect app-net app
docker network disconnect app-net app
docker network rm app-net

docker run --network app-net --name api imagem
```

## Docker — limpeza

```bash
docker container prune
docker image prune
docker volume prune
docker network prune
docker system prune
```

> Revise o que será removido antes dos comandos `prune`.

## Docker Compose

```bash
docker compose config
docker compose pull
docker compose build
docker compose up
docker compose up -d
docker compose up -d --build
docker compose ps
docker compose logs
docker compose logs -f app
docker compose exec app sh
docker compose restart app
docker compose stop
docker compose start
docker compose down
docker compose down --volumes
docker compose up -d --scale worker=3
```

## Docker Scout

```bash
docker scout version
docker scout quickview imagem
docker scout cves imagem
docker scout sbom imagem
```

## Docker Swarm

```bash
docker swarm init --advertise-addr <IP>
docker swarm join-token worker
docker swarm join --token <TOKEN> <IP>:2377
docker node ls
docker node inspect <NODE>
docker node update --availability drain <NODE>

docker service create --name web --replicas 3 -p 8080:80 nginx
docker service ls
docker service ps web
docker service logs -f web
docker service inspect --pretty web
docker service scale web=5
docker service update --replicas 5 web
docker service update --image nginx:stable-alpine web
docker service rollback web
docker service rm web

docker stack deploy -c stack.yaml app
docker stack ls
docker stack services app
docker stack ps app
docker stack rm app

docker swarm leave
docker swarm leave --force
```

## Kubernetes — contexto e cluster

```bash
kubectl cluster-info
kubectl get nodes
kubectl config get-contexts
kubectl config current-context
kubectl config use-context <CONTEXTO>
kubectl config set-context --current --namespace=<NAMESPACE>
```

## Kubernetes — recursos

```bash
kubectl api-resources
kubectl explain deployment
kubectl explain deployment.spec.template.spec.containers
kubectl apply -f arquivo.yaml
kubectl delete -f arquivo.yaml
kubectl get all
kubectl get all -A
kubectl get pods -o wide
kubectl get pods --show-labels
kubectl describe pod <POD>
```

## Kubernetes — logs e execução

```bash
kubectl logs <POD>
kubectl logs -f <POD>
kubectl logs <POD> -c <CONTAINER>
kubectl logs <POD> --previous
kubectl exec -it <POD> -- sh
kubectl exec -it <POD> -c <CONTAINER> -- sh
kubectl port-forward pod/<POD> 8080:80
kubectl port-forward service/<SERVICE> 8080:80
```

## Kubernetes — Deployments

```bash
kubectl get deployments
kubectl get replicasets
kubectl scale deployment/web --replicas=5
kubectl set image deployment/web web=imagem:2.0.0
kubectl rollout status deployment/web
kubectl rollout history deployment/web
kubectl rollout pause deployment/web
kubectl rollout resume deployment/web
kubectl rollout undo deployment/web
kubectl rollout undo deployment/web --to-revision=2
```

## Kubernetes — Services e rede

```bash
kubectl get services
kubectl describe service <SERVICE>
kubectl get endpointslices
kubectl get endpointslices -l kubernetes.io/service-name=<SERVICE>
kubectl get ingress
kubectl get networkpolicies
```

## Kubernetes — eventos e recursos

```bash
kubectl get events --sort-by=.lastTimestamp
kubectl top nodes
kubectl top pods
kubectl get resourcequota
kubectl get limitrange
kubectl get pvc
kubectl get storageclass
```

## Kubernetes — diagnóstico rápido

```bash
kubectl get pod <POD> -o yaml
kubectl describe pod <POD>
kubectl logs <POD> --previous
kubectl get events --field-selector involvedObject.name=<POD>
kubectl auth can-i create deployments
kubectl auth can-i '*' '*' --all-namespaces
```
