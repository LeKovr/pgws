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
-- 50_add.sql - Метод API add
/* ------------------------------------------------------------------------- */
\qecho '-- FD: wiki:wiki:52_doc.sql / 23 --'

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION group_id_by_code (a_group_code d_code) RETURNS d_id32 STABLE LANGUAGE 'sql' AS
$_$  -- FD: wiki:wiki:52_doc.sql / 27 --
  -- a_group_code: Код группы статей
  SELECT id
    FROM wiki.doc_group
    WHERE code = $1 /* a_group_code */
  ;
$_$;
SELECT pg_c('f', 'group_id_by_code', 'ID группы статей по ее коду');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION ids_by_code (
  a_group_code  d_code
  , a_code      d_path DEFAULT ''
  ) RETURNS t_wiki_ids STABLE LANGUAGE 'plpgsql' AS
$_$  -- FD: wiki:wiki:52_doc.sql / 41 --
  -- a_group_code: Код группы статей
  -- a_code: Код статьи
  DECLARE
    r_ids wiki.t_wiki_ids;
  BEGIN
    r_ids.group_id := wiki.group_id_by_code(a_group_code);
    IF r_ids.group_id IS NULL THEN
      RAISE EXCEPTION 'unknown group code'; -- TODO error_code
    END IF;
    SELECT INTO r_ids.id
      id
      FROM wiki.doc
      WHERE group_id = r_ids.group_id
        AND code = a_code
    ;
    RETURN r_ids;
  END;
$_$;
SELECT pg_c('f', 'ids_by_code', 'ID статьи по ее коду');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION doc_info (a_id d_id) RETURNS SETOF doc_info STABLE LANGUAGE 'plpgsql' AS
$_$  -- FD: wiki:wiki:52_doc.sql / 64 --
  -- a_id: ID статьи
  BEGIN
    RETURN QUERY SELECT * FROM wiki.doc_info WHERE id = a_id;
  END;
$_$;
SELECT pg_c('f', 'doc_info', 'Атрибуты статьи');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION doc_src(a_id d_id) RETURNS TEXT STABLE STRICT LANGUAGE 'sql' AS
$_$  -- FD: wiki:wiki:52_doc.sql / 74 --
  -- a_id: ID статьи
  SELECT src FROM wiki.doc WHERE id = $1; /* a_id */
$_$;
SELECT pg_c('f', 'doc_src', 'Текст статьи');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION can_create (
  a__sid    text -- ID сессии
  , a_group_id  ws.d_id32
  , a_code      ws.d_path DEFAULT ''
  ) RETURNS bool STABLE LANGUAGE 'plpgsql' AS
$_$  -- FD: wiki:wiki:52_doc.sql / 86 --
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
      RAISE EXCEPTION 'unknown account'; -- TODO: ERRORCODE
    END IF;
    SELECT INTO v_id
      id
      FROM wiki.doc
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
SELECT pg_c('f', 'can_create', 'ID статьи по ее коду');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION doc_create (
  a__sid        text      -- ID сессии
  , a_group_id  ws.d_id   -- ID группы статей
  , a_code      ws.d_path DEFAULT '' -- Код статьи
  , a_name      text      DEFAULT '' -- Название статьи
  , a_anno      text      DEFAULT '' -- Аннотация
  , a_src       text      DEFAULT '' -- Текст в разметке wiki
  -- , a_toc   text   -- Содержание
  -- , a_links text[] -- список внутренних ссылок
  ) RETURNS d_id32 LANGUAGE 'plpgsql' AS
$_$  -- FD: wiki:wiki:52_doc.sql / 125 --
  -- a__sid: ID сессии
  -- a_group_id:  ID группы статей
  -- a_code: Код статьи
  -- a_name: Название статьи
  -- a_anno: Аннотация
  -- a_src:  Текст в разметке wiki
  DECLARE
    v_account_id ws.d_id;
  BEGIN
    v_account_id := (acc.profile(a__sid,'')).id;
    IF v_account_id IS NULL THEN
      RAISE EXCEPTION 'unknown account'; -- TODO: ERRORCODE
    END IF;
    INSERT INTO wiki.doc (group_id, code, created_by, name, anno, src)
      VALUES (a_group_id, a_code, v_account_id, a_name, a_anno, a_src)
    ;
    RETURN 1;
  END;
$_$;
SELECT pg_c('f', 'doc_create', 'Создание новой статьи');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION doc_update_src (
  a__sid        text            -- ID сессии
  , a_id        ws.d_id         -- ID статьи
  , a_name      text DEFAULT '' -- Название статьи
  , a_anno      text DEFAULT '' -- Аннотация
  , a_src       text DEFAULT '' -- Текст в разметке wiki
  -- , a_toc   text   -- Содержание
  -- , a_links text[] -- список внутренних ссылок
  ) RETURNS d_id32 LANGUAGE 'plpgsql' AS
$_$  -- FD: wiki:wiki:52_doc.sql / 157 --
  -- a__sid: ID сессии
  -- a_id:   ID статьи
  -- a_name: Название статьи
  -- a_anno: Аннотация
  -- a_src:  Текст в разметке wiki
  DECLARE
    v_account_id ws.d_id;
  BEGIN
    v_account_id := (acc.profile(a__sid,'')).id;
    IF v_account_id IS NULL THEN
      RAISE EXCEPTION 'unknown account'; -- TODO: ERRORCODE
    END IF;
    -- TODO: save diff and v_account_id
    UPDATE wiki.doc SET
      name = a_name
      , anno = a_anno
      , src = a_src
      , updated_at = CURRENT_TIMESTAMP
      , cached_at = CURRENT_TIMESTAMP
      WHERE id = a_id
    ;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'doc id % not found', a_id; -- TODO: ERRORCODE
    END IF;
    RETURN 2;
  END;
$_$;
SELECT pg_c('f', 'doc_update_src', 'Сохранение текста статьи');

/* ------------------------------------------------------------------------- */
\qecho '-- FD: wiki:wiki:52_doc.sql / 188 --'
