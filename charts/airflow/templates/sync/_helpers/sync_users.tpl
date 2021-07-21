{{/*
The python sync script for users.
*/}}
{{- define "airflow.snyc.sync_users.py" }}
############################
#### BEGIN: GLOBAL CODE ####
############################
{{- include "airflow.snyc.global_code" . }}
##########################
#### END: GLOBAL CODE ####
##########################


#############
## Imports ##
#############
import sys
from flask_appbuilder.security.sqla.models import User, Role
from werkzeug.security import check_password_hash, generate_password_hash
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
class UserWrapper(object):
    def __init__(
            self,
            username: str,
            first_name: Optional[str] = None,
            last_name: Optional[str] = None,
            email: Optional[str] = None,
            role: Optional[str] = None,
            password: Optional[str] = None
    ):
        self.username = username
        self._first_name = first_name
        self._last_name = last_name
        self._email = email
        self.role = role
        self._password = password

    @property
    def first_name(self) -> str:
        return string_substitution(self._first_name, VAR__TEMPLATE_VALUE_CACHE)

    @property
    def last_name(self) -> str:
        return string_substitution(self._last_name, VAR__TEMPLATE_VALUE_CACHE)

    @property
    def email(self) -> str:
        return string_substitution(self._email, VAR__TEMPLATE_VALUE_CACHE)

    @property
    def password(self) -> str:
        return string_substitution(self._password, VAR__TEMPLATE_VALUE_CACHE)

    def as_dict(self) -> Dict[str, str]:
        return {
            "username": self.username,
            "first_name": self.first_name,
            "last_name": self.last_name,
            "email": self.email,
            "role": find_role(role_name=self.role),
            "password": self.password
        }


###############
## Variables ##
###############
VAR__TEMPLATE_NAMES = [
  {{- range $k, $v := .Values.airflow.usersTemplates }}
  {{ $k | quote }},
  {{- end }}
]
VAR__TEMPLATE_MTIME_CACHE = {}
VAR__TEMPLATE_VALUE_CACHE = {}
VAR__USER_WRAPPERS = {
  {{- range .Values.airflow.users }}
  {{ .username | quote }}: UserWrapper(
    username={{ (required "each `username` in `airflow.users` must be non-empty!" .username) | quote }},
    first_name={{ (required "each `firstName` in `airflow.users` must be non-empty!" .firstName) | quote }},
    last_name={{ (required "each `lastName` in `airflow.users` must be non-empty!" .lastName) | quote }},
    email={{ (required "each `email` in `airflow.users` must be non-empty!" .email) | quote }},
    role={{ (required "each `role` in `airflow.users` must be non-empty!" .role) | quote }},
    password={{ (required "each `password` in `airflow.users` must be non-empty!" .password) | quote }},
  ),
  {{- end }}
}


###############
## Functions ##
###############
def find_role(role_name: str) -> Role:
    """
    Get the FAB Role model associated with a `role_name`.
    """
    found_role = flask_appbuilder.sm.find_role(role_name)
    if found_role:
        return found_role
    else:
        valid_roles = flask_appbuilder.sm.get_all_roles()
        logging.error(f"Failed to find role=`{role_name}`, valid roles are: {valid_roles}")
        sys.exit(1)


def compare_users(user_dict: Dict, user_model: User) -> bool:
    """
    Check if user info (stored in dict) is identical to a FAB User model.
    """
    return (
            user_dict["username"] == user_model.username
            and user_dict["first_name"] == user_model.first_name
            and user_dict["last_name"] == user_model.last_name
            and user_dict["email"] == user_model.email
            and [user_dict["role"]] == user_model.roles
            and check_password_hash(pwhash=user_model.password, password=user_dict["password"])
    )


def sync_user(user_wrapper: UserWrapper) -> None:
    """
    Sync the User defined by a provided UserWrapper into the FAB DB.
    """
    username = user_wrapper.username
    u_new = user_wrapper.as_dict()
    u_old = flask_appbuilder.sm.find_user(username=username)

    if not u_old:
        logging.info(f"User=`{username}` is missing, adding...")
        if flask_appbuilder.sm.add_user(
                username=u_new["username"],
                first_name=u_new["first_name"],
                last_name=u_new["last_name"],
                email=u_new["email"],
                role=u_new["role"],
                password=u_new["password"]
        ):
            logging.info(f"User=`{username}` was successfully added.")
        else:
            logging.error(f"Failed to add User=`{username}`")
            sys.exit(1)
    else:
        if compare_users(u_new, u_old):
            pass
        else:
            logging.info(f"User=`{username}` exists but has changed, updating...")
            u_old.first_name = u_new["first_name"]
            u_old.last_name = u_new["last_name"]
            u_old.email = u_new["email"]
            u_old.roles = [u_new["role"]]
            u_old.password = generate_password_hash(u_new["password"])
            # strange check for False is because update_user() returns None for success
            # but in future might return the User model
            if not (flask_appbuilder.sm.update_user(u_old) is False):
                logging.info(f"User=`{username}` was successfully updated.")
            else:
                logging.error(f"Failed to update User=`{username}`")
                sys.exit(1)


def sync_all_users(user_wrappers: Dict[str, UserWrapper]) -> None:
    """
    Sync all users in provided `user_wrappers`.
    """
    logging.info("BEGIN: airflow users sync")
    for user_wrapper in user_wrappers.values():
        sync_user(user_wrapper)
    logging.info("END: airflow users sync")

    # ensures than any SQLAlchemy sessions are closed (so we don't hold a connection to the database)
    flask_app.do_teardown_appcontext()


def sync_with_airflow() -> None:
    """
    Preform a sync of all objects with airflow (note, `sync_with_airflow()` is called in `main()` template).
    """
    sync_all_users(user_wrappers=VAR__USER_WRAPPERS)


##############
## Run Main ##
##############
{{- if .Values.airflow.usersUpdate }}
main(sync_forever=True)
{{- else }}
main(sync_forever=False)
{{- end }}

{{- end }}