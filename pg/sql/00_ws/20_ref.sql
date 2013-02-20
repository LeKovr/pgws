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
-- 20_ref.sql - Справочники
/* ------------------------------------------------------------------------- */

/* ------------------------------------------------------------------------- */
CREATE TABLE ref (
  id         ws.d_id32 PRIMARY KEY
, class_id   d_class  NOT NULL REFERENCES class
, name       TEXT NOT NULL
, code       ws.d_code
, updated_at ws.d_stamp NOT NULL DEFAULT '2010-01-01'
);
SELECT pg_c('r', 'ref', 'Справочник')
, pg_c('c', 'ref.id',         'ID')
, pg_c('c', 'ref.name',       'Название')
, pg_c('c', 'ref.code',       'Метод доступа')
, pg_c('c', 'ref.updated_at', 'Момент последнего изменения')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE ref_item (
  ref_id     ws.d_id32 REFERENCES ref
, id         ws.d_id32 NOT NULL
, sort       ws.d_sort
, name       text NOT NULL
, group_id   ws.d_id32 NOT NULL DEFAULT 1
, deleted_at ws.d_stamp
, CONSTRAINT ref_item_pkey PRIMARY KEY (ref_id, id)
);
SELECT pg_c('r', 'ref_item', 'Позиция справочника')
, pg_c('c', 'ref_item.ref_id',     'ID справочника')
, pg_c('c', 'ref_item.id',         'ID позиции')
, pg_c('c', 'ref_item.sort',       'Порядок сортировки')
, pg_c('c', 'ref_item.name',       'Название')
, pg_c('c', 'ref_item.group_id',   'Внутренний ID группы')
, pg_c('c', 'ref_item.deleted_at', 'Момент удаления')
;

/* ------------------------------------------------------------------------- */
