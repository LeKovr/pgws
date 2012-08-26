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

    Методы класса doc, используемые методами wiki
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION doc_update_extra (
  a__sid        text
  , a_id        ws.d_id
  , a_links     d_links DEFAULT NULL
  , a_anno      text    DEFAULT ''
  , a_toc       text    DEFAULT ''
  ) RETURNS d_id LANGUAGE 'plpgsql' AS
$_$
  -- a__sid:      ID сессии
  -- a_id:        ID статьи
  -- a links:     Список внешних ссылок
  -- a_anno:      Аннотация
  -- a toc:       Содержание
  DECLARE
    v_account_id ws.d_id;
    v_revision ws.d_id;
  BEGIN
    v_account_id := (acc.profile(a__sid)).id;
    IF v_account_id IS NULL THEN
      RAISE EXCEPTION 'unknown account'; -- TODO: ERRORCODE
    END IF;
    -- TODO: save diff and v_account_id
    UPDATE wsd.doc SET
        cached_at = CURRENT_TIMESTAMP
      WHERE id = a_id
    ;
    IF NOT FOUND THEN
      RAISE EXCEPTION '%', ws.e_nodata();
    END IF;

    UPDATE wiki.doc_extra SET
      anno = a_anno
      , toc = a_toc
      WHERE id = a_id
    ;
    IF NOT FOUND THEN
      INSERT INTO wiki.doc_extra (id, anno, toc)
        VALUES (a_id, a_anno, a_toc)
      ;
    END IF;
    DELETE FROM wiki.doc_link WHERE id = a_id;
    IF a_links IS NOT NULL THEN
      INSERT INTO wiki.doc_link (id, path)
        SELECT a_id, link FROM unnest(a_links) link
      ;
    END IF;
    RETURN a_id;
  END;
$_$;
SELECT pg_c('f', 'doc_update_extra', 'Обновление вторичных данных',$_$/*
внутренний метод, вызывается при создании и изменении статьи.
обновляет извлеченные из текста аннотацию, содержание и список ссылок
*/$_$);

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION doc_group_id (a_id ws.d_id) RETURNS INTEGER STABLE LANGUAGE 'sql' AS
$_$
  -- a_id: ID статьи
  SELECT group_id FROM wsd.doc WHERE id = $1;
$_$;
SELECT pg_c('f', 'doc_group_id', 'ID вики по ID статьи');

/* ------------------------------------------------------------------------- */
