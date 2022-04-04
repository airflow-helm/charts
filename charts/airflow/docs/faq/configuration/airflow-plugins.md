[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# How to load airflow plugins?

There are multiple ways to load [airflow plugins](https://airflow.apache.org/docs/apache-airflow/stable/plugins.html) when using the chart.

## Option 1 - embedded into container image (recommended)

This chart uses the official [apache/airflow](https://hub.docker.com/r/apache/airflow) images, you may extend the airflow container image with your airflow plugins.

For example, here is a Dockerfile that extends `airflow:2.1.4-python3.8` with custom plugins:

```dockerfile
FROM apache/airflow:2.1.4-python3.8

# plugin files can be copied under `/home/airflow/plugins`
# (where `./plugins` is relative to the docker build context)
COPY plugins/* /home/airflow/plugins/

# plugins exposed as python packages can be installed with pip
RUN pip install --no-cache-dir \
    example==1.0.0
```

After building and tagging your Dockerfile as `MY_REPO:MY_TAG`, you may use it with the chart by specifying `airflow.image.*`:

```yaml
airflow:
  image:
    repository: MY_REPO
    tag: MY_TAG

    ## WARNING: even if set to "Always" do not reuse tag names, as containers only pull the latest image when restarting
    pullPolicy: IfNotPresent
```

## Option 2 - git-sync dags repo

> 🟥 __Warning__ 🟥
>
> With "Option 2", you must manually restart the webserver and scheduler pods for plugin changes to take effect.

If you are using git-sync to [load your DAG definitions](../dags/load-dag-definitions.md), you may also include your plugins in this repo.

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
    repo: "git@github.com:USERNAME/REPOSITORY.git"
    branch: "master"
    revision: "HEAD"
    syncWait: 60
    sshSecret: "airflow-ssh-git-secret"
    sshSecretKey: "id_rsa"
  
    # "known_hosts" verification can be disabled by setting to "" 
    sshKnownHosts: |-
      github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
```

## Option 3 - persistent volume 

> 🟥 __Warning__ 🟥
>
> With "Option 3", you must manually restart the webserver and scheduler pods for plugin changes to take effect.

You may load airflow plugins that are stored in a Kubernetes [Persistent Volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) by using the `airflow.extraVolumeMounts` and `airflow.extraVolumes` values.

For example, to mount a PersistentVolumeClaim called `airflow-plugins` that contains airflow plugin files at its root:

```yaml
airflow:
  configs:
    ## NOTE: this is the default value
    #AIRFLOW__CORE__PLUGINS_FOLDER: /opt/airflow/plugins

  extraVolumeMounts:
    - name: airflow-plugins
      mountPath: /opt/airflow/plugins
      ## NOTE: if plugin files are not at the root of the volume, you may set a subPath
      #subPath: "path/to/plugins"
      readOnly: true

  extraVolumes:
    - name: airflow-plugins
      persistentVolumeClaim:
        claimName: airflow-plugins
```

## Option 4 - ConfigMaps or Secrets

> 🟥 __Warning__ 🟥
>
> With "Option 4", you must manually restart the webserver and scheduler pods for plugin changes to take effect.

You may load airflow plugins that are sored in Kubernetes Secrets or ConfigMaps by using the `airflow.extraVolumeMounts` and `airflow.extraVolumes` values.

For example, to mount airflow plugin files from a ConfigMap called `airflow-plugins`:

```yaml
workers:
  configs:
    ## NOTE: this is the default value
    #AIRFLOW__CORE__PLUGINS_FOLDER: /opt/airflow/plugins
  
  extraVolumeMounts:
    - name: airflow-plugins
      mountPath: /opt/airflow/plugins
      readOnly: true

  extraVolumes:
    - name: airflow-plugins
      configMap:
        name: airflow-plugins
```

> 🟦 __Tip__ 🟦
>
> Your `airflow-plugins` ConfigMap might look something like this. 
>
> ```yaml
> apiVersion: v1
> kind: ConfigMap
> metadata:
>   name: airflow-plugins
> data:
>   my_airflow_plugin.py: |
>     from airflow.plugins_manager import AirflowPlugin
> 
>     class MyAirflowPlugin(AirflowPlugin):
>       name = "my_airflow_plugin"
>       ...
> ```

> 🟦 __Tip__ 🟦
>
> You may include the ConfigMap as an [extra manifest](../kubernetes/extra-manifests.md) of the chart using the `extraManifests` value.
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
