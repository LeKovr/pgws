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

    Внутренние константы пакета. Используются хранимым кодом.
*/

/* ------------------------------------------------------------------------- */
SET LOCAL search_path = wiki, ws, i18n_def, public;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_nogroupcode() RETURNS ws.d_errcode IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT '9901'::ws.d_errcode
$_$;
SELECT pg_c('f', 'const_error_nogroupcode', 'Константа: ошибка поиска группы по коду');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_norevision() RETURNS ws.d_errcode IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT '9902'::ws.d_errcode
$_$;
SELECT pg_c('f', 'const_error_norevision', 'Константа: ошибка соответствия версии документа');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_codeexists() RETURNS ws.d_errcode IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT '9903'::ws.d_errcode
$_$;
SELECT pg_c('f', 'const_error_codeexists', 'Константа: ошибка повторного создания кода документа');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_nochgtosave() RETURNS ws.d_errcode IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT '9904'::ws.d_errcode
$_$;
SELECT pg_c('f', 'const_error_nochgtosave', 'Константа: ошибка сохранения версии, не содержащей изменений');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_nodoc() RETURNS ws.d_errcode IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT '9905'::ws.d_errcode
$_$;
SELECT pg_c('f', 'const_error_nodoc', 'Константа: ошибка поиска статьи');
