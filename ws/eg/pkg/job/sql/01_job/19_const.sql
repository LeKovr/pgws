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

    Константы пакета, используемые в коде
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_pkg() RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'job'::text
$_$;
SELECT pg_c('f', 'const_pkg', 'Кодовое имя пакета "job"');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_status_id_ready() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 2
$_$;
SELECT pg_c('f', 'const_status_id_ready', 'ID статуса задач, готовой к выполнению');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_status_id_again() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 3
$_$;
SELECT pg_c('f', 'const_status_id_again', 'ID статуса задач, готовой к выполнению после ожидания');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_status_id_process() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 4
$_$;
SELECT pg_c('f', 'const_status_id_process', 'ID статуса задач в процессе выполнения');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_status_id_waiting() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 5
$_$;
SELECT pg_c('f', 'const_status_id_waiting', 'ID статуса задач, ожидающих завершения приоритетных');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_status_id_forced() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 7
$_$;
SELECT pg_c('f', 'const_status_id_forced', 'ID статуса задач, выполняемой индивидуальным сервером');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_status_id_locked() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 8
$_$;
SELECT pg_c('f', 'const_status_id_locked', 'ID статуса задач, выполнение которых заблокировано');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_status_id_urgent() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 9
$_$;
SELECT pg_c('f', 'const_status_id_urgent', 'ID статуса задач, выполняемой вне очереди');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_status_id_error() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 12
$_$;
SELECT pg_c('f', 'const_status_id_error', 'ID статуса задач, выполнение которых вызвало ошибку');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_status_id_success() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 10
$_$;
SELECT pg_c('f', 'const_status_id_success', 'ID статуса задач, выполненных успешно');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_status_id_idle() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 13
$_$;
SELECT pg_c('f', 'const_status_id_idle', 'ID статуса задач, выполненных вхолостую');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_arg_type_none() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 1
$_$;
SELECT pg_c('f', 'const_arg_type_none', 'ID типа неиспользуемого аргумента');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_job_group_prop() RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'job'::TEXT;
$_$;
SELECT pg_c('f', 'const_job_group_prop', 'Константа: название группы владельцев свойств');

/* ------------------------------------------------------------------------- */
