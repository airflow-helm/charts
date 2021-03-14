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
{{- printf "%s" .Chart.Name | trunc 63 | trimSuffix "-" -}}
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
A flag indicating if a celery-like executor is selected (empty if false)
*/}}
{{- define "airflow.executor.celery_like" -}}
{{- if or (eq .Values.airflow.executor "CeleryExecutor") (eq .Values.airflow.executor "CeleryKubernetesExecutor") -}}
true
{{- end -}}
{{- end -}}

{{/*
A flag indicating if a kubernetes-like executor is selected (empty if false)
*/}}
{{- define "airflow.executor.kubernetes_like" -}}
{{- if or (eq .Values.airflow.executor "KubernetesExecutor") (eq .Values.airflow.executor "CeleryKubernetesExecutor") -}}
true
{{- end -}}
{{- end -}}

{{/*
Construct a list of common volumeMounts for the web/scheduler/worker/flower containers
*/}}
{{- define "airflow.common.volumeMounts" }}
- name: scripts
  mountPath: /home/airflow/scripts
  readOnly: true
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
    claimName: {{ .Values.dags.persistence.existingClaim | default (printf "%s-dags" (include "airflow.fullname" . | trunc 58)) }}
{{- else if or (.Values.dags.git.gitSync.enabled) (.Values.dags.initContainer.enabled) }}
- name: dags-data
  emptyDir: {}
{{- end }}
{{- if .Values.logs.persistence.enabled }}
- name: logs-data
  persistentVolumeClaim:
    claimName: {{ .Values.logs.persistence.existingClaim | default (printf "%s-logs" (include "airflow.fullname" . | trunc 58)) }}
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
