{{/*
Define the image configs for airflow containers
*/}}
{{- define "airflow.image" }}
image: {{ .Values.airflow.image.repository }}:{{ .Values.airflow.image.tag }}
imagePullPolicy: {{ .Values.airflow.image.pullPolicy }}
securityContext:
  runAsUser: {{ .Values.airflow.image.uid }}
  runAsGroup: {{ .Values.airflow.image.gid }}
{{- end }}

{{/*
Define an init-container which checks the DB status
*/}}
{{- define "airflow.init_container.check_db" }}
- name: check-db
  {{- include "airflow.image" . | indent 2 }}
  envFrom:
    {{- include "airflow.envFrom" . | indent 4 }}
  env:
    {{- include "airflow.env" . | indent 4 }}
  command:
    - "/usr/bin/dumb-init"
    - "--"
  args:
    - "bash"
    - "-c"
    {{- if .Values.airflow.legacyCommands }}
    - "exec airflow checkdb"
    {{- else }}
    - "exec airflow db check"
    {{- end }}
{{- end }}

{{/*
Define an init-container which waits for DB migrations
*/}}
{{- define "airflow.init_container.wait_for_db_migrations" }}
- name: wait-for-db-migrations
  {{- include "airflow.image" . | indent 2 }}
  envFrom:
    {{- include "airflow.envFrom" . | indent 4 }}
  env:
    {{- include "airflow.env" . | indent 4 }}
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
Define an init-container which installs a list of pip packages
EXAMPLE USAGE: {{ include "airflow.init_container.install_pip_packages" (dict "Release" .Release "Values" .Values "extraPipPackages" $extraPipPackages) }}
*/}}
{{- define "airflow.init_container.install_pip_packages" }}
- name: install-pip-packages
  {{- include "airflow.image" . | indent 2 }}
  command:
    - "/usr/bin/dumb-init"
    - "--"
  args:
    - "pip"
    - "install"
    - "--target"
    - "/opt/python/site-packages"
    {{- range .extraPipPackages }}
    - {{ . | quote }}
    {{- end }}
  volumeMounts:
    - name: python-site-packages
      mountPath: /opt/python/site-packages
{{- end }}

{{/*
Define a container which regularly syncs a git-repo
EXAMPLE USAGE: {{ include "airflow.container.git_sync" (dict "Release" .Release "Values" .Values "sync_one_time" "true") }}
*/}}
{{- define "airflow.container.git_sync" }}
- name: dags-git-sync
  image: {{ .Values.dags.gitSync.image.repository }}:{{ .Values.dags.gitSync.image.tag }}
  imagePullPolicy: {{ .Values.dags.gitSync.image.pullPolicy }}
  securityContext:
    runAsUser: {{ .Values.dags.gitSync.image.uid }}
    runAsGroup: {{ .Values.dags.gitSync.image.gid }}
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
    - name: GIT_SYNC_ADD_USER
      value: "true"
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
The list of `volumeMounts` for web/scheduler/worker/flower container
EXAMPLE USAGE: {{ include "airflow.volumeMounts" (dict "Release" .Release "Values" .Values "extraPipPackages" $extraPipPackages "extraVolumeMounts" $extraVolumeMounts) }}
*/}}
{{- define "airflow.volumeMounts" }}
{{- /* dags */ -}}
{{- if .Values.dags.persistence.enabled }}
- name: dags-data
  mountPath: {{ .Values.dags.path }}
  subPath: {{ .Values.dags.persistence.subPath }}
{{- else if .Values.dags.gitSync.enabled }}
- name: dags-data
  mountPath: {{ .Values.dags.path }}
{{- end }}

{{- /* logs */ -}}
{{- if .Values.logs.persistence.enabled }}
- name: logs-data
  mountPath: {{ .Values.logs.path }}
  subPath: {{ .Values.logs.persistence.subPath }}
{{- end }}

{{- /* pip-packages */ -}}
{{- if .extraPipPackages }}
- name: python-site-packages
  mountPath: /opt/python/site-packages
{{- end }}

{{- /* user-defined (global) */ -}}
{{- if .Values.airflow.extraVolumeMounts }}
{{ toYaml .Values.airflow.extraVolumeMounts }}
{{- end }}

{{- /* user-defined */ -}}
{{- if .extraVolumeMounts }}
{{ toYaml .extraVolumeMounts }}
{{- end }}
{{- end }}

{{/*
The list of `volumes` for web/scheduler/worker/flower Pods
EXAMPLE USAGE: {{ include "airflow.volumes" (dict "Release" .Release "Values" .Values "extraPipPackages" $extraPipPackages "extraVolumes" $extraVolumes) }}
*/}}
{{- define "airflow.volumes" }}
{{- /* dags */ -}}
{{- if .Values.dags.persistence.enabled }}
- name: dags-data
  persistentVolumeClaim:
    {{- if .Values.dags.persistence.existingClaim }}
    claimName: {{ .Values.dags.persistence.existingClaim }}
    {{- else }}
    claimName: {{ printf "%s-dags" (include "airflow.fullname" . | trunc 58) }}
    {{- end }}
{{- else if .Values.dags.gitSync.enabled }}
- name: dags-data
  emptyDir: {}
{{- end }}

{{- /* logs */ -}}
{{- if .Values.logs.persistence.enabled }}
- name: logs-data
  persistentVolumeClaim:
    {{- if .Values.logs.persistence.existingClaim }}
    claimName: {{ .Values.logs.persistence.existingClaim }}
    {{- else }}
    claimName: {{ printf "%s-logs" (include "airflow.fullname" . | trunc 58) }}
    {{- end }}
{{- end }}

{{- /* git-sync */ -}}
{{- if .Values.dags.gitSync.enabled }}
{{- if .Values.dags.gitSync.sshSecret }}
- name: git-secret
  secret:
    secretName: {{ .Values.dags.gitSync.sshSecret }}
    defaultMode: 0644
{{- end }}
{{- if .Values.dags.gitSync.sshKnownHosts }}
- name: git-known-hosts
  secret:
    secretName: {{ include "airflow.fullname" . }}-known-hosts
    defaultMode: 0644
{{- end }}
{{- end }}

{{- /* pip-packages */ -}}
{{- if .extraPipPackages }}
- name: python-site-packages
  emptyDir: {}
{{- end }}

{{- /* user-defined (global) */ -}}
{{- if .Values.airflow.extraVolumes }}
{{ toYaml .Values.airflow.extraVolumes }}
{{- end }}

{{- /* user-defined */ -}}
{{- if .extraVolumes }}
{{ toYaml .extraVolumes }}
{{- end }}
{{- end }}

{{/*
The list of `envFrom` for web/scheduler/worker/flower Pods
*/}}
{{- define "airflow.envFrom" }}
- secretRef:
    name: "{{ include "airflow.fullname" . }}-config"
{{- end }}

{{/*
The list of `env` for web/scheduler/worker/flower Pods
*/}}
{{- define "airflow.env" }}
{{- /* postgres environment variables */ -}}
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

{{- /* redis environment variables */ -}}
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

{{- /* user-defined environment variables */ -}}
{{- if .Values.airflow.extraEnv }}
{{ toYaml .Values.airflow.extraEnv }}
{{- end }}
{{- end }}
