<h1 align="center">Airflow Helm Chart (User Community)</h1>

<br>

<p align="center">
  The <code>User-Community Airflow Helm Chart</code> is the standard way to deploy <a href="https://airflow.apache.org/">Apache Airflow</a> on <a href="https://kubernetes.io/">Kubernetes</a> with <a href="https://helm.sh/">Helm</a>.
  <br>
  Originally created in 2018, it has since helped thousands of companies create production-ready deployments of Airflow on Kubernetes.
</p>

<p align="center">
  <a href="https://github.com/airflow-helm/charts/releases">
    <img alt="Downloads" src="https://img.shields.io/github/downloads/airflow-helm/charts/total?style=flat-square&color=28a745">
  </a>
  <a href="https://github.com/airflow-helm/charts/graphs/contributors">
    <img alt="Contributors" src="https://img.shields.io/github/contributors/airflow-helm/charts?style=flat-square&color=28a745">
  </a>
  <a href="https://github.com/airflow-helm/charts/blob/main/LICENSE">
    <img alt="License" src="https://img.shields.io/github/license/airflow-helm/charts?style=flat-square&color=28a745">
  </a>
  <a href="https://github.com/airflow-helm/charts/releases">
    <img alt="Latest Release" src="https://img.shields.io/github/v/release/airflow-helm/charts?style=flat-square&color=6f42c1&label=latest%20release">
  </a>
  <a href="https://artifacthub.io/packages/helm/airflow-helm/airflow">
    <img alt="ArtifactHub" src="https://img.shields.io/static/v1?style=flat-square&color=417598&logo=artifacthub&label=ArtifactHub&message=airflow-helm">
  </a>
</p>

<p align="center">
  <a href="https://github.com/airflow-helm/charts/stargazers">
    <img alt="GitHub Stars" src="https://img.shields.io/github/stars/airflow-helm/charts?style=for-the-badge&color=ffcb2f&label=Support%20with%20%E2%AD%90%20on%20GitHub">
  </a>
  <a href="https://artifacthub.io/packages/helm/airflow-helm/airflow">
    <img alt="ArtifactHub Stars" src="https://img.shields.io/badge/dynamic/json?style=for-the-badge&color=ffcb2f&label=Support%20with%20%E2%AD%90%20on%20ArtifactHub&query=stars&url=https://artifacthub.io/api/v1/packages/af52c9e8-afa6-4443-952f-3d4d17e3be35/stars">
  </a>
</p>

<p align="center">
  <a href="https://github.com/airflow-helm/charts/discussions">
    <img alt="GitHub Discussions" src="https://img.shields.io/github/discussions/airflow-helm/charts?style=for-the-badge&color=17a2b8&label=Start%20a%20Discussion">
  </a>
  <a href="https://github.com/airflow-helm/charts/issues/new/choose">
    <img alt="GitHub Issues" src="https://img.shields.io/github/issues/airflow-helm/charts?style=for-the-badge&color=17a2b8&label=Open%20an%20Issue">
  </a>
</p>

<br>

## History

This project is independent from the official chart found in the `apache/airflow` GitHub repository, 
and was previously known as `stable/airflow` when it was developed in the `helm/charts` GitHub repository.

## Project Goals

1. Ease of Use
2. Great Documentation
3. Support for older Airflow Versions
4. Support for Kubernetes GitOps Tools (like ArgoCD)

## Key Features

- __Support for Airflow Versions:__ 
   - [`1.10` | `2.0` | `2.1` | `2.2` | `2.3`](#airflow-version-support)
- __Support for Airflow Executors:__ 
   - [`CeleryExecutor` | `KubernetesExecutor` | `CeleryKubernetesExecutor`](#airflow-executor-support)
- __Easily Connect with your Database:__
   - [`Connect to Postgres`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/database/external-database.md#option-1---postgres) |
     [`Configure PgBouncer`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/database/pgbouncer.md) |
     [`Connect to MySQL`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/database/external-database.md#option-2---mysql)
- __Declaratively Manage Airflow Configs:__
   - [`Users`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/security/airflow-users.md) |
     [`Connections`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/dags/airflow-connections.md) |
     [`Variables`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/dags/airflow-variables.md) |
     [`Pools`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/dags/airflow-pools.md)
- __Load Airflow DAGs:__
   - [`Load from Git-Sync`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/dags/load-dag-definitions.md#option-1---git-sync-sidecar) |
     [`Load from Volume`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/dags/load-dag-definitions.md#option-2---persistent-volume-claim) |
     [`Embed Into Image`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/dags/load-dag-definitions.md#option-3---embedded-into-container-image)
- __Manage Airflow Logs:__
   - [`Persist on Volume`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/monitoring/log-persistence.md#option-1---persistent-volume-claim) |
     [`Persist on Remote Provider`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/monitoring/log-persistence.md#option-2---remote-providers) |
     [`Automatic Log Cleanup`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/monitoring/log-cleanup.md)
- __Install Extra Python Packages:__
   - [`Install with Init-Containers`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/configuration/extra-python-packages.md#option-1---init-containers) |
     [`Embed Into Image`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/configuration/extra-python-packages.md#option-2---embedded-into-container-image)
- __Automatically Restart Unhealthy Airflow Schedulers:__
   - [`Heartbeat Check`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/monitoring/scheduler-liveness-probe.md#scheduler-heartbeat-check) |
     [`Task Creation Check`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/monitoring/scheduler-liveness-probe.md#scheduler-task-creation-check)

<br>

## Guides

#### [`Quickstart Guide`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/guides/quickstart.md) <sup><sub>⭐</sub></sup> <a id="quickstart-guide"></a>

#### [`Upgrade Guide`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/guides/upgrade.md) <sup><sub>⭐</sub></sup> <a id="upgrade"></a>

#### [`Uninstall Guide`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/guides/uninstall.md) <a id="uninstall"></a>

## Frequently Asked Questions

- __Configuration:__
  - [`Set Airflow Version`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/configuration/airflow-version.md) <sup><sub>⭐</sub></sup> <a id="how-to-use-a-specific-version-of-airflow"></a>
  - [`Manage Airflow Configs`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/configuration/airflow-configs.md) <sup><sub>⭐</sub></sup> <a id="how-to-set-airflow-configs"></a>
  - [`Manage Airflow Plugins`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/configuration/airflow-plugins.md)
  - [`Install Extra Python/Pip Packages`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/configuration/extra-python-packages.md) <a id="how-to-install-extra-pip-packages"></a>
  - [`Configure Celery Worker Autoscaling`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/configuration/autoscaling-celery-workers.md) <a id="how-to-set-up-celery-worker-autoscaling"></a>
- __DAGs:__
  - [`Load Airflow DAGs`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/dags/load-dag-definitions.md) <sup><sub>⭐</sub></sup> <a id="how-to-store-dags"></a>
  - [`Manage Airflow Connections`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/dags/airflow-connections.md) <sup><sub>⭐</sub></sup> <a id="how-to-create-airflow-connections"></a>
  - [`Manage Airflow Variables`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/dags/airflow-variables.md) <a id="how-to-create-airflow-variables"></a>
  - [`Manage Airflow Pools`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/dags/airflow-pools.md) <a id="how-to-create-airflow-pools"></a>
- __Security:__
  - [`Manage Airflow Users`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/security/airflow-users.md) <sup><sub>⭐</sub></sup> <a id="how-to-create-airflow-users"></a>
  - [`Integrate Airflow with LDAP or OAUTH`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/security/ldap-oauth.md) <a id="how-to-authenticate-airflow-users-with-ldapoauth"></a>
  - [`Set Airflow Fernet Encryption Key`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/security/set-fernet-key.md) <a id="how-to-set-a-custom-fernet-encryption-key"></a>
  - [`Set Airflow Webserver Secret Key`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/security/set-webserver-secret-key.md) <a id="how-to-set-a-custom-webserver-secret_key"></a>
- __Monitoring:__
  - [`Manage Airflow Logs`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/monitoring/log-persistence.md) <sup><sub>⭐</sub></sup> <a id="how-to-persist-airflow-logs"></a>
  - [`Manage Airflow Logs Cleanup`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/monitoring/log-cleanup.md)
  - [`Configure Scheduler Liveness Probe`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/monitoring/scheduler-liveness-probe.md) <a id="how-to-configure-the-scheduler-liveness-probe"></a>
  - [`Integrate Airflow with Prometheus`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/monitoring/prometheus.md) <a id="how-to-integrate-airflow-with-prometheus"></a>
- __Databases:__
  - [`Configure Database (Built-In)`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/database/embedded-database.md) <a id="how-to-use-the-embedded-postgres"></a>
  - [`Configure Database (External)`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/database/external-database.md) <sup><sub>⭐</sub></sup> <a id="how-to-use-an-external-database"></a>
  - [`Configure PgBouncer`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/database/pgbouncer.md)
  - [`Configure Redis (Built-In)`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/database/embedded-redis.md)
  - [`Configure Redis (External)`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/database/external-redis.md) <sup><sub>⭐</sub></sup> <a id="how-to-use-an-external-redis"></a>
- __Kubernetes:__
  - [`Configure Kubernetes Ingress`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/kubernetes/ingress.md) <sup><sub>⭐</sub></sup> <a id="how-to-set-up-an-ingress"></a>
  - [`Mount Extra Persistent Volumes`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/kubernetes/mount-persistent-volumes.md) <sup><sub>⭐</sub></sup>
  - [`Mount Files from Secrets/ConfigMaps`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/kubernetes/mount-files.md) <a id="how-to-mount-secretsconfigmaps-as-files-on-workers"></a>
  - [`Mount Environment Variables from Secrets/ConfigMaps`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/kubernetes/mount-environment-variables.md) <a id="how-to-create-airflow-variables"></a>
  - [`Configure Pod Affinity/Selectors/Tolerations`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/kubernetes/affinity-node-selectors-tolerations.md) <a id="how-to-use-pod-affinity-nodeselector-and-tolerations"></a>
  - [`Include Extra Kubernetes Manifests`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/kubernetes/extra-manifests.md) <a id="how-to-add-extra-manifests"></a>

## Examples

- __Custom Values Starting Points:__
  - [`CeleryExecutor`](sample-values-CeleryExecutor.yaml)
  - [`KubernetesExecutor`](sample-values-KubernetesExecutor.yaml)
  - [`CeleryKubernetesExecutor`](sample-values-CeleryKubernetesExecutor.yaml)
- __Real-World Examples:__
  - [`Minikube / Kind / K3D`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/examples/minikube)
  - [`Google Kubernetes Engine (GKE)`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/examples/google-gke)

<br>

## Airflow Version Support

The following table lists the __airflow versions__ supported by this chart (set by [`airflow.image.tag`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/docs/faq/configuration/airflow-version.md) value).

Chart Version → <br> Airflow Version ↓  | `7.0.0` - `7.16.0` | `8.0.0` - `8.5.3` | `8.6.0` | `8.6.1+` |
--- | --- | --- | --- | ---
`1.10.X` | ✔️ | ✔️ <sub>[1]</sub> | ✔️️ <sub>[1]</sub> | ✔️️ <sub>[1]</sub>
`2.0.X` | ❌ | ✔️ | ✔️ | ✔️
`2.1.X` | ❌ | ✔️ | ✔️ | ✔️
`2.2.X` | ❌ | ⚠️ <sub>[2]</sub> | ✔️️ | ✔️
`2.3.X` | ❌ | ❌ | ❌ | ✔️️

<sub>[1] you must set `airflow.legacyCommands = true` when using airflow version `1.10.X`</sub><br>
<sub>[2] the [Deferrable Operators & Triggers](https://airflow.apache.org/docs/apache-airflow/stable/concepts/deferring.html) feature won't work, as there is no `airflow triggerer` Deployment</sub>

## Airflow Executor Support

The following table lists the [__airflow executors__](https://airflow.apache.org/docs/apache-airflow/stable/executor/index.html) supported by this chart (set by `airflow.executor` value).

Chart Version → <br> Airflow Executor ↓ | `7.X.X` | `8.X.X` | 
--- | --- | ---
`CeleryExecutor` | ✔️ | ✔️
`KubernetesExecutor` | ⚠️️ <sub>[1]</sub> | ✔️
`CeleryKubernetesExecutor` | ❌ | ✔️

<sub>[1] we encourage you to use chart version `8.X.X`, so you can use the `airflow.kubernetesPodTemplate.*` values (requires airflow `1.10.11+`) </sub>

## Helm Values

The following is a summary of the __helm values__ provided by this chart (see full list in [`values.yaml`](https://github.com/airflow-helm/charts/tree/main/charts/airflow/values.yaml) file).

> click the `▶` symbol to expand

<details>
<summary><code>airflow.*</code></summary>

Parameter | Description | Default
--- | --- | ---
`airflow.legacyCommands` | if we use legacy 1.10 airflow commands | `false`
`airflow.image.*` | configs for the airflow container image | `<see values.yaml>`
`airflow.executor` | the airflow executor type to use | `CeleryExecutor`
`airflow.fernetKey` | the fernet encryption key (sets `AIRFLOW__CORE__FERNET_KEY`) | `7T512UXSSmBOkpWimFHIVb8jK6lfmSAvx4mO6Arehnc=`
`airflow.webserverSecretKey` | the secret_key for flask (sets `AIRFLOW__WEBSERVER__SECRET_KEY`) | `THIS IS UNSAFE!`
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
`airflow.defaultNodeSelector` | default nodeSelector for airflow Pods (is overridden by pod-specific values) | `{}`
`airflow.defaultAffinity` | default affinity configs for airflow Pods (is overridden by pod-specific values) | `{}`
`airflow.defaultTolerations` | default toleration configs for airflow Pods (is overridden by pod-specific values) | `[]`
`airflow.defaultSecurityContext` | default securityContext configs for Pods (is overridden by pod-specific values) | `{fsGroup: 0}`
`airflow.podAnnotations` | extra annotations for airflow Pods | `{}`
`airflow.extraPipPackages` | extra pip packages to install in airflow Pods | `[]`
`airflow.protectedPipPackages` | pip packages that are protected from upgrade/downgrade by `extraPipPackages` | `["apache-airflow"]`
`airflow.extraEnv` | extra environment variables for the airflow Pods | `[]`
`airflow.extraContainers` | extra containers for the airflow Pods | `[]`
`airflow.extraVolumeMounts` | extra VolumeMounts for the airflow Pods | `[]`
`airflow.extraVolumes` | extra Volumes for the airflow Pods | `[]`
`airflow.clusterDomain` | kubernetes cluster domain name | `cluster.local`
`airflow.localSettings.*` | airflow_local_settings.py | `<see values.yaml>`
`airflow.kubernetesPodTemplate.*` | pod_template.yaml | `<see values.yaml>`
`airflow.dbMigrations.*` | db-migrations Deployment | `<see values.yaml>`
`airflow.sync.*` | Sync Deployments | `<see values.yaml>`

<hr>
</details>

<details>
<summary><code>scheduler.*</code></summary>

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
`scheduler.logCleanup.*` | configs for the log-cleanup sidecar of the scheduler | `<see values.yaml>`
`scheduler.numRuns` | the value of the `airflow --num_runs` parameter used to run the airflow scheduler | `-1`
`scheduler.extraPipPackages` | extra pip packages to install in the scheduler Pods | `[]`
`scheduler.extraVolumeMounts` | extra VolumeMounts for the scheduler Pods | `[]`
`scheduler.extraVolumes` | extra Volumes for the scheduler Pods | `[]`
`scheduler.livenessProbe.*` | configs for the scheduler Pods' liveness probe | `<see values.yaml>`
`scheduler.extraInitContainers` | extra init containers to run in the scheduler Pods | `[]`

</details>

<details>
<summary><code>web.*</code></summary>

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

</details>

<details>
<summary><code>workers.*</code></summary>

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
`workers.logCleanup.*` | configs for the log-cleanup sidecar of the worker Pods | `<see values.yaml>`
`workers.extraPipPackages` | extra pip packages to install in the worker Pods | `[]`
`workers.extraVolumeMounts` | extra VolumeMounts for the worker Pods | `[]`
`workers.extraVolumes` | extra Volumes for the worker Pods | `[]`

</details>

<details>
<summary><code>triggerer.*</code></summary>

Parameter | Description | Default
--- | --- | ---
`triggerer.enabled` | if the triggerer should be deployed | `true`
`triggerer.replicas` | the number of triggerer Pods to run | `1`
`triggerer.resources` | resource requests/limits for the airflow triggerer Pods | `{}`
`triggerer.nodeSelector` | the nodeSelector configs for the triggerer Pods | `{}`
`triggerer.affinity` | the affinity configs for the triggerer Pods | `{}`
`triggerer.tolerations` | the toleration configs for the triggerer Pods | `[]`
`triggerer.securityContext` | the security context for the triggerer Pods | `{}`
`triggerer.labels` | labels for the triggerer Deployment | `{}`
`triggerer.podLabels` | Pod labels for the triggerer Deployment | `{}`
`triggerer.annotations` | annotations for the triggerer Deployment | `{}`
`triggerer.podAnnotations` | Pod annotations for the triggerer Deployment | `{}`
`triggerer.safeToEvict` | if we add the annotation: "cluster-autoscaler.kubernetes.io/safe-to-evict" = "true" | `true`
`triggerer.podDisruptionBudget.*` | configs for the PodDisruptionBudget of the triggerer Deployment | `<see values.yaml>`
`triggerer.capacity` | maximum number of triggers each triggerer will run at once (sets `AIRFLOW__TRIGGERER__DEFAULT_CAPACITY`) | `1000`
`triggerer.livenessProbe.*` | liveness probe for the triggerer Pods | `<see values.yaml>`
`triggerer.extraPipPackages` | extra pip packages to install in the triggerer Pods | `[]`
`triggerer.extraVolumeMounts` | extra VolumeMounts for the triggerer Pods | `[]`
`triggerer.extraVolumes` | extra Volumes for the triggerer Pods | `[]`

</details>

<details>
<summary><code>flower.*</code></summary>

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
`flower.basicAuthSecret` | the name of a pre-created secret containing the basic authentication value for flower | `""`
`flower.basicAuthSecretKey` | the key within `flower.basicAuthSecret` containing the basic authentication string | `""`
`flower.service.*` | configs for the Service of the flower Pods | `<see values.yaml>`
`flower.extraPipPackages` | extra pip packages to install in the flower Pod | `[]`
`flower.extraVolumeMounts` | extra VolumeMounts for the flower Pods | `[]`
`flower.extraVolumes` | extra Volumes for the flower Pods | `[]`

</details>

<details>
<summary><code>logs.*</code></summary>

Parameter | Description | Default
--- | --- | ---
`logs.path` | the airflow logs folder | `/opt/airflow/logs`
`logs.persistence.*` | configs for the logs PVC | `<see values.yaml>`

</details>

<details>
<summary><code>dags.*</code></summary>

Parameter | Description | Default
--- | --- | ---
`dags.path` | the airflow dags folder | `/opt/airflow/dags`
`dags.persistence.*` | configs for the dags PVC | `<see values.yaml>`
`dags.gitSync.*` | configs for the git-sync sidecar  | `<see values.yaml>`

</details>

<details>
<summary><code>ingress.*</code></summary>

Parameter | Description | Default
--- | --- | ---
`ingress.enabled` | if we should deploy Ingress resources | `false`
`ingress.apiVersion` | the `apiVersion` to use for Ingress resources | `networking.k8s.io/v1`
`ingress.web.*` | configs for the Ingress of the web Service | `<see values.yaml>`
`ingress.flower.*` | configs for the Ingress of the flower Service | `<see values.yaml>`

</details>

<details>
<summary><code>rbac.*</code></summary>

Parameter | Description | Default
--- | --- | ---
`rbac.create` | if Kubernetes RBAC resources are created | `true`
`rbac.events` | if the created RBAR role has GET/LIST access to Event resources | `false`

</details>

<details>
<summary><code>serviceAccount.*</code></summary>

Parameter | Description | Default
--- | --- | ---
`serviceAccount.create` | if a Kubernetes ServiceAccount is created | `true`
`serviceAccount.name` | the name of the ServiceAccount | `""`
`serviceAccount.annotations` | annotations for the ServiceAccount | `{}`

</details>

<details>
<summary><code>extraManifests</code></summary>

Parameter | Description | Default
--- | --- | ---
`extraManifests` | a list of extra Kubernetes manifests that will be deployed alongside the chart | `[]`

</details>

<details>
<summary><code>pgbouncer.*</code></summary>

Parameter | Description | Default
--- | --- | ---
`pgbouncer.enabled` | if the pgbouncer Deployment is created | `true`
`pgbouncer.image.*` | configs for the pgbouncer container image | `<see values.yaml>`
`pgbouncer.resources` | resource requests/limits for the pgbouncer Pods | `{}`
`pgbouncer.nodeSelector` | the nodeSelector configs for the pgbouncer Pods | `{}`
`pgbouncer.affinity` | the affinity configs for the pgbouncer Pods | `{}`
`pgbouncer.tolerations` | the toleration configs for the pgbouncer Pods | `[]`
`pgbouncer.securityContext` | the security context for the pgbouncer Pods | `{}`
`pgbouncer.labels` | labels for the pgbouncer Deployment | `{}`
`pgbouncer.podLabels` | Pod labels for the pgbouncer Deployment | `{}`
`pgbouncer.annotations` | annotations for the pgbouncer Deployment | `{}`
`pgbouncer.podAnnotations` | Pod annotations for the pgbouncer Deployment | `{}`
`pgbouncer.safeToEvict` | if we add the annotation: "cluster-autoscaler.kubernetes.io/safe-to-evict" = "true" | `true`
`pgbouncer.podDisruptionBudget.*` | configs for the PodDisruptionBudget of the pgbouncer | `<see values.yaml>`
`pgbouncer.livenessProbe.*` | configs for the pgbouncer Pods' liveness probe | `<see values.yaml>`
`pgbouncer.startupProbe.*` | configs for the pgbouncer Pods' startup probe | `<see values.yaml>`
`pgbouncer.terminationGracePeriodSeconds` | the maximum number of seconds to wait for queries upon pod termination, before force killing | `120`
`pgbouncer.authType` | sets pgbouncer config: `auth_type` | `md5`
`pgbouncer.maxClientConnections` | sets pgbouncer config: `max_client_conn` | `1000`
`pgbouncer.poolSize` | sets pgbouncer config: `default_pool_size` | `20`
`pgbouncer.logDisconnections` | sets pgbouncer config: `log_disconnections` | `0`
`pgbouncer.logConnections` | sets pgbouncer config: `log_connections` | `0`
`pgbouncer.clientSSL.*` | ssl configs for: clients -> pgbouncer | `<see values.yaml>`
`pgbouncer.serverSSL.*` | ssl configs for: pgbouncer -> postgres | `<see values.yaml>`

</details>

<details>
<summary><code>postgresql.*</code></summary>

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

<details>
<summary><code>externalDatabase.*</code></summary>

Parameter | Description | Default
--- | --- | ---
`externalDatabase.type` | the type of external database | `postgres`
`externalDatabase.host` | the host of the external database | `localhost`
`externalDatabase.port` | the port of the external database | `5432`
`externalDatabase.database` | the database/scheme to use within the the external database | `airflow`
`externalDatabase.user` | the username for the external database | `airflow`
`externalDatabase.userSecret` | the name of a pre-created secret containing the external database user | `""`
`externalDatabase.userSecretKey` | the key within `externalDatabase.userSecret` containing the user string | `postgresql-user`
`externalDatabase.password` | the password for the external database | `""`
`externalDatabase.passwordSecret` | the name of a pre-created secret containing the external database password | `""`
`externalDatabase.passwordSecretKey` | the key within `externalDatabase.passwordSecret` containing the password string | `postgresql-password`
`externalDatabase.properties` | extra connection-string properties for the external database | `""`

</details>

<details>
<summary><code>redis.*</code></summary>

Parameter | Description | Default
--- | --- | ---
`redis.enabled` | if the `stable/redis` chart is used | `true`
`redis.password` | the redis password | `airflow`
`redis.existingSecret` | the name of a pre-created secret containing the redis password | `""`
`redis.existingSecretPasswordKey` | the key within `redis.existingSecret` containing the password string | `redis-password`
`redis.cluster.*` | configs for redis cluster mode | `<see values.yaml>`
`redis.master.*` | configs for the redis master StatefulSet | `<see values.yaml>`
`redis.slave.*` | configs for the redis slave StatefulSet | `<see values.yaml>`

</details>

<details>
<summary><code>externalRedis.*</code></summary>

Parameter | Description | Default
--- | --- | ---
`externalRedis.host` | the host of the external redis | `localhost`
`externalRedis.port` | the port of the external redis | `6379`
`externalRedis.databaseNumber` | the database number to use within the external redis | `1`
`externalRedis.password` | the password for the external redis | `""`
`externalRedis.passwordSecret` | the name of a pre-created secret containing the external redis password | `""`
`externalRedis.passwordSecretKey` | the key within `externalRedis.passwordSecret` containing the password string | `redis-password`
`externalDatabase.properties` | extra connection-string properties for the external redis | `""`

</details>

<details>
<summary><code>serviceMonitor.*</code></summary>

Parameter | Description | Default
--- | --- | ---
`serviceMonitor.enabled` | if ServiceMonitor resources should be deployed | `false`
`serviceMonitor.selector` | labels for ServiceMonitor, so that Prometheus can select it | `{ prometheus: "kube-prometheus" }`
`serviceMonitor.path` | the ServiceMonitor web endpoint path | `/admin/metrics`
`serviceMonitor.interval` | the ServiceMonitor web endpoint path | `30s`

</details>

<details>
<summary><code>prometheusRule.*</code></summary>

Parameter | Description | Default
--- | --- | ---
`prometheusRule.enabled` | if the PrometheusRule resources should be deployed | `false`
`prometheusRule.additionalLabels` | labels for PrometheusRule, so that Prometheus can select it | `{}`
`prometheusRule.groups` | alerting rules for Prometheus | `[]`

</details>