[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Mount Files from Secrets/ConfigMaps

## Mount on ALL Airflow Pods

You may use the `airflow.extraVolumeMounts` and `airflow.extraVolumes` values to mount ConfigMaps/Secrets as files on all airflow pods.

For example, to mount a Secret called `redshift-creds` at the `/opt/airflow/secrets/redshift-creds` directory of all airflow pods:

```yaml
airflow:
  extraVolumeMounts:
    ## spec for VolumeMount: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#volumemount-v1-core
    - name: redshift-creds
      mountPath: /opt/airflow/secrets/redshift-creds
      readOnly: true

  extraVolumes:
    ## spec for Volume: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#volume-v1-core
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

## Mount on CeleryExecutor Workers

You may use the `workers.extraVolumeMounts` and `workers.extraVolumes` values to mount ConfigMaps/Secrets as files on the airflow CeleryExecutor worker pods.

For example, to mount a Secret called `redshift-creds` at the `/opt/airflow/secrets/redshift-creds` directory of all CeleryExecutor worker pods:

```yaml
workers:
  extraVolumeMounts:
    ## spec for VolumeMount: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#volumemount-v1-core
    - name: redshift-creds
      mountPath: /opt/airflow/secrets/redshift-creds
      readOnly: true
  
  extraVolumes:
    ## spec for Volume: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#volume-v1-core
    - name: redshift-creds
      secret:
        secretName: redshift-creds
```

## Mount on KubernetesExecutor Pod Template

You may use the `airflow.kubernetesPodTemplate.extraVolumeMounts` and `airflow.kubernetesPodTemplate.extraVolumes` values to mount ConfigMaps/Secrets as files on the airflow KubernetesExecutor pod template.

For example, to mount a Secret called `redshift-creds` at the `/opt/airflow/secrets/redshift-creds` directory of all KubernetesExecutor pod templates:

```yaml
airflow:
  kubernetesPodTemplate:
    ## spec for VolumeMount: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#volumemount-v1-core
    extraVolumeMounts:
      - name: redshift-creds
        mountPath: /opt/airflow/secrets/redshift-creds
        readOnly: true
  
    ## spec for Volume: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#volume-v1-core
    extraVolumes:
      - name: redshift-creds
        secret:
          secretName: redshift-creds
```