# Airflow Helm Chart (User Community)

## Helm Charts

| Name | Description |
| --- | --- |
| [charts/airflow](https://github.com/airflow-helm/charts/tree/main/charts/airflow) | Airflow Helm Chart (User Community) - used to deploy Apache Airflow on Kubernetes

## Docker Images

| Name | Description |
| --- | --- |
| [images/pgbouncer](https://github.com/airflow-helm/charts/tree/main/images/pgbouncer) | a lightweight image used to run [PgBouncer](https://www.pgbouncer.org/)

## Helm Repo Usage

```sh
helm repo add airflow-stable https://airflow-helm.github.io/charts
helm repo update
```