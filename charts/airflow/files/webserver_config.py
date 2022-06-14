from flask_appbuilder.security.manager import AUTH_DB

{{- if .Values.airflow.legacyCommands }}
# only needed for airflow 1.10
from airflow import configuration as conf
SQLALCHEMY_DATABASE_URI = conf.get("core", "SQL_ALCHEMY_CONN")
{{- end }}

# use embedded DB for auth
AUTH_TYPE = AUTH_DB
