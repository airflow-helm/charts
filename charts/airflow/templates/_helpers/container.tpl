{{/*
Define an init-container which waits for DB migrations
*/}}
{{- define "airflow.init_container.wait_for_db_migrations"}}
- name: wait-for-db-migrations
  image: {{ .Values.airflow.image.repository }}:{{ .Values.airflow.image.tag }}
  imagePullPolicy: {{ .Values.airflow.image.pullPolicy }}
  envFrom:
    - configMapRef:
        name: "{{ include "airflow.fullname" . }}-env"
  env:
    {{- include "airflow.common.env" . | indent 4 }}
  command:
    - "/usr/bin/dumb-init"
    - "--"
  args:
    - "bash"
    - "-c"
    {{- if .Values.airflow.legacyCommands }}
    ## airflow 1.10 has no check-migrations command
    - "exec sleep 5"
    {{- else }}
    - "exec airflow db check-migrations -t 60"
    {{- end }}
{{- end }}

{{/*
Define a container which regularly syncs a git-repo
*/}}
{{- define "airflow.container.git_sync"}}
- name: dags-git-sync
  image: {{ .Values.dags.gitSync.image.repository }}:{{ .Values.dags.gitSync.image.tag }}
  imagePullPolicy: {{ .Values.dags.gitSync.image.pullPolicy }}
  resources:
    {{- toYaml .Values.dags.gitSync.resources | nindent 4 }}
  env:
    {{- if .sync_one_time }}
    - name: GIT_SYNC_ONE_TIME
      value: "true"
    {{- end }}
    - name: GIT_SYNC_ROOT
      value: "/dags"
    - name: GIT_SYNC_DEST
      value: "repo"
    - name: GIT_SYNC_REPO
      value: {{ .Values.dags.gitSync.repo | quote }}
    - name: GIT_SYNC_BRANCH
      value: {{ .Values.dags.gitSync.branch | quote }}
    - name: GIT_SYNC_REV
      value: {{ .Values.dags.gitSync.revision | quote }}
    - name: GIT_SYNC_DEPTH
      value: {{ .Values.dags.gitSync.depth | quote }}
    - name: GIT_SYNC_WAIT
      value: {{ .Values.dags.gitSync.syncWait | quote }}
    - name: GIT_SYNC_TIMEOUT
      value: {{ .Values.dags.gitSync.syncTimeout | quote }}
    {{- if .Values.dags.gitSync.sshSecret }}
    - name: GIT_SYNC_SSH
      value: "true"
    - name: GIT_SSH_KEY_FILE
      value: "/etc/git-secret/id_rsa"
    {{- end }}
    {{- if .Values.dags.gitSync.sshKnownHosts }}
    - name: GIT_KNOWN_HOSTS
      value: "true"
    - name: GIT_SSH_KNOWN_HOSTS_FILE
      value: "/etc/git-secret/known_hosts"
    {{- else }}
    - name: GIT_KNOWN_HOSTS
      value: "false"
    {{- end }}
    {{- if .Values.dags.gitSync.httpSecret }}
    - name: GIT_SYNC_USERNAME
      valueFrom:
        secretKeyRef:
          name: {{ .Values.dags.gitSync.httpSecret }}
          key: {{ .Values.dags.gitSync.httpSecretUsernameKey }}
    - name: GIT_SYNC_PASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ .Values.dags.gitSync.httpSecret }}
          key: {{ .Values.dags.gitSync.httpSecretPasswordKey }}
    {{- end }}
  volumeMounts:
    - name: dags-data
      mountPath: /dags
    {{- if .Values.dags.gitSync.sshSecret }}
    - name: git-secret
      mountPath: /etc/git-secret/id_rsa
      readOnly: true
      subPath: {{ .Values.dags.gitSync.sshSecretKey }}
    {{- end }}
    {{- if .Values.dags.gitSync.sshKnownHosts }}
    - name: git-known-hosts
      mountPath: /etc/git-secret/known_hosts
      readOnly: true
      subPath: known_hosts
    {{- end }}
{{- end }}

{{/*
Construct a list of common "volumeMounts" for the web/scheduler/worker/flower containers
*/}}
{{- define "airflow.common.volumeMounts" }}
- name: scripts
  mountPath: /home/airflow/scripts
  readOnly: true
{{- if .Values.dags.persistence.enabled }}
- name: dags-data
  mountPath: {{ .Values.dags.path }}
  subPath: {{ .Values.dags.persistence.subPath }}
{{- else if .Values.dags.gitSync.enabled }}
- name: dags-data
  mountPath: {{ .Values.dags.path }}
{{- end }}
{{- if .Values.logs.persistence.enabled }}
- name: logs-data
  mountPath: {{ .Values.logs.path }}
  subPath: {{ .Values.logs.persistence.subPath }}
{{- end }}
{{- if .Values.airflow.extraVolumeMounts }}
{{- toYaml .Values.airflow.extraVolumeMounts }}
{{- end }}
{{- end }}

{{/*
Construct a list of common "volumes" for the web/scheduler/worker/flower Pods
*/}}
{{- define "airflow.common.volumes" }}
- name: scripts
  configMap:
    name: {{ include "airflow.fullname" . }}-scripts
    defaultMode: 0755
{{- if and (.Values.dags.gitSync.enabled) (.Values.dags.gitSync.sshSecret) }}
- name: git-secret
  secret:
    secretName: {{ .Values.dags.gitSync.sshSecret }}
    defaultMode: 0644
{{- end }}
{{- if and (.Values.dags.gitSync.enabled) (.Values.dags.gitSync.sshKnownHosts) }}
- name: git-known-hosts
  secret:
    secretName: {{ include "airflow.fullname" . }}-known-hosts
    defaultMode: 0644
{{- end }}
{{- if .Values.dags.persistence.enabled }}
- name: dags-data
  persistentVolumeClaim:
    claimName: {{ .Values.dags.persistence.existingClaim | default (printf "%s-dags" (include "airflow.fullname" . | trunc 58)) }}
{{- else if .Values.dags.gitSync.enabled }}
- name: dags-data
  emptyDir: {}
{{- end }}
{{- if .Values.logs.persistence.enabled }}
- name: logs-data
  persistentVolumeClaim:
    claimName: {{ .Values.logs.persistence.existingClaim | default (printf "%s-logs" (include "airflow.fullname" . | trunc 58)) }}
{{- end }}
{{- if .Values.airflow.extraVolumes }}
{{- toYaml .Values.airflow.extraVolumes }}
{{- end }}
{{- end }}

{{/*
Construct a list of common "env" for the web/scheduler/worker/flower Pods
NOTE: when applicable, we use the secrets created by the postgres/redis charts (which have fixed names and secret keys)
*/}}
{{- define "airflow.common.env" -}}
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
{{- /* ---------- EXTRAS ---------- */ -}}
{{- /* ---------------------------- */ -}}
{{- if .Values.airflow.extraEnv }}
{{ toYaml .Values.airflow.extraEnv }}
{{- end }}
{{- end }}