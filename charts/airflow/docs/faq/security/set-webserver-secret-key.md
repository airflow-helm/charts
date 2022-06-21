[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Set Airflow Webserver Secret Key

## Option 1 - using the value

> 🟥 __Warning__ 🟥
>
> We strongly recommend that you DO NOT USE the default `airflow.webserverSecretKey` in production.

You may set the webserver secret_key using the `airflow.webserverSecretKey` value, which sets the `AIRFLOW__WEBSERVER__SECRET_KEY` environment variable.

For example, to define the secret_key with `airflow.webserverSecretKey`:

```yaml
aiflow:
  webserverSecretKey: "THIS IS UNSAFE!"
```

## Option 2 - using a secret (recommended)

You may set the webserver secret_key from a Kubernetes Secret by referencing it with the `airflow.extraEnv` value.

For example, to use the `value` key from the existing Secret called `airflow-webserver-secret-key`:

```yaml
airflow:
  extraEnv:
    - name: AIRFLOW__WEBSERVER__SECRET_KEY
      valueFrom:
        secretKeyRef:
          name: airflow-webserver-secret-key
          key: value
```

## Option 3 - using `_CMD` or `_SECRET` configs

You may also set the webserver secret key by specifying either the `AIRFLOW__WEBSERVER__SECRET_KEY_CMD` or `AIRFLOW__WEBSERVER__SECRET_KEY_SECRET` environment variables.
Read about how the `_CMD` or `_SECRET` configs work in the ["Setting Configuration Options"](https://airflow.apache.org/docs/apache-airflow/stable/howto/set-config.html) section of the Airflow documentation.

For example, to use `AIRFLOW__WEBSERVER__SECRET_KEY_CMD`:

```yaml
airflow:
  ## WARNING: you must set `webserverSecretKey` to "", otherwise it will take precedence
  webserverSecretKey: ""

  ## NOTE: this is only an example, if your value lives in a Secret, you probably want to use "Option 2" above
  config:
    AIRFLOW__WEBSERVER__SECRET_KEY_CMD: "cat /opt/airflow/webserver-secret-key/value"
      
  extraVolumeMounts:
    - name: webserver-secret-key
      mountPath: /opt/airflow/webserver-secret-key
      readOnly: true
      
  extraVolumes:
    - name: webserver-secret-key
      secret:
        secretName: airflow-webserver-secret-key
```
