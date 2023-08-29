[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Manage Airflow Pools

You may use the `airflow.pools` value to create airflow [Pools](https://airflow.apache.org/docs/apache-airflow/stable/concepts.html#pools) in a declarative way.

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
      ## if deferred tasks count towards the slot limit, requires airflow 2.7.0+ (default: false)
      #include_deferred: false

  ## if we create a Deployment to perpetually sync `airflow.pools`
  poolsUpdate: true
```

We also provide the ability to automatically scale the number of pool slots, on a schedule:

```yaml
airflow:
  pools:
    - name: "pool_1"
      description: "example pool with 2 cron policies"
      
      ## the value of `slots` is ignored when `policies` is non-empty, but it must be set to an arbitrary value
      slots: 0
      
      ## at each sync interval, the policy with the most recently past `recurrence` is applied
      policies:

         ## POLICY: scale to 50 slots after 7:00pm UTC every day
         - name: "scale up at 7pm UTC"
           slots: 50
           ## the `recurrence` is any expression that would be accepted by the `croniter` python library
           recurrence: "0 19 * * *"
           
         ## POLICY: scale to 10 slots after 6:00am UTC every day
         - name: "scale down at 6am UTC"
           slots: 10
           recurrence: "0 6 * * *"
    
  ## if `poolsUpdate` is false, the `policies` are NOT applied, and the `slots` value is used
  poolsUpdate: true
```

> 🟦 __Tip__ 🟦
>
> At each sync interval, the policy with the most recently past `recurrence` is applied.
> 
> This means that when considering the above example:
> - if the pool does not have 50 slots at any time after 7:00pm UTC (but before 6:00am UTC), it will be scaled to 50 slots
> - if the pool does not have 10 slots at any time after 6:00am UTC (but before 7:00pm UTC), it will be scaled to 10 slots

> 🟦 __Tip__ 🟦
>
> As pools are only synced every 60 seconds, your `recurrence` should be set to an expression which occurs LESS frequently than this.
