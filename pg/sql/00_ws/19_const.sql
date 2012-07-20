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

    Константы
*/

/* ------------------------------------------------------------------------- */
SET LOCAL search_path = ws, i18n_def, public;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_rpc_err_nodata() RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT '02000'::TEXT
$_$;
SELECT pg_c('f', 'const_rpc_err_nodata', 'Константа: RPC код ошибки отсутствия данных');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const_rpc_err_noaccess() RETURNS TEXT IMMUTABLE LANGUAGE 'sql' AS
$_$
  SELECT '42501'::TEXT
$_$;
SELECT pg_c('f', 'const_rpc_err_noaccess', 'Константа: RPC код ошибки отсутствия доступа');
