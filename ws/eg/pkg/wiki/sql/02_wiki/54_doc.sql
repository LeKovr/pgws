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

    Методы класса doc
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION doc_status(a_id d_id) RETURNS d_id32 STABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_status_id ws.d_id32;
  BEGIN
    SELECT INTO v_status_id
      status_id::ws.d_id32
      FROM wsd.doc_group WHERE id = wiki.doc_group_id(a_id)
    ;
    IF v_status_id = wiki.const_status_id_online() THEN
      -- wiki online, используем статус статьи
      SELECT INTO v_status_id
        status_id::ws.d_id32
        FROM wsd.doc WHERE id = a_id
      ;
    END IF;
    RETURN v_status_id;
  END;
$_$;
SELECT pg_c('f', 'doc_status', 'Статус статьи вики');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION doc_acl(a_id d_id, a__sid d_sid DEFAULT NULL) RETURNS SETOF d_acl STABLE LANGUAGE 'sql' AS
$_$
  SELECT * FROM acc.object_acl(wiki.const_class_id(), wiki.doc_group_id($1), $2)
  -- TODO: добавить acl автора
$_$;
SELECT pg_c('f', 'doc_acl', 'ACL вики');

/* ------------------------------------------------------------------------- */
-- вернуть описание сервера, отвечающего за экземпляр текущего класса
CREATE OR REPLACE FUNCTION doc_server(a_id d_id) RETURNS SETOF server STABLE LANGUAGE 'sql' AS
$_$
  SELECT wiki.server(wiki.doc_group_id($1))
$_$;
SELECT pg_c('f', 'wiki_server', 'Сервер вики');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION doc_info (a_id d_id) RETURNS SETOF doc_info STABLE LANGUAGE 'plpgsql' AS
$_$
  -- a_id: ID статьи
  BEGIN
    RETURN QUERY SELECT * FROM wiki.doc_info WHERE id = a_id;
  END;
$_$;
SELECT pg_c('f', 'doc_info', 'Атрибуты документа');


/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION doc_keyword (a_id ws.d_id) RETURNS SETOF text STABLE LANGUAGE 'sql' AS
$_$
  -- a_id: ID статьи
  SELECT name FROM wsd.doc_keyword WHERE id = $1 ORDER BY name;
$_$;
SELECT pg_c('f', 'doc_keyword', 'список ключевых слов статьи');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION doc_src(a_id d_id) RETURNS TEXT STABLE STRICT LANGUAGE 'sql' AS
$_$
  -- a_id: ID статьи
  SELECT src FROM wsd.doc WHERE id = $1; /* a_id */
$_$;
SELECT pg_c('f', 'doc_src', 'Текст документа');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION doc_extra(a_id d_id) RETURNS doc_extra STABLE STRICT LANGUAGE 'sql' AS
$_$
  -- a_id: ID статьи
  SELECT * FROM wiki.doc_extra WHERE id = $1; /* a_id */
$_$;
SELECT pg_c('f', 'doc_extra', 'Дополнительные данные');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION doc_link(a_id d_id) RETURNS SETOF doc_link STABLE STRICT LANGUAGE 'sql' AS
$_$
  -- a_id: ID статьи
  SELECT * FROM wiki.doc_link WHERE id = $1; /* a_id */
$_$;
SELECT pg_c('f', 'doc_link', 'Ссылки ни внутренние документы');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION doc_diff(a_id d_id, a_revision d_cnt) RETURNS SETOF wsd.doc_diff STABLE STRICT LANGUAGE 'sql' AS
$_$
  -- a_id: ID статьи
  SELECT * FROM wsd.doc_diff WHERE id = $1 /* a_id */ AND revision = $2 /* a_revision */;
$_$;
SELECT pg_c('f', 'doc_diff', 'Изменения заданной ревизии');


/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION doc_update_src (
  a__sid        text
  , a_id        ws.d_id
  , a_revision  ws.d_cnt
  , a_src       text    DEFAULT ''
  , a_name      text    DEFAULT ''
  , a_links     d_links DEFAULT NULL
  , a_anno      text    DEFAULT ''
  , a_toc       text    DEFAULT ''
  , a_diff      text    DEFAULT ''
  ) RETURNS d_id LANGUAGE 'plpgsql' AS
$_$
  -- a__sid:      ID сессии
  -- a_id:        ID статьи
  -- a_revision:  Номер текущей ревизии
  -- a_src:       Текст в разметке wiki
  -- a_name:      Название
  -- a links:     Список внешних ссылок
  -- a_anno:      Аннотация
  -- a toc:       Содержание
  -- a_diff:      Изменения от предыдущей версии
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
      revision = revision + 1
      , updated_by = v_account_id
      , updated_at = CURRENT_TIMESTAMP
      , cached_at = CURRENT_TIMESTAMP
      , name = a_name
      , src = a_src
      WHERE id = a_id
        AND revision = a_revision
      RETURNING revision
        INTO v_revision
    ;
    IF NOT FOUND THEN
      RAISE EXCEPTION '%', ws.error_str(wiki.const_error_norevision(), a_revision::text);
    END IF;

    INSERT INTO wsd.doc_diff (id, revision, updated_at, updated_by, diff_src)
      VALUES (a_id, v_revision, CURRENT_TIMESTAMP, v_account_id, a_diff)
    ;

    PERFORM wiki.doc_update_extra(a__sid, a_id, a_links, a_anno, a_toc);
    RETURN a_id;
  END;
$_$;
SELECT pg_c('f', 'doc_update_src', 'Изменение пользователем текста документа');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION doc_update_attr (
  a__sid              text
  , a_id              ws.d_id
  , a_status_id       ws.d_id32
  , a_up_id           ws.d_id DEFAULT NULL
  , a_status_next_id  ws.d_id DEFAULT NULL
  , a_status_next_at  ws.d_stamp DEFAULT NULL
  , a_keywords        ws.d_texta DEFAULT NULL
  ) RETURNS d_id LANGUAGE 'plpgsql' AS
$_$
  -- a__sid:      ID сессии
  -- a_id:        ID статьи
  -- a_status_id: ID статуса
  -- a_up_id:     ID статьи-предка
  -- a_status_next_id  ID отложенного статуса
  -- a_status_next_at  Время активации отложенного статуса
  -- a_keywords        Ключевые слова
  DECLARE
    v_account_id ws.d_id;
    v_revision ws.d_id;
  BEGIN
    v_account_id := (acc.profile(a__sid)).id;
    IF v_account_id IS NULL THEN
      RAISE EXCEPTION 'unknown account'; -- TODO: ERRORCODE
    END IF;
    -- TODO: валидировать значения status_id, up_id, status_next_id
    -- TODO: заполнить pub_date по факту публикации
    UPDATE wsd.doc SET
      status_id        = a_status_id
      , up_id          = a_up_id
      , status_next_id = a_status_next_id
      , status_next_at = a_status_next_at
      WHERE id = a_id
    ;
    IF NOT FOUND THEN
      RAISE EXCEPTION '%', ws.e_nodata();
    END IF;

    DELETE FROM wsd.doc_keyword  WHERE id = a_id;

    INSERT INTO wsd.doc_keyword (id, name)
      SELECT DISTINCT a_id, name FROM unnest(a_keywords) name
    ;
    RETURN a_id;
  END;
$_$;
SELECT pg_c('f', 'doc_update_attr', 'Изменение атрибутов документа');

