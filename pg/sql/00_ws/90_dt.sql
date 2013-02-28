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

    Тесты
*/

/* ------------------------------------------------------------------------- */
\set TYPES '''{text, numeric, integer, json, uuid, ws.d_emails, ws.d_id32a, ws.facet, ws.z_facet, ws.t_hashtable, ws.z_cache, ws.dt_part}''::text[]'

SELECT ws.test('dt_check');

SELECT ws.dt_parent_base_code(code), ws.dt_is_complex(code), ws.dt_code(code), ws.dt(code), array(select ws.dt_facet(code)) as dt_facet, array(select dt_tree::text from ws.dt_tree(code)) as dt_tree
  FROM ws.dt
  WHERE code = ANY(:TYPES)
  ORDER BY code
;

SELECT array(select ws.dt_part(code)) as dt_part, ws.dt_parts(code)
  FROM ws.dt
  WHERE code = ANY(:TYPES)
    AND is_complex = true
  ORDER BY code
;

SELECT * FROM ws.dt_tree('ws.d_acls');


/* ------------------------------------------------------------------------- */
