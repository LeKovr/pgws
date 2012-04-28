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
\qecho '-- FD: wiki:wiki:22_doc.sql / 23 --'

/* ------------------------------------------------------------------------- */
CREATE TABLE doc_group (
  id      d_id32 PRIMARY KEY
  , code  d_code NOT NULL UNIQUE
  , name  text   NOT NULL
  , anno  text   NOT NULL
);

/* ------------------------------------------------------------------------- */
CREATE TABLE doc (
  id           d_id    PRIMARY KEY
  , status_id  d_id32  NOT NULL DEFAULT 1
  , group_id   d_id32  NOT NULL REFERENCES doc_group
  , code       d_path  NOT NULL
  , created_by d_id    NOT NULL REFERENCES acc.account
  , created_at d_stamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  , updated_at d_stamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  , cached_at  d_stamp
  , name       text
  , anno       text
  , toc        text
  , src        text
  , CONSTRAINT group_id_code_ukey UNIQUE (group_id, code)
);

SELECT pg_c('t', 'doc', 'Статья wiki')
  ,pg_c('c', 'doc.code', 'Код статьи (URI)')
  ,pg_c('c', 'doc.updated_at', 'Момент последнего редактирования')
  ,pg_c('c', 'doc.cached_at', 'Момент актуализации кэша')
;

CREATE SEQUENCE doc_id_seq;
ALTER TABLE doc ALTER COLUMN id SET DEFAULT NEXTVAL('doc_id_seq');

/* ------------------------------------------------------------------------- */
\qecho '-- FD: wiki:wiki:22_doc.sql / 60 --'
