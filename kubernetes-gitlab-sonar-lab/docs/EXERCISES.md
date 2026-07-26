# Exercícios práticos

## 1. Autorrecuperação

1. Execute `kubectl get pods -n dev -w`.
2. Exclua um pod do backend.
3. Observe o ReplicaSet criar outro automaticamente.

## 2. Escala horizontal

1. Altere `backend.replicaCount` para 4 no chart.
2. Faça commit e merge.
3. Observe o pipeline atualizar a quantidade de pods.

## 3. Falha no Quality Gate

1. Configure uma condição de cobertura no SonarQube.
2. Remova ou desabilite testes.
3. Faça merge em uma branch de laboratório.
4. Confirme que os jobs de build/deploy não iniciam.

Lembrete: na Community Build a análise deste lab ocorre na branch principal.
Faça o teste apenas em um projeto descartável.

## 4. Rollback

1. Faça dois merges que alterem a mensagem.
2. Consulte `helm history microplatform -n dev`.
3. Execute `helm rollback microplatform <REVISAO> -n dev --wait`.
4. Verifique a versão em `/api/info`.

## 5. Falha de worker

1. Liste os containers Kind com `docker ps`.
2. Pare um worker: `docker stop microplatform-dev-worker`.
3. Observe os pods afetados.
4. Inicie novamente o worker e acompanhe a recuperação.

## 6. Atualização sem disponibilidade

1. Mantenha `make watch` em execução.
2. Faça um merge que altere o backend.
3. Em outro terminal, execute repetidamente:

```bash
while true; do curl -fsS http://localhost:8081/api/info; echo; sleep 1; done
```

4. Confirme que as requisições continuam durante o rolling update.

## 7. ConfigMap

Crie um valor de saudação em ConfigMap e injete-o como variável de ambiente no
backend. Depois altere o chart para que uma mudança no ConfigMap provoque novo
rollout.

## 8. GitOps

Como evolução, substitua o deploy direto por Flux ou Argo CD. O pipeline deixa
de executar `helm upgrade` e passa a atualizar um repositório de manifests. O
controlador GitOps dentro do cluster realiza a reconciliação.
