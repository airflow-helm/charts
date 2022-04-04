[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# How to persist airflow logs?

> 🟥 __Warning__ 🟥
>
> For production, you should persist logs in a production deployment using one of these methods.
> By default, logs are stored within the container's filesystem, therefore any restart of the pod will wipe your DAG logs.

## Option 1 - persistent volume

### Chart Managed Volume

For example, to have the chart create a PVC with the `storageClass` called `default` and an initial `size` of `1Gi`:

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
  #path: /opt/airflow/logs
  
  persistence:
    enabled: true

    ## configs for the chart-managed volume
    storageClass: "default" # NOTE: "" means cluster-default
    size: 1Gi
    accessMode: ReadWriteMany
```

> 🟦 __Tip__ 🟦
>
> The name of the chart-managed volume will be `{{ .Release.Name | trunc 63 | trimSuffix "-" | trunc 58 }}-logs`.

### User Managed Volume

For example, to use an existing PVC called `my-logs-pvc`:

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
  #path: /opt/airflow/logs
  
  persistence:
    enabled: true

    ## the name of your existing volume
    existingClaim: my-logs-pvc
    
    accessMode: ReadWriteMany
```

> 🟦 __Tip__ 🟦
>
> Your `logs.persistence.existingClaim` PVC must support `ReadWriteMany` for `accessMode`.

## Option 2 - remote cloud bucket

### S3 Bucket (recommended on AWS)

For example, to use a remote S3 bucket for logging (with an `airflow.connection` called `my_aws` for authorization):

```yaml
airflow:
  config:
    AIRFLOW__LOGGING__REMOTE_LOGGING: "True"
    AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER: "s3://<<MY-BUCKET-NAME>>/airflow/logs"
    AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID: "my_aws"
    
  connections:
    ## see docs: https://airflow.apache.org/docs/apache-airflow-providers-amazon/stable/connections/aws.html
    - id: my_aws
      type: aws
      description: my AWS connection
      extra: |-
        { "aws_access_key_id": "XXXXXXXX",
          "aws_secret_access_key": "XXXXXXXX",
          "region_name":"eu-central-1" }
```

For example, to use a remote S3 bucket for logging (with [EKS - IAM Roles for Service Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) for authorization):

```yaml
airflow:
  config:
    AIRFLOW__LOGGING__REMOTE_LOGGING: "True"
    AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER: "s3://<<MY-BUCKET-NAME>>/airflow/logs"
    AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID: "aws_default"

serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::XXXXXXXXXX:role/<<MY-ROLE-NAME>>"
```

### GCS Bucket (recommended on GCP)

For example, to use a remote GCS bucket for logging (with an `airflow.connection` called `my_gcp` for authorization):

```yaml
airflow:
  config:
    AIRFLOW__LOGGING__REMOTE_LOGGING: "True"
    AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER: "gs://<<MY-BUCKET-NAME>>/airflow/logs"
    AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID: "my_gcp"
    
  connections:
    ## see docs: https://airflow.apache.org/docs/apache-airflow-providers-google/stable/connections/gcp.html
    - id: my_gcp
      type: google_cloud_platform
      description: my GCP connection
      extra: |-
        { "extra__google_cloud_platform__keyfile_dict": "XXXXXXXX",
          "extra__google_cloud_platform__num_retries": "5" }
```

For example, to use a remote GCS bucket for logging (with [GKE - Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity) for authorization):

```yaml
airflow:
  config:
    AIRFLOW__LOGGING__REMOTE_LOGGING: "True"
    AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER: "gs://<<MY-BUCKET-NAME>>/airflow/logs"
    AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID: "google_cloud_default"

serviceAccount:
  annotations:
    iam.gke.io/gcp-service-account: "<<MY-ROLE-NAME>>@<<MY-PROJECT-NAME>>.iam.gserviceaccount.com"
```