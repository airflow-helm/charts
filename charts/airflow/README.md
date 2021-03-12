# Airflow Helm Chart

> ⚠️ this chart is the continuation of [stable/airflow](https://github.com/helm/charts/tree/master/stable/airflow), see [issue #6](https://github.com/airflow-helm/charts/issues/6) for upgrade guide from the old chart

[Airflow](https://airflow.apache.org/) is a platform to programmatically author, schedule, and monitor workflows.

---

### 1 - Add the Repo:

```sh
helm repo add airflow-stable https://airflow-helm.github.io/charts
helm repo update
```

### 2 - Install the Chart:

Find each `CHART_VERSION` under [GitHub Releases](https://github.com/airflow-helm/charts/releases):

```sh
# Helm 3
helm install \
  [RELEASE_NAME] \
  airflow-stable/airflow \
  --version [CHART_VERSION] \
  --namespace [NAMESPACE] \
  --values ./custom-values.yaml

# Helm 2
helm install \
  airflow-stable/airflow \
  --name [RELEASE_NAME] \
  --version [CHART_VERSION] \
  --namespace [NAMESPACE] \
  --values ./custom-values.yaml
```

### 3 - Run commands in Webserver Pod:

```sh
kubectl exec \
  -it \
  --namespace [NAMESPACE] \
  --container airflow-web \
  Deployment/[RELEASE_NAME]-web \
  /bin/bash

# then run commands like 
airflow create_user ...
```

---

# Documentation

## Upgrade Guides

Old Version | New Version | Upgrade Guide
--- | --- | ---
v7.15.X | v8.0.0 | [link](UPGRADE.md#v715x--v800)
v7.14.X | v7.15.0 | [link](UPGRADE.md#v714x--v7150)
v7.13.X | v7.14.0 | [link](UPGRADE.md#v713x--v7140)
v7.12.X | v7.13.0 | [link](UPGRADE.md#v712x--v7130)
v7.11.X | v7.12.0 | [link](UPGRADE.md#v711x--v7120)
v7.10.X | v7.11.0 | [link](UPGRADE.md#v710x--v7110)
v7.9.X | v7.10.0 | [link](UPGRADE.md#v79x--v7100)


## Examples

Description | Example `values.yaml`
--- | ---
A __non-production__ starting point for use with minikube (CeleryExecutor) | [link](examples/minikube/custom-values.yaml)
A __production__ starting point for GKE on Google Cloud (CeleryExecutor) | [link](examples/google-gke/custom-values.yaml)


## Airflow Configs

### How to set Airflow configs?
<details>
<summary>Show More</summary>
<hr>

While we don't expose the `airflow.cfg` directly, you can use [environment variables](https://airflow.apache.org/docs/stable/howto/set-config.html) to set Airflow configs.

We expose the `airflow.config` value to make this easier:
```yaml
airflow:
  config:
    ## security
    AIRFLOW__WEBSERVER__EXPOSE_CONFIG: "False"
    
    ## dags
    AIRFLOW__CORE__LOAD_EXAMPLES: "False"
    AIRFLOW__SCHEDULER__DAG_DIR_LIST_INTERVAL: "30"
    
    ## email
    AIRFLOW__EMAIL__EMAIL_BACKEND: "airflow.utils.email.send_email_smtp"
    AIRFLOW__SMTP__SMTP_HOST: "smtpmail.example.com"
    AIRFLOW__SMTP__SMTP_MAIL_FROM: "admin@example.com"
    AIRFLOW__SMTP__SMTP_PORT: "25"
    AIRFLOW__SMTP__SMTP_SSL: "False"
    AIRFLOW__SMTP__SMTP_STARTTLS: "False"
    
    ## domain used in airflow emails
    AIRFLOW__WEBSERVER__BASE_URL: "http://airflow.example.com"
    
    ## ether environment variables
    HTTP_PROXY: "http://proxy.example.com:8080"
```

</details>

### How to store Airflow DAGs?
<details>
<summary>Show More</summary>
<hr>

<h3>Option 1 - Git-Sidecar (recommended)</h3>

This method places a git sidecar in each worker/scheduler/web Pod, that syncs your git repo into the dag folder every `dags.git.gitSync.refreshTime` seconds.

```yaml
dags:
  git:
    #ssh://git@example.com:22/REPOSITORY.git
    url: git@github.com:USERNAME/REPOSITORY.git
    ref: master
    secret: airflow-git-keys
    privateKeyName: id_rsa
    repoHost: github.com
    repoPort: 22

    gitSync:
      enabled: true
      refreshTime: 60
```

> ⚠️ specifying `known_hosts` inside `dags.git.secret` reduces the possibility of a man-in-the-middle attack, however, if you want to implicitly trust all repo host signatures set `dags.git.sshKeyscan` to `true`

You can create the `dags.git.secret` from your local `$HOME/.ssh` folder using:
```console
kubectl create secret generic \
  airflow-git-keys \
  --from-file=id_rsa=$HOME/.ssh/id_rsa \
  --from-file=id_rsa.pub=$HOME/.ssh/id_rsa.pub \
  --from-file=known_hosts=$HOME/.ssh/known_hosts \
  --namespace airflow
```

<h3>Option 2 - Kubernetes PVC</h3>

This method stores your DAGs in a Kubernetes PersistentVolume, you must configure some external system to ensure this volume has your latest DAGs.
For example, you could use your CI/CD pipeline system to preform a sync as changes are pushed to a git repo.

To share a PVC with multiple Pods, the PVC needs to have `accessMode` set to `ReadOnlyMany` or `ReadWriteMany` (Note: different StorageClass support different [access modes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes)).
If you are using Kubernetes on a public cloud, a persistent volume controller is likely built in: [Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/storage-classes.html), [Azure AKS](https://docs.microsoft.com/en-us/azure/aks/azure-files-dynamic-pv), [Google GKE](https://cloud.google.com/kubernetes-engine/docs/concepts/persistent-volumes)

Example values to use a StorageClass called `default`:
```yaml
dags:
  persistence:
    enabled: true
    storageClass: default
    accessMode: ReadOnlyMany
    size: 1Gi
```

<h3>Option 3 - Container Image</h3>

This method stores your DAGs inside the container image.

This chart uses the official [apache/airflow image](https://hub.docker.com/r/apache/airflow), extend this image and COPY your DAGs into the `dags.path` folder:
```docker
FROM apache/airflow:2.0.1-python3.8

# NOTE: dag path is set with the `dags.path` value
COPY ./my_dag_folder /opt/airflow/dags
```

The following values can be used to specify the container image:
```yaml
airflow:
  image:
    repository: MY_REPO
    tag: MY_TAG
```

</details>

### How to create Airflow Connections?
<details>
<summary>Show More</summary>
<hr>

<h3>Option 1 - Helm Value</h3>

You can create [Airflow Connections](https://airflow.apache.org/docs/stable/concepts.html#connections) using the `scheduler.connections` value.

The Connections will be deleted and re-added each time an airflow-scheduler Pod starts (undoing any changes made in the WebUI), you can disable the delete behaviour by setting `scheduler.refreshConnections=false`.

For example, to add a connection called `my_aws`:
```yaml
scheduler:
  connections:
    - id: my_aws
      type: aws
      extra: |-
        {
          "aws_access_key_id": "XXXXXXXX",
          "aws_secret_access_key": "XXXXXXXX",
          "region_name":"eu-central-1"
        }
```

<h3>Option 2 - Pre-Created Kubernetes Secret</h3>

If you don't want to store connections in your `values.yaml`, use `scheduler.existingSecretConnections` to specify the name of an existing Kubernetes Secret containing an `add-connections.sh` script.
Your script will be run EACH TIME an airflow-scheduler Pod starts, and `scheduler.connections` will not longer work.

Here is an example Secret you might create:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-airflow-connections
type: Opaque
stringData:
  add-connections.sh: |
    #!/usr/bin/env bash

    # remove any existing connection
    airflow connections --delete \
      --conn_id "my_aws"
  
    # re-add your custom connection
    airflow connections --add \
      --conn_id "my_aws" \
      --conn_type "aws" \
      --conn_extra "{\"aws_access_key_id\": \"XXXXXXXX\", \"aws_secret_access_key\": \"XXXXXXXX\", \"region_name\":\"eu-central-1\"}"
```

</details>

### How to create Airflow Variables?
<details>
<summary>Show More</summary>
<hr>

You can create [Airflow Variables](https://airflow.apache.org/docs/stable/concepts.html#variables) using the `scheduler.variables` value.

The Variables will be automatically re-imported each time an airflow-scheduler Pod starts.

For example, to specify a variable called `environment`:
```yaml
scheduler:
  variables:
    environment: "dev"
```

</details>

### How to create Airflow Pools?
<details>
<summary>Show More</summary>
<hr>

You can create [Airflow Pools](https://airflow.apache.org/docs/stable/concepts.html#pools) using the `scheduler.pools` value.

The Pools will be automatically re-imported each time an airflow-scheduler Pod starts.

For example, to create a pool called `example`:
```yaml
scheduler:
  pools: |
    {
      "example": {
        "description": "This is an example pool with 2 slots.",
        "slots": 2
      }
    }
```

</details>

### How to create Airflow Pools?
<details>
<summary>Show More</summary>
<hr>

You can use the `airflow.extraPipPackages` and `web.extraPipPackages` values to install Python Pip packages as each airflow Pod starts. 

These values will work with any pip package that you can install with `pip install XXXX`.

For example, enabling the airflow `airflow-exporter` package:
```yaml
airflow:
  extraPipPackages:
    - "airflow-exporter==1.3.1"
```

For example, you may be using `flask_oauthlib` to integrate with Okta/Google/etc for authorizing WebUI users:
```yaml
web:
  extraPipPackages:
    - "apache-airflow[google_auth]==2.0.1"
```

</details>

### How to set up Airflow Worker autoscaling?
<details>
<summary>Show More</summary>
<hr>

The Airflow Celery Workers can be scaled using the [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/), to enable autoscaling, you must set `workers.autoscaling.enabled=true`, then provide `workers.autoscaling.maxReplicas`.

Assume every task a worker executes consumes approximately `200Mi` memory, that means memory is a good metric for utilisation monitoring.
For a worker pod you can calculate it: `WORKER_CONCURRENCY * 200Mi`, so for `10 tasks` a worker will consume `~2Gi` of memory. 
In the following config if a worker consumes `80%` of `2Gi` (which will happen if it runs 9-10 tasks at the same time), an autoscaling event will be triggered, and a new worker will be added.
If you have many tasks in a queue, Kubernetes will keep adding workers until maxReplicas reached, in this case `16`.
```yaml
workers:
  # the initial/minimum number of workers
  replicas: 2

  resources:
    requests:
      memory: "2Gi"

  podDisruptionBudget:
    enabled: true
    ## prevents losing more than 20% of current worker task slots in a voluntary disruption
    maxUnavailable: "20%"

  autoscaling:
    enabled: true
    maxReplicas: 16
    metrics:
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80

  celery:
    instances: 10

    ## wait at most 9min for running tasks to complete before SIGTERM
    ## WARNING: 
    ## - some cloud cluster-autoscaler configs will not respect graceful termination 
    ##   longer than 10min, for example, Google Kubernetes Engine (GKE)
    gracefullTermination: true
    gracefullTerminationPeriod: 540

  ## how many seconds (after the 9min) to wait before SIGKILL
  terminationPeriod: 60

dags:
  git:
    gitSync:
      resources:
        requests:
          ## IMPORTANT! for autoscaling to work
          memory: "64Mi"
```

</details>

### How to persist Airflow logs (recommended)?
<details>
<summary>Show More</summary>
<hr>

> 🛑️️ you should persist logs in a production deployment using one of the following methods
> 
> By default, logs from the airflow-web/scheduler/worker are written within the Docker container's filesystem, therefore any restart of the pod will wipe the logs.

<h3>Option 1 - Kubernetes PVC</h3>

Example using a 1Gb Kubernetes PVC:
```yaml
logs:
  persistence:
    enabled: true
    storageClass: "" ## WARNING: your StorageClass MUST SUPPORT `ReadWriteMany`
    accessMode: ReadWriteMany
    size: 1Gi
```

<h3>Option 2 - Remote Bucket (recommended)</h3>

You must give airflow credentials for it to read/write on the remote bucket, this can be achieved with `AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID`, or by using something like [Workload Identity (GKE)](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity), or [IAM Roles for Service Accounts (EKS)](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html). 

Example, using `AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID` (can be used with AWS too):
```yaml
airflow:
  config:
    AIRFLOW__LOGGING__REMOTE_LOGGING: "True"
    AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER: "gs://<<MY-BUCKET-NAME>>/airflow/logs"
    AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID: "google_cloud_airflow"

scheduler:
  connections:
    - id: google_cloud_airflow
      type: google_cloud_platform
      extra: |-
        {
         "extra__google_cloud_platform__num_retries": "5",
         "extra__google_cloud_platform__keyfile_dict": "{...}"
        }
```
    
Example, using [Workload Identity (GKE)](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity):
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

Example, using [IAM Roles for Service Accounts (EKS)](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html):
```yaml
airflow:
  config:
    AIRFLOW__LOGGING__REMOTE_LOGGING: "True"
    AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER: "s3://<<MY-BUCKET-NAME>>/airflow/logs"
    AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID: "aws_default"

scheduler:
  securityContext:
    fsGroup: 65534

web:
  securityContext:
    fsGroup: 65534

workers:
  securityContext:
    fsGroup: 65534

serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::XXXXXXXXXX:role/<<MY-ROLE-NAME>>"
```

</details>

## Database Configs

### How to set username/password of the embedded Postgres?
<details>
<summary>Show More</summary>
<hr>

> 🛑️️ the embedded Postgres is NOT SUITABLE for production, you should configure one of the external databases

The embedded Postgres database has an insecure username/password by default, you should create secure credentials before using it.

For example, to create the required Kubernetes Secrets:
```sh
# set postgress password
kubectl create secret generic \
  airflow-postgresql \
  --from-literal=postgresql-password=$(openssl rand -base64 13) \
  --namespace airflow

# set redis password
kubectl create secret generic \
  airflow-redis \
  --from-literal=redis-password=$(openssl rand -base64 13) \
  --namespace airflow
```

Example `values.yaml`, to use those secrets:
```yaml
postgresql:
  existingSecret: airflow-postgresql

redis:
  existingSecret: airflow-redis
```

</details>

### How to set up an external database (recommended)?
<details>
<summary>Show More</summary>
<hr>

<h3>Option 1 - Postgres</h3>

Example values for an external Postgres database, with an existing `airflow_cluster1` database:
```yaml
externalDatabase:
  type: postgres
  host: postgres.example.org
  port: 5432
  database: airflow_cluster1
  user: airflow_cluster1
  passwordSecret: "airflow-cluster1-postgres-password"
  passwordSecretKey: "postgresql-password"
```

<h3>Option 2 - MySQL</h3>

> ⚠️ you must set `explicit_defaults_for_timestamp=1` in your MySQL instance, [see here](https://airflow.apache.org/docs/stable/howto/initialize-database.html)

Example values for an external MySQL database, with an existing `airflow_cluster1` database:
```yaml
externalDatabase:
  type: mysql
  host: mysql.example.org
  port: 3306
  database: airflow_cluster1
  user: airflow_cluster1
  passwordSecret: "airflow-cluster1-mysql-password"
  passwordSecretKey: "mysql-password"
```

</details>


## Kubernetes Configs

### How to mount ConfigMaps/Secrets as environment variables (All Pods)?
<details>
<summary>Show More</summary>
<hr>

You can use the `airflow.extraEnv` value to mount extra environment variables with the same syntax as `env` in ContainerSpec.

This method can be used to pass sensitive configs to Airflow.

For example, passing a Fernet key and LDAP password, (the `airflow` and `ldap` Kubernetes Secrets must already exist):
```yaml
airflow:
  extraEnv:
    - name: AIRFLOW__CORE__FERNET_KEY
      valueFrom:
        secretKeyRef:
          name: airflow
          key: fernet-key
    - name: AIRFLOW__LDAP__BIND_PASSWORD
      valueFrom:
        secretKeyRef:
          name: ldap
          key: password
```

</details>

### How to mount ConfigMaps as files (All Pods)?
<details>
<summary>Show More</summary>
<hr>

You can use the `airflow.extraConfigmapMounts` value to mount the keys of a ConfigMap as files.

For example, a `webserver_config.py` file:
```yaml
airflow:
  extraConfigmapMounts:
    - name: my-webserver-config
      mountPath: /opt/airflow/webserver_config.py
      configMap: my-airflow-webserver-config
      readOnly: true
      subPath: webserver_config.py
```

To create the `my-airflow-webserver-config` ConfigMap, you could use:
```console
kubectl create configmap \
  my-airflow-webserver-config \
  --from-file=webserver_config.py \
  --namespace airflow
```

</details>

### How to mount Secrets as files (Worker Pods)?
<details>
<summary>Show More</summary>
<hr>

You can use the `workers.secrets` value to mount secrets at `{workers.secretsDir}/<secret-name>` in airflow-worker Pods.

For example, mounting password Secrets:
```yaml
workers:
  secretsDir: /var/airflow/secrets
  secrets:
    - redshift-user
    - redshift-password
    - elasticsearch-user
    - elasticsearch-password
```

With the above configuration, you could read the `redshift-user` password from within a DAG or Python function using:
```python
import os
from pathlib import Path

def get_secret(secret_name):
    secrets_dir = Path('/var/airflow/secrets')
    secret_path = secrets_dir / secret_name
    assert secret_path.exists(), f'could not find {secret_name} at {secret_path}'
    secret_data = secret_path.read_text().strip()
    return secret_data

redshift_user = get_secret('redshift-user')
```

To create the `redshift-user` Secret, you could use:
```console
kubectl create secret generic \
  redshift-user \
  --from-literal=redshift-user=MY_REDSHIFT_USERNAME \
  --namespace airflow
```

</details>

### How to set up an Ingress?
<details>
<summary>Show More</summary>
<hr>

The chart provides an optional Kubernetes Ingress resource, for accessing airflow-webserver and airflow-flower outside of the cluster.

If you already have something hosted at the root of your domain, you might want to place airflow under a URL-prefix:
- http://example.com/airflow/
- http://example.com/airflow/flower

In this example, would set these values:
```yaml
airflow:
  config: 
    AIRFLOW__WEBSERVER__BASE_URL: "http://example.com/airflow/"

flower:
  urlPrefix: "/airflow/flower"

ingress:
  web:
    path: "/airflow"

  flower:
    path: "/airflow/flower"
```

We expose the `ingress.web.precedingPaths` and `ingress.web.succeedingPaths` values, which are __before__ and __after__ the default path respectively.

A common use-case is enabling https with the `aws-alb-ingress-controller` [ssl-redirect](https://kubernetes-sigs.github.io/aws-alb-ingress-controller/guide/tasks/ssl_redirect/), which needs a redirect path to be hit before the airflow-webserver one.

You would set the values of `precedingPaths` as the following:
```yaml
ingress:
  web:
    precedingPaths:
      - path: "/*"
        serviceName: "ssl-redirect"
        servicePort: "use-annotation"
```

</details>

### How to set up Prometheus with Airflow?
<details>
<summary>Show More</summary>
<hr>

To be able to expose Airflow metrics to Prometheus you will need install a plugin, one option is [epoch8/airflow-exporter](https://github.com/epoch8/airflow-exporter) which exports DAG and task metrics from Airflow.

A [ServiceMonitor](https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/api.md#servicemonitor) is a resource introduced by the [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator), ror more information, see the `serviceMonitor` section of `values.yaml`.

</details>

### How to add extra Kubernetes manifests?
<details>
<summary>Show More</summary>
<hr>

You can use the `extraManifests.[]` value to add custom Kubernetes manifests to the chart.

For example, adding a `BackendConfig` resource for GKE:
```yaml
extraManifests:
  - apiVersion: cloud.google.com/v1beta1
    kind: BackendConfig
    metadata:
      name: "{{ .Release.Name }}-test"
    spec:
      securityPolicy:
        name: "gcp-cloud-armor-policy-test"
```

</details>


## Chart Values

### Global:
<details>
<summary>Show More</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`airflow.image.*` | the container image for the web/scheduler/worker/flower containers | `<see values.yaml>`
`airflow.executor` | the airflow executor type to use | `CeleryExecutor`
`airflow.fernetKey` | the fernet key used to encrypt the connections/variables in the database | `7T512UXSSmBOkpWimFHIVb8jK6lfmSAvx4mO6Arehnc=`
`airflow.config` | environment variables for airflow configs | `{}`
`airflow.podAnnotations` | extra annotations for the web/scheduler/worker/flower Pods | `{}`
`airflow.extraEnv` | extra environment variables for the web/scheduler/worker/flower Pods | `[]`
`airflow.extraConfigmapMounts` | extra configMap volumeMounts for the web/scheduler/worker/flower Pods | `[]`
`airflow.extraContainers` | extra containers for the web/scheduler/worker Pods | `[]`
`airflow.extraPipPackages` | extra pip packages to install in the web/scheduler/worker Pods | `[]`
`airflow.extraVolumeMounts` | extra volumeMounts for the web/scheduler/worker Pods | `[]`
`airflow.extraVolumes` | extra volumes for the web/scheduler/worker Pods | `[]`
`airflow.podTemplateFile.*` | configs to generate AIRFLOW__KUBERNETES__POD_TEMPLATE_FILE | `<see values.yaml>`

</details>

### Airflow Scheduler:
<details>
<summary>Show More</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`scheduler.resources` | resource requests/limits for the scheduler Pods | `{}`
`scheduler.replicas` | the number of scheduler Pods to run | `1`
`scheduler.nodeSelector` | the nodeSelector configs for the scheduler Pods | `{}`
`scheduler.affinity` | the affinity configs for the scheduler Pods | `{}`
`scheduler.tolerations` | the toleration configs for the scheduler Pods | `[]`
`scheduler.securityContext` | the security context for the scheduler Pods | `{}`
`scheduler.labels` | labels for the scheduler Deployment | `{}`
`scheduler.podLabels` | Pod labels for the scheduler Deployment | `{}`
`scheduler.annotations` | annotations for the scheduler Deployment | `{}`
`scheduler.podAnnotations` | Pod Annotations for the scheduler Deployment | `{}`
`scheduler.safeToEvict` | if we add the annotation: "cluster-autoscaler.kubernetes.io/safe-to-evict" = "true" | `true`
`scheduler.podDisruptionBudget.*` | configs for the PodDisruptionBudget of the scheduler | `<see values.yaml>`
`scheduler.connections` | custom airflow connections for the airflow scheduler | `[]`
`scheduler.refreshConnections` | if `scheduler.connections` are deleted and re-added after each scheduler restart | `true`
`scheduler.existingSecretConnections` | the name of an existing Secret containing an `add-connections.sh` script to run on scheduler start | `""`
`scheduler.variables` | custom variables for the airflow scheduler | `"{}"`
`scheduler.pools` | custom pools for the airflow scheduler | `"{}"`
`scheduler.numRuns` | the value of the `airflow --num_runs` parameter used to run the airflow scheduler | `-1`
`scheduler.dbUpgrade` | if an `airflow db upgrade` init-container is created in the scheduler Pod | `true`
`scheduler.livenessProbe.*` | configs for the scheduler liveness probe | `<see values.yaml>`
`scheduler.secretsDir` | the directory in which to mount secrets on scheduler containers | `/var/airflow/secrets`
`scheduler.secrets` | the names of existing Kubernetes Secrets to mount as files at `{workers.secretsDir}/<secret_name>/<keys_in_secret>` | `[]`
`scheduler.secretsMap` | the name of an existing Kubernetes Secret to mount as files to `{web.secretsDir}/<keys_in_secret>` | `""`
`scheduler.extraInitContainers` | extra init containers to run before the scheduler pod | `[]`

</details>

### Airflow Webserver:
<details>
<summary>Show More</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`web.resources` | resource requests/limits for the airflow web pods | `{}`
`web.replicas` | the number of web Pods to run | `1`
`web.nodeSelector` | the number of web Pods to run | `{}`
`web.affinity` | the affinity configs for the web Pods | `{}`
`web.tolerations` | the toleration configs for the web Pods | `[]`
`web.securityContext` | the security context for the web Pods | `{}`
`web.labels` | labels for the web Deployment | `{}`
`web.podLabels` | Pod labels for the web Deployment | `{}`
`web.annotations` | annotations for the web Deployment | `{}`
`web.podAnnotations` | Pod annotations for the web Deployment | `{}`
`web.safeToEvict` | if we add the annotation: "cluster-autoscaler.kubernetes.io/safe-to-evict" = "true" | `true`
`web.podDisruptionBudget.*` | configs for the PodDisruptionBudget of the web Deployment | `<see values.yaml>`
`web.service.*` | configs for the Service of the web pods | `<see values.yaml>`
`web.serializeDAGs` | sets `AIRFLOW__CORE__STORE_SERIALIZED_DAGS` | `false`
`web.extraPipPackages` | extra pip packages to install in the web container | `[]`
`web.readinessProbe.*` | configs for the web Service readiness probe | `<see values.yaml>`
`web.livenessProbe.*` | configs for the web Service liveness probe | `<see values.yaml>`
`web.secretsDir` | the directory in which to mount secrets on web containers | `/var/airflow/secrets`
`web.secrets` | the names of existing Kubernetes Secrets to mount as files at `{workers.secretsDir}/<secret_name>/<keys_in_secret>` | `[]`
`web.secretsMap` | the name of an existing Kubernetes Secret to mount as files to `{web.secretsDir}/<keys_in_secret>` | `""`
`web.webserverConfigFile.*` | configs to generate webserver_config.py | `<see values.yaml>`

</details>

### Airflow Worker:
<details>
<summary>Show More</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`workers.enabled` | if the airflow workers StatefulSet should be deployed | `true`
`workers.resources` | resource requests/limits for the airflow worker Pods | `{}`
`workers.replicas` | the number of workers Pods to run | `1`
`workers.nodeSelector` | the nodeSelector configs for the worker Pods | `{}`
`workers.affinity` | the affinity configs for the worker Pods | `{}`
`workers.tolerations` | the toleration configs for the worker Pods | `[]`
`workers.securityContext` | the security context for the worker Pods | `{}`
`workers.labels` | labels for the worker StatefulSet | `{}`
`workers.podLabels` | Pod labels for the worker StatefulSet | `{}`
`workers.annotations` | annotations for the worker StatefulSet | `{}`
`workers.podAnnotations` | Pod annotations for the worker StatefulSet | `{}`
`workers.safeToEvict` | if we add the annotation: "cluster-autoscaler.kubernetes.io/safe-to-evict" = "true" | `true`
`workers.podDisruptionBudget.*` | configs for the PodDisruptionBudget of the worker StatefulSet | `<see values.yaml>`
`workers.autoscaling.*` | configs for the HorizontalPodAutoscaler of the worker Pods | `<see values.yaml>`
`workers.celery.*` | configs for the celery worker Pods | `<see values.yaml>`
`workers.terminationPeriod` | how many seconds to wait after SIGTERM before SIGKILL of the celery worker | `60`
`workers.secretsDir` | directory in which to mount secrets on worker containers | `/var/airflow/secrets`
`workers.secrets` | the names of existing Kubernetes Secrets to mount as files at `{workers.secretsDir}/<secret_name>/<keys_in_secret>` | `[]`
`workers.secretsMap` | the name of an existing Kubernetes Secret to mount as files to `{web.secretsDir}/<keys_in_secret>` | `""`
  
</details>

### Airflow Flower:
<details>
<summary>Show More</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`flower.enabled` | if the Flower UI should be deployed | `true`
`flower.resources` | resource requests/limits for the flower Pods | `{}`
`flower.affinity` | the affinity configs for the flower Pods | `{}`
`flower.tolerations` | the toleration configs for the flower Pods | `[]`
`flower.securityContext` | the security context for the flower Pods | `{}`
`flower.labels` | labels for the flower Deployment | `{}`
`flower.podLabels` | Pod labels for the flower Deployment | `{}`
`flower.annotations` | annotations for the flower Deployment | `{}`
`flower.podAnnotations` | Pod annotations for the flower Deployment | `{}`
`flower.safeToEvict` | if we add the annotation: "cluster-autoscaler.kubernetes.io/safe-to-evict" = "true" | `true`
`flower.podDisruptionBudget.*` | configs for the PodDisruptionBudget of the flower Deployment | `<see values.yaml>`
`flower.oauthDomains` | the value of the flower `--auth` argument | `""`
`flower.basicAuthSecret` | the name of a pre-created secret containing the basic authentication value for flower | `""`
`flower.basicAuthSecretKey` | the key within `flower.basicAuthSecret` containing the basic authentication string | `""`
`flower.urlPrefix` | sets `AIRFLOW__CELERY__FLOWER_URL_PREFIX` | `""`
`flower.service.*` | configs for the Service of the flower Pods | `<see values.yaml>`
`flower.extraConfigmapMounts` | extra ConfigMaps to mount on the flower Pods | `[]`

</details>

### Logs:
<details>
<summary>Show More</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`logs.path` | the airflow logs folder | `/opt/airflow/logs`
`logs.persistence.*` | configs for the logs PVC | `<see values.yaml>`

</details>

### DAGs:
<details>
<summary>Show More</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`dags.path` | the airflow dags folder | `/opt/airflow/dags`
`dags.installRequirements` | install any Python `requirements.txt` at the root of `dags.path` automatically | `false`
`dags.persistence.*` | configs for the dags PVC | `<see values.yaml>`
`dags.git.*` | configs for the DAG git repository & sync container | `<see values.yaml>`
`dags.initContainer.*` | configs for the git-clone init-container | `<see values.yaml>`

</details>

### Kubernetes (Ingress):
<details>
<summary>Show More</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`ingress.enabled` | if we should deploy Ingress resources | `false`
`ingress.web.*` | configs for the Ingress of the web Service | `<see values.yaml>`
`ingress.flower.*` | configs for the Ingress of the flower Service | `<see values.yaml>`

</details>

### Kubernetes (Other):
<details>
<summary>Show More</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`rbac.create` | if Kubernetes RBAC resources are created | `true`
`rbac.events` | if the created RBAR role has GET/LIST access to Event resources | `false`
`serviceAccount.create` | if a Kubernetes ServiceAccount is created | `true`
`serviceAccount.name` | the name of the ServiceAccount | `""`
`serviceAccount.annotations` | annotations for the ServiceAccount | `{}`
`extraManifests` | extra Kubernetes manifests to include alongside this chart | `[]`

</details>

### Database (Embedded - Postgres):
<details>
<summary>Show More</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`postgresql.enabled` | if the `stable/postgresql` chart is used | `true`
`postgresql.postgresqlDatabase` | the postgres database to use | `airflow`
`postgresql.postgresqlUsername` | the postgres user to create | `postgres`
`postgresql.postgresqlPassword` | the postgres user's password | `airflow`
`postgresql.existingSecret` | the name of a pre-created secret containing the postgres password | `""`
`postgresql.existingSecretKey` | the key within `postgresql.passwordSecret` containing the password string | `postgresql-password`
`postgresql.persistence.*` | configs for the PVC of postgresql | `<see values.yaml>`
`postgresql.master.*` | configs for the postgres StatefulSet | `<see values.yaml>`

</details>

### Database (External - Postgres/MySQL):
<details>
<summary>Show More</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`externalDatabase.type` | the type of external database: {mysql,postgres} | `postgres`
`externalDatabase.host` | the host of the external database | `localhost`
`externalDatabase.port` | the port of the external database | `5432`
`externalDatabase.database` | the database/scheme to use within the the external database | `airflow`
`externalDatabase.user` | the user of the external database | `airflow`
`externalDatabase.passwordSecret` | the name of a pre-created secret containing the external database password | `""`
`externalDatabase.passwordSecretKey` | the key within `externalDatabase.passwordSecret` containing the password string | `postgresql-password`
`externalDatabase.properties` | the connection properties e.g. "?sslmode=require" | `""`

</details>

### Redis (Embedded):
<details>
<summary>Show More</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`redis.enabled` | if the `stable/redis` chart is used | `true`
`redis.password` | the redis password | `airflow`
`redis.existingSecret` | the name of a pre-created secret containing the redis password | `""`
`redis.existingSecretPasswordKey` | the key within `redis.existingSecret` containing the password string | `redis-password`
`redis.cluster.*` | configs for redis cluster mode | `<see values.yaml>`
`redis.master.*` | configs for the redis master | `<see values.yaml>`
`redis.slave.*` | configs for the redis slaves | `<see values.yaml>`

</details>

### Redis (External):
<details>
<summary>Show More</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`externalRedis.host` | the host of the external redis | `localhost`
`externalRedis.port` | the port of the external redis | `6379`
`externalRedis.databaseNumber` | the database number to use within the the external redis | `1`
`externalRedis.passwordSecret` | the name of a pre-created secret containing the external redis password | `""`
`externalRedis.passwordSecretKey` | the key within `externalRedis.passwordSecret` containing the password string | `redis-password`

</details>

### Prometheus:
<details>
<summary>Show More</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`serviceMonitor.enabled` | if ServiceMonitor resources should be deployed | `false`
`serviceMonitor.selector` | labels for ServiceMonitor, so that Prometheus can select it | `{ prometheus: "kube-prometheus" }`
`serviceMonitor.path` | the ServiceMonitor web endpoint path | `/admin/metrics`
`serviceMonitor.interval` | the ServiceMonitor web endpoint path | `30s`
`prometheusRule.enabled` | if the PrometheusRule resources should be deployed | `false`
`prometheusRule.additionalLabels` | labels for PrometheusRule, so that Prometheus can select it | `{}`
`prometheusRule.groups` | alerting rules for Prometheus | `[]`

</details>

<br>
<br>