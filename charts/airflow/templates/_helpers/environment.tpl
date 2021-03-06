{{/*
Construct a set of secret environment variables to be mounted in web, scheduler, worker, and flower pods.
When applicable, we use the secrets created by the postgres/redis charts (which have fixed names and secret keys).
*/}}
{{- define "airflow.mapenvsecrets" -}}
{{- /* ------------------------------ */ -}}
{{- /* ---------- POSTGRES ---------- */ -}}
{{- /* ------------------------------ */ -}}
{{- if .Values.postgresql.enabled }}
{{- if .Values.postgresql.existingSecret }}
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.postgresql.existingSecret }}
      key: {{ .Values.postgresql.existingSecretKey }}
{{- else }}
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "airflow.postgresql.fullname" . }}
      key: postgresql-password
{{- end }}
{{- else }}
{{- if .Values.externalDatabase.passwordSecret }}
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalDatabase.passwordSecret }}
      key: {{ .Values.externalDatabase.passwordSecretKey }}
{{- else }}
- name: DATABASE_PASSWORD
  value: ""
{{- end }}
{{- end }}
{{- /* --------------------------- */ -}}
{{- /* ---------- REDIS ---------- */ -}}
{{- /* --------------------------- */ -}}
{{- if (include "airflow.executor.celery_like" .) }}
{{- if .Values.redis.enabled }}
{{- if .Values.redis.existingSecret }}
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.redis.existingSecret }}
      key: {{ .Values.redis.existingSecretPasswordKey }}
{{- else }}
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "airflow.redis.fullname" . }}
      key: redis-password
{{- end }}
{{- else }}
{{- if .Values.externalRedis.passwordSecret }}
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalRedis.passwordSecret }}
      key: {{ .Values.externalRedis.passwordSecretKey }}
{{- else }}
- name: REDIS_PASSWORD
  value: ""
{{- end }}
{{- end }}
{{- end }}
{{- /* ---------------------------- */ -}}
{{- /* ---------- FLOWER ---------- */ -}}
{{- /* ---------------------------- */ -}}
{{- if and (.Values.flower.basicAuthSecret) (not .Values.airflow.config.AIRFLOW__CELERY__FLOWER_BASIC_AUTH) }}
- name: AIRFLOW__CELERY__FLOWER_BASIC_AUTH
  valueFrom:
    secretKeyRef:
      name: {{ .Values.flower.basicAuthSecret }}
      key: {{ .Values.flower.basicAuthSecretKey }}
{{- end }}
{{- /* ---------------------------- */ -}}
{{- /* ---------- EXTRAS ---------- */ -}}
{{- /* ---------------------------- */ -}}
{{- if .Values.airflow.extraEnv }}
{{ toYaml .Values.airflow.extraEnv }}
{{- end }}
{{- end }}

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