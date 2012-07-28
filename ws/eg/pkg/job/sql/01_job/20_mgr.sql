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

    Таблицы JobManager
*/

/* ------------------------------------------------------------------------- */
CREATE TABLE job.mgr_stat (
  pid         INTEGER PRIMARY KEY
, loop_count  INTEGER
, event_count INTEGER
, error_count INTEGER
, run_at      TIMESTAMP(0)
, loop_at     TIMESTAMP(0)
, event_at    TIMESTAMP(0)
, error_at    TIMESTAMP(0)
, cron_at     TIMESTAMP(0)
, shadow_at   TIMESTAMP(0)
, updated_at  TIMESTAMP(0) DEFAULT CURRENT_TIMESTAMP
);
SELECT pg_c('r', 'mgr_stat', 'Статистика процессов JobManager')
  ,pg_c('c', 'mgr_stat.pid', 'PID процесса')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE job.mgr_error (
  pid         INTEGER
, error_count INTEGER
, anno        TEXT
, first_at    TIMESTAMP(0)
, last_at     TIMESTAMP(0)
, updated_at  TIMESTAMP(0) DEFAULT CURRENT_TIMESTAMP
, CONSTRAINT  mgr_error_pkey PRIMARY KEY (pid, anno)
);
SELECT pg_c('r', 'mgr_error', 'Ошибки процессов JobManager')
  ,pg_c('c', 'mgr_error.pid', 'PID процесса')
;

/* ------------------------------------------------------------------------- */
