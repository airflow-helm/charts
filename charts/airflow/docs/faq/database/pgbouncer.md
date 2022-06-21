[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# Configure PgBouncer

By default, this chart deploys [PgBouncer](https://www.pgbouncer.org/) to pool db connections and reduce the load from large numbers of airflow tasks.

## PgBouncer Configs

> 🟥 __Warning__ 🟥
>
> If using an external Postgres that has [`password_encryption = 'SCRAM-SHA-256'`](https://www.postgresql.org/docs/current/runtime-config-connection.html#GUC-PASSWORD-ENCRYPTION), you must configure PgBouncer with `auth_type = scram-sha-256`.
>
> ```yaml
> pgbouncer:
>   authType: scram-sha-256
> ```

> 🟥 __Warning__ 🟥
>
> If using [Azure Database for PostgreSQL](https://azure.microsoft.com/en-au/services/postgresql/), you must configure PgBouncer with `auth_type = scram-sha-256` and `server_tls_sslmode = verify-ca`.
>
> ```yaml
> pgbouncer:
>   authType: scram-sha-256
> 
>   serverSSL:
>     mode: verify-ca
> ```

We expose a number of PgBouncer's configs as values under `pgbouncer.*`:

```yaml
pgbouncer:
  ## if the pgbouncer Deployment is created
  enabled: true

  ## sets pgbouncer config: `auth_type`
  authType: md5

  ## sets pgbouncer config: `max_client_conn`
  maxClientConnections: 1000

  ## sets pgbouncer config: `default_pool_size`
  poolSize: 20

  ## sets pgbouncer config: `log_disconnections`
  logDisconnections: 0

  ## sets pgbouncer config: `log_connections`
  logConnections: 0

  ## ssl configs for: clients -> pgbouncer
  ##
  clientSSL:
    ## sets pgbouncer config: `client_tls_sslmode`
    mode: prefer

    ## sets pgbouncer config: `client_tls_ciphers`
    ciphers: normal

    ## sets pgbouncer config: `client_tls_ca_file`
    caFile:
      existingSecret: ""
      existingSecretKey: root.crt

    ## sets pgbouncer config: `client_tls_key_file`
    ## WARNING: a self-signed cert & key are generated if left empty
    keyFile:
      existingSecret: ""
      existingSecretKey: client.key

    ## sets pgbouncer config: `client_tls_cert_file`
    ## WARNING: a self-signed cert & key are generated if left empty
    certFile:
      existingSecret: ""
      existingSecretKey: client.crt

  ## ssl configs for: pgbouncer -> postgres
  ##
  serverSSL:
    ## sets pgbouncer config: `server_tls_sslmode`
    mode: prefer

    ## sets pgbouncer config: `server_tls_ciphers`
    ciphers: normal

    ## sets pgbouncer config: `server_tls_ca_file`
    caFile:
      existingSecret: ""
      existingSecretKey: root.crt

    ## sets pgbouncer config: `server_tls_key_file`
    keyFile:
      existingSecret: ""
      existingSecretKey: server.key

    ## sets pgbouncer config: `server_tls_cert_file`
    certFile:
      existingSecret: ""
      existingSecretKey: server.crt

```

