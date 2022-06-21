[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Set Airflow Fernet Encryption Key

## Option 1 - using the value

> 🟥 __Warning__ 🟥
>
> We strongly recommend that you DO NOT USE the default `airflow.fernetKey` in production.

You may set the fernet encryption key using the `airflow.fernetKey` value, which sets the `AIRFLOW__CORE__FERNET_KEY` environment variable.

For example, to define the fernet key with `airflow.fernetKey`:

```yaml
aiflow:
  fernetKey: "7T512UXSSmBOkpWimFHIVb8jK6lfmSAvx4mO6Arehnc="
```

## Option 2 - using a secret (recommended)

You may set the fernet encryption key from a Kubernetes Secret by referencing it with the `airflow.extraEnv` value.

For example, to use the `value` key from the existing Secret called `airflow-fernet-key`:

```yaml
airflow:
  extraEnv:
    - name: AIRFLOW__CORE__FERNET_KEY
      valueFrom:
        secretKeyRef:
          name: airflow-fernet-key
          key: value
```

## Option 3 - using `_CMD` or `_SECRET` configs

You may also set the fernet key by specifying either the `AIRFLOW__CORE__FERNET_KEY_CMD` or `AIRFLOW__CORE__FERNET_KEY_SECRET` environment variables.
Read about how the `_CMD` or `_SECRET` configs work in the ["Setting Configuration Options"](https://airflow.apache.org/docs/apache-airflow/stable/howto/set-config.html) section of the Airflow documentation.

For example, to use `AIRFLOW__CORE__FERNET_KEY_CMD`:

```yaml
airflow:
  ## WARNING: you must set `fernetKey` to "", otherwise it will take precedence
  fernetKey: ""

  ## NOTE: this is only an example, if your value lives in a Secret, you probably want to use "Option 2" above
  config:
    AIRFLOW__CORE__FERNET_KEY_CMD: "cat /opt/airflow/fernet-key/value"
      
  extraVolumeMounts:
    - name: fernet-key
      mountPath: /opt/airflow/fernet-key
      readOnly: true
      
  extraVolumes:
    - name: fernet-key
      secret:
        secretName: airflow-fernet-key
```