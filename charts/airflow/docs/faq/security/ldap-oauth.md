[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# How to integrate airflow with LDAP or OAUTH?

> 🟦 __Tip__ 🟦
>
> After integrating with LDAP or OAUTH, you should:
> 
> 1. Set the `airflow.users` value to `[]`
> 2. Manually delete any previously created users (with the airflow WebUI)

> 🟦 __Tip__ 🟦
>
> If you see a __blank screen__ after logging in as an LDAP or OAUTH user, it is probably because that user has not received at least the [`Viewer` FAB role](https://airflow.apache.org/docs/apache-airflow/stable/security/access-control.html#viewer).
> In both following examples, we set `AUTH_USER_REGISTRATION_ROLE = "Public"`, which does not provide access to the WebUI.
> Therefore, unless a binding from `AUTH_ROLES_MAPPING` gives the user the `Viewer`, `User`, `Op`, or `Admin` FAB role, they will be unable to see the WebUI.

## Integrate with LDAP

Airflow uses [Flask-Appbuilder](https://github.com/dpgaspar/Flask-AppBuilder) for its WebUI.

> 🟦 __Tip__ 🟦
>
> Learn more about [integrating Flask-Appbuilder with LDAP](https://flask-appbuilder.readthedocs.io/en/latest/security.html#authentication-ldap) in their docs.

We provide `web.webserverConfig.*` to define the Flask-AppBuilder [`webserver_config.py`](../configuration/airflow-configs.md#webserver_configpy) file.

For example, to integrate with a typical Microsoft Active Directory using Flask-AppBuilder's `AUTH_LDAP` `AUTH_TYPE`:

```yaml
web:
  # WARNING: for production usage, create your own image with these packages installed rather than using `extraPipPackages`
  extraPipPackages:
    ## the following configs require Flask-AppBuilder 3.2.0 (or later)
    - "Flask-AppBuilder~=3.4.0"
    ## the following configs require python-ldap
    - "python-ldap~=3.4.0"

  webserverConfig:
    stringOverride: |-
      from airflow import configuration as conf
      from flask_appbuilder.security.manager import AUTH_LDAP

      SQLALCHEMY_DATABASE_URI = conf.get('core', 'SQL_ALCHEMY_CONN')
      
      AUTH_TYPE = AUTH_LDAP
      AUTH_LDAP_SERVER = "ldap://ldap.example.com"
      AUTH_LDAP_USE_TLS = False
      
      # registration configs
      AUTH_USER_REGISTRATION = True  # allow users who are not already in the FAB DB
      AUTH_USER_REGISTRATION_ROLE = "Public"  # this role will be given in addition to any AUTH_ROLES_MAPPING
      AUTH_LDAP_FIRSTNAME_FIELD = "givenName"
      AUTH_LDAP_LASTNAME_FIELD = "sn"
      AUTH_LDAP_EMAIL_FIELD = "mail"  # if null in LDAP, email is set to: "{username}@email.notfound"
      
      # bind username (for password validation)
      AUTH_LDAP_USERNAME_FORMAT = "uid=%s,ou=users,dc=example,dc=com"  # %s is replaced with the provided username
      # AUTH_LDAP_APPEND_DOMAIN = "example.com"  # bind usernames will look like: {USERNAME}@example.com
      
      # search configs
      AUTH_LDAP_SEARCH = "ou=users,dc=example,dc=com"  # the LDAP search base (if non-empty, a search will ALWAYS happen)
      AUTH_LDAP_UID_FIELD = "uid"  # the username field

      # a mapping from LDAP DN to a list of FAB roles
      AUTH_ROLES_MAPPING = {
          "cn=airflow_users,ou=groups,dc=example,dc=com": ["User"],
          "cn=airflow_admins,ou=groups,dc=example,dc=com": ["Admin"],
      }
      
      # the LDAP user attribute which has their role DNs
      AUTH_LDAP_GROUP_FIELD = "memberOf"
      
      # if we should replace ALL the user's roles each login, or only on registration
      AUTH_ROLES_SYNC_AT_LOGIN = True
      
      # force users to re-auth after 30min of inactivity (to keep roles in sync)
      PERMANENT_SESSION_LIFETIME = 1800
```

## Integrate with OAUTH

Airflow uses [Flask-Appbuilder](https://github.com/dpgaspar/Flask-AppBuilder) for its WebUI.

> 🟦 __Tip__ 🟦
>
> Learn more about [integrating Flask-Appbuilder with OAUTH](https://flask-appbuilder.readthedocs.io/en/latest/security.html#authentication-oauth) in their docs.

We provide `web.webserverConfig.*` to define the Flask-AppBuilder [`webserver_config.py`](../configuration/airflow-configs.md#webserver_configpy) file.

For example, to integrate with Okta using Flask-AppBuilder's `AUTH_OAUTH` `AUTH_TYPE`:

```yaml
web:
  extraPipPackages:
    ## the following configs require Flask-AppBuilder 3.2.0 (or later)
    - "Flask-AppBuilder~=3.4.0"
    ## the following configs require Authlib
    - "Authlib~=0.15.5"

  webserverConfig:
    stringOverride: |-
      from airflow import configuration as conf
      from flask_appbuilder.security.manager import AUTH_OAUTH

      SQLALCHEMY_DATABASE_URI = conf.get('core', 'SQL_ALCHEMY_CONN')
      
      AUTH_TYPE = AUTH_OAUTH
      
      # registration configs
      AUTH_USER_REGISTRATION = True  # allow users who are not already in the FAB DB
      AUTH_USER_REGISTRATION_ROLE = "Public"  # this role will be given in addition to any AUTH_ROLES_MAPPING

      # the list of providers which the user can choose from
      OAUTH_PROVIDERS = [
          {
              'name': 'okta',
              'icon': 'fa-circle-o',
              'token_key': 'access_token',
              'remote_app': {
                  'client_id': 'OKTA_KEY',
                  'client_secret': 'OKTA_SECRET',
                  'api_base_url': 'https://OKTA_DOMAIN.okta.com/oauth2/v1/',
                  'client_kwargs': {
                      'scope': 'openid profile email groups'
                  },
                  'access_token_url': 'https://OKTA_DOMAIN.okta.com/oauth2/v1/token',
                  'authorize_url': 'https://OKTA_DOMAIN.okta.com/oauth2/v1/authorize',
              }
          }
      ]
      
      # a mapping from the values of `userinfo["role_keys"]` to a list of FAB roles
      AUTH_ROLES_MAPPING = {
          "FAB_USERS": ["User"],
          "FAB_ADMINS": ["Admin"],
      }

      # if we should replace ALL the user's roles each login, or only on registration
      AUTH_ROLES_SYNC_AT_LOGIN = True
      
      # force users to re-auth after 30min of inactivity (to keep roles in sync)
      PERMANENT_SESSION_LIFETIME = 1800
```