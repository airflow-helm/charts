{{/*
The python script to syncronize dag statuses
*/}}
{{- define "airflow.dags.sync_dags.py" }}
############################
#### BEGIN: GLOBAL CODE ####
############################
{{- include "airflow.sync.global_code" . }}
##########################
#### END: GLOBAL CODE ####
##########################

#############
## Imports ##
#############
from airflow.utils.db import create_session
from airflow.models import DagModel

###############
## Variables ##
###############
VAR__TEMPLATE_NAMES = []
VAR__TEMPLATE_MTIME_CACHE = {}
VAR__TEMPLATE_VALUE_CACHE = {}

VAR__DAG_STATUS = {
    {{- range $k, $v := .Values.dags.controlled -}}
    "{{ $k }}": {{ $v | ternary "False" "True" }},

    {{- end -}}
}


###############
## Functions ##
###############
def update_dag(session, dag_id: str, is_paused: bool):
    logging.info(f"setting {dag_id} to {is_paused}")
    try:
        qry = session.query(DagModel).filter(DagModel.dag_id == dag_id)
        d = qry.first()
        if d.is_paused != is_paused:
            d.is_paused = is_paused
            session.commit()
    except Exception as err:
        logging.info(f"Failed to set {dag_id} to {is_paused}")
        logging.error(err)
        session.rollback()

def sync_with_airflow():
    with create_session() as session:
        for dag_id, is_paused in VAR__DAG_STATUS.items():
            update_dag(session, dag_id, is_paused)

        {{- if .Values.dags.pauseUncontrolled -}}
        {{- printf "session.query(DagModel).filter(DagModel.dag_id.not_in(list(VAR__DAG_STATUS.keys()))).update({'is_paused': True})\n\n" | nindent 4 -}}
        {{- end -}}

##############
## Run Main ##
##############
{{- if .Values.dags.controlledDagsUpdate }}
main(sync_forever=True)
{{- else }}
main(sync_forever=False)
{{- end }}

{{- end }}