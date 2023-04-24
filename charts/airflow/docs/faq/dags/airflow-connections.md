[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Manage Airflow Connections

Airflow Connections are typically [created](https://airflow.apache.org/docs/apache-airflow/stable/howto/connection.html#creating-a-connection-with-the-ui) 
and [updated](https://airflow.apache.org/docs/apache-airflow/stable/howto/connection.html#editing-a-connection-with-the-ui) using the WebUI, 
but this can be dangerous as it makes your Airflow environment dependent on _manual post-install steps_, 
leaving you vulnerable to users making unexpected changes.

To solve this and other issues, the chart provides the `airflow.connections` value to specify a list of connections that will be automatically synced into your airflow deployment.

> 🟦 __Tip__ 🟦
>
> See our [examples](#examples) to learn more about `airflow.connections`.

## How to define a connection?

All `airflow.connections` must have an `id` and `type` specified, but the meaning of other attributes will depend on the `type`.

```yaml
airflow: 
  connections:
    - ## "Connection Id" (required)
      id: ...
      
      ## "Connection Type" (required)
      type: ...
      
      ## "Description"
      description: ...
      
      ## "Host" (supports `airflow.connectionsTemplates`)
      host: ...
      
      ## "Port"
      port: ...
      
      ## "Schema" (supports `airflow.connectionsTemplates`)
      schema: ...
      
      ## "Login" (supports `airflow.connectionsTemplates`)
      login: ...
      
      ## "Password" (supports `airflow.connectionsTemplates`)
      password: ...
            
      ## "Extra" (supports `airflow.connectionsTemplates`)
      extra: ...
```

## How are connections synced?

The chart will automatically sync connections into the airflow metadata database,
how this sync is performed will depend on the value of `airflow.connectionsUpdate`.

When `airflow.connectionsUpdate` is `true`:

- The chart uses a Deployment that syncs connections every 60 seconds
- _NOTE: a sync also occurs when a Secret/ConfigMap referenced in `airflow.connectionsTemplates` is updated_

When `airflow.connectionsUpdate` is `false`:

- The chart uses a [`post-install` hook](https://helm.sh/docs/topics/charts_hooks/) to run a sync Job after each `helm upgrade`
- _NOTE: this means that connections are only synced when running `helm upgrade`_

> 🟥 __Warning__ 🟥
>
> When using ArgoCD you must set `airflow.connectionsUpdate` to `true`,
> otherwise you may encounter "field is immutable" errors from the `post-install` Job.

## How to delete a connection?

The sync process is unable to delete connections as it ignores everything not listed in `airflow.connections`,
to fully remove a connection you must:

1. Remove it from your `airflow.connections` value
2. Manually delete it with the Airflow WebUI or CLI

## How to store connections in Secrets and ConfigMaps?

Sometimes you may wish to use Secrets or ConfigMaps within your connection definitions rather 
than storing them in plain-text, the chart enables this with the `airflow.connectionsTemplates` value.

The keys of `airflow.connectionsTemplates` become [`$`-based templates](https://docs.python.org/3/library/string.html#template-strings) 
inside the `host`, `schema`, `login`, `password` and `extra` string fields.

> 🟦 __Tip__ 🟦
>
> See our [examples](#examples) about "Secret Templates" to learn more about `airflow.connectionsTemplates`.

## How to integrate with external _secret management systems_?

Updates to Secrets used in `airflow.connectionsTemplates` are automatically propagated to the `airflow.connections` which reference them.

This behaviour enables using the [`ExternalSecret`](https://external-secrets.io/latest/api/externalsecret/) CRD from
[External Secrets Operator](https://github.com/external-secrets/external-secrets) to integrate with many popular 
_secret management systems_, for example:

- [AWS Secrets Manager](https://external-secrets.io/latest/provider/aws-secrets-manager/)
- [Azure Key Vault](https://external-secrets.io/latest/provider/azure-key-vault/)
- [Google Secret Manager](https://external-secrets.io/latest/provider/google-secrets-manager/)
- [HashiCorp Vault](https://external-secrets.io/latest/provider/hashicorp-vault/)

## How to include special characters in `extra`?

The `extra` field must be a valid JSON object, this means you must escape any special JSON characters in your strings.

For example, this connection includes an `extra` JSON object with values that contain `newlines` and `"`:

```yaml
airflow: 
  connections:
    - id: ...
      type: ...
      extra: |
        {
          "key_1": "line_one\n line_two\n special_\"_chars\n line_four\n"
        }
```

> 🟦 __Tip__ 🟦
> 
> The following Python function may be used to generate an escaped JSON string:
> 
> ```python
> import json
> 
> raw_string = """line_one\n line_two\n special_"_chars\n line_four\n"""
> 
> # NOTE: `json.dumps()` adds `"` around the string
> escaped_string = json.dumps(raw_string)
> 
> print("-------- BEGIN RAW STRING --------")
> print(raw_string)
> print("-------- END RAW STRING ----------")
> 
> print("-------- BEGIN ESCAPED STRING --------")
> print(escaped_string)
> print("-------- END ESCAPED STRING ----------")
> ```

# Examples

The following examples demonstrate common connection `type`s which you may find useful.

This is NOT a comprehensive list of connection `type`s, see the [full list in airflow's official docs](https://airflow.apache.org/docs/apache-airflow-providers/core-extensions/connections.html).

> 🟦 __Tip__ 🟦
> 
> Click the `▶` symbol to expand the examples.

## AWS Connection 

The `apache-airflow-providers-amazon` provider package contains the `"aws"` connection type.

The following are some options for defining [`"aws"` type connections](https://airflow.apache.org/docs/apache-airflow-providers-amazon/stable/connections/aws.html) using this chart.

<details>
<summary>
  <a id="aws-connection---plain-text" class="anchor"></a>
  <b>Option 1: Plain Text</b>
</summary>

The following values will create an `"aws"` type connection called `my_aws` using a token stored in plain-text:

```yaml
airflow: 
  connections:
    - id: my_aws
      type: aws
      description: my AWS connection
      
      ## your `AWS_ACCESS_KEY_ID`
      login: XXXXXXXX
      
      ## your `AWS_SECRET_ACCESS_KEY`
      password: XXXXXXXX
      
      ## see the official "aws" connection docs for valid extra configs
      extra: |
        {
          "region_name": "eu-central-1"
        }
```

> 🟥 __Warning__ 🟥
>
> Rather than storing `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in plain-text within your values, consider using:
>
> - [`Option 2: Secret Templates`](#aws-connection---secret-templates)
> - [`Option 3: EKS IAM roles for service accounts`](#aws-connection---eks-iam-roles-for-service-accounts) 

</details>

<details>
<summary>
  <a id="aws-connection---secret-templates"></a>
  <b>Option 2: Secret Templates</b>
</summary>

The following values will create an `"aws"` type connection called `my_aws` using a token stored in `Secret/my-aws-token`:

```yaml
airflow: 
  connections:
    - id: my_aws
      type: aws
      description: my AWS connection
      
      ## this string template is defined by `airflow.connectionsTemplates.ACCESS_KEY_ID` 
      login: ${ACCESS_KEY_ID}
      
      ## this string template is defined by `airflow.connectionsTemplates.SECRET_ACCESS_KEY` 
      password: ${SECRET_ACCESS_KEY}
      
      ## see the official "aws" connection docs for valid extra configs
      extra: |
        {
          "region_name": "eu-central-1"
        }

  connectionsTemplates:
    ## extracts the value of AWS_ACCESS_KEY_ID from `Secret/my-aws-token`
    ACCESS_KEY_ID:
      kind: secret
      name: my-aws-token
      key: AWS_ACCESS_KEY_ID

    ## extracts the value of AWS_SECRET_ACCESS_KEY from `Secret/my-aws-token`
    SECRET_ACCESS_KEY:
      kind: secret
      name: my-aws-token
      key: AWS_SECRET_ACCESS_KEY
```

> 🟦 __Tip__ 🟦
>
> You may create the `Secret` called `my-aws-token` with `kubectl`.
> 
> ```shell
> kubectl create secret generic \
>   my-aws-token \
>   --from-literal=AWS_ACCESS_KEY_ID='xxxxxxxxxxxxxxxxxxxx' \
>   --from-literal=AWS_SECRET_ACCESS_KEY='aaaaaaaaaaaaa/bbbbbbb/cccccccccccccccccc' \
>   --namespace my-airflow-namespace
> ```

</details>

<details>
<summary>
  <a id="aws-connection---eks-iam-roles-for-service-accounts"></a>
  <b>Option 3: EKS IAM roles for service accounts (recommended)</b>
</summary>

If you are running on EKS, it is usually preferable to use [IAM roles for service accounts (IRSA)](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html),
which removes the need to provide `AWS_ACCESS_KEY_ID` or `AWS_SECRET_ACCESS_KEY`.

The following values will create an `"aws"` type connection called `my_aws` that will use IRSA:

```yaml
airflow:
  connections:
    - id: my_aws
      type: aws
      description: my AWS connection

      ## NOTE: don't provide `login` or `password`,
      ##       otherwise they will take precedence over the ones injected by IRSA
      extra: |
        {
          "region_name": "eu-central-1"
        }
      
      ## NOTE: airflow supports cross-account AWS access through the usual assume_role method,
      ##       you can provide the ARN of the role to assume under the "role_arn" field of "extra"
      #extra: |
      #  {
      #    "role_arn": "arn:aws:iam::YYYYYYYYYYY:role/Cross-Account-Role",
      #    "region_name": "eu-central-1"
      #  }

serviceAccount:
  annotations:
    # replace with the AWS role you have configured for IRSA
    eks.amazonaws.com/role-arn: "arn:aws:iam::XXXXXXXXXX:role/<<MY_ROLE_NAME>>"
```

</details>

## GCP Connection

The `apache-airflow-providers-google` provider package contains the `"google_cloud_platform"` connection type.

The following are some options for defining [`"google_cloud_platform"` type connections](https://airflow.apache.org/docs/apache-airflow-providers-google/stable/connections/gcp.html) using this chart.

<details>
<summary>
  <a id="gcp-connection---secret-keyfile"></a>
  <b>Option 1: Secret Keyfile</b>
</summary>

The following values will create a `"google_cloud_platform"` type connection called `my_gcp` that will use a `keyfile.json` from `Secret/my-gcp-keyfile`:

```yaml
airflow:
  connections:
    - id: my_gcp
      type: google_cloud_platform
      description: my GCP connection
      
      ## see the official "google_cloud_platform" connection docs for valid extra configs
      extra: |
        {
          "extra__google_cloud_platform__key_path": "/opt/airflow/secrets/gcp-keyfile/keyfile.json",
          "extra__google_cloud_platform__num_retries": 5
        }

  extraVolumeMounts:
    - name: gcp-keyfile
      mountPath: /opt/airflow/secrets/gcp-keyfile
      readOnly: true

  extraVolumes:
    - name: gcp-keyfile
      secret:
        ## assumes that `Secret/my-gcp-keyfile` contains a key called `keyfile.json`
        secretName: my-gcp-keyfile
```

> 🟦 __Tip__ 🟦
>
> If you have a GCP keyfile at `./keyfile.json`, 
> you may create `Secret/my-gcp-keyfile` using this command:
> 
> ```shell
> kubectl create secret generic \
>   my-gcp-keyfile \
>   --from-file=keyfile.json=./keyfile.json \
>   --namespace my-airflow-namespace
> ```

</details>

<details>
<summary>
  <a id="gcp-connection---gke-workload-identity"></a>
  <b>Option 2: GKE Workload Identity (recommended)</b>
</summary>

If you are running on GKE, it is usually preferable to use [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity),
which removes the need to provide a keyfile.

The following values will create a `"google_cloud_platform"` type connection called `my_gcp` that will use GKE Workload Identity:

```yaml
airflow:
  connections:
    - id: my_gcp
      type: google_cloud_platform
      description: my GCP connection
      extra: |
        {
          "extra__google_cloud_platform__num_retries": 5
        }

serviceAccount:
  annotations:
    iam.gke.io/gcp-service-account: "<<MY_ROLE_NAME>>@<<MY_PROJECT_NAME>>.iam.gserviceaccount.com"
```

</details>

## Azure Blob Storage Connection

The `apache-airflow-providers-microsoft-azure` provider package contains the `"wasb"` connection type.

The following are some options for defining [`"wasb"` type connections](https://airflow.apache.org/docs/apache-airflow-providers-microsoft-azure/stable/connections/wasb.html) using this chart.

<details>
<summary>
  <a id="azure-blob-storage-connection---plain-text"></a>
  <b>Option 1: Plain Text</b>
</summary>

The following values will create a `"wasb"` type connection called `my_wasb` using a token stored in plain-text:

```yaml
airflow:
  connections:
    - id: my_wasb
      type: wasb
      description: my Azure Blob Storage connection
      
      ## your `AZURE_CLIENT_ID`
      login: XXXXXXXX
      
      ## your `AZURE_CLIENT_SECRET`
      password: XXXXXXXX
      
      ## your `AZURE_TENANT_ID`
      extra: |
        {
          "extra__wasb__tenant_id": "XXXXXXXX"
        }
```

> 🟥 __Warning__ 🟥
>
> Rather than storing `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, and `AZURE_TENANT_ID` in plain-text within your values,
> consider using:
> 
> - [`Option 2: Secret Templates`](#azure-blob-storage-connection---secret-templates)

</details>

<details>
<summary>
  <a id="azure-blob-storage-connection---secret-templates"></a>
  <b>Option 2: Secret Templates (recommended)</b>
</summary>

The following values will create a `"wasb"` type connection called `my_wasb` using a token stored in `Secret/my-wasb-token`:

```yaml
airflow: 
  connections:
    - id: my_wasb
      type: wasb
      description: my Azure Blob Storage connection
      
      ## this string template is defined by `airflow.connectionsTemplates.CLIENT_ID` 
      login: ${CLIENT_ID}
      
      ## this string template is defined by `airflow.connectionsTemplates.CLIENT_SECRET` 
      password: ${CLIENT_SECRET}
      
      ## this string template is defined by `airflow.connectionsTemplates.TENANT_ID` 
      extra: |
        {
          "extra__wasb__tenant_id": "${TENANT_ID}"
        }

  connectionsTemplates:
    ## extracts the value of AZURE_CLIENT_ID from `Secret/my-wasb-token`
    CLIENT_ID:
      kind: secret
      name: my-wasb-token
      key: AZURE_CLIENT_ID

    ## extracts the value of AZURE_CLIENT_SECRET from `Secret/my-wasb-token`
    CLIENT_SECRET:
      kind: secret
      name: my-wasb-token
      key: AZURE_CLIENT_SECRET

    ## extracts the value of AZURE_TENANT_ID from `Secret/my-wasb-token`
    TENANT_ID:
      kind: secret
      name: my-wasb-token
      key: AZURE_TENANT_ID
```

> 🟦 __Tip__ 🟦
>
> You may create the `Secret` called `my-wasb-token` with `kubectl`.
> 
> ```shell
> kubectl create secret generic \
>   my-wasb-token \
>   --from-literal=AZURE_CLIENT_ID='xxxxxxxxxxxxxxxxxxxx' \
>   --from-literal=AZURE_CLIENT_SECRET='xxxxxxxxxxxxxxxxxxxx' \
>   --from-literal=AZURE_TENANT_ID='xxxxxxxxxxxxxxxxxxxx' \
>   --namespace my-airflow-namespace
> ```

</details>

## Postgres Connection

The `apache-airflow-providers-postgres` provider package contains the `"postgres"` connection type.

The following are some options for defining [`"postgres"` type connections](https://airflow.apache.org/docs/apache-airflow-providers-postgres/stable/connections/postgres.html) using this chart.

<details>
<summary>
  <a id="postgres-connection---plain-text"></a>
  <b>Option 1: Plain Text</b>
</summary>

The following values will create a `"postgres"` type connection called `my_postgres` using credentials stored in plain-text:

```yaml
airflow:
  connections:
    - id: my_postgres
      type: postgres
      description: my Postgres connection
      
      host: postgres.example.com
      port: 5432
      
      login: XXXXXXXX
      password: XXXXXXXX
      
      schema: my_database
      
      ## see the official "postgres" connection docs for valid extra configs
      extra: |
        { 
          "sslmode": "allow" 
        }
```

> 🟥 __Warning__ 🟥
>
> Rather than storing > `login` and `password` in plain-text within your values, consider using:
> 
> - [`Option 2: Secret Templates`](#postgres-connection---secret-templates) 

</details>

<details>
<summary>
  <a id="postgres-connection---secret-templates"></a>
  <b>Option 2: Secret Templates (recommended)</b>
</summary>

The following values will create an `"postgres"` type connection called `my_postgres` using credentials stored in `Secret/my-postgres-credentials`:

```yaml
airflow: 
  connections:
    - id: my_postgres
      type: postgres
      description: my Postgres connection
      
      host: postgres.example.com
      port: 5432
      
      ## this string template is defined by `airflow.connectionsTemplates.POSTGRES_USERNAME` 
      login: ${POSTGRES_USERNAME}
      
      ## this string template is defined by `airflow.connectionsTemplates.POSTGRES_PASSWORD` 
      password: ${POSTGRES_PASSWORD}
      
      schema: my_database
      
      ## see the official "postgres" connection docs for valid extra configs
      extra: |
        { 
          "sslmode": "allow" 
        }

  connectionsTemplates:
    ## extracts the value of `username` from `Secret/my-postgres-credentials`
    POSTGRES_USERNAME:
      kind: secret
      name: my-postgres-credentials
      key: username

    ## extracts the value of `password` from `Secret/my-postgres-credentials`
    POSTGRES_PASSWORD:
      kind: secret
      name: my-postgres-credentials
      key: password
```

> 🟦 __Tip__ 🟦
>
> You may create the `Secret` called `my-postgres-credentials` with `kubectl`.
> 
> ```shell
> kubectl create secret generic \
>   my-postgres-credentials \
>   --from-literal=username='xxxxxxxxxxxx' \
>   --from-literal=password='xxxxxxxxxxxx' \
>   --namespace my-airflow-namespace
> ```

</details>

## SSH Connection

The `apache-airflow-providers-ssh` provider package contains the `"ssh"` connection type.

The following are some options for defining [`"ssh"` type connections](https://airflow.apache.org/docs/apache-airflow-providers-ssh/stable/connections/ssh.html) using this chart.

<details>
<summary>
  <a id="ssh-connection---plain-text"></a>
  <b>Option 1: Plain Text</b>
</summary>

The following values will create a `"ssh"` type connection called `my_ssh` using credentials stored in plain-text:

```yaml
airflow:
  connections:
    - id: my_ssh
      type: ssh
      description: my SSH connection
      
      host: ssh.example.com
      port: 22
      
      login: XXXXXXXX
      password: XXXXXXXX
      
      ## see the official "ssh" connection docs for valid extra configs
      extra: |
        { 
          "conn_timeout": "15" 
        }
```

> 🟥 __Warning__ 🟥
>
> Rather than storing `login` and `password` in plain-text within your values, consider using:
> 
> - [`Option 2: Secret Templates`](#ssh-connection---secret-templates)
> - [`Option 3: Secret Keyfile`](#ssh-connection---secret-keyfile)

</details>

<details>
<summary>
  <a id="ssh-connection---secret-templates"></a>
  <b>Option 2: Secret Templates</b>
</summary>

The following values will create an `"ssh"` type connection called `my_ssh` using credentials stored in `Secret/my-ssh-credentials`:

```yaml
airflow: 
  connections:
    - id: my_ssh
      type: ssh
      description: my SSH connection
      
      host: ssh.example.com
      port: 22
      
      ## this string template is defined by `airflow.connectionsTemplates.SSH_USERNAME` 
      login: ${SSH_USERNAME}
      
      ## this string template is defined by `airflow.connectionsTemplates.SSH_PASSWORD` 
      password: ${SSH_PASSWORD}
      
      ## see the official "ssh" connection docs for valid extra configs
      extra: |
        { 
          "conn_timeout": "15" 
        }

  connectionsTemplates:
    ## extracts the value of `username` from `Secret/my-ssh-credentials`
    SSH_USERNAME:
      kind: secret
      name: my-ssh-credentials
      key: username

    ## extracts the value of `password` from `Secret/my-ssh-credentials`
    SSH_PASSWORD:
      kind: secret
      name: my-ssh-credentials
      key: password
```

> 🟦 __Tip__ 🟦
>
> You may create the `Secret` called `my-ssh-credentials` with `kubectl`.
> 
> ```shell
> kubectl create secret generic \
>   my-ssh-credentials \
>   --from-literal=username='xxxxxxxxxxxx' \
>   --from-literal=password='xxxxxxxxxxxx' \
>   --namespace my-airflow-namespace
> ```

</details>

<details>
<summary>
  <a id="ssh-connection---secret-keyfile"></a>
  <b>Option 3: Secret Keyfile</b>
</summary>

The following values will create a `"ssh"` type connection called `my_ssh` that will use an `id_rsa` file from `Secret/my-ssh-keyfile`:

```yaml
airflow:
  connections:
    - id: my_ssh
      type: ssh
      description: my SSH connection
      
      host: ssh.example.com
      port: 22
            
      ## see the official "ssh" connection docs for valid extra configs
      extra: |
        { 
          "key_file": "/opt/airflow/secrets/ssh-keyfile/id_rsa",
          "conn_timeout": "15"
        }

  extraVolumeMounts:
    - name: ssh-keyfile
      mountPath: /opt/airflow/secrets/ssh-keyfile
      readOnly: true

  extraVolumes:
    - name: ssh-keyfile
      secret:
        ## assumes that `Secret/my-ssh-keyfile` contains a key called `id_rsa`
        secretName: my-ssh-keyfile
        ## ssh complains if `id_rsa` has permissions that are too open
        defaultMode: 0600
```

> 🟦 __Tip__ 🟦
>
> If you have the SSH private key at `$HOME/.ssh/id_rsa`, 
> you may create `Secret/my-ssh-keyfile` using this command:
> 
> ```shell
> kubectl create secret generic \
>   my-ssh-keyfile \
>   --from-file=id_rsa=$HOME/.ssh/id_rsa \
>   --namespace my-airflow-namespace
> ```

</details>
