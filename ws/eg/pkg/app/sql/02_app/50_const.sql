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
\qecho '-- FD: app:app:50_const.sql / 23 --'

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const(a_tag TEXT) RETURNS TEXT IMMUTABLE STRICT LANGUAGE 'plpgsql' AS
$_$  -- FD: app:app:50_const.sql / 27 --
  DECLARE
    CLASS_APP    CONSTANT ws.d_classcode := '00'; -- номер класса из class_id
    v TEXT;
  BEGIN

    IF    a_tag = 'APP_ERR_NOINTERNAL'   THEN v := CLASS_APP || '21';
    ELSIF a_tag = 'APP_ERR_NOTFOUND'   THEN v := CLASS_APP || '22';
    ELSE RAISE EXCEPTION 'ERROR: Unknown tag %', a_tag;
    END IF;
    RETURN v;
  END
$_$;

\qecho '-- FD: app:app:50_const.sql / 41 --'
