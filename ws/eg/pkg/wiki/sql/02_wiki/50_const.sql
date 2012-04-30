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
\qecho '-- FD: wiki:wiki:50_const.sql / 23 --'

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION const(a_tag TEXT) RETURNS TEXT IMMUTABLE STRICT LANGUAGE 'plpgsql' AS
$_$  -- FD: wiki:wiki:50_const.sql / 27 --
  DECLARE
    CLASS_WIKI   CONSTANT ws.d_classcode := '99';
    v TEXT;
  BEGIN
    IF    a_tag = 'WIKI_ERR_NOGROUPCODE'  THEN v := CLASS_WIKI || '01';
    ELSIF a_tag = 'WIKI_ERR_NOREVISION'   THEN v := CLASS_WIKI || '02';
    ELSIF a_tag = 'WIKI_ERR_CODEEXISTS'   THEN v := CLASS_WIKI || '03';
    ELSIF a_tag = 'WIKI_ERR_NOCHGTOSAVE'  THEN v := CLASS_WIKI || '04'; -- вызывается из perl-кода
    ELSE RAISE EXCEPTION 'ERROR: Unknown tag %', a_tag;
    END IF;
    RETURN v;
  END
$_$;

\qecho '-- FD: wiki:wiki:50_const.sql / 42 --'