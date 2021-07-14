# Airflow User Community Helm Charts

This chart is a user-community Helm Chart. Its "Powered by Apache Airflow" as stated by the
[Apache Trademark Rules](https://www.apache.org/foundation/marks/faq/#poweredby) but it is
not managed by the Apache Software Foundation.

If you want to raise issues about this chart, please raise them in this project, not
in the Apache Airflow one.

Historically, it was one of the most used Airflow Chart (formerly named "stable chart") before the
Apache Airflow project released their chart. You are free to continue to use the chart
as it is continuosly updated and maintained by the user community, however we are
working together with the Apache Airflow Community to help users to migrate to
the [Official Apache Airflow Communty chart](https://airflow.apache.org/docs/helm-chart/stable/index.html).

## Charts

| name | description |
| --- | --- |
| [charts/airflow](https://github.com/airflow-helm/charts/tree/main/charts/airflow) | the user community Airflow Helm Chart - used to deploy Airflow on Kubernetes

## Repo Usage

```sh
helm repo add airflow-stable https://airflow-helm.github.io/charts
helm repo update
```

## Contributing

Please refer to [CONTRIBUTING.md](https://github.com/airflow-helm/charts/tree/main/charts/airflow/CONTRIBUTING.md) for details.
