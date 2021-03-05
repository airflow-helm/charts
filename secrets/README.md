# Secrets

## Airflow connections

1. Fill out the `add-connections-secrets.templete.yml` and save it into `add-connections-secrets.yml`
2. Create secret:
  * staging: `kubectl apply -f ./add-connections-secrets-staging.yml`
  * prod: `kubectl apply -f ./add-connections-secrets-prod.yml`

## Git

```
kubectl create secret generic \
  airflow-git-keys \
  --from-file=id_rsa=$HOME/.ssh/id_rsa \
  --from-file=id_rsa.pub=$HOME/.ssh/id_rsa.pub \
  --from-file=known_hosts=$HOME/.ssh/known_hosts \
  --namespace airflow
```