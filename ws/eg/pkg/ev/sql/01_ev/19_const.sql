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
  SELECT 'ev'::text
$_$;
SELECT pg_c('f', 'const_pkg', 'Кодовое имя пакета "ev"');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_status_id_draft() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 1
$_$;
SELECT pg_c('f', 'const_status_id_draft', 'ID статуса события до готовности спецификации');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_status_id_rcpt() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 2
$_$;
SELECT pg_c('f', 'const_status_id_rcpt', 'ID статуса события в процессе формирования списка адресатов');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_status_id_notify() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 3
$_$;
SELECT pg_c('f', 'const_status_id_notify', 'ID статуса события в процессе формирования уведомлений');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_status_id_done() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 4
$_$;
SELECT pg_c('f', 'const_status_id_done', 'ID статуса события после завершения всех действий');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_status_id_archive() RETURNS INTEGER IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 7
$_$;
SELECT pg_c('f', 'const_status_id_archive', 'ID статуса события, не имеющего списка адресатов');


/* ------------------------------------------------------------------------- */
