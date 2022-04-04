[🔗 Return to `Table of Contents` for more FAQ topics 🔗](https://github.com/airflow-helm/charts/tree/main/charts/airflow#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](https://github.com/airflow-helm/charts/tree/main/charts/airflow)

# How to configure an external database?

> 🟥 __Warning__ 🟥
>
> We __STRONGLY RECOMMEND__ that all production deployments of Airflow use an external database, not the [embedded database](embedded-database.md).

> 🟦 __Tip__ 🟦
>
> When compared with the Postgres that is embedded in this chart, an __external database__ comes with many benefits:
> 
> 1. The embedded Postgres version is usually very outdated, so is susceptible to critical security bugs
> 2. The embedded database may not scale to your performance requirements
> 3. An external database will likely achieve higher uptime
> 4. An external database can be configured with backups and disaster recovery
> 
> Commonly, people use the managed PostgreSQL service from their cloud vendor to provision an external database:
> 
> Cloud Platform | Service Name
> --- | ---
> Amazon Web Services | [Amazon RDS for PostgreSQL](https://aws.amazon.com/rds/postgresql/)
> Microsoft Azure | [Azure Database for PostgreSQL](https://azure.microsoft.com/en-au/services/postgresql/)
> Google Cloud | [Cloud SQL for PostgreSQL](https://cloud.google.com/sql/docs/postgres)
> Alibaba Cloud | [ApsaraDB RDS for PostgreSQL](https://www.alibabacloud.com/product/apsaradb-for-rds-postgresql)
> IBM Cloud | [IBM Cloud® Databases for PostgreSQL](https://cloud.ibm.com/docs/databases-for-postgresql)

## Option 1 - Postgres

> 🟨 __Note__ 🟨
>
> By default, this chart deploys [PgBouncer](https://www.pgbouncer.org/) to pool db connections and reduce the load from large numbers of airflow tasks.
>
> You may read more about [how to configure the chart's PgBouncer](pgbouncer.md).

For example, to use an external Postgres at `postgres.example.org`, with an existing `airflow_cluster1` database:

```yaml
postgresql:
  ## to use the external db, the embedded one must be disabled
  enabled: false

## for full list of PgBouncer configs, see values.yaml
pgbouncer:
  enabled: true

  ## WARNING: for PostgreSQL with password_encryption = 'SCRAM-SHA-256', the following non-default value is needed
  # authType: scram-sha-256
  
  ## WARNING: for "Azure PostgreSQL", the following non-default values are needed
  # authType: scram-sha-256
  # serverSSL:
  #   mode: verify-ca

externalDatabase:
  type: postgres
  
  host: postgres.example.org
  port: 5432
  
  ## the schema which will contain the airflow tables
  database: airflow_cluster1

  ## (username - option 1) a plain-text helm value
  user: my_airflow_user
  
  ## (username - option 2) a Kubernetes secret in your airflow namespace
  #userSecret: "airflow-cluster1-database-credentials"
  #userSecretKey: "username"

  ## (password - option 1) a plain-text helm value
  password: my_airflow_password

  ## (password - option 2) a Kubernetes secret in your airflow namespace
  #passwordSecret: "airflow-cluster1-database-credentials"
  #passwordSecretKey: "password"

  ## use this for any extra connection-string settings, e.g. ?sslmode=disable
  properties: ""
```

## Option 2 - MySQL

> 🟥 __Warning__ 🟥
>
> You must set `explicit_defaults_for_timestamp=1` in your MySQL instance, [see here](https://airflow.apache.org/docs/stable/howto/initialize-database.html)

For example, to use an external MySQL at `mysql.example.org`, with an existing `airflow_cluster1` database:

```yaml
postgresql:
  ## to use the external db, the embedded one must be disabled
  enabled: false

pgbouncer:
  ## pgbouncer is automatically disabled if `externalDatabase.type` is `mysql`
  #enabled: false

externalDatabase:
  type: mysql
  
  host: mysql.example.org
  port: 3306

  ## the database which will contain the airflow tables
  database: airflow_cluster1

  ## (username - option 1) a plain-text helm value
  user: my_airflow_user

  ## (username - option 2) a Kubernetes secret in your airflow namespace
  #userSecret: "airflow-cluster1-database-credentials"
  #userSecretKey: "username"

  ## (password - option 1) a plain-text helm value
  password: my_airflow_password

  ## (password - option 2) a Kubernetes secret in your airflow namespace
  #passwordSecret: "airflow-cluster1-database-credentials"
  #passwordSecretKey: "password"

  ## use this for any extra connection-string settings, e.g. ?useSSL=false
  properties: ""
```