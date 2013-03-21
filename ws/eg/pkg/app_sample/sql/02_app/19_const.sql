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
SET LOCAL search_path = :PKG, ws, i18n_def, public;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_forbidden() RETURNS d_errcode IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'Y0021'::ws.d_errcode
$_$;
SELECT pg_c('f', 'const_error_forbidden', 'Константа: ошибка доступа уровня приложения');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_error_notfound() RETURNS d_errcode IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT 'Y0021'::ws.d_errcode
$_$;
SELECT pg_c('f', 'const_error_notfound', 'Константа: ошибка поиска уровня приложения');
