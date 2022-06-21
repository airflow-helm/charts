[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Manage Airflow Variables

## Define with Plain-Text

You may use the `airflow.variables` value to create airflow [Variables](https://airflow.apache.org/docs/apache-airflow/stable/concepts.html#variables) in a declarative way.

For example, to create variables called `var_1`, `var_2`:

```yaml
airflow:
  variables:
    - key: "var_1"
      value: "my_value_1"
    - key: "var_2"
      value: "my_value_2"

  ## if we create a Deployment to perpetually sync `airflow.variables`
  variablesUpdate: true
```

## Define with templates from Secrets or ConfigMaps

You may use `airflow.variablesTemplates` to extract string templates from keys in Secrets or Configmaps.

For example, to use templates from `Secret/my-secret` and `ConfigMap/my-configmap` in the `var_1` and `var_2` variables:

```yaml
airflow:
  ## use the MY_VALUE_1 and MY_VALUE_2 templates that are defined in `airflow.variablesTemplates`
  variables:
    - key: "var_1"
      value: "${MY_VALUE_1}"
    - key: "var_2"
      value: "${MY_VALUE_2}"

  ## bash-like templates to be used in `airflow.variables`
  variablesTemplates:
    
    ## define the `MY_VALUE_1` template from the `my-configmap` ConfigMap
    MY_VALUE_1:
      kind: configmap
      name: my-configmap
      key: value1
      
    ## define the `MY_VALUE_2` template from the `my-secret` Secret
    MY_VALUE_2:
      kind: secret
      name: my-secret
      key: value2

  ## if we create a Deployment to perpetually sync `airflow.variables`
  variablesUpdate: false
```

> 🟨 __Note__ 🟨
>
> When `airflow.variablesUpdate` is `true`, the `airflow.variables` which use `airflow.variablesTemplates` will be updated in real-time, 
> allowing tools like [External Secrets Operator](https://github.com/external-secrets/external-secrets) to be used.