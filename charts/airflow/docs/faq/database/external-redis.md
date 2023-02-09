[🔗 Return to `Table of Contents` for more FAQ topics 🔗](../../../README.md#frequently-asked-questions)

> Note, this page was written for the [`User-Community Airflow Helm Chart`](../../../)

# Configure Database (External)

For example, to use an external redis at `example.redis.cache.windows.net` with ssl enabled:

```yaml
redis:
  enabled: false

externalRedis:
  host: "example.redis.cache.windows.net"
  port: 6380
  
  ## the redis database-number that airflow will use
  databaseNumber: 1

  ## (option 1 - password) a plain-text helm value
  password: my_airflow_password

  ## (option 2 - password) a Kubernetes secret in your airflow namespace
  #passwordSecret: "airflow-cluster1-redis-credentials"
  #passwordSecretKey: "password"

  ## use this for any extra connection-string settings
  properties: "?ssl_cert_reqs=CERT_OPTIONAL"
```