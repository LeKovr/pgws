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
CREATE OR REPLACE FUNCTION doc_file (
  a_id        ws.d_id
, a_file_id   ws.d_id DEFAULT 0
) RETURNS SETOF fs.file_info LANGUAGE 'sql' AS
$_$
  SELECT * FROM fs.file_info WHERE class_id = wiki.const_doc_class_id() AND obj_id = $1 AND $2 IN (id, 0) ORDER BY created_at;
$_$;
SELECT pg_c('f', 'doc_file', 'Атрибуты файлов статьи');

/* ------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION doc_file_add (
  a__sid      text
, a_id        ws.d_id
, a__path     text
, a__size     integer
, a__csum     text
, a_name      text
, a_ctype     text
, a_anno      text DEFAULT NULL
  ) RETURNS SETOF fs.file_info LANGUAGE 'plpgsql' AS
$_$
  -- a__sid:  ID сессии
  -- a_id:    ID статьи
  -- a__path: Путь к файлу в хранилище nginx
  -- a__size: Размер (байт)
  -- a__csum: Контрольная сумма (sha1)
  -- a_name:  Внешнее имя файла
  -- a_ctype: Content type
  -- a_anno:  Комментарий
  DECLARE
    v_account_id INTEGER;
    v_code TEXT;
    v_file_id INTEGER;
  BEGIN
    -- TODO: content-type & extention control
    v_account_id := (acc.profile(a__sid)).id;
    v_file_id := fs.file_add(v_account_id, 'wiki', a_id, a__path, a__size, a__csum, a_name, NULL, a_ctype, NULL, a_anno);
    RETURN QUERY SELECT * FROM wiki.doc_file(a_id, v_file_id);
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
    DELETE FROM wsd.file_link WHERE class_id = wiki.const_doc_class_id() AND obj_id = a_id AND id = a_file_id;
    -- TODO: если файл уже нигде не используется - удалить его?
    RETURN TRUE;
  END;
$_$;
SELECT pg_c('f', 'doc_file_del', 'Удаление файла из статьи');


/* ------------------------------------------------------------------------- */
