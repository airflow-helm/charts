[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Manage Airflow Configs

## airflow.cfg

While we don't expose the `airflow.cfg` file directly, you may use [environment variables](https://airflow.apache.org/docs/stable/howto/set-config.html) to set Airflow configs.

The `airflow.config` value makes this easier, each key-value is mounted as an environment variable on each Pod:

```yaml
airflow:
  config:
    ## security
    AIRFLOW__WEBSERVER__EXPOSE_CONFIG: "False"
    
    ## dags
    AIRFLOW__CORE__LOAD_EXAMPLES: "False"
    AIRFLOW__SCHEDULER__DAG_DIR_LIST_INTERVAL: "30"
    
    ## email
    AIRFLOW__EMAIL__EMAIL_BACKEND: "airflow.utils.email.send_email_smtp"
    AIRFLOW__SMTP__SMTP_HOST: "smtpmail.example.com"
    AIRFLOW__SMTP__SMTP_MAIL_FROM: "admin@example.com"
    AIRFLOW__SMTP__SMTP_PORT: "25"
    AIRFLOW__SMTP__SMTP_SSL: "False"
    AIRFLOW__SMTP__SMTP_STARTTLS: "False"
    
    ## domain used in airflow emails
    AIRFLOW__WEBSERVER__BASE_URL: "http://airflow.example.com"
    
    ## ether environment variables
    HTTP_PROXY: "http://proxy.example.com:8080"
```

> 🟦 __Tip__ 🟦
>
> To store sensitive configs in Kubernetes secrets, you may use the `airflow.extraEnv` value.
> 
> For example, to set `AIRFLOW__CORE__FERNET_KEY` from a Secret called `airflow-fernet-key` containing a key called `value`:
>
> ```yaml
> airflow:
>   extraEnv:
>     - name: AIRFLOW__CORE__FERNET_KEY
>       valueFrom:
>         secretKeyRef:
>           name: airflow-fernet-key
>           key: value
> ```

## webserver_config.py

We expose the `web.webserverConfig.*` values to define your Flask-AppBuilder `webserver_config.py` file.

For example, a minimal `webserver_config.py` file that uses [`AUTH_DB`](https://flask-appbuilder.readthedocs.io/en/latest/security.html#authentication-database):

```yaml
web:
  webserverConfig:
    ## the full content of the `webserver_config.py` file, as a string
    stringOverride: |
      from airflow import configuration as conf
      from flask_appbuilder.security.manager import AUTH_DB
      
      # the SQLAlchemy connection string
      SQLALCHEMY_DATABASE_URI = conf.get('core', 'SQL_ALCHEMY_CONN')
      
      # use embedded DB for auth
      AUTH_TYPE = AUTH_DB

    ## the name of an existing Secret containing a `webserver_config.py` key
    ## NOTE: if set, takes precedence over `web.webserverConfig.stringOverride`
    #existingSecret: "my-airflow-webserver-config"

    ## if the `webserver_config.py` file is mounted
    ## NOTE: set to false if you wish to mount your own `webserver_config.py` file
    #enabled: false
```

> 🟦 __Tip__ 🟦
>
> We also provide more detailed docs on [how to integrate airflow with LDAP or OAUTH](../security/ldap-oauth.md).

## airflow_local_settings.py

We expose the `airflow.localSettings.*` values to define your `airflow_local_settings.py` file.

For example, an `airflow_local_settings.py` file that sets a [cluster policy](https://airflow.apache.org/docs/apache-airflow/stable/concepts/cluster-policies.html) to reject dags with no tags:

```yaml
airflow:
  localSettings:
    ## the full content of the `airflow_local_settings.py` file, as a string
    stringOverride: |
      from airflow.models import DAG
      from airflow.exceptions import AirflowClusterPolicyViolation
      
      def dag_policy(dag: DAG):
          """Ensure that DAG has at least one tag"""
          if not dag.tags:
              raise AirflowClusterPolicyViolation(
                  f"DAG {dag.dag_id} has no tags. At least one tag required. File path: {dag.fileloc}"
              )

    ## the name of an existing Secret containing a `airflow_local_settings.py` key
    ## NOTE: if set, takes precedence over `airflow.localSettings.stringOverride`
    #existingSecret: "my-airflow-local-settings"
```

For example, an `airflow_local_settings.py` file that sets the default KubernetesExecutor container image:

```yaml
airflow:
  localSettings:
    ## the full content of the `airflow_local_settings.py` file, as a string
    stringOverride: |
      # use a custom `xcom_sidecar` image for KubernetesPodOperator()
      from airflow.kubernetes.pod_generator import PodDefaults
      PodDefaults.SIDECAR_CONTAINER.image = "gcr.io/PROJECT-ID/custom-sidecar-image"
```