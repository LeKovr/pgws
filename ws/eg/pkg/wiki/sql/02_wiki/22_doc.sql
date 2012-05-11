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
CREATE TABLE doc_extra (
  id                  d_id32  PRIMARY KEY REFERENCES wiki_data.doc
  , is_toc_preferred  bool    NOT NULL DEFAULT FALSE
  , toc               text
  , anno              text
);
SELECT pg_c('t', 'doc_extra', 'Дополнительные данные статьи wiki')
  ,pg_c('c', 'doc_extra.id', 'ID статьи')
  ,pg_c('c', 'doc_extra.is_toc_preferred', 'В кратком списке выводить не аннотацию а содержание')
;


/* ------------------------------------------------------------------------- */
CREATE TABLE doc_link (
  id            d_id32  NOT NULL REFERENCES wiki_data.doc
  , path        text    NOT NULL
  , is_wiki     bool    NOT NULL DEFAULT TRUE -- TODO считать триггером или при запросе
  , link_id     d_id    REFERENCES wiki_data.doc
  , CONSTRAINT  doc_link_pkey PRIMARY KEY (id, path)
);
SELECT pg_c('t', 'doc_link', 'Ссылка на внутренние документы статьи wiki')
  ,pg_c('c', 'doc_link.id', 'ID статьи')
;

/* ------------------------------------------------------------------------- */
\qecho '-- FD: wiki:wiki:22_doc.sql / 52 --'
