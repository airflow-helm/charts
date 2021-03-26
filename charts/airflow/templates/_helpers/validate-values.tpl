{{/* Checks for `.Release.name` */}}
{{- if gt (len .Release.Name) 43 }}
  {{ required "The `.Release.name` must be less than 43 characters (due to the 63 character limit for names in Kubernetes)!" nil }}
{{- end }}

{{/* Checks for `airflow.legacyCommands` */}}
{{- if .Values.airflow.legacyCommands }}
  {{- if not (eq "1" (.Values.scheduler.replicas | toString)) }}
  {{ required "If `airflow.legacyCommands=true`, then `scheduler.replicas` must be set to `1`!" nil }}
  {{- end }}
{{- end }}

{{/* Checks for `airflow.executor` */}}
{{- if not (has .Values.airflow.executor (list "CeleryExecutor" "CeleryKubernetesExecutor" "KubernetesExecutor")) }}
  {{ required "The `airflow.executor` must be one of: [CeleryExecutor, CeleryKubernetesExecutor, KubernetesExecutor]!" nil }}
{{- end }}
{{- if eq .Values.airflow.executor "CeleryExecutor" }}
  {{- if or (not .Values.workers.enabled) (not .Values.redis.enabled) }}
  {{ required "If `airflow.executor=CeleryExecutor`, all of [`workers.enabled`, `redis.enabled`] should be `true`!" nil }}
  {{- end }}
{{- end }}
{{- if eq .Values.airflow.executor "CeleryKubernetesExecutor" }}
  {{- if or (not .Values.workers.enabled) (not .Values.redis.enabled) }}
  {{ required "If `airflow.executor=CeleryKubernetesExecutor`, all of [`workers.enabled`, `redis.enabled`] should be `true`!" nil }}
  {{- end }}
{{- end }}
{{- if eq .Values.airflow.executor "KubernetesExecutor" }}
  {{- if or (.Values.workers.enabled) (.Values.flower.enabled) (.Values.redis.enabled) }}
  {{ required "If `airflow.executor=KubernetesExecutor`, none of [`workers.enabled`, `flower.enabled`, `redis.enabled`] should be `true`!" nil }}
  {{- end }}
{{- end }}

{{/* Checks for `airflow.config` */}}
{{- if .Values.airflow.config.AIRFLOW__CORE__EXECUTOR }}
  {{ required "Don't define `airflow.config.AIRFLOW__CORE__EXECUTOR`, it will be automatically set by the chart!" nil }}
{{- end }}
{{- if or .Values.airflow.config.AIRFLOW__CORE__DAGS_FOLDER }}
  {{ required "Don't define `airflow.config.AIRFLOW__CORE__EXECUTOR`, it will be automatically set by the chart!" nil }}
{{- end }}
{{- if or (.Values.airflow.config.AIRFLOW__CELERY__BROKER_URL) (.Values.airflow.config.AIRFLOW__CELERY__BROKER_URL_CMD) }}
  {{ required "Don't define `airflow.config.AIRFLOW__CELERY__BROKER_URL`, it will be automatically set by the chart!" nil }}
{{- end }}
{{- if or (.Values.airflow.config.AIRFLOW__CELERY__RESULT_BACKEND) (.Values.airflow.config.AIRFLOW__CELERY__RESULT_BACKEND_CMD) }}
  {{ required "Don't define `airflow.config.AIRFLOW__CELERY__RESULT_BACKEND`, it will be automatically set by the chart!" nil }}
{{- end }}
{{- if or (.Values.airflow.config.AIRFLOW__CORE__SQL_ALCHEMY_CONN) (.Values.airflow.config.AIRFLOW__CORE__SQL_ALCHEMY_CONN_CMD) }}
  {{ required "Don't define `airflow.config.AIRFLOW__CORE__SQL_ALCHEMY_CONN`, it will be automatically set by the chart!" nil }}
{{- end }}

{{/* Checks for `dags.gitSync` */}}
{{- if .Values.dags.gitSync.enabled }}
  {{- if .Values.dags.persistence.enabled }}
  {{ required "If `dags.gitSync.enabled=true`, then `persistence.enabled` must be disabled!" nil }}
  {{- end }}
  {{- if not .Values.dags.gitSync.repo }}
  {{ required "If `dags.gitSync.enabled=true`, then `dags.gitSync.repo` must be non-empty!" nil }}
  {{- end }}
  {{- if and (.Values.dags.gitSync.sshSecret) (.Values.dags.gitSync.httpSecret) }}
  {{ required "At most, one of `dags.gitSync.sshSecret` and `dags.gitSync.httpSecret` can be defined!" nil }}
  {{- end }}
  {{- if and (.Values.dags.gitSync.repo | lower | hasPrefix "git@github.com") (not .Values.dags.gitSync.sshSecret) }}
  {{ required "You must define `dags.gitSync.sshSecret` when using GitHub with SSH for `dags.gitSync.repo`!" nil }}
  {{- end }}
{{- end }}

{{/* Checks for `ingress` */}}
{{- if .Values.ingress }}
  {{/* Checks for `ingress.web.path` */}}
  {{- if .Values.ingress.web.path }}
    {{- if not (.Values.ingress.web.path | hasPrefix "/") }}
    {{ required "The `ingress.web.path` should start with a '/'!" nil }}
    {{- end }}
    {{- if .Values.ingress.web.path | hasSuffix "/" }}
    {{ required "The `ingress.web.path` should NOT include a trailing '/'!" nil }}
    {{- end }}
  {{- end }}

  {{/* Checks for `ingress.flower.path` */}}
  {{- if .Values.ingress.flower.path }}
    {{- if not (.Values.ingress.flower.path | hasPrefix "/") }}
    {{ required "The `ingress.flower.path` should start with a '/'!" nil }}
    {{- end }}
    {{- if .Values.ingress.flower.path | hasSuffix "/" }}
    {{ required "The `ingress.flower.path` should NOT include a trailing '/'!" nil }}
    {{- end }}
    {{- if .Values.airflow.config.AIRFLOW__CELERY__FLOWER_URL_PREFIX }}
      {{- if not (eq .Values.ingress.flower.path .Values.airflow.config.AIRFLOW__CELERY__FLOWER_URL_PREFIX) }}
      {{ required "The `ingress.flower.path` should be the same as `airflow.config.AIRFLOW__CELERY__FLOWER_URL_PREFIX`!" nil }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}