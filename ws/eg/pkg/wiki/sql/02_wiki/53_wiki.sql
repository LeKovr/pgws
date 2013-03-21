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

    Методы класса wiki
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION status(a_id d_id) RETURNS d_id32 STABLE LANGUAGE 'sql' AS
$_$
  SELECT status_id::ws.d_id32 FROM wsd.doc_group WHERE id = $1;
$_$;
SELECT pg_c('f', 'status', 'Статус вики');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION acl(a_id d_id, a__sid d_sid DEFAULT NULL) RETURNS SETOF d_acl STABLE LANGUAGE 'sql' AS
$_$
  SELECT * FROM acc.object_acl(wiki.const_class_id(), $1, $2)
$_$;
SELECT pg_c('f', 'acl', 'ACL вики');

/* ------------------------------------------------------------------------- */
-- вернуть описание сервера, отвечающего за экземпляр текущего класса
CREATE OR REPLACE FUNCTION server(a_id d_id) RETURNS SETOF server STABLE LANGUAGE 'plpgsql' AS
$_$
  DECLARE
    v_id  ws.d_id32;
  BEGIN
    v_id := 1; -- расчет id ответственного сервера по id конкурса
    RETURN QUERY
      SELECT *
      FROM ws.server
      WHERE id = v_id
    ;
    RETURN;
  END
$_$;
SELECT pg_c('f', 'server', 'Сервер вики');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION id_by_code (a_code d_code) RETURNS d_id32 STABLE LANGUAGE 'sql' AS
$_$
  -- a_code: Код группы документов
-- TODO: не возвращать ID если нет доступа на чтение к группе
  SELECT id::ws.d_id32
    FROM wsd.doc_group
    WHERE code = $1 /* a_group_code */
  ;
$_$;
SELECT pg_c('f', 'id_by_code', 'ID wiki по ее коду');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION name_by_code (a_code d_code) RETURNS TEXT STABLE LANGUAGE 'sql' AS
$_$
  -- a_code: Код группы документов
-- TODO: не возвращать name если нет доступа на чтение к группе
  SELECT name
    FROM wsd.doc_group
    WHERE code = $1 /* a_group_code */
  ;
$_$;
SELECT pg_c('f', 'name_by_code', 'Название wiki по ее коду');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION doc_id_by_code (
  a_id  d_id
  , a_code      d_path DEFAULT ''
  ) RETURNS d_id STABLE LANGUAGE 'sql' AS
$_$
  -- a_id: ID вики
  -- a_code: Код документа
  SELECT id::ws.d_id
      FROM wsd.doc
      WHERE group_id = $1
        AND code = $2
    ;
$_$;
SELECT pg_c('f', 'doc_id_by_code', 'ID документа по коду');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION doc_by_name (a_id ws.d_id32, a_string TEXT, a_max_rows ws.d_cnt DEFAULT 15) RETURNS SETOF ws.t_hashtable STABLE LANGUAGE 'sql' AS
$_$
  -- a_id: ID wiki
  SELECT id::TEXT, name FROM wiki.doc_info WHERE group_id = $1 AND name ~* $2 ORDER BY name LIMIT $3;
$_$;
SELECT pg_c('f', 'doc_by_name', 'список статей, название которых содержит string');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION keyword_by_name (a_id ws.d_id32, a_string TEXT, a_max_rows ws.d_cnt DEFAULT 15) RETURNS SETOF text STABLE LANGUAGE 'sql' AS
$_$
  -- a_id: ID wiki
  SELECT DISTINCT name FROM wiki.doc_keyword_info WHERE group_id = $1 AND name ~* $2 ORDER BY name LIMIT $3;
$_$;
SELECT pg_c('f', 'keyword_by_name', 'список ключевых слов wiki, содержащих строку string');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION doc_create (
  a__sid        text
  , a_id        ws.d_id
  , a_code      ws.d_path DEFAULT ''
  , a_src       text      DEFAULT ''
  , a_name      text      DEFAULT ''
  , a_links     d_links   DEFAULT NULL
  , a_anno      text      DEFAULT ''
  , a_toc       text      DEFAULT ''
  ) RETURNS d_id LANGUAGE 'plpgsql' AS
$_$
  -- a__sid:      ID сессии
  -- a_id:        ID wiki
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
    v_account_id := (acc.profile(a__sid)).id;
    IF v_account_id IS NULL THEN
      RAISE EXCEPTION 'unknown account'; -- TODO: ERRORCODE from acc.
    END IF;

    SELECT INTO v_doc_id
      id
      FROM wsd.doc
      WHERE group_id = a_id
        AND code = a_code
    ;
    IF FOUND THEN
      RAISE EXCEPTION '%', ws.error_str(wiki.const_error_codeexists(), v_doc_id::text);
    END IF;

    INSERT INTO wsd.doc (group_id, status_id, code, created_by, updated_by, name, src)
      VALUES (a_id, wiki.const_doc_status_id_draft(), a_code, v_account_id, v_account_id, a_name, a_src)
      RETURNING id INTO v_doc_id
    ;

    PERFORM wiki.doc_update_extra(a__sid, v_doc_id, a_links, a_anno, a_toc);

    RETURN v_doc_id;
  END;
$_$;
SELECT pg_c('f', 'doc_create', 'Создание документа');
