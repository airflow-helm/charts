{{/* Checks for airflow.legacyCommands */}}
{{- if .Values.airflow.legacyCommands }}
  {{- if not (eq "1" (.Values.scheduler.replicas | toString)) }}
  {{ required "If `airflow.legacyCommands=true`, then `scheduler.replicas` must be set to `1`!" nil }}
  {{- end }}
{{- end }}

{{/* Checks for airflow.executor */}}
{{- if eq .Values.airflow.executor "KubernetesExecutor" }}
  {{- if or (.Values.workers.enabled) (.Values.flower.enabled) (.Values.redis.enabled) }}
  {{ required "If `airflow.executor=KubernetesExecutor`, none of [`workers.enabled`, `flower.enabled`, `redis.enabled`] should be `true`!" nil }}
  {{- end }}
{{- end }}

{{/* Checks for airflow.config */}}
{{- if .Values.airflow.config.AIRFLOW__CELERY__BROKER_URL }}
{{ required "Don't define `airflow.config.AIRFLOW__CELERY__BROKER_URL`, it will be automatically set by the chart!" nil }}
{{- end }}
{{- if .Values.airflow.config.AIRFLOW__CELERY__RESULT_BACKEND }}
{{ required "Don't define `airflow.config.AIRFLOW__CELERY__RESULT_BACKEND`, it will be automatically set by the chart!" nil }}
{{- end }}
{{- if .Values.airflow.config.AIRFLOW__CORE__SQL_ALCHEMY_CONN }}
{{ required "Don't define `airflow.config.AIRFLOW__CORE__SQL_ALCHEMY_CONN`, it will be automatically set by the chart!" nil }}
{{- end }}

{{/* Checks for dags.gitSync */}}
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