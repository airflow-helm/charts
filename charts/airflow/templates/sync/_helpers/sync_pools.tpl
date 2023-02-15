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


class Schedule(object):

    def __init__(
            self,
            name: str,
            recurrence: str,
            slots: int
    ):
        if not croniter.is_valid(recurrence):
            raise ValueError(f"Invalid recurrence {recurrence} for schedule {name}")

        self.name = name

        self.recurrence = recurrence
        self.slots = slots

    def update(self, pool: "PoolWrapper"):
        """updates pool based on the policy"""
        pool.slots = self.slots

    def get_last_update(self, now: datetime) -> datetime:
        return croniter(expr_format=self.recurrence, start_time=epoch).get_prev(ret_type=datetime)



class PoolWrapper(object):
    def __init__(
            self,
            name: str,
            description: str,
            slots: int,
            schedules: List[Schedule]
    ):
        self.name = name
        self.description = description
        self.slots = slots
        self.schedules = schedules

    def as_pool(self) -> Pool:
        pool = Pool()
        pool.pool = self.name
        pool.slots = self.slots
        pool.description = self.description
        return pool

    @property
    def is_scheduled(self) -> bool:
        return len(self.schedules) > 0

    def update_from_schedules(self, ) -> None:
        epoch = datetime.now()
        most_recent_schedule = sorted(self.schedules, key=lambda x: x.get_last_update(now))[-1]
        most_recent_schedule.update(self)




###############
## Variables ##
###############
VAR__TEMPLATE_NAMES = []
VAR__TEMPLATE_MTIME_CACHE = {}
VAR__TEMPLATE_VALUE_CACHE = {}
VAR__POOL_WRAPPERS = {
  {{- range .Values.airflow.pools }}
  {{ .name | quote }}: PoolWrapper(
    name={{ (required "each `name` in `airflow.pools` must be non-empty!" .name) | quote }},
    description={{ (required "each `description` in `airflow.pools` must be non-empty!" .description) | quote }},
    {{- if not (or (typeIs "float64" .slots) (typeIs "int64" .slots)) }}
    {{- /* the type of a number could be float64 or int64 depending on how it was set (values.yaml, or --set) */ -}}
    {{ required "each `slots` in `airflow.pools` must be int-type!" nil }}
    {{- end }}
    slots={{ (required "each `slots` in `airflow.pools` must be non-empty!" .slots) }},
    {{- if and (not $.Values.airflow.poolsUpdate) (gt (len (default "" .schedules)) 0)  }}
        {{ required "`airflow.poolsUpdate` must be true when specifying scheduled pools" nil }}
    {{- end }}
    schedules=[
        {{- range .schedules }}
            Schedule(
                name={{ (required "each `name` in `airflow.pools.schedules` must be non-empty!" .name) | quote }},
                recurrence={{ (required "each `recurrence` in `airflow.pools.recurrence` must be non-empty!" .recurrence) | quote }},
                {{- if not (or (typeIs "float64" .slots) (typeIs "int64" .slots)) }}
                {{- /* the type of a number could be float64 or int64 depending on how it was set (values.yaml, or --set) */ -}}
                {{ required "each `slots` in `airflow.pools` must be int-type!" nil }}
                {{- end }}
                slots={{ (required "each `slots` in `airflow.pools` must be non-empty!" .slots) }},
            ),
        {{- end }}
    ]
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


def update_pool_wrappers_from_schedules(pool_wrappers: Dict[str, PoolWrapper]) -> None:
    """
    Sync all scheduled pools in provided `pool_wrappers` according to the most recent schedule.
    """
    for pool in pool_wrappers.values():
        if pool.is_scheduled:
            pool.update_from_schedules()


def sync_with_airflow() -> None:
    """
    Preform a sync of all objects with airflow (note, `sync_with_airflow()` is called in `main()` template).
    """
    {{- if .Values.airflow.poolsUpdate }}
    update_pool_wrappers_from_schedules(pool_wrappers=VAR__POOL_WRAPPERS)
    {{- end }}

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