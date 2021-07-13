# Airflow Helm Chart

__`User Community` version, previously known as `stable/airflow`__

[![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/airflow-helm)](https://artifacthub.io/packages/helm/airflow-helm/airflow)

---

This chart provides a standard way to deploy [Apache Airflow](https://airflow.apache.org/) on your Kubernetes cluster,
and is used by thousands of companies for their production deployments of Airflow.

> 🟦 __Discussion__ 🟦
>
> The `user community` chart is an alternative to the `official` chart found in the `apache/airflow` repo.<br>
> There are differences between the charts, so you should evaluate which is better for your organisation.
>
> The `user community` chart has existed since 2018 and was previously called `stable/airflow` on the official [helm/charts](https://github.com/helm/charts/tree/master/stable/airflow) repo.
>
> The goals of the `user community` chart are:<br>
> (1) be easy to configure<br>
> (2) support older airflow versions<br>
> (3) provide great documentation<br>
> (4) automatically detect bad configs<br>

## Quickstart Guide

These steps will allow you to quickly install Apache Airflow on your Kubernetes cluster using the `community` chart.

### 1. Install the Chart

> 🟨 __Note__ 🟨
>
> In production, we encourage using a tool like [ArgoCD](https://argoproj.github.io/argo-cd/), rather than running `helm install` manually

```sh
# add this repo as "airflow-stable"
helm repo add airflow-stable https://airflow-helm.github.io/charts
helm repo update

# set environment variables (to make `helm install ...` cleaner)
export RELEASE_NAME=my-airflow-cluster # a name
export NAMESPACE=my-airflow-namespace # a namespace
export CHART_VERSION=8.X.X # a chart version - https://github.com/airflow-helm/charts/blob/main/charts/airflow/CHANGELOG.md
export VALUES_FILE=./custom-values.yaml # your values file

# use helm 3+ to install
helm install \
  $RELEASE_NAME \
  airflow-stable/airflow \
  --namespace $NAMESPACE \
  --version $CHART_VERSION \
  --values $VALUES_FILE
  
# wait until the above command returns (there are some post-install Jobs which may take a while)
```

### 2. Login to the WebUI

```sh
export NAMESPACE=my-airflow-namespace # set a namespace!

export POD_NAME=$(kubectl get pods --namespace $NAMESPACE -l "component=web,app=airflow" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward --namespace $NAMESPACE $POD_NAME 8080:8080

# open the web-ui in your browser: http://localhost:8080 
# default user login: admin/admin
```

## Important Documentation

### Changelog

The [CHANGELOG.md](CHANGELOG.md) is found at the root of this chart folder.

### Airflow Version Support

See [the guide here](#how-to-use-a-specific-version-of-airflow) on how to explicitly set your airflow version.

. | `1.10.X`  | `2.0.X` | `2.1.X`
--- | --- | --- | ---
chart - `7.X.X` | ✅ | ❌ | ❌
chart - `8.X.X` | ✅ <sub>[1]</sub> | ✅ | ✅

<sub>[1] you must set `airflow.legacyCommands = true` to use airflow `1.10.X` with chart `8.X.X`

### Airflow Executor Support

Set your airflow executor-type using the `airflow.executor` value.

. | `CeleryExecutor` | `KubernetesExecutor` | `CeleryKubernetesExecutor`
--- | --- | --- | --- 
chart - `7.X.X` | ✅ | ✅ <sub>[1]</sub> | ❌
chart - `8.X.X` | ✅ | ✅ | ✅

<sub>[1] we encourage you to upgrade the chart to `8.X.X`, so you can use the `airflow.kubernetesPodTemplate` values (which require airflow `1.10.11+`, as they set [AIRFLOW__KUBERNETES__POD_TEMPLATE_FILE](https://airflow.apache.org/docs/apache-airflow/2.1.0/configurations-ref.html#pod-template-file)) </sub>

### Examples

We provide some example `values.yaml` files for common configurations:

- [Minikube/Kind - CeleryExecutor](examples/minikube/custom-values.yaml)
- [Google Kubernetes Engine (GKE) - CeleryExecutor](examples/google-gke/custom-values.yaml)

### Further Reading

We recommend you review the following questions from the FAQ:

- [How to use a specific version of airflow?](#how-to-use-a-specific-version-of-airflow)
- [How to set airflow configs?](#how-to-set-airflow-configs)
- [How to create airflow users?](#how-to-create-airflow-users) or [How to authenticate airflow users with LDAP/OAUTH?](#how-to-authenticate-airflow-users-with-ldapoauth)
- [How to create airflow connections?](#how-to-create-airflow-connections)
- [How to use an external database?](#how-to-use-an-external-database)
- [How to persist airflow logs?](#how-to-persist-airflow-logs)
- [How to setup an Ingres?](#how-to-set-up-an-ingress)

## FAQ - Airflow

> These are some frequently asked questions related to airflow configs:

### How to use a specific version of airflow?
<details>
<summary>Expand</summary>
<hr>

There will always be a single default version of airflow shipped with this chart, see `airflow.image.*` in [values.yaml](values.yaml) for the current one, but other versions are supported, please see the [Airflow Version Support](#airflow-version-support) matrix.

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
<summary>Expand</summary>
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
<summary>Expand</summary>
<hr>

<h3>Option 1a - git-sync sidecar (SSH auth)</h3>

This method uses an SSH git-sync sidecar to sync your git repo into the dag folder every `dags.gitSync.syncWait` seconds.

Example values defining an SSH git repo:
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

<h3>Option 1b - git-sync sidecar (HTTP auth)</h3>

This method uses an HTTP git sidecar to sync your git repo into the dag folder every `dags.gitSync.syncWait` seconds.

Example values defining an HTTP git repo:
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

<h3>Option 2a - PersistentVolumeClaim (chart-managed)</h3>

With this method, you store your DAGs in a Kubernetes PersistentVolume, which is mounted to all scheduler/web/worker Pods.
You must configure some external system to ensure this volume has your latest DAGs.
For example, you could use your CI/CD pipeline system to preform a sync as changes are pushed to your DAGs git repo.

Example values to create a PVC with the `storageClass` called `default` and 1Gi initial `size`:
```yaml
dags:
  persistence:
    enabled: true
    storageClass: default
    accessMode: ReadOnlyMany
    size: 1Gi
```

<h3>Option 2b - PersistentVolumeClaim (existing / user-managed)</h3>

> 🟨 __Note__ 🟨
>
> Your `dags.persistence.existingClaim` PVC must support `ReadOnlyMany` or `ReadWriteMany` for `accessMode`

Example values to use an existing PVC called `my-dags-pvc`:
```yaml
dags:
  persistence:
    enabled: true
    existingClaim: my-dags-pvc
    accessMode: ReadOnlyMany
```

<h3>Option 3 - embedded into container image</h3>

> 🟨 __Note__ 🟨 
> 
> This chart uses the official [apache/airflow](https://hub.docker.com/r/apache/airflow) images, consult airflow's official [docs about custom images](https://airflow.apache.org/docs/apache-airflow/2.0.1/production-deployment.html#production-container-images)

This method stores your DAGs inside the container image.

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
```

<hr>
</details>

### How to install extra pip packages?
<details>
<summary>Expand</summary>
<hr>

<h3>Option 1 - use init-containers</h3>

> 🟥 __Warning__ 🟥 
> 
> We strongly advice that you DO NOT TO USE this feature in production, instead please use "Option 2"

You can use the `airflow.extraPipPackages` value to install pip packages on all Pods, you can also use the more specific `scheduler.extraPipPackages`, `web.extraPipPackages`, `worker.extraPipPackages` and `flower.extraPipPackages`.
Packages defined with the more specific values will take precedence over `airflow.extraPipPackages`, as they are listed at the end of the `pip install ...` command, and pip takes the package version which is __defined last__.

Example values for installing the `airflow-exporter` package on all scheduler/web/worker/flower Pods:
```yaml
airflow:
  extraPipPackages:
    - "airflow-exporter~=1.4.1"
```

Example values for installing PyTorch on the scheduler/worker Pods only:
```yaml
scheduler:
  extraPipPackages:
    - "torch~=1.8.0"

worker:
  extraPipPackages:
    - "torch~=1.8.0"
```

<h3>Option 2 - embedded into container image (recommended)</h3>

This chart uses the official [apache/airflow](https://hub.docker.com/r/apache/airflow) images, consult airflow's official [docs about custom images](https://airflow.apache.org/docs/apache-airflow/2.0.1/production-deployment.html#production-container-images), you can extend the airflow container image with your pip packages.

For example, extending `airflow:2.0.1-python3.8` with the `torch` package:
```dockerfile
FROM apache/airflow:2.0.1-python3.8

# install your pip packages
RUN pip install torch~=1.8.0
```

Example values to use your `MY_REPO:MY_TAG` container image:
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
<summary>Expand</summary>
<hr>

<h3>Option 1 - use plain-text</h3>

You can use the `airflow.users` value to create airflow users in a declarative way.

Example values to create `admin` (with "Admin" RBAC role) and `user` (with "User" RBAC role):
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

  ## if we create a Deployment to perpetually sync `airflow.users`
  usersUpdate: true
```

<h3>Option 2 - use templates from Secrets/ConfigMaps</h3>

> 🟨 __Note__ 🟨
>
> If `airflow.usersUpdate = true`, the users which use `airflow.usersTemplates` will be updated in real-time, allowing tools like [external-secrets](https://github.com/external-secrets/kubernetes-external-secrets) to be used.

You can use `airflow.usersTemplates` to extract string templates from keys in Secrets or Configmaps.

Example values to use templates from `Secret/my-secret` and `ConfigMap/my-configmap` in parts of the `admin` user:
```yaml
airflow:
  users:
    - username: admin
      password: ${ADMIN_PASSWORD}
      role: Admin
      email: ${ADMIN_EMAIL}
      firstName: admin
      lastName: admin
        
  ## bash-like templates to be used in `airflow.users`
  usersTemplates:
    ADMIN_PASSWORD:
      kind: secret
      name: my-secret
      key: password
    ADMIN_EMAIL:
      kind: configmap
      name: my-configmap
      key: email
        
  ## if we create a Deployment to perpetually sync `airflow.users`
  usersUpdate: true
```

<hr>
</details>

### How to authenticate airflow users with LDAP/OAUTH? 
<details>
<summary>Expand</summary>
<hr>

> 🟥 __Warning__ 🟥 
> 
> If you set up LDAP/OAUTH, you should set `airflow.users = []` (and delete any previously created users)
> 
> The version of Flask-Builder installed might not be the latest, see [How to install extra pip packages?](#how-to-install-extra-pip-packages)

You can use the `web.webserverConfig.*` values to adjust the Flask-Appbuilder `webserver_config.py` file, read [Flask-builder's security docs](https://flask-appbuilder.readthedocs.io/en/latest/security.html) for further reference.

Example values to integrate with a typical Microsoft Active Directory using `AUTH_LDAP`:
```yaml
web:
  # WARNING: for production usage, create your own image with these packages installed rather than using `extraPipPackages`
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

Example values to integrate with Okta using `AUTH_OAUTH`:
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
<summary>Expand</summary>
<hr>

> 🟥 __Warning__ 🟥 
> 
> We strongly recommend that you change the default encryption key, otherwise the encryption is somewhat pointless

<h3>Option 1 - using value</h3>

You can customize the fernet encryption key using the `airflow.fernetKey` value, which sets the `AIRFLOW__CORE__FERNET_KEY` environment variable.

Example values to define a fernet key in plain-text:
```yaml
aiflow:
  fernetKey: "7T512UXSSmBOkpWimFHIVb8jK6lfmSAvx4mO6Arehnc="
```

<h3>Option 2 - using secret (recommended)</h3>

You can customize the fernet encryption key by pre-creating a Secret, and specifying it with the `airflow.extraEnv` value.

Example values to use the `value` key from the existing Secret `airflow-fernet-key`:
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
<summary>Expand</summary>
<hr>

<h3>Option 1 - use plain-text</h3>

You can use the `airflow.connections` value to create airflow [Connections](https://airflow.apache.org/docs/apache-airflow/stable/concepts.html#connections) in a declarative way.

Example values to create connections called `my_aws`, `my_gcp`, `my_postgres`, and `my_ssh`:
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

  ## if we create a Deployment to perpetually sync `airflow.connections`
  connectionsUpdate: true
```

<h3>Option 2 - use templates from Secrets/ConfigMaps</h3>

> 🟨 __Note__ 🟨
>
> If `airflow.connectionsUpdate = true`, the connections which use `airflow.connectionsTemplates` will be updated in real-time, allowing tools like [external-secrets](https://github.com/external-secrets/kubernetes-external-secrets) to be used.

You can use `airflow.connectionsTemplates` to extract string templates from keys in Secrets or Configmaps.

Example values to use templates from `Secret/my-secret` and `ConfigMap/my-configmap` in parts of the `my_aws` connection:
```yaml
airflow: 
  connections:
    - id: my_aws
      type: aws
      description: my AWS connection
      extra: |-
        { "aws_access_key_id": "${AWS_ACCESS_KEY_ID}",
          "aws_secret_access_key": "${AWS_ACCESS_KEY}",
          "region_name":"eu-central-1" }

  ## bash-like templates to be used in `airflow.connections`
  connectionsTemplates:
    AWS_ACCESS_KEY_ID:
      kind: configmap
      name: my-configmap
      key: username
    AWS_ACCESS_KEY:
      kind: secret
      name: my-secret
      key: password

  ## if we create a Deployment to perpetually sync `airflow.connections`
  connectionsUpdate: true
```

<hr>
</details>

### How to create airflow variables?
<details>
<summary>Expand</summary>
<hr>

<h3>Option 1 - use plain-text</h3>

You can use the `airflow.variables` value to create airflow [Variables](https://airflow.apache.org/docs/apache-airflow/stable/concepts.html#variables) in a declarative way.

Example values to create variables called `var_1`, `var_2`:
```yaml
airflow:
  variables:
    - key: "var_1"
      value: "my_value_1"
    - key: "var_2"
      value: "my_value_2"

  ## if we create a Deployment to perpetually sync `airflow.variables`
  variablesUpdate: true
```

<h3>Option 2 - use templates from Secrets/Configmaps</h3>

> 🟨 __Note__ 🟨
>
> If `airflow.variablesTemplates = true`, the connections which use `airflow.variablesTemplates` will be updated in real-time, allowing tools like [external-secrets](https://github.com/external-secrets/kubernetes-external-secrets) to be used.

You can use `airflow.variablesTemplates` to extract string templates from keys in Secrets or Configmaps.

Example values to use templates from `Secret/my-secret` and `ConfigMap/my-configmap` in the `var_1` and `var_2` variables:
```yaml
airflow:
  variables:
    - key: "var_1"
      value: "${MY_VALUE_1}"
    - key: "var_2"
      value: "${MY_VALUE_2}"

  ## bash-like templates to be used in `airflow.variables`
  variablesTemplates:
    MY_VALUE_1:
      kind: configmap
      name: my-configmap
      key: value1
    MY_VALUE_2:
      kind: secret
      name: my-secret
      key: value2

  ## if we create a Deployment to perpetually sync `airflow.variables`
  ##
  variablesUpdate: false
```

<hr>
</details>

### How to create airflow pools?
<details>
<summary>Expand</summary>
<hr>

You can use the `airflow.pools` value to create airflow [Pools](https://airflow.apache.org/docs/apache-airflow/stable/concepts.html#pools) in a declarative way.

Example values to create pools called `pool_1`, `pool_2`:
```yaml
airflow:
  pools:
    - name: "pool_1"
      description: "example pool with 5 slots"
      slots: 5
    - name: "pool_2"
      description: "example pool with 10 slots"
      slots: 10

  ## if we create a Deployment to perpetually sync `airflow.pools`
  poolsUpdate: true
```

<hr>
</details>

### How to set up celery worker autoscaling?
<details>
<summary>Expand</summary>
<hr>

> 🟨 __Note__ 🟨
> 
> This method of autoscaling is not ideal. There is not necessarily a link between RAM usage, and the number of pending tasks, meaning you could have a situation where your workers don't scale up despite having pending tasks.

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

### How to persist airflow logs?
<details>
<summary>Expand</summary>
<hr>

> 🟥 __Warning__ 🟥 
> 
> For production, you should persist logs in a production deployment using one of these methods.<br>
> By default, logs are stored within the container's filesystem, therefore any restart of the pod will wipe your DAG logs.

<h3>Option 1a - PersistentVolumeClaim (chart-managed)</h3>

Example values to create a PVC with the cluster-default `storageClass` and 1Gi initial `size`:
```yaml
logs:
  persistence:
    enabled: true
    storageClass: "" ## empty string means cluster-default
    accessMode: ReadWriteMany
    size: 1Gi

airflow:
  kubernetesPodTemplate:
    # chown mounted volumes to gid=65534, and give processes gid=65534
    securityContext:
      fsGroup: 65534

  sync:
    # chown mounted volumes to gid=65534, and give processes gid=65534
    securityContext:
      fsGroup: 65534

scheduler:
  # chown mounted volumes to gid=65534, and give processes gid=65534
  securityContext:
    fsGroup: 65534

web:
  # chown mounted volumes to gid=65534, and give processes gid=65534
  securityContext:
    fsGroup: 65534

workers:
  # chown mounted volumes to gid=65534, and give processes gid=65534
  securityContext:
    fsGroup: 65534

flower:
  # chown mounted volumes to gid=65534, and give processes gid=65534
  securityContext:
    fsGroup: 65534
```

<h3>Option 1b - PersistentVolumeClaim (existing / user-managed)</h3>

> 🟨 __Note__ 🟨
>
> Your `logs.persistence.existingClaim` PVC must support `ReadWriteMany` for `accessMode`

Example values to use an existing PVC called `my-logs-pvc`:

```yaml
logs:
  persistence:
    enabled: true
    existingClaim: my-logs-pvc
    accessMode: ReadWriteMany

airflow:
  kubernetesPodTemplate:
    # chown mounted volumes to gid=65534, and give processes gid=65534
    securityContext:
      fsGroup: 65534

  sync:
    # chown mounted volumes to gid=65534, and give processes gid=65534
    securityContext:
      fsGroup: 65534

scheduler:
  # chown mounted volumes to gid=65534, and give processes gid=65534
  securityContext:
    fsGroup: 65534

web:
  # chown mounted volumes to gid=65534, and give processes gid=65534
  securityContext:
    fsGroup: 65534

workers:
  # chown mounted volumes to gid=65534, and give processes gid=65534
  securityContext:
    fsGroup: 65534

flower:
  # chown mounted volumes to gid=65534, and give processes gid=65534
  securityContext:
    fsGroup: 65534
```

<h3>Option 2 - Remote Bucket (recommended)</h3>

You must give airflow credentials for it to read/write on the remote bucket, this can be achieved with `AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID`, or by using something like [Workload Identity (GKE)](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity), or [IAM Roles for Service Accounts (EKS)](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html). 

Example values using `AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID` (can be used with S3 + AWS connection too):
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

Example values using [Workload Identity (GKE)](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity):
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

Example values using [IAM Roles for Service Accounts (EKS)](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html):
```yaml
airflow:
  config:
    AIRFLOW__LOGGING__REMOTE_LOGGING: "True"
    AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER: "s3://<<MY-BUCKET-NAME>>/airflow/logs"
    AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID: "aws_default"

  kubernetesPodTemplate:
    # chown mounted volumes to gid=65534, and give processes gid=65534
    securityContext:
      fsGroup: 65534

  sync:
    # chown mounted volumes to gid=65534, and give processes gid=65534
    securityContext:
      fsGroup: 65534

scheduler:
  # chown mounted volumes to gid=65534, and give processes gid=65534
  securityContext:
    fsGroup: 65534

web:
  # chown mounted volumes to gid=65534, and give processes gid=65534
  securityContext:
    fsGroup: 65534

workers:
  # chown mounted volumes to gid=65534, and give processes gid=65534
  securityContext:
    fsGroup: 65534

flower:
  # chown mounted volumes to gid=65534, and give processes gid=65534
  securityContext:
    fsGroup: 65534

serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::XXXXXXXXXX:role/<<MY-ROLE-NAME>>"
```

<hr>
</details>

## FAQ - Databases

> These are some frequently asked questions related to database configs:

### How to use the embedded Postgres?
<details>
<summary>Expand</summary>
<hr>

> 🟥 __Warning__ 🟥 
> 
> The embedded Postgres is NOT SUITABLE for production, you should follow [How to use an external database?](#how-to-use-an-external-database)

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

Example values to use those secrets:
```yaml
postgresql:
  existingSecret: airflow-postgresql

redis:
  existingSecret: airflow-redis
```

<hr>
</details>

### How to use an external database?
<details>
<summary>Expand</summary>
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

> 🟨 __Note__ 🟨 
> 
> You must set `explicit_defaults_for_timestamp=1` in your MySQL instance, [see here](https://airflow.apache.org/docs/stable/howto/initialize-database.html)

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
<summary>Expand</summary>
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

## FAQ - Kubernetes

> These are some frequently asked questions related to kubernetes configs:

### How to mount ConfigMaps/Secrets as environment variables?
<details>
<summary>Expand</summary>
<hr>

> 🟨 __Note__ 🟨 
> 
> This method can be used to pass sensitive configs to Airflow

You can use the `airflow.extraEnv` value to mount extra environment variables with the same structure as [EnvVar in ContainerSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#envvar-v1-core).

Example values to use the `value` key from the existing Secret `airflow-fernet-key` to define `AIRFLOW__CORE__FERNET_KEY`:
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
<summary>Expand</summary>
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
<summary>Expand</summary>
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

> 🟦 __Discussion__ 🟦
> 
> A common use-case is [enabling SSL with the aws-alb-ingress-controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.1/guide/tasks/ssl_redirect/), which needs a redirect path to be hit before the airflow-webserver one

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
<summary>Expand</summary>
<hr>

To be able to expose Airflow metrics to Prometheus you will need install a plugin, one option is [epoch8/airflow-exporter](https://github.com/epoch8/airflow-exporter) which exports DAG and task metrics from Airflow.

A [ServiceMonitor](https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/api.md#servicemonitor) is a resource introduced by the [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator), ror more information, see the `serviceMonitor` section of `values.yaml`.

<hr>
</details>

### How to add extra manifests?
<details>
<summary>Expand</summary>
<hr>

You can use the `extraManifests.[]` value to add custom Kubernetes manifests to the chart.

Example values to add a `BackendConfig` resource (for GKE):
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

## Values Reference

> The list of values provided by this chart (see the [values.yaml](values.yaml) file for more details):

### `airflow.*`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`airflow.legacyCommands` | if we use legacy 1.10 airflow commands | `false`
`airflow.image.*` | configs for the airflow container image | `<see values.yaml>`
`airflow.executor` | the airflow executor type to use | `CeleryExecutor`
`airflow.fernetKey` | the fernet key used to encrypt the connections/variables in the database | `7T512UXSSmBOkpWimFHIVb8jK6lfmSAvx4mO6Arehnc=`
`airflow.config` | environment variables for airflow configs | `{}`
`airflow.users` | a list of users to create | `<see values.yaml>`
`airflow.usersTemplates` | bash-like templates to be used in `airflow.users` | `<see values.yaml>`
`airflow.usersUpdate` | if we create a Deployment to perpetually sync `airflow.users` | `true`
`airflow.connections` | a list airflow connections to create | `<see values.yaml>`
`airflow.connectionsTemplates` | bash-like templates to be used in `airflow.connections` | `<see values.yaml>`
`airflow.connectionsUpdate` | if we create a Deployment to perpetually sync `airflow.connections` | `true`
`airflow.variables` | a list airflow variables to create | `<see values.yaml>`
`airflow.variablesTemplates` | bash-like templates to be used in `airflow.variables` | `<see values.yaml>`
`airflow.variablesUpdate` | if we create a Deployment to perpetually sync `airflow.variables` | `true`
`airflow.pools` | a list airflow pools to create | `<see values.yaml>`
`airflow.poolsUpdate` | if we create a Deployment to perpetually sync `airflow.pools` | `true`
`airflow.podAnnotations` | extra annotations for the web/scheduler/worker/flower Pods | `{}`
`airflow.extraPipPackages` | extra pip packages to install in the web/scheduler/worker/flower Pods | `[]`
`airflow.extraEnv` | extra environment variables for the web/scheduler/worker/flower Pods | `[]`
`airflow.extraContainers` | extra containers for the web/scheduler/worker/flower Pods | `[]`
`airflow.extraVolumeMounts` | extra VolumeMounts for the web/scheduler/worker/flower Pods | `[]`
`airflow.extraVolumes` | extra Volumes for the web/scheduler/worker/flower Pods | `[]`
`airflow.kubernetesPodTemplate.*` | configs to generate the AIRFLOW__KUBERNETES__POD_TEMPLATE_FILE | `<see values.yaml>`
`airflow.sync.*` | configs for the `airflow.{connections, pools, users, variables}` Deployments/Jobs | `<see values.yaml>`

<hr>
</details>

### `scheduler.*`
<details>
<summary>Expand</summary>
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

### `web.*`
<details>
<summary>Expand</summary>
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

### `workers.*`
<details>
<summary>Expand</summary>
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

### `flower.*`
<details>
<summary>Expand</summary>
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

### `logs.*`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`logs.path` | the airflow logs folder | `/opt/airflow/logs`
`logs.persistence.*` | configs for the logs PVC | `<see values.yaml>`

<hr>
</details>

### `dags.*`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`dags.path` | the airflow dags folder | `/opt/airflow/dags`
`dags.persistence.*` | configs for the dags PVC | `<see values.yaml>`
`dags.gitSync.*` | configs for the git-sync sidecar  | `<see values.yaml>`

<hr>
</details>

### `ingress.*`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`ingress.enabled` | if we should deploy Ingress resources | `false`
`ingress.web.*` | configs for the Ingress of the web Service | `<see values.yaml>`
`ingress.flower.*` | configs for the Ingress of the flower Service | `<see values.yaml>`

<hr>
</details>

### `rbac.*`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`rbac.create` | if Kubernetes RBAC resources are created | `true`
`rbac.events` | if the created RBAR role has GET/LIST access to Event resources | `false`

<hr>
</details>

### `serviceAccount.*`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`serviceAccount.create` | if a Kubernetes ServiceAccount is created | `true`
`serviceAccount.name` | the name of the ServiceAccount | `""`
`serviceAccount.annotations` | annotations for the ServiceAccount | `{}`

<hr>
</details>

### `extraManifests`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`extraManifests` | extra Kubernetes manifests to include alongside this chart | `[]`

<hr>
</details>

### `postgresql.*`
<details>
<summary>Expand</summary>
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

### `externalDatabase.*`
<details>
<summary>Expand</summary>
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

### `redis.*`
<details>
<summary>Expand</summary>
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

### `externalRedis.*`
<details>
<summary>Expand</summary>
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

### `serviceMonitor.*`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`serviceMonitor.enabled` | if ServiceMonitor resources should be deployed | `false`
`serviceMonitor.selector` | labels for ServiceMonitor, so that Prometheus can select it | `{ prometheus: "kube-prometheus" }`
`serviceMonitor.path` | the ServiceMonitor web endpoint path | `/admin/metrics`
`serviceMonitor.interval` | the ServiceMonitor web endpoint path | `30s`

<hr>
</details>

### `prometheusRule.*`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`prometheusRule.enabled` | if the PrometheusRule resources should be deployed | `false`
`prometheusRule.additionalLabels` | labels for PrometheusRule, so that Prometheus can select it | `{}`
`prometheusRule.groups` | alerting rules for Prometheus | `[]`

<hr>
</details>