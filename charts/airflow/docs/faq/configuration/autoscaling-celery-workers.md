[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Configure Celery Worker Autoscaling

> 🟨 __Note__ 🟨
>
> This method of autoscaling is not ideal. 
> There is not necessarily a link between RAM usage, and the number of pending tasks, 
> meaning you could have a situation where your workers don't scale up despite having pending tasks.
> 
> We are planning to implement an airflow-task aware autoscaler in a future chart release.

The Airflow Celery Workers can be scaled using the [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/), 
to enable autoscaling, you must set `workers.autoscaling.enabled=true`, then provide `workers.autoscaling.maxReplicas`.

Assume every task a worker executes consumes approximately `200Mi` memory, that means memory is a good metric for utilisation monitoring.
For a worker pod you can calculate it: `WORKER_CONCURRENCY * 200Mi`, so for `10 tasks` a worker will consume `~2Gi` of memory.
In the following config if a worker consumes `80%` of `2Gi` (which will happen if it runs 9-10 tasks at the same time), 
an autoscaling event will be triggered, and a new worker will be added.
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

  logCleanup:
    resources:
      requests:
        ## IMPORTANT! for autoscaling to work with logCleanup
        memory: "64Mi"

dags:
  gitSync:
    resources:
      requests:
        ## IMPORTANT! for autoscaling to work with gitSync
        memory: "64Mi"
```