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

    PGWS. Вспомогательные функции
*/
/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION status_name (a_id INTEGER) RETURNS TEXT STABLE LANGUAGE 'sql' AS
$_$
  SELECT name FROM job.status WHERE id = $1;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION status_can_create (a_id INTEGER) RETURNS BOOL STABLE LANGUAGE 'sql' AS
$_$
  SELECT can_create FROM job.status WHERE id = $1;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION status_can_run (a_id INTEGER) RETURNS BOOL STABLE LANGUAGE 'sql' AS
$_$
  SELECT can_run FROM job.status WHERE id = $1;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION status_can_arc (a_id INTEGER) RETURNS BOOL STABLE LANGUAGE 'sql' AS
$_$
  SELECT can_arc FROM job.status WHERE id = $1;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION handler_id (
  a_pkg TEXT
, a_code TEXT
) RETURNS INTEGER
STABLE LANGUAGE 'plpgsql' AS
$_$
  -- handler_id - Номер договора компании на заданную дату
  -- a_pkg:   Код пакета
  -- a_code:  Код класса
  DECLARE
    v_handler_id job.handler.id%TYPE;
  BEGIN
    SELECT INTO v_handler_id
      id
      FROM job.handler
      WHERE pkg = a_pkg AND code = a_code
    ;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Unknown handler code %:%', a_pkg, a_code;
    END IF;
    RETURN v_handler_id;
  END
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION handler_id (a_type_handler_code TEXT) RETURNS INTEGER STABLE LANGUAGE 'sql' AS
$_$
  -- handler_id - Номер договора компании на заданную дату
  -- a_type_handler_code:   "Код типа"."Код класса"
  SELECT job.handler_id(split_part($1, '.', 1), split_part($1, '.', 2));
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION handler_name (a_id INTEGER) RETURNS TEXT STABLE LANGUAGE 'sql' AS
$_$
  -- handler_name - Имя класса по id
  -- a_id: ID класса
  SELECT name FROM job.handler WHERE id = $1;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION handler_pkg_code (a_id INTEGER) RETURNS TEXT STABLE LANGUAGE 'sql' AS
$_$
  -- handler_name - Имя класса по id
  -- a_id: ID класса
  SELECT pkg||'.'||code FROM job.handler WHERE id = $1;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION handler_dust_days (a_id INTEGER) RETURNS INTEGER STABLE LANGUAGE 'sql' AS
$_$
  SELECT dust_days FROM job.handler WHERE id = $1;
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION handler (INTEGER) RETURNS job.handler STABLE LANGUAGE 'sql' AS
$_$
/* Вызов: job.handler_info(handler_id) */
  SELECT * FROM job.handler WHERE id = $1
$_$;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION current (a_id INTEGER) RETURNS wsd.job STABLE LANGUAGE 'sql' AS
$_$
  SELECT * FROM wsd.job WHERE id = $1;
$_$;

/* ------------------------------------------------------------------------- */
