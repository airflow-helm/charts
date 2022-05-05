[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# How to load DAG definitions?

To use your airflow cluster, you will need to make your DAG definitions (python files) available to airflow.
While there are many ways you can achieve this, we natively support the following methods.

## Option 1 - Git-Sync Sidecar 

With this method, you store your DAGs in a git repo and configure sidecars on the airflow Pods which automatically keep a local cache of this repo in sync.

> 🟦 __Tip__ 🟦
>
> The git repo content is stored under a `repo/` sub folder of `dag.path`, 
> so by default you will find your repo under `/opt/airflow/dags/repo`.

### SSH git auth

You may configure your git-sync sidecars to access the repo through SSH.

For example to sync from `git@github.com:USERNAME/REPOSITORY.git` using the RSA keys stored in `Secret/airflow-ssh-git-secret`:

```yaml
airflow:
  config:
    ## NOTE: set by `dags.gitSync.syncWait`, unless you override it
    #AIRFLOW__SCHEDULER__DAG_DIR_LIST_INTERVAL: 60

dags:
  ## NOTE: this is the default value
  path: /opt/airflow/dags
  
  gitSync:
    enabled: true
    
    ## NOTE: some git providers will need an `ssh://` prefix
    repo: "git@github.com:USERNAME/REPOSITORY.git"
    branch: "master"
    revision: "HEAD"
    
    ## the sub-path within your repo where dags are located
    ## NOTE: airflow will only see dags under this path, but the whole repo will still be synced
    #repoSubPath: "path/to/dags"
    
    ## number of seconds to wait between syncs
    ## NOTE: also sets `AIRFLOW__SCHEDULER__DAG_DIR_LIST_INTERVAL` unless overwritten in `airflow.config`
    syncWait: 60
    
    ## the max number of seconds allowed for a complete sync
    ## NOTE: if your repo takes a very long time to sync, you may need to increase this value
    #syncTimeout: 120
    
    ## the number of consecutive failures allowed before aborting
    ## NOTE: if your repo regularly has intermittent failures, you may wish to set a non-0 value
    #maxFailures: 0
    
    sshSecret: "airflow-ssh-git-secret"
    sshSecretKey: "id_rsa"
    
    ## NOTE: "known_hosts" verification can be disabled by setting to "" 
    sshKnownHosts: |-
      github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
```

> 🟦 __Tip__ 🟦
>
> If you have the SSH private key at `$HOME/.ssh/id_rsa`, 
> you may create `Secret/airflow-ssh-git-secret` using this command:
> 
> ```shell
> kubectl create secret generic \
>   airflow-ssh-git-secret \
>   --from-file=id_rsa=$HOME/.ssh/id_rsa \
>   --namespace my-airflow-namespace
> ```

### HTTP git auth

You may configure your git-sync sidecars to access the repo through HTTP.

For example, to sync from `https://github.com/USERNAME/REPOSITORY.git` using the HTTP credentials stored in `Secret/airflow-http-git-secret`:

```yaml
airflow:
  config:
    ## NOTE: set by `dags.gitSync.syncWait`, unless you override it
    #AIRFLOW__SCHEDULER__DAG_DIR_LIST_INTERVAL: 60

dags:
  ## NOTE: this is the default value
  path: /opt/airflow/dags
  
  gitSync:
    enabled: true
    
    repo: "https://github.com/USERNAME/REPOSITORY.git"
    branch: "master"
    revision: "HEAD"
    
    ## the sub-path within your repo where dags are located
    ## NOTE: airflow will only see dags under this path, but the whole repo will still be synced
    #repoSubPath: "path/to/dags"
    
    ## number of seconds to wait between syncs
    ## NOTE: also sets `AIRFLOW__SCHEDULER__DAG_DIR_LIST_INTERVAL` unless overwritten in `airflow.config`
    syncWait: 60
    
    ## the max number of seconds allowed for a complete sync
    ## NOTE: if your repo takes a very long time to sync, you may need to increase this value
    #syncTimeout: 120
    
    ## the number of consecutive failures allowed before aborting
    ## NOTE: if your repo regularly has intermittent failures, you may wish to set a non-0 value
    #maxFailures: 0
    
    httpSecret: "airflow-http-git-secret"
    httpSecretUsernameKey: username
    httpSecretPasswordKey: password
```

> 🟦 __Tip__ 🟦
>
> You may create `Secret/airflow-http-git-secret` using this command, 
> replacing `MY_GIT_USERNAME` and `MY_GIT_TOKEN` with your HTTP credentials:
> 
> ```shell
> kubectl create secret generic \
>   airflow-http-git-secret \
>   --from-literal=username='MY_GIT_USERNAME' \
>   --from-literal=password='MY_GIT_TOKEN' \
>   --namespace my-airflow-namespace
> ```

## Option 2 - Persistent Volume Claim

With this method, you use a [`persistentVolumeClaim`](https://kubernetes.io/docs/concepts/storage/volumes/#persistentvolumeclaim) type Volume to share DAG files between the airflow Pods.

> 🟦 __Tip__ 🟦
>
> You must configure some external system to populate the volume with your latest DAGs.
> For example, you may use your CI/CD pipeline system to preform a sync as changes are pushed to your DAGs git repo.

### Chart Managed Volume

The chart can manage creation of the PersistentVolumeClaim for your DAGs.

For example, to have the chart create a PersistentVolumeClaim with the `storageClass` called `default` and a `size` of `1Gi`:

```yaml
dags:
  ## NOTE: this is the default value
  path: /opt/airflow/dags
  
  persistence:
    enabled: true
    
    ## NOTE: set `storageClass` to "" for the cluster-default
    storageClass: "default" 
    
    ## NOTE: some types of StorageClass will ignore this request (for example, EFS)
    size: 1Gi
    
    ## NOTE: as multiple Pods read the DAGs concurrently this must be ReadOnlyMany or ReadWriteMany
    accessMode: ReadOnlyMany
```

> 🟦 __Tip__ 🟦
>
> The name of the chart-managed PersistentVolumeClaim will be your `helm install` release name with `"-dags"` appended.
> 
> For example, if you use `helm install my-airflow airflow-stable/airflow ...`, the PVC will be called: `my-airflow-dags`

### User Managed Volume

If you wish to take more control of the PersistentVolumeClaim used for your DAGs, you may create a 
[`PersistentVolumeClaim`](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims) 
resource inside your helm install namespace and then tell the chart to use it.

For example, to have the chart use an existing PersistentVolumeClaim called `my-dags-pvc`:

```yaml
dags:
  ## NOTE: this is the default value
  path: /opt/airflow/dags
  
  persistence:
    enabled: true
    
    ## NOTE: this is name of your existing volume
    existingClaim: my-dags-pvc
    
    ## NOTE: as multiple Pods read the DAGs concurrently this must be ReadOnlyMany or ReadWriteMany
    accessMode: ReadOnlyMany
```

## Option 3 - Embedded Into Container Image

With this method, you store your DAGs inside your container image.
This chart uses the official [apache/airflow](https://hub.docker.com/r/apache/airflow) images, you may extend them to include your DAG definition files.

For example, here is a Dockerfile, which extends `apache/airflow:2.2.5-python3.8` by placing DAG files into `/opt/airflow/dags`:

```dockerfile
FROM apache/airflow:2.2.5-python3.8

## copy the content of local folder `./my_dag_folder` into container folder `/opt/airflow/dags`
COPY ./my_dag_folder /opt/airflow/dags
```

The following values tell the chart to use the `MY_REPO:MY_TAG` container image:

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