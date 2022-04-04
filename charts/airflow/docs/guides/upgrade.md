[🔗 Return to `Table of Contents` for more guides 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#guides)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Upgrade Guide

> 🟦 __Tip__ 🟦
>
> Always consult the [CHANGELOG](../../CHANGELOG.md) before upgrading chart versions.

> 🟦 __Tip__ 🟦
>
> Always pin a specific `--version X.X.X` rather than installing the latest version.

```shell
## pull updates from the helm repository
helm repo update

## set the release-name & namespace (must be same as previously installed)
export AIRFLOW_NAME="airflow-cluster"
export AIRFLOW_NAMESPACE="airflow-cluster"

## apply any changed `custom-values.yaml` AND upgrade the chart to version `8.X.X`
helm upgrade \
  "$AIRFLOW_NAME" \
  airflow-stable/airflow \
  --namespace "$AIRFLOW_NAMESPACE" \
  --version "8.X.X" \
  --values ./custom-values.yaml
```