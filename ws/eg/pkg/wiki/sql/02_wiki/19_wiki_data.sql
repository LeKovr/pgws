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
--  19_wiki_data.sql - Создание схемы wiki_data и ее объектов.
-- Выполняется только при отсутствии схемы wiki_data
/* ------------------------------------------------------------------------- */
\qecho '-- FD: wiki:wiki:19_wiki_data.sql / 24 --'

CREATE SCHEMA wiki_data;

/* ------------------------------------------------------------------------- */
CREATE TABLE wiki_data.doc_group (
  id      INTEGER PRIMARY KEY
  , code  TEXT    NOT NULL UNIQUE
  , name  TEXT    NOT NULL
  , anno  TEXT    NOT NULL
);

/* ------------------------------------------------------------------------- */
CREATE TABLE wiki_data.doc (
  id           INTEGER      PRIMARY KEY
  , status_id  INTEGER      NOT NULL DEFAULT 1
  , group_id   INTEGER      NOT NULL REFERENCES wiki_data.doc_group
  , up_id      INTEGER      REFERENCES wiki_data.doc
  , code       TEXT         NOT NULL DEFAULT ''
  , revision   INTEGER      NOT NULL DEFAULT 1
  , pub_date   DATE
  , created_by INTEGER      NOT NULL REFERENCES acc_data.account
  , created_at TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP
  , updated_by INTEGER      NOT NULL REFERENCES acc_data.account
  , updated_at TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP
  , cached_at  TIMESTAMP(0)
  , status_next_id INTEGER
  , status_next_at TIMESTAMP(0)
  , src        TEXT         NOT NULL
  , name       TEXT
  , CONSTRAINT group_id_code_ukey UNIQUE (group_id, code)
);

SELECT pg_c('t', 'wiki_data.doc', 'Статья wiki')
  ,pg_c('c', 'wiki_data.doc.code', 'Код статьи (URI)')
  ,pg_c('c', 'wiki_data.doc.updated_at', 'Момент последнего редактирования')
  ,pg_c('c', 'wiki_data.doc.cached_at', 'Момент актуализации кэша')
;

CREATE SEQUENCE wiki_data.doc_id_seq;
ALTER TABLE wiki_data.doc ALTER COLUMN id SET DEFAULT NEXTVAL('wiki_data.doc_id_seq');

/* ------------------------------------------------------------------------- */
CREATE TABLE wiki_data.doc_diff (
  id            INTEGER       REFERENCES wiki_data.doc
  , revision    INTEGER       NOT NULL
  , updated_by  INTEGER       NOT NULL REFERENCES acc_data.account
  , updated_at  TIMESTAMP(0)  NOT NULL DEFAULT CURRENT_TIMESTAMP
  , diff_src    TEXT
  , CONSTRAINT  doc_diff_pkey PRIMARY KEY (id, revision)
);
SELECT pg_c('t', 'wiki_data.doc_diff', 'Изменения между ревизиями статьи wiki')
  ,pg_c('c', 'wiki_data.doc_diff.id', 'ID статьи')
;

/* ------------------------------------------------------------------------- */
SELECT ws.pkg_oper_add('wiki_data');

/* ------------------------------------------------------------------------- */
INSERT INTO wiki_data.doc_group (id, code, name, anno) VALUES
  (1, 'wk', 'Public','Public info')
  , (2, 'sys', 'Internal', 'Internal info')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE wiki_data.doc_keyword (
  id           INTEGER REFERENCES wiki_data.doc
  , name       TEXT
  , CONSTRAINT doc_keyword_pkey PRIMARY KEY (id, name)
);
SELECT pg_c('t', 'wiki_data.doc_keyword', 'Ключевые слова')
  ,pg_c('c', 'wiki_data.doc_keyword.id', 'ID статьи')
  ,pg_c('c', 'wiki_data.doc_keyword.name', 'Слово')
;

/* ------------------------------------------------------------------------- */
\qecho '-- FD: wiki:wiki:19_wiki_data.sql / 100 --'
