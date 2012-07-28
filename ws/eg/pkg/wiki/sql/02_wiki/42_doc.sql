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

    Представления пакета
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW doc_info AS SELECT
  d.id
, d.status_id
, d.group_id
, d.up_id
, d.code
, d.revision
, d.pub_date
, d.created_by
, d.created_at
, d.updated_by
, d.updated_at
, d.status_next_id
, d.status_next_at
, d.name
, dg.status_id AS group_status_id
, dg.name AS group_name
, a.name AS updated_by_name
  FROM wsd.doc d
    JOIN wsd.doc_group dg ON (d.group_id = dg.id)
    JOIN wsd.account a ON (d.created_by = a.id)
;

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW doc_keyword_info AS SELECT
  d.id
, d.group_id
, dk.name
  FROM wsd.doc d
    JOIN wsd.doc_keyword dk USING (id)
;
