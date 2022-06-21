[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Configure Redis (Built-In)

> 🟦 __Tip__ 🟦
>
> You may consider using an [external redis](external-redis.md) rather than the embedded one.

## Set a Custom Password

The embedded Redis has an insecure password of `airflow` by default which is set by the `redis.password` value.
To improve security, you should generate a custom password and store it in a Kubernetes secret using `redis.existingSecret`.

For example, to use a pre-created Secret called `airflow-redis` that contains a key called `redis-password`:

```yaml
redis:
  existingSecret: airflow-redis
  existingSecretKey: redis-password
```

> 🟦 __Tip__ 🟦
>
> You may use `kubectl` to create the `airflow-redis` Secret with a random `redis-password` key.
>
> ```shell
> kubectl create secret generic \
>   airflow-redis \
>   --from-literal=redis-password=$(openssl rand -base64 13) \
>   --namespace my-airflow-namespace
> ```