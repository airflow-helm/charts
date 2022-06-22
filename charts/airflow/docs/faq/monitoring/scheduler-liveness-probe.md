[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Configure Scheduler Liveness Probe

## Scheduler "Heartbeat Check"

The chart includes a [Kubernetes Liveness Probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
for each airflow scheduler which regularly queries the Airflow Metadata Database to ensure the scheduler is ["healthy"](https://airflow.apache.org/docs/apache-airflow/stable/logging-monitoring/check-health.html).

A scheduler is "healthy" if it has had a "heartbeat" in the last `AIRFLOW__SCHEDULER__SCHEDULER_HEALTH_CHECK_THRESHOLD` seconds.
Each scheduler will perform a "heartbeat" every `AIRFLOW__SCHEDULER__SCHEDULER_HEARTBEAT_SEC` seconds by updating the `latest_heartbeat` of its `SchedulerJob` in the Airflow Metadata `jobs` table.

By default, the chart runs a liveness probe every __30 seconds__ (`periodSeconds`), and will restart a scheduler if __5 probe failures__ (`failureThreshold`) occur in a row.
This means a scheduler must be unhealthy for at least `30 x 5 = 150` seconds before Kubernetes will automatically restart a scheduler Pod.

Here is an overview of the `scheduler.livenessProbe.*` values:

```yaml
scheduler:
  livenessProbe:
    enabled: true
    
    ## number of seconds to wait after a scheduler container starts before running its first probe
    ## NOTE: schedulers take a few seconds to actually start
    initialDelaySeconds: 10
    
    ## number of seconds to wait between each probe
    periodSeconds: 30
    
    ## maximum number of seconds that a probe can take before timing out
    ## WARNING: if your database is very slow, you may need to increase this value to prevent invalid scheduler restarts
    timeoutSeconds: 60
    
    ## maximum number of consecutive probe failures, after which the scheduler will be restarted
    ## NOTE: a "failure" could be any of:
    ##  1. the probe takes more than `timeoutSeconds`
    ##  2. the probe detects the scheduler as "unhealthy"
    ##  3. the probe "task creation check" fails
    failureThreshold: 5
```

> 🟥 __Warning__ 🟥
>
> A scheduler can have a "heartbeat" but be deadlocked such that it's unable to schedule new tasks,
> the ["task creation check"](#scheduler-task-creation-check) should detect these situations and force a scheduler restart.
> 
> - https://github.com/apache/airflow/issues/7935 - patched in airflow `2.0.2`
> - https://github.com/apache/airflow/issues/15938 - patched in airflow `2.1.1`

## Scheduler "Task Creation Check"

The liveness probe can additionally check if the Scheduler is creating new [tasks](https://airflow.apache.org/docs/apache-airflow/stable/concepts/tasks.html) as an indication of its health.
This check works by ensuring that the most recent `LocalTaskJob` had a `start_date` no more than `scheduler.livenessProbe.taskCreationCheck.thresholdSeconds` seconds ago.

> 🟦 __Tip__ 🟦
>
> The "Task Creation Check" is currently disabled by default, it can be enabled with `scheduler.livenessProbe.taskCreationCheck.enabled`.

Here is an overview of the `scheduler.livenessProbe.taskCreationCheck.*` values:

```yaml
scheduler:
  livenessProbe:
    enabled: true
    
    taskCreationCheck:
      ## if the task creation check is enabled
      enabled: true

      ## the maximum number of seconds since the start_date of the most recent LocalTaskJob
      ## WARNING: must be AT LEAST equal to your shortest DAG schedule_interval
      ## WARNING: DummyOperator tasks will NOT be seen by this probe
      thresholdSeconds: 300
      
      ## minimum number of seconds the scheduler must have run before the task creation check begins
      ## WARNING: must be long enough for the scheduler to boot and create a task
      ##
      schedulerAgeBeforeCheck: 180
```

> 🟦 __Tip__ 🟦
>
> You might use the following `canary_dag` DAG definition to run a small task every __300 seconds__ (5 minutes).
> 
> ```python
> from datetime import datetime, timedelta
> from airflow import DAG
> 
> # import using try/except to support both airflow 1 and 2
> try:
>     from airflow.operators.bash import BashOperator
> except ModuleNotFoundError:
>     from airflow.operators.bash_operator import BashOperator
> 
> dag = DAG(
>     dag_id="canary_dag",
>     default_args={
>         "owner": "airflow",
>     },
>     schedule_interval="*/5 * * * *",
>     start_date=datetime(2022, 1, 1),
>     dagrun_timeout=timedelta(minutes=5),
>     is_paused_upon_creation=False,
>     catchup=False,
> )
> 
> # WARNING: while `DummyOperator` would use less resources, the check can't see those tasks 
> #          as they don't create LocalTaskJob instances
> task = BashOperator(
>     task_id="canary_task",
>     bash_command="echo 'Hello World!'",
>     dag=dag,
> )
> ```