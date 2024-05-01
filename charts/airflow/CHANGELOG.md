# Changelog

All notable changes to the `User-Community Airflow Helm Chart` will be documented in this file.

This project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html) and [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

TBD

## [8.9.0] - 2024-04-30

> 🟨 __NOTES__ 🟨
>
> - this is the first version of the chart with support for airflow 2.9, along with [pretty much all previous versions of airflow](https://github.com/airflow-helm/charts/tree/main/charts/airflow#airflow-version-support)
> - the default airflow image is now `apache/airflow:2.8.4-python3.9`, but you can still use any supported version of airflow
> - we have fixed an important bug for airflow <=2.5.3 (introduced in chart version 8.7.1), some liveness probes were creating significant load on the backend database [#853](https://github.com/airflow-helm/charts/pull/853)

> 🟦 __OTHER__ 🟦
>
> - If you appreciate the `User-Community Airflow Helm Chart` please consider supporting us!
>    - [give a ⭐ on GitHub](https://github.com/airflow-helm/charts/stargazers)
>    - [give a ⭐ on ArtifactHub](https://artifacthub.io/packages/helm/airflow-helm/airflow)

### Changed
- the default airflow image is now `apache/airflow:2.8.4-python3.9` (see the [airflow version support matrix](https://github.com/airflow-helm/charts/tree/main/charts/airflow#airflow-version-support))
- the default git-sync image is now `registry.k8s.io/git-sync/git-sync:v3.6.9`
- the default pgbouncer image is now `ghcr.io/airflow-helm/pgbouncer:1.22.1-patch.0`
- the default embedded postgres image is now `ghcr.io/airflow-helm/postgresql-bitnami:11.22-patch.0`
- the default embedded redis image is now `bitnami/redis:6.2.14-debian-12-r17`

### Added
- add `extraContainers` and `extraInitContainers` values for all components ([#856](https://github.com/airflow-helm/charts/pull/856))
- add `topologySpreadConstraints` values  ([#752](https://github.com/airflow-helm/charts/pull/752))
- add values to set init-container resources ([#855](https://github.com/airflow-helm/charts/pull/855))
- add `airflow.defaultContainerSecurityContext` value ([#624](https://github.com/airflow-helm/charts/pull/624))
- add `pgbouncer.statsUsers` value to set `stats_user` in pgbouncer ([#820](https://github.com/airflow-helm/charts/pull/820))
- add optional `rbac.secrets` value to give GET/LIST/WATCH on Secrets ([#790](https://github.com/airflow-helm/charts/pull/790))

### Fixed
- scheduler and triggerer probe performance for airflow <2.6.0 ([#853](https://github.com/airflow-helm/charts/pull/853))
- fix `extraPipPackages` values for airflow 2.9.0+ ([#858](https://github.com/airflow-helm/charts/pull/858))
- don't import `User` and `Role` FAB models, fixes airflow 2.9.0+ ([#857](https://github.com/airflow-helm/charts/pull/857))
- set `appProtocol` on Service ports (for Istio) ([#854](https://github.com/airflow-helm/charts/pull/854))

## [8.8.0] - 2023-08-28

> 🟨 __NOTES__ 🟨
>
> - this is the first version of the chart with support for airflow 2.7, along with [pretty much all previous versions of airflow](https://github.com/airflow-helm/charts/tree/main/charts/airflow#airflow-version-support)
> - the default airflow image is now `apache/airflow:2.6.3-python3.9`, but you can still use any supported version of airflow

### Changed
- the default airflow image is now `apache/airflow:2.6.3-python3.9` (see the [airflow version support matrix](https://github.com/airflow-helm/charts/tree/main/charts/airflow#airflow-version-support))

### Added
- add liveness probe for celery workers ([#766](https://github.com/airflow-helm/charts/pull/766))
- support `include_deferred` in pool sync for airflow 2.7.0 ([#775](https://github.com/airflow-helm/charts/pull/775))

### Fixed
- sync-users for airflow 2.7.0 ([#772](https://github.com/airflow-helm/charts/pull/772))
- invalid pgbouncer-certs volume spec when empty ([#777](https://github.com/airflow-helm/charts/pull/777))

## [8.7.1] - 2023-05-13

> 🟨 __NOTES__ 🟨
>
> - this is the first version of the chart with support for airflow 2.6, along with pretty much all previous versions of airflow, see the [airflow version support matrix](https://github.com/airflow-helm/charts/tree/main/charts/airflow#airflow-version-support)

### Fixed
- fixed liveness probes in airflow 2.6.0 ([#743](https://github.com/airflow-helm/charts/pull/743))

## [8.7.0] - 2023-04-06

> 🟥 __WARNINGS__ 🟥
>
> - if you use a custom `pgbouncer.image.tag`, you MUST update it to `1.18.0-patch.1` or later, as we now require the `openssl` package to be installed for generating self-signed certificates
> - if you use a custom `postgresql.image`, please take note that `postgresql.image.registry` is now `ghcr.io` by default (rather than `docker.io`)
> - if you use "Azure File" for logs persistence, you MUST NOT update to airflow 2.5.1, 2.5.2, or 2.5.3:
>    - there is an [issue in these versions](https://github.com/apache/airflow/issues/29112) that will cause your tasks to fail
>    - if you wish to use these versions, you will need to use a different method of logs persistence, for example [the `Azure Blob Storage` remote provider](https://github.com/airflow-helm/charts/blob/main/charts/airflow/docs/faq/monitoring/log-persistence.md#option-2---remote-providers)

> 🟨 __NOTES__ 🟨
>
> - the default airflow image is now `apache/airflow:2.5.3-python3.8`, but you can still use any supported version of airflow, see the [airflow version support matrix](https://github.com/airflow-helm/charts/tree/main/charts/airflow#airflow-version-support)
> - when upgrading to airflow 2.5, you may wish to rename your kubernetes `aiflow.config` from `AIRFLOW__KUBERNETES__*` to `AIRFLOW__KUBERNETES_EXECUTOR__*`, as the former was deprecated by airflow 2.5
> - the chart should no longer be forever "out of sync" in apps like ArgoCD, as this issue was resolved by [#718](https://github.com/airflow-helm/charts/pull/718)

### Changed
- the default airflow image is now `apache/airflow:2.5.3-python3.8` (see the [airflow version support matrix](https://github.com/airflow-helm/charts/tree/main/charts/airflow#airflow-version-support))
- the default git-sync image is now `registry.k8s.io/git-sync/git-sync:v3.6.5`
- the default pgbouncer image is now `ghcr.io/airflow-helm/pgbouncer:1.18.0-patch.1`
- the default embedded postgres image is now `ghcr.io/airflow-helm/postgresql-bitnami:11.16-patch.0` (our new [custom image](https://github.com/airflow-helm/charts/tree/main/images/postgresql-bitnami/11/alpine), with support for ARM64)
- the default embedded redis image is now `bitnami/redis:5.0.14-debian-10-r173`
- we now generate self-signed certificates for pgbouncer using a startup script, fixing ArgoCD being forever "out of sync" ([#718](https://github.com/airflow-helm/charts/pull/718))

### Added
- feature for automatically changing pool slots on cron schedules ([#649](https://github.com/airflow-helm/charts/pull/649))
- ability to disable chart-managed `webserver_config.py` file with `web.webserverConfig.enabled` value ([#631](https://github.com/airflow-helm/charts/pull/631))
- added `dags.gitSync.submodules` value ([#620](https://github.com/airflow-helm/charts/pull/620))

### Fixed
- ensure Kubernetes 1.25+ support by updating default api versions for `PodDisruptionBudget` and `HorizontalPodAutoscaler` ([#685](https://github.com/airflow-helm/charts/pull/685))
- now also set `kubernetes_executor` airflow configs, as `kubernetes` ones are deprecated ([#719](https://github.com/airflow-helm/charts/pull/719))
- fix typo in error message ([#696](https://github.com/airflow-helm/charts/pull/696))

## [8.6.1] - 2022-06-22

> 🟥 __WARNINGS__ 🟥
>
> - When using `extraPipPackages`, Pods will now fail to start if the `apache-airflow` version would be changed from the image version,
>   see `airflow.protectedPipPackages` for more information.
>   (NOTE: for critical deployments we STRONGLY recommend [embedding extra packages into the image](docs/faq/configuration/extra-python-packages.md#option-2---embedded-into-container-image) instead of using `extraPipPackages`)
> - The maximum length for a helm release-name has been lowered to `40` characters (down from `43`).
>   Existing deployments with a helm release-name between `41` and `43` characters MUST enable the `allowLongReleaseName` value to continue using the chart.
>   (NOTE: the embedded Postgres and Redis will not work with a release-name between `41` and `43` characters).

> 🟨 __NOTES__ 🟨
>
> - The chart now works with Airflow 2.3, however, please note the default image tag is still `2.2.5-python3.8`.
> - Storing [logs under `airflow.extraVolumeMounts` (Pod Volumes)](docs/faq/monitoring/log-persistence.md#option-3---pod-volumes) is now a supported usage pattern.
> - The [Scheduler "task creation check"](docs/faq/monitoring/scheduler-liveness-probe.md#scheduler-task-creation-check) now has the `scheduler.livenessProbe.taskCreationCheck.schedulerAgeBeforeCheck` 
>   value to ensure the scheduler has time to create tasks before starting the check.
> - Airflow 2.3.0 introduced BETA support for ARM CPUs (like Apple Silicon).
>   The chart's current default images for Postgres/Redis only support `amd64`,
>   however, you may test our drop-in replacements that support both `arm64` and `amd64`:
>    - [`bitnami/postgresql`](https://hub.docker.com/r/bitnami/postgresql/) → [`ghcr.io/airflow-helm/postgresql-bitnami`](https://ghcr.io/airflow-helm/postgresql-bitnami)
>    - [`bitnami/redis`](https://hub.docker.com/r/bitnami/redis/) → `TBA`

### Changed
- update `.helmignore` file to exclude docs ([#593](https://github.com/airflow-helm/charts/pull/593))
- require release-name to have <= 40 characters ([#589](https://github.com/airflow-helm/charts/pull/589))

### Added
- add `airflow.protectedPipPackages` ([#610](https://github.com/airflow-helm/charts/pull/610))
- allow using `extraVolumeMounts` for log storage ([#585](https://github.com/airflow-helm/charts/pull/585))
- minimum scheduler age before task-creation-check ([#612](https://github.com/airflow-helm/charts/pull/612))

### Fixed
- fix some breaking changes from airflow 2.3.0 ([#592](https://github.com/airflow-helm/charts/pull/592)) 
- fix wait-for-db-migrations in airflow 2.3.0 ([#576](https://github.com/airflow-helm/charts/pull/576)) 
- fix pgbouncer liveness probe in minikube ([#560](https://github.com/airflow-helm/charts/pull/560))
- use rsync for extraPipPackages ([#599](https://github.com/airflow-helm/charts/pull/599))
- set `AIRFLOW__LOGGING__WORKER_LOG_SERVER_PORT` ([#608](https://github.com/airflow-helm/charts/pull/608))
- only set `SQLALCHEMY_DATABASE_URI` in airflow 1.10 ([#609](https://github.com/airflow-helm/charts/pull/609))

## [8.6.0] - 2022-04-13

> 🟥 __WARNINGS__ 🟥
>
> - If you have `logs.persistence.enabled` set to `true`, you MUST disable `scheduler.logCleanup.enabled` and `workers.logCleanup.enabled` or the upgrade will fail
> - If using airflow `2.0.X` or `2.1.X`, you should set `triggerer.enabled` to `false`, as the triggerer was added in airflow `2.2.0` and will fail in older versions
> - If you currently pin `dags.gitSync.image.tag`, please update to the new default of `v3.5.0`
> - If you currently pin `pgbouncer.image.tag`, please update to the new default of `1.17.0-patch.0`
> - If you currently pin `pgbouncer.maxClientConnections`, please update to the new default of `1000`

> 🟨 __NOTES__ 🟨
>
> - Consider enabling the new [Scheduler "task creation check"](docs/faq/monitoring/scheduler-liveness-probe.md#scheduler-task-creation-check) to prevent deadlocks, especially if using airflow versions before `2.1.1`
> - If you disabled PgBouncer because of incompatibility with "Azure PostgreSQL", you can re-enable it if you [set `pgbouncer.authType = scram-sha-256` and `pgbouncer.serverSSL = verify-ca`](docs/faq/database/pgbouncer.md)
> - This chart version fixes [an issue that caused `db-migrations` to hang](https://github.com/airflow-helm/charts/pull/529) when PgBouncer is enabled with airflow `2.2.0+`
> - While NOT recommended, you can now set [external database](docs/faq/database/external-database.md) and [external redis](docs/faq/database/external-redis.md) passwords with a plain-text value
> - If you are using [celery worker autoscaling](docs/faq/configuration/autoscaling-celery-workers.md), you must set a non-empty value for `workers.logCleanup.resources.requests`
> - The new ["log-cleanup sidecar"](docs/faq/monitoring/log-cleanup.md) is enabled by default on schedulers and workers
> - The new [PgBouncer startupProbe](https://github.com/airflow-helm/charts/pull/547) will only work in Kubernetes 1.18+
> - The [`extraManifests` value](docs/faq/kubernetes/extra-manifests.md) has been significantly improved

### Changed
- the default `airflow.image` is now `apache/airflow:2.2.5-python3.8` (see the [airflow version support matrix](https://github.com/airflow-helm/charts/tree/main/charts/airflow#airflow-version-support))
- support helm templating in `extraManifests` by allowing string elements ([docs](docs/faq/kubernetes/extra-manifests.md)) ([#523](https://github.com/airflow-helm/charts/pull/523))
- update default `dags.gitSync.image.tag` to `v3.5.0` ([#544](https://github.com/airflow-helm/charts/pull/544))
- update default `pgbouncer.image.tag` to `1.17.0-patch.0` ([#552](https://github.com/airflow-helm/charts/pull/552))
- update default `pgbouncer.maxClientConnections` to `1000` ([#543](https://github.com/airflow-helm/charts/pull/543))

### Added
- add "airflow triggerer" Deployment ([#555](https://github.com/airflow-helm/charts/pull/555))
- add "log-cleanup sidecar" to scheduler and worker ([docs](docs/faq/monitoring/log-cleanup.md)) ([#554](https://github.com/airflow-helm/charts/pull/554))
- add "task creation check" to scheduler liveness probe ([docs](docs/faq/monitoring/scheduler-liveness-probe.md#scheduler-task-creation-check)) ([#549](https://github.com/airflow-helm/charts/pull/549))
- allow setting database passwords with values & setting database usernames from secrets ([docs](docs/faq/database/external-database.md#option-1---postgres)) ([#553](https://github.com/airflow-helm/charts/pull/553))
- allow `airflow.users[].roles` to specify a list of roles ([docs](docs/faq/security/airflow-users.md)) ([#539](https://github.com/airflow-helm/charts/pull/539))
- add `pgbouncer.authType` value ([docs](docs/faq/database/pgbouncer.md)) ([#498](https://github.com/airflow-helm/charts/pull/498))
- add `ingressClassName` values to ingress ([docs](docs/faq/kubernetes/ingress.md)) ([#527](https://github.com/airflow-helm/charts/pull/527))
- add `airflow.clusterDomain` value ([#441](https://github.com/airflow-helm/charts/pull/441))
- add `labels` values for `sync` and `db-migrations` ([#467](https://github.com/airflow-helm/charts/pull/467))
- add `airflow.kubernetesPodTemplate.extraContainers` value ([#456](https://github.com/airflow-helm/charts/pull/456))
- add `airflow.kubernetesPodTemplate.extraInitContainers` value ([#446](https://github.com/airflow-helm/charts/pull/446))
- add `airflow.kubernetesPodTemplate.shareProcessNamespace` value ([#408](https://github.com/airflow-helm/charts/pull/408))
- add `airflow.kubernetesPodTemplate.podLabels` value ([#534](https://github.com/airflow-helm/charts/pull/534))

### Fixed
- fix `airflow.{fernetKey,webserverSecretKey}` overshadowing `_CMD` and `_SECRET` configs ([docs-1](docs/faq/security/set-fernet-key.md), [docs-2](docs/faq/security/set-webserver-secret-key.md)) ([#508](https://github.com/airflow-helm/charts/pull/508))
- fix PG_ADVISORY_LOCK not being released when using pgbouncer ([#529](https://github.com/airflow-helm/charts/pull/529))
- only set `CONNECTION_CHECK_MAX_COUNT` once ([#533](https://github.com/airflow-helm/charts/pull/533))
- set `DUMB_INIT_SETSID=0` for celery workers (fix warm shutdown) ([#550](https://github.com/airflow-helm/charts/pull/550))
- replace pgbouncer readinessProbe with startupProbe ([#547](https://github.com/airflow-helm/charts/pull/547))
- allow ingress `servicePort` to be string or number ([#530](https://github.com/airflow-helm/charts/pull/530))
- fix `pgbouncer.livenessProbe.enabled` not being respected ([#546](https://github.com/airflow-helm/charts/pull/546))
- cast user values with toString before b64enc ([#557](https://github.com/airflow-helm/charts/pull/557))

## [8.5.3] - 2022-01-10

> 🟥 __WARNINGS__ 🟥
>
> - Update to this version if you are using Kubernetes 1.20+ to prevent the scheduler's liveness probe causing a restart loop (see issue: [#484](https://github.com/airflow-helm/charts/issues/484))
> - If you currently set `scheduler.livenessProbe.timeoutSeconds` or `pgbouncer.livenessProbe.timeoutSeconds` in your values, ensure you update them to the new default of `60`

### Changed
- the default `airflow.image` is now `apache/airflow:2.1.4-python3.8` (see the [airflow version support matrix](https://github.com/airflow-helm/charts/tree/main/charts/airflow#airflow-version-support))

### Fixed
- increase default `timeoutSeconds` for liveness probes ([#496](https://github.com/airflow-helm/charts/pull/496))
- typo in `GIT_SYNC_MAX_SYNC_FAILURES` environment variable name ([#462](https://github.com/airflow-helm/charts/pull/462))

## [8.5.2] - 2021-08-25

> 🟥 __WARNINGS__ 🟥
>
> - You must stop URL-encoding special characters in `externalDatabase.user`, the chart will now automatically do this for you. For example, don't replace `@` with `%40` anymore.

### Changed
- special characters in `externalDatabase.user` are now automatically url-encoded ([#407](https://github.com/airflow-helm/charts/pull/407))

### Fixed
- self-signed certificates are now only generated for `client_tls_key_file` and `client_tls_cert_file` PgBouncer configs ([#404](https://github.com/airflow-helm/charts/pull/404))
- flower pods are now correctly affected by default: nodeSelector, affinity, tolerations ([#405](https://github.com/airflow-helm/charts/pull/405))

## [8.5.1] - 2021-08-23
### Fixed
- fixed PgBouncer not working if `externalDatabase.database` or `postgresql.postgresqlDatabase` is not `"airflow"` ([#398](https://github.com/airflow-helm/charts/pull/398))

## [8.5.0] - 2021-08-19

> 🟥 __WARNINGS__ 🟥
>
> - If using Kubernetes 1.18 or earlier, you MUST set `ingress.apiVersion` to `networking.k8s.io/v1beta1`
> - If using Kubernetes 1.22+, you MUST set `ingress.apiVersion` to `networking.k8s.io/v1` (this is default)
> - You must set a custom value for `airflow.webserverSecretKey` to ensure your airflow's security

> 🟨 __NOTES__ 🟨
>
> - This is an important upgrade for Postgres users, as it implements [PgBouncer](https://www.pgbouncer.org/) support, which should  eliminate Postgres "too many connections" errors.
> - If you are using the `XXXX.securityContext` values, consider using the new global `airflow.defaultSecurityContext` value, so that you don't have to update your values in future.
> - If you are using the `XXXX.{nodeSelector,affinity,tolerations}` values, consider using the new global `airflow.{defaultNodeSelector,defaultAffinity,defaultTolerations}` values, so that you don't have to update your values in future.
> - To revert to using a post-install Job for `db-migrations`, set `airflow.dbMigrations.runAsJob` to `true`
> - The new default of `airflow.defaultSecurityContext = {fsGroup: 0}` should prevent filesystem permission errors in mounted volumes

### Changed
- the default `airflow.image` is now `apache/airflow:2.1.2-python3.8` (see the [airflow version support matrix](https://github.com/airflow-helm/charts/tree/main/charts/airflow#airflow-version-support))
- the default `airflow.image.gid` is now `0` ([#388](https://github.com/airflow-helm/charts/pull/388))
- the Kubernetes Ingress now uses `networking.k8s.io/v1` for `apiVersion` by default ([#381](https://github.com/airflow-helm/charts/pull/381))
- we now include git-sync containers in all Deployments ([#390](https://github.com/airflow-helm/charts/pull/390))
- we now use the official `/entrypoint` of the airflow container ([#386](https://github.com/airflow-helm/charts/pull/386))
- any `airflow.extraPipPackages` are now installed in snyc Jobs/Deployments ([#354](https://github.com/airflow-helm/charts/pull/354))
- we now include `airflow.{config,extraEnv}` in the pip-install containers ([#365](https://github.com/airflow-helm/charts/pull/365))
- we now include `airflow.{config,extraEnv}` in the git-sync containers ([#380](https://github.com/airflow-helm/charts/pull/380))
- we now include `airflow.extraContainers` in the flower Deployment ([#379](https://github.com/airflow-helm/charts/pull/379))
- the KubernetesExecutor pod-template now respects the `airflow.image.*` values ([#352](https://github.com/airflow-helm/charts/pull/352))
- added values validation for `externalDatabase.type` ([#348](https://github.com/airflow-helm/charts/pull/348))

### Added
- PgBouncer is now supported (and enabled by default), see the new `pgbouncer.*` values ([#341](https://github.com/airflow-helm/charts/pull/341), [#330](https://github.com/airflow-helm/charts/pull/330))
- created a new Deployment called `db-migrations` to manage airflow database schema upgrades ([#345](https://github.com/airflow-helm/charts/pull/345))
- added the `airflow.webserverSecretKey` value with default `"THIS IS UNSAFE!"` ([#346](https://github.com/airflow-helm/charts/pull/346))
- added the `airflow.defaultSecurityContext` value with default `{fsGroup: 0}` ([#367](https://github.com/airflow-helm/charts/pull/367))
- added `airflow.{defaultNodeSelector,defaultAffinity,defaultTolerations}` values ([#372](https://github.com/airflow-helm/charts/pull/372))
- added `airflow.localSettings.*` values to make specifying `airflow_local_settings.py` easier ([#374](https://github.com/airflow-helm/charts/pull/374))

### Fixed
- fixed the scheduler livenessProbe command ([#351](https://github.com/airflow-helm/charts/pull/351))
- made the sync-users deployment close its db connection after each loop ([#320](https://github.com/airflow-helm/charts/pull/320))
- stopped using `stringData` in Kubernetes Secrets ([#356](https://github.com/airflow-helm/charts/pull/356), [#391](https://github.com/airflow-helm/charts/pull/391))
- fixed typos in sync/_helpers templates ([#366](https://github.com/airflow-helm/charts/pull/366), [#387](https://github.com/airflow-helm/charts/pull/387))
- always include `airflow.env` last ([#385](https://github.com/airflow-helm/charts/pull/385))

### Removed
- removed the broken `flower.oauthDomains` value ([#383](https://github.com/airflow-helm/charts/pull/383))

### Docs
- significant rewrite of the post-install NOTES.txt ([#358](https://github.com/airflow-helm/charts/pull/358))
- general cleanup of `values.yaml` docstrings ([#389](https://github.com/airflow-helm/charts/pull/389))

## [8.4.1] - 2021-07-12
### Fixed
- remove Job dependency on `.Release.Revision` to prevent immutability errors ([#298](https://github.com/airflow-helm/charts/pull/298))
   - (important for tools like [argo-cd](https://github.com/argoproj/argo-cd/) which never run `helm install ...`, causing `.Release.Revision` to never be incremented)

## [8.4.0] - 2021-07-09

> 🟥 __WARNINGS__ 🟥
> 
> - The meaning of `airflow.{usersUpdate,connectionsUpdate,poolsUpdate,variablesUpdate}` have changed:
>    - If `true`, a Deployment will perpetually sync `airflow.{users,connections,pools,variables}`, reverting changes made in the airflow UI
>    - If `false`, a single Job is created after each `helm upgrade ...` to sync `airflow.{users,connections,pools,variables}` once

> 🟨 __NOTES__ 🟨
> 
> - You may now use Secrets and ConfigMaps to define your `airflow.{users,connections,pools,variables}`:
>    - [How to manage airflow users?](docs/faq/security/airflow-users.md)
>    - [How to manage airflow connections?](docs/faq/dags/airflow-connections.md)
>    - [How to manage airflow variables?](docs/faq/dags/airflow-variables.md)
>    - [How to manage airflow pools?](docs/faq/dags/airflow-pools.md)

### Changed
- the default `airflow.image` is now `apache/airflow:2.1.1-python3.8` (see the [airflow version support matrix](https://github.com/airflow-helm/charts/tree/main/charts/airflow#airflow-version-support)) ([#286](https://github.com/airflow-helm/charts/issues/286))
- the `Chart.yaml` now explicitly specifies `apiVersion=v2` (requiring helm 3) ([#278](https://github.com/airflow-helm/charts/issues/278))
- the `requirements.yaml` file was removed in preference of the `v2` dependencies method (specifying in `Chart.yaml`) ([#278](https://github.com/airflow-helm/charts/issues/278))
- git-sync containers are now deployed in webserver, regardless of `airflow.legacyCommands` ([#288](https://github.com/airflow-helm/charts/pull/288))
- `wait-for-db-migrations` init-containers now work properly when `airflow.legacyCommands=true` ([#271](https://github.com/airflow-helm/charts/pull/271))
- improve validation of `{logs,dags}.persistence.accessMode` ([#269](https://github.com/airflow-helm/charts/pull/269))

### Added
- allow referencing Secrets/ConfigMaps in `airflow.{users,connections,pools,variables}` ([#281](https://github.com/airflow-helm/charts/pull/281))
- removed the need for `helmWait` value ([#266](https://github.com/airflow-helm/charts/pull/266))

### Fixed
- include volumeMounts in init-containers ([#255](https://github.com/airflow-helm/charts/pull/255))
- add `release` to worker Service selector ([#267](https://github.com/airflow-helm/charts/pull/267))
- mount `dags-data` with `readOnly=true` if `accessMode=ReadOnlyMany` ([#268](https://github.com/airflow-helm/charts/pull/268))
- only validate `ingress.{web,flower}.path` if `ingress.enabled=true` ([#270](https://github.com/airflow-helm/charts/pull/270))
- multiple Schedulers could run if `legacyCommands=true` (due to rollingUpdate) ([#272](https://github.com/airflow-helm/charts/pull/272))

## [8.3.2] - 2021-06-30
### Docs
- added this changelog ([#231](https://github.com/airflow-helm/charts/issues/231))
- add description to each section of the README ([#162](https://github.com/airflow-helm/charts/issues/162))
- add airflow <--> chart version support matrix ([#137](https://github.com/airflow-helm/charts/issues/137))
- improve the README formatting

## [8.3.1] - 2021-06-29
### Docs
- fix(example): hpa of gke example doesn't work ([#225](https://github.com/airflow-helm/charts/issues/225))

## [8.3.0] - 2021-06-23
### Added
- Add support for GIT_SYNC_MAX_FAILURES ([#182](https://github.com/airflow-helm/charts/issues/182))
  - `dags.gitSync.maxFailures`
    
## [8.2.0] - 2021-06-03
### Added
- Add redis properties configuration for external redis ([#200](https://github.com/airflow-helm/charts/issues/200))
  - `externalRedis.properties`

## [8.1.3] - 2021-05-21
### Docs
- Typo in docs for `airflow.pools` in README.md ([#207](https://github.com/airflow-helm/charts/issues/207))
- README implies that Helm 2 is supported, but its not ([#184](https://github.com/airflow-helm/charts/issues/184))

## [8.1.2] - 2021-05-21
### Fixed
- run jobs with airflow serviceAccount ([#201](https://github.com/airflow-helm/charts/issues/201))

## [8.1.1] - 2021-05-21
### Docs
- Remove references to `workers.celery.instances` (which was removed in 8.0.0) ([#202](https://github.com/airflow-helm/charts/issues/202))

## [8.1.0] - 2021-05-11
### Added
- Add `airflow.kubernetesPodTemplate.resources` value ([#175](https://github.com/airflow-helm/charts/issues/175))

## [8.0.9] - 2021-04-27
### Fixed
- make check-db timeout 60s ([#181](https://github.com/airflow-helm/charts/issues/181))
- move to `pip install --user` ([#168](https://github.com/airflow-helm/charts/issues/168)) ([#169](https://github.com/airflow-helm/charts/issues/169))

## [8.0.8] - 2021-04-20
### Fixed
- don't include git-sync containers in webserver for airflow 2.0 ([#152](https://github.com/airflow-helm/charts/issues/152))
- ensure dags git repo is cloned before containers start ([#124](https://github.com/airflow-helm/charts/issues/124))
- introduce timeout for check-db init-container ([#153](https://github.com/airflow-helm/charts/issues/153))
- only include git-sync init-container in pod_template if enabled ([#158](https://github.com/airflow-helm/charts/issues/158))

### Docs
- add docs for `externalDatabase.properties` in README

## [8.0.7] - 2021-04-16
### Fixed
- only include `checksum/config-pod-template` annotation for kubernetes_like executors ([#150](https://github.com/airflow-helm/charts/issues/150))
- give more information in value validation errors ([#150](https://github.com/airflow-helm/charts/issues/150))
- prevent embedded postgres/redis being enabled at same time as external ([#150](https://github.com/airflow-helm/charts/issues/150))
- use _helper variable in pod_template envFrom ([#150](https://github.com/airflow-helm/charts/issues/150))
- include `airflow.podAnnotations` in jobs ([#140](https://github.com/airflow-helm/charts/issues/140))
- add int64 to validation, so int variables set in bash work ([#136](https://github.com/airflow-helm/charts/issues/136))
- add missing pod labels to upgrade-db job ([#150](https://github.com/airflow-helm/charts/issues/150))
- fix validation for wildcard ingress paths ([#144](https://github.com/airflow-helm/charts/issues/144))
- fix incorrect variable usage for variablesUpdate ([#139](https://github.com/airflow-helm/charts/issues/139))
- add validation for airflow version compatibility with `airflow.legacyCommands` state ([#150](https://github.com/airflow-helm/charts/issues/150))
- make `ingress.web/flower.tls.secretName` optional ([#41](https://github.com/airflow-helm/charts/issues/41))
- fix support for passwords with bash special characters ([#147](https://github.com/airflow-helm/charts/issues/147))

### Docs
- fix dockerfile code blocks in README ([#150](https://github.com/airflow-helm/charts/issues/150))
- fix typo in connections example ([#148](https://github.com/airflow-helm/charts/issues/148))
- add docs for using non-default airflow versions ([#150](https://github.com/airflow-helm/charts/issues/150))

## [8.0.6] - 2021-04-10
### Fixed
- fix volume definition for logs-data with existing claim ([#128](https://github.com/airflow-helm/charts/issues/128))

## [8.0.5] - 2021-04-06
### Fixed
- extract probe path from AIRFLOW__WEBSERVER__BASE_URL + ingress path validation ([#120](https://github.com/airflow-helm/charts/issues/120))

## [8.0.4] - 2021-04-05
### Fixed
- add "Release" to template context dict ([#121](https://github.com/airflow-helm/charts/issues/121))

## [8.0.3] - 2021-04-05
### Fixed
- fix wrong value for envFrom in pod_template ([#122](https://github.com/airflow-helm/charts/issues/122))

## [8.0.2] - 2021-03-28
### Fixed
- properly fixes the following issues (which were not properly fixed in `8.0.1`):
   - `extraVolumeMounts` and `extraVolumes` parsing error ([#98](https://github.com/airflow-helm/charts/issues/98))
   - Flower deployment fails with `airflow.extraVolumeMounts` set ([#101](https://github.com/airflow-helm/charts/issues/101))
- fixes some bad wording on the `airflow.config.AIRFLOW__CORE__DAGS_FOLDER` value validation ([#108](https://github.com/airflow-helm/charts/issues/108))
- addresses an issue with our PYTHONPATH when using `*.extraPipPackages`, which was overriding anything that the user set with `airflow.extraEnv` ([#106](https://github.com/airflow-helm/charts/issues/106))
- fixes the PYTHONPATH not being set when using `airflow.kubernetesPodTemplate.extraPipPackages` with `pod_template.yaml` ([#108](https://github.com/airflow-helm/charts/issues/108))

## [8.0.1] - 2021-03-27

> 🟥 __WARNINGS__ 🟥
>
> - Ensure any previous `upgrade-db` Jobs are manually removed from your Kubernetes before installing with `helmWait=true` (see issue: [#99](https://github.com/airflow-helm/charts/issues/99))

### Added
- Added new value `helmWait`, which should be enabled when the `--wait` flag is used with `helm install` ([#102](https://github.com/airflow-helm/charts/issues/102))

### Fixed
- Flower deployment fails with `airflow.extraVolumeMounts` set ([#101](https://github.com/airflow-helm/charts/issues/101))
- `aiflow.extraVolumeMounts` and `airflow.extraVolumes` parsing error ([#98](https://github.com/airflow-helm/charts/issues/98))
- Validation helper incorrectly requires `workers.enabled=true`([#97](https://github.com/airflow-helm/charts/issues/97))

## [8.0.0] - 2021-03-27

> 🟥 __WARNINGS__ 🟥
> 
> - This is a MAJOR update, meaning there are BREAKING changes

> 🟨 __NOTES__ 🟨
>
> Upgrading Tips:
> - to continue using Airflow `1.10.X`, please set `airflow.legacyCommands=true`
> - you might want to start from a fresh `values.yaml` file
> - if you decide to also upgrade to airflow `2.X.X` check your [dags are compatible](https://airflow.apache.org/docs/apache-airflow/stable/upgrading-to-2.html#step-5-upgrade-airflow-dags)

### Added
#### Feature Highlights:
- native support for "KubernetesExecutor", and "CeleryKubernetesExecutor", see the new `airflow.kubernetesPodTemplate.*` values
- native support for "webserver_config.py", see the new `web.webserverConfig.*` values
- native support for [Airflow 2.0's HA scheduler](https://airflow.apache.org/docs/apache-airflow/stable/scheduler.html#running-more-than-one-scheduler), see the new `scheduler.replicas` value
- significantly improved git-sync system by moving to [kubernetes/git-sync](https://github.com/kubernetes/git-sync)
- significantly improved pip installs by moving to an init-container
- added docs for [How to integrate airflow with LDAP or OAUTH?](docs/faq/security/ldap-oauth.md)
- general cleanup of almost every helm file
- significant docs/README rewrite

#### Other Features:
- added `airflow.users` to help you create/update airflow web users:
   - __WARNING:__ default settings create an admin user (user: __admin__ - password: __admin__), disable by setting `airflow.users` to `[]`
- added `airflow.connections` to help you create/update airflow connections:
- added `airflow.variables` to help you create/update airflow variables:
- added `airflow.pools` to help you create/update airflow pools:
- flower Pods are now affected by `airflow.extraPipPackages`, `airflow.extraVolumeMounts`, `airlfow.extraVolumes`
- you no longer need to set `web.readinessProbe.scheme` or `web.livenessProbe.scheme`, we now only use HTTPS if `AIRFLOW__WEBSERVER__WEB_SERVER_SSL_CERT` and `AIRFLOW__WEBSERVER__WEB_SERVER_SSL_KEY` are set
- airflow db upgrades are now managed with a post "helm upgrade" Job, meaning it only runs once per upgrade (rather than each time the scheduler starts)

#### VALUES - Added:
<details>
<summary>Expand</summary>

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

</details>

### Changed
- the name of the `dags.persistence` PVC has changed from `HELM_RELEASE` to `HELM_RELEASE-dags`:
   - __WARNING:__ you must manually migrate your dags to the new PVC if you had `dags.persistence.enabled = true` (but were not explicitly setting `dags.persistence.existingClaim`)
   - __WARNING:__ be sure to download your dags from the `HELM_RELEASE` volume __BEFORE__ doing the upgrade (as helm may delete the old PVC, during the upgrade)

#### VALUES - Changed Defaults:
<details>
<summary>Expand</summary>

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

</details>

### Removed
- the `XXX.extraConfigmapMounts`, `XXX.secretsDir`, `XXX.secrets`, `XXX.secretsMap` values have been removed, and replaced with `XXX.extraVolumes` and `XXX.extraVolumeMounts`, which use typical Kubernetes volume-mount syntax
- the `dags.installRequirements` value has been removed, please instead use the `XXX.extraPipPackages` values, this change was made for two main reasons:
   1. allowed us to move the pip-install commands into an init-container, which greatly simplifies pod-startup, and removes the need to set any kind of readiness-probe delay in Webserver/Flower Pods
   2. the installRequirements command only ran at Pod start up, meaning you would have to restart all your pods if you updated the `requirements.txt` in your git repo (which isn't very declarative)

#### VALUES - Removed:
<details>
<summary>Expand</summary>

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

</details>

## [7.16.0] - 2020-12-23
### Added
- scheduler kubernetes secrets ([#48](https://github.com/airflow-helm/charts/issues/48))
   - `scheduler.secretsDir`
   - `scheduler.secrets`
   - `scheduler.secretsMap`
    
## [7.15.0] - 2020-12-15
### Changed
- We now use `airflow upgradedb || airflow db upgrade` instead of `airflow initdb` with the following values ([#39](https://github.com/airflow-helm/charts/issues/39))
   - `scheduler.initdb`
   - `scheduler.preinitdb`
- Changed image `pullPolicy` values defaults ([#39](https://github.com/airflow-helm/charts/issues/39))
   - `dags.git.gitSync.image.pullPolicy = IfNotPresent`
   - `dags.initContainer.image.pullPolicy = IfNotPresent`

### Docs
- Update docs for Dag Storage option 1 ([#33](https://github.com/airflow-helm/charts/issues/33))

## [7.14.3] - 2020-11-24
### Fixed
- fix quoting of "$" in connections ([#18](https://github.com/airflow-helm/charts/issues/18))

## [7.14.2] - 2020-11-24
### Docs
- improve README ([#17](https://github.com/airflow-helm/charts/issues/17))

## [7.14.1] - 2020-11-24
### Fixed
- Allow local development with Skaffold ([#7](https://github.com/airflow-helm/charts/issues/7))

## [7.14.0] - 2020-11-05

> 🟨 __NOTES__ 🟨
>
> - This is the first version after migrating to the [new repo](https://github.com/airflow-helm/charts/tree/main/charts/airflow)
> - All versions before `7.14.0` are ONLY available in the [legacy repo](https://github.com/helm/charts/tree/master/stable/airflow)
> - There were NO changes from `7.13.2` in this version

## 7.13.0 - 20XX-XX-XX
### Added
- `flower.oauthDomains`

## 7.12.0 - 20XX-XX-XX
### Added
- `ingress.web.labels`
- `ingress.flower.labels`
- `ingress.flower.precedingPaths`
- `ingress.flower.succeedingPaths`

## 7.11.0 - 20XX-XX-XX
### Added
- You can now use an externally created Secret to store airflow connections. (Rather than storing them in plain-text with `scheduler.connections`)
   - `scheduler.existingSecretConnections`

## 7.10.0 - 20XX-XX-XX
### Changed
- We now make use of the _CMD variables for `AIRFLOW__CORE__SQL_ALCHEMY_CONN_CMD`, `AIRFLOW__CELERY__RESULT_BACKEND_CMD`, and `AIRFLOW__CELERY__BROKER_URL_CMD`:
   - This fixes the Scheduler liveness probe implemented in `7.8.0`
   - This allows using `kubectl exec` to run commands like `airflow create_user`
- Configs passed with `airflow.config` are now passed as-defined in your values.yaml
   - This fixes an issue where people had to escape `"` characters in JSON strings

## 7.9.0 - 20XX-XX-XX
### Changed
- You can now give the airflow ServiceAccount GET/LIST on Event resources
   - This is needed for `KubernetesPodOperator(log_events_on_failure=True)`
   - To enable, set `rbac.events = true` (Default: `false`)

## 7.8.0 - 20XX-XX-XX
### Added
- The scheduler now has a liveness probe which will force the pod to restart if it becomes unhealthy for more than some threshold of time (default: 150sec)
   - __WARNING:__ this is on by default, but can be disabled with: `scheduler.livenessProbe.enabled`
   - `scheduler.livenessProbe.enabled`
   - `scheduler.livenessProbe.initialDelaySeconds`
   - `scheduler.livenessProbe.periodSeconds`
   - `scheduler.livenessProbe.failureThreshold`

### Changed
- Upgraded default airflow image to `1.10.12`

## 7.7.0 - 20XX-XX-XX
### Fixed 
- `redis.existingSecretKey` in `values.yaml` was corrected to `redis.existingSecretPasswordKey` (to align with [stable/redis](https://github.com/helm/charts/tree/master/stable/redis))

## 7.6.0 - 20XX-XX-XX

> 🟨 __NOTES__ 🟨
>
> - We now annotate all pods with `cluster-autoscaler.kubernetes.io/safe-to-evict` by default (disable using the `*.safeToEvict` values)
> - GKE's cluster-autoscaler will not honor a `gracefulTerminationPeriod` of more than 10min, if your jobs need more than this amount of time to finish, please set `workers.safeToEvict = false`

### Added
- You can now configure `safe-to-evict` annotations (so that pods with emptyDir Volumes can be evicted by cluster-autoscaler)
   - `flower.safeToEvict`
   - `scheduler.safeToEvict`
   - `web.safeToEvict`
   - `workers.safeToEvict`
- You can now create PodDisruptionBudgets for all components: {flower, webserver, worker}
   - `flower.podDisruptionBudget.*`
   - `web.podDisruptionBudget.*`
   - `workers.podDisruptionBudget.*`
- You can now run multiple instances of flower
   - `flower.replicas`
- You can now specify minReadySeconds for flower
   - `flower.minReadySeconds`
    
### Changed
- The chart YAML has been refactored
- Default values of embedded charts (postgres, redis) have been set with `safe-to-evit` annotations:
   - `postgresql.master.podAnnotations = {"cluster-autoscaler.kubernetes.io/safe-to-evict": "true"}`
   - `redis.master.podAnnotations = {"cluster-autoscaler.kubernetes.io/safe-to-evict": "true"}`
   - `redis.slave.podAnnotations = {"cluster-autoscaler.kubernetes.io/safe-to-evict": "true"}`
- The chart now forces the correct INTERNAL ports to be used (NOTE: this will not prevent you changing Service/Ingress ports)

## 7.5.0 - 20XX-XX-XX
### Added
- Added an ability to setup external database connection properties for TLS or other advanced parameters
   - `externalDatabase.properties`

## 7.4.0 - 20XX-XX-XX
### Added
- `workers.celery.gracefullTerminationPeriod`
   - __WARNING:__ if you currently use a high value of `workers.terminationPeriod`, consider lowering it to 60 and setting a high value for `workers.celery.gracefullTerminationPeriod`

### Changed
- Reduced how likely it is for a celery worker to receive SIGKILL with graceful termination enabled. New celery worker graceful shutdown lifecycle:
   1. prevent worker accepting new tasks
   1. wait AT MOST `workers.celery.gracefullTerminationPeriod` for tasks to finish
   1. send SIGTERM to worker
   1. wait AT MOST `workers.terminationPeriod` for kill to finish
   1. send SIGKILL to worker

## 7.3.0 - 20XX-XX-XX
### Added
- Added an ability to specify a specific port for Flower when using NodePort service type
   - `flower.service.nodePort.http`

## 7.2.0 - 20XX-XX-XX
### Added
- Fixed Flower's liveness probe when Basic Authentication is enabled for Flower. You can specify a basic auth value via a Kubernetes Secret using the values `flower.basicAuthSecret` and `flower.basicAuthSecretKey`. The secret value will get encoded and included in the liveness probe's header.

## 7.1.0 - 20XX-XX-XX
### Added
#### Feature Highlights:
- We have dramatically reduced the start time of airflow pods.
- This was mostly achieved by removing arbitrary delays in the start commands for airflow pods.
- If you still want these delays, please set the added `*.initialStartupDelay` to non-zero values.
- We have improved support for when `airflow.executor` is set to `KubernetesExecutor`:
   - redis configs/components are no longer deployed
   - we now set `AIRFLOW__KUBERNETES__NAMESPACE`, `AIRFLOW__KUBERNETES__WORKER_SERVICE_ACCOUNT_NAME`, and `AIRFLOW__KUBERNETES__ENV_FROM_CONFIGMAP_REF`
- We have fixed an error caused by including a `'` in your redis/postgres/mysql password.
- We have reverted a change in 7.0.0 which prevented the use of airflow docker images with embedded DAGs.
   - (Just ensure that `dags.initContainer.enabled` and `git.gitSync.enabled` are `false`)
- The `AIRFLOW__CORE__SQL_ALCHEMY_CONN`, `AIRFLOW__CELERY__RESULT_BACKEND`, and `AIRFLOW__CELERY__BROKER_URL` environment variables are now available if you `kubectl exec ...` into airflow Pods.
- We have improved the script used when `workers.celery.gracefullTermination` is `true`.
- We have fixed an error with pools in `scheduler.pools` not being added to the scheduler.
- We have fixed an error with the `scheduler.preinitdb` container not knowing the database connection string.

#### New Values:
- `scheduler.initialStartupDelay`
- `workers.initialStartupDelay`
- `flower.initialStartupDelay`
- `web.readinessProbe.enabled`
- `web.livenessProbe.enabled`

### Changed
- `airflow.fernetKey`
   - ~~Is now `""` by default, to enforce that users generate a custom one.~~
     ~~(However, please consider using `airflow.extraEnv` to define it from a pre-created secret)~~
     __(We have undone this change in `7.1.1`, but we still encourage you to set a custom fernetKey!)__
- `dags.installRequirements`
   - Is now `false` by default, as this was an unintended change with the 7.0.0 upgrade.

## 7.0.0 - 20XX-XX-XX

> 🟨 __NOTES__ 🟨
>
> - To read about versions `7.0.0` and before, please see the [legacy repo](https://github.com/helm/charts/tree/master/stable/airflow).

[Unreleased]: https://github.com/airflow-helm/charts/compare/airflow-8.9.0...HEAD
[8.9.0]: https://github.com/airflow-helm/charts/compare/airflow-8.8.0...airflow-8.9.0
[8.8.0]: https://github.com/airflow-helm/charts/compare/airflow-8.7.1...airflow-8.8.0
[8.7.1]: https://github.com/airflow-helm/charts/compare/airflow-8.7.0...airflow-8.7.1
[8.7.0]: https://github.com/airflow-helm/charts/compare/airflow-8.6.1...airflow-8.7.0
[8.6.1]: https://github.com/airflow-helm/charts/compare/airflow-8.6.0...airflow-8.6.1
[8.6.0]: https://github.com/airflow-helm/charts/compare/airflow-8.5.3...airflow-8.6.0
[8.5.3]: https://github.com/airflow-helm/charts/compare/airflow-8.5.2...airflow-8.5.3
[8.5.2]: https://github.com/airflow-helm/charts/compare/airflow-8.5.1...airflow-8.5.2
[8.5.1]: https://github.com/airflow-helm/charts/compare/airflow-8.5.0...airflow-8.5.1
[8.5.0]: https://github.com/airflow-helm/charts/compare/airflow-8.4.1...airflow-8.5.0
[8.4.1]: https://github.com/airflow-helm/charts/compare/airflow-8.4.0...airflow-8.4.1
[8.4.0]: https://github.com/airflow-helm/charts/compare/airflow-8.3.2...airflow-8.4.0
[8.3.2]: https://github.com/airflow-helm/charts/compare/airflow-8.3.1...airflow-8.3.2
[8.3.1]: https://github.com/airflow-helm/charts/compare/airflow-8.3.0...airflow-8.3.1
[8.3.0]: https://github.com/airflow-helm/charts/compare/airflow-8.2.0...airflow-8.3.0
[8.2.0]: https://github.com/airflow-helm/charts/compare/airflow-8.1.3...airflow-8.2.0
[8.1.3]: https://github.com/airflow-helm/charts/compare/airflow-8.1.2...airflow-8.1.3
[8.1.2]: https://github.com/airflow-helm/charts/compare/airflow-8.1.1...airflow-8.1.2
[8.1.1]: https://github.com/airflow-helm/charts/compare/airflow-8.1.0...airflow-8.1.1
[8.1.0]: https://github.com/airflow-helm/charts/compare/airflow-8.0.9...airflow-8.1.0
[8.0.9]: https://github.com/airflow-helm/charts/compare/airflow-8.0.8...airflow-8.0.9
[8.0.8]: https://github.com/airflow-helm/charts/compare/airflow-8.0.7...airflow-8.0.8
[8.0.7]: https://github.com/airflow-helm/charts/compare/airflow-8.0.6...airflow-8.0.7
[8.0.6]: https://github.com/airflow-helm/charts/compare/airflow-8.0.5...airflow-8.0.6
[8.0.5]: https://github.com/airflow-helm/charts/compare/airflow-8.0.4...airflow-8.0.5
[8.0.4]: https://github.com/airflow-helm/charts/compare/airflow-8.0.3...airflow-8.0.4
[8.0.3]: https://github.com/airflow-helm/charts/compare/airflow-8.0.2...airflow-8.0.3
[8.0.2]: https://github.com/airflow-helm/charts/compare/airflow-8.0.1...airflow-8.0.2
[8.0.1]: https://github.com/airflow-helm/charts/compare/airflow-8.0.0...airflow-8.0.1
[8.0.0]: https://github.com/airflow-helm/charts/compare/airflow-7.16.0...airflow-8.0.0
[7.16.0]: https://github.com/airflow-helm/charts/compare/airflow-7.15.0...airflow-7.16.0
[7.15.0]: https://github.com/airflow-helm/charts/compare/airflow-7.14.3...airflow-7.15.0
[7.14.3]: https://github.com/airflow-helm/charts/compare/airflow-7.14.2...airflow-7.14.3
[7.14.2]: https://github.com/airflow-helm/charts/compare/airflow-7.14.1...airflow-7.14.2
[7.14.1]: https://github.com/airflow-helm/charts/compare/airflow-7.14.0...airflow-7.14.1
[7.14.0]: https://github.com/airflow-helm/charts/compare/airflow-7.14.0...airflow-7.14.0