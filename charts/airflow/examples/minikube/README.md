[🔗 Return to `Table of Contents` for more examples 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#examples)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Example - Minikube / Kind / K3D

## Purpose

This is intended to be a starting point for non-production local deployments (like `Minikube`, `Kind` and `k3d`).

## Contents

- [`custom-values.yaml`](custom-values.yaml): a starting point for your values file

## Notes

- this example uses `CeleryExecutor`
- this example assumes your DAGs git repo is publicly accessible through HTTP

## External Dependencies

- Git repo for DAGs: `https://github.com/USERNAME/REPOSITORY.git`