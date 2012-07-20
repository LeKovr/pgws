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

    Методы API пакета
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION group_id_by_code (a_group_code d_code) RETURNS d_id32 STABLE LANGUAGE 'sql' AS
$_$  
  -- a_group_code: Код группы документов
  SELECT id::ws.d_id32
    FROM wsd.doc_group
    WHERE code = $1 /* a_group_code */
  ;
$_$;
SELECT pg_c('f', 'group_id_by_code', 'ID группы документов по ее коду');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ids_by_code (
  a_group_code  d_code
  , a_code      d_path DEFAULT ''
  ) RETURNS t_wiki_ids STABLE LANGUAGE 'plpgsql' AS
$_$  
  -- a_group_code: Код группы документов
  -- a_code: Код документа
  DECLARE
    r_ids wiki.t_wiki_ids;
  BEGIN
    r_ids.group_id := wiki.group_id_by_code(a_group_code);
    IF r_ids.group_id IS NULL THEN
      RAISE EXCEPTION '%', ws.error_str(wiki.const_error_nogroupcode(), a_group_code::text);
    END IF;
    SELECT INTO r_ids.id
      id
      FROM wsd.doc
      WHERE group_id = r_ids.group_id
        AND code = a_code
    ;
    RETURN r_ids;
  END;
$_$;
SELECT pg_c('f', 'ids_by_code', 'ID документа по коду');

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
CREATE OR REPLACE FUNCTION doc_by_name (a_group_id ws.d_id32, a_string TEXT, a_max_rows ws.d_cnt DEFAULT 15) RETURNS SETOF ws.t_hashtable STABLE LANGUAGE 'sql' AS
$_$  
  -- a_id: ID статьи
  SELECT id::TEXT, name FROM wiki.doc_info WHERE group_id = $1 AND name ~ $2 ORDER BY name LIMIT $1;
$_$;
SELECT pg_c('f', 'doc_by_name', 'список статей, название которых содержит string');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION doc_keyword (a_id ws.d_id) RETURNS SETOF text STABLE LANGUAGE 'sql' AS
$_$  
  -- a_id: ID статьи
  SELECT name FROM wsd.doc_keyword WHERE id = $1 ORDER BY name;
$_$;
SELECT pg_c('f', 'doc_keyword', 'список ключевых слов статьи');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION keyword_by_name (a_group_id ws.d_id32, a_string TEXT, a_max_rows ws.d_cnt DEFAULT 15) RETURNS SETOF text STABLE LANGUAGE 'sql' AS
$_$  
  -- a_id: ID статьи
  SELECT name FROM wiki.doc_keyword_info WHERE group_id = $1 AND name ~ $2 ORDER BY name LIMIT $3;
$_$;
SELECT pg_c('f', 'keyword_by_name', 'список ключевых слов, содержащих строку string');

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
CREATE OR REPLACE FUNCTION can_create (
  a__sid    text -- ID сессии
  , a_group_id  ws.d_id32
  , a_code      ws.d_path DEFAULT ''
  ) RETURNS bool STABLE LANGUAGE 'plpgsql' AS
$_$  
  -- a__sid:      ID сессии
  -- a_group_id:  ID группы статей
  -- a_code:      Код статьи
  DECLARE
    v_id  ws.d_id;
    v_group_id ws.d_id32;
  BEGIN
    -- TODO: проверить a_code на приемлемость
    v_group_id := (acc.profile(a__sid,'')).group_id;
    IF v_group_id IS NULL THEN
      RAISE EXCEPTION 'unknown account'; -- TODO: ERRORCODE from acc.
    END IF;
    SELECT INTO v_id
      id
      FROM wsd.doc
      WHERE group_id = v_group_id
        AND code = a_code
    ;
    IF NOT FOUND THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END;
$_$;
SELECT pg_c('f', 'can_create', 'Проверка прав на создание документа');

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
    v_account_id := (acc.profile(a__sid,'')).id;
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
SELECT pg_c('f', 'doc_update_extra', 'Обновление вторичных данных');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION doc_create (
  a__sid        text
  , a_group_id  ws.d_id
  , a_code      ws.d_path DEFAULT ''
  , a_src       text      DEFAULT ''
  , a_name      text      DEFAULT ''
  , a_links     d_links   DEFAULT NULL
  , a_anno      text      DEFAULT ''
  , a_toc       text      DEFAULT ''
  ) RETURNS d_id LANGUAGE 'plpgsql' AS
$_$  
  -- a__sid:      ID сессии
  -- a_group_id:  ID группы статей
  -- a_code:      Код статьи
  -- a_src:       Текст в разметке wiki
  -- a_name:      Название
  -- a links:     Список внешних ссылок
  -- a_anno:      Аннотация
  -- a toc:       Содержание
  DECLARE
    v_account_id ws.d_id;
    v_doc_id ws.d_id;
  BEGIN
    v_account_id := (acc.profile(a__sid,'')).id;
    IF v_account_id IS NULL THEN
      RAISE EXCEPTION 'unknown account'; -- TODO: ERRORCODE from acc.
    END IF;

    SELECT INTO v_doc_id
      id
      FROM wsd.doc
      WHERE group_id = a_group_id
        AND code = a_code
    ;
    IF FOUND THEN
      RAISE EXCEPTION '%', ws.error_str(wiki.const_error_codeexists(), v_doc_id::text);
    END IF;

    INSERT INTO wsd.doc (group_id, code, created_by, updated_by, name, src)
      VALUES (a_group_id, a_code, v_account_id, v_account_id, a_name, a_src)
      RETURNING id INTO v_doc_id
    ;

    PERFORM wiki.doc_update_extra(a__sid, v_doc_id, a_links, a_anno, a_toc);

    RETURN v_doc_id;
  END;
$_$;
SELECT pg_c('f', 'doc_create', 'Создание документа');

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
    v_account_id := (acc.profile(a__sid,'')).id;
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
    v_account_id := (acc.profile(a__sid,'')).id;
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


/* ------------------------------------------------------------------------- */
