# Upgrading Steps

## `v8.2.0` → `v8.3.0`

__The following IMPROVEMENTS have been made:__

* Added an ability set the maximum number of sync failures that the gitSync sidecar container will tolerate before exiting

__The following values have been ADDED:__

* `dags.gitSync.maxFailures`

## `v8.1.X` → `v8.2.0`


__The following values have been ADDED:__

* `externalRedis.properties`

## `v8.0.X` → `v8.1.0`

### VALUES - New:
- `airflow.kubernetesPodTemplate.resources`

## `v7.15.X` → `v8.0.0`

> 🛑️️ this is a MAJOR update, meaning there are BREAKING changes
> - you might want to start your `values.yaml` file again

> ⚠️ the default version of airflow has changed to `2.0.1`
> - check your dags [are compatible](https://airflow.apache.org/docs/apache-airflow/stable/upgrading-to-2.html#step-5-upgrade-airflow-dags)
> - note that you won't be able to downgrade your database back to `1.10.X` schema
> - the default version of python has changed to `3.8`

### Feature Highlights:
- native support for "KubernetesExecutor", and "CeleryKubernetesExecutor", see the new `airflow.kubernetesPodTemplate.*` values
- native support for "webserver_config.py", see the new `web.webserverConfig.*` values
- native support for [Airflow 2.0's HA scheduler](https://airflow.apache.org/docs/apache-airflow/stable/scheduler.html#running-more-than-one-scheduler), see the new `scheduler.replicas` value
- significantly improved git-sync system by moving to [kubernetes/git-sync](https://github.com/kubernetes/git-sync)
- significantly improved pip installs by moving to an init-container
- added a [guide for integrating airflow with your "Microsoft AD" or "OAUTH"](README.md#how-to-authenticate-airflow-users-with-ldapoauth)
- general cleanup of almost every helm file
- significant docs/README rewrite

### Other Features:
- added `airflow.users` to help you create/update airflow web users:
  - __WARNING:__ default settings create an admin user (user: __admin__ - password: __admin__), disable by setting `airflow.users` to `[]`
- added `airflow.connections` to help you create/update airflow connections:
- added `airflow.variables` to help you create/update airflow variables:
- added `airflow.pools` to help you create/update airflow pools:
- flower Pods are now affected by `airflow.extraPipPackages`, `airflow.extraContainers`, `airflow.extraVolumeMounts`, `airlfow.extraVolumes`  
- you no longer need to set `web.readinessProbe.scheme` or `web.livenessProbe.scheme`, we now only use HTTPS if `AIRFLOW__WEBSERVER__WEB_SERVER_SSL_CERT` and `AIRFLOW__WEBSERVER__WEB_SERVER_SSL_KEY` are set
- airflow db upgrades are now managed with a post "helm upgrade" Job, meaning it only runs once per upgrade (rather than each time the scheduler starts)

### Removed Features
- the `XXX.extraConfigmapMounts`, `XXX.secretsDir`, `XXX.secrets`, `XXX.secretsMap` values have been removed, and replaced with `XXX.extraVolumes` and `XXX.extraVolumeMounts`, which use typical Kubernetes volume-mount syntax
- the `dags.installRequirements` value has been removed, please instead use the `XXX.extraPipPackages` values, this change was made for two main reasons: 
  1. allowed us to move the pip-install commands into an init-container, which greatly simplifies pod-startup, and removes the need to set any kind of readiness-probe delay in Webserver/Flower Pods
  2. the installRequirements command only ran at Pod start up, meaning you would have to restart all your pods if you updated the `requirements.txt` in your git repo (which isn't very declarative)

### Known Issues:
- if you want to continue using airflow `1.10.X`, you must enable `airflow.legacyCommands`, but note that not all features of the chart will work (and there is no expectation of full support for `1.10.X`)
- if you were using `dags.persistence.enabled` but not explicitly setting `dags.persistence.existingClaim`, the name of the PVC will change (meaning your dags will disappear)
  - to fix this, set `dags.persistence.existingClaim` to the value of the previous dags PVC (which will be your Helm RELEASE_NAME)

### Recommendations:
- start your values.yaml from scratch (by looking at the new examples, and defaults)

### Request for Contributions:
- improvements for the docs
- any feature you need to get the chart running in your environment (NOTE: we won't always implement every feature proposed)
- replace the `postgresql` and `redis` sub-charts (currently declared in `requirements.yaml`) with straight YAML in this chart
- implement a system where `XXX.extraPipPackages` only requires a single installation after each "helm upgrade" (probably using Jobs and PersistentVolumeClaims)
   - This will be most beneficial for `airflow.kubernetesPodTemplate.extraPipPackages`, as those pip installs have to run for every task in "KubernetesExecutor" mode
- autoscaling using [KEDA](https://github.com/kedacore/keda) for the scheduler/worker replica counts (this will let us remove the largely useless HorizontalPodAutoscaler approach)

### VALUES - Changed Defaults:
- `rbac.events` = `true`
- `scheduler.livenessProbe.initialDelaySeconds` = `10`
- `web.readinessProbe.enabled` = `true`
- `web.readinessProbe.timeoutSeconds` = `5`
- `web.livenessProbe.periodSeconds` = `10`
- `web.readinessProbe.failureThreshold` = `6`
- `web.livenessProbe.initialDelaySeconds` = `10`
- `web.livenessProbe.timeoutSeconds` = `5`
- `web.livenessProbe.failureThreshold` = `6`
- `scheduler.podDisruptionBudget.enabled` = `false`

### VALUES - New:
- `airflow.legacyCommands`
- `airflow.image.uid`
- `airflow.image.gid`
- `airflow.users`
- `airflow.usersUpdate`
- `airflow.connections`
- `airflow.connectionsUpdate`
- `airflow.variables`
- `airflow.variablesUpdate`
- `airflow.pools`
- `airflow.poolsUpdate`
- `airflow.kubernetesPodTemplate.stringOverride`
- `airflow.kubernetesPodTemplate.nodeSelector`
- `airflow.kubernetesPodTemplate.affinity`
- `airflow.kubernetesPodTemplate.tolerations`
- `airflow.kubernetesPodTemplate.podAnnotations`
- `airflow.kubernetesPodTemplate.securityContext`
- `airflow.kubernetesPodTemplate.extraPipPackages`
- `airflow.kubernetesPodTemplate.extraVolumeMounts`
- `airflow.kubernetesPodTemplate.extraVolumes`
- `scheduler.replicas`
- `scheduler.livenessProbe.timeoutSeconds`
- `scheduler.extraPipPackages`
- `scheduler.extraVolumeMounts`
- `scheduler.extraVolumes`
- `web.webserverConfig.stringOverride`
- `web.webserverConfig.existingSecret`
- `web.extraVolumeMounts`
- `web.extraVolumes`
- `workers.extraPipPackages`
- `workers.extraVolumeMounts`
- `workers.extraVolumes`
- `flower.readinessProbe.enabled`
- `flower.readinessProbe.initialDelaySeconds`
- `flower.readinessProbe.periodSeconds`
- `flower.readinessProbe.timeoutSeconds`
- `flower.readinessProbe.failureThreshold`
- `flower.livenessProbe.enabled`
- `flower.livenessProbe.initialDelaySeconds`
- `flower.livenessProbe.periodSeconds`
- `flower.livenessProbe.timeoutSeconds`
- `flower.livenessProbe.failureThreshold`
- `flower.extraPipPackages`
- `flower.extraVolumeMounts`
- `flower.extraVolumes`
- `dags.gitSync.enabled`
- `dags.gitSync.image.repository`
- `dags.gitSync.image.tag`
- `dags.gitSync.image.pullPolicy`
- `dags.gitSync.image.uid`
- `dags.gitSync.image.gid`
- `dags.gitSync.resources`
- `dags.gitSync.repo`
- `dags.gitSync.repoSubPath`
- `dags.gitSync.branch`
- `dags.gitSync.revision`
- `dags.gitSync.depth`
- `dags.gitSync.syncWait`
- `dags.gitSync.syncTimeout`
- `dags.gitSync.httpSecret`
- `dags.gitSync.httpSecretUsernameKey`
- `dags.gitSync.httpSecretPasswordKey`
- `dags.gitSync.sshSecret`
- `dags.gitSync.sshSecretKey`
- `dags.gitSync.sshKnownHosts`
  
### VALUES - Removed:
- `airflow.extraConfigmapMounts`
- `scheduler.initialStartupDelay`
- `scheduler.preinitdb`
- `scheduler.initdb`
- `scheduler.connections`
- `scheduler.refreshConnections`
- `scheduler.existingSecretConnections`
- `scheduler.pools`
- `scheduler.variables`
- `scheduler.secretsDir`
- `scheduler.secrets`
- `scheduler.secretsMap`
- `web.initialStartupDelay`
- `web.minReadySeconds`
- `web.baseUrl`
- `web.serializeDAGs`
- `web.readinessProbe.scheme`
- `web.readinessProbe.successThreshold`
- `web.livenessProbe.scheme`
- `web.livenessProbe.successThreshold`
- `web.secretsDir`
- `web.secrets`
- `web.secretsMap`
- `workers.celery.instances`
- `workers.initialStartupDelay`
- `workers.secretsDir`
- `workers.secrets`
- `workers.secretsMap`
- `flower.initialStartupDelay`
- `flower.minReadySeconds`
- `flower.extraConfigmapMounts`
- `flower.urlPrefix`
- `flower.secretsDir`
- `flower.secrets`
- `flower.secretsMap`
- `dags.doNotPickle`
- `dags.installRequirements`
- `dags.git.url`
- `dags.git.ref`
- `dags.git.secret`
- `dags.git.sshKeyscan`
- `dags.git.privateKeyName`
- `dags.git.repoHost`
- `dags.git.repoPort`
- `dags.git.gitSync.enabled`
- `dags.git.gitSync.resources`
- `dags.git.gitSync.image`
- `dags.git.gitSync.refreshTime`
- `dags.git.gitSync.mountPath`
- `dags.git.gitSync.syncSubPath`
- `dags.initContainer.enabled`
- `dags.initContainer.resources`
- `dags.initContainer.image.repository`
- `dags.initContainer.image.tag`
- `dags.initContainer.image.pullPolicy`
- `dags.initContainer.mountPath`
- `dags.initContainer.syncSubPath`
- `ingress.web.livenessPath`
- `ingress.flower.livenessPath`

## `v7.14.X` → `v7.15.0`

__The following IMPROVEMENTS have been made:__
* We now use `airflow upgradedb || airflow db upgrade` instead of `airflow initdb` with the following values:
    * `scheduler.initdb`
    * `scheduler.preinitdb`

__The following values have CHANGED DEFAULTS:__
* `dags.git.gitSync.image.pullPolicy`
    * Is now `IfNotPresent` by default
* `dags.initContainer.image.pullPolicy`
    * Is now `IfNotPresent` by default

## `v7.13.X` → `v7.14.0`

> ⚠️ WARNING
> 
> We migrated to the [airflow-helm/charts](https://github.com/airflow-helm/charts) repo, after the deprecation of the [helm/charts](https://github.com/helm/charts/) repo.

__There were NO CHANGES in this version__

## `v7.12.X` → `v7.13.0`

__The following values have been ADDED:__
* `flower.oauthDomains`

## `v7.11.X` → `v7.12.0`

__The following values have been ADDED:__
* `ingress.web.labels`
* `ingress.flower.labels`
* `ingress.flower.precedingPaths`
* `ingress.flower.succeedingPaths`

## `v7.10.X` → `v7.11.0`

__The following IMPROVEMENTS have been made:__
* You can now use `scheduler.existingSecretConnections` with an externally created Secret to store airflow connections. 
  (Rather than storing them in plain-text with `scheduler.connections`)

__The following values have been ADDED:__
* `scheduler.existingSecretConnections`

## `v7.9.X` → `v7.10.0`

__The following IMPROVEMENTS have been made:__
* We now make use of the `_CMD` variables for `AIRFLOW__CORE__SQL_ALCHEMY_CONN_CMD`, `AIRFLOW__CELERY__RESULT_BACKEND_CMD`, and `AIRFLOW__CELERY__BROKER_URL_CMD`:
  * This fixes the Scheduler liveness probe implemented in `7.8.0`
  * This fixes using `kubectl exec` to run commands like `airflow create_user`
* Configs passed with `airflow.config` are now passed as-defined in your `values.yaml`:
  * This fixes an issue where people had to escape `"` characters in JSON strings

## `v7.8.X` → `v7.9.0`

__The following IMPROVEMENTS have been made:__

* You can now give the airflow ServiceAccount GET/LIST on Event resources
    * This is needed for `KubernetesPodOperator(log_events_on_failure=True)`
    * To enable, set `rbac.events` to `true` (Default: `false`)

__The following values have been ADDED:__
* `rbac.events`

## `v7.7.X` → `v7.8.0`

> ⚠️ WARNING 
>
> If you install many pip packages with: `airflow.extraPipPackages`, `web.extraPipPackages`, or `dags.installRequirements`
> 
> Ensure you set `scheduler.livenessProbe.initialDelaySeconds` to longer than the install time
>

__The following IMPROVEMENTS have been made:__
* Upgraded to Airflow: `1.10.12`
* The scheduler now has a liveness probe which will force the pod to restart if it becomes unhealthy for more than some threshold of time (default: 150sec)
  * NOTE: this is on by default, but can be disabled with: `scheduler.livenessProbe.enabled`

__The following values have been ADDED:__
* `scheduler.livenessProbe.enabled`
* `scheduler.livenessProbe.initialDelaySeconds`
* `scheduler.livenessProbe.periodSeconds`
* `scheduler.livenessProbe.failureThreshold`

## `v7.6.X` → `v7.7.0`

__If you are using an INTERNAL redis database, some configs have changed:__

| 7.6.x | 7.7.x | Notes |
| --- | --- | ---|
| `redis.existingSecretKey` | `redis.existingSecretPasswordKey` | Changed to align with [stable/redis](https://github.com/helm/charts/tree/master/stable/redis) |

## `v7.5.X` → `v7.6.0`

> ⚠️ WARNING
>
> We now annotate all pods with `cluster-autoscaler.kubernetes.io/safe-to-evict` by default.
> 
> If you want to disable this:
>  - Set: `flower.safeToEvict`, `scheduler.safeToEvict`, `web.safeToEvict`, `workers.safeToEvict` to `false`
>  - Set: `postgresql.master.podAnnotations`, `redis.master.podAnnotations`, `redis.slave.podAnnotations` to `{}`
>
> Note for GKE:
>  - GKE's cluster-autoscaler will not honor a `gracefulTerminationPeriod` of more than 10min,
>    if your jobs need more than this amount of time to finish, please set `workers.safeToEvict` to `false`
> 

__The following IMPROVEMENTS have been made:__
* The chart YAML has been refactored
* You can now configure `safe-to-evict` annotations (so that pods with emptyDir Volumes can be evicted by cluster-autoscaler)
* You can now create PodDisruptionBudgets for all components: {flower, webserver, worker}
* The chart now forces the correct ports to be used (NOTE: this will not prevent you changing Service/Ingress ports)
* You can now run multiple instances of flower
* You can now specify minReadySeconds for flower

__The following values have CHANGED DEFAULTS:__
* `postgresql.master.podAnnotations`:
    * Is now `{"cluster-autoscaler.kubernetes.io/safe-to-evict": "true"}`
* `redis.master.podAnnotations`:
    * Is now `{"cluster-autoscaler.kubernetes.io/safe-to-evict": "true"}`
* `redis.slave.podAnnotations`:
    * Is now `{"cluster-autoscaler.kubernetes.io/safe-to-evict": "true"}`

__The following values have been ADDED:__
* `flower.minReadySeconds`
* `flower.podDisruptionBudget.*`
* `flower.replicas`
* `flower.safeToEvict`
* `scheduler.safeToEvict`
* `web.podDisruptionBudget.*`
* `web.safeToEvict`
* `workers.podDisruptionBudget.*`
* `workers.safeToEvict`

## `v7.4.X` → `v7.5.0`

__The following IMPROVEMENTS have been made:__

* Added an ability to setup external database connection propertites with the value `externalDatabase.properties` for TLS or other advanced parameters

__The following values have been ADDED:__

* `externalDatabase.properties`

## `v7.3.X` → `v7.4.0`

__The following IMPROVEMENTS have been made:__

* Reduced how likely it is for a celery worker to receive SIGKILL with graceful termination enabled.
  New celery worker graceful shutdown lifecycle:
    1. prevent worker accepting new tasks
    2. wait AT MOST `workers.celery.gracefullTerminationPeriod` for tasks to finish
    3. send `SIGTERM` to worker
    4. wait AT MOST `workers.terminationPeriod` for kill to finish
    5. send `SIGKILL` to worker

__The following values have been ADDED:__

* `workers.celery.gracefullTerminationPeriod`:
    * if you currently use a high value of `workers.terminationPeriod`, consider lowering it to `60` and setting a high value for `workers.celery.gracefullTerminationPeriod`

## `v7.2.X` → `v7.3.0`

__The following IMPROVEMENTS have been made:__

* Added an ability to specify a specific port for Flower when using NodePort service type with the value `flower.service.nodePort.http`

__The following values have been ADDED:__

* `flower.service.nodePort.http`

## `v7.1.X` → `v7.2.0`

__The following IMPROVEMENTS have been made:__

* Fixed Flower's liveness probe when Basic Authentication is enabled for Flower.
  You can specify a basic auth value via a Kubernetes Secret using the values `flower.basicAuthSecret` and `flower.basicAuthSecretKey`.
  The secret value will get encoded and included in the liveness probe's header.

__The following values have been ADDED:__

* `flower.basicAuthSecret`
* `flower.basicAuthSecretKey`

## `v7.0.X` → `v7.1.0`

__The following IMPROVEMENTS have been made:__

* We have dramatically reduced the start time of airflow pods.
  This was mostly achieved by removing arbitrary delays in the start commands for airflow pods.
  If you still want these delays, please set the added `*.initialStartupDelay` to non-zero values.
* We have improved support for when `airflow.executor` is set to `KubernetesExecutor`:
    * redis configs/components are no longer deployed
    * we now set `AIRFLOW__KUBERNETES__NAMESPACE`, `AIRFLOW__KUBERNETES__WORKER_SERVICE_ACCOUNT_NAME`, and `AIRFLOW__KUBERNETES__ENV_FROM_CONFIGMAP_REF`
* We have fixed an error caused by including a `'` in your redis/postgres/mysql password.
* We have reverted a change in 7.0.0 which prevented the use of airflow docker images with embedded DAGs. 
  (Just ensure that `dags.initContainer.enabled` and `git.gitSync.enabled` are `false`)
* The `AIRFLOW__CORE__SQL_ALCHEMY_CONN`, `AIRFLOW__CELERY__RESULT_BACKEND`, and `AIRFLOW__CELERY__BROKER_URL` environment variables are now available if you `kubectl exec ...` into airflow Pods.
* We have improved the script used when `workers.celery.gracefullTermination` is `true`.
* We have fixed an error with pools in `scheduler.pools` not being added to the scheduler.
* We have fixed an error with the `scheduler.preinitdb` container not knowing the database connection string.

__The following values have CHANGED DEFAULTS:__

* `airflow.fernetKey`:
    * ~~Is now `""` by default, to enforce that users generate a custom one.~~
      ~~(However, please consider using `airflow.extraEnv` to define it from a pre-created secret)~~
      __(We have undone this change in `7.1.1`, but we still encourage you to set a custom fernetKey!)__
* `dags.installRequirements`:
    * Is now `false` by default, as this was an unintended change with the 7.0.0 upgrade.

__The following values have been ADDED:__

* `scheduler.initialStartupDelay`
* `workers.initialStartupDelay`
* `flower.initialStartupDelay`
* `web.readinessProbe.enabled`
* `web.livenessProbe.enabled`

## `v6.X.X` → `v7.0.0`

> ⚠️ WARNING
>
> You MUST stop using images derived from `puckel/docker-airflow` and instead derive from `apache/airflow`

This version updates to Airflow 1.10.10, and moves to the official Airflow Docker images.
Due to the size of these changes, it may be easier to create a new [values.yaml](values.yaml), starting from the one in this repo.

__The official image has a new `AIRFLOW_HOME`, you must change any references in your custom `values.yaml`:__

| Variable | 6.x.x | 7.x.x |
| --- | --- | --- | 
| `AIRFLOW_HOME` | `/usr/local/airflow` | `/opt/airflow` | 
| `dags.path` | `/usr/local/airflow/dags` | `/opt/airflow/dags` | 
| `logs.path` | `/usr/local/airflow/logs` | `/opt/airflow/logs` | 

__These internal mount paths have moved, you must update any references:__

| 6.x.x | 7.x.x |
| --- | --- |
| `/usr/local/git` | `/home/airflow/git` |
| `/usr/local/scripts` | `/home/airflow/scripts` |
| `/usr/local/connections` | `/home/airflow/connections` |
| `/usr/local/variables-pools` | `/home/airflow/variables-pools` |
| `/usr/local/airflow/.local` | `/home/airflow/.local` |

__The following values have been MOVED:__

| 6.x.x | 7.x.x |
| --- | --- |
| `airflow.podDisruptionBudgetEnabled` | `scheduler.podDisruptionBudget.enabled` |
| `airflow.podDisruptionBudget.maxUnavailable` | `scheduler.podDisruptionBudget.maxUnavailable` |
| `airflow.podDisruptionBudget.minAvailable` | `scheduler.podDisruptionBudget.minAvailable` |
| `airflow.webReplicas` | `web.replicas` |
| `airflow.initdb` | `scheduler.initdb` |
| `airflow.preinitdb` | `scheduler.preinitdb` |
| `airflow.extraInitContainers` | `scheduler.extraInitContainers` |
| `airflow.schedulerNumRuns` | `scheduler.numRuns` |
| `airflow.connections` | `scheduler.connections` |
| `airflow.variables` | `scheduler.variables` |
| `airflow.pools` | `scheduler.pools` |
| `airflow.service.*` | `web.service.*` |
| `dags.initContainer.installRequirements` | `dags.installRequirements` |
| `logsPersistence.*` | `logs.persistence.*` |
| `persistence.*` | `dags.persistence.*` |

__If you are using an EXTERNAL postgres database, some configs have changed:__

| 6.x.x | 7.x.x | Notes |
| --- | --- | ---|
| `N/A` | `externalDatabase.type` | can choose `mysql` or `postgres` |
| `postgresql.postgresHost` | `externalDatabase.host` | |
| `postgresql.service.port` | `externalDatabase.port` | we no longer support changing the port of the embedded postgresql chart |
| `postgresql.postgresqlDatabase` | `externalDatabase.database` | |
| `postgresql.postgresqlUsername` | `externalDatabase.user` | |
| `postgresql.postgresqlPassword` | `N/A` | we don't support storing external database passwords in plain text |
| `postgresql.existingSecret` | `externalDatabase.passwordSecret` | |
| `postgresql.existingSecretKey` | `externalDatabase.passwordSecretKey` | |

__If you are using an EXTERNAL redis database, some configs have changed:__

| 6.x.x | 7.x.x | Notes |
| --- | --- | ---|
| `redis.redisHost` | `externalRedis.host` | |
| `redis.master.service.port` | `externalRedis.port` | we no longer support changing the port of the embedded redis chart |
| `redis.password` | `N/A` | we don't support storing external redis passwords in plain text |
| `N/A` | `externalRedis.databaseNumber` | changing the database number was not previously supported |
| `redis.existingSecret` | `externalRedis.passwordSecret` | |
| `redis.existingSecretKey` | `externalRedis.passwordSecretKey` | |


__The following values have been SPLIT:__

* `web.initialDelaySeconds`:
  * --> `web.readinessProbe.initialDelaySeconds`
  * --> `web.livenessProbe.initialDelaySeconds`

__The following values have CHANGED BEHAVIOUR:__

* `airflow.executor`:
  * Previously you specified the executor name without the `Executor` suffix, now you must include it.
  * For example: `Celery` --> `CeleryExecutor`
* `airflow.fernetKey`:
  * Previously if omitted, this would be generated for you, we now have a default value, which we STRONGLY ENCOURAGE you to change.
  * Also note, you should consider using `airflow.extraEnv` to prevent this value being stored in your `values.yaml`
* `dags.installRequirements`:
  * Previously, `dags.installRequirements` only worked if `dags.initContainer.enabled` was true, now it will work regardless of other settings.

__The following values have NEW DEFAULTS:__
* `dags.persistence.accessMode`:
  * `ReadWriteOnce` --> `ReadOnlyMany`
* `logs.persistence.accessMode`:
  * `ReadWriteOnce` --> `ReadWriteMany`

__The following values have been REMOVED:__

* `postgresql.service.port`:
  * As there is no reason to change the port of the embedded postgresql, and we have separated the external database configs. 
* `redis.master.service.port`:
  * As there is no reason to change the port of the embedded redis, and we have separated the external redis configs. 

__The following values have been ADDED:__

* `airflow.extraPipPackages`:
  * Allows extra pip packages to be installed in the airflow-web/scheduler/worker containers.
* `web.extraPipPackages`:
  * Allows extra pip packages to be installed in the airflow-web container only.

__Other changes:__

* Special characters will now be correctly encoded in passwords for postgres/mysql/redis.

## `v5.X.X` → `v6.0.0`

This version updates `postgresql` and `redis` dependencies.

__Thee following values have CHANGED:__

| 5.x.x | 6.x.x | Notes |
| --- | --- | ---|
|`postgresql.postgresHost` |`postgresql.postgresqlHost` | |
|`postgresql.postgresUser` |`postgresql.postgresqlUsername` | |
|`postgresql.postgresPassword` |`postgresql.postgresqlPassword` | |
|`postgresql.postgresDatabase` |`postgresql.postgresqlDatabase` | |
|`postgresql.persistence.accessMode` |`postgresql.persistence.accessModes` | Instead of a single value, now the config accepts an array |
|`redis.master.persistence.accessMode` |`redis.master.persistence.accessModes` | Instead of a single value, now the config accepts an array |

## `v4.X.X` → `v5.0.0`

> ⚠️ WARNING
>
> This upgrade will fail if a custom ingress path is set for web and/or flower and `web.baseUrl` and/or `flower.urlPrefix`

This version splits the configuration for webserver and flower web UI from Ingress configurations, for separation of concerns.

__The following values have been ADDED:__

* `web.baseUrl`
* `flower.urlPrefix`

## `v3.X.X` → `v4.0.0`

This version splits the specs for the NodeSelector, Affinity and Toleration features.
Instead of being global, and injected in every component, they are now defined _by component_ to provide more flexibility for your deployments. 
As such, the migration steps are really simple, just ust copy and paste your node/affinity/tolerance definitions in the four airflow components, which are `worker`, `scheduler`, `flower` and `web`. 
The default `values.yaml` file should help you with locating those.
