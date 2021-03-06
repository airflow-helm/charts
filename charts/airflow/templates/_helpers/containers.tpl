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
      readOnly: true
{{- end }}