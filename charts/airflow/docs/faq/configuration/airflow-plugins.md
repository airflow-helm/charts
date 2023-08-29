[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Manage Airflow Plugins

There are multiple ways to load [Airflow Plugins](https://airflow.apache.org/docs/apache-airflow/stable/plugins.html) when using the chart.

## Option 1 - Embedded Into Container Image

You may embed your [Airflow Plugins](https://airflow.apache.org/docs/apache-airflow/stable/plugins.html) directly into the container image.

> 🟩 __Suggestion__ 🟩
> 
> This is the __suggested method__ for installing Airflow Plugins.

<details>
<summary>
  <b>Example</b>
</summary>

---

This chart uses the official [`apache/airflow`](https://hub.docker.com/r/apache/airflow) Docker images.

Here is a Dockerfile that extends `apache/airflow:2.6.3-python3.9` with custom plugins:

```dockerfile
FROM apache/airflow:2.6.3-python3.9

# plugin files can be copied under `/home/airflow/plugins`
# (where `./plugins` is relative to the docker build context)
COPY plugins/* /home/airflow/plugins/

# plugins exposed as python packages can be installed with pip
RUN pip install --no-cache-dir \
    example==1.0.0
```

You might then build and tag this Dockerfile as `MY_REPO:MY_TAG`.

The following values tell the chart to use the `MY_REPO:MY_TAG` container image:

```yaml
airflow:
  image:
    repository: MY_REPO
    tag: MY_TAG

    ## WARNING: even if set to "Always" DO NOT reuse tag names, 
    ##          containers only pull the latest image when restarting
    pullPolicy: IfNotPresent
```

</details>

## Option 2 - Git-Sync DAGs Repo

If you are using git-sync to [load your DAG definitions](../dags/load-dag-definitions.md), you may also include your 
[Airflow Plugins](https://airflow.apache.org/docs/apache-airflow/stable/plugins.html) in this repo.

<details>
<summary>
  <b>Example</b>
</summary>

---

> 🟥 __Warning__ 🟥
>
> With this option, you must MANUALLY restart the Webserver for plugin changes to take effect.

For example, if your DAG git repo includes plugins under `./PATH/TO/PLUGINS`:

```yaml
airflow:
  configs:
    ## NOTE: there is an extra `/repo/` in the path
    AIRFLOW__CORE__PLUGINS_FOLDER: /opt/airflow/dags/repo/PATH/TO/PLUGINS

dags:
  ## NOTE: this is the default value
  #path: /opt/airflow/dags

  gitSync:
    enabled: true
    repo: "https://github.com/USERNAME/REPOSITORY.git"
    branch: "master"
```

</details>

## Option 3 - Persistent Volume 

You may load [Airflow Plugins](https://airflow.apache.org/docs/apache-airflow/stable/plugins.html) 
that are stored in a Kubernetes [Persistent Volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) 
by using the `workers.extraVolumeMounts` and `workers.extraVolumes` values.

<details>
<summary>
  <b>Example</b>
</summary>

---

> 🟥 __Warning__ 🟥
>
> With this option, you must MANUALLY restart the Webserver for plugin changes to take effect.

For example, to mount a PersistentVolumeClaim called `airflow-plugins` that contains airflow plugin files at its root:

```yaml
airflow:
  configs:
    ## NOTE: this is the default value
    #AIRFLOW__CORE__PLUGINS_FOLDER: /opt/airflow/plugins

workers:
  extraVolumeMounts:
    - name: airflow-plugins
      mountPath: /opt/airflow/plugins
      readOnly: true
      
      ## NOTE: if plugin files are not at the root of the volume, you may set a subPath
      #subPath: "path/to/plugins"

  extraVolumes:
    - name: airflow-plugins
      persistentVolumeClaim:
        claimName: airflow-plugins
```

</details>

## Option 4 - ConfigMaps or Secrets

You may load [Airflow Plugins](https://airflow.apache.org/docs/apache-airflow/stable/plugins.html) 
that are stored in Secrets or ConfigMaps by using the `workers.extraVolumeMounts` and `workers.extraVolumes` values.

<details>
<summary>
  <b>Example</b>
</summary>

---

> 🟥 __Warning__ 🟥
>
> With this option, you must MANUALLY restart the Webserver for plugin changes to take effect.

For example, to mount airflow plugin files from a ConfigMap called `airflow-plugins`:

```yaml
airflow:
  configs:
    ## NOTE: this is the default value
    #AIRFLOW__CORE__PLUGINS_FOLDER: /opt/airflow/plugins

workers:  
  extraVolumeMounts:
    - name: airflow-plugins
      mountPath: /opt/airflow/plugins
      readOnly: true

  extraVolumes:
    - name: airflow-plugins
      configMap:
        name: airflow-plugins
```

Your `airflow-plugins` ConfigMap might look something like this. 

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: airflow-plugins
data:
  my_airflow_plugin.py: |
    from airflow.plugins_manager import AirflowPlugin

    class MyAirflowPlugin(AirflowPlugin):
      name = "my_airflow_plugin"
      ...
```

> 🟦 __Tip__ 🟦
>
> You may include the ConfigMap using the [`extraManifests`](../kubernetes/extra-manifests.md) value:
> 
> ```yaml
> extraManifests:
>   - |
>     apiVersion: v1
>     kind: ConfigMap
>     metadata:
>       name: airflow-plugins
>       labels:
>         app: {{ include "airflow.labels.app" . }}
>         chart: {{ include "airflow.labels.chart" . }}
>         release: {{ .Release.Name }}
>         heritage: {{ .Release.Service }}
>     data:
>       my_airflow_plugin.py: |
>         from airflow.plugins_manager import AirflowPlugin
>         
>         class MyAirflowPlugin(AirflowPlugin):
>           name = "my_airflow_plugin"
>           ...
> ```

</details>
