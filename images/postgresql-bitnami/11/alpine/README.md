# PostgreSQL Docker Image

The Apache Airflow helm chart under [charts/airflow](https://github.com/airflow-helm/charts/tree/main/charts/airflow) uses this docker image to implement [PostgreSQL](https://www.postgresql.org/) support.

### Important Links:
- The [Dockerfile](https://github.com/airflow-helm/charts/blob/main/images/postgresql-bitnami/11/alpine/Dockerfile) for this image.
- The [CHANGELOG.md](https://github.com/airflow-helm/charts/blob/main/images/postgresql-bitnami/11/alpine/CHANGELOG.md) for this image.

### Pull Locations:
- [DockerHub](https://hub.docker.com/r/airflowhelm/postgresql-bitnami):
  - `docker pull airflowhelm/postgresql-bitnami:latest`
- [GitHub Container Registry](http://ghcr.io/airflow-helm/postgresql-bitnami):
  - `docker pull ghcr.io/airflow-helm/postgresql-bitnami:latest`

### Notes About Building for ARM:
- Building this image for `arm64` using QEMU emulation will likely never finish (for example, inside a GitHub Action).
- You must use a local ARM device (like an Apple Silicon Mac) to build for `arm64`.
- Build Steps:
   1. create a PR suggesting changes under `./images/postgresql-bitnami/11/alpine/*`
   2. clone your PR source repo onto an ARM device (ensure you checkout the EXACT commit of your PR)
   3. [authorize `docker` with a GitHub Token for writing to `ghcr.io`](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry)
   4. build the Dockerfile, and cache all layers to our [`ci/images/postgresql-bitnami/11/alpine`](https://ghcr.io/airflow-helm/ci/images/postgresql-bitnami/11/alpine) package:
       - `cd images/postgresql-bitnami/11/alpine`
       - `docker buildx build --cache-to=type=registry,ref=ghcr.io/airflow-helm/ci/images/postgresql-bitnami/11/alpine,mode=max .`
