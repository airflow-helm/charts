[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# How to mount ConfigMaps and Secrets as files?

## Mount on CeleryExecutor Workers

You may use the `workers.extraVolumeMounts` and `workers.extraVolumes` values to mount ConfigMaps/Secrets as files on the airflow CeleryExecutor worker pods.

For example, to mount a Secret called `redshift-creds` at the `/opt/airflow/secrets/redshift-creds` directory of all CeleryExecutor worker pods:

```yaml
workers:
  extraVolumeMounts:
    - name: redshift-creds
      mountPath: /opt/airflow/secrets/redshift-creds
      readOnly: true

  extraVolumes:
    - name: redshift-creds
      secret:
        secretName: redshift-creds
```

> 🟦 __Tip__ 🟦
>
> You may create the `redshift-creds` Secret with `kubectl`.
> 
> ```shell
> kubectl create secret generic \
>   redshift-creds \
>   --from-literal=user=MY_REDSHIFT_USERNAME \
>   --from-literal=password=MY_REDSHIFT_PASSWORD \
>   --namespace my-airflow-namespace
> ```

> 🟦 __Tip__ 🟦
>
> You may read the `/opt/airflow/secrets/redshift-creds` files from within an airflow [PythonOperator](https://airflow.apache.org/docs/apache-airflow/stable/howto/operator/python.html).
> 
> ```python
> from pathlib import Path
> redis_user = Path("/opt/airflow/secrets/redshift-creds/user").read_text().strip()
> redis_password = Path("/opt/airflow/secrets/redshift-creds/password").read_text().strip()
> ```

## Mount on KubernetesExecutor Pod Template

You may use the `airflow.kubernetesPodTemplate.extraVolumeMounts` and `airflow.kubernetesPodTemplate.extraVolumes` values to mount ConfigMaps/Secrets as files on the airflow KubernetesExecutor pod template.

For example, to mount a Secret called `redshift-creds` at the `/opt/airflow/secrets/redshift-creds` directory of all KubernetesExecutor pod templates:

```yaml
airflow:
  kubernetesPodTemplate:
    extraVolumeMounts:
      - name: redshift-creds
        mountPath: /opt/airflow/secrets/redshift-creds
        readOnly: true
  
    extraVolumes:
      - name: redshift-creds
        secret:
          secretName: redshift-creds
```