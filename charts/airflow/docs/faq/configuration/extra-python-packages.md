[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# How to install extra python packages?

## Option 1 - use init-containers

> 🟥 __Warning__ 🟥
>
> We __strongly advice__ that you DO NOT USE "Option 1" in production, as PyPI packages may change unexpectedly between container restarts.

### Install on all Airflow Pods

You may use the `airflow.extraPipPackages` value to install pip packages on all airflow Pods.

For example, to install PyTorch on all scheduler/web/worker/flower Pods:

```yaml
airflow:
  extraPipPackages:
    - "airflow-exporter~=1.4.1"
```

### Install on Scheduler only

You may use the `scheduler.extraPipPackages` value to install pip packages on the airflow scheduler Pods.

For example, to install PyTorch on the scheduler Pods only:

```yaml
scheduler:
  extraPipPackages:
    - "torch~=1.8.0"
```

> 🟦 __Tip__ 🟦
>
> If a package is defined in both `airflow.extraPipPackages` and `scheduler.extraPipPackages`, the version in the latter will take precedence.
>
> This is because we list packages from deployment-specific values at the end of the `pip install ...` command.

### Install on Worker only

You may use the `worker.extraPipPackages` value to install pip packages on the airflow worker Pods.

For example, to install PyTorch on the worker Pods only:

```yaml
worker:
  extraPipPackages:
    - "torch~=1.8.0"
```

### Install on Flower only

You may use the `flower.extraPipPackages` value to install pip packages on the flower Pods.

For example, to install PyTorch on the flower Pods only:

```yaml
flower:
  extraPipPackages:
    - "torch~=1.8.0"
```

### Install from Private pip index

Pip can install packages from a private Python Package Index using the `--index-url` argument or `PIP_INDEX_URL` environment variable.

For example, to install `my-internal-package` from a private index hosted at `example.com/packages/simple/`:

```yaml
airflow:
  config:
    ## pip configs can be set with environment variables
    PIP_TIMEOUT: 60
    PIP_INDEX_URL: https://<username>:<password>@example.com/packages/simple/
    PIP_TRUSTED_HOST: example.com
  
  extraPipPackages:
    - "my-internal-package==1.0.0"
```

## Option 2 - embedded into container image (recommended)

This chart uses the official [apache/airflow](https://hub.docker.com/r/apache/airflow) images, you may extend the airflow container image with your pip packages.

For example, here is a Dockerfile that extends `airflow:2.1.4-python3.8` with the `torch` package:

```dockerfile
FROM apache/airflow:2.1.4-python3.8

# install your pip packages
RUN pip install --no-cache-dir \
    torch~=1.8.0
```

After building and tagging your Dockerfile as `MY_REPO:MY_TAG`, you may use it with the chart by specifying `airflow.image.*`:

```yaml
airflow:
  image:
    repository: MY_REPO
    tag: MY_TAG
        
    ## WARNING: even if set to "Always" do not reuse tag names, as containers only pull the latest image when restarting
    pullPolicy: IfNotPresent
```

> 🟥 __Warning__ 🟥
>
> Ensure that you never reuse an image tag name.
> This ensures that whenever you update `airflow.image.tag`, all airflow pods will restart with the latest pip-packages.
>
> For example, you may append a version or git hash corresponding to your pip-packages:
>
> 1. `MY_REPO:MY_TAG-v1`, `MY_REPO:MY_TAG-v2`, `MY_REPO:MY_TAG-v3`
> 2. `MY_REPO:MY_TAG-0.1.0`, `MY_REPO:MY_TAG-0.1.1`, `MY_REPO:MY_TAG-0.1.3`
> 3. `MY_REPO:MY_TAG-a1a1a1a`, `MY_REPO:MY_TAG-a2a2a3a`, `MY_REPO:MY_TAG-a3a3a3a`
