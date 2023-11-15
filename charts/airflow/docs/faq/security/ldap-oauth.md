[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Integrate Airflow with LDAP or OAUTH

> 🟥 __Warning__ 🟥
> 
> The `AUTH_ROLES_MAPPING` feature requires `Flask-Appbuilder>=3.2.0`.
> Starting from Airflow 2.0.2, `Flask-Appbuilder>=3.2.0` is included by default,
> older versions of airflow will require you to [manually install](../configuration/extra-python-packages.md) `Flask-AppBuilder>=3.2.0`.

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

> 🟥 __Warning__ 🟥
>
> LDAP integration requires the `python-ldap` python package to be installed.
> Starting from Airflow 2.0.2, `python-ldap` is included by default,
> older versions of airflow will require you to [manually install](../configuration/extra-python-packages.md) `python-ldap`.

Airflow authentication can be delegated to an LDAP server as it uses Flask-Appbuilder (FAB) for its web UI.
Learn how to connect FAB with an LDAP server in [the FAB Security docs](https://flask-appbuilder.readthedocs.io/en/latest/security.html#authentication-ldap),
or follow one of these examples.

<details>
<summary>
  <b>Microsoft Active Directory</b>
</summary>

---

This example assumes that all users can preform an LDAP search (typical for Microsoft Active Directory).

These [`web.webserverConfig`](../configuration/airflow-configs.md#webserver_configpy) values will integrate with a typical Microsoft Active Directory server:

```yaml
web:
  webserverConfig:
    ## this is the full text of your `webserver_config.py`
    stringOverride: |
      from flask_appbuilder.security.manager import AUTH_LDAP

      # only needed for airflow 1.10
      #from airflow import configuration as conf
      #SQLALCHEMY_DATABASE_URI = conf.get("core", "SQL_ALCHEMY_CONN")
      
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

</details>

<details>
<summary>
  <b>OpenLDAP</b>
</summary>

---

This example assumes that a special account is needed to preform an LDAP search (typical for OpenLDAP).

These [`web.webserverConfig`](../configuration/airflow-configs.md#webserver_configpy) values will integrate with a typical OpenLDAP server:

```yaml
web:
  webserverConfig:
    ## this is the full text of your `webserver_config.py`
    stringOverride: |
      from flask_appbuilder.security.manager import AUTH_LDAP

      # only needed for airflow 1.10
      #from airflow import configuration as conf
      #SQLALCHEMY_DATABASE_URI = conf.get("core", "SQL_ALCHEMY_CONN")
      
      AUTH_TYPE = AUTH_LDAP
      AUTH_LDAP_SERVER = "ldap://ldap.example.com"
      AUTH_LDAP_USE_TLS = False
      
      # registration configs
      AUTH_USER_REGISTRATION = True  # allow users who are not already in the FAB DB
      AUTH_USER_REGISTRATION_ROLE = "Public"  # this role will be given in addition to any AUTH_ROLES_MAPPING
      AUTH_LDAP_FIRSTNAME_FIELD = "givenName"
      AUTH_LDAP_LASTNAME_FIELD = "sn"
      AUTH_LDAP_EMAIL_FIELD = "mail"  # if null in LDAP, email is set to: "{username}@email.notfound"
      
      # search configs
      AUTH_LDAP_SEARCH = "ou=users,dc=example,dc=com"  # the LDAP search base
      AUTH_LDAP_UID_FIELD = "uid"  # the username field
      AUTH_LDAP_BIND_USER = "uid=admin,ou=users,dc=example,dc=com"  # the special bind username for search
      AUTH_LDAP_BIND_PASSWORD = "admin_password"  # the special bind password for search

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

</details>

## Integrate with OAUTH

> 🟥 __Warning__ 🟥
>
> OAUTH integration requires the `Authlib` python package to be installed.
> Starting from Airflow 2.2.0, `Authlib` is included by default,
> older versions of airflow will require you to [manually install](../configuration/extra-python-packages.md) `Authlib`.

Airflow authentication can be bridged to an OAUTH provider as it uses Flask-Appbuilder (FAB) for its web UI.
Learn how to connect FAB with an OAUTH provider in [the FAB Security docs](https://flask-appbuilder.readthedocs.io/en/latest/security.html#authentication-oauth),
or follow one of these examples.

<details>
<summary>
  <b>GitHub</b>
</summary>

---

> 🟦 __Tip__ 🟦
>
> The OAUTH callback URL will be: `https://MY_AIRFLOW_DOMAIN/oauth-authorized/github`

These [`web.webserverConfig`](../configuration/airflow-configs.md#webserver_configpy) values will integrate with GitHub:

```yaml
web:
  webserverConfig:
    ## this is the full text of your `webserver_config.py`
    stringOverride: |
      #######################################
      # Custom AirflowSecurityManager
      #######################################
      from airflow.www.security import AirflowSecurityManager
      
      class CustomSecurityManager(AirflowSecurityManager):
          def get_oauth_user_info(self, provider, resp):
              if provider == "github":
                  user_data = self.appbuilder.sm.oauth_remotes[provider].get("user").json()
                  emails_data = self.appbuilder.sm.oauth_remotes[provider].get("user/emails").json()
                  teams_data = self.appbuilder.sm.oauth_remotes[provider].get("user/teams").json()
      
                  # unpack the user's name
                  first_name = ""
                  last_name = ""
                  name = user_data.get("name", "").split(maxsplit=1)
                  if len(name) == 1:
                      first_name = name[0]
                  elif len(name) == 2:
                      first_name = name[0]
                      last_name = name[1]
      
                  # unpack the user's email
                  email = ""
                  for email_data in emails_data:
                      if email_data["primary"]:
                          email = email_data["email"]
                          break
      
                  # unpack the user's teams as role_keys
                  # NOTE: each role key will be "my-github-org/my-team-name"
                  role_keys = []
                  for team_data in teams_data:
                      team_org = team_data["organization"]["login"]
                      team_slug = team_data["slug"]
                      team_ref = team_org + "/" + team_slug
                      role_keys.append(team_ref)
      
                  return {
                      "username": "github_" + user_data.get("login", ""),
                      "first_name": first_name,
                      "last_name": last_name,
                      "email": email,
                      "role_keys": role_keys,
                  }
              else:
                  return {}
      
      #######################################
      # Actual `webserver_config.py`
      #######################################
      from flask_appbuilder.security.manager import AUTH_OAUTH
      
      # only needed for airflow 1.10
      #from airflow import configuration as conf
      #SQLALCHEMY_DATABASE_URI = conf.get("core", "SQL_ALCHEMY_CONN")
      
      AUTH_TYPE = AUTH_OAUTH
      SECURITY_MANAGER_CLASS = CustomSecurityManager
      
      # registration configs
      AUTH_USER_REGISTRATION = True  # allow users who are not already in the FAB DB
      AUTH_USER_REGISTRATION_ROLE = "Public"  # this role will be given in addition to any AUTH_ROLES_MAPPING
      
      # the list of providers which the user can choose from
      OAUTH_PROVIDERS = [
          {
              "name": "github",
              "icon": "fa-github",
              "token_key": "access_token",
              "remote_app": {
                  "client_id": "GITHUB_CLIENT_ID",
                  "client_secret": "GITHUB_CLIENT_SECRET",
                  "api_base_url": "https://api.github.com",
                  "client_kwargs": {"scope": "read:org read:user user:email"},
                  "access_token_url": "https://github.com/login/oauth/access_token",
                  "authorize_url": "https://github.com/login/oauth/authorize",
              },
          },
      ]
      
      # a mapping from the values of `userinfo["role_keys"]` to a list of FAB roles
      AUTH_ROLES_MAPPING = {
          "my-github-org/airflow-users-team": ["User"],
          "my-github-org/airflow-admin-team": ["Admin"],
      }
      
      # if we should replace ALL the user's roles each login, or only on registration
      AUTH_ROLES_SYNC_AT_LOGIN = True
      
      # force users to re-auth after 30min of inactivity (to keep roles in sync)
      PERMANENT_SESSION_LIFETIME = 1800
```

</details>


<details>
<summary>
  <b>Okta</b>
</summary>

---

> 🟦 __Tip__ 🟦
>
> The OAUTH callback URL will be: `https://MY_AIRFLOW_DOMAIN/oauth-authorized/okta`

These [`web.webserverConfig`](../configuration/airflow-configs.md#webserver_configpy) values will integrate with Okta:

```yaml
web:
  webserverConfig:
    ## this is the full text of your `webserver_config.py`
    stringOverride: |
      from flask_appbuilder.security.manager import AUTH_OAUTH

      # only needed for airflow 1.10
      #from airflow import configuration as conf
      #SQLALCHEMY_DATABASE_URI = conf.get("core", "SQL_ALCHEMY_CONN")
      
      AUTH_TYPE = AUTH_OAUTH
      
      # registration configs
      AUTH_USER_REGISTRATION = True  # allow users who are not already in the FAB DB
      AUTH_USER_REGISTRATION_ROLE = "Public"  # this role will be given in addition to any AUTH_ROLES_MAPPING
      
      # the list of providers which the user can choose from
      OAUTH_PROVIDERS = [
        {
            "name": "okta",
            "icon": "fa-circle-o",
            "token_key": "access_token",
            "remote_app": {
                "client_id": "OKTA_CLIENT_ID",
                "client_secret": "OKTA_CLIENT_SECRET",
                "api_base_url": "https://OKTA_DOMAIN.okta.com/oauth2/v1/",
                "client_kwargs": {"scope": "openid profile email groups"},
                "server_metadata_url": "https://OKTA_DOMAIN.okta.com/.well-known/openid-configuration",
            },
        },
      ]
      
      # a mapping from the values of `userinfo["role_keys"]` to a list of FAB roles
      AUTH_ROLES_MAPPING = {
          "MyOktaGroup1": ["User"],
          "MyOktaGroup2": ["Admin"],
      }

      # if we should replace ALL the user's roles each login, or only on registration
      AUTH_ROLES_SYNC_AT_LOGIN = True
      
      # force users to re-auth after 30min of inactivity (to keep roles in sync)
      PERMANENT_SESSION_LIFETIME = 1800
```

</details>