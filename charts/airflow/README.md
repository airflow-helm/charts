> ⚠️ NOTE: this is the community-maintained descendant of the [stable/airflow](https://github.com/helm/charts/tree/master/stable/airflow) helm chart

# Airflow Helm Chart  [![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/airflow-helm)](https://artifacthub.io/packages/search?repo=airflow-helm)

[Apache Airflow](https://airflow.apache.org/) is a platform to programmatically author, schedule, and monitor workflows.

---

### 1 - Add the Repo to Helm

```sh
helm repo add airflow-stable https://airflow-helm.github.io/charts
helm repo update
```

### 2 - Install the Chart

```sh
export RELEASE_NAME=my-airflow-cluster # a name
export NAMESPACE=my-airflow-namespace # a namespace
export CHART_VERSION=8.X.X # a chart version - https://github.com/airflow-helm/charts/releases
export VALUES_FILE=./custom-values.yaml # your values file

# with Helm 3
helm install \
  $RELEASE_NAME \
  airflow-stable/airflow \
  --namespace $NAMESPACE \
  --version $CHART_VERSION \
  --values $VALUES_FILE
```

### 3 - Expose the WebUI (with port-forward)

```sh
export NAMESPACE=my-airflow-namespace # set a namespace!

export POD_NAME=$(kubectl get pods --namespace $NAMESPACE -l "component=web,app=airflow" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward --namespace $NAMESPACE $POD_NAME 8080:8080
```

### 5 - Browse to the WebUI

- http://localhost:8080 
- user: __admin__ / password: __admin__

### 6 - Review important docs

- [How to use a specific version of airflow?](#how-to-use-a-specific-version-of-airflow)
- [How to set airflow configs?](#how-to-set-airflow-configs)
- [How to create airflow users?](#how-to-create-airflow-users) // [How to authenticate airflow users with LDAP/OAUTH?](#how-to-authenticate-airflow-users-with-ldapoauth)
- [How to use an external database?](#how-to-use-an-external-database-recommended)
- [How to persist Airflow logs?](#how-to-persist-airflow-logs-recommended)
- [How to setup an Ingres?](#how-to-set-up-an-ingress)

# Documentation

## Upgrade Guides

Old Version | New Version | Upgrade Guide
--- | --- | ---
v8.2.X | v8.3.0 | [link](UPGRADE.md#v82x--v830)
v8.1.X | v8.2.0 | [link](UPGRADE.md#v81x--v820)
v8.0.X | v8.1.0 | [link](UPGRADE.md#v80x--v810)
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

### How to use a specific version of airflow?
<details>
<summary>Show More</summary>
<hr>

There will always be a single default version of airflow shipped with this chart, see `airflow.image.*` in [values.yaml](values.yaml) for the current one.

However, given the general nature of the chart, it is likely that other versions of airflow will work too.

For example, using airflow `2.0.1`, with python `3.6`:
```yaml
airflow:
  image:
    repository: apache/airflow
    tag: 2.0.1-python3.6
```

For example, using airflow `1.10.15`, with python `3.8`:
```yaml
airflow:
  # this must be "true" for airflow 1.10
  legacyCommands: true
  
  image:
    repository: apache/airflow
    tag: 1.10.15-python3.8
```

<hr>
</details>

### How to set airflow configs?
<details>
<summary>Show More</summary>
<hr>

While we don't expose the "airflow.cfg" file directly, you can use [environment variables](https://airflow.apache.org/docs/stable/howto/set-config.html) to set Airflow configs.

The `airflow.config` value makes this easier, each key-value is mounted as an environment variable on each scheduler/web/worker/flower Pod:
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

<hr>
</details>

### How to store DAGs?
<details>
<summary>Show More</summary>
<hr>

<h3>Option 1a - SSH git-sync sidecar (recommended)</h3>

This method uses an SSH git-sync sidecar to sync your git repo into the dag folder every `dags.gitSync.syncWait` seconds.

For example:
```yaml
airflow:
  config:
    AIRFLOW__SCHEDULER__DAG_DIR_LIST_INTERVAL: 60

dags:
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

You can create the `airflow-ssh-git-secret` Secret using:
```console
kubectl create secret generic \
  airflow-ssh-git-secret \
  --from-file=id_rsa=$HOME/.ssh/id_rsa \
  --namespace my-airflow-namespace
```

<h3>Option 1b - HTTP git-sync sidecar</h3>

This method uses an HTTP git sidecar to sync your git repo into the dag folder every `dags.gitSync.syncWait` seconds.

For example:
```yaml
airflow:
  config:
    AIRFLOW__SCHEDULER__DAG_DIR_LIST_INTERVAL: 60

dags:
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

You can create `airflow-http-git-secret` Secret using:
```console
kubectl create secret generic \
  airflow-http-git-secret \
  --from-literal=username=MY_GIT_USERNAME \
  --from-literal=password=MY_GIT_TOKEN \
  --namespace my-airflow-namespace
```

<h3>Option 2 - shared volume</h3>

With this method, you store your DAGs in a Kubernetes PersistentVolume, which is mounted to all scheduler/web/worker Pods.

You must configure some external system to ensure this volume has your latest DAGs, for example, you could use your CI/CD pipeline system to preform a sync as changes are pushed to your DAGs git repo.

> ⚠️ the PVC needs to have `accessMode` = `ReadOnlyMany` (or `ReadWriteMany`) 
> 
> Different StorageClasses support different [access-modes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes).
> For Kubernetes on public cloud, a persistent volume controller is likely built in, so check the available access-modes: [Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/storage-classes.html), [Azure AKS](https://docs.microsoft.com/en-us/azure/aks/azure-files-dynamic-pv), [Google GKE](https://cloud.google.com/kubernetes-engine/docs/concepts/persistent-volumes)

Example values to use a StorageClass called `default`:
```yaml
dags:
  persistence:
    enabled: true
    storageClass: default
    accessMode: ReadOnlyMany
    size: 1Gi
```

<h3>Option 3 - embedded into container image</h3>

This method stores your DAGs inside the container image.

> ⚠️ this chart uses the official [apache/airflow](https://hub.docker.com/r/apache/airflow) images, consult airflow's official [docs about custom images](https://airflow.apache.org/docs/apache-airflow/2.0.1/production-deployment.html#production-container-images)

For example, extending `airflow:2.0.1-python3.8` with some dags:
```dockerfile
FROM apache/airflow:2.0.1-python3.8

# NOTE: dag path is set with the `dags.path` value
COPY ./my_dag_folder /opt/airflow/dags
```

Then use this container image with the chart:
```yaml
airflow:
  image:
    repository: MY_REPO
    tag: MY_TAG
```

<hr>
</details>

### How to install extra pip packages?
<details>
<summary>Show More</summary>
<hr>

<h3>Option 1 - use init-containers</h3>

> 🛑️️️ seriously consider the implications of having each Pod run `pip install` before using this feature in production

You can use the `airflow.extraPipPackages` value to install pip packages on all Pods, you can also use the more specific `scheduler.extraPipPackages`, `web.extraPipPackages`, `worker.extraPipPackages` and `flower.extraPipPackages`.

Packages defined with the more specific values will take precedence over `airflow.extraPipPackages`, as they are listed at the end of the `pip install ...` command, and pip takes the package version which is __defined last__.

For example, installing the `airflow-exporter` package on all scheduler/web/worker/flower Pods:
```yaml
airflow:
  extraPipPackages:
    - "airflow-exporter~=1.4.1"
```

For example, installing PyTorch on the scheduler/worker Pods only:
```yaml
scheduler:
  extraPipPackages:
    - "torch~=1.8.0"

worker:
  extraPipPackages:
    - "torch~=1.8.0"
```

<h3>Option 2 - embedded into container image (recommended)</h3>

You can extend the airflow container image with your pip packages.

> ⚠️ this chart uses the official [apache/airflow](https://hub.docker.com/r/apache/airflow) images, consult airflow's official [docs about custom images](https://airflow.apache.org/docs/apache-airflow/2.0.1/production-deployment.html#production-container-images)

For example, extending `airflow:2.0.1-python3.8` with the `torch` package:
```dockerfile
FROM apache/airflow:2.0.1-python3.8

# install your pip packages
RUN pip install torch~=1.8.0
```

Then use this container image with the chart:
```yaml
airflow:
  image:
    repository: MY_REPO
    tag: MY_TAG
```

<hr>
</details>

### How to create airflow users? 
<details>
<summary>Show More</summary>
<hr>

You can use the `airflow.users` value to create airflow users with a post-install/post-update helm hook Job.

> ⚠️ if you need to edit the users in the web-ui (for example, to change their password), you should set `airflow.usersUpdate` to `false`

For example, to create `admin` (with "Admin" RBAC role) and `user` (with "User" RBAC role):
```yaml
airflow:
  users:
    - username: admin
      password: admin
      role: Admin
      email: admin@example.com
      firstName: admin
      lastName: admin
    - username: user
      password: user123
      role: User
      email: user@example.com
      firstName: user
      lastName: user

  ## if we update users or just create them the first time (lookup by `username`)
  usersUpdate: true
```

<hr>
</details>

### How to authenticate airflow users with LDAP/OAUTH? 
<details>
<summary>Show More</summary>
<hr>

You can use the `web.webserverConfig.*` values to adjust the Flask-Appbuilder `webserver_config.py` file, you can read Flask-builder's security docs [here](https://flask-appbuilder.readthedocs.io/en/latest/security.html).

> 🛑️️ if you set up LDAP/OAUTH, you should set `airflow.users` to `[]` (and delete any previously created users)

> ⚠️ the version of Flask-Builder installed by airflow might not be the latest, but you can use `web.extraPipPackages` to install a newer version, if needed

For example, to integrate with a typical Microsoft Active Directory using `AUTH_LDAP`:
```yaml
web:
  extraPipPackages:
    ## the following configs require Flask-AppBuilder 3.2.0 (or later)
    - "Flask-AppBuilder~=3.2.0"
    ## the following configs require python-ldap
    - "python-ldap~=3.3.1"

  webserverConfig:
    stringOverride: |-
      from airflow import configuration as conf
      from flask_appbuilder.security.manager import AUTH_LDAP

      SQLALCHEMY_DATABASE_URI = conf.get('core', 'SQL_ALCHEMY_CONN')
      
      AUTH_TYPE = AUTH_LDAP
      AUTH_LDAP_SERVER = "ldap://ldap.example.com"
      AUTH_LDAP_USE_TLS = False
      
      # registration configs
      AUTH_USER_REGISTRATION = True  # allow users who are not already in the FAB DB
      AUTH_USER_REGISTRATION_ROLE = "Public"  # this role will be given in addition to any AUTH_ROLES_MAPPING
      AUTH_LDAP_FIRSTNAME_FIELD = "givenName"
      AUTH_LDAP_LASTNAME_FIELD = "sn"
      AUTH_LDAP_EMAIL_FIELD = "mail"  # if null in LDAP, email is set to: "{username}@email.notfound"
      
      # bind username (for password validation)
      AUTH_LDAP_USERNAME_FORMAT = "uid=%s,ou=users,dc=example,dc=com"  # %s is replaced with the provided username
      # AUTH_LDAP_APPEND_DOMAIN = "example.com"  # bind usernames will look like: {USERNAME}@example.com
      
      # search configs
      AUTH_LDAP_SEARCH = "ou=users,dc=example,dc=com"  # the LDAP search base (if non-empty, a search will ALWAYS happen)
      AUTH_LDAP_UID_FIELD = "uid"  # the username field

      # a mapping from LDAP DN to a list of FAB roles
      AUTH_ROLES_MAPPING = {
          "cn=airflow_users,ou=groups,dc=example,dc=com": ["User"],
          "cn=airflow_admins,ou=groups,dc=example,dc=com": ["Admin"],
      }
      
      # the LDAP user attribute which has their role DNs
      AUTH_LDAP_GROUP_FIELD = "memberOf"
      
      # if we should replace ALL the user's roles each login, or only on registration
      AUTH_ROLES_SYNC_AT_LOGIN = True
      
      # force users to re-auth after 30min of inactivity (to keep roles in sync)
      PERMANENT_SESSION_LIFETIME = 1800
```

For example, to integrate with Okta using `AUTH_OAUTH`:
```yaml
web:
  extraPipPackages:
    ## the following configs require Flask-AppBuilder 3.2.0 (or later)
    - "Flask-AppBuilder~=3.2.0"
    ## the following configs require Authlib
    - "Authlib~=0.15.3"

  webserverConfig:
    stringOverride: |-
      from airflow import configuration as conf
      from flask_appbuilder.security.manager import AUTH_OAUTH

      SQLALCHEMY_DATABASE_URI = conf.get('core', 'SQL_ALCHEMY_CONN')
      
      AUTH_TYPE = AUTH_OAUTH
      
      # registration configs
      AUTH_USER_REGISTRATION = True  # allow users who are not already in the FAB DB
      AUTH_USER_REGISTRATION_ROLE = "Public"  # this role will be given in addition to any AUTH_ROLES_MAPPING

      # the list of providers which the user can choose from
      OAUTH_PROVIDERS = [
          {
              'name': 'okta',
              'icon': 'fa-circle-o',
              'token_key': 'access_token',
              'remote_app': {
                  'client_id': 'OKTA_KEY',
                  'client_secret': 'OKTA_SECRET',
                  'api_base_url': 'https://OKTA_DOMAIN.okta.com/oauth2/v1/',
                  'client_kwargs': {
                      'scope': 'openid profile email groups'
                  },
                  'access_token_url': 'https://OKTA_DOMAIN.okta.com/oauth2/v1/token',
                  'authorize_url': 'https://OKTA_DOMAIN.okta.com/oauth2/v1/authorize',
              }
          }
      ]
      
      # a mapping from the values of `userinfo["role_keys"]` to a list of FAB roles
      AUTH_ROLES_MAPPING = {
          "FAB_USERS": ["User"],
          "FAB_ADMINS": ["Admin"],
      }

      # if we should replace ALL the user's roles each login, or only on registration
      AUTH_ROLES_SYNC_AT_LOGIN = True
      
      # force users to re-auth after 30min of inactivity (to keep roles in sync)
      PERMANENT_SESSION_LIFETIME = 1800
```

<hr>
</details>

### How to set a custom fernet (encryption) key? 
<details>
<summary>Show More</summary>
<hr>

<h3>Option 1 - using value</h3>

You can customize the fernet encryption key using the `airflow.fernetKey` value, which sets the `AIRFLOW__CORE__FERNET_KEY` environment variable.

For example:
```yaml
aiflow:
  fernetKey: "7T512UXSSmBOkpWimFHIVb8jK6lfmSAvx4mO6Arehnc="
```

<h3>Option 2 - using secret (recommended)</h3>

You can customize the fernet encryption key by pre-creating a Secret, and specifying it with the `airflow.extraEnv` value.

For example, if the Secret `airflow-fernet-key` already exist, and contains a key called `value`:
```yaml
airflow:
  extraEnv:
    - name: AIRFLOW__CORE__FERNET_KEY
      valueFrom:
        secretKeyRef:
          name: airflow-fernet-key
          key: value
```

<hr>
</details>

### How to create airflow connections?
<details>
<summary>Show More</summary>
<hr>

You can use the `airflow.connections` value to create airflow [Connections](https://airflow.apache.org/docs/apache-airflow/stable/concepts.html#connections) with a post-install/post-update helm hook Job.

> ⚠️ if you need to edit the connections in the web-ui (for example, to add a sensitive password), you should set `airflow.connectionsUpdate` to `false`

For example, to create connections called `my_aws`, `my_gcp`, `my_postgres`, and `my_ssh`:
```yaml
airflow:
  connections:
    ## see docs: https://airflow.apache.org/docs/apache-airflow-providers-amazon/stable/connections/aws.html
    - id: my_aws
      type: aws
      description: my AWS connection
      extra: |-
        { "aws_access_key_id": "XXXXXXXX",
          "aws_secret_access_key": "XXXXXXXX",
          "region_name":"eu-central-1" }
    ## see docs: https://airflow.apache.org/docs/apache-airflow-providers-google/stable/connections/gcp.html
    - id: my_gcp
      type: google_cloud_platform
      description: my GCP connection
      extra: |-
        { "extra__google_cloud_platform__keyfile_dict": "XXXXXXXX",
          "extra__google_cloud_platform__num_retries: "XXXXXXXX" }
    ## see docs: https://airflow.apache.org/docs/apache-airflow-providers-postgres/stable/connections/postgres.html
    - id: my_postgres
      type: postgres
      description: my Postgres connection
      host: postgres.example.com
      port: 5432
      login: db_user
      password: db_pass
      schema: my_db
      extra: |-
        { "sslmode": "allow" }
    ## see docs: https://airflow.apache.org/docs/apache-airflow-providers-ssh/stable/connections/ssh.html
    - id: my_ssh
      type: ssh
      description: my SSH connection
      host: ssh.example.com
      port: 22
      login: ssh_user
      password: ssh_pass
      extra: |-
        { "timeout": "15" }

  ## if we update connections or just create them the first time (lookup by `id`)
  connectionsUpdate: true
```

<hr>
</details>

### How to create airflow variables?
<details>
<summary>Show More</summary>
<hr>

You can use the `airflow.variables` value to create airflow [Variables](https://airflow.apache.org/docs/apache-airflow/stable/concepts.html#variables) with a post-install/post-update helm hook Job.

> ⚠️ if you need to edit the variables in the web-ui, you should set `airflow.variablesUpdate` to `false`

For example, to create variables called `var_1`, `var_2`:
```yaml
airflow:
  variables:
    - key: "var_1"
      value: "my_value_1"
    - key: "var_2"
      value: "my_value_2"

  ## if we update variables or just create them the first time (lookup by `key`)
  variablesUpdate: true
```

<hr>
</details>

### How to create airflow pools?
<details>
<summary>Show More</summary>
<hr>

You can use the `airflow.pools` value to create airflow [Pools](https://airflow.apache.org/docs/apache-airflow/stable/concepts.html#pools) with a post-install/post-update helm hook Job.

> ⚠️ if you need to edit the variables in the web-ui, you should set `airflow.poolsUpdate` to `false`

For example, to create pools called `pool_1`, `pool_2`:
```yaml
airflow:
  pools:
    - name: "pool_1"
      slots: 5
      description: "example pool with 5 slots"
    - name: "pool_2"
      slots: 10
      description: "example pool with 10 slots"

  ## if we update pools or just create them the first time (lookup by `name`)
  poolsUpdate: true
```

<hr>
</details>

### How to set up celery worker autoscaling?
<details>
<summary>Show More</summary>
<hr>

The Airflow Celery Workers can be scaled using the [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/), to enable autoscaling, you must set `workers.autoscaling.enabled=true`, then provide `workers.autoscaling.maxReplicas`.

Assume every task a worker executes consumes approximately `200Mi` memory, that means memory is a good metric for utilisation monitoring.
For a worker pod you can calculate it: `WORKER_CONCURRENCY * 200Mi`, so for `10 tasks` a worker will consume `~2Gi` of memory. 
In the following config if a worker consumes `80%` of `2Gi` (which will happen if it runs 9-10 tasks at the same time), an autoscaling event will be triggered, and a new worker will be added.
If you have many tasks in a queue, Kubernetes will keep adding workers until maxReplicas reached, in this case `16`.
```yaml
airflow:
  config:
    AIRFLOW__CELERY__WORKER_CONCURRENCY: 10

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
    ## wait at most 9min for running tasks to complete before SIGTERM
    ## WARNING: 
    ## - some cloud cluster-autoscaler configs will not respect graceful termination 
    ##   longer than 10min, for example, Google Kubernetes Engine (GKE)
    gracefullTermination: true
    gracefullTerminationPeriod: 540

  ## how many seconds (after the 9min) to wait before SIGKILL
  terminationPeriod: 60

dags:
  gitSync:
    resources:
      requests:
        ## IMPORTANT! for autoscaling to work with gitSync
        memory: "64Mi"
```

<hr>
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

Example, using `AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID` (can be used with S3 + AWS connection too):
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
          "extra__google_cloud_platform__keyfile_dict: "XXXXXXXX",
          "extra__google_cloud_platform__num_retries": "5" }
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

<hr>
</details>

## Database Configs

### How to use the embedded Postgres?
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
  --namespace my-airflow-namespace

# set redis password
kubectl create secret generic \
  airflow-redis \
  --from-literal=redis-password=$(openssl rand -base64 13) \
  --namespace my-airflow-namespace
```

Example `values.yaml`, to use those secrets:
```yaml
postgresql:
  existingSecret: airflow-postgresql

redis:
  existingSecret: airflow-redis
```

<hr>
</details>

### How to use an external database (recommended)?
<details>
<summary>Show More</summary>
<hr>

<h3>Option 1 - Postgres</h3>

Example values for an external Postgres database, with an existing `airflow_cluster1` database:
```yaml
postgresql:
  enabled: false

externalDatabase:
  type: postgres
  host: postgres.example.org
  port: 5432
  database: airflow_cluster1
  user: airflow_cluster1
  passwordSecret: "airflow-cluster1-postgres-password"
  passwordSecretKey: "postgresql-password"

  # use this for any extra connection-string settings, e.g. ?sslmode=disable
  properties: ""
```

<h3>Option 2 - MySQL</h3>

> ⚠️ you must set `explicit_defaults_for_timestamp=1` in your MySQL instance, [see here](https://airflow.apache.org/docs/stable/howto/initialize-database.html)

Example values for an external MySQL database, with an existing `airflow_cluster1` database:
```yaml
postgresql:
  enabled: false

externalDatabase:
  type: mysql
  host: mysql.example.org
  port: 3306
  database: airflow_cluster1
  user: airflow_cluster1
  passwordSecret: "airflow-cluster1-mysql-password"
  passwordSecretKey: "mysql-password"

  # use this for any extra connection-string settings, e.g. ?useSSL=false
  properties: ""
```

<hr>
</details>

### How to use an external redis?
<details>
<summary>Show More</summary>
<hr>

Example values for an external redis with ssl enabled:
```yaml
redis:
  enabled: false

externalRedis:
  host: "example.redis.cache.windows.net"
  port: 6380
  databaseNumber: 15
  passwordSecret: "redis-password"
  passwordSecretKey: "value"
  properties: "?ssl_cert_reqs=CERT_OPTIONAL"
```

<hr>
</details>

## Kubernetes Configs

### How to mount ConfigMaps/Secrets as environment variables?
<details>
<summary>Show More</summary>
<hr>

You can use the `airflow.extraEnv` value to mount extra environment variables with the same structure as [EnvVar in ContainerSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#envvar-v1-core).

This method can be used to pass sensitive configs to Airflow.

For example, if the Secret `airflow-fernet-key` already exist, and contains a key called `value`:
```yaml
airflow:
  extraEnv:
    - name: AIRFLOW__CORE__FERNET_KEY
      valueFrom:
        secretKeyRef:
          name: airflow-fernet-key
          key: value
```

<hr>
</details>

### How to mount Secrets/Configmaps as files on workers?
<details>
<summary>Show More</summary>
<hr>

You can use the `workers.extraVolumeMounts` and `workers.extraVolumes` values to mount Secretes as files.

For example, if the Secret `redshift-creds` already exist, and has keys called `user` and `password`:
```yaml
workers:
  extraVolumeMounts:
    - name: redshift-creds
      mountPath: /opt/airflow/secrets/redshift-creds
      readOnly: true

  extraVolumes:
    - name: redshift-creds
      secret:
        secretName: redshift-creds
```

You could then read the `/opt/airflow/secrets/redshift-creds` files from within a DAG Python function:
```python
from pathlib import Path
redis_user = Path("/opt/airflow/secrets/redshift-creds/user").read_text().strip()
redis_password = Path("/opt/airflow/secrets/redshift-creds/password").read_text().strip()
```

To create the `redshift-creds` Secret, you could use:
```console
kubectl create secret generic \
  redshift-creds \
  --from-literal=user=MY_REDSHIFT_USERNAME \
  --from-literal=password=MY_REDSHIFT_PASSWORD \
  --namespace my-airflow-namespace
```

<hr>
</details>

### How to set up an Ingress?
<details>
<summary>Show More</summary>
<hr>

The chart provides the `ingress.*` values for deploying a Kubernetes Ingress to allow access to airflow outside the cluster.

Consider the situation where you already have something hosted at the root of your domain, you might want to place airflow under a URL-prefix:
- http://example.com/airflow/
- http://example.com/airflow/flower

In this example, would set these values:
```yaml
airflow:
  config: 
    AIRFLOW__WEBSERVER__BASE_URL: "http://example.com/airflow/"
    AIRFLOW__CELERY__FLOWER_URL_PREFIX: "/airflow/flower"

ingress:
  enabled: true
  web:
    path: "/airflow"
  flower:
    path: "/airflow/flower"
```

We expose the `ingress.web.precedingPaths` and `ingress.web.succeedingPaths` values, which are __before__ and __after__ the default path respectively.

> ⚠️ A common use-case is [enabling SSL with the aws-alb-ingress-controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.1/guide/tasks/ssl_redirect/), which needs a redirect path to be hit before the airflow-webserver one.

For example, setting `ingress.web.precedingPaths` for an aws-alb-ingress-controller with SSL:
```yaml
ingress:
  web:
    precedingPaths:
      - path: "/*"
        serviceName: "ssl-redirect"
        servicePort: "use-annotation"
```

<hr>
</details>

### How to integrate airflow with Prometheus?
<details>
<summary>Show More</summary>
<hr>

To be able to expose Airflow metrics to Prometheus you will need install a plugin, one option is [epoch8/airflow-exporter](https://github.com/epoch8/airflow-exporter) which exports DAG and task metrics from Airflow.

A [ServiceMonitor](https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/api.md#servicemonitor) is a resource introduced by the [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator), ror more information, see the `serviceMonitor` section of `values.yaml`.

<hr>
</details>

### How to add extra manifests?
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

<hr>
</details>

## Chart Values

### Global:
<details>
<summary>Show More</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`airflow.legacyCommands` | if we use legacy 1.10 airflow commands | `false`
`airflow.image.*` | configs for the airflow container image | `<see values.yaml>`
`airflow.executor` | the airflow executor type to use | `CeleryExecutor`
`airflow.fernetKey` | the fernet key used to encrypt the connections/variables in the database | `7T512UXSSmBOkpWimFHIVb8jK6lfmSAvx4mO6Arehnc=`
`airflow.config` | environment variables for airflow configs | `{}`
`airflow.users` | a list of initial users to create | `<see values.yaml>`
`airflow.usersUpdate` | if we update users or just create them the first time (lookup by `username`) | `true`
`airflow.users` | a list of initial users to create | `<see values.yaml>`
`airflow.connections` | a list of initial connections to create | `<see values.yaml>`
`airflow.connectionsUpdate` | if we update connections or just create them the first time (lookup by `id`) | `true`
`airflow.variables` | a list of initial variables to create | `<see values.yaml>`
`airflow.variablesUpdate` | if we update variables or just create them the first time (lookup by `key`) | `true`
`airflow.pools` | a list of initial pools to create | `<see values.yaml>`
`airflow.poolsUpdate` | if we update pools or just create them the first time (lookup by `name`) | `true`
`airflow.podAnnotations` | extra annotations for the web/scheduler/worker/flower Pods | `{}`
`airflow.extraPipPackages` | extra pip packages to install in the web/scheduler/worker/flower Pods | `[]`
`airflow.extraEnv` | extra environment variables for the web/scheduler/worker/flower Pods | `[]`
`airflow.extraContainers` | extra containers for the web/scheduler/worker/flower Pods | `[]`
`airflow.extraVolumeMounts` | extra VolumeMounts for the web/scheduler/worker/flower Pods | `[]`
`airflow.extraVolumes` | extra Volumes for the web/scheduler/worker/flower Pods | `[]`
`airflow.kubernetesPodTemplate.*` | configs to generate the AIRFLOW__KUBERNETES__POD_TEMPLATE_FILE | `<see values.yaml>`

<hr>
</details>

### Airflow Scheduler:
<details>
<summary>Show More</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`scheduler.replicas` | the number of scheduler Pods to run | `1`
`scheduler.resources` | resource requests/limits for the scheduler Pods | `{}`
`scheduler.nodeSelector` | the nodeSelector configs for the scheduler Pods | `{}`
`scheduler.affinity` | the affinity configs for the scheduler Pods | `{}`
`scheduler.tolerations` | the toleration configs for the scheduler Pods | `[]`
`scheduler.securityContext` | the security context for the scheduler Pods | `{}`
`scheduler.labels` | labels for the scheduler Deployment | `{}`
`scheduler.podLabels` | Pod labels for the scheduler Deployment | `{}`
`scheduler.annotations` | annotations for the scheduler Deployment | `{}`
`scheduler.podAnnotations` | Pod annotations for the scheduler Deployment | `{}`
`scheduler.safeToEvict` | if we add the annotation: "cluster-autoscaler.kubernetes.io/safe-to-evict" = "true" | `true`
`scheduler.podDisruptionBudget.*` | configs for the PodDisruptionBudget of the scheduler | `<see values.yaml>`
`scheduler.numRuns` | the value of the `airflow --num_runs` parameter used to run the airflow scheduler | `-1`
`scheduler.extraPipPackages` | extra pip packages to install in the scheduler Pods | `[]`
`scheduler.extraVolumeMounts` | extra VolumeMounts for the scheduler Pods | `[]`
`scheduler.extraVolumes` | extra Volumes for the scheduler Pods | `[]`
`scheduler.livenessProbe.*` | configs for the scheduler Pods' liveness probe | `<see values.yaml>`
`scheduler.extraInitContainers` | extra init containers to run in the scheduler Pods | `[]`

<hr>
</details>

### Airflow Webserver:
<details>
<summary>Show More</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`web.webserverConfig.*` | configs to generate webserver_config.py | `<see values.yaml>`
`web.replicas` | the number of web Pods to run | `1`
`web.resources` | resource requests/limits for the airflow web pods | `{}`
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
`web.readinessProbe.*` | configs for the web Pods' readiness probe | `<see values.yaml>`
`web.livenessProbe.*` | configs for the web Pods' liveness probe | `<see values.yaml>`
`web.extraPipPackages` | extra pip packages to install in the web Pods | `[]`
`web.extraVolumeMounts` | extra VolumeMounts for the web Pods | `[]`
`web.extraVolumes` | extra Volumes for the web Pods | `[]`

<hr>
</details>

### Airflow Celery Worker:
<details>
<summary>Show More</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`workers.enabled` | if the airflow workers StatefulSet should be deployed | `true`
`workers.replicas` | the number of workers Pods to run | `1`
`workers.resources` | resource requests/limits for the airflow worker Pods | `{}`
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
`workers.extraPipPackages` | extra pip packages to install in the worker Pods | `[]`
`workers.extraVolumeMounts` | extra VolumeMounts for the worker Pods | `[]`
`workers.extraVolumes` | extra Volumes for the worker Pods | `[]`

<hr>
</details>

### Airflow Flower:
<details>
<summary>Show More</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`flower.enabled` | if the Flower UI should be deployed | `true`
`flower.resources` | resource requests/limits for the flower Pods | `{}`
`flower.nodeSelector` | the nodeSelector configs for the flower Pods | `{}`
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
`flower.service.*` | configs for the Service of the flower Pods | `<see values.yaml>`
`flower.extraPipPackages` | extra pip packages to install in the flower Pod | `[]`
`flower.extraVolumeMounts` | extra VolumeMounts for the flower Pods | `[]`
`flower.extraVolumes` | extra Volumes for the flower Pods | `[]`

<hr>
</details>

### Logs:
<details>
<summary>Show More</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`logs.path` | the airflow logs folder | `/opt/airflow/logs`
`logs.persistence.*` | configs for the logs PVC | `<see values.yaml>`

<hr>
</details>

### DAGs:
<details>
<summary>Show More</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`dags.path` | the airflow dags folder | `/opt/airflow/dags`
`dags.persistence.*` | configs for the dags PVC | `<see values.yaml>`
`dags.gitSync.*` | configs for the git-sync sidecar  | `<see values.yaml>`

<hr>
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

<hr>
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

<hr>
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

<hr>
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

<hr>
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

<hr>
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
`externalDatabase.properties` | the connection properties eg ?ssl_cert_reqs=CERT_OPTIONAL | `""` 

<hr>
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

<hr>
</details>

<br>
<br>
