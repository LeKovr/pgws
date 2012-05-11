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
\qecho '-- FD: pgws:ws:20_ref.sql / 23 --'

/* ------------------------------------------------------------------------- */
CREATE TABLE ref (
  id           ws.d_id32 PRIMARY KEY
  , class_id   d_class  NOT NULL REFERENCES class
  , name       TEXT NOT NULL
  , code       ws.d_code
  , updated_at ws.d_stamp NOT NULL DEFAULT '2010-01-01'
);

COMMENT ON TABLE  ref IS 'Справочник';
COMMENT ON COLUMN ref.id         IS 'ID';
COMMENT ON COLUMN ref.name       IS 'Название';
COMMENT ON COLUMN ref.code       IS 'Метод доступа';
COMMENT ON COLUMN ref.updated_at IS 'Момент последнего изменения';

/* ------------------------------------------------------------------------- */
CREATE TABLE ref_item (
  ref_id       ws.d_id32 REFERENCES ref
  , id         ws.d_id32 NOT NULL
  , sort       ws.d_sort
  , name       text NOT NULL
  , group_id   ws.d_id32 NOT NULL DEFAULT 1
  , deleted_at ws.d_stamp
  , CONSTRAINT ref_item_pkey PRIMARY KEY (ref_id, id)
);

COMMENT ON TABLE  ref_item IS 'Позиция справочника';
COMMENT ON COLUMN ref_item.ref_id  IS 'ID справочника';
COMMENT ON COLUMN ref_item.id         IS 'ID позиции';
COMMENT ON COLUMN ref_item.sort       IS 'Порядок сортировки';
COMMENT ON COLUMN ref_item.name       IS 'Название';
COMMENT ON COLUMN ref_item.group_id   IS 'Внутренний ID группы';
COMMENT ON COLUMN ref_item.deleted_at IS 'Момент удаления';

/* ------------------------------------------------------------------------- */
\qecho '-- FD: pgws:ws:20_ref.sql / 60 --'
