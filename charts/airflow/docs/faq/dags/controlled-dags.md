[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Controlled Airflow DAGS

## Define with Plain-Text

You may use the `airflow.dags.controlled` value to set the [pause status for DAGs](https://airflow.apache.org/docs/apache-airflow/stable/concepts/dags.html#dag-pausing-deactivation-and-deletion) in a declarative way.

For example, to ensure that a DAG with the dag_id `RunDataExtractionCronDaily` is unpaused set:

```yaml
dags:
  controlled:
    RunDataExtractionCronDaily: true

## if we create a Deployment to perpetually sync `airflow.dags.controlled`
controlledUpdate: true

## if we should pause any dag that is not speicifed in `airflow.dags.controlled`
pauseUncontrolled: true
```
