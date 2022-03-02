{{/*
The python sync script for roles.
*/}}
{{- define "airflow.sync.sync_roles.py" }}
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
import sys
from typing import List, Tuple, Dict
from flask_appbuilder.security.sqla.models import Role
{{- if .Values.airflow.legacyCommands }}
import airflow.www_rbac.app as www_app
flask_app, flask_appbuilder = www_app.create_app()
{{- else }}
import airflow.www.app as www_app
flask_app = www_app.create_app()
flask_appbuilder = flask_app.appbuilder
{{- end }}


#############
## Classes ##
#############
class RoleWrapper(object):
    def __init__(
            self,
            name: str,
            permissions: List[Tuple[str, str]] = []
    ):
        self.name = name
        self.permissions = permissions

    def as_dict(self) -> Dict[str, any]:
        return {
            "name": self.name,
            "permissions": self.permissions
        }


###############
## Variables ##
###############
VAR__TEMPLATE_NAMES = []
VAR__TEMPLATE_MTIME_CACHE = {}
VAR__TEMPLATE_VALUE_CACHE = {}
VAR__ROLE_WRAPPERS = {
  {{- range .Values.airflow.roles }}
  {{ .name | quote }}: RoleWrapper(
    name={{ (required "each `name` in `airflow.roles` must be non-empty!" .name) | quote }},
    permissions=[
      {{- range .permissions }}
        ( {{ index . 0 | quote }}, {{ index . 1 | quote }} ),
      {{- end }}
    ]
  ),
  {{- end }}
}


def sync_role(role_wrapper: RoleWrapper) -> None:
    """
    Sync the Role defined by a provided RoleWrapper into the FAB DB.
    """
    name = role_wrapper.name
    r_new = role_wrapper.as_dict()
    r_old = flask_appbuilder.sm.find_role(name=name)

    if r_old:
        role = r_old
    else:
        logging.info(f"Role=`{name}` is missing, adding...")
        role = flask_appbuilder.sm.add_role(name=r_new["name"])
        if role:
            logging.info(f"Role=`{name}` was successfully added.")
        else:
            logging.error(f"Failed to add Role=`{name}`")
            sys.exit(1)
    
    p_old = set([(p.permission.name, p.view_menu.name) for p in role.permissions])
    p_new = set(r_new["permissions"])

    for p in (p_old - p_new):
        # Not deleting DAG-level permissions, as they are assigned using `access_control` attribute in DAG code
        if not p[1].startswith('DAG:'):
            perm_view = flask_appbuilder.sm.find_permission_view_menu(p[0], p[1])
            flask_appbuilder.sm.del_permission_role(role, perm_view)
            logging.info(f"Deleted permission `{perm_view}` from role=`{role.name}`")
    
    for p in (p_new - p_old):
        perm_view = flask_appbuilder.sm.find_permission_view_menu(p[0], p[1])
        if perm_view is None:
            logging.error(f"Failed to add permission `{p[0]} {p[1]}` to role=`{role.name}` - no such permission")
            sys.exit(1)
        flask_appbuilder.sm.add_permission_role(role, perm_view)
        logging.info(f"Added permission `{perm_view}` to role=`{role.name}`")


def sync_all_roles(role_wrappers: Dict[str, RoleWrapper]) -> None:
    """
    Sync all roles in provided `role_wrappers`.
    """
    logging.info("BEGIN: airflow roles sync")
    for role_wrapper in role_wrappers.values():
        sync_role(role_wrapper)
    logging.info("END: airflow roles sync")

    # ensures than any SQLAlchemy sessions are closed (so we don't hold a connection to the database)
    flask_app.do_teardown_appcontext()


def sync_with_airflow() -> None:
    """
    Preform a sync of all objects with airflow (note, `sync_with_airflow()` is called in `main()` template).
    """
    sync_all_roles(role_wrappers=VAR__ROLE_WRAPPERS)


##############
## Run Main ##
##############
{{- if .Values.airflow.rolesUpdate }}
main(sync_forever=True)
{{- else }}
main(sync_forever=False)
{{- end }}

{{- end }}