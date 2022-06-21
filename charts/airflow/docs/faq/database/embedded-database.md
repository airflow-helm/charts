[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Configure Database (Built-In)

> 🟥 __Warning__ 🟥
>
> The embedded database is NOT SUITABLE for production, we strongly recommend using an [external database](external-database.md) instead!

## Set a Custom Password

The embedded PostgreSQL database has an insecure password of `airflow` by default which is set by the `postgresql.postgresqlPassword` value.
To improve database security, you should generate a custom password and store it in a Kubernetes secret using `postgresql.existingSecret`.

For example, to use a pre-created Secret called `airflow-postgresql` that contains a key called `postgresql-password`:

```yaml
postgresql:
  existingSecret: airflow-postgresql
  existingSecretKey: postgresql-password
```

> 🟦 __Tip__ 🟦
>
> You may use `kubectl` to create the `airflow-postgresql` Secret with a random `postgresql-password` key.
>
> ```shell
> kubectl create secret generic \
>   airflow-postgresql \
>   --from-literal=postgresql-password=$(openssl rand -base64 13) \
>   --namespace my-airflow-namespace
> ```