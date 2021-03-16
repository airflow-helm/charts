{{/*
Bash command which echos the DB connection string in SQLAlchemy format.
NOTE:
 - used by `AIRFLOW__CORE__SQL_ALCHEMY_CONN_CMD`
 - the `DATABASE_PASSWORD_CMD` sub-command is set in `configmap-env`
*/}}
{{- define "DATABASE_SQLALCHEMY_CMD" -}}
{{- if .Values.postgresql.enabled -}}
echo -n "postgresql+psycopg2://${DATABASE_USER}:$(eval $DATABASE_PASSWORD_CMD)@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_DB}"
{{- else if and (not .Values.postgresql.enabled) (eq "postgres" .Values.externalDatabase.type) -}}
echo -n "postgresql+psycopg2://${DATABASE_USER}:$(eval $DATABASE_PASSWORD_CMD)@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_DB}${DATABASE_PROPERTIES}"
{{- else if and (not .Values.postgresql.enabled) (eq "mysql" .Values.externalDatabase.type) -}}
echo -n "mysql+mysqldb://${DATABASE_USER}:$(eval $DATABASE_PASSWORD_CMD)@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_DB}${DATABASE_PROPERTIES}"
{{- end -}}
{{- end -}}

{{/*
Bash command which echos the DB connection string in Celery result_backend format.
NOTE:
 - used by `AIRFLOW__CELERY__RESULT_BACKEND_CMD`
 - the `DATABASE_PASSWORD_CMD` sub-command is set in `configmap-env`
*/}}
{{- define "DATABASE_CELERY_CMD" -}}
{{- if .Values.postgresql.enabled -}}
echo -n "db+postgresql://${DATABASE_USER}:$(eval $DATABASE_PASSWORD_CMD)@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_DB}"
{{- else if and (not .Values.postgresql.enabled) (eq "postgres" .Values.externalDatabase.type) -}}
echo -n "db+postgresql://${DATABASE_USER}:$(eval $DATABASE_PASSWORD_CMD)@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_DB}${DATABASE_PROPERTIES}"
{{- else if and (not .Values.postgresql.enabled) (eq "mysql" .Values.externalDatabase.type) -}}
echo -n "db+mysql://${DATABASE_USER}:$(eval $DATABASE_PASSWORD_CMD)@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_DB}${DATABASE_PROPERTIES}"
{{- end -}}
{{- end -}}

{{/*
Bash command which echos the Redis connection string.
NOTE:
 - used by `AIRFLOW__CELERY__BROKER_URL_CMD`
 - the `REDIS_PASSWORD_CMD` sub-command is set in `configmap-env`
*/}}
{{- define "REDIS_CONNECTION_CMD" -}}
echo -n "redis://$(eval $REDIS_PASSWORD_CMD)${REDIS_HOST}:${REDIS_PORT}/${REDIS_DBNUM}"
{{- end -}}