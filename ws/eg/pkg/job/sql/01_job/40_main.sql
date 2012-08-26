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

    Представления пакета
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW stored AS
  SELECT
    'current'::TEXT AS storage_code, * FROM wsd.job
  UNION SELECT
    'todo'::TEXT AS storage_code,    * FROM wsd.job_todo
  UNION SELECT
    'past'::TEXT AS storage_code,    * FROM wsd.job_past
;
SELECT pg_c('v', 'stored', 'Все хранилища job')
  , pg_c('c', 'stored.storage_code', 'Код хранилища')
;

CREATE OR REPLACE VIEW srv_attr AS
  SELECT
    id
  , validfrom
  , prio
  , handler_id AS h_id
  , job.handler_pkg_code(handler_id) AS code
  , status_id AS s_id
  , job.status_name(status_id)
  , created_by
  , waiting_for as wait4
  , created_at::TIMESTAMP(0)
  , run_at::TIMESTAMP(0)
  , exit_at::TIMESTAMP(0)
--  , run_pid
  FROM wsd.job
  ORDER BY id
;

CREATE OR REPLACE VIEW arg_attr AS
  SELECT
    id
  , validfrom
  , handler_id
  , status_id
  , arg_id
  , arg_date
  , arg_num
  , arg_more
  , arg_id2
  , arg_date2
  , arg_id3
  FROM wsd.job
  ORDER BY id
;

