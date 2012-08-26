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

    Функции работы с загружаемыми файлами
*/

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION doc_file_add (
  a__sid        text
, a_id        ws.d_id
, a_name     text
, a_path     text
, a_size     integer
, a_ctype    text
, a_csum     text
, a_prefix   text DEFAULT NULL
, a_anno     text DEFAULT NULL
  ) RETURNS SETOF wsd.file LANGUAGE 'plpgsql' AS
$_$
  -- a__sid:      ID сессии
  -- a_id:        ID статьи
  -- a name:     Имя файла
  -- a_path:     Путь к файлу в хранилище nginx
  -- a toc:       Содержание
  DECLARE
    v_account_id INTEGER;
    v_code TEXT;
    r wsd.file;
  BEGIN
    v_account_id := (acc.profile(a__sid)).id;

    INSERT INTO wsd.file (code, name, size, ctype, created_by, csum, anno) VALUES
      (v_code, a_name, a_size, a_ctype, v_account_id, a_csum, a_anno)
      RETURNING * INTO r
    ;
    INSERT INTO wsd.wiki_file (id, file_id)
      VALUES (a_id, r.file_id)
    ;
    RETURN NEXT r;
    RETURN;
  END;
$_$;
SELECT pg_c('f', 'doc_file_add', 'Добавление в статью загруженного файла');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION doc_file_del (
  a_id        ws.d_id
, a_file_id   ws.d_id
) RETURNS BOOL LANGUAGE 'plpgsql' AS
$_$
  BEGIN
    DELETE FROM wsd.wiki_file WHERE id = a_id AND file_id = a_file_id;
    -- TODO: если файл уже нигде не используется - удалить его?
    RETURN TRUE;
  END;
$_$;
SELECT pg_c('f', 'doc_file_del', 'Удаление файла из статьи');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION doc_file (
  a_id        ws.d_id
, a_file_id   ws.d_id DEFAULT 0
) RETURNS SETOF doc_file_info LANGUAGE 'sql' AS
$_$
  SELECT * FROM wiki.doc_file_info WHERE id = $1 AND $2 IN (file_id, 0);
$_$;
SELECT pg_c('f', 'doc_file', 'Атрибуты файлов статьи');

/* ------------------------------------------------------------------------- */
