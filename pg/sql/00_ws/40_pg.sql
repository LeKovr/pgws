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

    Представления информации БД Postgresql
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW pg_sql AS SELECT
  datname
, NOW() - query_start AS duration
, application_name
, procpid
, current_query
  FROM pg_stat_activity
  WHERE current_query <> '<IDLE>'
  ORDER BY duration DESC
;
SELECT pg_c('v', 'pg_sql', 'Текущие запросы к БД')
;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW pg_const AS SELECT
  ws.pg_schema_by_oid(pronamespace) AS schema
, proname AS code
, pg_catalog.format_type(p.prorettype, NULL) AS type
, ws.pg_exec_func(ws.pg_schema_by_oid(pronamespace), proname) AS value
, obj_description(p.oid, 'pg_proc') AS anno
  FROM pg_catalog.pg_proc p
  WHERE p.proname LIKE 'const_%'
  ORDER BY 1, 2
;

SELECT pg_c('v', 'pg_const', 'Справочник внутренних констант пакетов')
;
