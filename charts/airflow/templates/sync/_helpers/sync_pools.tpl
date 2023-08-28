{{/*
The python sync script for pools.
*/}}
{{- define "airflow.sync.sync_pools.py" }}
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
from airflow.models import Pool
from airflow.utils.db import create_session
from croniter import croniter
from datetime import datetime
from typing import Tuple


#############
## Classes ##
#############
class ScheduledPolicy(object):
    def __init__(
            self,
            name: str,
            recurrence: str,
            slots: int,
    ):
        if not croniter.is_valid(recurrence):
            raise ValueError(f"Invalid recurrence '{recurrence}' for schedule '{name}'")

        self.name = name
        self.recurrence = recurrence
        self.slots = slots

    def last_match_time(self, now: datetime) -> datetime:
        return croniter(expr_format=self.recurrence, start_time=now).get_prev(ret_type=datetime)


class PoolWrapper(object):
    def __init__(
            self,
            name: str,
            description: str,
            slots: int,
            include_deferred: bool,
            policies: List[ScheduledPolicy],
            enable_policies: bool,
    ):
        self.name = name
        self.description = description
        self.slots = slots
        self.include_deferred = include_deferred
        self.policies = policies
        self.enable_policies = enable_policies

    def as_pool(self) -> Pool:
        pool = Pool()
        pool.pool = self.name
        # NOTE: include_deferred is only available in Airflow 2.7.0+
        if hasattr(Pool, "include_deferred"):
            pool.include_deferred = self.include_deferred
        if self._has_policies():
            most_recent_policy = self._most_recent_policy()
            pool.slots = most_recent_policy.slots
            pool.description = f"{self.description} - MOST_RECENT_POLICY='{most_recent_policy.name}'"
        else:
            pool.slots = self.slots
            pool.description = self.description
        return pool

    def _has_policies(self) -> bool:
        return self.enable_policies and len(self.policies) > 0

    def _most_recent_policy(self) -> ScheduledPolicy:
        now = datetime.utcnow()
        return max(self.policies, key=lambda policy: policy.last_match_time(now))


###############
## Variables ##
###############
VAR__TEMPLATE_NAMES = []
VAR__TEMPLATE_MTIME_CACHE = {}
VAR__TEMPLATE_VALUE_CACHE = {}
VAR__POOL_WRAPPERS = {
  {{- range .Values.airflow.pools }}
  {{ .name | quote }}: PoolWrapper(
    name={{ (required "the `name` in each `airflow.pools[]` must be non-empty!" .name) | quote }},
    description={{ (required "the `description` in each `airflow.pools[]` must be non-empty!" .description) | quote }},
    {{- if not (or (typeIs "float64" .slots) (typeIs "int64" .slots)) }}
    {{- /* the type of a number could be float64 or int64 depending on how it was set (values.yaml, or --set) */ -}}
    {{ required "the `slots` in each `airflow.pools[]` must be int-type!" nil }}
    {{- end }}
    slots={{ (required "the `slots` in each `airflow.pools[]` must be non-empty!" .slots) }},
    {{- $include_deferred := dig "include_deferred" nil . }}
    {{- if not (or (typeIs "bool" $include_deferred) (eq $include_deferred nil)) }}
    {{ required "if specified, the `include_deferred` in each `airflow.pools[]` must be bool-type!" nil }}
    {{- end }}
    {{- if $include_deferred }}
    include_deferred=True,
    {{- else }}
    include_deferred=False,
    {{- end }}
    policies=[
        {{- range .policies }}
            ScheduledPolicy(
                name={{ (required "the `name` in each `airflow.pools[].policies[]` must be non-empty!" .name) | quote }},
                recurrence={{ (required "the `recurrence` in each `airflow.pools[].policies[]` must be non-empty!" .recurrence) | quote }},
                {{- if not (or (typeIs "float64" .slots) (typeIs "int64" .slots)) }}
                {{- /* the type of a number could be float64 or int64 depending on how it was set (values.yaml, or --set) */ -}}
                {{ required "the `slots` in each `airflow.pools[].policies[]` must be int-type!" nil }}
                {{- end }}
                slots={{ (required "the `slots` in each `airflow.pools[].policies[]` must be non-empty!" .slots) }},
            ),
        {{- end }}
    ],
    {{- if $.Values.airflow.poolsUpdate }}
    enable_policies=True,
    {{- else }}
    enable_policies=False,
    {{- end }}
  ),
  {{- end }}
}


###############
## Functions ##
###############
def compare_pools(p1: Pool, p2: Pool) -> bool:
    """
    Check if two Pool objects are identical.
    """
    return (
            p1.pool == p1.pool
            and p1.description == p2.description
            and p1.slots == p2.slots
            and getattr(p1, "include_deferred", False) == getattr(p2, "include_deferred", False)
    )


def sync_pool(pool_wrapper: PoolWrapper) -> None:
    """
    Sync the Pool defined by a provided PoolWrapper into the airflow DB.
    """
    p_name = pool_wrapper.name
    p_new = pool_wrapper.as_pool()

    pool_added = False
    pool_updated = False

    with create_session() as session:
        p_old = session.query(Pool).filter(Pool.pool == p_name).first()
        if not p_old:
            logging.info(f"Pool=`{p_name}` is missing, adding...")
            session.add(p_new)
            pool_added = True
        else:
            if compare_pools(p_new, p_old):
                pass
            else:
                logging.info(f"Pool=`{p_name}` exists but has changed, updating...")
                p_old.description = p_new.description
                p_old.slots = p_new.slots
                if hasattr(Pool, "include_deferred"):
                    p_old.include_deferred = p_new.include_deferred
                pool_updated = True

    if pool_added:
        logging.info(f"Pool=`{p_name}` was successfully added.")
    if pool_updated:
        logging.info(f"Pool=`{p_name}` was successfully updated.")


def sync_all_pools(pool_wrappers: Dict[str, PoolWrapper]) -> None:
    """
    Sync all pools in provided `pool_wrappers`.
    """
    logging.info("BEGIN: airflow pools sync")
    for pool_wrapper in pool_wrappers.values():
        sync_pool(pool_wrapper)
    logging.info("END: airflow pools sync")


def sync_with_airflow() -> None:
    """
    Preform a sync of all objects with airflow (note, `sync_with_airflow()` is called in `main()` template).
    """
    sync_all_pools(pool_wrappers=VAR__POOL_WRAPPERS)


##############
## Run Main ##
##############
{{- if .Values.airflow.poolsUpdate }}
main(sync_forever=True)
{{- else }}
main(sync_forever=False)
{{- end }}

{{- end }}