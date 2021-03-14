{{/*
Construct an init-container which waits for DB migrations
*/}}
{{- define "airflow.init_container.wait_for_db_migrations"}}
- name: wait-for-db-migrations
  image: {{ .Values.airflow.image.repository }}:{{ .Values.airflow.image.tag }}
  imagePullPolicy: {{ .Values.airflow.image.pullPolicy }}
  envFrom:
    - configMapRef:
        name: "{{ include "airflow.fullname" . }}-env"
  env:
    {{- include "airflow.mapenvsecrets" . | indent 4 }}
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
Construct an init-container which clones the DAG git repo once
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
      mountPath: {{ .Values.dags.initContainer.mountPath }}
    - name: scripts-git
      mountPath: /home/airflow/scripts-git
      readOnly: true
    {{- if .Values.dags.git.secret }}
    - name: git-ssh-secret
      mountPath: /keys
      readOnly: true
    {{- end }}
{{- end }}

{{/*
Construct a container definition which regularly syncs the DAG git repo
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
      mountPath: {{ .Values.dags.git.gitSync.mountPath }}
    - name: scripts-git
      mountPath: /home/airflow/scripts-git
      readOnly: true
    {{- if .Values.dags.git.secret }}
    - name: git-ssh-secret
      mountPath: /keys
      readOnly: true
    {{- end }}
{{- end }}