[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# How to load DAG definitions?

## Option 1 - git-sync sidecar 

### SSH git auth

This method uses an SSH git-sync sidecar to sync your git repo into the dag folder every `dags.gitSync.syncWait` seconds.

Example values defining an SSH git repo:

```yaml
airflow:
  config:
    ## NOTE: this is set to `dags.gitSync.syncWait` by default
    #AIRFLOW__SCHEDULER__DAG_DIR_LIST_INTERVAL: 60

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
    
    ## NOTE: "known_hosts" verification can be disabled by setting to "" 
    sshKnownHosts: |-
      github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
```

> 🟦 __Tip__ 🟦
>
> You may create the `airflow-ssh-git-secret` Secret using:
> 
> ```shell
> kubectl create secret generic \
>   airflow-ssh-git-secret \
>   --from-file=id_rsa=$HOME/.ssh/id_rsa \
>   --namespace my-airflow-namespace
> ```

### HTTP git auth

This method uses an HTTP git sidecar to sync your git repo into the dag folder every `dags.gitSync.syncWait` seconds.

Example values defining an HTTP git repo:

```yaml
airflow:
  config:
    ## NOTE: this is set to `dags.gitSync.syncWait` by default
    #AIRFLOW__SCHEDULER__DAG_DIR_LIST_INTERVAL: 60

dags:
  ## NOTE: this is the default value
  #path: /opt/airflow/dags
  
  gitSync:
    enabled: true
    repo: "https://github.com/USERNAME/REPOSITORY.git"
    branch: "master"
    revision: "HEAD"
    syncWait: 60
    httpSecret: "airflow-http-git-secret"
    httpSecretUsernameKey: username
    httpSecretPasswordKey: password
```

> 🟦 __Tip__ 🟦
>
> You may create `airflow-http-git-secret` Secret using:
> 
> ```shell
> kubectl create secret generic \
>   airflow-http-git-secret \
>   --from-literal=username=MY_GIT_USERNAME \
>   --from-literal=password=MY_GIT_TOKEN \
>   --namespace my-airflow-namespace
> ```

## Option 2 - persistent volume

With this method, you store your DAGs in a Kubernetes PersistentVolume, which is mounted to all scheduler/web/worker Pods.

> 🟦 __Tip__ 🟦
>
> You must configure some external system to ensure the persistent volume has your latest DAGs.
> 
> For example, you could use your CI/CD pipeline system to preform a sync as changes are pushed to your DAGs git repo.

### Chart Managed Volume

For example, to have the chart create a PVC with the `storageClass` called `default` and an initial `size` of `1Gi`:

```yaml
dags:
  ## NOTE: this is the default value
  #path: /opt/airflow/dags
  
  persistence:
    enabled: true
    
    ## configs for the chart-managed volume
    storageClass: "default" # NOTE: "" means cluster-default
    size: 1Gi
    
    accessMode: ReadOnlyMany
```

> 🟦 __Tip__ 🟦
>
> The name of the chart-managed volume will be `{{ .Release.Name | trunc 63 | trimSuffix "-" | trunc 58 }}-dags`.

### User Managed Volume

For example, to use an existing PVC called `my-dags-pvc`:

```yaml
dags:
  ## NOTE: this is the default value
  #path: /opt/airflow/dags
  
  persistence:
    enabled: true
    
    ## the name of your existing volume
    existingClaim: my-dags-pvc
    
    accessMode: ReadOnlyMany
```

> 🟦 __Tip__ 🟦
>
> Your `dags.persistence.existingClaim` PVC must support `ReadOnlyMany` or `ReadWriteMany` for `accessMode`

## Option 3 - embedded into container image

This chart uses the official [apache/airflow](https://hub.docker.com/r/apache/airflow) images, you may extend the airflow container image with your DAG definition files.

Example extending `airflow:2.0.1-python3.8` with some dags:

```dockerfile
FROM apache/airflow:2.0.1-python3.8

# NOTE: dag path is set with the `dags.path` value
COPY ./my_dag_folder /opt/airflow/dags
```

Example values to use `MY_REPO:MY_TAG` container image with the chart:

```yaml
airflow:
  image:
    repository: MY_REPO
    tag: MY_TAG

    ## WARNING: even if set to "Always" do not reuse tag names, as containers only pull the latest image when restarting
    pullPolicy: IfNotPresent
```

> 🟥 __Warning__ 🟥
>
> Ensure that you never reuse an image tag name.
> This ensures that whenever you update `airflow.image.tag`, all airflow pods will restart with the latest DAGs.
>
> For example, you may append a version or git hash corresponding to your DAGs:
>
> 1. `MY_REPO:MY_TAG-v1`, `MY_REPO:MY_TAG-v2`, `MY_REPO:MY_TAG-v3`
> 2. `MY_REPO:MY_TAG-0.1.0`, `MY_REPO:MY_TAG-0.1.1`, `MY_REPO:MY_TAG-0.1.3`
> 3. `MY_REPO:MY_TAG-a1a1a1a`, `MY_REPO:MY_TAG-a2a2a3a`, `MY_REPO:MY_TAG-a3a3a3a`