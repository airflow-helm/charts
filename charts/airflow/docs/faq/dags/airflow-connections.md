[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# How to manage airflow connections?

Airflow Connections are typically [created](https://airflow.apache.org/docs/apache-airflow/stable/howto/connection.html#creating-a-connection-with-the-ui) 
and [updated](https://airflow.apache.org/docs/apache-airflow/stable/howto/connection.html#editing-a-connection-with-the-ui) using the WebUI, 
but this can be dangerous as it makes your Airflow environment dependent on _manual post-install steps_, leaving you vulnerable to users making unexpected changes.
To solve this and other issues, the chart provides the `airflow.connections` value to specify a list of connections that will be automatically reconciled into your airflow deployment.

## Defining Connections

We provide the `airflow.connections` value, a YAML list with elements that have the attributes of an Airflow Connection.

Here is an example connection that has all possible fields set as `"..."`:

```yaml
airflow: 
  connections:
    - ## "Connection Id" (required)
      id: ...
      
      ## "Connection Type" (required)
      type: ...
      
      ## "Description"
      description: ...
      
      ## "Host" (allows connectionsTemplates)
      host: ...
      
      ## "Port"
      port: ...
      
      ## "Schema" (allows connectionsTemplates)
      schema: ...
      
      ## "Login" (allows connectionsTemplates)
      login: ...
      
      ## "Password" (allows connectionsTemplates)
      password: ...
            
      ## "Extra" (allows connectionsTemplates)
      extra: ...
```

The `type` attribute specifies what kind of connection is being managed, to learn about each connection `type`:
- See the [examples section](#examples) of this FAQ page.
- See [the list of types](https://airflow.apache.org/docs/apache-airflow-providers/core-extensions/connections.html) in airflow's official docs. 
   - _(TIP: click "Connection Types" in the left-sidebar after clicking on a "hook" API page)_

> 🟦 __Tip__ 🟦
>
> The `extra` attribute must be a valid JSON object, this means you must _escape_ any special JSON characters in your strings.
> 
> For example, this connection includes an `extra` JSON object with values that contain `newlines` and `"`:
> 
> ```yaml
> airflow: 
>   connections:
>     - id: ...
>       type: ...
>       extra: |
>         {
>           "key_1": "line_one\n line_two\n special_\"_chars\n line_four\n"
>         }
> ```
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

## Connection Syncing

Connections defined in `airflow.connections` are automatically synced into the airflow metadata database:

- If `airflow.connectionsUpdate` is `true` _(default)_:
   - a Deployment is created that syncs connection definitions every 60 seconds (or whenever a Secret/ConfigMap referenced in `airflow.connectionsTemplates` is updated)
- If `airflow.connectionsUpdate` is `false`:
   - a [`post-install` hook](https://helm.sh/docs/topics/charts_hooks/) runs a Job after each `helm install/upgrade` that syncs connection definitions a single time

> 🟦 __Tip__ 🟦
>
> Removing a connection that was previously defined in `airflow.connections` requires __two steps__ 
> because the sync ignores connections not listed in `airflow.connections`:
> 
> 1. Remove the connection from the `airflow.connections` list.
> 2. Use the WebUI or CLI to remove the connection.

> 🟥 __Warning__ 🟥
>
> When using ArgoCD (or similar tools), you must set `airflow.connectionsUpdate` to `true`,
> otherwise you may encounter "field is immutable" errors from the `post-install` Job.
> This is because `helm template` does not apply the [`helm.sh/hook-delete-policy: before-hook-creation`](https://helm.sh/docs/topics/charts_hooks/#hook-deletion-policies)
> annotation that removes any existing Jobs before applying the new one.

## Templating from Secrets and ConfigMaps

Sometimes you may wish to use parts of Secrets or ConfigMaps within your connection definitions, we provide the `airflow.connectionsTemplates` value to enable this.

The keys of `airflow.connectionsTemplates` will be templated using [`$`-based substitution](https://docs.python.org/3/library/string.html#template-strings) inside 
the `host`, `schema`, `login`, `password` and `extra` string fields.

Here is a conceptual example which uses templates from `ConfigMap/my-configmap` and `Secret/my-secret`.

```yaml
airflow:
  connections:
    - id: ...
      type: ...
      description: ...
      host: ${CONFIGMAP_TEMPLATE}
      port: ...
      schema: ${CONFIGMAP_TEMPLATE}
      login: ${CONFIGMAP_TEMPLATE}
      password: ${SECRET_TEMPLATE}
      
      ## WARNING: if CONFIGMAP_TEMPLATE or SECRET_TEMPLATE contain any special characters like `"`,
      ##          they must be escaped so that a valid JSON string is created
      ##          (currently, this escaping must take place in the Secret/ConfigMap itself)
      extra: |
        {
          "example_1": "${CONFIGMAP_TEMPLATE}",
          "example_2": "${SECRET_TEMPLATE}",
        }

  connectionsTemplates:
    ## creates a template called ${CONFIGMAP_TEMPLATE} from the `username` key in `ConfigMap/my-configmap` 
    CONFIGMAP_TEMPLATE:
      kind: configmap
      name: my-configmap
      key: username

    ## creates a template called ${SECRET_TEMPLATE} from the `password` key in `Secret/my-secret` 
    SECRET_TEMPLATE:
      kind: secret
      name: my-secret
      key: password
```

> 🟦 __Tip__ 🟦
>
> Updates to Secrets and ConfigMaps referenced in `airflow.connectionsTemplates` are automatically propagated to the `airflow.connections` which reference them.
> This allows integration with _secret management systems_ through the [External Secrets Operator](https://github.com/external-secrets/external-secrets).
>
> The [External Secrets Operator](https://github.com/external-secrets/external-secrets) supports common _secret management systems_ like:
> - [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/)
> - [Azure Key Vault](https://azure.microsoft.com/en-us/services/key-vault/)
> - [Google Secrets Manager](https://cloud.google.com/secret-manager)
> - [HashiCorp Vault](https://github.com/hashicorp/vault)

# Examples

The following examples cover some common connection types which you may find useful.

## AWS Connection

The `apache-airflow-providers-amazon` provider package contains the [`"aws"`](https://airflow.apache.org/docs/apache-airflow-providers-amazon/stable/connections/aws.html) connection type.

For example, the following values will create an `"aws"` type connection called `my_aws`:

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
      
      ## refer to "aws" connection docs for valid parameters
      extra: |
        {
          "region_name": "eu-central-1"
        }
```

> 🟦 __Tip__ 🟦
>
> If you are running on EKS, it is usually preferable to use [IAM roles for service accounts (IRSA)](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html),
> which removes the need to provide `AWS_ACCESS_KEY_ID` or `AWS_SECRET_ACCESS_KEY`.
> 
> To use IRSA, you must create an "empty" AWS connection, and apply the appropriate Pod ServiceAccount annotations.
> 
> ```yaml
> airflow:
>   connections:
>     - id: my_aws
>       type: aws
>       description: my AWS connection
> 
>       ## no access tokens should be provided, 
>       ## otherwise they will take precedence over the ones injected by IRSA
>       #login: ~
>       #password: ~
> 
>       ## TIP: omit `role_arn` if an assume_role is not necessary 
>       ##      (e.g. if `eks.amazonaws.com/role-arn` already has the correct permissions)
>       ##
>       ## TIP: you may create separate connections with different `role_arn` to give varied access 
>       ##      (this is especially important for cross-account access)
>       extra: |
>         {
>           "role_arn": "arn:aws:iam::123456789012:role/S3Access",
>           "region_name": "eu-central-1"
>         }
> 
> serviceAccount:
>   annotations:
>     # replace with the AWS role you have configured for IRSA
>     eks.amazonaws.com/role-arn: "arn:aws:iam::XXXXXXXXXX:role/<<MY_ROLE_NAME>>"
> ```

> 🟥 __Warning__ 🟥
>
> If you are using Airflow 1.10+, you must include `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in `extra` field, rather than the `login` and `password` fields.
> 
> ```yaml
> airflow: 
>   connections:
>     - id: my_aws
>       type: aws
>       description: my AWS connection
>       extra: |
>         { 
>           "aws_access_key_id": "XXXXXXXX",
>           "aws_secret_access_key": "XXXXXXXX",
>           "region_name": "eu-central-1"
>         }
> ```

## GCP Connection

The `apache-airflow-providers-google` provider package contains the [`"google_cloud_platform"`](https://airflow.apache.org/docs/apache-airflow-providers-google/stable/connections/gcp.html) connection type.

For example, the following values will create a `"google_cloud_platform"` type connection called `my_gcp` that references a keyfile stored in `Secret/gcp-keyfile`:

```yaml
airflow:
  connections:
    - id: my_gcp
      type: google_cloud_platform
      description: my GCP connection
      
      ## refer to "google_cloud_platform" connection docs for valid parameters
      extra: |
        {
          "extra__google_cloud_platform__key_path": "/opt/airflow/secrets/gcp-keyfile/keyfile.json",
          "extra__google_cloud_platform__num_retries: "5"
        }

  extraVolumeMounts:
    - name: gcp-keyfile
      mountPath: /opt/airflow/secrets/gcp-keyfile
      readOnly: true

  extraVolumes:
    - name: gcp-keyfile
      secret:
        ## assumes that `Secret/gcp-keyfile` contains a key called `keyfile.json`
        secretName: gcp-keyfile
```

> 🟦 __Tip__ 🟦
>
> If you are running on GKE, it is usually preferable to use [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity),
> which removes the need to provide a keyfile.
> 
> To use Workload Identity, you must create an "empty" GCP connection, and apply the appropriate Pod ServiceAccount annotations.
> 
> ```yaml
> airflow:
>   connections:
>     - id: my_gcp
>       type: google_cloud_platform
>       description: my GCP connection
>       extra: |
>         {
>           "extra__google_cloud_platform__num_retries: "5"
>         }
> 
> serviceAccount:
>   annotations:
>     iam.gke.io/gcp-service-account: "<<MY_ROLE_NAME>>@<<MY_PROJECT_NAME>>.iam.gserviceaccount.com"
> ```

## Azure Blob Storage Connection

The `apache-airflow-providers-microsoft-azure` provider package contains the [`"wabs"`](https://airflow.apache.org/docs/apache-airflow-providers-microsoft-azure/stable/connections/wasb.html) connection type.

For example, the following values will create a `"wabs"` type connection called `my_wabs`:

```yaml
airflow:
  connections:
    - id: my_wabs
      type: wabs
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

## Postgres Connection

The `apache-airflow-providers-postgres` provider package contains the [`"postgres"`](https://airflow.apache.org/docs/apache-airflow-providers-postgres/stable/connections/postgres.html) connection type.

For example, the following values will create a `"postgres"` type connection called `my_postgres`:

```yaml
airflow:
  connections:
    - id: my_postgres
      type: postgresql
      description: my Postgres connection
      host: postgres.example.com
      port: 5432
      login: db_user
      password: db_pass
      schema: my_db
      extra: |
        { 
          "sslmode": "allow" 
        }
```

## SSH Connection

The `apache-airflow-providers-ssh` provider package contains the [`"ssh"` connection type](https://airflow.apache.org/docs/apache-airflow-providers-ssh/stable/connections/ssh.html).

For example to create a `"ssh"` connection called `my_ssh`:

```yaml
airflow:
  connections:
    - id: my_ssh
      type: ssh
      description: my SSH connection
      host: ssh.example.com
      port: 22
      login: ssh_user
      password: ssh_pass
      
      ## refer to "ssh" connection docs for valid parameters
      ## TIP: you may specify "key_file" under `extra` rather than providing a `password`
      extra: |
        { 
          "conn_timeout": "15" 
        }
```

