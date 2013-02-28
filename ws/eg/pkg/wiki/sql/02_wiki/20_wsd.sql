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

    Добавление объектов в схему wsd
*/

/* ------------------------------------------------------------------------- */
INSERT INTO wsd.pkg_script_protected (code, pkg, ver) VALUES (:'FILE', :'PKG', :'VER');

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.doc_group ( -- wsd.wiki_book
  id          INTEGER PRIMARY KEY
, status_id INTEGER NOT NULL DEFAULT 1
, code      TEXT    NOT NULL UNIQUE
, name      TEXT    NOT NULL
, anno      TEXT    NOT NULL
);

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.doc (
  id           INTEGER      PRIMARY KEY
, status_id  INTEGER      NOT NULL DEFAULT 1
, group_id   INTEGER      NOT NULL REFERENCES wsd.doc_group
, up_id      INTEGER      REFERENCES wsd.doc
, code       TEXT         NOT NULL DEFAULT ''
, revision   INTEGER      NOT NULL DEFAULT 1
, pub_date   DATE
, created_by INTEGER      NOT NULL REFERENCES wsd.account
, created_at TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP
, updated_by INTEGER      NOT NULL REFERENCES wsd.account
, updated_at TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP
, cached_at  TIMESTAMP(0)
, status_next_id INTEGER
, status_next_at TIMESTAMP(0)
, src        TEXT         NOT NULL
, name       TEXT
, CONSTRAINT group_id_code_ukey UNIQUE (group_id, code)
);

SELECT pg_c('r', 'wsd.doc', 'Статья wiki')
, pg_c('c', 'wsd.doc.code', 'Код статьи (URI)')
, pg_c('c', 'wsd.doc.updated_at', 'Момент последнего редактирования')
, pg_c('c', 'wsd.doc.cached_at', 'Момент актуализации кэша')
;

CREATE SEQUENCE wsd.doc_id_seq;
ALTER TABLE wsd.doc ALTER COLUMN id SET DEFAULT NEXTVAL('wsd.doc_id_seq');

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.doc_diff (
  id            INTEGER       REFERENCES wsd.doc
, revision    INTEGER       NOT NULL
, updated_by  INTEGER       NOT NULL REFERENCES wsd.account
, updated_at  TIMESTAMP(0)  NOT NULL DEFAULT CURRENT_TIMESTAMP
, diff_src    TEXT
, CONSTRAINT  doc_diff_pkey PRIMARY KEY (id, revision)
);
SELECT pg_c('r', 'wsd.doc_diff', 'Изменения между ревизиями статьи wiki')
  ,pg_c('c', 'wsd.doc_diff.id', 'ID статьи')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE wsd.doc_keyword (
  id           INTEGER REFERENCES wsd.doc
, name       TEXT
, CONSTRAINT doc_keyword_pkey PRIMARY KEY (id, name)
);
SELECT pg_c('r', 'wsd.doc_keyword', 'Ключевые слова')
, pg_c('c', 'wsd.doc_keyword.id', 'ID статьи')
, pg_c('c', 'wsd.doc_keyword.name', 'Слово')
;
