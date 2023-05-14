[🔗 Return to `Table of Contents` for more guides 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#guides)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Quickstart Guide

## Step 1 - Prepare your Environment

- Kubernetes `1.18+`
- Helm `3.0+` ([installing helm](https://helm.sh/docs/intro/install/))
- (Optional) configure a Git repo with your DAG files ([loading dag definitions](../faq/dags/load-dag-definitions.md))
- (Optional) an external `PostgreSQL` or `MySQL` database ([connecting your database](../faq/database/external-database.md))
- (Optional) an external `Redis` database for `CeleryExecutor` ([connecting your redis](../faq/database/external-redis.md))

> 🟦 __Tip__ 🟦
>
> To deploy the `User-Community Airflow Helm Chart` you will need a Kubernetes cluster.
> <br>
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

## Step 2 - Add the Helm Repository

The following commands will add our repository to your helm:

```shell
## add this helm repository
helm repo add airflow-stable https://airflow-helm.github.io/charts

## update your helm repo cache
helm repo update
```

## Step 3 - Create your Custom Values File

Helm charts are configured with things called values, the full list of a chart's values are listed in a chart's `values.yaml` file
(which also sets the defaults).

The `User-Community Airflow Helm Chart` has an incredibly large number of values (over 1000!),
but don't get scared just yet, you can start by defining a few important values and grow your `custom-values.yaml` from there.

We recommend that you start your `custom-values.yaml` file from one of our samples:

- [`CeleryExecutor`](../../sample-values-CeleryExecutor.yaml)
- [`KubernetesExecutor`](../../sample-values-KubernetesExecutor.yaml)
- [`CeleryKubernetesExecutor`](../../sample-values-CeleryKubernetesExecutor.yaml)

> 🟦 __Tip__ 🟦
> 
> The following links should help you extend your `custom-values.yaml` to suit your needs:
>
> - [`Docs: Key Features`](../../README.md#key-features)
> - [`Docs: Frequently Asked Questions`](../../README.md#frequently-asked-questions)
> - [`Docs: Examples`](../../README.md#examples)
> - [`Docs: Helm Values`](../../README.md#helm-values)

> 🟦 __Tip__ 🟦
>
> If you need a refresher on YAML syntax, check out the following resources:
> 
> - [`Learn YAML in Y minutes`](https://learnxinyminutes.com/docs/yaml/)
> - [`YAML Multiline Strings`](https://yaml-multiline.info/)

## Step 4 - Install the Airflow Chart

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
  
## wait until the above command returns and resources become ready 
## (may take a while)
```

> 🟥 __Warning__ 🟥
>
> Always pin the `--version` so you don't unexpectedly update chart versions!

> 🟦 __Tip__ 🟦
>
> - find the full list of chart versions in our [CHANGELOG](https://github.com/airflow-helm/charts/blob/main/charts/airflow/CHANGELOG.md)
> - `Watch 👀 on GitHub` to be notified about new chart versions, click "watch" → "custom" → "releases".

## Step 5 - Access the Airflow UI

```shell
## port-forward the airflow webserver
kubectl port-forward svc/${AIRFLOW_NAME}-web 8080:8080 --namespace $AIRFLOW_NAMESPACE

## open your browser to: http://localhost:8080 
## (default login: `admin`/`admin`)
```

> 🟦 __Tip__ 🟦
>
> Learn more about authentication:
>
> - [`Manage Airflow Users`](../faq/security/airflow-users.md) 
> - [`Integrate Airflow with LDAP or OAUTH`](../faq/security/ldap-oauth.md)
