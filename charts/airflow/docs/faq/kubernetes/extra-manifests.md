[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Include Extra Kubernetes Manifests

You may use the `extraManifests` value to specify a list of extra Kubernetes manifests that will be deployed alongside the chart.

> 🟦 __Tip__ 🟦
>
> [Helm templates](https://helm.sh/docs/chart_template_guide/functions_and_pipelines/) within these strings will be rendered

Example values to create a `Secret` for database credentials: _(__WARNING:__ store custom values securely if used)_

```yaml
extraManifests:
  - |
    apiVersion: v1
    kind: Secret
    metadata:
      name: airflow-postgres-credentials
    data:
      postgresql-password: {{ `password1` | b64enc | quote }}
```

Example values to create a `Deployment` for a [busybox](https://busybox.net/) container:

```yaml
extraManifests:
  - |
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: {{ include "airflow.fullname" . }}-busybox
      labels:
        app: {{ include "airflow.labels.app" . }}
        component: busybox
        chart: {{ include "airflow.labels.chart" . }}
        release: {{ .Release.Name }}
        heritage: {{ .Release.Service }}
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: {{ include "airflow.labels.app" . }}
          component: busybox
          release: {{ .Release.Name }}
      template:
        metadata:
          labels:
            app: {{ include "airflow.labels.app" . }}
            component: busybox
            release: {{ .Release.Name }}
        spec:
          containers:
            - name: busybox
              image: busybox:1.35
              command:
                - "/bin/sh"
                - "-c"
              args:
                - |
                  ## to break the infinite loop when we receive SIGTERM
                  trap "exit 0" SIGTERM;
                  ## keep the container running (so people can `kubectl exec -it` into it)
                  while true; do
                    echo "I am alive...";
                    sleep 30;
                  done
```