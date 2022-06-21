[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Manage Airflow Users

## Integrate with LDAP or OAUTH

For more information, please refer to the [`Integrate Airflow with LDAP or OAUTH`](ldap-oauth.md) page.

## Define with Plain-Text

You may use the `airflow.users` value to create airflow users in a declarative way.

For example, to create `admin` (with "Admin" RBAC role) and `user` (with "User" RBAC role):

```yaml
airflow:
  users:
    ## define the user called "admin" 
    - username: admin
      password: admin
      role: Admin
      email: admin@example.com
      firstName: admin
      lastName: admin

    ## define the user called "user" 
    - username: user
      password: user123
      ## TIP: `role` can be a single role or a list of roles
      role: 
        - User
        - Viewer
      email: user@example.com
      firstName: user
      lastName: user

  ## if we create a Deployment to perpetually sync `airflow.users`
  usersUpdate: true
```

## Define with templates from Secrets or ConfigMaps

You may use `airflow.usersTemplates` to extract string templates from keys in Secrets or Configmaps.

For example, to use templates from `Secret/my-secret` and `ConfigMap/my-configmap` in parts of the `admin` user:

```yaml
airflow:
  users:
    ## define the user called "admin" 
    - username: admin
      role: Admin
      firstName: admin
      lastName: admin
      
      ## use the ADMIN_PASSWORD template defined in `airflow.usersTemplates`
      password: ${ADMIN_PASSWORD}
           
      ## use the ADMIN_EMAIL template defined in `airflow.usersTemplates`
      email: ${ADMIN_EMAIL}
        
  ## bash-like templates to be used in `airflow.users`
  usersTemplates:

    ## define the `ADMIN_PASSWORD` template from the `my-secret` Secret
    ADMIN_PASSWORD:
      kind: secret
      name: my-secret
      key: password
      
    ## define the `ADMIN_EMAIL` template from the `my-configmap` ConfigMap
    ADMIN_EMAIL:
      kind: configmap
      name: my-configmap
      key: email
        
  ## if we create a Deployment to perpetually sync `airflow.users`
  usersUpdate: true
```

> 🟨 __Note__ 🟨
>
> When `airflow.usersUpdate` is `true`, the `airflow.users` which use `airflow.usersTemplates` will be updated in real-time, 
> allowing tools like [External Secrets Operator](https://github.com/external-secrets/external-secrets) to be used.