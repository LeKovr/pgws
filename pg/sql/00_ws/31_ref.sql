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

    Методы работы со справочниками
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ref_info(a_id d_id32) RETURNS SETOF ref STABLE LANGUAGE 'sql' AS
$_$
  SELECT * FROM ws.ref WHERE id = $1;
$_$;
SELECT pg_c('f', 'ref_info', 'Атрибуты справочника');


/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ref(a_id d_id32, a_item_id d_id32 DEFAULT 0, a_group_id d_id32 DEFAULT 0, a_active_only BOOL DEFAULT TRUE) RETURNS SETOF ref_item STABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_code TEXT;
  BEGIN
  RETURN QUERY
    SELECT *
    FROM ws.ref_item
    WHERE ref_id = a_id
      AND a_item_id IN (id, 0)
      AND a_group_id IN (group_id, 0)
      AND (NOT a_active_only OR deleted_at IS NULL)
      ORDER BY sort
  ;
  IF NOT FOUND THEN
    SELECT INTO v_code code FROM ws.ref WHERE id = a_id;
    IF NOT FOUND THEN
      RAISE EXCEPTION '%', ws.e_nodata();
    END IF;
    RETURN QUERY EXECUTE 'SELECT * FROM ' || v_code || '($1, $2, $3)' USING a_id, a_item_id, a_group_id;
  END IF;
  RETURN;
  END;
$_$;
SELECT pg_c('f', 'ref', 'Значение из справочника ws.ref');
/* ------------------------------------------------------------------------- */
