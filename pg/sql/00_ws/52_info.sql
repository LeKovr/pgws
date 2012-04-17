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

*/
-- 52_info.sql - Функции объектов класса info
/* ------------------------------------------------------------------------- */
\qecho '-- FD: pg:ws:52_info.sql / 23 --'

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION info_status() RETURNS d_id32 IMMUTABLE LANGUAGE 'sql' AS 
$_$  -- FD: pg:ws:52_info.sql / 27 -- 
  SELECT 1::ws.d_id32
$_$;
SELECT pg_c('f', 'info_status', 'Статус инфо');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION info_acl(a__sid d_sid) RETURNS SETOF d_acl IMMUTABLE LANGUAGE 'sql' AS 
$_$  -- FD: pg:ws:52_info.sql / 34 -- 
  SELECT 1::ws.d_acl;
$_$;
SELECT pg_c('f', 'info_acl', 'ACL sid для инфо');

/* ------------------------------------------------------------------------- */
-- вернуть описание сервера, отвечающего за экземпляр текущего класса
CREATE OR REPLACE FUNCTION info_server() RETURNS SETOF server STABLE LANGUAGE 'sql' AS 
$_$  -- FD: pg:ws:52_info.sql / 42 -- 
  SELECT * FROM ws.server WHERE id = 1
$_$;

/* ------------------------------------------------------------------------- */
\qecho '-- FD: pg:ws:52_info.sql / 47 --'
