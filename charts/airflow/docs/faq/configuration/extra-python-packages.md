[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Install Extra Python/Pip Packages

## Option 1 - Init Containers

You may use Pod [init-containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) to install pip packages during each Pod startup.

> 🟥 __Warning__ 🟥
>
> We strongly recommend you DO NOT use `extraPipPackages` in critical deployments.
> <br>
> Packages from PyPI can change unexpectedly between container restarts and break your environment.

> 🟦 __Tip__ 🟦
>
> Always pin a SPECIFIC package version like `torch==1.8.0` instead of `torch~=1.8.0`,
> this reduces the likelihood of inconsistent package versions across your cluster.

> 🟦 __Tip__ 🟦
>
> The `airflow.protectedPipPackages` value specifies a list of packages whose versions will be constrained to whatever was already installed in the image.
> <br>
> By default, we only protect the `apache-airflow` package, but you can extend `airflow.protectedPipPackages` with your own packages.

<details>
<summary>
  <b>Install on ALL Pods</b>
</summary>

---

The `airflow.extraPipPackages` value installs pip packages on all Airflow Pods.

For example, to install `torch` on all Airflow Pods:

```yaml
airflow:
  extraPipPackages:
    - "torch==1.8.0"
```

> 🟨 __Note__ 🟨
> 
> Global packages defined in `airflow.extraPipPackages` will NOT be installed in the KubernetesExecutor pod template.

</details>

<details>
<summary>
  <b>Install on Scheduler Pods</b>
</summary>

---

The `scheduler.extraPipPackages` value installs pip packages on the Airflow Scheduler Pods.

For example, to install `torch` on the Scheduler Pods only:

```yaml
scheduler:
  extraPipPackages:
    - "torch==1.8.0"
```

> 🟦 __Tip__ 🟦
>
> If the same package is defined in both `airflow.extraPipPackages` and `scheduler.extraPipPackages`, 
> the version in `scheduler.extraPipPackages` will take precedence.
>
> This is because packages from deployment-specific values are listed at the END of the `pip install` command.

</details>

<details>
<summary>
  <b>Install on Worker Pods (CeleryExecutor)</b>
</summary>

---

The `worker.extraPipPackages` value installs pip packages on the Airflow Worker Pods.

For example, to install `torch` on the Worker Pods only:

```yaml
worker:
  extraPipPackages:
    - "torch==1.8.0"
```

> 🟦 __Tip__ 🟦
>
> If the same package is defined in both `airflow.extraPipPackages` and `worker.extraPipPackages`, 
> the version in `worker.extraPipPackages` will take precedence.
>
> This is because packages from deployment-specific values are listed at the END of the `pip install` command.

</details>

<details>
<summary>
  <b>Install on Pod Template (KubernetesExecutor)</b>
</summary>

---

The `airflow.kubernetesPodTemplate.extraPipPackages` value installs pip packages in the KubernetesExecutor Pod Template.

For example, to install `torch` on the KubernetesExecutor Pod Template only:

```yaml
airflow:
  kubernetesPodTemplate:
    extraPipPackages:
      - "torch==1.8.0"
```

> 🟨 __Note__ 🟨
> 
> Global packages defined in `airflow.extraPipPackages` will NOT be installed in the KubernetesExecutor pod template.

</details>

<details>
<summary>
  <b>Install on Flower Pods</b>
</summary>

---

The `flower.extraPipPackages` value installs pip packages on the Flower Pods.

For example, to install `torch` on the Flower Pods only:

```yaml
flower:
  extraPipPackages:
    - "torch==1.8.0"
```

> 🟦 __Tip__ 🟦
>
> If the same package is defined in both `airflow.extraPipPackages` and `flower.extraPipPackages`, 
> the version in `flower.extraPipPackages` will take precedence.
>
> This is because packages from deployment-specific values are listed at the END of the `pip install` command.

</details>

<details>
<summary>
  <b>Install from PRIVATE pip Index</b>
</summary>

---

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

</details>

## Option 2 - Embedded Into Container Image

You may embed your python packages directly into the container image.

> 🟩 __Suggestion__ 🟩
> 
> This is the __suggested method__ for installing extra python packages.

<details>
<summary>
  <b>Example</b>
</summary>

---

This chart uses the official [`apache/airflow`](https://hub.docker.com/r/apache/airflow) Docker images.

Here is a Dockerfile that extends `apache/airflow:2.6.3-python3.9` with the `torch` package:

```dockerfile
FROM apache/airflow:2.6.3-python3.9

# install your pip packages
RUN pip install --no-cache-dir \
    torch~=1.8.0
```

You might then build and tag this Dockerfile as `MY_REPO:MY_TAG`.

The following values tell the chart to use the `MY_REPO:MY_TAG` container image:

```yaml
airflow:
  image:
    repository: MY_REPO
    tag: MY_TAG
        
    ## WARNING: even if set to "Always" DO NOT reuse tag names, 
    ##          containers only pull the latest image when restarting
    pullPolicy: IfNotPresent
```

> 🟥 __Warning__ 🟥
>
> Ensure that you NEVER REUSE an image tag name.
> <br>
> This ensures that whenever you update `airflow.image.tag`, all airflow pods will restart and have the same packages.
> <br>
> For example, you may append a version or git hash corresponding to your packages:
>
> 1. `MY_REPO:MY_TAG-v1`, `MY_REPO:MY_TAG-v2`, `MY_REPO:MY_TAG-v3`
> 2. `MY_REPO:MY_TAG-0.1.0`, `MY_REPO:MY_TAG-0.1.1`, `MY_REPO:MY_TAG-0.1.3`
> 3. `MY_REPO:MY_TAG-a1a1a1a`, `MY_REPO:MY_TAG-a2a2a3a`, `MY_REPO:MY_TAG-a3a3a3a`

</details>