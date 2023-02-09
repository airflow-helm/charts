[🔗 Return to `Table of Contents` for more FAQ topics 🔗](../../../README.md#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](../../../)

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

  ## if we create a Deployment to perpetually sync `airflow.pools`
  poolsUpdate: true
```