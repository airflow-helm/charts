[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# How to persist airflow logs?

By default, logs are stored under `/opt/airflow/logs` within an [`emptyDir`](https://kubernetes.io/docs/concepts/storage/volumes/#emptydir) type Volume, 
this means they only last as long as a respective Pod resides on the same Node.

We recommend you chose one of the following options to ensure that historical airflow task logs remain accessible in your Web UI.

## Option 1 - Persistent Volume Claim

You can use a [`persistentVolumeClaim`](https://kubernetes.io/docs/concepts/storage/volumes/#persistentvolumeclaim) type Volume to store your logs in a durable way.

> 🟦 __Tip__ 🟦
>
> You will need a [StorageClass](https://kubernetes.io/docs/concepts/storage/storage-classes/) that supports the `ReadWriteMany` 
> access mode already set up in your Kubernetes cluster.
>
> Kubernetes is currently [migrating from "Volume Plugins" to "CSI Drivers"](https://kubernetes.io/blog/2021/12/10/storage-in-tree-to-csi-migration-status-update/),
> refer to one of the following tables to check if your StorageClass has support for `ReadWriteMany`:
> 
> 1. If you are using an in-tree "Volume Plugin", refer to [this table](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes).
> 2. If you are using a "CSI Driver", refer to [this table](https://kubernetes-csi.github.io/docs/drivers.html)

### Chart Managed Volume

The chart can manage creation of the PersistentVolumeClaim Volume for your logs.

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
    
    ## NOTE: as multiple pods will write logs, this must be ReadWriteMany
    accessMode: ReadWriteMany
```

> 🟦 __Tip__ 🟦
>
> The name of the chart-managed PersistentVolumeClaim will be your `helm install` release name with `"-logs"` appended.
> 
> For example, if you use `helm install my-airflow airflow-stable/airflow ...`, the PVC will be called: `my-airflow-logs`

### User Managed Volume

If you wish to take more control of the PersistentVolumeClaim Volume used for your logs, you may create a 
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

    ## NOTE: this is name of your existing volume
    existingClaim: my-logs-pvc
    
    ## NOTE: as multiple pods will write logs, this must be ReadWriteMany
    accessMode: ReadWriteMany
```

## Option 2 - Remote Providers

Many community-managed [Airflow Providers](https://airflow.apache.org/docs/apache-airflow-providers/) expose different ways 
to [write logs to durable storage](https://airflow.apache.org/docs/apache-airflow-providers/core-extensions/logging.html),
the following examples show how to set up some of the most common ones with this chart.

This is not a comprehensive list of remote logging provider options, 
consult [the official catalog](https://airflow.apache.org/docs/apache-airflow-providers/core-extensions/logging.html) to see the full list.

> 🟦 __Tip__ 🟦
>
> Airflow logs are sent to the remote provider _on task completion_ (including failure).
> 
> This means two important things:
> 
> 1. Logs for _currently running tasks_ will not be present in the remote provider.
> 2. When a worker crashes, the logs of tasks that worker was running will be lost. (Unless some kind of file-system persistence is also enabled)

> 🟥 __Warning__ 🟥
>
> The following examples assume you are using Airflow 2.0+, please consult the [Airflow 1.10.15 "Writing Logs" docs](https://airflow.apache.org/docs/apache-airflow/1.10.15/howto/write-logs.html)
> for more information about remote logging on Airflow 1.10+.
>
> Specifically, take note that some configs were renamed in Airflow 2.0+:
> 
> - `AIRFLOW__CORE__REMOTE_LOGGING` → `AIRFLOW__LOGGING__REMOTE_LOGGING`
> - `AIRFLOW__CORE__REMOTE_BASE_LOG_FOLDER` → `AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER`
> - `AIRFLOW__CORE__REMOTE_LOG_CONN_ID` → `AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID`

### S3 Bucket

The `apache-airflow-providers-amazon` provider supports [remote logging into S3 buckets](https://airflow.apache.org/docs/apache-airflow-providers-amazon/stable/logging/s3-task-handler.html).

For example, to use an S3 bucket called `<<MY_BUCKET_NAME>>` under the object key prefix `airflow/logs` 
with AWS access provided by an Airflow Connection called `my_aws`:

```yaml
airflow:
  config:
    AIRFLOW__LOGGING__REMOTE_LOGGING: "True"
    AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER: "s3://<<MY_BUCKET_NAME>>/airflow/logs"
    AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID: "my_aws"
```

You must create an Airflow Connection called `my_aws` for this example to work, 
see our [guide to managing AWS connections with the `airflow.connections` value](../dags/airflow-connections.md#aws-connection).

### Google Cloud Storage

The `apache-airflow-providers-google` provider supports [remote logging into GCS buckets](https://airflow.apache.org/docs/apache-airflow-providers-google/stable/logging/gcs.html).

For example, to use a GCS bucket called `<<MY_BUCKET_NAME>>` under the object key prefix `airflow/logs` 
with GCP access provided by an Airflow Connection called `my_gcp`:

```yaml
airflow:
  config:
    AIRFLOW__LOGGING__REMOTE_LOGGING: "True"
    AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER: "gs://<<MY-BUCKET-NAME>>/airflow/logs"
    AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID: "my_gcp"
```

You must create an Airflow Connection called `my_gcp` for this example to work,
see our [guide to managing GCP connections with the `airflow.connections` value](../dags/airflow-connections.md#gcp-connection).

### Azure Blob Storage

The `apache-airflow-providers-microsoft-azure` provider supports [remote logging into Azure Blob Storage](https://airflow.apache.org/docs/apache-airflow-providers-microsoft-azure/stable/logging/index.html).

For example, to use Azure Blob Storage called `wasb-<<MY_NAME>>` with Azure Blob Storage access provided by an Airflow Connection called `my_wabs`:

```yaml
airflow:
  config:
    AIRFLOW__LOGGING__REMOTE_LOGGING: "True"
    AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER: "wasb-<<MY_NAME>>"
    AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID: "my_wabs"
```

You must create an Airflow Connection called `my_wabs` for this example to work, 
see our [guide to managing Azure Blob Storage connections with the `airflow.connections` value](../dags/airflow-connections.md#azure-blob-storage-connection).