# Local Development with Skaffold

Developers sometimes also require to run Airflow locally in their own Kubernetes Cluster. This requires: 
 - Live Reload of Dags and
 - Local Docker Builds. 

 The tool [Skaffold](https://skaffold.dev/) helps you achieve these goals and make you more productive in developing Airflow dags. 

## Requirements

- [Helm 3](https://helm.sh/docs/intro/install/)
- [Skaffold](https://skaffold.dev/)

## Folder Structure

 This example assumes the following folder structure:

 ```
my-airflow/
├── dags/
│   └── my_dag.py
├── helm/
│   ├── Chart.yaml
│   └── values.yaml
├── Dockerfile
└── skaffold.yaml
```

where all dag fiels are placed in the `dags` folder and the `airflow` helm chart is referenced as a dependency in the `helm` folder: 

```yaml
# Chart.yaml
apiVersion: "v2"
name: "my-airflow"
description: "Helm chart for my-airflow"
type: application
version: "1.0.0"
appVersion: "7.14.0"
dependencies:
  - name: airflow
    version: 7.14.0
    repository: "https://airflow-helm.github.io/charts"
```

The local helm chart can now be referenced in the `skaffold.yaml` file so that the custom airflow helm chart can be deployed on your local or remote kubernetes cluster with Skaffold: 

```yaml
# skaffold.yaml
apiVersion: skaffold/v2beta1
kind: Config
build:
  artifacts:
    - image: airflow
      context: ./
      # enable live reload of all your dags directly into the pods dags folder
      sync:
        manual:
          - src: "dags/**/*.py"
            dest: dags
            strip: dags/
  local:
    useDockerCLI: true
deploy:
  helm:
    releases:
      - name: airflow
        chartPath: helm
        skipBuildDependencies: true
        values:
          airflow.airflow.image: airflow
        setValueTemplates:
          airflow.airflow.executor: KubernetesExecutor
          airflow.dags.persistence.enabled: false
          airflow.workers.enabled: false
          airflow.flower.enabled: false
          airflow.redis.enabled: false
          airflow.logs.persistence.enabled: true
          # ensure that also worker nodes contain dag live reload
          airflow.airflow.config.AIRFLOW__KUBERNETES__DAGS_IN_IMAGE: " True" # hack with whitespace because helm has otherwise issues with boolean values
        imageStrategy:
          helm: {}
portForward:
  - resourceType: service
    resourceName: airflow-web
    port: 8080
    localPort: 8080
```

The live-reload functionality of Skaffold avoids time expensive helm re-deployments because the Python files are synced directly within the worker and webserver pods.

For additional dependencies (e.g. pip), an own `Dockerfile` can be used: 

```Dockerfile
# Dockerfile
FROM apache/airflow:1.10.12-python3.6
RUN pip install --user fastavro
COPY dags dags
```

## Run locally

With this setup, you are able to deploy this helm chart with 

```
skaffold dev --port-forward
```

The Airflow web UI is accessible via http://localhost:8080. 
