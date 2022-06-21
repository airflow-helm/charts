[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Manage Airflow Logs Cleanup

> 🟥 __Warning__ 🟥
>
> If `logs.persistence.enabled` is `true`, then `scheduler.logCleanup.enabled` and `workers.logCleanup.enabled` must be `false`.
>
> This is to prevent multiple log-cleanup sidecars attempting to delete the same logs files at the same time.
> We are planning to implement a central log-cleanup deployment in a future release that will work with log persistence.

## Scheduler

By default, this chart deploys each airflow scheduler Pod with a sidecar that deletes log files last-modified more than `scheduler.logCleanup.retentionMinutes` minutes ago.
This helps prevent excessive log buildup within the Pod's filesystem.

You may disable or configure the log-cleanup sidecar with the `scheduler.logCleanup.*` values:

```yaml
scheduler:
  logCleanup:
    ## WARNING: must be disabled if `logs.persistence.enabled` is `true`
    enabled: true

    ## the number of minutes to retain log files (by last-modified time)
    retentionMinutes: 21600

    ## the number of seconds between each check for files to delete
    intervalSeconds: 900
```

## CeleryExecutor Workers

By default, this chart deploys each airflow CeleryExecutor worker Pod with a sidecar that deletes log files last-modified more than `workers.logCleanup.retentionMinutes` minutes ago.
This helps prevent excessive log buildup within the Pod's filesystem.

You may disable or configure the log-cleanup sidecar with the `workers.logCleanup.*` values:

```yaml
workers:
  logCleanup:
    ## WARNING: must be disabled if `logs.persistence.enabled` is `true`
    enabled: true

    ## the number of minutes to retain log files (by last-modified time)
    retentionMinutes: 21600

    ## the number of seconds between each check for files to delete
    intervalSeconds: 900
```