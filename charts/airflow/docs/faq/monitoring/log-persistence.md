[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Manage Airflow Logs

By default, logs are stored under `/opt/airflow/logs` within an [`emptyDir`](https://kubernetes.io/docs/concepts/storage/volumes/#emptydir) type Volume, 
this means they only last as long as each airflow Pod resides on the same Node.

We recommend that you chose one of the following options to ensure that past airflow logs remain accessible in your Web UI.

## Option 1 - Persistent Volume Claim

You may use a [`PersistentVolumeClaim`](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) to store your logs in a durable way.

> 🟨 __Note__ 🟨
>
> You will need a [StorageClass](https://kubernetes.io/docs/concepts/storage/storage-classes/) that supports `ReadWriteMany` 
> access mode to be already set up in your cluster:
> 
> - [check here for in-tree "Volume Plugins"](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) 
> - [check here for "CSI Drivers"](https://kubernetes-csi.github.io/docs/drivers.html) 

<details>
<summary>
  <a id="chart-managed-volume"></a>
  <b>Chart Managed Volume</b>
</summary>

---

The chart can manage the initial creation of a PersistentVolumeClaim for your logs.

> 🟦 __Tip__ 🟦
>
> The name of the `PersistentVolumeClaim` will be your helm release-name with `"-logs"` appended.
> <br>
> For example, if you use `helm install my-airflow ...`, the PVC will be called `my-airflow-logs`.

For example, to have the chart create a PersistentVolumeClaim with the `storageClass` called `default` and a `size` of `5Gi`:

```yaml
scheduler:
  logCleanup:
    ## WARNING: scheduler log-cleanup must be disabled if `logs.persistence.enabled` is `true`
    enabled: false

workers:
  logCleanup:
    ## WARNING: workers log-cleanup must be disabled if `logs.persistence.enabled` is `true`
    enabled: false

logs:
  ## NOTE: this is the default value
  path: /opt/airflow/logs
  
  persistence:
    enabled: true

    ## NOTE: set `storageClass` to "" for the cluster-default
    storageClass: "default"
    
    ## NOTE: some types of StorageClass will ignore this request (for example, EFS)
    size: 5Gi
    
    ## WARNING: as multiple pods will write logs, this MUST be ReadWriteMany
    accessMode: ReadWriteMany
```

</details>

<details>
<summary>
  <a id="user-managed-volume"></a>
  <b>User Managed Volume</b>
</summary>

---

If you wish to take more control of the PersistentVolumeClaim used for your logs, you may create a 
[`PersistentVolumeClaim`](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims) 
resource inside your helm install namespace and then tell the chart to use it.

For example, to have the chart use an existing PersistentVolumeClaim called `my-logs-pvc`:

```yaml
scheduler:
  logCleanup:
    ## WARNING: scheduler log-cleanup must be disabled if `logs.persistence.enabled` is `true`
    enabled: false

workers:
  logCleanup:
    ## WARNING: workers log-cleanup must be disabled if `logs.persistence.enabled` is `true`
    enabled: false

logs:
  ## NOTE: this is the default value
  path: /opt/airflow/logs
  
  persistence:
    enabled: true

    ## the name of your existing PersistentVolumeClaim
    existingClaim: my-logs-pvc
    
    ## WARNING: as multiple pods will write logs, this MUST be ReadWriteMany
    accessMode: ReadWriteMany
```

</details>

## Option 2 - Remote Providers

Many of the [Airflow Providers](https://airflow.apache.org/docs/apache-airflow-providers/) expose vendor-specific ways to write logs to durable storage,
consult [the official catalog](https://airflow.apache.org/docs/apache-airflow-providers/core-extensions/logging.html) for a full list of logging extensions in remote providers.

> 🟨 __Note__ 🟨
>
> Remote providers __only receive logs on task completion__ (including failure), this means two important things:
> 
> 1. logs of currently running tasks are not present in the remote provider
> 2. if a worker crashes, the logs of currently running tasks will be lost (unless a file-system persistence is also enabled)

> 🟥 __Warning__ 🟥
>
> These examples require Airflow 2.0+, if using Airflow 1.10, please consult the [Airflow 1.10.15 "Writing Logs" page](https://airflow.apache.org/docs/apache-airflow/1.10.15/howto/write-logs.html).

<details>
<summary>
  <a id="s3-bucket"></a>
  <b>S3 Bucket</b>
</summary>

---

The `apache-airflow-providers-amazon` provider supports [remote logging into S3 buckets](https://airflow.apache.org/docs/apache-airflow-providers-amazon/stable/logging/s3-task-handler.html).

> 🟦 __Tip__ 🟦
>
> An `aws` type airflow connection called `my_aws` must exist for this example,
> see our [guide using `airflow.connections`](../dags/airflow-connections.md#aws-connection) to do this.

For example, to use an S3 bucket called `<<MY_BUCKET_NAME>>` under the object key prefix `airflow/logs` 
with AWS access provided by an Airflow Connection called `my_aws`:

```yaml
airflow:
  config:
    AIRFLOW__LOGGING__REMOTE_LOGGING: "True"
    AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER: "s3://<<MY_BUCKET_NAME>>/airflow/logs"
    AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID: "my_aws"
```

</details>

<details>
<summary>
  <a id="google-cloud-storage"></a>
  <b>Google Cloud Storage</b>
</summary>

---

The `apache-airflow-providers-google` provider supports [remote logging into GCS buckets](https://airflow.apache.org/docs/apache-airflow-providers-google/stable/logging/gcs.html).

> 🟦 __Tip__ 🟦
>
> A `google_cloud_platform` type airflow connection called `my_gcp` must exist for this example,
> see our [guide using `airflow.connections`](../dags/airflow-connections.md#gcp-connection) to do this.

For example, to use a GCS bucket called `<<MY_BUCKET_NAME>>` under the object key prefix `airflow/logs` 
with GCP access provided by an Airflow Connection called `my_gcp`:

```yaml
airflow:
  config:
    AIRFLOW__LOGGING__REMOTE_LOGGING: "True"
    AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER: "gs://<<MY-BUCKET-NAME>>/airflow/logs"
    AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID: "my_gcp"
```

</details>

<details>
<summary>
  <a id="azure-blob-storage"></a>
  <b>Azure Blob Storage</b>
</summary>

---

The `apache-airflow-providers-microsoft-azure` provider supports [remote logging into Azure Blob Storage](https://airflow.apache.org/docs/apache-airflow-providers-microsoft-azure/stable/logging/index.html).

> 🟦 __Tip__ 🟦
>
> A `wasb` type airflow connection called `my_wasb` must exist for this example,
> see our [guide using `airflow.connections`](../dags/airflow-connections.md#azure-blob-storage-connection) to do this.

For example, to use Azure Blob Storage called `wasb-<<MY_NAME>>` with access provided by an Airflow Connection called `my_wasb`:

```yaml
airflow:
  config:
    AIRFLOW__LOGGING__REMOTE_LOGGING: "True"
    AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER: "wasb-<<MY_NAME>>"
    AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID: "my_wasb"
```

</details>

## Option 3 - Pod Volumes

You may use a [`Pod Volume`](https://kubernetes.io/docs/concepts/storage/volumes/) to store your logs.
Kubernetes has many types of Pod Volumes, consult [the official docs](https://kubernetes.io/docs/concepts/storage/volumes/#volume-types) for the full list.

> 🟥 __Warning__ 🟥
>
> Pod Volumes are an advanced feature, consider other options unless you need the flexibility of this approach.

> 🟦 __Tip__ 🟦
>
> It is possible to store both __logs__ AND __DAGs__ on the same Pod Volume by setting `dags.path` and `logs.path` to be a sub folder 
> under a `mountPath` from `airflow.extraVolumeMounts`. _(WARNING: the volume type must support writing)_

<details>
<summary>
  <a id="persistentVolumeClaim-volume"></a>
  <b><code>persistentVolumeClaim</code> Volume</b>
</summary>

---

> 🟦 __Tip__ 🟦
>
> The chart has special values just for PersistentVolumeClaims (`logs.persistence.*`), 
> see [`Option 1`](#option-1---persistent-volume-claim) for more information.

For example, to mount a [`persistentVolumeClaim`](https://kubernetes.io/docs/concepts/storage/volumes/#persistentvolumeclaim) type volume at `/opt/airflow/logs`:

```yaml
airflow:
  extraVolumeMounts:
    ## spec: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#volumemount-v1-core
    - name: logs-volume
      mountPath: /opt/airflow/logs

  extraVolumes:
    ## spec: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#volume-v1-core
    - name: logs-volume
      persistentVolumeClaim:
        claimName: my-existing-persistent-volume-claim

scheduler:
  logCleanup:
    ## WARNING: scheduler log-cleanup must be disabled if `logs.path` is under an `airflow.extraVolumeMounts`
    enabled: false

workers:
  logCleanup:
    ## WARNING: workers log-cleanup must be disabled if `logs.path` is under an `airflow.extraVolumeMounts`
    enabled: false

logs:
  ## NOTE: this is the default value
  path: /opt/airflow/logs
```

</details>

<details>
<summary>
  <a id="nfs-volume"></a>
  <b><code>nfs</code> Volume</b>
</summary>

---

For example, to mount an [`nfs`](https://kubernetes.io/docs/concepts/storage/volumes/#nfs) type volume at `/opt/airflow/logs`:

```yaml
airflow:
  extraVolumeMounts:
    ## spec: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#volumemount-v1-core
    - name: logs-volume
      mountPath: /opt/airflow/logs

  extraVolumes:
    ## spec: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#volume-v1-core
    - name: logs-volume
      nfs:
        path: /path/on/nfs/server
        server: nfs.example.com

scheduler:
  logCleanup:
    ## WARNING: scheduler log-cleanup must be disabled if `logs.path` is under an `airflow.extraVolumeMounts`
    enabled: false

workers:
  logCleanup:
    ## WARNING: workers log-cleanup must be disabled if `logs.path` is under an `airflow.extraVolumeMounts`
    enabled: false

logs:
  ## NOTE: this is the default value
  path: /opt/airflow/logs
```

</details>

<details>
<summary>
  <a id="hostPath-volumes"></a>
  <b><code>hostPath</code> Volume</b>
</summary>

---

> 🟥 __Warning__ 🟥
>
> We strongly recommend NOT TO USE `hostPath` type volumes, as they provide access to the filesystem of the underlying node.

For example, to mount a [`hostPath`](https://kubernetes.io/docs/concepts/storage/volumes/#hostpath) type volume at `/opt/airflow/logs`:

```yaml
airflow:
  extraVolumeMounts:
    ## spec: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#volumemount-v1-core
    - name: logs-volume
      mountPath: /opt/airflow/logs

  extraVolumes:
    ## spec: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#volume-v1-core
    - name: logs-volume
      hostPath:
        ## WARNING: this represents a local path on the Kubernetes Node
        path: /tmp/airflow
        type: DirectoryOrCreate

scheduler:
  logCleanup:
    ## WARNING: scheduler log-cleanup must be disabled if `logs.path` is under an `airflow.extraVolumeMounts`
    enabled: false

workers:
  logCleanup:
    ## WARNING: workers log-cleanup must be disabled if `logs.path` is under an `airflow.extraVolumeMounts`
    enabled: false

logs:
  ## NOTE: this is the default value
  path: /opt/airflow/logs
```

</details>