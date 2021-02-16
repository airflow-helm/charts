{{/* vim: set filetype=mustache: */}}

{{/*
Construct the base name for all resources in this chart.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "airflow.fullname" -}}
{{- printf "%s" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Construct the `labels.app` for used by all resources in this chart.
*/}}
{{- define "airflow.labels.app" -}}
{{- .Values.nameOverride | default .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Construct the `labels.chart` for used by all resources in this chart.
*/}}
{{- define "airflow.labels.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Construct the name of the airflow ServiceAccount.
*/}}
{{- define "airflow.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- .Values.serviceAccount.name | default (include "airflow.fullname" .) -}}
{{- else -}}
{{- .Values.serviceAccount.name | default "default" -}}
{{- end -}}
{{- end -}}

{{/*
Construct the `postgresql.fullname` of the postgresql sub-chat chart.
Used to discover the Service and Secret name created by the sub-chart.
*/}}
{{- define "airflow.postgresql.fullname" -}}
{{- if .Values.postgresql.fullnameOverride -}}
{{- .Values.postgresql.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "postgresql" .Values.postgresql.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Construct the `redis.fullname` of the redis sub-chat chart.
Used to discover the master Service and Secret name created by the sub-chart.
*/}}
{{- define "airflow.redis.fullname" -}}
{{- if .Values.redis.fullnameOverride -}}
{{- .Values.redis.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "redis" .Values.redis.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
A flag indicating if a celery-like executor is selected.
*/}}
{{- define "airflow.executor.celery_like" -}}
{{- if or (eq .Values.airflow.executor "CeleryExecutor") (eq .Values.airflow.executor "CeleryKubernetesExecutor") -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
A flag indicating if a kubernetes-like executor is selected.
*/}}
{{- define "airflow.executor.kubernetes_like" -}}
{{- if or (eq .Values.airflow.executor "KubernetesExecutor") (eq .Values.airflow.executor "CeleryKubernetesExecutor") -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

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
Construct a list of common volumeMounts for the web/scheduler/worker/flower containers
*/}}
{{- define "airflow.common.volumeMounts" }}
- name: scripts
  mountPath: /home/airflow/scripts
{{- if .Values.dags.persistence.enabled }}
- name: dags-data
  mountPath: {{ .Values.dags.path }}
  subPath: {{ .Values.dags.persistence.subPath }}
{{- else if or (.Values.dags.git.gitSync.enabled) (.Values.dags.initContainer.enabled) }}
- name: dags-data
  mountPath: {{ .Values.dags.path }}
{{- end }}
{{- if .Values.logs.persistence.enabled }}
- name: logs-data
  mountPath: {{ .Values.logs.path }}
  subPath: {{ .Values.logs.persistence.subPath }}
{{- end }}
{{- range .Values.airflow.extraConfigmapMounts }}
- name: {{ .name }}
  mountPath: {{ .mountPath }}
  readOnly: {{ .readOnly }}
  {{- if .subPath }}
  subPath: {{ .subPath }}
  {{- end }}
{{- end }}
{{- if .Values.airflow.extraVolumeMounts }}
{{- toYaml .Values.airflow.extraVolumeMounts }}
{{- end }}
{{- end }}

{{/*
Construct a list of volumes which used in web/scheduler/worker/flower Pods
*/}}
{{- define "airflow.common.volumes"}}
- name: scripts
  configMap:
    name: {{ include "airflow.fullname" . }}-scripts
    defaultMode: 0755
{{- if or (.Values.dags.git.gitSync.enabled) (.Values.dags.initContainer.enabled) }}
- name: scripts-git
  configMap:
    name: {{ include "airflow.fullname" . }}-scripts-git
    defaultMode: 0755
{{- if .Values.dags.git.secret }}
- name: git-ssh-secret
  secret:
    secretName: {{ .Values.dags.git.secret }}
    defaultMode: 0700
{{- end }}
{{- end }}
{{- if .Values.dags.persistence.enabled }}
- name: dags-data
  persistentVolumeClaim:
    claimName: {{ .Values.dags.persistence.existingClaim | default (include "airflow.fullname" . ) }}
{{- else if or (.Values.dags.git.gitSync.enabled) (.Values.dags.initContainer.enabled) }}
- name: dags-data
  emptyDir: {}
{{- end }}
{{- if .Values.logs.persistence.enabled }}
- name: logs-data
  persistentVolumeClaim:
    claimName: {{ .Values.logs.persistence.existingClaim | default (printf "%s-logs" (include "airflow.fullname" . | trunc 58 )) }}
{{- end }}
{{- range .Values.airflow.extraConfigmapMounts }}
- name: {{ .name }}
  configMap:
    name: {{ .configMap }}
{{- end }}
{{- if .Values.airflow.extraVolumes }}
{{- toYaml .Values.airflow.extraVolumes }}
{{- end }}
{{- end }}

{{/*
Construct a container definition for dags git-sync
*/}}
{{- define "airflow.container.git_sync"}}
- name: dags-git-sync
  image: {{ .Values.dags.git.gitSync.image.repository }}:{{ .Values.dags.git.gitSync.image.tag }}
  imagePullPolicy: {{ .Values.dags.git.gitSync.image.pullPolicy }}
  resources:
    {{- toYaml .Values.dags.git.gitSync.resources | nindent 4 }}
  command:
    - /home/airflow/scripts-git/git-sync.sh
  args:
    - "{{ .Values.dags.git.url }}"
    - "{{ .Values.dags.git.ref }}"
    - "{{ .Values.dags.git.gitSync.mountPath }}{{ .Values.dags.git.gitSync.syncSubPath }}"
    - "{{ .Values.dags.git.repoHost }}"
    - "{{ .Values.dags.git.repoPort }}"
    - "{{ .Values.dags.git.privateKeyName }}"
    - "{{ .Values.dags.git.gitSync.refreshTime }}"
  volumeMounts:
    - name: dags-data
      mountPath: "{{ .Values.dags.git.gitSync.mountPath }}"
    - name: scripts-git
      mountPath: /home/airflow/scripts-git
    {{- if .Values.dags.git.secret }}
    - name: git-ssh-secret
      mountPath: /keys
    {{- end }}
{{- end }}

{{/*
Construct an init-container definition for dags git-clone
*/}}
{{- define "airflow.init_container.git_clone"}}
- name: dags-git-clone
  image: {{ .Values.dags.initContainer.image.repository }}:{{ .Values.dags.initContainer.image.tag }}
  imagePullPolicy: {{ .Values.dags.initContainer.image.pullPolicy }}
  resources:
    {{- toYaml .Values.dags.initContainer.resources | nindent 4 }}
  command:
    - /home/airflow/scripts-git/git-clone.sh
  args:
    - "{{ .Values.dags.git.url }}"
    - "{{ .Values.dags.git.ref }}"
    - "{{ .Values.dags.initContainer.mountPath }}{{ .Values.dags.initContainer.syncSubPath }}"
    - "{{ .Values.dags.git.repoHost }}"
    - "{{ .Values.dags.git.repoPort }}"
    - "{{ .Values.dags.git.privateKeyName }}"
  volumeMounts:
    - name: dags-data
      mountPath: "{{ .Values.dags.initContainer.mountPath }}"
    - name: scripts-git
      mountPath: /home/airflow/scripts-git
    {{- if .Values.dags.git.secret }}
    - name: git-ssh-secret
      mountPath: /keys
    {{- end }}
{{- end }}

{{/*
Construct an init-container definition for upgradedb
*/}}
{{- define "airflow.init_container.upgradedb"}}
- name: upgradedb
  image: {{ .Values.airflow.image.repository }}:{{ .Values.airflow.image.tag }}
  imagePullPolicy: {{ .Values.airflow.image.pullPolicy}}
  resources:
    {{- toYaml .Values.scheduler.resources | nindent 4 }}
  envFrom:
    - configMapRef:
        name: "{{ include "airflow.fullname" . }}-env"
  env:
    {{- include "airflow.mapenvsecrets" . | indent 4 }}
  command:
    - "/usr/bin/dumb-init"
    - "--"
  args:
    - "/bin/bash"
    - "-c"
    - "/home/airflow/scripts/retry-upgradedb.sh"
  volumeMounts:
    - name: scripts
      mountPath: /home/airflow/scripts
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

