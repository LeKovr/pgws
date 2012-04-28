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
-- 21_main.sql - Таблицы API
/* ------------------------------------------------------------------------- */
\qecho '-- FD: wiki:wiki:42_doc.sql / 23 --'

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW doc_info AS SELECT
  d.id
  , d.status_id
  , d.group_id
  , d.code
  , created_by
  , d.created_at
  , d.updated_at
  , d.name
  , dg.name AS group_name
  , a.name AS created_by_name
  FROM wiki.doc d
  JOIN wiki.doc_group dg ON (d.group_id = dg.id)
  JOIN wiki.account a ON (d.created_by = a.id)
;


/* ------------------------------------------------------------------------- */
\qecho '-- FD: wiki:wiki:42_doc.sql / 44 --'
