[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Integrate Airflow with Prometheus

> 🟨 __Note__ 🟨
>
> We are planning to implement native Prometheus/StatsD support in a future chart release.

To be able to expose Airflow metrics to Prometheus you will need install a plugin, 
one option is [epoch8/airflow-exporter](https://github.com/epoch8/airflow-exporter) which exports DAG and task metrics from Airflow.

A [ServiceMonitor](https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/api.md#servicemonitor) 
is a resource introduced by the [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator), 
for more information, see the `serviceMonitor` section of `values.yaml`.