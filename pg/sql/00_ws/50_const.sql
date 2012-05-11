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
-- 50_const.sql - Вспомогательные функции
/* ------------------------------------------------------------------------- */
\qecho '-- FD: pgws:ws:50_const.sql / 23 --'

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const(a_tag TEXT) RETURNS TEXT IMMUTABLE STRICT LANGUAGE 'plpgsql' AS
$_$  -- FD: pgws:ws:50_const.sql / 27 --
  DECLARE
    CLASS_CORE    CONSTANT ws.d_classcode := '00';
    CLASS_SYSTEM CONSTANT ws.d_classcode := '01';
    v TEXT;
  BEGIN

    IF    a_tag = 'RPC_ERR_NODATA'   THEN v := '02000';
    ELSIF a_tag = 'RPC_ERR_NOACCESS'   THEN v := '42501';
    ELSE RAISE EXCEPTION 'ERROR: Unknown tag %', a_tag;
    END IF;
    RETURN v;
  END
$_$;

\qecho '-- FD: pgws:ws:50_const.sql / 42 --'
