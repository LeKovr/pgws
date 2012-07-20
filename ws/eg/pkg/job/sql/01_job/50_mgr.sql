/*

    Copyright (c) 2010, 2012 Tender.Pro http://tender.pro.

    This file is part of PGWS - Postgresql WebServices.

    PGWS is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    PGWS is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with PGWS.  If not, see <http://www.gnu.org/licenses/>.

    Методы работы с JobManager
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION mgr_stat_reload() RETURNS VOID VOLATILE LANGUAGE 'sql' AS
$_$
DELETE FROM job.mgr_stat;
DELETE FROM job.mgr_error;
SELECT pg_notify ('job_stat', '');
$_$;
SELECT pg_c('f', 'mgr_stat_reload', 'Обновить статистику JobManager');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION mgr_stat_load(
  a_pid         INTEGER
, a_loop_count  INTEGER
, a_event_count INTEGER
, a_error_count INTEGER
, a_run_at      INTEGER
, a_loop_at     INTEGER
, a_event_at    INTEGER
, a_error_at    INTEGER
, a_cron_at     INTEGER
, a_shadow_at   INTEGER
) RETURNS INTEGER VOLATILE LANGUAGE 'plpgsql' AS
$_$
BEGIN
  UPDATE job.mgr_stat SET
    updated_at    = CURRENT_TIMESTAMP
    , loop_count  = a_loop_count
    , event_count = a_event_count
    , error_count = a_error_count
    , run_at      = ws.epoch2timestamp(a_run_at)
    , loop_at     = ws.epoch2timestamp(a_loop_at)
    , event_at    = ws.epoch2timestamp(a_event_at)
    , error_at    = ws.epoch2timestamp(a_error_at)
    , cron_at     = ws.epoch2timestamp(a_cron_at)
    , shadow_at   = ws.epoch2timestamp(a_shadow_at)
   WHERE pid = a_pid
  ;
  IF NOT FOUND THEN
    INSERT INTO job.mgr_stat(pid, loop_count, event_count, error_count, run_at, loop_at, event_at, error_at, cron_at, shadow_at)
      VALUES (a_pid, a_loop_count, a_event_count, a_error_count
        , ws.epoch2timestamp(a_run_at)
        , ws.epoch2timestamp(a_loop_at)
        , ws.epoch2timestamp(a_event_at)
        , ws.epoch2timestamp(a_error_at)
        , ws.epoch2timestamp(a_cron_at)
        , ws.epoch2timestamp(a_shadow_at)
      )
    ;
  END IF;
  PERFORM pg_notify('job_stat_loaded', a_pid::text); -- To whom it may concern
  RETURN 1;
END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION mgr_error_load(
  a_pid         INTEGER
, a_error_count INTEGER
, a_first_at    INTEGER
, a_last_at     INTEGER
, a_anno        TEXT
) RETURNS INTEGER VOLATILE LANGUAGE 'plpgsql' AS
$_$
BEGIN
  UPDATE job.mgr_error SET
    updated_at    = CURRENT_TIMESTAMP
    , first_at    = ws.min(first_at, ws.epoch2timestamp(a_first_at))
    , last_at     = ws.max(last_at, ws.epoch2timestamp(a_last_at))
    , error_count = error_count + a_error_count
   WHERE pid = a_pid
    AND anno = a_anno
  ;
  IF NOT FOUND THEN
    INSERT INTO job.mgr_error(pid, error_count, anno, first_at, last_at)
      VALUES (a_pid, a_error_count, a_anno
        , ws.epoch2timestamp(a_first_at)
        , ws.epoch2timestamp(a_last_at)
      )
    ;
  END IF;
  PERFORM pg_notify('job_error_loaded', a_pid::text); -- To whom it may concern
  RETURN 1;
END;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION mgr_test_event(a_id_first INTEGER DEFAULT 0, a_id_last INTEGER DEFAULT 10) RETURNS INTEGER VOLATILE LANGUAGE 'plpgsql' AS
$_$
DECLARE
BEGIN
  FOR v_i IN a_id_first..a_id_last LOOP
    PERFORM pg_notify('job_event', v_i::text);
  END LOOP;
  PERFORM job.mgr_stat_reload();
  RETURN a_id_last - a_id_first + 1;
END;
$_$;


/* ------------------------------------------------------------------------- */
