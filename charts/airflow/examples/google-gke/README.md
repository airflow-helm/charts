[🔗 Return to `Table of Contents` for more examples 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#examples)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Example - Google Kubernetes Engine (GKE) 

## Purpose

This is intended to be a starting point for production deployments in GKE clusters.

## Contents

- [`custom-values.yaml`](custom-values.yaml): a starting point for your values file
- [`k8s_resources/`](k8s_resources): kubernetes manifests that you will need to edit and then apply to your cluster
   - [`Certificate/airflow-cluster1-cert`](k8s_resources/certificate.yaml)
   - [`Secret/airflow-cluster1-fernet-key`](k8s_resources/secret-fernet-key.yaml)
   - [`Secret/airflow-cluster1-mysql-credentials`](k8s_resources/secret-mysql-credentials.yaml)
   - [`Secret/airflow-cluster1-redis-password`](k8s_resources/secret-redis-password.yaml)
   - [`Secret/airflow-cluster1-git-secret`](k8s_resources/secret-git-secret.yaml)
   - [`Secret/airflow-cluster1-webserver-key`](k8s_resources/secret-webserver-key.yaml)

## Notes

- this example uses `CeleryExecutor`
- this example uses [GKE Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity), rather than storing GCP keyfiles
- airflow requires that `explicit_defaults_for_timestamp=1` in your MySQL instance

## Cluster Dependencies

- create a namespace called `airflow-cluster1`
- install [cert-manager](https://github.com/cert-manager/cert-manager) and create a `ClusterIssuer` called `letsencrypt-issuer`
- set up [GKE Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)

## External Dependencies

- Git repo for DAGs: `ssh://git@github.com:USERNAME/REPOSITORY.git`
- CloudSQL (MySQL): `mysql.example.com:3306`
- Cloud Storage Bucket: `gs://XXXXXXXX--airflow-cluster1/`
- SMTP server: `smtpmail.example.com`
- DNS A Record: `airflow-cluster1.example.com --> XXX.XXX.XXX.XXX`
- Google Service Account: `airflow-cluster1@MY_PROJECT_ID.iam.gserviceaccount.com`
- IAM Bindings:
   - Google Cloud Storage:
      - `gs://XXXXXXXX--airflow-cluster1`
         - `roles/storage.objectAdmin` --> `serviceAccount:airflow-cluster1@$MY_PROJECT_NAME.iam.gserviceaccount.com`
         - `roles/storage.legacyBucketReader` --> `serviceAccount:airflow-cluster1@$MY_PROJECT_NAME.iam.gserviceaccount.com`
   - Service Accounts:
      - `airflow-cluster1@MY_PROJECT_ID.iam.gserviceaccount.com`
         - `roles/iam.workloadIdentityUser` --> `MY_PROJECT_NAME.svc.id.goog[airflow-cluster1/airflow]`