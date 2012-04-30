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
  , code       d_path  NOT NULL DEFAULT ''
  , revision   d_cnt   NOT NULL DEFAULT 1
  , created_by d_id    NOT NULL REFERENCES acc.account
  , created_at d_stamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  , updated_by d_id    NOT NULL REFERENCES acc.account
  , updated_at d_stamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  , cached_at  d_stamp
  , src        text NOT NULL
  , name       text
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
CREATE TABLE doc_extra (
  id                  d_id32  PRIMARY KEY REFERENCES doc
  , is_toc_preferred  bool    NOT NULL DEFAULT FALSE
  , toc               text
  , anno              text
);
SELECT pg_c('t', 'doc_extra', 'Дополнительные данные статьи wiki')
  ,pg_c('c', 'doc_extra.id', 'ID статьи')
  ,pg_c('c', 'doc_extra.is_toc_preferred', 'В кратком списке выводить не аннотацию а содержание')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE doc_diff (
  id            d_id32  REFERENCES doc
  , revision    d_cnt   NOT NULL
  , updated_by  d_id    NOT NULL REFERENCES acc.account
  , updated_at  d_stamp NOT NULL DEFAULT CURRENT_TIMESTAMP
  , diff_src    text
  , CONSTRAINT  doc_diff_pkey PRIMARY KEY (id, revision)
);
SELECT pg_c('t', 'doc_diff', 'Изменения между ревизиями статьи wiki')
  ,pg_c('c', 'doc_diff.id', 'ID статьи')
;

/* ------------------------------------------------------------------------- */
CREATE TABLE doc_link (
  id            d_id32  NOT NULL REFERENCES doc
  , path        text    NOT NULL
  , is_wiki     bool    NOT NULL DEFAULT TRUE -- TODO считать триггером или при запросе
  , link_id     d_id    REFERENCES wiki.doc
  , CONSTRAINT  doc_link_pkey PRIMARY KEY (id, path)
);
SELECT pg_c('t', 'doc_link', 'Ссылка ни внутренние документы статьи wiki')
  ,pg_c('c', 'doc_link.id', 'ID статьи')
;

/* ------------------------------------------------------------------------- */
\qecho '-- FD: wiki:wiki:22_doc.sql / 97 --'
