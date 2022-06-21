[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Mount Extra Persistent Volumes

## Mount on CeleryExecutor Workers

You may use the `workers.extraVolumeMounts` and `workers.extraVolumes` values to mount persistent volumes on the airflow CeleryExecutor worker pods.

For example, to mount a Volume called `worker-tmp` at the `/tmp` directory of all CeleryExecutor worker pods:

```yaml
workers:
  extraVolumeMounts:
    - name: worker-tmp
      mountPath: /tmp
      readOnly: false

  extraVolumes:
    - name: worker-tmp
      persistentVolumeClaim:
        claimName: worker-tmp
```

## Mount on KubernetesExecutor Pod Template

You may use the `airflow.kubernetesPodTemplate.extraVolumeMounts` and `airflow.kubernetesPodTemplate.extraVolumes` values to mount persistent volumes on the airflow KubernetesExecutor pod template.

For example, to mount a Volume called `worker-tmp` at the `/tmp` directory of all KubernetesExecutor pod templates:

```yaml
airflow:
  kubernetesPodTemplate:
    extraVolumeMounts:
      - name: worker-tmp
        mountPath: /tmp
        readOnly: false
  
    extraVolumes:
      - name: worker-tmp
        persistentVolumeClaim:
          claimName: worker-tmp
```