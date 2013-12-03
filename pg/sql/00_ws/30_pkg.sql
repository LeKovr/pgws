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

    Компиляция и установка пакетов
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pkg_current() RETURNS SETOF TEXT STABLE LANGUAGE 'sql' AS
$_$
  SELECT code FROM ws.pkg WHERE op = 'init';
$_$;
SELECT pg_c('f', 'pkg_current', 'текущий инициализирующийся пакет');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION pg_pkg() RETURNS TEXT STABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_pkg TEXT;
  BEGIN
    SELECT INTO v_pkg * FROM ws.pkg_current();
    IF NOT FOUND THEN
      v_pkg := ws.pg_cs();
    END IF;
    RETURN v_pkg;
  END
$_$;
SELECT pg_c('f', 'pg_pkg', 'текущая схема');
