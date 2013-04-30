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

    Тесты перехода от dt.id к dt.code
*/

/* ------------------------------------------------------------------------- */

SELECT ws.test('dt_check');

\set FILE :TEST .inc

\set CODE text
\i :FILE
\set CODE numeric
\i :FILE
\set CODE integer
\i :FILE
\set CODE json
\i :FILE
\set CODE uuid
\i :FILE
\set CODE ws.d_emails
\i :FILE
\set CODE ws.d_id32a
\i :FILE
\set CODE ws.facet
\i :FILE
\set CODE ws.z_facet
\i :FILE
\set CODE ws.t_hashtable
\i :FILE
\set CODE ws.z_cache
\i :FILE
\set CODE ws.dt_part
\i :FILE

-- TODO: не работает в pg 9.0
-- SELECT * FROM ws.dt_tree('ws.d_acls') AS d_acls_tree;


/* ------------------------------------------------------------------------- */
