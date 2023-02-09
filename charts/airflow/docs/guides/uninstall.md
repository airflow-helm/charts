[🔗 Return to `Table of Contents` for more guides 🔗](../../README.md#guides)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](../../)

# Uninstall Guide

```shell
## set the release-name & namespace (must be same as previously installed)
export AIRFLOW_NAME="airflow-cluster"
export AIRFLOW_NAMESPACE="airflow-cluster"

## uninstall the chart
helm uninstall \
  "$AIRFLOW_NAME" \
  --namespace "$AIRFLOW_NAMESPACE"
```