[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# How to manage airflow connections?

## Define with Plain-Text

You may use the `airflow.connections` value to create airflow [Connections](https://airflow.apache.org/docs/apache-airflow/stable/concepts.html#connections) in a declarative way.

For example, to create connections called `my_aws`, `my_gcp`, `my_postgres`, and `my_ssh`:

```yaml
airflow: 
  connections:
    ## see docs: https://airflow.apache.org/docs/apache-airflow-providers-amazon/stable/connections/aws.html
    - id: my_aws
      type: aws
      description: my AWS connection
      extra: |-
        { "aws_access_key_id": "XXXXXXXX",
          "aws_secret_access_key": "XXXXXXXX",
          "region_name":"eu-central-1" }
    ## see docs: https://airflow.apache.org/docs/apache-airflow-providers-google/stable/connections/gcp.html
    - id: my_gcp
      type: google_cloud_platform
      description: my GCP connection
      extra: |-
        { "extra__google_cloud_platform__keyfile_dict": "XXXXXXXX",
          "extra__google_cloud_platform__num_retries: "XXXXXXXX" }
    ## see docs: https://airflow.apache.org/docs/apache-airflow-providers-postgres/stable/connections/postgres.html
    - id: my_postgres
      type: postgres
      description: my Postgres connection
      host: postgres.example.com
      port: 5432
      login: db_user
      password: db_pass
      schema: my_db
      extra: |-
        { "sslmode": "allow" }
    ## see docs: https://airflow.apache.org/docs/apache-airflow-providers-ssh/stable/connections/ssh.html
    - id: my_ssh
      type: ssh
      description: my SSH connection
      host: ssh.example.com
      port: 22
      login: ssh_user
      password: ssh_pass
      extra: |-
        { "timeout": "15" }

  ## if we create a Deployment to perpetually sync `airflow.connections`
  connectionsUpdate: true
```

## Define with templates from Secrets or ConfigMaps

You may use `airflow.connectionsTemplates` to extract string templates from keys in Secrets or Configmaps.

For example, to use templates from `Secret/my-secret` and `ConfigMap/my-configmap` in parts of the `my_aws` connection:

```yaml
airflow: 
  connections:
    - id: my_aws
      type: aws
      description: my AWS connection
      
      ## use the AWS_ACCESS_KEY_ID and AWS_ACCESS_KEY templates that are defined in `airflow.connectionsTemplates`
      extra: |-
        { "aws_access_key_id": "${AWS_ACCESS_KEY_ID}",
          "aws_secret_access_key": "${AWS_ACCESS_KEY}",
          "region_name":"eu-central-1" }

  ## bash-like templates to be used in `airflow.connections`
  connectionsTemplates:

    ## define the `AWS_ACCESS_KEY_ID` template from the `my-configmap` ConfigMap
    AWS_ACCESS_KEY_ID:
      kind: configmap
      name: my-configmap
      key: username

    ## define the `AWS_ACCESS_KEY` template from the `my-secret` Secret
    AWS_ACCESS_KEY:
      kind: secret
      name: my-secret
      key: password

  ## if we create a Deployment to perpetually sync `airflow.connections`
  connectionsUpdate: true
```

> 🟨 __Note__ 🟨
>
> If `airflow.connectionsUpdate = true`, the connections which use `airflow.connectionsTemplates` will be updated in real-time,
> allowing tools like [external-secrets](https://github.com/external-secrets/kubernetes-external-secrets) to be used.
