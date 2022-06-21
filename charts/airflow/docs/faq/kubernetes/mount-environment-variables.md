[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Mount Environment Variables from Secrets/ConfigMaps

You may use the `airflow.extraEnv` value to mount extra environment variables with the same structure as [EnvVar in ContainerSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#envvar-v1-core).

> 🟦 __Tip__ 🟦
>
> This method can be used to pass sensitive [airflow configs](../configuration/airflow-configs.md).

For example, to use the `value` key from the existing Secret `airflow-fernet-key` to define `AIRFLOW__CORE__FERNET_KEY`:

```yaml
airflow:
  extraEnv:
    - name: AIRFLOW__CORE__FERNET_KEY
      valueFrom:
        secretKeyRef:
          name: airflow-fernet-key
          key: value
```