[🔗 Return to `Table of Contents` for more guides 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#guides)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Quickstart Guide

> 🟦 __Tip__ 🟦
>
> To deploy the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow) you will need a Kubernetes cluster.
>
> The following table lists some popular Kubernetes distributions by platform.
>
> Platform | Kubernetes Distribution
> --- | ---
> Local Machine | [k3d](https://k3d.io/)
> Local Machine | [kind](https://kind.sigs.k8s.io/)
> Local Machine | [minikube](https://minikube.sigs.k8s.io/)
> Amazon Web Services | [Amazon Elastic Kubernetes Service (EKS)](https://aws.amazon.com/eks/)
> Microsoft Azure | [Azure Kubernetes Service (AKS)](https://azure.microsoft.com/en-au/services/kubernetes-service/)
> Google Cloud | [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine)
> Alibaba Cloud | [Alibaba Cloud Container Service for Kubernetes (ACK)](https://www.alibabacloud.com/product/kubernetes)
> IBM Cloud | [IBM Cloud Kubernetes Service (IKS)](https://www.ibm.com/cloud/kubernetes-service)

## STEP 1 - Prepare Your Environment

- Kubernetes `1.18+`
- Helm `3.0+` ([installing helm](https://helm.sh/docs/intro/install/))
- (Optional) configure a Git repo with your DAG files ([loading dag definitions](../faq/dags/load-dag-definitions.md))
- (Optional) an external `PostgreSQL` or `MySQL` database ([connecting your database](../faq/database/external-database.md))
- (Optional) an external `Redis` database for `CeleryExecutor` ([connecting your redis](../faq/database/external-redis.md))

## STEP 2 - Add the Helm Repository

```shell
## add this helm repository & pull updates from it
helm repo add airflow-stable https://airflow-helm.github.io/charts
helm repo update
```

## STEP 3 - Install the Airflow Chart

```shell
## set the release-name & namespace
export AIRFLOW_NAME="airflow-cluster"
export AIRFLOW_NAMESPACE="airflow-cluster"

## create the namespace
kubectl create ns "$AIRFLOW_NAMESPACE"

## install using helm 3
helm install \
  "$AIRFLOW_NAME" \
  airflow-stable/airflow \
  --namespace "$AIRFLOW_NAMESPACE" \
  --version "8.X.X" \
  --values ./custom-values.yaml
  
## wait until the above command returns (may take a while)
```

> 🟦 __Tip__ 🟦
>
> To create your  `./custom-values.yaml`, refer to our other documentation.
>
> - [Frequently Asked Questions](../..#frequently-asked-questions)
> - [Examples](../..#examples)
> - [Helm Values](../..#helm-values)

## STEP 4 - Access the Airflow UI

```shell
## port-forward the airflow webserver
kubectl port-forward svc/${AIRFLOW_NAME}-web 8080:8080 --namespace $AIRFLOW_NAMESPACE

## open your browser to: http://localhost:8080 
```

> 🟦 __Tip__ 🟦
>
> The default Airflow UI login is `admin`/`admin`.
>
> You may also [define your own users](../faq/security/airflow-users.md) or [integrate with your LDAP/OAUTH](../faq/security/ldap-oauth.md).
